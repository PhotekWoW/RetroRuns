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
    -- Non-English clients: resolve through the EJ walk.
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
    -- Last resort: compare against our own translations.
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
    self.state.bossesKilledViaPairOnly[boss.index] = nil
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
    wipe(self.state.bossesKilledViaPairOnly)
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

-- The routing array in force: LFR wing, then skip route, then standard.
function RR:GetActiveRouting()
    local raid = self.currentRaid
    if not raid then return nil end
    -- A wing covers only its own boss subset.
    local wing = self:GetActiveWing()
    if wing and wing.routing then
        return wing.routing
    end
    if self.state.activeRouteVariant == "skip" and raid.skipRoute then
        return raid.skipRoute
    end
    return raid.routing
end

-- True when the active route's bosses are all dead. Bosses unavailable at the
-- current difficulty don't hold it open. False when no steps are authored.
function RR:IsActiveRouteComplete()
    local routing = self:GetActiveRouting()
    if not routing or #routing == 0 then return false end
    local activeBucket = self:FoldDifficulty(self.currentRaid, self.state.currentDifficultyID)
    for _, step in ipairs(routing) do
        local boss = self:GetBossByIndex(step.bossIndex)
        local availableHere = (not activeBucket)
            or (not boss)
            or self:BossAvailableInBucket(boss, activeBucket)
        -- Optional bosses don't hold the route open.
        if availableHere
            and step.bossIndex
            and not step.optional
            and not self:IsBossKilled(step.bossIndex) then
            return false
        end
    end
    return true
end

-- True when the route is complete but an optional boss was left alive.
-- Selects the "Skip Run Complete!" banner over the plain one, so the
-- end-of-run state stays honest about what was left behind.
function RR:ActiveRouteSkippedOptionalBoss()
    local routing = self:GetActiveRouting()
    if not routing then return false end
    for _, step in ipairs(routing) do
        if step.optional and step.bossIndex
            and not self:IsBossKilled(step.bossIndex) then
            return true
        end
    end
    return false
end

function RR:GetAvailableSteps()
    local results = {}
    local routing = self:GetActiveRouting()
    if not routing then return results end
    -- A nil bucket (not yet detected) filters nothing.
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
    -- Every variant numbers its steps from 1, so stale progress reads against
    -- the wrong steps.
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
        -- Every surface reads "no active step" as run-complete.
        if self.IsActiveRouteComplete and self:IsActiveRouteComplete() then
            self.state.activeStep = nil
            self:OnActiveStepChanged(prevStep, nil)
            return nil
        end
        local chosen = available[1]
        -- An optional step yields to a later one the player's position
        -- matches. When nothing matches, it keeps the pointer.
        if chosen.optional then
            local mapID = C_Map and C_Map.GetBestMapForUnit
                and C_Map.GetBestMapForUnit("player") or nil
            local subZone = (GetSubZoneText and GetSubZoneText()) or ""
            -- Position decides the cede only while the optional boss is
            -- still ahead.
            local movedOn = self:AnyLaterStepCompleted(chosen)
            local cede = movedOn
                or (mapID and not self:StepLocationMatches(chosen, mapID, subZone))
            if cede then
                for i = 2, #available do
                    if self:StepLocationMatches(available[i], mapID, subZone) then
                        chosen = available[i]
                        break
                    end
                end
            end
        end
        self.state.activeStep = chosen
        self:OnActiveStepChanged(prevStep, chosen)
        return chosen
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

-- True when any step ordered after `step` in the active routing has its
-- boss already dead. Proof the player has moved past `step`, used by the
-- optional-step rule: an optional boss must not reclaim the pointer once
-- a later boss is down, even where their maps overlap.
function RR:AnyLaterStepCompleted(step)
    if not step then return false end
    local routing = self:GetActiveRouting()
    if not routing then return false end
    local seen = false
    for _, candidate in ipairs(routing) do
        if seen and candidate.bossIndex
            and self:IsBossKilled(candidate.bossIndex) then
            return true
        end
        if candidate == step then seen = true end
    end
    return false
end

