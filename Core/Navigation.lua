-------------------------------------------------------------------------------
-- RetroRuns -- Navigation.lua
-- Boss resolution, step computation, segment selection, progress tracking,
-- teleport-arrival detection. Pure logic -- no UI or frame references.
-------------------------------------------------------------------------------

local RR = RetroRuns

-------------------------------------------------------------------------------
-- Boss lookup
-------------------------------------------------------------------------------

function RR:GetBossByIndex(index)
    if not self.currentRaid then return nil end
    for _, boss in ipairs(self.currentRaid.bosses) do
        if boss.index == index then return boss end
    end
end

function RR:GetBossByName(name)
    if not self.currentRaid or not name then return nil end
    for _, boss in ipairs(self.currentRaid.bosses) do
        if boss.name == name then return boss end
    end
end

function RR:GetBossByNormalizedName(name)
    if not self.currentRaid or not name then return nil end
    local needle = self:NormalizeName(name)
    for _, boss in ipairs(self.currentRaid.bosses) do
        if self:NormalizeName(boss.name) == needle then return boss end
        if boss.aliases then
            for _, alias in ipairs(boss.aliases) do
                if self:NormalizeName(alias) == needle then return boss end
            end
        end
    end
end

function RR:ResolveBoss(name)
    local boss = self:GetBossByName(name) or self:GetBossByNormalizedName(name)
    if boss then return boss end
    -- Locale fallback: on non-English clients, callers like the saved-instance
    -- lockout sync hand us Blizzard-localized boss names, which never match the
    -- English boss.name/aliases above. The Encounter Journal returns names in
    -- the client's language, so translate localized name -> journalEncounterID
    -- via the memoized EJ walk, then find the boss carrying that id. Costs
    -- nothing on English clients (the direct paths above already matched).
    if not (self.currentRaid and self.currentRaid.journalInstanceID) then return nil end
    local nameMap = self:GetEJNameMapForJournalInstance(self.currentRaid.journalInstanceID)
    local journalEncID = nameMap and nameMap[name]
    if journalEncID then
        for _, candidate in ipairs(self.currentRaid.bosses) do
            if candidate.journalEncounterID == journalEncID then
                return candidate
            end
        end
    end
    -- The saved-instance lockout names its encounters from a different
    -- Blizzard table than the Encounter Journal, and the two tables can
    -- disagree on a boss's localized name (Mogu'shan Vaults boss 3 in
    -- Spanish: the lockout says "Gara'jal el Vinculador de Espíritus",
    -- the journal just "Gara'jal"). When the journal lookup misses,
    -- compare against the addon's own translation of each boss name and
    -- alias, folded through NormalizeName so casing and accent
    -- differences between the two Spanish locales cannot break the
    -- match. On English clients every translation is the identity, so
    -- the guard skips all comparisons.
    local needle = self:NormalizeName(name)
    if needle then
        for _, candidate in ipairs(self.currentRaid.bosses) do
            local translated = RR.L[candidate.name]
            if translated ~= candidate.name
                and self:NormalizeName(translated) == needle then
                return candidate
            end
            if candidate.aliases then
                for _, alias in ipairs(candidate.aliases) do
                    local translatedAlias = RR.L[alias]
                    if translatedAlias ~= alias
                        and self:NormalizeName(translatedAlias) == needle then
                        return candidate
                    end
                end
            end
        end
    end
    return nil
end

-- Locale-independent boss lookup. ENCOUNTER_END's encounterID is a
-- dungeonEncounterID; our data uses journalEncounterID. Bridge via
-- Core.lua's cached map. Returns nil if the ID doesn't resolve --
-- callers should fall back to name-based lookup.
function RR:GetBossByEncounterID(encounterID)
    if not self.currentRaid or not encounterID then return nil end
    local journalInstanceID = self.currentRaid.journalInstanceID
    if not journalInstanceID then return nil end

    -- EJ-derived journal->dungeon map. May be missing entries for hidden
    -- bonus bosses the journal doesn't index (e.g. Ra-den), so it's not a
    -- hard requirement -- the explicit dungeonEncounterID below covers those.
    local jeToDe = self:GetEJMapForJournalInstance(journalInstanceID) or {}

    for _, boss in ipairs(self.currentRaid.bosses) do
        if boss.journalEncounterID and jeToDe[boss.journalEncounterID] == encounterID then
            return boss
        end
        -- Explicit dungeonEncounterID in the data, for bosses the EJ doesn't
        -- expose. Observed from the live ENCOUNTER_END event at bring-up.
        if boss.dungeonEncounterID and boss.dungeonEncounterID == encounterID then
            return boss
        end
    end
    return nil
