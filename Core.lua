-------------------------------------------------------------------------------
-- RetroRuns -- Core.lua
-- Namespace, DB lifecycle, event hub, slash commands, shared utilities.
-- No UI frame references. No navigation logic.
-------------------------------------------------------------------------------

local ADDON_NAME = "RetroRuns"
local VERSION    = "1.2.0"

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
    while #buf > 200 do table.remove(buf, 1) end
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

local function ValidateRaidData()
    if not RetroRuns_Data then
        RR:Debug("RetroRuns_Data is nil -- no raid data loaded.")
        return
    end

    -- Validation output is developer / maintainer signal, not something a
    -- regular player needs to see in chat every /reload. Route all warnings
    -- through RR:Debug(), which no-ops unless `/rr debug` is on. Turn debug
    -- on when iterating on new raid data or chasing a suspected bad entry.
    local warn = function(msg) RR:Debug(msg) end

    for instanceID, raid in pairs(RetroRuns_Data) do
        local prefix = ("Data[%s] (%s):"):format(
            tostring(instanceID), tostring(raid.name or "?"))

        if not raid.instanceID then
            warn(prefix .. " missing instanceID")
        end
        if type(raid.bosses) ~= "table" or #raid.bosses == 0 then
            warn(prefix .. " missing or empty bosses table")
        end
        if type(raid.routing) ~= "table" or #raid.routing == 0 then
            warn(prefix .. " missing or empty routing table")
        end

        -- Build a set of valid boss indices for cross-checking, and
        -- while we're walking the bosses, validate specialLoot entries
        -- (optional field; each entry must have id + recognized kind).
        local validBossIndices = {}
        local VALID_SPECIAL_KINDS = { mount = true, pet = true, toy = true, decor = true }
        for _, boss in ipairs(raid.bosses or {}) do
            if not boss.index then
                warn(prefix .. " boss missing index field")
            elseif not boss.name then
                warn(prefix .. " boss #" .. boss.index .. " missing name")
            else
                validBossIndices[boss.index] = true
            end

            if boss.specialLoot ~= nil then
                if type(boss.specialLoot) ~= "table" then
                    warn(prefix .. (" boss #%s specialLoot must be a table"):format(
                        tostring(boss.index)))
                else
                    for si, item in ipairs(boss.specialLoot) do
                        local bp = prefix .. (" boss #%s specialLoot[%d]:"):format(
                            tostring(boss.index), si)
                        if not item.id then
                            warn(bp .. " missing id")
                        end
                        if not item.kind then
                            warn(bp .. " missing kind (mount|pet|toy|decor)")
                        elseif not VALID_SPECIAL_KINDS[item.kind] then
                            warn(bp .. (" unrecognized kind '%s' (expected mount|pet|toy|decor)"):format(
                                tostring(item.kind)))
                        end
                    end
                end
            end
        end

        for i, step in ipairs(raid.routing or {}) do
            local sp = prefix .. " step " .. i .. ":"
            if not step.bossIndex then
                warn(sp .. " missing bossIndex")
            elseif not validBossIndices[step.bossIndex] then
                warn(sp .. (" bossIndex %d has no matching boss"):format(
                    step.bossIndex))
            end
            if not step.requires then
                warn(sp .. " missing requires table (use {} for none)")
            else
                for _, req in ipairs(step.requires) do
                    if not validBossIndices[req] then
                        warn(sp .. (" requires unknown bossIndex %d"):format(req))
                    end
                end
            end
            if not step.segments or #step.segments == 0 then
                warn(sp .. " has no segments")
            else
                for si, seg in ipairs(step.segments) do
                    if not seg.mapID then
                        warn(sp .. (" segment %d missing mapID"):format(si))
                    end
                    if not seg.kind then
                        warn(sp .. (" segment %d missing kind"):format(si))
                    end
                    -- `points` may legitimately be empty for teleport /
                    -- portal segments that carry only a note, so we don't
                    -- warn on an empty points list the way we warn on
                    -- missing mapID/kind. Segments with NO points table at
                    -- all (structurally malformed) would still be caught
                    -- by the nil-check in the rendering path.
                end
            end
        end
    end
end

-------------------------------------------------------------------------------
-- SavedVariable lifecycle
-------------------------------------------------------------------------------

