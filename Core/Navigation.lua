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
    return self:GetBossByName(name) or self:GetBossByNormalizedName(name)
end

-- Locale-independent boss lookup. ENCOUNTER_END's encounterID is a
-- dungeonEncounterID; our data uses journalEncounterID. Bridge via
-- Core.lua's cached map. Returns nil if the ID doesn't resolve --
-- callers should fall back to name-based lookup.
function RR:GetBossByEncounterID(encounterID)
    if not self.currentRaid or not encounterID then return nil end
    local journalInstanceID = self.currentRaid.journalInstanceID
    if not journalInstanceID then return nil end

    local jeToDe = self:GetEJMapForJournalInstance(journalInstanceID)
    if not jeToDe then return nil end

    for _, boss in ipairs(self.currentRaid.bosses) do
        if boss.journalEncounterID and jeToDe[boss.journalEncounterID] == encounterID then
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

function RR:GetAvailableSteps()
    local results = {}
    if not self.currentRaid or not self.currentRaid.routing then return results end
    for _, step in ipairs(self.currentRaid.routing) do
        if not self:IsBossKilled(step.bossIndex)
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

function RR:GetProgressLines()
    local lines = {}
    if not self.currentRaid then return lines end
    -- Three states: killed (green check), active (yellow >), pending
    -- (gray). All non-active bosses look the same -- the player's only
    -- forward marker is the yellow active step.
    local KILLED_GLYPH = "|TInterface\\RaidFrame\\ReadyCheck-Ready:12:12|t"
    for _, boss in ipairs(self.currentRaid.bosses) do
        local marker, color
        if self.state.bossesKilled[boss.index] then
            marker, color = "[" .. KILLED_GLYPH .. "]", "ff00ff00"
        elseif self.state.activeStep
            and self.state.activeStep.bossIndex == boss.index then
            marker, color = "[>]", "ffffff00"
        else
            marker, color = "[ ]", "ff9d9d9d"
        end
        table.insert(lines, ("|c%s%s %s|r"):format(color, marker, boss.name))
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
    local step = self.state.activeStep
    if not step or not WorldMapFrame then return end
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
-- only -- mid-encounter chat carries secret-tainted payloads. English
-- substring matching, no localization.

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
        if not text or not sender then return end

        local step = RR.state and RR.state.activeStep
        if not step or not step.segments then return end
        local stepIndex = step.step or step.priority or 0

        RR:AdvanceProgress("npc-dialog", { npc = sender, text = text })
        RR.UI.Update()
        if RetroRunsMapOverlay then RetroRunsMapOverlay:Refresh() end
    end)
    if not ok then
        RR:ZoneLog("[DialogTrigger] handler crash: " .. tostring(err))
    end
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