end

-- Returns true if the encounterID resolved to a boss and the kill
-- was marked; false otherwise (caller falls back to name-based lookup).
function RR:MarkBossKilledByEncounterID(encounterID)
    if not self.currentRaid or not encounterID then return false end
    local boss = self:GetBossByEncounterID(encounterID)
    if boss then
        if self.ZoneLog then
            self:ZoneLog((
                "MarkBossKilledByEncounterID: resolved encounterID %d -> bossIndex %d (%s)"
            ):format(encounterID, boss.index, boss.name))
        end
        self:MarkBossKilled(boss)
        self:ComputeNextStep()
        return true
    else
        if self.ZoneLog then
            self:ZoneLog((
                "MarkBossKilledByEncounterID: NO MATCH for encounterID=%d (will try name fallback)"
            ):format(encounterID))
        end
        return false
    end
end

-------------------------------------------------------------------------------
-- Kill state
-------------------------------------------------------------------------------

function RR:IsBossKilled(index)
    return self.state.bossesKilled[index] == true
end

function RR:MarkBossKilled(boss)
    if not boss then return end
    self.state.bossesKilled[boss.index] = true
    if self.state.manualTargetBossIndex == boss.index then
        self.state.manualTargetBossIndex = nil
    end
end

function RR:MarkBossKilledByEncounterName(encounterName)
    if not self.currentRaid or not encounterName then
        if self.ZoneLog then
            self:ZoneLog(("MarkBossKilledByEncounterName: bailing -- currentRaid=%s name=%s")
                :format(tostring(self.currentRaid), tostring(encounterName)))
        end
        return
    end
    local boss = self:ResolveBoss(encounterName)
    if boss then
        if self.ZoneLog then
            self:ZoneLog(("MarkBossKilledByEncounterName: resolved %q -> bossIndex %d (%s)")
                :format(encounterName, boss.index, boss.name))
        end
        self:MarkBossKilled(boss)
        self:ComputeNextStep()
    else
        if self.ZoneLog then
            self:ZoneLog(("MarkBossKilledByEncounterName: NO MATCH for %q"):format(encounterName))
        end
        self:Debug("No boss matched encounter: " .. encounterName)
    end
end

function RR:ClearBossState()
    wipe(self.state.bossesKilled)
end

-------------------------------------------------------------------------------
-- Step availability
-------------------------------------------------------------------------------

function RR:RequirementsMet(requirements)
    if not requirements or #requirements == 0 then return true end
    for _, idx in ipairs(requirements) do
        if not self:IsBossKilled(idx) then return false end
    end
    return true
end

-- Returns the active routing array for the current raid: the skip route
-- when the player loaded the skip variant and one is authored, otherwise
-- the standard route. The engine reads navigation steps through this so a
-- skip run follows a different step array (different order, skipped
-- bosses) without mutating the shared raid data. Cross-raid validation
-- and the idle/Skips lists still read raid.routing (the standard route)
-- directly -- those are not variant-sensitive.
function RR:GetActiveRouting()
    local raid = self.currentRaid
    if not raid then return nil end
    -- LFR: if the player is in a wing we have routing for, that wing's route
    -- wins. Each wing covers only its own boss subset, so completion and step
    -- selection (which read through this function) scope to the wing. When in
    -- LFR but no wing entry matches, GetActiveWing returns nil and we fall
    -- through -- the panel's LFR guard then shows the unsupported message.
    local wing = self:GetActiveWing()
    if wing and wing.routing then
        return wing.routing
    end
    if self.state.activeRouteVariant == "skip" and raid.skipRoute then
        return raid.skipRoute
    end
    return raid.routing
end