function RR:InitializeDB()
    RetroRunsDB = RetroRunsDB or {}
    MergeDefaults(RetroRunsDB, self.defaults)
    RetroRunsDB.showPanel = false
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
local ejMapCache = {}

local function GetEJMapForJournalInstance(journalInstanceID)
    if not journalInstanceID then return nil end
    local cached = ejMapCache[journalInstanceID]
    if cached then return cached end
    local jeToDe = {}
    local i = 1
    while true do
        local _, _, je, _, _, _, de = EJ_GetEncounterInfoByIndex(i, journalInstanceID)
        if not je then break end
        if de then jeToDe[je] = de end
        i = i + 1
    end
    ejMapCache[journalInstanceID] = jeToDe
    return jeToDe
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

-- Returns the highest difficulty for which the skip is unlocked on the
-- account, or nil if no flag is set or the raid has no skipQuests
-- config. Returned values are WoW raid difficulty IDs:
--   16 = Mythic, 15 = Heroic, 14 = Normal.
-- LFR (17) is intentionally excluded -- LFR raids don't have skip quests.
function RR:GetRaidSkipUnlockedCeiling(raid)
    if not raid or not raid.skipQuests then return nil end
    local fn = C_QuestLog and C_QuestLog.IsQuestFlaggedCompletedOnAccount
    if not fn then return nil end
    if raid.skipQuests.mythic and fn(raid.skipQuests.mythic) then return 16 end
    if raid.skipQuests.heroic and fn(raid.skipQuests.heroic) then return 15 end
    if raid.skipQuests.normal and fn(raid.skipQuests.normal) then return 14 end
    return nil
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

function RR:GetSupportedRaid()
    local info = self:GetCurrentInstanceInfo()
    if info.instanceType ~= "raid" then return nil end
    if RetroRuns_Data then
        if RetroRuns_Data[info.instanceID] then
            return RetroRuns_Data[info.instanceID]
        end
        if info.name then
            local needle = self:NormalizeName(info.name)
            for _, raid in pairs(RetroRuns_Data) do
                if self:NormalizeName(raid.name) == needle then
                    return raid
                end
            end
        end
    end
    return nil
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
-- save) so stale segment marks don't survive into a fresh lockout. See
-- HANDOFF 2026-04-26 stale-persistence investigation for context.
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

    if not (RetroRunsDB and RetroRunsDB.completedSegments) then return end
    if not self.currentRaid then return end

    local store = RetroRunsDB.completedSegments[self.currentRaid.instanceID]
    if not store then return end

    local currentLockoutId = self:GetCurrentLockoutId()
    -- Old-schema record (no segments field) OR lockoutId mismatch:
    -- persistence is stale (different lockout, or pre-0.6.1 schema),
    -- wipe it. Initial-login wipe in PEW handles cross-WoW-session
    -- staleness; this guard handles the smaller case where a /reload
    -- happens AFTER the weekly reset rolled the lockout.
    if not store.lockoutId or store.lockoutId ~= currentLockoutId then
        RetroRunsDB.completedSegments[self.currentRaid.instanceID] = nil
        return
    end

    -- Lockout matches: restore segments.
    if store.segments then
        for stepIndex, segs in pairs(store.segments) do
            self.state.completedSegments[stepIndex] = {}
            for segIndex, v in pairs(segs) do
                self.state.completedSegments[stepIndex][segIndex] = v
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
    self:SyncFromSavedRaidInfo(true)   -- request fresh server data
    self:RestorePersistedSegments()
    self:ComputeNextStep()
    self:RefreshAll()
end

