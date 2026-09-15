-------------------------------------------------------------------------------
-- RetroRuns -- Core.lua
-- Namespace, DB lifecycle, event hub, slash commands, shared utilities.
-- No UI frame references. No navigation logic.
-------------------------------------------------------------------------------

local ADDON_NAME = "RetroRuns"
local VERSION    = "3.1.2"

-------------------------------------------------------------------------------
-- Namespace
-------------------------------------------------------------------------------

RetroRuns = {
    VERSION = VERSION,
    frame   = CreateFrame("Frame"),

    -- Localized-string lookup. Returns the English key when no translation
    -- exists.
    L = setmetatable({}, { __index = function(_, key) return key end }),

    -- Per-locale translation tables, keyed by locale code. Each locale
    -- file registers its table here.
    LocaleTables = {},

    currentRaid = nil,

    -- Runtime state -- never written to SavedVariables
    state = {
        bossesKilled          = {},   -- [bossIndex] = true
        -- Kills known only from the shared-lockout sibling's saved row.
        bossesKilledViaPairOnly = {},
        bossPartialKills = {},   -- bossIndex -> { [dungeonEncounterID]=true }
        -- Optional bosses the player chose to bypass. Same key space and
        -- lifetime as bossesKilled, so every reset that clears kills
        -- clears these too.
        bossesSkipped         = {},   -- [bossIndex] = true
        activeStep            = nil,
        testMode              = false,
        loadedRaidKey         = nil,
        lastSeenRaidKey       = nil,
        -- True once UPDATE_INSTANCE_INFO has fired. The load decision defers
        -- only until then.
        instanceInfoSeen      = false,
        lastUnsupportedRaid   = nil,
        currentDifficultyID   = nil,
        currentDifficultyName = nil,
        isReloadingUi         = false, -- captured from PLAYER_ENTERING_WORLD
        zoneLog               = {},   -- ring buffer of zone-change debug lines, shown by /rr diag
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
        -- Legacy CENTER-relative offsets. Kept only as the migration
        -- source; the live anchor is panelAnchorX/Y below.
        panelX       = 0,
        panelY       = 0,
        -- TOPLEFT-relative anchor (panelAnchorY is negative, downward).
        -- Top-left is what every layout path already pins, and unlike a
        -- CENTER offset it does not depend on the frame's SIZE -- which is
        -- what broke: quitting minimized saved the 44-tall bar's center,
        -- and the restore applied it to the 460-tall frame, putting the top
        -- edge (460-44)/2 = 208px out, compounding every launch.
        -- panelAnchorSet gates the one-time migration and is cleared by
        -- Reset to Defaults, so a reset re-derives from panelX/panelY = 0.
        panelAnchorSet = false,
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
        toasterDuration = 5.0,
        -- toasterStayUntilClick: when true, toasts never auto-fade -- they hold
        -- until the user clicks them to dismiss. Overrides toasterDuration.
        toasterStayUntilClick = false,
        -- mapPois: the always-on map POI layer (vendors, rares, doors).
        -- Toggled by the checkbox on the world map; route markers are
        -- unaffected.
        mapPois = true,
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
function RR.Trim(str)
    return (str or ""):match("^%s*(.-)%s*$")
end

--- Prefixed chat output.
function RR:Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage(
        "|cff4DCCFFR|cffF259C7R|r|cff7f7f7f:|r " .. tostring(msg))
end

-- Caret-span highlight color, shared. Proper nouns in authored prose and
-- in map-marker hints wear the same orange; it lived as a literal in two
-- files and the second copy was written from the first by hand.
RR.C_ORANGE = "ff7f00"

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
    self:Print((RR.L["|cffaaaaaav%s loaded. Type |r|cffffffff/rr help|r|cffaaaaaa for commands.|r"]):format(VERSION))
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
--- The entrance a plane navigates to. Most instances carry one position;
--- an instance whose two factions walk in from different places carries an
--- alliance/horde pair instead and the player's own faction picks. Callers
--- always get a flat { mapID, x, y } either way, so nothing downstream has
--- to know which shape the data file used.
function RR:GetRaidEntrance(raid)
    if not raid then return nil end
    local entrance = raid.entrance
    if type(entrance) ~= "table" then return nil end
    if entrance.alliance or entrance.horde then
        -- Anything that is not Horde takes the Alliance side, which covers
        -- the neutral pandaren case without a third branch.
        if UnitFactionGroup("player") == "Horde" then
            return entrance.horde or entrance.alliance
        end
        return entrance.alliance or entrance.horde
    end
    return entrance
end

-- True when an instance carries a step-by-step route. Dungeons ship for
-- transmog browsing and entrance navigation first and gain routing in
-- phases, so the idle list dims the ones that cannot be run yet.
function RR:InstanceHasRouting(instance)
    return type(instance) == "table"
        and type(instance.routing) == "table"
        and #instance.routing > 0
end

-- Routed dungeons among `instances` the account has not seen yet, or nil.
-- The dungeon list stamps NEW on the expansion header until it is opened.
function RR:UnseenRoutedDungeons(instances)
    local seen = RetroRunsDB and RetroRunsDB.seenRoutedDungeons
    if not seen then return nil end
    local unseen
    for _, instance in ipairs(instances or {}) do
        if instance.kind == "dungeon" and self:InstanceHasRouting(instance)
           and not seen[instance.journalInstanceID] then
            unseen = unseen or {}
            unseen[#unseen + 1] = instance
        end
    end
    return unseen
end

function RR:MarkRoutedDungeonsSeen(instances)
    local seen = RetroRunsDB and RetroRunsDB.seenRoutedDungeons
    if not seen then return end
    for _, instance in ipairs(instances or {}) do
        seen[instance.journalInstanceID] = true
    end
end

-- Which expansion's Timewalking is running right now, as one of our own
-- expansion names, or nil when none is.
--
-- Read from the group finder rather than the calendar. The calendar route
-- needs per-REGION event ids -- the same Timewalking week carries different
-- ids on US, EU, KO and TW -- plus a walk of many months to find them; the
-- random-dungeon list is the client answering directly, in whatever region
-- it is running.
--
-- Every Timewalking random is listed at once, one per expansion, whether
-- or not its week is live, and `isTimeWalker` (GetLFGDungeonInfo's 18th
-- return) reads false on all of them. IsLFGDungeonJoinable's first return,
-- isAvailableForAll, is true only for the running event.
--
-- Difficulty 24 is Timewalking -- the same bucket the dungeon data keys its
-- Timewalking-only appearances under -- and it separates a Timewalking week
-- from the other joinable holiday dungeons (Headless Horseman and friends).
-- Tested rather than an id list on purpose: a hardcoded list written before
-- Dragonflight would already be missing 3143.
--
-- KNOWN LIMIT: the random list is what THIS character may queue for, so a
-- character under the event's level floor sees nothing and this reports
-- nil. It is a display hint, never a gate on data.
--
-- The guards below cover secret values on tainted paths; they cost one
-- call each.
local timewalkingCache, timewalkingCacheAt = nil, 0
local TIMEWALKING_CACHE_SECONDS = 30

function RR:GetActiveTimewalkingExpansion()
    local now = GetTime and GetTime() or 0
    if timewalkingCacheAt > 0
        and (now - timewalkingCacheAt) < TIMEWALKING_CACHE_SECONDS then
        return timewalkingCache
    end
    timewalkingCacheAt = now
    timewalkingCache = nil

    if not (GetNumRandomDungeons and GetLFGRandomDungeonInfo
            and GetLFGDungeonInfo and IsLFGDungeonJoinable) then
        return nil
    end
    local total = GetNumRandomDungeons() or 0
    -- An empty list means the client has not delivered its lock info yet
    -- (the first paint after login lands here), not that no week is live.
    -- Leave the cache unstamped so the next ask retries instead of pinning
    -- "no event" for 30 seconds.
    if total == 0 then
        timewalkingCacheAt = 0
        return nil
    end
    for index = 1, total do
        local dungeonID = GetLFGRandomDungeonInfo(index)
        if dungeonID then
            local _, _, _, _, _, _, _, _, expansionLevel,
                  _, _, difficulty = GetLFGDungeonInfo(dungeonID)
            local joinable = IsLFGDungeonJoinable(dungeonID)
            local tainted = issecretvalue
                and (issecretvalue(expansionLevel)
                     or issecretvalue(difficulty) or issecretvalue(joinable))
            if not tainted and joinable and difficulty == 24
                and expansionLevel then
                -- expansionLevel counts up from 0 at Classic; our list runs
                -- newest first. Derived rather than a second table, so a new
                -- expansion added to that one list is picked up here too.
                local order = RR.EXPANSION_ORDER_NEWEST_FIRST
                local name = order and order[#order - expansionLevel]
                if name then
                    timewalkingCache = name
                    return name
                end
            end
        end
    end
    return nil
end

-- The lock-info push the login paint was missing (LFG_LOCK_INFO_RECEIVED).
-- Re-ask with the cache cleared; repaint only when the answer actually
-- moved, since other addons request this info too and the event re-fires.
function RR:RefreshTimewalkingFromLockInfo()
    local previous = timewalkingCache
    timewalkingCacheAt = 0
    if self:GetActiveTimewalkingExpansion() ~= previous
        and self.UI and self.UI.Update then
        if self.UI.InvalidateIdleListCache then
            self.UI.InvalidateIdleListCache()
        end
        self.UI.Update()
    end
end

-- When the running Timewalking week ends: days remaining, and the calendar
-- day it closes on. Returns nil for both when it cannot be determined.
--
-- The group finder knows WHICH expansion is running but not for how long,
-- so the end date has to come off the calendar. The trap there is that
-- Timewalking calendar event ids are per-REGION -- there are four regional
-- tables of them -- so matching by id would need a table that rots.
--
-- Matched by TITLE against PLAYER_DIFFICULTY_TIMEWALKER instead, the
-- client's own localized word for the difficulty. Blizzard names the event
-- with that word, so
-- the match holds in every locale without an id table anywhere. If a locale
-- inflects the word so the match fails, the date simply goes unreported --
-- the marker still shows.
--
-- Walked forward from today rather than over the whole calendar: the event
-- runs about a week, so this month and the next cannot miss it, where a full
-- walk would span 36 months for no gain.
local twEndCache, twEndCacheAt = nil, 0
local TW_END_CACHE_SECONDS = 900   -- a date does not move; this is for logins
-- A read that FOUND nothing is held for seconds, not minutes. The calendar
-- answers empty until its data arrives, so the first read after a login or a
-- zone routinely misses -- and caching that miss for the full window leaves
-- the marker untinted for a quarter of an hour with the week still running.
local TW_END_RETRY_SECONDS = 15

function RR:GetTimewalkingEnd()
    local now = GetTime and GetTime() or 0
    local window = twEndCache and TW_END_CACHE_SECONDS or TW_END_RETRY_SECONDS
    if twEndCacheAt > 0 and (now - twEndCacheAt) < window then
        if not twEndCache then return nil end
        return twEndCache.days, twEndCache.month, twEndCache.day,
               twEndCache.hour, twEndCache.minute
    end
    twEndCacheAt = now
    twEndCache = nil

    local term = PLAYER_DIFFICULTY_TIMEWALKER
    if not term or term == "" then return nil end
    if not (C_Calendar and C_Calendar.GetNumDayEvents and C_Calendar.GetDayEvent
            and C_Calendar.GetMonthInfo and C_DateAndTime
            and C_DateAndTime.GetCurrentCalendarTime) then
        return nil
    end
    -- The calendar answers empty until it has been opened once.
    if C_Calendar.OpenCalendar then C_Calendar.OpenCalendar() end
    local today = C_DateAndTime.GetCurrentCalendarTime()
    if not today or not today.monthDay then return nil end

    local thisMonth = C_Calendar.GetMonthInfo(0)
    local daysThisMonth = (thisMonth and thisMonth.numDays) or 31

    for monthOffset = 0, 1 do
        local firstDay = (monthOffset == 0) and today.monthDay or 1
        local lastDay = (monthOffset == 0) and daysThisMonth or 31
        for day = firstDay, lastDay do
            local count = C_Calendar.GetNumDayEvents(monthOffset, day) or 0
            for index = 1, count do
                local event = C_Calendar.GetDayEvent(monthOffset, day, index)
                local title = event and event.title
                -- Secret-tainted titles error on find(); skip rather than raise.
                local tainted = issecretvalue and title
                    and issecretvalue(title)
                if title and not tainted
                    and title:find(term, 1, true)
                    and event.sequenceType == "END" then
                    local ahead = (monthOffset == 0)
                        and (day - today.monthDay)
                        or (daysThisMonth - today.monthDay + day)
                    local info = C_Calendar.GetMonthInfo(monthOffset)
                    -- The END entry's own time is the hour the week closes
                    -- (a Monday 11:00 start ends the following Monday at
                    -- 10:00, an hour shy of seven days).
                    -- Carried so the last day can be reported in hours
                    -- rather than rounded to a day that is already over.
                    -- endTime, not startTime: on an END entry startTime is
                    -- the segment's start and endTime is when the week
                    -- actually closes.
                    local at = event.endTime or event.startTime
                    twEndCache = {
                        days   = ahead,
                        month  = info and info.month or nil,
                        day    = day,
                        hour   = at and at.hour or nil,
                        minute = at and at.minute or nil,
                    }
                    return ahead, twEndCache.month, day,
                           twEndCache.hour, twEndCache.minute
                end
            end
        end
    end
    return nil
end

-- True when this instance itself offers a Timewalking run, ignoring
-- whether the week is currently running.
--
-- Reads the data files' `timewalking` field, which the dungeon generator
-- emits from db2's MapDifficulty (difficulty 24; the three raids carrying
-- 33 have it by hand). NOT the [24] loot bucket: the 6.2 reprint items
-- track the ORIGINAL rotation (Ahn'kahet, Utgarde Pinnacle carry reprints
-- but cannot host a TW run today), while Utgarde Keep, Azjol-Nerub and
-- The Forge of Souls run TW with no reprints at all. Capability and loot
-- diverge, so they are separate signals.
function RR:InstanceOffersTimewalking(instance)
    return type(instance) == "table" and instance.timewalking == true
end

-- True when this instance can be run at Timewalking RIGHT NOW: it offers a
-- Timewalking version and its expansion is the week that is live.
function RR:IsTimewalkingLive(instance)
    if not self:InstanceOffersTimewalking(instance) then return false end
    local active = self:GetActiveTimewalkingExpansion()
    return active ~= nil and instance.expansion == active
end

-- True when this instance's expansion is the one Timewalking is running
-- for. Dungeon-only: raid Timewalking is a separate rotation the group
-- finder does not answer for this way.
function RR:IsTimewalkingActiveFor(instance)
    if not instance or instance.kind ~= "dungeon" then return false end
    local active = self:GetActiveTimewalkingExpansion()
    return active ~= nil and instance.expansion == active
end

-- True when a dungeon sits in the CURRENT Mythic+ season. Read at runtime
-- from the client rather than authored: the pool rotates every season, so
-- any table we wrote would go stale. GetMapTable returns challenge map
-- ids, which ChallengeMaps.lua translates to our instance map ids.
--
-- Seasonal treatment is per DIFFICULTY, not per dungeon: a dungeon in the
-- pool is not soloable at Mythic while its Normal and Heroic are
-- unaffected.
function RR:IsSeasonalDungeon(instance)
    if not instance or instance.kind ~= "dungeon" then return false end
    if not (C_ChallengeMode and C_ChallengeMode.GetMapTable) then return false end
    local translation = RetroRuns_DungeonMeta
        and RetroRuns_DungeonMeta.challengeMapToInstance
    if not translation then return false end
    for _, challengeMapID in ipairs(C_ChallengeMode.GetMapTable() or {}) do
        if translation[challengeMapID] == instance.instanceID then
            return true
        end
    end
    return false
end

-- A dungeon in the current Mythic+ pool, entered at Heroic, Mythic or
-- Keystone difficulty. Those three are retuned to current level for the
-- season, so it is a group run, not a solo legacy run; nothing loads.
function RR:IsSeasonalMythicEntry(instance, info)
    if not instance or instance.kind ~= "dungeon" then return false end
    local difficultyID = info and info.difficultyID
    if difficultyID ~= 2 and difficultyID ~= 23 and difficultyID ~= 8 then
        return false
    end
    return self:IsSeasonalDungeon(instance)
end

--- Drops a waypoint across the provider stack, returning which slots fired.
---   PLANNER: AWP-with-backend > Zygor > Mapzeroth (one wins).
---   ARROW:   TomTom > Blizzard (suppressed if a planner fired).
---   OVERLAY: AWP-without-backend + WUI (both can layer).
--- Nil when no provider produced any UI.
function RR:NavigateToDestination(mapID, x, y, title, routeContext)
    if not mapID or not x or not y then
        self:Print(RR.L["Destination data is incomplete."])
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
        self:Print(RR.L["No supported waypoint API available."])
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
    local entrance = self:GetRaidEntrance(raid)
    if not raid or not entrance then
        self:Print(RR.L["No entrance data for that instance."])
        return nil
    end
    if not entrance.mapID or not entrance.x or not entrance.y then
        self:Print(RR.L["Entrance data is incomplete."])
        return nil
    end

    local title = (RR.L["RetroRuns: %s entrance"]):format(self:GetLocalizedRaidName(raid) or "raid")
    return self:NavigateToDestination(entrance.mapID, entrance.x, entrance.y, title, raid)
end

--- Drop a waypoint at a Covenant Sanctum weapon vendor (Castle
--- Nathria). Routes through the shared NavigateToDestination dispatch.
function RR:NavigateToSanctum(raid, covID)
    if not raid or not raid.weaponVendors or not covID then
        self:Print(RR.L["No sanctum vendor data available."])
        return nil
    end
    local vendor = raid.weaponVendors[covID]
    if not vendor or not vendor.vendorMapID or not vendor.x or not vendor.y then
        self:Print(RR.L["Sanctum vendor data is incomplete."])
        return nil
    end

    local title = (RR.L["RetroRuns: %s (%s vendor)"]):format(
        (vendor.vendorName and RR.L[vendor.vendorName]) or RR.L["Sanctum"],
        (vendor.covenantName and RR.L[vendor.covenantName]) or RR.L["covenant"])
    return self:NavigateToDestination(vendor.vendorMapID, vendor.x, vendor.y, title, raid)
end

--- Pick the player's faction half of a vendor block, or the block itself
--- when it ships one spot for both. Shared by tokenVendors and by the
--- per-boss omniToken blocks, which take the same faction-split shape.
function RR:ResolveFactionBlock(block)
    if not block then return nil end
    if block.alliance or block.horde then
        local faction = UnitFactionGroup and UnitFactionGroup("player")
        return (faction == "Alliance") and block.alliance or block.horde
    end
    return block
end

--- Look up a dungeon by its data key. The dungeon table is keyed by
--- journalInstanceID, not instance map id: several journal dungeons share
--- one map (Dire Maul's wings, Stratholme's halves), so the map cannot key
--- the table the way it does for raids.
function RR:GetDungeonByKey(journalInstanceID)
    if not journalInstanceID then return nil end
    return RetroRuns_DungeonData and RetroRuns_DungeonData[journalInstanceID]
end

--- Resolve a raid's tokenVendors entry, picking the player's faction half
--- when the raid ships a split.
function RR:GetTokenVendor(raid)
    return self:ResolveFactionBlock(raid and raid.tokenVendors)
end

--- Drop a waypoint at a raid's token-redemption vendor (Icecrown Citadel,
--- Firelands, Siege of Orgrimmar). Routes through the shared
--- NavigateToDestination dispatch.
function RR:NavigateToTokenVendor(raid)
    local vendor = self:GetTokenVendor(raid)
    if not vendor then
        self:Print(RR.L["No token vendor data available."])
        return nil
    end
    -- Raids whose city merchants differ per armor type are routed by the
    -- browser instead, which knows the class being viewed; this path
    -- serves the single-vendor raids.
    local mapID, x, y = vendor.vendorMapID, vendor.x, vendor.y
    if not mapID or not x or not y then
        self:Print(RR.L["No token vendor data available."])
        return nil
    end
    local title = (RR.L["RetroRuns: %s"]):format(
        (vendor.vendorName and RR.L[vendor.vendorName]) or RR.L["Token vendor"])
    return self:NavigateToDestination(mapID, x, y, title, raid)
end

--- The NPC whose gossip queues legacy LFR solo, keyed by raid.expansion.
--- Battle for Azeroth splits by faction. `unverified` coords are approximate.
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
    ["Cataclysm"] = {
        -- Dragon Soul is the only Cataclysm raid with a Raid Finder wing.
        npcName = "Auridormi",
        zone    = "Caverns of Time, Tanaris",
        mapID   = 75, x = 0.631, y = 0.273,
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
        self:Print(RR.L["No LFR queue NPC known for that expansion."])
        return nil
    end
    if not npc.mapID or npc.mapID == 0 or not npc.x or not npc.y then
        -- A zero mapID means the destination isn't routable yet (e.g.
        -- the Garrison, whose mapID varies by faction/building tier and
        -- isn't captured). Tell the player where to go in text instead.
        self:Print((RR.L["LFR queue: talk to %s (%s)."]):format(
            npc.npcName or RR.L["the queue NPC"], RR.L[npc.zone or "see guide"]))
        return nil
    end

    local title = (RR.L["RetroRuns: %s (LFR queue)"]):format(npc.npcName or "queue NPC")
    local result = self:NavigateToDestination(npc.mapID, npc.x, npc.y, title, nil)
    if result and npc.unverified then
        self:Print((RR.L["Note: %s's location is approximate -- look nearby (%s)."]):format(
            npc.npcName or RR.L["the NPC"], npc.zone and RR.L[npc.zone] or ""))
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

--- Normalize a name for fuzzy matching:
--- lowercase, strip punctuation, collapse whitespace.
function RR:NormalizeName(name)
    if not name then return nil end
    name = name:lower()
    name = name:gsub("[\226\128\152\226\128\153'\96]", "") -- curly + straight apostrophes
    -- Primary fold: ASCII alphanumerics, spaces, and hyphens survive;
    -- everything else -- punctuation AND all non-ASCII bytes -- is stripped.
    -- Deliberately aggressive for Latin scripts: the saved-instance lockout
    -- and the Encounter Journal can disagree on accents for the same boss,
    -- and stripping accented characters from both sides lets those match.
    local primary = name:gsub("[^%w%s%-]", "")
    primary = primary:gsub("%s+", " ")
    primary = primary:match("^%s*(.-)%s*$")
    if primary:find("%w") then return primary end
    -- Lua character classes are ASCII-only, so %w destroys a name written
    -- entirely in Hangul, CJK or Cyrillic; one that also carries a hyphen
    -- or a digit would survive the primary fold as just that character
    -- and collide with every other such name. Keeping bytes >= 128 stays
    -- symmetric.
    local fallback = name:gsub("[^%w%s%-\128-\255]", "")
    fallback = fallback:gsub("%s+", " ")
    fallback = fallback:match("^%s*(.-)%s*$")
    if fallback == "" then return nil end
    return fallback
end

--- Truncate to at most maxBytes without slicing a multibyte UTF-8
--- character. A plain :sub(1, N) on localized text can cut mid-sequence,
--- and one invalid byte in a log line makes the whole containing EditBox
--- render blank. Backs the cut up past any continuation bytes so the last
--- included character is always complete.
function RR.Utf8SafeTruncate(text, maxBytes)
    if type(text) ~= "string" or #text <= maxBytes then return text end
    local cut = maxBytes
    while cut > 0 do
        local nextByte = text:byte(cut + 1)
        if not nextByte or nextByte < 0x80 or nextByte > 0xBF then break end
        cut = cut - 1
    end
    return text:sub(1, cut)
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
    local value = RetroRunsDB[key]
    if value == nil then return default end
    if key == "fontSize" and type(value) == "number" and value > RR.FONT_SIZE_MAX then
        return RR.FONT_SIZE_MAX
    end
    return value
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
    local function looksUnverified(text)
        if type(text) ~= "string" then return false end
        local lower = text:lower()
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
    -- routingOptional: dungeons ship browsable and gain routes in phases, so
    -- an absent route is a valid shipped state there, not a defect. Every
    -- other rule applies to both trees.
    local function validateTable(tbl, tableLabel, routingOptional)
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
            if raid.routing == nil then
                -- Absent is legal only where routing is optional.
                if not routingOptional then
                    add("error", raidLabel, "missing or empty routing table")
                end
            elseif type(raid.routing) ~= "table" or #raid.routing == 0 then
                -- Present but unusable is a defect in either tree: the key
                -- was authored and says nothing.
                add("error", raidLabel, "missing or empty routing table")
            end

            -- Build a set of valid boss indices for cross-checking,
            -- and validate specialLoot while we're at it.
            local validBossIndices = {}
            local VALID_SPECIAL_KINDS = { mount = true, pet = true, toy = true, decor = true, manuscript = true, illusion = true, musicroll = true }
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
                                    bp .. " missing kind (mount|pet|toy|decor|manuscript|illusion|musicroll)")
                            elseif not VALID_SPECIAL_KINDS[item.kind] then
                                add("error", raidLabel,
                                    bp .. (" unrecognized kind '%s' (expected mount|pet|toy|decor|manuscript|illusion|musicroll)"):format(
                                        tostring(item.kind)))
                            end
                            -- Illusions need their own sourceID.
                            if item.kind == "illusion" and not item.sourceID then
                                add("error", raidLabel,
                                    bp .. " kind=illusion requires sourceID field for transmog API validation")
                            end
                            -- Quest-flag collectibles resolve their
                            -- collected state from the completed-quest
                            -- flag, so a missing questID renders them
                            -- permanently uncollected rather than erroring.
                            if (item.kind == "manuscript" or item.kind == "musicroll")
                               and not item.questID then
                                add("error", raidLabel,
                                    bp .. (" kind=%s requires questID field for collection tracking"):format(item.kind))
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
                            elseif seg.triggeredBy.encounter then
                                if type(seg.triggeredBy.encounter) ~= "number" then
                                    add("error", raidLabel,
                                        sp .. (" segment %d triggeredBy.encounter must be a dungeonEncounterID"):format(si))
                                end
                            elseif seg.triggeredBy.scenario then
                                if type(seg.triggeredBy.scenario) ~= "number" then
                                    add("error", raidLabel,
                                        sp .. (" segment %d triggeredBy.scenario must be a scenario criteriaID"):format(si))
                                end
                            else
                                -- triggeredBy with no known sub-key (e.g. just empty {})
                                add("warn", raidLabel,
                                    sp .. (" segment %d triggeredBy has no recognized sub-key (expected dialog, encounter, or scenario)"):format(si))
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

                        -- Usually a copy-paste slip, though not always.
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

    validateTable(RetroRuns_Data,        "Data")
    validateTable(RetroRuns_DataHorde,   "DataHorde")
    -- Dungeons carry routing in their own data table and are linted by the
    -- same rules. Omitting this table made a scoped run over a dungeon
    -- report zero issues because it had examined zero instances.
    validateTable(RetroRuns_DungeonData, "DungeonData", true)
    return issues
end

-- Load-time walk: errors only. Warnings live in the on-demand linter.
local function ValidateRaidData()
    local issues = CollectRaidDataIssues(nil)
    for _, issue in ipairs(issues) do
        if issue.severity == "error" then
            RR:Debug(("Data[%s]: %s"):format(issue.raid, issue.msg))
        end
    end
end

--- On-demand linter: every issue, errors and warnings, in a copy window.
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
    local function add(line) table.insert(out, line) end

    add("RetroRuns -- Route Lint Report")
    if scopeFilter and scopeFilter ~= "" then
        add(("Scope: instances matching %q"):format(scopeFilter))
    else
        add("Scope: all loaded instances")
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
    local existingAccount = type(RetroRunsDB) == "table" and next(RetroRunsDB) ~= nil
    RetroRunsDB = RetroRunsDB or {}
    MergeDefaults(RetroRunsDB, self.defaults)

    -- Routed dungeons this account has opened an expansion for. Absent on
    -- the first run: every routed dungeon counts as seen, except the ones
    -- routed in this very version on an account that ran an earlier one.
    if not RetroRunsDB.seenRoutedDungeons then
        local seen = {}
        for _, dungeon in pairs(RetroRuns_DungeonData or {}) do
            if self:InstanceHasRouting(dungeon)
               and not (existingAccount and dungeon.routedIn == RetroRuns.VERSION) then
                seen[dungeon.journalInstanceID] = true
            end
        end
        RetroRunsDB.seenRoutedDungeons = seen
    end

    -- launchMode is applied from PLAYER_ENTERING_WORLD on initial login, not
    -- here: this runs on /reload too, and a reload is not a login. Applying
    -- it here discarded whatever the panel was showing before the reload.

    -- Only the long-lived log survives /reload, bucketed per character. An
    -- integer index means the old flat-list shape and is discarded.
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
    -- A queued auto-stamp event that fired while recording was inactive.
    -- Stored as epoch seconds so the staleness check survives /reload.
    if RetroRunsDB.recorderPendingEvent and self.recorder then
        self.recorder.pendingEvent = RetroRunsDB.recorderPendingEvent
    end

    -- RR.state.zoneLog aliases RetroRunsDB.zoneLog, so it survives /reload.
    -- Wiped on initial login; the entry cap lives in RR:ZoneLog.
    RetroRunsDB.zoneLog = RetroRunsDB.zoneLog or {}
    self.state.zoneLog = RetroRunsDB.zoneLog

    -- The transmog browser's class filter used to be saved here. It is
    -- runtime state now, so any value left by an earlier version is dead
    -- weight; drop it rather than leave it in the file forever.
    RetroRunsDB.tmogClassFilter      = nil
    RetroRunsDB.tmogClassFilterOwner = nil
end

-- Load-time visibility: hidden, minimized, or full. Anything unrecognized
-- falls through to minimized. Initial login only, so a /reload leaves the
-- panel in whatever state the player had it.
function RR:ApplyLaunchMode()
    if not RetroRunsDB then return end
    local launchMode = self:GetSetting("launchMode", "minimized")
    if launchMode == "hidden" then
        RetroRunsDB.showPanel = false
    elseif launchMode == "full" then
        RetroRunsDB.showPanel = true
        RetroRunsDB.minimized = false
    else
        RetroRunsDB.showPanel = true
        RetroRunsDB.minimized = true
    end
end

-- Screen geometry -> TOPLEFT offsets in the frame's own scaled space.
-- Offsets divide by the FRAME's effective scale, not UIParent's (Wowpedia
-- "UI scaling"), the same rule the drag and resize maths follow.
local function TopLeftOffsets(frame)
    local fl, ft = frame:GetLeft(), frame:GetTop()
    local pl, pt = UIParent:GetLeft(), UIParent:GetTop()
    if not (fl and ft and pl and pt) then return nil end
    local fscale = frame:GetEffectiveScale()
    local pscale = UIParent:GetEffectiveScale()
    return (fl * fscale - pl * pscale) / fscale,
           (ft * fscale - pt * pscale) / fscale
end
RR.TopLeftOffsets = TopLeftOffsets

function RR:RestorePanelPosition(source)
    if not RetroRunsUI then return end
    local trace = RR.UI and RR.UI._panelPosTrace
    RetroRunsUI:ClearAllPoints()

    if not self:GetSetting("panelAnchorSet") then
        -- One-time migration. Apply the legacy CENTER offset, read where
        -- that actually put the frame, and store it as a TOPLEFT anchor.
        -- Converting through live geometry rather than arithmetic keeps
        -- scale handling identical to every other path here.
        local x, y = self:GetSetting("panelX", 0), self:GetSetting("panelY", 0)
        RetroRunsUI:SetPoint("CENTER", UIParent, "CENTER", x, y)
        local left, top = TopLeftOffsets(RetroRunsUI)
        if left and top then
            self:SetSetting("panelAnchorX", left)
            self:SetSetting("panelAnchorY", top)
            self:SetSetting("panelAnchorSet", true)
            RetroRunsUI:ClearAllPoints()
            RetroRunsUI:SetPoint("TOPLEFT", UIParent, "TOPLEFT", left, top)
        end
        if trace then
            table.insert(trace, ("MIGRATE(%s) center x=%s y=%s -> left=%s top=%s")
                :format(source or "?", x, y,
                        left and math.floor(left + 0.5) or "?",
                        top and math.floor(top + 0.5) or "?"))
        end
        return
    end

    local left = self:GetSetting("panelAnchorX", 0)
    local top  = self:GetSetting("panelAnchorY", 0)
    RetroRunsUI:SetPoint("TOPLEFT", UIParent, "TOPLEFT", left, top)
    if trace then
        table.insert(trace, ("RESTORE(%s) left=%s top=%s"):format(
            source or "?", math.floor(left + 0.5), math.floor(top + 0.5)))
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
    -- journalInstanceID rides the key because instanceID alone cannot tell
    -- Dire Maul's wings apart: zoning in resolves the wing from the player's
    -- uiMap, which is still the OUTSIDE map for the first beat, so the first
    -- pass lands on the fallback wing. With the wing in the key, the beat
    -- where the real map arrives is itself a context change and re-runs the
    -- wipe/restore/seed for the wing the player is actually in.
    return tostring(raid.instanceID or info.instanceID or "?")
           .. ":" .. tostring(raid.journalInstanceID or 0)
           .. ":" .. tostring(info.difficultyID or 0)
end

-- Raid name for display only; comparisons and keys stay on the data name.
local localizedRaidNameCache = {}
function RR:GetLocalizedRaidName(raid)
    raid = raid or self.currentRaid
    if not raid then return nil end
    local journalInstanceID = raid.journalInstanceID
    if not journalInstanceID or not EJ_GetInstanceInfo then
        return raid.name
    end
    local cached = localizedRaidNameCache[journalInstanceID]
    if cached == nil then
        local localizedName = EJ_GetInstanceInfo(journalInstanceID)
        cached = (localizedName and localizedName ~= "") and localizedName or false
        localizedRaidNameCache[journalInstanceID] = cached
    end
    if cached == false then return raid.name end
    return cached
end

-- Localized boss name from the journal, falling back to the authored name.
-- Only successful lookups are cached.
local localizedBossNameCache = {}
function RR:GetLocalizedBossName(boss)
    if not boss then return nil end
    local journalEncounterID = boss.journalEncounterID
    if not journalEncounterID or not EJ_GetEncounterInfo then
        return boss.name
    end
    local cached = localizedBossNameCache[journalEncounterID]
    if cached then return cached end
    local localizedName = EJ_GetEncounterInfo(journalEncounterID)
    if localizedName and localizedName ~= "" then
        localizedBossNameCache[journalEncounterID] = localizedName
        return localizedName
    end
    return boss.name
end

-- The skip target's boss name, localized for display only. Resolves a shorter
-- authored name on a unique substring; anything ambiguous renders as authored.
function RR:GetLocalizedSkipTargetName(raid)
    if not raid or not raid.skipToBoss then return nil end
    local target = raid.skipToBoss
    if not raid.bosses then return target end
    for _, boss in ipairs(raid.bosses) do
        if boss.name == target then
            return self:GetLocalizedBossName(boss) or target
        end
    end
    local partialMatch, matchCount = nil, 0
    for _, boss in ipairs(raid.bosses) do
        if boss.name and boss.name:find(target, 1, true) then
            partialMatch = boss
            matchCount = matchCount + 1
        end
    end
    if matchCount == 1 then
        return self:GetLocalizedBossName(partialMatch) or target
    end
    return target
end

function RR:GetRaidDisplayName()
    if not self.currentRaid then return nil end
    local raidName = self:GetLocalizedRaidName(self.currentRaid)
    local diff = self.state.currentDifficultyName
    if diff and diff ~= "" then
        return ("%s (%s)"):format(raidName, diff)
    end
    return raidName
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

-- Sibling cache: localized encounter name -> journalEncounterID, per journal
-- instance. Built in the same EJ walk as ejMapCache. EJ_GetEncounterInfoByIndex
-- returns names in the CLIENT's language, so this map lets name-based lookups
-- (saved-instance lockout sync in particular, whose API also returns localized
-- names) resolve on any locale without per-locale data.
local ejNameMapCache = {}

local function GetEJMapForJournalInstance(journalInstanceID)
    if not journalInstanceID or journalInstanceID == 0 then return nil end
    local cached = ejMapCache[journalInstanceID]
    if cached then return cached end

    -- Save the currently-selected EJ instance and difficulty so we can
    -- restore both. Selecting the instance is required before the walk
    -- (EJ_GetEncounterInfoByIndex needs EJ_SelectInstance called for the
    -- session).
    local prevInst = EJ_GetSelectedInstance and EJ_GetSelectedInstance() or nil
    local prevDiff = EJ_GetDifficulty and EJ_GetDifficulty() or nil
    if EJ_SelectInstance then
        -- EJ_SelectInstance RAISES (not returns nil) on an id the client
        -- rejects -- e.g. an instance not in the player's available
        -- JournalTierXInstance set. Guard it so a bad id yields an empty
        -- map (callers already handle empty) instead of erroring out of
        -- this function and taking the caller down with it.
        local selectOk = pcall(EJ_SelectInstance, journalInstanceID)
        if not selectOk then
            return {}
        end
    end

    local journalToDungeonEnc = {}
    local localizedNameToJournalEnc = {}

    -- One walk of the encounter list at a given EJ difficulty. Fills the
    -- id and name maps and returns how many encounters it saw. A walk
    -- returns nothing if the active difficulty is one the instance does
    -- not expose (the walk breaks on the first nil row).
    local function walkAtDifficulty(difficultyID)
        if EJ_SetDifficulty then
            EJ_SetDifficulty(difficultyID)
        end
        local walked = 0
        local encIndex = 1
        while true do
            local encName, _, journalEncID, _, _, _, dungeonEncID =
                EJ_GetEncounterInfoByIndex(encIndex, journalInstanceID)
            if not journalEncID then break end
            if dungeonEncID then
                journalToDungeonEnc[journalEncID] = dungeonEncID
            end
            if encName and encName ~= "" then
                localizedNameToJournalEnc[encName] = journalEncID
            end
            walked = walked + 1
            encIndex = encIndex + 1
        end
        return walked
    end

    -- MoP raids expose only the legacy sizes and the Classic 40-player
    -- raids only id 9, so fall through until one yields rows. Dungeons
    -- answer on their own ids (1 Normal, 2 Heroic, 23 Mythic, 8 Keystone,
    -- 24 Timewalking), so those trail the raid ids. An instance whose
    -- live id is missing here walks empty forever: the result is not
    -- cached (see below), so every caller re-runs the whole
    -- select-and-restore dance and drags an open Encounter Journal along
    -- with it.
    -- EVERY difficulty is walked and the results accumulate. Stopping at the
    -- first one that returned rows looked cheaper, but it trusted whichever
    -- difficulty answered first to be the instance's real one, and the raid
    -- ids are tried before the dungeon ids. Scarlet Monastery answers the
    -- 10-player raid difficulty with a single junk encounter, so the walk
    -- stopped there and memoized a one-encounter map for a three-boss
    -- dungeon -- its pills read 0/1 all session. The maps are keyed by
    -- journalEncounterID, so a union across difficulties is exactly the set
    -- of encounters the instance has, whichever difficulty exposed each one.
    local count = 0
    for _, difficultyID in ipairs({ 14, 15, 5, 6, 3, 4, 9, 17, 7,
                                    1, 2, 23, 8, 24 }) do
        count = count + walkAtDifficulty(difficultyID)
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
        ejNameMapCache[journalInstanceID] = localizedNameToJournalEnc
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

-- Localized encounter name -> journalEncounterID for a journal instance, in
-- the client's language. Piggybacks on the same memoized EJ walk; calling the
-- id-map builder first guarantees the name cache is populated when available.
function RR:GetEJNameMapForJournalInstance(journalInstanceID)
    if not journalInstanceID or journalInstanceID == 0 then return nil end
    GetEJMapForJournalInstance(journalInstanceID)
    return ejNameMapCache[journalInstanceID]
end

-- Warms the EJ map cache for every loaded instance after login, a few
-- instances per tick, pausing while the Encounter Journal is open.
local EJ_WARM_TICK_SECONDS  = 0.1
local EJ_WARM_TICK_BUDGET_MS = 20

function RR:WarmEncounterJournalMaps()
    if not EJ_GetEncounterInfoByIndex then return end
    local pending = {}
    for _, registry in ipairs({ RetroRuns_Data, RetroRuns_DungeonData }) do
        for _, instance in pairs(registry or {}) do
            local journalInstanceID = instance.journalInstanceID
            if journalInstanceID and journalInstanceID ~= 0
               and not ejMapCache[journalInstanceID] then
                pending[#pending + 1] = journalInstanceID
            end
        end
    end
    if #pending == 0 then return end
    table.sort(pending)

    local nextIndex = 1
    local ticker
    ticker = C_Timer.NewTicker(EJ_WARM_TICK_SECONDS, function()
        if _G.EncounterJournal and _G.EncounterJournal:IsShown() then
            return
        end
        local tickStart = debugprofilestop()
        while nextIndex <= #pending do
            GetEJMapForJournalInstance(pending[nextIndex])
            nextIndex = nextIndex + 1
            if debugprofilestop() - tickStart >= EJ_WARM_TICK_BUDGET_MS then
                break
            end
        end
        if nextIndex > #pending then
            ticker:Cancel()
        end
    end)
end

-- Live difficulty IDs and the display bucket each folds into. Buckets are
-- 17=LFR, 14=Normal, 15=Heroic, 16=Mythic. Raids opt in with `difficultyModel`.
local DIFFICULTY_MODELS = {
    independent = {
        -- live id -> display bucket (identity)
        fold    = { [17] = 17, [14] = 14, [15] = 15, [16] = 16 },
        -- display buckets in pill / browser order
        buckets = { 17, 14, 15, 16 },
    },
    sharedLfr = {
        -- 7=LFR, 3/4=Normal (10/25), 5/6=Heroic (10/25)
        fold    = { [7] = 17, [3] = 14, [4] = 14, [5] = 15, [6] = 15 },
        buckets = { 17, 14, 15 },
    },
    shared = {
        -- Cataclysm. Dragon Soul uses sharedLfr instead.
        fold    = { [3] = 14, [4] = 14, [5] = 15, [6] = 15 },
        buckets = { 14, 15 },
    },
    single = {
        -- One difficulty: Baradin Hold, Ulduar, the TBC raids, and the
        -- Classic raids. The 40-player ones report live id 9; Ruins of
        -- Ahn'Qiraj reports 3, which the TBC raids already cover.
        fold    = { [3] = 14, [4] = 14, [9] = 14, [14] = 14 },
        buckets = { 14 },
    },
    sizes = {
        -- Wrath-style raids where 10-player and 25-player are distinct
        -- difficulties with distinct loot tables AND fully independent
        -- weekly lockouts. No raid currently uses this; each 3/4-only
        -- raid's lockout shape is settled by a live kill test at its
        -- bring-up and lands here or on sizesShared accordingly.
        fold    = { [3] = 3, [4] = 4 },
        buckets = { 3, 4 },
    },
    sizesShared = {
        -- Wrath, no Heroic. Distinct loot per size, one shared lockout.
        fold    = { [3] = 3, [4] = 4 },
        buckets = { 3, 4 },
    },
    sizesHeroic = {
        -- Four size/heroic combinations, one shared lockout.
        fold    = { [3] = 3, [4] = 4, [5] = 5, [6] = 6 },
        buckets = { 3, 4, 5, 6 },
    },
    difficultyLocked = {
        -- The week locks to a difficulty rather than a size.
        fold    = { [3] = 3, [4] = 4, [5] = 5, [6] = 6 },
        buckets = { 3, 4, 5, 6 },
    },
    dungeon = {
        -- Walk-in dungeon universe: 1 = Normal, 2 = Heroic, 23 = Mythic,
        -- folded onto the raid bucket vocabulary so pills, the browser
        -- and DIFF_LETTER reuse it unchanged. Queue and event ids
        -- (8 Keystone, 24 Timewalking, 19 Event) never fold: those runs
        -- are not walk-in clears. Per-dungeon availableDifficulties
        -- trims the buckets to what the map offers.
        fold    = { [1] = 14, [2] = 15, [23] = 16, [24] = 24 },
        buckets = { 14, 15, 16, 24 },
    },
    singleTw = {
        -- A single-difficulty raid whose Timewalking reprint drops are
        -- tracked as their own bucket. The TW bucket appears only in the
        -- browser: the pill builders skip buckets their label maps omit,
        -- and no lockout machinery reads 33.
        fold    = { [3] = 14, [4] = 14, [9] = 14, [14] = 14, [33] = 33 },
        buckets = { 14, 33 },
    },
}
-- The dungeon data files name their appearance shape (one appearance per
-- item vs per-difficulty appearances); both shapes share the one walk-in
-- fold.
DIFFICULTY_MODELS.dungeonBinary = DIFFICULTY_MODELS.dungeon
DIFFICULTY_MODELS.dungeonTiered = DIFFICULTY_MODELS.dungeon

-- Resolve a raid's difficulty model, defaulting to independent.
function RR:GetDifficultyModel(raid)
    local key = raid and raid.difficultyModel or "independent"
    return DIFFICULTY_MODELS[key] or DIFFICULTY_MODELS.independent
end

-- The buckets to show, in pill order. `availableDifficulties` filters them.
function RR:GetDisplayBuckets(raid)
    local model = self:GetDifficultyModel(raid)
    local allowed = raid and raid.availableDifficulties
    if not allowed then return model.buckets end
    local allow = {}
    for _, b in ipairs(allowed) do allow[b] = true end
    local out = {}
    for _, b in ipairs(model.buckets) do
        if allow[b] then table.insert(out, b) end
    end
    return out
end

-- Fold a live difficulty ID (what GetInstanceInfo / GetSavedInstanceInfo
-- report) into the display bucket for a raid. Returns the id unchanged
-- if the raid's model doesn't remap it.
function RR:FoldDifficulty(raid, liveDifficultyID)
    if not liveDifficultyID then return liveDifficultyID end
    local model = self:GetDifficultyModel(raid)
    return model.fold[liveDifficultyID] or liveDifficultyID
end

-- True for any raw difficulty that folds to LFR under some model.
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

-- True in a Raid Finder instance of the current raid. Use everywhere LFR
-- needs gating.
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

-- The lfrWings entry for the wing the player is in, or nil. `aliasOf` entries
-- are dereferenced here.
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

-- Takes a display bucket, not a live ID. No `availableDifficulties` field
-- means available everywhere.
-- True when the boss exists for the player's faction. A boss with no
-- faction field belongs to both. Same field and semantics as loot rows
-- and routing segments.
function RR:BossAvailableToFaction(boss)
    if not boss then return false end
    if not boss.faction then return true end
    return boss.faction == (UnitFactionGroup and UnitFactionGroup("player"))
end

-- True when the server never reports this boss's death, so no source can
-- ever mark it killed: no encounter event, no scenario criterion, no
-- lockout. Scarlet Monastery of Old's High Inquisitor Fairbanks is the
-- first. Such a boss
-- still LISTS -- its loot is real and collectible -- but it must stay out
-- of every completion count, or a full clear can never read complete.
function RR:IsBossKillUntracked(boss)
    return type(boss) == "table" and boss.killUntracked == true
end

function RR:BossAvailableInBucket(boss, bucket)
    if not boss then return false end
    if not self:BossAvailableToFaction(boss) then return false end
    local allowed = boss.availableDifficulties
    if not allowed then return true end  -- unrestricted: exists everywhere
    for _, b in ipairs(allowed) do
        if b == bucket then return true end
    end
    return false
end

-- Per-difficulty kill counts for any raid, keyed by display bucket. Reads
-- purely from cache; the caller owns the bossesKilled floor.
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

    -- Tiered-lockout mirroring (difficultyLocked): a boss killed at any
    -- bucket of a tier is dead for EVERY bucket of that tier -- the tier
    -- is one live lockout the player moves between, so a 10 Player kill
    -- must show on the 25 Player pill too. Extend each bucket's live-ID
    -- check list with its tier siblings' live IDs.
    for _, bucket in ipairs(self:GetDisplayBuckets(raid)) do
        local tier = self:LockoutTierFor(raid, bucket)
        if tier then
            local merged, seen = {}, {}
            for _, tierBucket in ipairs(tier) do
                for _, liveId in ipairs(liveIdsForBucket[tierBucket] or {}) do
                    if not seen[liveId] then
                        seen[liveId] = true
                        merged[#merged + 1] = liveId
                    end
                end
            end
            liveIdsForBucket[bucket] = merged
        end
    end

    for _, bucket in ipairs(self:GetDisplayBuckets(raid)) do
        local complete = 0
        local total    = 0
        -- The count is over LOCKOUT ENCOUNTERS, not boss rows. Boss rows
        -- and encounters are not one-to-one in either direction:
        --   * several rows can share ONE encounter -- Return to Karazhan's
        --     three Opera Hall variants, Zul'Gurub's four Cache of Madness
        --     bosses, the Nexus commanders, Trial of the Champion's three.
        --     Counting rows there credited a single kill two to four times.
        --   * a row can map to NO encounter at all -- the Violet Hold's six
        --     rotating pool bosses and Atal'Hakkar's Wardens of the Dream
        --     carry DungeonEncounterID 0, so they can never report complete
        --     and left a denominator no clear could reach.
        -- Both shapes disappear once the encounter id is what gets counted.
        local countedEncounters = {}
        for _, b in ipairs(raid.bosses or {}) do
            -- Availability alone, never whether the journal exposes an ID.
            -- An untracked boss can never be marked killed, so counting it
            -- would put the clear permanently out of reach. It still lists.
            if self:BossAvailableInBucket(b, bucket)
                and not self:IsBossKillUntracked(b) then
                -- Falls back to the data file's ID when the journal has none.
                local dungeonEncID = journalToDungeonEnc[b.journalEncounterID]
                    or b.dungeonEncounterID
                    or (b.dungeonEncounterIDs and b.dungeonEncounterIDs[1])
                if dungeonEncID and not countedEncounters[dungeonEncID] then
                    countedEncounters[dungeonEncID] = true
                    total = total + 1
                    for _, liveId in ipairs(liveIdsForBucket[bucket] or {}) do
                        -- A plural boss (several real encounters folded into
                        -- one journal entry) is complete when EVERY member is.
                        -- Named apart from the bucket's `complete` counter on
                        -- purpose: an inner `local complete` shadowed it, and
                        -- the increment below then ran against this boolean.
                        local encounterDone
                        if b.dungeonEncounterIDs then
                            encounterDone = true
                            for _, memberID in ipairs(b.dungeonEncounterIDs) do
                                if not C_RaidLocks.IsEncounterComplete(instanceID, memberID, liveId) then
                                    encounterDone = false
                                    break
                                end
                            end
                        else
                            encounterDone = C_RaidLocks.IsEncounterComplete(instanceID, dungeonEncID, liveId)
                        end
                        if encounterDone then
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
            -- Apply the floor to the active bucket and, on a tiered
            -- lockout, its tier siblings -- a kill counts for the whole
            -- tier at once, and the pills should agree before the async
            -- instance cache catches up.
            local floorBuckets = self:LockoutTierFor(raid, activeBucket)
                or { activeBucket }
            for _, floorBucket in ipairs(floorBuckets) do
                if result[floorBucket] then
                    local localCount = 0
                    local floorEncounters = {}
                    for _, b in ipairs(raid.bosses or {}) do
                        -- Only count toward the bucket if the boss exists
                        -- there, and count each lockout ENCOUNTER once --
                        -- both mirror the per-bucket total above so the
                        -- floor can't push complete past total. Rows
                        -- sharing an encounter would otherwise each add
                        -- one against a total that counts them as one.
                        local dungeonEncID = journalToDungeonEnc[b.journalEncounterID]
                            or b.dungeonEncounterID
                            or (b.dungeonEncounterIDs and b.dungeonEncounterIDs[1])
                        if self.state.bossesKilled[b.index]
                            and not self.state.bossesKilledViaPairOnly[b.index]
                            and self:BossAvailableInBucket(b, floorBucket)
                            and dungeonEncID
                            and not floorEncounters[dungeonEncID] then
                            floorEncounters[dungeonEncID] = true
                            localCount = localCount + 1
                        end
                    end
                    if localCount > result[floorBucket].complete then
                        result[floorBucket].complete = localCount
                    end
                end
            end
        end
    end

    return result
end

function RR:GetPerDifficultyKillCounts()
    if not self.currentRaid then return nil end
    return self:GetPerDifficultyKillCountsForRaid(self.currentRaid)
end

-- LFR kill count as { complete, total }, read from the lockout hyperlink's
-- per-boss bitfield. Nil without wing data.

-- Normalized raid name -> LFR set-bit count and positions, from one scan of
-- every LFR lockout. Cached for a few seconds.
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
        -- Active lockouts only: locked, with a positive reset.
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
            if key and key ~= "" then
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

    -- Summed per wing, not counted raw -- some raids set two bits per boss.
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

-- Per-wing LFR progress for the idle-list expander. Each entry:
--   { key, name, complete, total, unmapped, bosses = { { index, name, killed } } }
-- A mapped wing (lockoutBits) tests each boss's bit against the live set. An
-- unmapped wing (lockoutBitSet -- the group without per-boss assignment) gets
-- a real count but leaves each `killed` nil, so the UI can render the names
-- neutrally and flag the wing as pending a capture.
-- Returns nil if the raid has no lfrWings.
function RR:GetWingProgressForRaid(raid)
    if not raid or not raid.lfrWings then return nil end

    local _, posByName = self:GetLFRLockoutCounts()
    -- Saved-instance names arrive in the client's language, so the English
    -- data name misses on non-English clients. Try it first (free on
    -- English clients), then the client-localized name from the EJ, which
    -- is the same string the saved-instance list reports.
    local key = self:NormalizeName(raid.name)
    local setPos = (key and key ~= "" and posByName and posByName[key])
    if not setPos then
        local localizedKey = self:NormalizeName(self:GetLocalizedRaidName(raid))
        setPos = localizedKey and localizedKey ~= "" and posByName
            and posByName[localizedKey]
    end
    setPos = setPos or {}

    -- Resolve a boss index to its display name via the raid's bosses[] table.
    local function bossName(index)
        local boss = raid.bosses and raid.bosses[index]
        return (boss and self:GetLocalizedBossName(boss)) or ("Boss " .. tostring(index))
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
        -- Wing keys are lfgDungeonIDs, so the client can resolve the wing's
        -- name in its own language; the authored name is the fallback.
        local wingDisplayName
        if GetLFGDungeonInfo then
            wingDisplayName = GetLFGDungeonInfo(wkey)
        end
        if not wingDisplayName or wingDisplayName == "" then
            wingDisplayName = wing.name or "Wing"
        end
        local entry = {
            key   = wkey,
            name  = wingDisplayName,
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

-- Records which lockout bit each LFR boss sets, gathered during normal farming
-- rather than by manual probing. The bit order is its own id space, so watching
-- one kill at a time is the only way to learn it. The lockout API lags the kill
-- by a second or two, so the read is deferred.
function RR:CaptureLFRBitForKill(encounterName)
    local raid = self.currentRaid
    if not raid or not self:IsInLFR() then return end

    -- Retry on a "none" result rather than logging it: a fast kill can register
    -- its bit late, and committing the miss plus a stale snapshot would make
    -- that bit turn up lumped with the next kill's as ambiguous.
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

-- Buckets sharing one weekly lockout. Whichever member has kills locks the
-- others. Only applies when the raid offers more than one member.
local SHARED_LOCKOUT_GROUPS = {
    sharedLfr   = { 14, 15 },
    shared      = { 14, 15 },
    sizesShared = { 3, 4 },
    sizesHeroic = { 3, 4, 5, 6 },
}

-- Buckets inside a tier share a lockout; kills in one tier lock the others.
local TIERED_LOCKOUT_GROUPS = {
    difficultyLocked = { { 3, 4 }, { 5, 6 } },
}

-- The raid's tiers with each tier filtered to the buckets the raid
-- actually offers (empty tiers dropped). Returns nil for raids without a
-- tiered model.
local function OfferedLockoutTiers(raid)
    local tiers = TIERED_LOCKOUT_GROUPS[raid.difficultyModel or "independent"]
    if not tiers then return nil end
    local allowed = raid.availableDifficulties
    local allowedSet
    if allowed then
        allowedSet = {}
        for _, bucket in ipairs(allowed) do allowedSet[bucket] = true end
    end
    local offered = {}
    for _, tier in ipairs(tiers) do
        local kept = {}
        for _, bucket in ipairs(tier) do
            if not allowedSet or allowedSet[bucket] then
                kept[#kept + 1] = bucket
            end
        end
        if #kept > 0 then offered[#offered + 1] = kept end
    end
    if #offered == 0 then return nil end
    return offered
end

-- The tier (bucket list) containing the given bucket, or nil. Exposed on
-- RR for the kill-count mirroring in GetPerDifficultyKillCountsForRaid.
function RR:LockoutTierFor(raid, bucket)
    if not raid or not bucket then return nil end
    local tiers = OfferedLockoutTiers(raid)
    if not tiers then return nil end
    for _, tier in ipairs(tiers) do
        for _, member in ipairs(tier) do
            if member == bucket then return tier end
        end
    end
    return nil
end

-- Buckets of a shared-lockout group that the raid actually offers. Returns
-- nil when the model isn't shared, or when fewer than two members exist
-- (nothing can be locked by a group of one).
local function OfferedGroupBuckets(raid)
    local group = SHARED_LOCKOUT_GROUPS[raid.difficultyModel or "independent"]
    if not group then return nil end

    local offered = {}
    local allowed = raid.availableDifficulties
    for _, bucket in ipairs(group) do
        local isOffered = true
        if allowed then
            isOffered = false
            for _, allowedBucket in ipairs(allowed) do
                if allowedBucket == bucket then isOffered = true break end
            end
        end
        if isOffered then offered[#offered + 1] = bucket end
    end
    if #offered < 2 then return nil end
    return offered
end

-- Every bucket the shared lockout currently blocks, or nil when nothing is.
-- One member with kills locks every other offered member.
function RR:GetLockedOutBuckets(raid, counts)
    if not raid or not counts then return nil end

    local tiers = OfferedLockoutTiers(raid)
    if tiers then
        local killTiers = {}
        local anyKills = false
        for tierIndex, tier in ipairs(tiers) do
            for _, bucket in ipairs(tier) do
                if counts[bucket] and counts[bucket].complete > 0 then
                    killTiers[tierIndex] = true
                    anyKills = true
                    break
                end
            end
        end
        if not anyKills then return nil end
        local locked = {}
        for tierIndex, tier in ipairs(tiers) do
            if not killTiers[tierIndex] then
                for _, bucket in ipairs(tier) do
                    locked[#locked + 1] = bucket
                end
            end
        end
        if #locked == 0 then return nil end
        return locked
    end

    local offered = OfferedGroupBuckets(raid)
    if not offered then return nil end

    local anyDone = false
    for _, bucket in ipairs(offered) do
        if counts[bucket] and counts[bucket].complete > 0 then
            anyDone = true
            break
        end
    end
    if not anyDone then return nil end

    local locked = {}
    for _, bucket in ipairs(offered) do
        local bucketDone = counts[bucket] and counts[bucket].complete > 0
        if not bucketDone then locked[#locked + 1] = bucket end
    end
    if #locked == 0 then return nil end
    return locked
end

-- A shared lockout is stored under whichever difficulty was entered first, so
-- either member's row resolves to it.
function RR:SavedRowMatchesActiveLockout(savedDifficultyId)
    if savedDifficultyId == self.state.currentDifficultyID then return true end
    local raid = self.currentRaid
    if not raid then return false end
    local savedBucket  = self:FoldDifficulty(raid, savedDifficultyId)
    local activeBucket = self:FoldDifficulty(raid, self.state.currentDifficultyID)
    -- Tiered model: a saved row belongs to the active lockout only when
    -- both buckets sit in the SAME tier -- the other tier's lockout is a
    -- different (blocked) one, not this one.
    local activeTier = self:LockoutTierFor(raid, activeBucket)
    if activeTier then
        for _, bucket in ipairs(activeTier) do
            if bucket == savedBucket then return true end
        end
        return false
    end
    local group = SHARED_LOCKOUT_GROUPS[raid.difficultyModel or "independent"]
    if not group then return false end
    -- Any two members of the group share one lockout, so a saved row under
    -- any member belongs to the active difficulty's lockout.
    local savedInGroup, activeInGroup = false, false
    for _, bucket in ipairs(group) do
        if bucket == savedBucket  then savedInGroup  = true end
        if bucket == activeBucket then activeInGroup = true end
    end
    return savedInGroup and activeInGroup
end

-- Dumps every saved instance with IsEncounterComplete probed per encounter.
-- Looking for expired entries where C_RaidLocks still returns true, which
-- would mean stale data is leaking into the pills.
function RR:LockProbe()
    if RequestRaidInfo then RequestRaidInfo() end

    local lines = {}
    local function add(line) lines[#lines + 1] = line end

    local savedCount = GetNumSavedInstances and GetNumSavedInstances() or 0
    add(("GetNumSavedInstances() = %d"):format(savedCount))
    add("")

    if savedCount == 0 then
        add("(no saved instances; nothing to dump)")
        self:ShowCopyWindow("LockProbe", table.concat(lines, "\n"))
        return
    end

    for i = 1, savedCount do
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

        -- Raids key on the live map id. Dungeons key on journalInstanceID
        -- and several can share one map, so every dungeon on this map is
        -- probed.
        local candidates = {}
        if C_RaidLocks and C_RaidLocks.IsEncounterComplete then
            if isRaid then
                candidates[1] = self:GetRaidByInstanceID(instanceID)
            elseif RetroRuns_DungeonData then
                for _, dungeon in pairs(RetroRuns_DungeonData) do
                    if dungeon.instanceID == instanceID then
                        candidates[#candidates + 1] = dungeon
                    end
                end
            end
        end
        for _, raid in ipairs(candidates) do
            local journalToDungeonEnc = self:GetEJMapForJournalInstance(raid.journalInstanceID)
            if journalToDungeonEnc and next(journalToDungeonEnc) then
                add(("    C_RaidLocks.IsEncounterComplete(%s, <dungeonEncID>, %s):")
                    :format(tostring(instanceID), tostring(difficultyId)))
                for _, b in ipairs(raid.bosses or {}) do
                    local dungeonEncID = journalToDungeonEnc[b.journalEncounterID]
                    if dungeonEncID then
                        local encounterComplete = C_RaidLocks.IsEncounterComplete(
                            instanceID, dungeonEncID, difficultyId)
                        add(("      %s (dungeonEncID=%s): %s")
                            :format(tostring(b.name), tostring(dungeonEncID),
                                    tostring(encounterComplete)))
                    end
                end
            end

            -- Probes each boss against every legacy size id plus the display
            -- buckets and LFR. A kill lighting up only its own id means the
            -- difficulties are independent; lighting up siblings means they
            -- must fold to one bucket. This is how a model gets decided.
            local matrixIds, matrixLegend
            if raid.kind == "dungeon" then
                matrixIds    = { 1, 2, 23, 8, 24 }
                matrixLegend = "[1=N 2=H 23=M 8=Key 24=TW]"
            else
                matrixIds    = { 3, 4, 5, 6, 14, 15, 7, 17 }
                matrixLegend = "[3=10N 4=25N 5=10H 6=25H 14=N 15=H 7=LFRlegacy 17=LFR]"
            end
            add("    cross-difficulty matrix " .. matrixLegend .. ":")
            for _, b in ipairs(raid.bosses or {}) do
                local dungeonEncID =
                    (journalToDungeonEnc and journalToDungeonEnc[b.journalEncounterID])
                    or b.dungeonEncounterID
                    or (b.dungeonEncounterIDs and b.dungeonEncounterIDs[1])
                if dungeonEncID then
                    local cells = {}
                    for _, probeId in ipairs(matrixIds) do
                        local complete = C_RaidLocks.IsEncounterComplete(
                            instanceID, dungeonEncID, probeId)
                        cells[#cells + 1] = ("%s=%s"):format(
                            tostring(probeId), complete and "T" or "f")
                    end
                    add(("      %s (deID=%s): %s")
                        :format(tostring(b.name), tostring(dungeonEncID),
                                table.concat(cells, " ")))
                else
                    add(("      %s: no dungeonEncounterID (EJ map empty, no data fallback)")
                        :format(tostring(b.name)))
                end
            end
        end
        add("")
    end

    self:ShowCopyWindow("LockProbe", table.concat(lines, "\n"))
end

-- Skip quests are account-wide and don't backfill, so the highest flag-true
-- difficulty is the ceiling.

-- Normalizes raid.skipQuests to an array of chain descriptors. Nil when the
-- raid has none.
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
            local rawType = type(raw)
            if (rawType == "number" or rawType == "string") and (tonumber(raw) or 0) > 0 then
                return false, false, true
            end
        end
    end

    -- Tier 4: nothing proven.
    return false, false, "?"
end

function RR:GetRaidSkipUnlockedCeiling(raid)
    if not raid then return nil end

    -- Ungated (Burning Crusade): nothing to unlock, so the ceiling is the
    -- top of the range and the cascade below makes it available at every
    -- difficulty the raid offers.
    if self:RaidSkipIsUngated(raid) then return 16 end

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

    -- Collapses GarroshSkipStates to a ceiling. "?" doesn't count as unlocked.
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
    -- Ungated skips apply at every difficulty the raid offers, so the
    -- downward cascade from the ceiling is the correct model.
    if self:RaidSkipIsUngated(raid) then return true end
    if raid.skipQuests then return true end
    if raid.skipAchievement then return false end
    -- Garrosh scroll: once unlocked it applies at every difficulty the
    -- player can enter, so the downward cascade from its Mythic ceiling
    -- is the correct model.
    if raid.skipGarrosh then return true end
    return false
end

-- A skip route with no unlock mechanism declared, so it is always offered.
-- The Burning Crusade raids are the case: their gates were deleted, not
-- replaced with a flag.
function RR:RaidSkipIsUngated(raid)
    if not raid then return false end
    if not raid.skipRoute then return false end
    return raid.skipQuests == nil
        and raid.skipAchievement == nil
        and raid.skipGarrosh == nil
end

-- True iff the raid has any skip mechanic configured (regardless of
-- whether it's currently unlocked). Single gate for the UI sites that
-- decide whether to surface the skip column / detail row at all, so a
-- new mechanism only has to be added here rather than at every call
-- site.
function RR:RaidHasSkipMechanic(raid)
    if not raid then return false end
    -- Ungated routes are deliberately NOT counted here. The Skips window
    -- tracks unlock progress, and an ungated skip has no progress to
    -- track -- it would render as a permanently-unlocked row that tells
    -- the player nothing. It is offered on the load dialog instead.
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
    -- Callers pass the RAW live difficulty, so fold before range-checking.
    difficultyID = self:FoldDifficulty(raid, difficultyID)
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
    -- Fold the RAW live difficulty before range-checking, exactly as
    -- IsRaidSkipAvailableAtDifficulty does. These two are near-duplicates
    -- and the load dialog calls THIS one, so a fix applied only to the
    -- sibling changes nothing the player sees.
    difficultyID = self:FoldDifficulty(raid, difficultyID)
    if difficultyID < 14 or difficultyID > 16 then return false end
    local ceiling = self:GetRouteTargetSkipCeiling(raid)
    if not ceiling then return false end
    if not self:RaidSkipIsCascading(raid) then
        return difficultyID == ceiling
    end
    return difficultyID <= ceiling
end

-- The data table for the raid the player is inside. Horde reads
-- RetroRuns_DataHorde first, falling through to the shared table.
-- Dungeon lookup by INSTANCE MAP id, which is what GetInstanceInfo
-- reports. The data itself is keyed by journalInstanceID because five
-- dungeons share a map with a sibling -- Dire Maul's three wings all
-- report map 429, Stratholme's two entrances both report 329 -- so the
-- map id genuinely cannot pick between them. The lowest journalInstanceID
-- wins, which at least makes the answer stable run to run; the other 118
-- resolve one to one. Built once, since the data never changes after load.
--
-- A wing that is its OWN instance rather than part of one walkable map
-- (Scarlet Monastery of Old's four) declares `uiMaps`, and that index is
-- consulted first: the player's current uiMap names the wing outright.
-- Dire Maul and Stratholme carry no `uiMaps` and keep the lowest-id
-- behavior, which is right for them -- their wings share one instance a
-- player walks between.
local dungeonByInstanceMap, dungeonByUiMap
local function BuildDungeonIndexes()
    dungeonByInstanceMap, dungeonByUiMap = {}, {}
    for _, dungeon in pairs(RetroRuns_DungeonData or {}) do
        local mapID = dungeon.instanceID
        if mapID and mapID > 0 then
            local claimed = dungeonByInstanceMap[mapID]
            if not claimed
                or (dungeon.journalInstanceID or 0) < (claimed.journalInstanceID or 0)
            then
                dungeonByInstanceMap[mapID] = dungeon
            end
            for _, uiMapID in ipairs(dungeon.uiMaps or {}) do
                dungeonByUiMap[uiMapID] = dungeon
            end
        end
    end
end

-- The wing chosen when the player entered, kept until they leave. Wings that
-- SHARE one walkable instance (Stratholme's two doors, Dire Maul's three)
-- cannot be re-resolved from the live uiMap on every location change: a Main
-- Gate run that steps into the Gauntlet (318) reads as Service Entrance and
-- would swap the boss list, the route and the run record's key mid-run. The
-- game itself decides at the door -- entering the front gate makes the side
-- door port you back to it until an explicit reset -- so this mirrors that:
-- resolved once on entry, cleared on leaving.
local enteredWing = nil
-- True while the held wing was picked inside the login settle window. The
-- client's first map reads after a login can name the wrong floor outright
-- for their first second, so a hold taken then stays open to a
-- claimed re-pick until the window closes.
local enteredWingProvisional = false

local function InLoginSettleWindow()
    local untilTime = RR.state and RR.state.loginSettleUntil
    return untilTime ~= nil and GetTime() < untilTime
end

local function DungeonForInstanceMap(instanceMapID, uiMapID)
    if not instanceMapID then return nil end
    if not dungeonByInstanceMap then BuildDungeonIndexes() end
    -- Already inside: keep the wing entry picked, however the player has
    -- wandered since. A PROVISIONAL hold re-picks from any claimed uiMap
    -- until the login window closes; a settled hold is kept, which is the
    -- side-door rule.
    if enteredWing and enteredWing.instanceID == instanceMapID then
        if enteredWingProvisional then
            local byUi = uiMapID and dungeonByUiMap[uiMapID]
            if byUi and byUi.instanceID == instanceMapID then
                enteredWing = byUi
            end
            enteredWingProvisional = InLoginSettleWindow()
        end
        return enteredWing
    end
    -- The wing the player is actually standing in, when one claims this
    -- uiMap and belongs to this instance. Guarded on instanceID so a
    -- stale map reading cannot hand back a dungeon from somewhere else.
    local byUi = uiMapID and dungeonByUiMap[uiMapID]
    if byUi and byUi.instanceID == instanceMapID then
        enteredWing = byUi
        enteredWingProvisional = InLoginSettleWindow()
        return byUi
    end
    -- No wing claims this map: the lowest journalInstanceID sibling, which
    -- at least makes the answer stable run to run.
    --
    -- NOT REMEMBERED, and that is the whole point. GetInstanceInfo reports
    -- the instance a beat BEFORE the player's uiMap catches up -- the zone
    -- log shows the first resolve landing while the zone still reads
    -- "Eastern Plaguelands" with a nil map -- so this branch runs on entry
    -- with nothing to identify the wing by. Caching that guess pinned the
    -- Service Entrance to the Main Gate until the next reload. Left
    -- uncached, the next call once the map resolves picks the right wing
    -- and caches THAT. Single-wing dungeons are unaffected: their tiebreak
    -- has one candidate and is right every time.
    return dungeonByInstanceMap[instanceMapID]
end

-- Cleared on leaving, so the next entry resolves fresh. Exposed on RR
-- because HandleLocationChange lives outside this file's local scope.
function RR:ClearEnteredWing()
    enteredWing = nil
    enteredWingProvisional = false
end

function RR:GetSupportedRaid()
    local info = self:GetCurrentInstanceInfo()
    -- Dungeons are supported instances too: entering one loads its boss
    -- progress, arms the toaster and points the transmog button at it,
    -- whether or not it has a route yet.
    if info.instanceType == "party" then
        -- The player's own map, so a wing that is its own instance
        -- resolves to the wing rather than to its lowest-id sibling.
        local uiMapID = C_Map and C_Map.GetBestMapForUnit
            and C_Map.GetBestMapForUnit("player")
        return DungeonForInstanceMap(info.instanceID, uiMapID)
    end
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

-- Overwrites name and journalEncounterID in place from a boss's
-- `factionEncounters` table. Once per session; Neutral keeps the authored
-- Alliance values.
function RR:ResolveFactionEncounters()
    local faction = UnitFactionGroup("player")
    if faction ~= "Alliance" and faction ~= "Horde" then return end
    -- Rewrite one authored string's caret tokens through the name map.
    -- Only an EXACT caret match is substituted: a note can legitimately
    -- name the other faction's ship or city in its prose, and a blanket
    -- string replace would corrupt that. Titles are matched whole for the
    -- same reason.
    local function resolveTokens(text, nameMap)
        if type(text) ~= "string" then return text end
        return (text:gsub("%^([^%^]+)%^", function(token)
            local resolved = nameMap[token]
            return "^" .. (resolved or token) .. "^"
        end))
    end
    local function applyToTable(dataTable)
        if not dataTable then return end
        for _, raid in pairs(dataTable) do
            if raid.bosses then
                -- Every name this encounter goes by, mapped to the one
                -- this character actually fights. Built across all bosses
                -- first, because a note for one step can reference another
                -- step's boss (ToC's Twin Val'kyr note names the Champions).
                local nameMap = {}
                for _, boss in ipairs(raid.bosses) do
                    local variant = boss.factionEncounters
                        and boss.factionEncounters[faction]
                    if variant then
                        if variant.name then
                            for _, other in pairs(boss.factionEncounters) do
                                if other.name then
                                    nameMap[other.name] = variant.name
                                end
                            end
                            if boss.name then nameMap[boss.name] = variant.name end
                            boss.name = variant.name
                        end
                        if variant.journalEncounterID then
                            boss.journalEncounterID = variant.journalEncounterID
                        end
                    end
                end
                -- Routing carries the encounter name in its step title and
                -- in the hand-authored travel notes. Without this the
                -- dropdown would say "Champions of the Alliance" while the
                -- note under it still said "Champions of the Horde".
                if raid.routing then
                    for _, step in ipairs(raid.routing) do
                        -- A segment tagged with a faction belongs only to
                        -- that faction's route (the ICC gunship approach:
                        -- each faction boards its own ship from a
                        -- different rampart path). Untagged segments are
                        -- shared. Same field and semantics as loot rows.
                        local segments = step.segments or {}
                        for segIndex = #segments, 1, -1 do
                            local seg = segments[segIndex]
                            if seg.faction and seg.faction ~= faction then
                                table.remove(segments, segIndex)
                            end
                        end
                        if next(nameMap) then
                            if step.title and nameMap[step.title] then
                                step.title = nameMap[step.title]
                            end
                            for _, seg in ipairs(segments) do
                                seg.note    = resolveTokens(seg.note, nameMap)
                                seg.minNote = resolveTokens(seg.minNote, nameMap)
                                -- Skip variants name the same encounters.
                                seg.skipNote =
                                    resolveTokens(seg.skipNote, nameMap)
                                seg.skipMinNote =
                                    resolveTokens(seg.skipMinNote, nameMap)
                            end
                        end
                    end
                end
            end
        end
    end
    applyToTable(RetroRuns_Data)
    applyToTable(RetroRuns_DataHorde)
    applyToTable(RetroRuns_DungeonData)
end

-------------------------------------------------------------------------------
-- Raid load / unload
-------------------------------------------------------------------------------

-- The lockoutId for the loaded raid, or nil on a fresh lockout. Changes at
-- every weekly reset, so it keys persisted-progress invalidation.
function RR:GetCurrentLockoutId()
    if not self.currentRaid then return nil end
    if not self.state.currentDifficultyID then return nil end

    -- Prefer a row stored under the active difficulty; on a shared-lockout
    -- raid, fall back to the pair sibling's row (same weekly lockout,
    -- stored under whichever size was entered first).
    local pairLockoutId = nil
    local numSaved = GetNumSavedInstances()
    for i = 1, numSaved do
        local _, lockoutId, _, difficultyId, _, _, _, isRaid,
              _, _, _, _, _, instanceID = GetSavedInstanceInfo(i)
        -- Row type has to match the instance: GetSavedInstanceInfo reports
        -- isRaid=false for a saved dungeon, so a raid-only test made the
        -- persisted store unreachable for every Heroic and Mythic dungeon.
        local wantRaidRow = (self.currentRaid.kind ~= "dungeon")
        if ((isRaid and true or false) == wantRaidRow)
            and instanceID == self.currentRaid.instanceID then
            if difficultyId == self.state.currentDifficultyID then
                return lockoutId
            elseif self:SavedRowMatchesActiveLockout(difficultyId) then
                pairLockoutId = pairLockoutId or lockoutId
            end
        end
    end
    return pairLockoutId
end

-- True if the player has killed at least one boss in the current raid's
-- active lockout. Reads encounterProgress (12th return of
-- GetSavedInstanceInfo) for the matching instanceID + difficulty. A
-- lockout id alone does not imply a kill, so this gates "committed."
function RR:HasAnyKillThisLockout()
    if not self.currentRaid or not self.currentRaid.instanceID then return false end
    if not self.state.currentDifficultyID then return false end

    local pairHasKill = nil
    local numSaved = GetNumSavedInstances()
    for i = 1, numSaved do
        local _, _, _, difficultyId, _, _, _, isRaid,
              _, _, _, encounterProgress, _,
              instanceID = GetSavedInstanceInfo(i)
        if isRaid and instanceID == self.currentRaid.instanceID then
            if difficultyId == self.state.currentDifficultyID then
                return (encounterProgress or 0) > 0
            elseif self:SavedRowMatchesActiveLockout(difficultyId) then
                pairHasKill = pairHasKill or ((encounterProgress or 0) > 0)
            end
        end
    end
    return pairHasKill or false
end

-- Wipes test/stale state, syncs kills, restores persisted segments, recomputes
-- the step, refreshes.
function RR:RestoreRealRaidState()
    self:ClearBossState()
    self:SyncFromSavedRaidInfo(true)   -- request fresh server data
    -- Leaving test mode wipes the simulated kills, and for an instance the
    -- server does not save, the sync above has nothing to put back -- the
    -- real run's kills live only in our own record. sameSession is true:
    -- the client never left, so it is provably the same instance. Test
    -- kills never entered the record (PersistRunProgress stands down in
    -- test mode), so what comes back is what was really killed.
    self:RestoreRunProgress(true)
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

    -- Show the panel, but honor the user's minimized choice: the
    -- minimized bar now carries the active step and its note, so forcing
    -- the full panel open on every raid load overrides a deliberate
    -- setting to show something the bar already says.
    self:SetSetting("showPanel", true)
    self:RefreshAll()
end

function RR:UnloadCurrentRaid()
    self.state.loadedRaidKey = nil
    self.state.activeRouteVariant = nil
    self:RefreshAll()
end

function RR:HandleLocationChange()
    local info = self:GetCurrentInstanceInfo()

    -- Dungeons ("party") are supported instances too, so they fall
    -- through to the same load path raids take. Anything else -- the open
    -- world, battlegrounds, scenarios -- unloads.
    if info.instanceType ~= "raid" and info.instanceType ~= "party" then
        self:ApplyPendingInstanceGeneration()
        self:ClearEnteredWing()
        self.currentRaid                 = nil
        self.state.lastSeenRaidKey       = nil
        self.state.currentDifficultyID   = nil
        self.state.currentDifficultyName = nil
        self.state.lastUnsupportedRaid   = nil
        self.state.lastPlayerMapID       = nil
        self.state.seasonalStandDownKey  = nil
        self.state.panelOpenedByHand     = nil
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

    -- Leaving a mapID completes the earliest incomplete segment on it -- the
    -- only completion mechanism available inside a raid.
    -- Every pass through here while inside counts as contact with the
    -- spawned instance, supported or not -- the hourly cap does not care
    -- whether RetroRuns tracks the place.
    self:TrackInstanceEntry(info)

    local currentMapID = C_Map and C_Map.GetBestMapForUnit and
                         C_Map.GetBestMapForUnit("player")
    local previousMapID = self.state.lastPlayerMapID

    -- Helper: resolve mapID -> sub-zone name from the active raid's
    -- maps table, falling back to the raw ID if no name is registered.
    local mapName = function(id)
        if not id then return "(none)" end
        local raidMaps = self.currentRaid and self.currentRaid.maps
        local mapName = raidMaps and raidMaps[id]
        if mapName then return ("%s (%d)"):format(mapName, id) end
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

    -- A subZone can change without the mapID changing. No-op when no advance
    -- is computed.
    if currentMapID and previousMapID and currentMapID == previousMapID then
        self:AdvanceProgress("zone")
    end

    if currentMapID then
        self.state.lastPlayerMapID = currentMapID
    end

    -- The record's last-seen spot updates on every location change, so
    -- the login comparison never waits on a logout event. Held during the
    -- settle window: the login restore must read the PREVIOUS session's
    -- stamp before anything overwrites it.
    if self.currentRaid and not InLoginSettleWindow()
        and self.StampLastSeen then
        self:StampLastSeen()
    end

    -- An optional step yields on position, so movement re-selects. Gated on
    -- the ROUTE holding one, not the active step, so the cede is reversible.
    if self.currentRaid and self:ActiveRoutingHasOptionalStep() then
        local before = self.state.activeStep
        local after  = self:ComputeNextStep()
        if after ~= before then
            RR.UI.Update()
            if RetroRunsMapOverlay then RetroRunsMapOverlay:Refresh() end
        end
    end

    local supported = self:GetSupportedRaid()
    if supported and self:IsSeasonalMythicEntry(supported, info) then
        -- Said once per entry; every zone event inside comes back through here.
        local entryKey = self:GetRaidContextKey(supported, info)
        if self.state.seasonalStandDownKey ~= entryKey then
            self.state.seasonalStandDownKey = entryKey
            self.state.panelOpenedByHand = nil
            self:PrintAfterBanner(RR.L["Seasonal M+ Dungeon detected. Routing is disabled for Heroic and Mythic difficulties."])
        end
        -- Falls through the unsupported branch below without its line:
        -- this dungeon is supported, just stood down from.
        self.state.lastUnsupportedRaid = info.name
        supported = nil
    end
    if supported then
        self.currentRaid                 = supported
        self.state.currentDifficultyID   = info.difficultyID
        self.state.currentDifficultyName = info.difficultyName

        -- Warms the GetItemInfo cache so the browser's quality read resolves
        -- on first open.
        if GetItemInfo and supported.bosses then
            for _, boss in ipairs(supported.bosses) do
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
            end
        end

        local key = self:GetRaidContextKey(supported, info)
        if self.state.lastSeenRaidKey ~= key then
            -- A store with no confirmed lockout means the async data hasn't
            -- landed: defer, and UPDATE_INSTANCE_INFO re-drives this. No store
            -- is genuinely fresh, so prompt now.
            if self:HasSavedRouteStore()
                and not self:GetCurrentLockoutId()
                and not self.state.instanceInfoSeen then
                self:ZoneLog("HLC: load decision deferred until instance info arrives")
                return
            end

            -- bossesKilled is bossIndex-keyed with no raid scoping, so a new
            -- context has to wipe it.
            wipe(self.state.bossesKilled)
            wipe(self.state.bossesKilledViaPairOnly)
            wipe(self.state.bossPartialKills)
            wipe(self.state.bossesSkipped)
            -- The step pointer and the per-step segment progress are keyed
            -- the same way and need the same wipe. Dire Maul's three wings
            -- share an instanceID, so walking between them can otherwise
            -- leave a step belonging to the wing next door: its segments sit
            -- on a map the player is not standing on, the line picker returns
            -- nothing, and the panel reads out another wing's travel note.
            self.state.activeStep = nil
            self.state.progress = {}
            self.state.triggersFired = self.state.triggersFired or {}
            wipe(self.state.triggersFired)
            self.state.lastSeenRaidKey = key

            -- An instance with no saved lockout has nothing on the server
            -- to sync from, so its kills come back from our own record.
            -- Runs right after the wipe above, which is what it undoes.
            --
            -- `isReloadingUi` is only true when the client never left,
            -- making the record provably this same instance.
            --
            -- Being placed inside the instance at login is not a second
            -- proof: a Normal dungeon's soft reset replaces the contents
            -- without moving the player.
            self:RestoreRunProgress(self.state.isReloadingUi)
            -- Criteria can arrive after PLAYER_ENTERING_WORLD, so the read
            -- above is retried until the API answers.
            self:ScheduleScenarioKillRetry()

            -- Dungeons never take the resume path: it announces which
            -- route variant is being restored, and they have no variants
            -- (and often no route). A Heroic or Mythic dungeon does carry
            -- a real lockout, so without this guard a re-entry after a
            -- kill would resume a route that does not exist.
            if supported.kind ~= "dungeon"
               and self:HasPersistedProgressForCurrentLockout()
               and self:HasAnyKillThisLockout() then
                -- Committed (a route loaded AND a boss dead): restore the
                -- persisted route silently instead of re-prompting.
                self.state.loadedRaidKey = key
                self:LoadCurrentRaid()
                -- Confirm the resumed route in chat (no dialog showed it).
                local saved = self:GetPersistedRouteVariant()
                local routeWord = (saved == "skip") and RR.L["SKIP"] or RR.L["FULL"]
                local killed, total = self:GetRaidProgressCounts()
                self:PrintAfterBanner((RR.L["%s Lockout in Progress (%d/%d)."])
                    :format(self:GetRaidDisplayName()
                                or self:GetLocalizedRaidName(supported),
                            killed, total))
                self:PrintAfterBanner((RR.L["Resuming %s route."]):format(routeWord))
            elseif self:IsInLFR() or supported.kind == "dungeon" then
                -- Neither route variant applies in LFR, so load directly.
                -- Dungeons load directly too: the full/skip choice the
                -- dialog exists to offer is a raid concept, and asking
                -- about navigation would promise a route an unrouted
                -- dungeon does not have.
                self.state.loadedRaidKey = key
                self:LoadCurrentRaid()
            else
                self.state.loadedRaidKey = nil
                self:SetSetting("showPanel", false)
                if RetroRunsUI then RetroRunsUI:Hide() end
                if RR.UI and RR.UI.ShowLoadDialog then
                    RR.UI.ShowLoadDialog(self:GetRaidDisplayName()
                        or self:GetLocalizedRaidName(supported))
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
        wipe(self.state.bossesKilledViaPairOnly)
        wipe(self.state.bossPartialKills)
        wipe(self.state.bossesSkipped)
        self:ClearEnteredWing()
        self.currentRaid                 = nil
        -- Boss indices are not instance-scoped, so a remembered encounter
        -- would aim the transmog button at the wrong boss of the next
        -- instance entered.
        self.state.lastEncounterBossIndex = nil
        -- The run record deliberately SURVIVES stepping outside. A
        -- non-saving instance stays alive for a grace period after the
        -- last player leaves, so walking out and back in finds the same
        -- bosses dead -- clearing here would have shown them alive again.
        -- What ends a run is an explicit reset (hooked on ResetInstances)
        -- or the record ageing out.
        self.state.loadedRaidKey         = nil
        self.state.instanceInfoSeen      = false
        self.state.currentDifficultyID   = nil
        self.state.currentDifficultyName = nil
        if info.name and self.state.lastUnsupportedRaid ~= info.name then
            self.state.lastUnsupportedRaid = info.name
            self.state.panelOpenedByHand = nil
            self:Print(info.name .. RR.L[" is not supported yet."])
        end
        -- The panel gate reads currentRaid, so a frame that was open on the
        -- way in closes here rather than staying up over the run.
        self:RefreshAll()
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
        -- The no-change early-out only holds where a lockout backs the sync.
        -- A lockout-less instance has no saved rows to diff, so its kill
        -- state changes without the sync ever reporting it.
        if changed == false and self:GetCurrentLockoutId() then return end
    else
        self.state.activeStep = nil
    end
    self:ZoneLog("RefreshAll: calling UI.Update + MapOverlay:Refresh")
    RR.UI.Update()
    if RetroRunsMapOverlay then RetroRunsMapOverlay:Refresh() end
end

-- Saved-instance re-query on a short backoff, for encounters that end
-- without a success flag: their kill credit can land seconds after the
-- immediate re-query has already come back empty, and with no later query
-- the step would only advance on the next zone change. One sequence runs at
-- a time; it stops as soon as a sync reports a change (here or in the
-- UPDATE_INSTANCE_INFO handler) or the budget is spent.
function RR:ScheduleKillSyncRetry()
    if self.state.killSyncRetryActive then return end
    self.state.killSyncRetryActive = true
    local delays = { 3, 5, 8 }
    local raidKeyAtSchedule = self:GetRaidContextKey()
    local attempt = 0
    local function tick()
        -- Cleared elsewhere means the kill already landed.
        if not self.state.killSyncRetryActive then return end
        attempt = attempt + 1
        -- The run moved on: raid unloaded, zoned out, or context changed.
        if self.state.testMode
            or not self.currentRaid
            or self.state.loadedRaidKey ~= self:GetRaidContextKey()
            or self:GetRaidContextKey() ~= raidKeyAtSchedule then
            self.state.killSyncRetryActive = nil
            return
        end
        local changed = self:SyncFromSavedRaidInfo(true)
        self:ZoneLog(("kill-sync retry %d/%d: changed=%s")
            :format(attempt, #delays, tostring(changed)))
        if changed ~= false then
            self.state.killSyncRetryActive = nil
            RR.UI.Update()
            if RetroRunsMapOverlay then RetroRunsMapOverlay:Refresh() end
            return
        end
        if attempt < #delays then
            C_Timer.After(delays[attempt + 1], tick)
        else
            self.state.killSyncRetryActive = nil
        end
    end
    C_Timer.After(delays[1], tick)
end

-------------------------------------------------------------------------------
-- Test-mode helpers
-------------------------------------------------------------------------------

function RR:ResetTestState()
    self:ClearBossState()
    self.state.testMode             = true
    self:ComputeNextStep()
end

function RR:DisableTestMode()
    self.state.testMode             = false
    -- Wipe any fake test-mode state and rebuild from real lockout.
    -- Without this, exiting test mode left the panel showing the
    -- accumulated test-mode kills/segments rather than reality.
    -- testMode must be set to false BEFORE this call -- SyncFromSavedRaidInfo
    -- short-circuits when testMode is true.
    self:RestoreRealRaidState()
end

function RR:SimulateKillNext()
    if not self.currentRaid then
        self:Print(RR.L["No supported instance detected."])
        return
    end
    if not self.state.testMode then
        self.state.testMode = true
        self:ClearBossState()
        self:ComputeNextStep()
    end
    -- Route order, not the position-aware active step.
    local step = self:GetAvailableSteps()[1]
    if not step then self:Print(RR.L["No available next step."]) ; return end
    local boss = self:GetBossByIndex(step.bossIndex)
    self:MarkBossKilled(boss)
    self:ComputeNextStep()
    self:Print(RR.L["Simulated kill: "] .. (boss and boss.name or "Unknown"))
    RR.UI.Update()
    if RetroRunsMapOverlay then RetroRunsMapOverlay:Refresh() end
end

-------------------------------------------------------------------------------
-- Manual kill overrides  (/rr kill, /rr unkill)
-------------------------------------------------------------------------------

function RR:ManualKill(input)
    if not self.currentRaid then
        self:Print(RR.L["No instance loaded."])
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
        self:Print(RR.L["No instance loaded."])
        return
    end
    local boss = self:ResolveBoss(input)
    if not boss then
        self:Print(("No boss matched '%s'."):format(input))
        return
    end
    self.state.bossesKilled[boss.index] = nil
    self.state.bossesKilledViaPairOnly[boss.index] = nil
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
    local function add(line) table.insert(lines, line) end

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
        add("Instance: (none loaded)")
        add("Open a supported instance to load state.")
        RR:ShowCopyWindow(
            "|cffF259C7RETRO|r|cff4DCCFFRUNS|r  |cffaaaaaastatus|r",
            table.concat(lines, "\n"))
        self:Print(RR.L["Status window opened.  (no instance loaded)"])
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
    local entrance = self:GetRaidEntrance(raid)
    if entrance then
        add(("Entrance (data): mapID=%s  coords=%.1f, %.1f  subZone=%q"):format(
            tostring(entrance.mapID or "?"),
            (entrance.x or 0) * 100, (entrance.y or 0) * 100,
            entrance.subZone or ""))
        if raid.entrance and (raid.entrance.alliance or raid.entrance.horde) then
            add(("Entrance (data): faction pair; showing %s"):format(
                tostring(UnitFactionGroup("player"))))
        end
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

    -- Prefers raid.maps over GetMapInfo. Flags any mapID not yet declared.
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
    worldMapID = WorldMapFrame and WorldMapFrame:GetMapID()
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
        add("Step: (none -- instance complete?)")
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
-- LootProbe: logs every candidate loot event with its payload. Which event
-- fires depends on the TYPE of drop, not the raid's era.
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
    local argCount = select("#", ...)
    local parts = {}
    for i = 1, argCount do
        local arg = select(i, ...)
        parts[i] = ("arg%d=%s"):format(i, tostring(arg))
    end
    local stamp = date("%H:%M:%S")
    if argCount == 0 then
        return ("[%s] %s  (no args)"):format(stamp, event)
    end
    return ("[%s] %s\n    %s"):format(stamp, event, table.concat(parts, "\n    "))
end

local function LootEventHandler(_, event, ...)
    if not lootProbe.active then return end
    lootProbe.buffer[#lootProbe.buffer + 1] = FormatLootCapture(event, ...)
    -- One line per capture so they can be seen landing live; the full
    -- payload goes to the dump window.
    RR:Print(("|cff00ff88[LootProbe]|r %s (%d arg(s))"):format(event, select("#", ...)))
end

function RR:LootProbeStart()
    if lootProbe.active then
        self:Print(RR.L["|cff00ff88[LootProbe]|r already armed. /rr lootprobe stop to disarm."])
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
    self:Print(RR.L["|cff00ff88[LootProbe]|r Loot a mix of drops (gear, mount, pet, transmog), then /rr lootprobe stop."])
end

function RR:LootProbeStop()
    if not lootProbe.active then
        self:Print(RR.L["|cff00ff88[LootProbe]|r not armed. /rr lootprobe start to begin capture."])
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



-------------------------------------------------------------------------------
-- Copyable dump window
--
-- Shared across all debug/probe tools. Any command that produces text the
-- user needs to copy/paste should call RR:ShowCopyWindow(title, text)
-- rather than spamming chat. Chat is lossy (line wraps, scroll-off, no way
-- to select); this window opens with all text visible and a Select All
-- button for immediate Ctrl+C.
-------------------------------------------------------------------------------

local function GetOrCreateCopyWindow()
    if RetroRunsCopyFrame then return RetroRunsCopyFrame end

    local copyFrame = CreateFrame("Frame", "RetroRunsCopyFrame", UIParent, "BackdropTemplate")
    copyFrame:SetSize(600, 500)
    copyFrame:SetPoint("CENTER")
    copyFrame:SetMovable(true)
    copyFrame:EnableMouse(true)
    copyFrame:RegisterForDrag("LeftButton")
    copyFrame:SetClampedToScreen(true)
    copyFrame:SetScript("OnDragStart", copyFrame.StartMoving)
    copyFrame:SetScript("OnDragStop",  copyFrame.StopMovingOrSizing)
    copyFrame:SetFrameStrata("DIALOG")
    copyFrame:SetBackdrop({
        bgFile   = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    copyFrame:SetBackdropColor(0.05, 0.05, 0.05, 0.95)

    copyFrame.title = copyFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    copyFrame.title:SetPoint("TOPLEFT", 12, -10)

    local closeBtn = CreateFrame("Button", nil, copyFrame, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", -4, -4)
    closeBtn:SetScript("OnClick", function() copyFrame:Hide() end)

    local hint = copyFrame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    hint:SetPoint("TOPLEFT", 12, -28)
    hint:SetText("Click inside the box, press Ctrl+A to select all, then Ctrl+C to copy.")

    local selBtn = CreateFrame("Button", nil, copyFrame, "UIPanelButtonTemplate")
    selBtn:SetSize(90, 22)
    selBtn:SetPoint("TOPRIGHT", -36, -24)
    selBtn:SetText("Select All")

    local scrollFrame = CreateFrame("ScrollFrame", nil, copyFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 10, -48)
    scrollFrame:SetPoint("BOTTOMRIGHT", -30, 10)

    local editBox = CreateFrame("EditBox", nil, scrollFrame)
    editBox:SetMultiLine(true)
    editBox:SetMaxLetters(0)
    editBox:SetAutoFocus(false)
    editBox:SetFontObject(GameFontHighlightSmall)
    editBox:SetWidth(scrollFrame:GetWidth())
    editBox:SetScript("OnEscapePressed", function() copyFrame:Hide() end)
    scrollFrame:SetScrollChild(editBox)

    selBtn:SetScript("OnClick", function()
        editBox:SetFocus()
        editBox:HighlightText()
    end)

    copyFrame.editBox = editBox
    copyFrame:Hide()
    return copyFrame
end

-- A multiline EditBox renders NOTHING when SetText receives a string
-- containing an invalid UTF-8 sequence or a stray control byte -- one bad
-- byte anywhere blanks the entire window, which presented as "/rr diag is
-- blank" on a koKR client. Diagnostic text is by nature arbitrary (raw API
-- returns, captured names, ring-buffer content), so the window sanitizes:
-- every valid UTF-8 sequence passes through untouched; invalid bytes and
-- control characters (except newline and tab) are replaced with a visible
-- \xNN marker, so corrupt input renders AND shows exactly where the
-- corruption sits instead of hiding it.
local function SanitizeForEditBox(text)
    local pieces = {}
    local byteIndex = 1
    local length = #text
    while byteIndex <= length do
        local byte = text:byte(byteIndex)
        local sequenceLength
        if byte < 0x80 then
            sequenceLength = 1
        elseif byte >= 0xC2 and byte <= 0xDF then
            sequenceLength = 2
        elseif byte >= 0xE0 and byte <= 0xEF then
            sequenceLength = 3
        elseif byte >= 0xF0 and byte <= 0xF4 then
            sequenceLength = 4
        end
        local valid = sequenceLength ~= nil
        if valid and sequenceLength == 1 then
            -- Control characters other than \n and \t also break rendering.
            if byte < 0x20 and byte ~= 0x0A and byte ~= 0x09 then
                valid = false
            end
        elseif valid then
            if byteIndex + sequenceLength - 1 > length then
                valid = false
            else
                for continuation = 1, sequenceLength - 1 do
                    local contByte = text:byte(byteIndex + continuation)
                    if not contByte or contByte < 0x80 or contByte > 0xBF then
                        valid = false
                        break
                    end
                end
            end
        end
        if valid then
            pieces[#pieces + 1] = text:sub(byteIndex, byteIndex + sequenceLength - 1)
            byteIndex = byteIndex + sequenceLength
        else
            pieces[#pieces + 1] = ("\\x%02X"):format(byte)
            byteIndex = byteIndex + 1
        end
    end
    return table.concat(pieces)
end

-- Public helper usable from any module. Pass any title + any body text.
function RR:ShowCopyWindow(title, text)
    local win = GetOrCreateCopyWindow()
    win.title:SetText(title or "|cffF259C7RETRO|r|cff4DCCFFRUNS|r  |cffaaaaaaDebug Output|r")
    win.editBox:SetText(SanitizeForEditBox(text or ""))
    win.editBox:SetCursorPosition(0)
    win:Show()
end

-- Slash commands
-------------------------------------------------------------------------------

local DEV_COMMANDS = {
    sessionlog = true, mapicons = true, lfrwing = true, ej = true, newtag = true,
    locale = true, localeharvest = true, devtools = true, dt = true, record = true,
}

SLASH_RETRORUNS1 = "/retroruns"
SLASH_RETRORUNS2 = "/rr"

SlashCmdList["RETRORUNS"] = function(input)
    local msg  = RR.Trim(input):lower()
    local args = {}
    for word in msg:gmatch("%S+") do table.insert(args, word) end
    local cmd  = args[1] or ""
    local rest = RR.Trim(msg:sub(#cmd + 1))

    -- These commands are defined in DevTools, which the release build does
    -- not carry; without it they fall through to the help text.
    if DEV_COMMANDS[cmd] and not RR.ToggleDevTools then cmd = "help" end

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
        -- On-demand structural lint of all loaded raid and dungeon data. Reports
        -- errors (malformed required fields, broken cross-refs) and
        -- warnings (unverified maps[] entries, segment subZones not
        -- present in maps[], consecutive-duplicate mapIDs). Optional
        -- second arg filters to instances whose name contains that
        -- substring, e.g. `/rr lintroute Aberrus`.
        local scope = args[2]
        RR:LintRoute(scope)

    elseif cmd == "panelpos" then
        -- Panel-position provenance. Every persist and restore is tagged
        -- with the code path that asked, so a user whose panel drifts back
        -- to a corner between logins can show which write clobbered it.
        local lines = { "Panel position trace (oldest first)",
                        ("anchor: left=%s top=%s  set=%s  minimized=%s"):format(
                            tostring(RR:GetSetting("panelAnchorX")),
                            tostring(RR:GetSetting("panelAnchorY")),
                            tostring(RR:GetSetting("panelAnchorSet")),
                            tostring(RR:GetSetting("minimized"))),
                        ("legacy center: x=%s y=%s"):format(
                            tostring(RR:GetSetting("panelX")),
                            tostring(RR:GetSetting("panelY"))), "" }
        for _, entry in ipairs((RR.UI and RR.UI._panelPosTrace) or {}) do
            lines[#lines + 1] = entry
        end
        if #lines == 3 then lines[#lines + 1] = "(no writes recorded yet)" end
        RR:ShowCopyWindow("RetroRuns -- panel position",
            table.concat(lines, string.char(10)))

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
            RR:Print(RR.L["LFR bit capture log cleared."])
        else
            local log = (RetroRunsDebug and RetroRunsDebug.lfrBitLog) or {}
            local lines = {}
            local function add(line) lines[#lines + 1] = line end
            add("LFR per-boss lockout-bit capture log")
            add("(each entry = one LFR kill; 'bit' is the lockout bit that kill set)")
            add("")
            if #log == 0 then
                add("(empty -- kill LFR bosses to populate; `/rr lfrbits clear` to reset)")
            else
                for i = 1, #log do
                    local entry = log[i]
                    add(("%s  %s  ->  bit %s   [%s]"):format(
                        tostring(entry.t), tostring(entry.boss), tostring(entry.bit), tostring(entry.raid)))
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
        RR:RestorePanelPosition("reset-defaults")
        if RetroRunsSettingsFrame and RetroRunsSettingsFrame.RestorePosition then
            RetroRunsSettingsFrame:RestorePosition()
        end
        RR.UI.ApplySettings()
        RR.UI.SyncSettingsControls()
        RR:RefreshAll()
        RR:Print(RR.L["Settings reset to defaults."])

    elseif cmd == "refresh" then
        RR.state.testMode = false
        if RR.currentRaid then
            RR.state.loadedRaidKey = RR:GetRaidContextKey()
        end
        RR:RefreshAll()

    elseif cmd == "debug" then
        local newDebug = not RR:GetSetting("debug")
        RR:SetSetting("debug", newDebug)
        RR:Print(RR.L["Debug "] .. (newDebug and "ON" or "OFF"))

    elseif cmd == "test" then
        RR:ResetTestState()
        RR.UI.Update()
        if RetroRunsMapOverlay then RetroRunsMapOverlay:Refresh() end
        RR:Print(RR.L["Test mode ON -- /rr next to advance, /rr real to exit."])

    elseif cmd == "next" then
        RR:SimulateKillNext()

    elseif cmd == "real" then
        RR:DisableTestMode()
        RR:Print(RR.L["Returned to live instance state."])

    elseif cmd == "resetsegments" then
        -- Clear persisted routing-progress state for the CURRENT raid.
        -- Use when a backtrack or other quirk has left progress advanced
        -- past a seg that shouldn't yet be complete -- the renderer then
        -- surfaces the wrong segment's note. Scoped to the current raid;
        -- other raids' persisted progress is preserved.
        --
        -- Also clears the in-memory zone log ring buffer. Resetting
        -- progress is almost always done while diagnosing something,
        -- where the next thing wanted is a clean log showing only the
        -- events from the post-reset walk, not the stale entries from
        -- before it. Wiping it here removes the manual mental
        -- timestamp-filtering step.
        if not RR.currentRaid then
            RR:Print(RR.L["No instance loaded. Zone into a supported instance first."])
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
            RR:Print(("Routing progress cleared for %s. (zone log also wiped)"):format(RR.currentRaid.name))
        end

    elseif cmd == "kill" then
        if rest == "" then
            RR:Print(RR.L["Usage: /rr kill <boss name>"])
        else
            RR:ManualKill(rest)
        end

    elseif cmd == "unkill" then
        if rest == "" then
            RR:Print(RR.L["Usage: /rr unkill <boss name>"])
        else
            RR:ManualUnkill(rest)
        end

    elseif cmd == "ej" then
        RR:HarvestDiagnose()

    elseif cmd == "lockprobe" then
        RR:LockProbe()

    elseif cmd == "newtag" and RR.NewTagCommand then
        RR:NewTagCommand(args[2], RR.Trim(rest:sub(#(args[2] or "") + 1)))

    elseif cmd == "locale" then
        RR:DevLocaleCommand(rest)

    elseif cmd == "localeharvest" then
        if args[2] == "misses" then
            RR:LocaleHarvestMisses(false)
        elseif args[2] == "clearmisses" then
            RR:LocaleHarvestMisses(true)
        else
            RR:LocaleHarvest()
        end

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
            RR:Print(RR.L["Usage: /rr firedialog <dialog text>  (simulates a speakerless raid emote through the real dialog handler)"])
        else
            RR:Print(RR.L["|cff00ff88[firedialog]|r simulating speakerless emote: "] .. rawRest)
            -- Route through the real handler (no sender), so this exercises
            -- the same guard + dispatch a live CHAT_MSG_RAID_BOSS_EMOTE hits
            -- -- not a direct AdvanceProgress call that skips the handler.
            RR:SimulateDialogEvent(rawRest, nil)
        end

    elseif cmd == "record" then
        local sub = args[2] or ""
        if     sub == "start"  then RR:StartRecording()
        elseif sub == "stop"   then RR:StopRecording()
        elseif sub == "dump"   then RR:DumpRecording()
        elseif sub == "reset"  then RR:ResetRecording()
        elseif sub == "status" then RR:RecordingStatus()
        else
            RR:Print(RR.L["Record: /rr record [start|stop|dump|reset|status]"])
        end

    elseif cmd == "lootprobe" then
        local sub = args[2] or ""
        if     sub == "start" then RR:LootProbeStart()
        elseif sub == "stop"  then RR:LootProbeStop()
        else
            RR:Print(RR.L["LootProbe: /rr lootprobe [start|stop]  (capture loot/toast events to build the suppress list)"])
        end

    elseif cmd == "toaster" then
        local sub = args[2] or ""
        if     sub == "on"    then RR:EnableToaster()
        elseif sub == "off"   then RR:DisableToaster()
        elseif sub == "debug" then RR:ToasterDebug()
        elseif sub == "clear" then RR:ToasterClearTrace()
        elseif sub == "probe" then
            if RR.ToastProbe then RR:ToastProbe(args[3], args[4]) end
        elseif sub == "navharvest" then
            if RR.ToastNavHarvest then RR:ToastNavHarvest() end
        else                       RR:ToggleToaster()
        end

    elseif cmd == "cancelnav" then
        if RR.state.activeRoute then
            RR:CancelNavRoute()
            RR:Print(RR.L["Navigation canceled."])
        else
            RR:Print(RR.L["No active navigation route."])
        end

    elseif cmd == "status" then
        RR:PrintStatus()

    else
        -- Help text. Default output is a short user-facing list; dev and
        -- diagnostic commands are hidden behind `/rr help dev` so the normal
        -- help stays focused on what players actually use.
        local subcmd = args[2] or ""
        if subcmd == "dev" then
            RR:Print(RR.L["RetroRuns dev commands:"])
            RR:Print(RR.L["  /rr  debug                       (toggle verbose logging)"])
            RR:Print(RR.L["  /rr  test | next | real          (test-mode stepping)"])
            RR:Print(RR.L["  /rr  resetsegments               (clear persisted segment state)"])
            RR:Print(RR.L["  /rr  kill <name> | unkill <name> (manual kill-state override)"])
            RR:Print(RR.L["  /rr  record [start|stop|dump|reset|status]"])
            RR:Print(RR.L["  /rr  sessionlog [all]            (recorder session log; omit `all` for current-instance only)"])
            RR:Print(RR.L["  /rr  lintroute [instance name]   (structural lint of instance routing data)"])
            RR:Print(RR.L["  /rr  diag                        (consolidated engine, zone and session logs)"])
            RR:Print(RR.L["  /rr  mapicons                    (dump exact coords of every Blizzard icon on the visible map)"])
            RR:Print(RR.L["  /rr  ej                          (EJ + instance-info dump for bring-up)"])
            RR:Print(RR.L["  /rr  devtools (or dt)             (toggle the DevTools panel)"])
            RR:Print(RR.L["  /rr  cancelnav                   (cancel an active entrance-navigation route)"])
            RR:Print(RR.L["  /rr  reset | refresh             (reset settings to defaults | re-render the main panel)"])
        else
            RR:Print(RR.L["RetroRuns commands:"])
            RR:Print(RR.L["  /rr                  (toggle main panel)"])
            RR:Print(RR.L["  /rr  status          (current instance, step, kill state)"])
            RR:Print(RR.L["  /rr  tmog            (open transmog browser)"])
            RR:Print(RR.L["  /rr  skips           (account-wide raid skip status)"])
            RR:Print(RR.L["  /rr  settings        (open settings window)"])
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
            RR:ApplyLocale()
            -- The locale choice is final once the saved override has been
            -- read, and RR.L holds the active strings, so the ten source
            -- tables (nine of them for other clients) can go to the
            -- collector instead of living in memory all session.
            RR.LocaleTables = {}
            if RR:GetSetting("debug") then ValidateRaidData() end
            C_Timer.After(0, function()
                RR:RestorePanelPosition("addon-loaded")
                RR:InitMinimapButton()
                RR:InitDialogTriggers()
                RR:RefreshAll()
            end)
        end

    elseif event == "PLAYER_LOGIN" then
        -- Apply faction-variant encounters before anything renders boss
        -- names or builds EJ maps. PLAYER_LOGIN is the earliest point
        -- where UnitFactionGroup is reliable on initial login.
        RR:ResolveFactionEncounters()

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
        -- queue. Guarded on the API existing so an older version, or its
        -- absence, silently no-ops.
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
        -- on each fresh login/reload, and the prior persistent behavior
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
                        C_Item.GetItemInfo(tokenID)
                    end
                end
            end
        end

    elseif event == "PLAYER_ENTERING_WORLD" then
        local isInitialLogin, isReloadingUi = ...
        RR.state.isReloadingUi = isReloadingUi and true or false

        RR:ZoneLog(("PEW: isInitialLogin=%s isReloadingUi=%s"):format(
            tostring(isInitialLogin), tostring(isReloadingUi)))

        -- Re-assert the saved panel position. The client applies its own
        -- cached frame layout between ADDON_LOADED and here, which can
        -- override the position applied at load time on installs where a
        -- character still carries an old per-character entry. Running the
        -- restore again after that pass makes the shared position final.
        RR:RestorePanelPosition("player-entering-world")

        -- Load-time visibility, applied once per login. The panel painted
        -- from its saved state back at ADDON_LOADED, so a login refreshes
        -- to pick the new values up; both loads sit behind the loading
        -- screen until here, so nothing visible changes underneath.
        if isInitialLogin then
            RR:ApplyLaunchMode()
            RR:RefreshAll()
        end

        -- The random-dungeon list the Timewalking marker reads answers
        -- empty until the client's first lock-info push, so the login
        -- paint shows no marker. Ask for the push; the handler repaints
        -- when it lands.
        if RequestLFDPlayerLockInfo then RequestLFDPlayerLockInfo() end

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
            -- The first seconds after a login are a settle window: the
            -- client's map reads can name the wrong floor outright
            -- so the wing hold stays provisional
            -- until it closes.
            RR.state.loginSettleUntil = GetTime() + 30
        end

        C_Timer.After(1.0, function() RR:HandleLocationChange() end)

        -- The EJ map cache is per session, so both a login and a /reload
        -- start cold. Warm it once the location settle has run.
        C_Timer.After(3.0, function() RR:WarmEncounterJournalMaps() end)

    elseif event == "LFG_LOCK_INFO_RECEIVED" then
        RR:RefreshTimewalkingFromLockInfo()

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
                -- The kill landed; any pending kill-sync retry can stop.
                RR.state.killSyncRetryActive = nil
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

    elseif event == "PLAYER_LOGOUT" then
        -- Fires on camp, exit and /reload alike, just before SavedVariables
        -- write out -- the one moment the logout spot can be stamped.
        if RR.StampLastSeen then RR:StampLastSeen() end

    elseif event == "SCENARIO_CRITERIA_UPDATE" then
        -- A scenario objective changed state. Scenario triggers are state
        -- checks, so no payload is carried; the advance re-reads the API.
        -- The same update also carries kill completions, and it is the
        -- only witness to a kill whose ENCOUNTER_END and BOSS_KILL both
        -- fail to arrive.
        if RR.currentRaid and RR.state.loadedRaidKey then
            RR:ApplyLiveScenarioKills("criteria update")
            RR:AdvanceProgress("scenario")
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
                -- Also offer the kill to segment routing. Scripted fights
                -- that end a leg of a route can have their own
                -- DungeonEncounter row without being journal bosses (Ruby
                -- Sanctum's lieutenants), so the two paths are independent:
                -- the marker above ignores them, this advances past them.
                -- Only segs declaring triggeredBy.encounter can act on it.
                RR:AdvanceProgress("encounter-end", { encounterID = encounterID })
                RR.UI.Update()
                if RetroRunsMapOverlay then RetroRunsMapOverlay:Refresh() end
            else
                -- Not reported as a success. Usually a wipe or a reset,
                -- but multi-stage encounters end each stage this way and
                -- some never report a success at all: The Northrend
                -- Beasts fires three times with success=0 (Gormok, the
                -- worms, Icehowl) and never once with success=1, so the
                -- ID path above can't register the kill and the only
                -- sources left are BOSS_KILL and the saved-instance
                -- cache. Ask the server now, then keep asking on a short
                -- backoff: the credit can land seconds after this first
                -- query has already come back empty, and the server does
                -- not push an update to a stationary player on its own.
                -- Each reply lands as UPDATE_INSTANCE_INFO, whose handler
                -- syncs and re-renders only when the kill set actually
                -- changed -- so on a genuine wipe this costs a few round
                -- trips and changes nothing on screen.
                if RequestRaidInfo then RequestRaidInfo() end
                RR:ScheduleKillSyncRetry()
                -- Re-render so the travel pane snaps back to the live
                -- (non-frozen) text.
                RR.UI.Update()
            end
        end

    elseif event == "BOSS_KILL" then
        -- Kill credit, as distinct from ENCOUNTER_END's script verdict. A
        -- solo player can out-pace a scripted fight so it ends success=0
        -- (or never reports a success at all) while the server still
        -- grants the kill; this event fires when the credit lands. Same
        -- marking path as a success=1 ENCOUNTER_END, and marking an
        -- already-marked boss is a no-op, so overlap with a clean success
        -- is harmless.
        local encounterID, encounterName = ...

        RR:ZoneLog(("BOSS_KILL fired: id=%s name=%q loadedKey=%s currentKey=%s")
            :format(tostring(encounterID), tostring(encounterName),
                    tostring(RR.state.loadedRaidKey),
                    tostring(RR:GetRaidContextKey())))

        if not RR.state.testMode
            and RR.currentRaid
            and RR.state.loadedRaidKey == RR:GetRaidContextKey() then
            if not RR:MarkBossKilledByEncounterID(encounterID) then
                -- The name can carry trailing titles ("X, Champion of the
                -- Naaru"); strip them so the name fallback can match.
                if type(encounterName) == "string" then
                    RR:MarkBossKilledByEncounterName(
                        (encounterName:gsub(",.*$", "")))
                end
            end
            RR:AdvanceProgress("encounter-end", { encounterID = encounterID })
            RR.UI.Update()
            if RetroRunsMapOverlay then RetroRunsMapOverlay:Refresh() end
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
        -- Remember which boss this is, so the transmog button can open on
        -- it. A routed instance takes the boss from its active step; an
        -- unrouted one (every dungeon, until its route is built) has no
        -- step to read, and the boss being pulled is the best answer
        -- available. Kept after the fight so the button still lands on it
        -- while looting.
        local startedEncounterID = ...
        -- Logged as well as END: without this pair there is no way to tell
        -- a dropped END from an encounter that never engaged at all.
        RR:ZoneLog(("ENCOUNTER_START fired: id=%s loadedKey=%s currentKey=%s")
            :format(tostring(startedEncounterID),
                    tostring(RR.state.loadedRaidKey),
                    tostring(RR:GetRaidContextKey())))
        local startedBoss = RR:GetBossByEncounterID(startedEncounterID)
        if startedBoss then
            RR.state.lastEncounterBossIndex = startedBoss.index
            -- A boss cannot be pulled twice in one spawned instance, so an
            -- encounter starting on a boss already recorded dead proves the
            -- instance reset while the run record survived.
            if RR.state.bossesKilled[startedBoss.index]
                and not RR.state.testMode
                and not RR:GetCurrentLockoutId()
                and RR.HandleStaleRunRecord then
                RR:ZoneLog(("encounter started on recorded-dead boss %d")
                    :format(startedBoss.index))
                RR:HandleStaleRunRecord()
            end
        end
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

-- "Reset all instances" ends every run outright, so the kill record for a
-- non-saving instance has to go with it -- otherwise a mount farmer's next
-- lap would open with the previous lap's bosses already checked off. Hooked
-- rather than read from chat: the hook fires on the actual call and needs
-- no localized message matching.
if type(_G.ResetInstances) == "function" then
    hooksecurefunc("ResetInstances", function()
        -- The hook fires even when the game refuses the reset, which it
        -- always does for the instance the player is standing in -- so a
        -- record describing that instance survives the call.
        local info = RR:GetCurrentInstanceInfo()
        local inside = (info.instanceType == "party" or info.instanceType == "raid")
            and info.instanceID or nil
        local cleared, kept = 0, 0
        local function judge(record)
            -- The game refuses to reset the instance the player stands in,
            -- wings included -- they share the map -- so those slots survive.
            return record and inside and record.instanceID == inside
        end
        if RetroRunsDB then
            if RetroRunsDB.activeRun and not judge(RetroRunsDB.activeRun) then
                RetroRunsDB.activeRun = nil
                cleared = cleared + 1
            elseif RetroRunsDB.activeRun then
                kept = kept + 1
            end
            for jid, record in pairs(RetroRunsDB.activeRuns or {}) do
                if judge(record) then
                    kept = kept + 1
                else
                    RetroRunsDB.activeRuns[jid] = nil
                    cleared = cleared + 1
                end
            end
        end
        if cleared > 0 or kept > 0 then
            RR:ZoneLog(("ResetInstances called: %d record(s) cleared, %d kept")
                :format(cleared, kept))
        end
        RR:AdvanceInstanceGeneration()
    end)
end

RR.frame:RegisterEvent("ADDON_LOADED")
RR.frame:RegisterEvent("PLAYER_LOGIN")
RR.frame:RegisterEvent("PLAYER_ENTERING_WORLD")
RR.frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
RR.frame:RegisterEvent("ZONE_CHANGED")
RR.frame:RegisterEvent("ZONE_CHANGED_INDOORS")
RR.frame:RegisterEvent("UPDATE_INSTANCE_INFO")
RR.frame:RegisterEvent("LFG_LOCK_INFO_RECEIVED")
RR.frame:RegisterEvent("ENCOUNTER_END")
RR.frame:RegisterEvent("SCENARIO_CRITERIA_UPDATE")
RR.frame:RegisterEvent("BOSS_KILL")
RR.frame:RegisterEvent("ENCOUNTER_START")
RR.frame:RegisterEvent("GET_ITEM_INFO_RECEIVED")
RR.frame:RegisterEvent("PLAYER_LOGOUT")

-------------------------------------------------------------------------------
-- Tickers
-------------------------------------------------------------------------------

-- UI heartbeat. Fires once per second while in a loaded raid; calls
-- UI.Update unconditionally. The tick itself is never logged to ZoneLog,
-- even in debug mode: a once-per-second constant line floods the ring
-- buffer (60 entries per minute) and evicts the entries that matter.
local heartbeatTicks = 0
C_Timer.NewTicker(1.0, function()
    -- Outside an instance the full heartbeat stays off, but the footer's
    -- instance counter is a CLOCK -- its minutes tick down while the player
    -- stands still, and zone events are the only other repaint out there.
    -- A narrow refresh every 30s keeps it honest without waking the panel.
    if not RR.currentRaid then
        heartbeatTicks = heartbeatTicks + 1
        if heartbeatTicks % 30 == 0
            and RR.UI and RR.UI.RefreshFooterStatus then
            RR.UI.RefreshFooterStatus()
        end
        return
    end
    if RR.currentRaid
        and RR.state.loadedRaidKey == RR:GetRaidContextKey() then
        heartbeatTicks = heartbeatTicks + 1
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

        -- Scenario-criteria backstop, every fifth tick. SCENARIO_CRITERIA_
        -- UPDATE is the primary path; this bounds how long a missed kill
        -- can sit unrecorded when no further update is coming.
        if heartbeatTicks % 5 == 0 and RR.ApplyLiveScenarioKills then
            RR:ApplyLiveScenarioKills("heartbeat")
        end
    end
end)