-- True when every boss in the active route has been killed -- the run is
-- complete for whichever variant is loaded. Keys off actual boss kills
-- rather than comparing step count to total boss count, so a skip route
-- (fewer steps than bosses) completes correctly when its final boss dies
-- instead of never reaching "complete." Difficulty-excluded bosses (a
-- step whose boss doesn't exist at the current difficulty) don't block
-- completion, matching the same filter GetAvailableSteps applies, so the
-- run can complete after the last boss that's actually killable here.
-- Returns false if the active route has no steps (nothing authored yet),
-- so an uncaptured raid stays distinguishable from a finished one.
function RR:IsActiveRouteComplete()
    local routing = self:GetActiveRouting()
    if not routing or #routing == 0 then return false end
    local activeBucket = self:FoldDifficulty(self.currentRaid, self.state.currentDifficultyID)
    for _, step in ipairs(routing) do
        local boss = self:GetBossByIndex(step.bossIndex)
        local availableHere = (not activeBucket)
            or (not boss)
            or self:BossAvailableInBucket(boss, activeBucket)
        if availableHere
            and step.bossIndex
            and not self:IsBossKilled(step.bossIndex) then
            return false
        end
    end
    return true
end

function RR:GetAvailableSteps()
    local results = {}
    local routing = self:GetActiveRouting()
    if not routing then return results end
    -- Current difficulty as a display bucket, so a step whose boss doesn't
    -- exist at this difficulty (e.g. Heroic-only Ra-den while on Normal) is
    -- excluded from the route -- the panel then reaches run-complete after
    -- the last reachable boss instead of pointing at an unkillable one.
    -- When difficulty is unknown (not yet detected), don't filter -- better
    -- to show the step than to hide it on a transient nil.
    local activeBucket = self:FoldDifficulty(self.currentRaid, self.state.currentDifficultyID)
    for _, step in ipairs(routing) do
        local boss = self:GetBossByIndex(step.bossIndex)
        local availableHere = (not activeBucket)
            or (not boss)
            or self:BossAvailableInBucket(boss, activeBucket)
        if availableHere
            and not self:IsBossKilled(step.bossIndex)
            and self:RequirementsMet(step.requires) then
            table.insert(results, step)
        end
    end
    table.sort(results, function(a, b)
        return (a.priority or a.step or 999) < (b.priority or b.step or 999)
    end)
    return results
end

function RR:ComputeNextStep()
    -- If the active routing variant has changed since progress was last
    -- loaded (e.g. the player walked from one LFR wing into another, or
    -- switched routes, without a raid reload), the in-memory progress still
    -- reflects the previous variant -- and since variants number their steps
    -- from 1, stale values would be read against the new variant's steps.
    -- Reload from the correct namespace first. RestorePersistedProgress
    -- updates progressVariantKey, so this is a no-op once aligned.
    if self.state.progressVariantKey ~= self:ActiveVariantKey() then
        self:RestorePersistedProgress()
    end

    local prevStep = self.state.activeStep
    self.state.activeStep = nil
    if not self.currentRaid then return nil end
    local available = self:GetAvailableSteps()
    if self.state.manualTargetBossIndex then
        for _, step in ipairs(available) do
            if step.bossIndex == self.state.manualTargetBossIndex then
                self.state.activeStep = step
                self:OnActiveStepChanged(prevStep, step)
                return step
            end
        end
        self.state.manualTargetBossIndex = nil
    end
    if #available > 0 then
        self.state.activeStep = available[1]
        self:OnActiveStepChanged(prevStep, available[1])
        return available[1]
    end
    self:OnActiveStepChanged(prevStep, nil)
    return nil
end

-- Called when ComputeNextStep transitions to a different active step.
-- Resets step-scoped runtime state and seeds the RetroEngine for the
-- new step.
function RR:OnActiveStepChanged(prevStep, newStep)
    if prevStep == newStep then return end
    if self.state.backtraceLastCurrent then
        wipe(self.state.backtraceLastCurrent)
    end
    if self.ZoneLog then
        local prevLabel = prevStep and (prevStep.title or ("step " .. tostring(prevStep.step or prevStep.priority))) or "(none)"
        local newLabel = newStep and (newStep.title or ("step " .. tostring(newStep.step or newStep.priority))) or "(none)"
        self:ZoneLog(("OnActiveStepChanged: %s -> %s"):format(prevLabel, newLabel))
    end

    if newStep then
        self:SeedProgress(newStep)
    end
end

function RR:SetManualTarget(bossIndex)
    self.state.manualTargetBossIndex = bossIndex
    self:ComputeNextStep()
end

-------------------------------------------------------------------------------
-- Progress
-------------------------------------------------------------------------------

-- Returns "X/Y" -- bosses killed over total. Available for
-- tooltips or alternate UI modes.
function RR:GetProgressText()
    if not self.currentRaid then return "0/0" end
    local total, killed = #self.currentRaid.bosses, 0
    for _, boss in ipairs(self.currentRaid.bosses) do
        if self:IsBossKilled(boss.index) then killed = killed + 1 end
    end
    return ("%d/%d"):format(killed, total)
end

-- Progress scoped to the ACTIVE route rather than the whole raid. In an LFR
-- wing GetActiveRouting returns only that wing's steps, so the count reflects
-- the wing's own bosses (3/4) instead of the full raid (which GetProgressText
-- reports). On Normal/Heroic the active route is the full raid, so this
-- matches GetProgressText there. Steps are deduped by bossIndex because a
-- boss can span several routing steps (multi-segment approaches), which would
-- otherwise inflate the total. Returns killed, total as numbers.
function RR:GetActiveRouteProgress()
    local routing = self:GetActiveRouting()
    if not routing then return 0, 0 end
    local seen = {}
    local total, killed = 0, 0
    for _, step in ipairs(routing) do
        local bossIndex = step.bossIndex
        if bossIndex and not seen[bossIndex] then
            seen[bossIndex] = true
            total = total + 1
            if self:IsBossKilled(bossIndex) then killed = killed + 1 end
        end
    end
    return killed, total
