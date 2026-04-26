-------------------------------------------------------------------------------
-- RetroRuns -- RaidState.lua
-- Syncs kill state from WoW's saved-instance API.
-------------------------------------------------------------------------------

local RR = RetroRuns

-- requestRaidInfo = true  : also calls RequestRaidInfo() to ask the server
--                            for fresh data. Use on zone change / load only.
-- requestRaidInfo = false : reads current cached saved-instance data only.
--                            Use after ENCOUNTER_END where we already know
--                            the kill from the event and don't want a
--                            server round-trip that would cause a second
--                            UI refresh via UPDATE_INSTANCE_INFO.
--
-- Returns true if the kill state changed (caller can use this to skip
-- redundant UI refreshes), false if the new state matched what was
-- already in memory. ComputeNextStep is only called when state changed.
--
-- Implementation note: the sync builds the new kill set in a local table
-- first, then compares against state.bossesKilled. This avoids a brief
-- window where state.bossesKilled is empty during the iteration, which
-- caused panel-flicker on every zone-change event because ComputeNextStep
-- would briefly pick a different active step before the re-population
-- completed. See HANDOFF 2026-04-25 flicker investigation.
function RR:SyncFromSavedRaidInfo(requestRaidInfo)
    if self.state.testMode then
        self:ComputeNextStep()
        return false
    end

    if not self.currentRaid then
        wipe(self.state.bossesKilled)
        self:ComputeNextStep()
        return false
    end

    if requestRaidInfo then
        RequestRaidInfo()
    end

    -- Build the new kill set in a temp table.
    local newKilled = {}
    local numSaved  = GetNumSavedInstances()
    for i = 1, numSaved do
        local _, _, _, difficultyId, _, _, _, isRaid,
              _, _, numEncounters, _, _, instanceID = GetSavedInstanceInfo(i)

        if isRaid
            and instanceID   == self.currentRaid.instanceID
            and difficultyId == self.state.currentDifficultyID then
            for e = 1, numEncounters do
                local bossName, _, isKilled = GetSavedInstanceEncounterInfo(i, e)
                if bossName and isKilled then
                    local boss = self:ResolveBoss(bossName)
                    if boss then newKilled[boss.index] = true end
                end
            end
        end
    end

    -- Compare to current state. Two passes:
    --   First pass: detect ADDITIONS (new has kills that old doesn't).
    --     Additions are always legitimate -- ENCOUNTER_END, server push
    --     of new lockout data, etc. Accept these.
    --   Second pass: detect REMOVALS (old has kills that new doesn't).
    --     Removals MID-SESSION are almost always saved-instance cache
    --     hiccups (Blizzard's cache is not consistent across consecutive
    --     reads -- transient drops have been observed where boss N
    --     disappears from the cache for one read, then reappears on the
    --     next). Reject these. Real lockout resets happen on raid load
    --     when state is wiped first, so we never need to honor a
    --     mid-session removal. See HANDOFF 2026-04-25 flicker
    --     investigation for the diagnostic capture that proved this.
    local hasAddition = false
    for k in pairs(newKilled) do
        if not self.state.bossesKilled[k] then
            hasAddition = true
            break
        end
    end

    local hasRemoval = false
    for k in pairs(self.state.bossesKilled) do
        if not newKilled[k] then
            hasRemoval = true
            break
        end
    end

    -- If only removals were detected (no additions), reject the entire
    -- update. The cache is mid-hiccup; the next sync will restore
    -- correct state.
    if hasRemoval and not hasAddition then
        if self.ZoneLog then
            local function setSummary(t)
                local count = 0
                local list  = {}
                for k in pairs(t) do
                    count = count + 1
                    table.insert(list, tostring(k))
                end
                table.sort(list)
                return ("%d:[%s]"):format(count, table.concat(list, ","))
            end
            self:ZoneLog(("SyncFromSavedRaidInfo REJECTED removal-only update: old=%s new=%s")
                :format(setSummary(self.state.bossesKilled), setSummary(newKilled)))
        end
        return false
    end

    if not hasAddition and not hasRemoval then return false end

    -- Diagnostic: log the before/after kill sets when a change is
    -- accepted. Useful for understanding state transitions during
    -- normal play (kills, lockout loads).
    if self.ZoneLog then
        local function setSummary(t)
            local count = 0
            local list  = {}
            for k in pairs(t) do
                count = count + 1
                table.insert(list, tostring(k))
            end
            table.sort(list)
            return ("%d:[%s]"):format(count, table.concat(list, ","))
        end
        self:ZoneLog(("SyncFromSavedRaidInfo CHANGE: old=%s new=%s")
            :format(setSummary(self.state.bossesKilled), setSummary(newKilled)))
    end

    -- For additions: merge new entries into existing state instead of
    -- replacing it. This preserves any kill flags that were set via
    -- ENCOUNTER_END but haven't yet shown up in the cache. (Without
    -- this, an addition-only update would still wipe and re-populate,
    -- which could drop ENCOUNTER_END marks that beat the cache by a
    -- few hundred ms.)
    for k in pairs(newKilled) do
        self.state.bossesKilled[k] = true
    end
    -- Clear manualTargetBossIndex if the manually-targeted boss is now
    -- killed (matches the behaviour of MarkBossKilled which does this
    -- check when called from ENCOUNTER_END's MarkBossKilledByEncounterName).
    if self.state.manualTargetBossIndex
        and self.state.bossesKilled[self.state.manualTargetBossIndex] then
        self.state.manualTargetBossIndex = nil
    end

    self:ComputeNextStep()
    return true
end