-- True when the active routing contains any step flagged `optional`.
-- Location changes re-drive step selection only for these routes, so
-- every other raid keeps the kill-driven behavior untouched. Memoized
-- per raid and variant, which together identify a routing table.
function RR:ActiveRoutingHasOptionalStep()
    local key = tostring(self.currentRaid and self.currentRaid.instanceID)
        .. "|" .. tostring(self:ActiveVariantKey())
    if self.state.optionalStepRouteKey == key then
        return self.state.optionalStepRoutePresent == true
    end
    local present = false
    local routing = self:GetActiveRouting()
    if routing then
        for _, step in ipairs(routing) do
            if step.optional then present = true break end
        end
    end
    self.state.optionalStepRouteKey     = key
    self.state.optionalStepRoutePresent = present
    return present
end

function RR:SetManualTarget(bossIndex)
    self.state.manualTargetBossIndex = bossIndex
    self:ComputeNextStep()
end

-------------------------------------------------------------------------------
-- Progress
-------------------------------------------------------------------------------

-- Bosses killed over total, counted across our own boss list rather than
-- GetSavedInstanceInfo's numEncounters.
function RR:GetRaidProgressCounts()
    if not self.currentRaid then return 0, 0 end
    local total, killed = #self.currentRaid.bosses, 0
    for _, boss in ipairs(self.currentRaid.bosses) do
        if self:IsBossKilled(boss.index) then killed = killed + 1 end
    end
    return killed, total
end

-- Returns "X/Y" -- bosses killed over total. Available for
-- tooltips or alternate UI modes.
function RR:GetProgressText()
    local killed, total = self:GetRaidProgressCounts()
    return ("%d/%d"):format(killed, total)
end

-- Progress scoped to the active route, deduped by bossIndex.
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

-- Shortest label for a boss: barLabel if set, else the shortest of its name
-- and aliases. Punctuation-stripped aliases are skipped as display candidates.
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

-- (pos, total) for the active step within the route's kill order.
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

-- The raid's bosses in the order navigation will direct the player to kill
-- them. Re-simulates ComputeNextStep's rule; mutates no state.
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
    -- All three states are bracket + 12px element + bracket, so boss names
    -- left-align at any font size.
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

    -- A boss unavailable here renders grayed and uncounted, not hidden.
    local activeBucket = self:FoldDifficulty(self.currentRaid, self.state.currentDifficultyID)
    local BUCKET_NAME  = { [14] = RR.L["Normal"], [15] = RR.L["Heroic"], [16] = RR.L["Mythic"], [17] = RR.L["LFR"] }

    for _, boss in ipairs(order) do
        local displayName = self:GetLocalizedBossName(boss)
        local restrictedHere = activeBucket
            and not self:BossAvailableInBucket(boss, activeBucket)

        if restrictedHere then
            -- Tagged with the difficulty it needs.
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
-- Watches monster yell/say/emote against per-seg
-- `triggeredBy = { dialog = { npc, match } }`. Outside-encounter only.

local dialogTriggerFrame = nil

local function DialogTriggerHandler(_, event, ...)
    -- pcall wrap so a malformed chat payload doesn't error mid-route.
    local args = { event, ... }
    local ok, err = pcall(function()
        local text   = args[2]   -- arg1 = dialog text
        local sender = args[3]   -- arg2 = speaker name

        -- Log before any guard; every exit below names the guard that fired.
        local payloadIsSecret = issecretvalue
            and (issecretvalue(text) or issecretvalue(sender)) or false
        if RR.ZoneLog then
            if payloadIsSecret then
                RR:ZoneLog("[DialogTrigger] heard: (secret payload)")
            else
                local shown = tostring(text)
                if #shown > 120 then shown = RR.Utf8SafeTruncate(shown, 120) .. "..." end
                RR:ZoneLog(("[DialogTrigger] heard: npc=%q text=%q")
                    :format(tostring(sender or ""), shown))
            end
        end

        -- Secret-tainted payloads can't be compared.
        if payloadIsSecret then
            RR:ZoneLog("[DialogTrigger] dropped: secret payload")
            return
        end
        -- Text is required, sender is not -- boss emotes have no speaker.
        if not text then
            RR:ZoneLog("[DialogTrigger] dropped: no text")
            return
        end

        local step = RR.state and RR.state.activeStep
        if not step or not step.segments then
            RR:ZoneLog("[DialogTrigger] dropped: no active step with segments")
            return
        end
        local stepIndex = step.step or step.priority or 0
        RR:ZoneLog(("[DialogTrigger] matching against step %d (%d segs)")
            :format(stepIndex, #step.segments))

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