end

-- Name of the boss the player is currently routed toward -- the active step's
-- boss. Mirrors the source GetActiveMinNote reads (state.activeStep), so the
-- bar's next-target name and its minNote always describe the same boss.
-- Returns nil when no step is active (run complete, or nothing loaded).
function RR:GetActiveTargetName()
    local step = self.state and self.state.activeStep
    if not step then return nil end
    local boss = self:GetBossByIndex(step.bossIndex)
    return boss and self:GetLocalizedBossName(boss) or nil
end

-- Shortest label for a boss: an explicit barLabel override if the boss carries
-- one, otherwise the shortest of its full name and any aliases. Aliases carry
-- short forms ("Sylvanas" for "Sylvanas Windrunner"), which keeps the minimized
-- bar's boss label compact.
--
-- Aliases exist first for name matching (ResolveBoss against Blizzard's
-- saved-instance strings), so some are punctuation-stripped spellings of a
-- form already present -- "NZoth" beside "N'Zoth", "Kelthuzad" beside
-- "Kel'Thuzad". Those are never valid to display, and being one byte shorter
-- they would otherwise always win, so they're skipped: an alias is ignored when
-- it carries no punctuation and another candidate with the same letters does.
--
-- barLabel covers what's left -- where the shortest legitimate candidate is
-- still the wrong label, such as a two-boss encounter whose shortest alias
-- names only one of them. Ties keep the earlier candidate (name before aliases,
-- then alias order). Returns nil for no boss.
function RR:GetBossDisplayLabel(boss)
    if not boss then return nil end
    if boss.barLabel and boss.barLabel ~= "" then return RR.L[boss.barLabel] end
    -- On a non-English client the journal name differs from the authored
    -- English name; the English aliases below can't shorten a localized
    -- name, so it renders as-is.
    local localizedName = self:GetLocalizedBossName(boss)
    if localizedName ~= boss.name then return localizedName end
    local best = boss.name
    if not boss.aliases then return best end

    -- Letters and digits only, lowercased: two candidates that reduce to the
    -- same key differ solely in punctuation and casing.
    local function letters(text)
        return (text:gsub("[^%w]", ""):lower())
    end
    local function punctuated(text)
        return text:find("[^%w ]") ~= nil
    end

    for _, alias in ipairs(boss.aliases) do
        if alias and #alias < #best then
            -- Skip a punctuation-stripped twin of the name or another alias.
            local strippedTwin = false
            if not punctuated(alias) then
                local key = letters(alias)
                if letters(boss.name) == key and punctuated(boss.name) then
                    strippedTwin = true
                else
                    for _, other in ipairs(boss.aliases) do
                        if other ~= alias and letters(other) == key
                            and punctuated(other) then
                            strippedTwin = true
                            break
                        end
                    end
                end
            end
            if not strippedTwin then best = alias end
        end
    end
    return best
end

-- Display label of the boss the player is currently routed toward. Same boss
-- as GetActiveTargetName (reads state.activeStep), but returns the shortest
-- label rather than the full name, for the space-constrained minimized bar.
function RR:GetActiveTargetLabel()
    local step = self.state and self.state.activeStep
    if not step then return nil end
    local boss = self:GetBossByIndex(step.bossIndex)
    return self:GetBossDisplayLabel(boss)