function RR:LoadCurrentRaid()
    if not self.currentRaid then return end
    self.state.loadedRaidKey = self:GetRaidContextKey()

    self:RestorePersistedSegments()

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
        .. "|cffc0c0c0Designed for max-level characters running legacy content.|r",
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
            -- removal-rejection guard (added 2026-04-25 to defeat
            -- saved-instance cache hiccups mid-session) would
            -- otherwise refuse to clear the stale data when the new
            -- raid's cache reports no kills.
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
-- UI. Pasteable so Photek can share it during debugging.
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
    -- the raid.maps hand-authored name, which is the real dropdown
    -- label from the world map frame. Blizzard's GetMapInfo API
    -- returns the parent raid name for sub-zones in raids like
    -- Sanctum, so the API alone is not useful here. Flags any
    -- mapID not yet in raid.maps so we know which sub-zones still
    -- need to be declared as routes get recorded.
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

    elseif cmd == "traveldebug" then
        -- Snapshot of the inputs the travel-pane renderer is using right
        -- now: player mapID, world-map mapID, the mapID the renderer
        -- would actually pick (GetBestMapForStep), and per-segment state
        -- (mapID, has-note, completed). Used to diagnose "why is the
        -- travel pane showing the wrong segment's note?" One-shot dump
        -- rather than per-update, so chat doesn't get spammed.
        RR:TravelDebug()

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

    elseif cmd == "dragontest" then
        -- Probe a single itemID against APIs likely to track dragon-
        -- riding manuscript appearance unlocks. Manuscripts are
        -- consumable items: using one casts a spell that unlocks a
        -- customization in the dragonriding UI. After consumption the
        -- itemID is gone, but the unlock state persists. We need to
        -- find which API surface answers "is the unlock learned" --
        -- this probe dumps every plausible call so we can identify it
        -- empirically.
        local id = tonumber(args[2])
        if not id then
            RR:Print("Usage: /rr dragontest <itemID>  (e.g. 201790 for Renewed Proto-Drake: Embodiment of the Storm-Eater)")
        else
            local lines = {}
            local function add(s) table.insert(lines, s) end

            add(("dragontest itemID=%d"):format(id))

            -- Item-level info first
            local name, link, _, _, _, itemType, itemSubType, _, equipLoc, _, _, classID, subclassID = GetItemInfo(id)
            add(("GetItemInfo: name=%s itemType=%s itemSubType=%s equipLoc=%q classID=%s subclassID=%s"):format(
                tostring(name), tostring(itemType), tostring(itemSubType),
                tostring(equipLoc or ""), tostring(classID), tostring(subclassID)))
            add(("  link=%s"):format(tostring(link)))

            -- The item triggers a spell on use. That spell's ID is
            -- usually the durable identifier for the unlock.
            if GetItemSpell then
                local spellName, spellID = GetItemSpell(id)
                add(("GetItemSpell: name=%s spellID=%s"):format(
                    tostring(spellName), tostring(spellID)))
                if spellID then
                    if IsPlayerSpell then
                        add(("  IsPlayerSpell(%d): %s"):format(spellID, tostring(IsPlayerSpell(spellID))))
                    end
                    if IsSpellKnown then
                        add(("  IsSpellKnown(%d): %s"):format(spellID, tostring(IsSpellKnown(spellID))))
                    end
                    if IsSpellKnownOrOverridesKnown then
                        add(("  IsSpellKnownOrOverridesKnown(%d): %s"):format(
                            spellID, tostring(IsSpellKnownOrOverridesKnown(spellID))))
                    end
                end
            else
                add("GetItemSpell: (function missing)")
            end

            -- Dragonriding-specific namespace (might exist as
            -- C_PlayerInfo, C_MountJournal extension, or its own C_*).
            -- Probe with try-catch so missing tables don't crash.
            local function probeNamespace(ns, label)
                if type(ns) == "table" then
                    add(("%s: (table present)"):format(label))
                    -- List visible function-typed members for orientation
                    for k, v in pairs(ns) do
                        if type(v) == "function" then
                            add(("    %s.%s (function)"):format(label, k))
                        end
                    end
                else
                    add(("%s: (not present)"):format(label))
                end
            end
            -- Dragon riding lived under different names through DF/TWW
            -- patches. Probe several.
            probeNamespace(C_PlayerInfo, "C_PlayerInfo")

            -- C_MountJournal.GetMountFromItem still useful here in case
            -- manuscripts unlock customizations associated with a parent
            -- mount ID.
            if C_MountJournal and C_MountJournal.GetMountFromItem then
                local mountID = C_MountJournal.GetMountFromItem(id)
                add(("C_MountJournal.GetMountFromItem: %s"):format(tostring(mountID)))
            end

            -- C_MountJournal might have a GetIsDragonRidingMount or
            -- similar extension on parent mounts.
            if C_MountJournal and C_MountJournal.GetMountIDs then
                add("C_MountJournal.GetMountIDs: (skipped enumeration; too many entries)")
            end

            -- Toy/PlayerHasToy is unlikely to apply but cheap to confirm
            if PlayerHasToy then
                add(("PlayerHasToy(%d): %s"):format(id, tostring(PlayerHasToy(id))))
            end

            RetroRunsDebug = RetroRunsDebug or {}
            RetroRunsDebug.dragontest = table.concat(lines, "\n")

            RR:ShowCopyWindow(
                ("|cffF259C7RETRO|r|cff4DCCFFRUNS|r  |cffaaaaaaDebug: dragontest %d|r"):format(id),
                table.concat(lines, "\n"))
            RR:Print(("dragontest %d complete. Copy window opened."):format(id))
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

            RR:Print("tmogverify: warming item cache, please wait 1s...")

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

                add(("tmogverify: raid=%s"):format(tostring(raid.name or "?")))
                add("Data-integrity check: every sourceID in the data file is")
                add("validated against the live Blizzard API.")
                add("")
                add("Severity tags:")
                add("  [ERR] definite data bug -- fix before next release")
                add("  [WRN] suspicious, may be legit -- manual review")
                add("  [--] informational (shape/structure notes)")
                add("")

                for _, boss in ipairs(raid.bosses) do
                    add(("=== Boss %d: %s ==="):format(
                        boss.index or 0, boss.name or "?"))

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
                                        if apiDiff and apiDiff ~= diffID then
                                            table.insert(findings, ("[ERR] %s src=%d: itemContext=%d says difficulty=%s, but lives in %s slot"):format(
                                                DIFF_NAME[diffID], b.src, ctx,
                                                DIFF_NAME[apiDiff] or tostring(apiDiff),
                                                DIFF_NAME[diffID]))
                                            T.bucket_mismatch = (T.bucket_mismatch or 0) + 1
                                        end
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
                                add(("  [OK]  %-7d  %s%s"):format(
                                    item.id, item.name or "?", classTag))
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
                        add("  (no regular loot)")
                    end

                    -- Special loot
                    if boss.specialLoot and #boss.specialLoot > 0 then
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
                            end
                            local mythicTag = sp.mythicOnly and " [Mythic only]" or ""
                            if #findings == 0 then
                                add(("  [OK]  %-7d  (%s) %s%s"):format(
                                    sp.id or 0, sp.kind or "?",
                                    sp.name or "?", mythicTag))
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
                add(("  [ERR] bucket-slot mismatches:  %d"):format(T.bucket_mismatch))
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
                add("  Binary-shape items are rendered by the UI as a single")
                add("  bracketed indicator (not a 4-dot strip); the cloned-")
                add("  across-buckets encoding in the data file is the")
                add("  established convention for single-variant items.")

                RetroRunsDebug = RetroRunsDebug or {}
                RetroRunsDebug.tmogverify = table.concat(lines, "\n")

                RR:ShowCopyWindow(
                    ("|cffF259C7RETRO|r|cff4DCCFFRUNS|r  |cffaaaaaaDebug: tmogverify|r"),
                    table.concat(lines, "\n"))
                RR:Print("tmogverify complete. Copy window opened.")
            end) -- C_Timer.After callback closer
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
            RR:Print("  /rr  raidcapture                 (full new-raid tier + loot harvest)")
            RR:Print("  /rr  weaponharvest               (harvest CN weapon-token pools)")
            RR:Print("  /rr  vendorscan                  (scan open merchant frame for items+costs)")
            RR:Print("  /rr  tmogtest <itemID>           (transmog diagnostic)")
            RR:Print("  /rr  ejprobe [itemID]            (dump EJ loot for selected encounter)")
            RR:Print("  /rr  tierprobe <itemID>          (dump C_TransmogSets sources for a tier itemID)")
            RR:Print("  /rr  traveldebug                 (snapshot of travel-pane renderer state)")
            RR:Print("  /rr  srctest <sourceID>          (transmog source diagnostic)")
            RR:Print("  /rr  specialtest <itemID>        (special-loot API probe)")
            RR:Print("  /rr  dragontest <itemID>         (dragonriding manuscript API probe)")
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
        if isInitialLogin and RetroRunsDB then
            RetroRunsDB.completedSegments = {}
            RR:ZoneLog("PEW: initial login -- wiped persisted segments")
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
        local _, encounterName, _, _, success = ...
        RR:ZoneLog(("ENCOUNTER_END fired: name=%q success=%s testMode=%s loadedKey=%s currentKey=%s")
            :format(tostring(encounterName), tostring(success),
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
                RR:MarkBossKilledByEncounterName(encounterName)
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
    end
end)