end

-- Position of the current target in the route's kill order: returns (pos, total)
-- where pos is the 1-based index of the active-step boss within GetRouteBossOrder
-- and total is the route length. This answers "which boss am I on" (boss 2 of 4)
-- rather than "how many are dead", so the position reflects route order even if
-- bosses were killed out of sequence. Returns nil when no step is active.
function RR:GetActiveTargetPosition()
    local step = self.state and self.state.activeStep
    if not step then return nil end
    local order = self:GetRouteBossOrder()
    local total = #order
    if total == 0 then return nil end
    for pos, boss in ipairs(order) do
        if boss.index == step.bossIndex then
            return pos, total
        end
    end
    return nil
end

-- Returns the raid's bosses in the order the navigation picker directs
-- the player to kill them. This is a pure simulation of the same
-- selection rule ComputeNextStep uses (GetAvailableSteps -> take the
-- first): repeatedly pick the step whose boss prerequisites (`requires`)
-- are satisfied and whose `priority or step` key is lowest, "kill" its
-- boss locally, and continue. It is the single source of truth for route
-- order, shared by the Boss Progress list so the display can never drift
-- from navigation. Mutates no engine state.
--
-- The tie-break (step, then array index) only matters when two ready
-- steps share a `priority or step` value; the live picker's sort is
-- unstable in that case, so making it deterministic here is strictly an
-- improvement, not a divergence.
function RR:GetRouteBossOrder()
    local order = {}
    local steps = self:GetActiveRouting()
    if not steps then return order end
    local placed = {}   -- bossIndex -> true once emitted (simulated kill)

    local function reqMet(step)
        if not step.requires then return true end
        for _, req in ipairs(step.requires) do
            if not placed[req] then return false end
        end
        return true
    end

    for _ = 1, #steps do
        local best, bestKey, bestStep, bestIdx
        for i, step in ipairs(steps) do
            if not placed[step.bossIndex] and reqMet(step) then
                local key = step.priority or step.step or 999
                local st  = step.step or 999
                if not best
                    or key < bestKey
                    or (key == bestKey and st < bestStep)
                    or (key == bestKey and st == bestStep and i < bestIdx) then
                    best, bestKey, bestStep, bestIdx = step, key, st, i
                end
            end
        end
        if not best then break end   -- unsatisfiable requires; stop cleanly
        local boss = self:GetBossByIndex(best.bossIndex)
        if boss then table.insert(order, boss) end
        placed[best.bossIndex] = true
    end
    return order
end

function RR:GetProgressLines()
    local lines = {}
    if not self.currentRaid then return lines end
    -- Three states, each framing an identical 12px marker slot so the
    -- boss names left-align across all rows regardless of font size:
    --   killed  -- green check texture
    --   active  -- yellow arrow texture
    --   pending -- transparent spacer (empty slot of the same width)
    -- All three are bracket + 12px element + bracket. The previous
    -- version mixed a 12px texture (killed) with space-padded text
    -- (active "[ > ]", pending "[    ]"); spaces and a fixed-px texture
    -- never share a width, and the gap drifted further as the user's
    -- font-size slider scaled the spaces but not the texture -- so the
    -- brackets never aligned. Uniform 12px textures remove the drift.
    local KILLED_GLYPH  = "|TInterface\\RaidFrame\\ReadyCheck-Ready:12:12|t"
    -- Yellow forward chevron. Vertex-color args tint the white source
    -- texture to the active-yellow used elsewhere in the panel.
    local ACTIVE_GLYPH  = "|TInterface\\ChatFrame\\ChatFrameExpandArrow:12:12:0:0:32:32:0:32:0:32:255:255:0|t"
    -- Transparent 1x1 stretched to 12px: reserves the slot width with no
    -- visible mark, so pending rows align with killed/active rows.
    local PENDING_GLYPH = "|TInterface\\Common\\Spacer:12:12|t"

    -- Two orderings. "rr" lists bosses in the order navigation directs
    -- the player to kill them (GetRouteBossOrder, which simulates the
    -- picker) so the list fills top-down as bosses fall. "ej" keeps the
    -- in-game Encounter Journal order. Default is "rr".
    local order
    if self:GetSetting("bossOrderMode", "rr") == "ej" or not self:GetActiveRouting() then
        order = self.currentRaid.bosses
    else
        order = self:GetRouteBossOrder()
    end

    -- Current difficulty as a display bucket. A boss that doesn't exist at
    -- this difficulty (e.g. Heroic-only Ra-den while on Normal) renders as a
    -- grayed, uncounted row with a "(<difficulty> only)" tag so the player
    -- knows the boss exists and why it's unreachable here -- rather than it
    -- silently vanishing. nil bucket (difficulty not yet detected) disables
    -- the restriction so nothing is hidden on a transient unknown.
    local activeBucket = self:FoldDifficulty(self.currentRaid, self.state.currentDifficultyID)
    local BUCKET_NAME  = { [14] = RR.L["Normal"], [15] = RR.L["Heroic"], [16] = RR.L["Mythic"], [17] = RR.L["LFR"] }

    for _, boss in ipairs(order) do
        local displayName = self:GetLocalizedBossName(boss)
        local restrictedHere = activeBucket
            and not self:BossAvailableInBucket(boss, activeBucket)

        if restrictedHere then
            -- Heroic-only (or otherwise difficulty-gated) boss on a
            -- difficulty where it can't be engaged. Grayed, not counted
            -- toward completion, tagged with the difficulty it requires.
            -- A boss restricted to a single bucket names that bucket; one
            -- restricted to several lists them.
            local allowed = boss.availableDifficulties or {}
            local names = {}
            for _, b in ipairs(allowed) do
                names[#names + 1] = BUCKET_NAME[b] or tostring(b)
            end
            local tag = (#names > 0) and (" |cff808080(" .. table.concat(names, "/") .. " " .. RR.L["only"] .. ")|r") or ""
            table.insert(lines, ("|cff9d9d9d[|r%s|cff9d9d9d]|r |cff808080%s|r%s"):format(
                PENDING_GLYPH, displayName, tag))
        elseif self.state.bossesKilled[boss.index] then
            -- Killed: gray brackets framing the green check (native green,
            -- unaffected by color codes). Name green.
            table.insert(lines, ("|cff9d9d9d[|r%s|cff9d9d9d]|r |cff00ff00%s|r"):format(
                KILLED_GLYPH, displayName))
        elseif self.state.activeStep
            and self.state.activeStep.bossIndex == boss.index then
            -- Active: gray brackets framing the yellow arrow. Name yellow.
            table.insert(lines, ("|cff9d9d9d[|r%s|cff9d9d9d]|r |cffffff00%s|r"):format(
                ACTIVE_GLYPH, displayName))
        else
            -- Pending: gray brackets framing the transparent spacer. Name
            -- gray.
            table.insert(lines, ("|cff9d9d9d[|r%s|cff9d9d9d]|r |cff9d9d9d%s|r"):format(
                PENDING_GLYPH, displayName))
        end
    end
    return lines
end

-------------------------------------------------------------------------------
-- Segment / map helpers
-------------------------------------------------------------------------------

function RR:GetPlayerMapPosition()
    if C_Map and C_Map.GetBestMapForUnit then
        local mapID = C_Map.GetBestMapForUnit("player")
        if mapID then
            local pos = C_Map.GetPlayerMapPosition(mapID, "player")
            if pos then return mapID, pos.x, pos.y end
        end
    end
    return nil, nil, nil
end

function RR:GetStepMaps(step)
    step = step or self.state.activeStep
    local maps = {}
    if not step then return maps end
    if step.segments then
        for _, seg in ipairs(step.segments) do
            local segMapID = seg.when and seg.when.mapID
            if segMapID then maps[segMapID] = true end
        end
    elseif step.mapID then
        maps[step.mapID] = true
    end
    return maps
end

function RR:GetFirstIncompleteSegment(step)
    if not step or not step.segments then return nil end
    local stepIndex = step.step or step.priority or 0
    local progress = self:GetProgress(stepIndex)
    return step.segments[progress] or step.segments[1]
end

function RR:ShowCurrentMapForStep()
    if not WorldMapFrame then return end
    local step = self.state.activeStep
    -- No active routing step (idle, run-complete, or out in the world):
    -- just open the world map to wherever the player currently is.
    if not step then
        if not WorldMapFrame:IsShown() then ToggleWorldMap() end
        return
    end
    local currentMapID = WorldMapFrame.GetMapID and WorldMapFrame:GetMapID()
    local stepMaps     = self:GetStepMaps(step)
    local activeSeg    = self:GetFirstIncompleteSegment(step)
    local activeSegMapID = activeSeg and activeSeg.when and activeSeg.when.mapID
    local targetMapID  =
        (currentMapID and stepMaps[currentMapID] and currentMapID)
        or activeSegMapID
        or step.mapID
    if not targetMapID then return end
    if not WorldMapFrame:IsShown() then ToggleWorldMap() end
    C_Timer.After(0, function()
        WorldMapFrame:SetMapID(targetMapID)
        if RetroRunsMapOverlay then RetroRunsMapOverlay:Refresh() end
    end)
end

-------------------------------------------------------------------------------
-- Dialog-trigger advancement
-------------------------------------------------------------------------------
-- Watches CHAT_MSG_MONSTER_YELL / _SAY / _RAID_BOSS_EMOTE for NPC
-- voicelines that signal a navigation gate (e.g. an orb-click dialog
-- that opens the next leg of the route). Matches against per-seg
-- `triggeredBy = { dialog = { npc, match } }`. Outside-encounter
-- only -- mid-encounter chat carries secret-tainted payloads. Plain
-- substring matching against the authored English, with the locale
-- table consulted for the client-language forms of both npc and match.

local dialogTriggerFrame = nil

local function DialogTriggerHandler(_, event, ...)
    -- pcall wrap so a malformed chat payload doesn't error mid-route.
    local args = { event, ... }
    local ok, err = pcall(function()
        local text   = args[2]   -- arg1 = dialog text
        local sender = args[3]   -- arg2 = speaker name

        -- Secret-tainted (mid-encounter) payloads can't be compared.
        if issecretvalue and (issecretvalue(text) or issecretvalue(sender)) then
            return
        end
        -- Require text; sender is optional. System-style emotes -- notably
        -- CHAT_MSG_RAID_BOSS_EMOTE lines like "Megaera rises from the
        -- mists!" -- arrive with no speaker (sender nil/empty). Those are
        -- exactly the events a no-npc text trigger is meant to catch, so
        -- gating on sender would drop them. TriggerMatches only consults
        -- npc when the trigger specifies one, so a nil sender is safe to
        -- pass through.
        if not text then return end

        local step = RR.state and RR.state.activeStep
        if not step or not step.segments then return end
        local stepIndex = step.step or step.priority or 0

        -- Log the raw dialog (sender + text) so a diag captures exactly what
        -- was heard, whether or not it matched a trigger -- useful for
        -- verifying faction-specific trigger strings. Text truncated to keep
        -- the log line readable.
        if RR.ZoneLog then
            local shown = tostring(text)
            if #shown > 120 then shown = shown:sub(1, 120) .. "..." end
            RR:ZoneLog(("[DialogTrigger] heard: npc=%q text=%q")
                :format(tostring(sender or ""), shown))
        end

        RR:AdvanceProgress("npc-dialog", { npc = sender, text = text })
        RR.UI.Update()
        if RetroRunsMapOverlay then RetroRunsMapOverlay:Refresh() end
    end)
    if not ok then
        RR:ZoneLog("[DialogTrigger] handler crash: " .. tostring(err))
    end
end

-- Drive the dialog path exactly as a real chat event would, including
-- the sender guard, so a simulated trigger exercises the same code a live
-- emote hits. sender defaults to nil to mirror the speakerless
-- CHAT_MSG_RAID_BOSS_EMOTE case.
function RR:SimulateDialogEvent(text, sender, event)
    DialogTriggerHandler(dialogTriggerFrame, event or "CHAT_MSG_RAID_BOSS_EMOTE", text, sender)
end

-- Initialize the dialog-trigger listener (idempotent).
function RR:InitDialogTriggers()
    if dialogTriggerFrame then return end
    dialogTriggerFrame = CreateFrame("Frame")
    dialogTriggerFrame:SetScript("OnEvent", DialogTriggerHandler)
    dialogTriggerFrame:RegisterEvent("CHAT_MSG_MONSTER_YELL")
    dialogTriggerFrame:RegisterEvent("CHAT_MSG_MONSTER_SAY")
    dialogTriggerFrame:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE")
end

function RR:IsPanelAllowed()
    return self:GetSetting("showPanel") and true or false
end
