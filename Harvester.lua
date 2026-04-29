-------------------------------------------------------------------------------
-- RetroRuns -- Harvester.lua
-- Development-only tool. Harvests loot + per-difficulty transmog sourceIDs
-- from the Encounter Journal.
--
-- HOW PER-DIFFICULTY SOURCES ARE RESOLVED:
-- Each EJ loot entry's `link` carries an `itemContext` value
-- (Enum.ItemCreationContext) that tells us which difficulty Blizzard generated
-- the link at: RaidFinder/RaidNormal/RaidHeroic/RaidMythic. We parse that out
-- of the link options and use it to assign the difficulty bucket. The legacy
-- `itemModID` field is unreliable (e.g. all four difficulty variants of every
-- Sepulcher item have modID=0); itemContext is the source of truth and only
-- falls back to modID when context returns 0/UNKNOWN.
--
-- We also enumerate the appearance's other source variants via
-- GetAllAppearanceSources(appearanceID) and parse each variant's link in the
-- same way -- so a single regular-loot pass at one EJ difficulty captures all
-- four difficulty source IDs for an item.
--
-- (Reference: TokenTransmogTooltips' DungeonJournalExtractor uses this same
-- itemContext-from-link approach. The *Extended* enum variants in our diff
-- map mirror its handling -- those exist for older raids where Blizzard tags
-- variants with non-canonical context values.)
--
-- TIER PIECES:
-- Tier tokens themselves carry no transmog appearance (they're consumables).
-- We don't enumerate them via the EJ class filter anymore; instead we use
-- C_TransmogSets.GetAllSets() to find sets whose label matches a value
-- declared in the raid's `tierSets` config, then C_TransmogSets.GetSourcesForSlot
-- gives us per-class per-slot per-difficulty sourceIDs directly. This skips
-- the token-resolution problem entirely (tokens have equipLoc="" and are
-- filtered as junk; we never see them).
--
-- The raid data file declares which sets to pull and which boss each drops
-- on (since C_TransmogSets doesn't carry boss-source info). If a raid has no
-- `tierSets` block, the tier-harvest step is skipped silently.
--
-- Usage:
--   /rr harvest              -- harvest the current raid
--   /rr harvest dump         -- open the copyable output window
--   /rr ej                   -- diagnostic: scan EJ encounter IDs
--   /rr tiersets             -- diagnostic: dump C_TransmogSets entries to
--                               find labels for the current raid (use this
--                               output to populate `tierSets` in raid data)
--
-- This file is NOT needed by end users and can be omitted from public releases.
-------------------------------------------------------------------------------

local RR = RetroRuns

-- Slots with no transmog value -- skip entirely.
local EXCLUDED_SLOTS = {
    INVTYPE_NECK             = true,
    INVTYPE_FINGER           = true,
    INVTYPE_TRINKET          = true,
    INVTYPE_BAG              = true,
    INVTYPE_QUIVER           = true,
    INVTYPE_NON_EQUIP_IGNORE = true,
    [""]                     = true,
}

local SLOT_LABEL = {
    INVTYPE_HEAD           = "Head",
    INVTYPE_SHOULDER       = "Shoulder",
    INVTYPE_CHEST          = "Chest",
    INVTYPE_WAIST          = "Waist",
    INVTYPE_LEGS           = "Legs",
    INVTYPE_FEET           = "Feet",
    INVTYPE_WRIST          = "Wrist",
    INVTYPE_HAND           = "Hands",
    INVTYPE_BACK           = "Back",
    INVTYPE_WEAPON         = "Weapon",
    INVTYPE_SHIELD         = "Off-hand",
    INVTYPE_RANGED         = "Ranged",
    INVTYPE_ROBE           = "Chest",
    INVTYPE_2HWEAPON       = "Two-Hand",
    INVTYPE_WEAPONMAINHAND = "Main Hand",
    INVTYPE_WEAPONOFFHAND  = "Off Hand",
    INVTYPE_HOLDABLE       = "Held In Off-hand",
    INVTYPE_THROWN         = "Ranged",
    INVTYPE_RANGEDRIGHT    = "Ranged",
    INVTYPE_CLOAK          = "Back",
    INVTYPE_TABARD         = "Tabard",
    INVTYPE_BODY           = "Shirt",
}

-- WoW's item modID (appearance variant suffix) -> in-game difficulty ID.
-- LEGACY: this mapping is unreliable for some raids -- e.g. all four difficulty
-- variants of every Sepulcher item have modID=0. We use ITEM_CONTEXT_TO_DIFFICULTY
-- as the primary signal and only fall back to this when itemContext is 0/UNKNOWN.
local MODID_TO_DIFFICULTY = {
    [3] = 14,   -- Normal
    [4] = 17,   -- LFR
    [5] = 15,   -- Heroic
    [6] = 16,   -- Mythic
}

-- Enum.ItemCreationContext -> in-game difficulty ID.
-- This is the reliable per-difficulty signal: every EJ-generated item link
-- carries an itemContext value as the 12th option in its hyperlink, and that
-- value cleanly identifies which difficulty Blizzard generated the link at.
-- The *Extended* enum variants exist for older raids where Blizzard tags
-- variants with non-canonical context values; mapping them all back to the
-- canonical four difficulties keeps the harvester resilient across content.
local ITEM_CONTEXT_TO_DIFFICULTY = {
    [Enum.ItemCreationContext.RaidFinder]            = 17,
    [Enum.ItemCreationContext.RaidFinderExtended]    = 17,
    [Enum.ItemCreationContext.RaidFinderExtended_2]  = 17,
    [Enum.ItemCreationContext.RaidFinderExtended_3]  = 17,
    [Enum.ItemCreationContext.RaidNormal]            = 14,
    [Enum.ItemCreationContext.RaidNormalExtended]    = 14,
    [Enum.ItemCreationContext.RaidNormalExtended_2]  = 14,
    [Enum.ItemCreationContext.RaidNormalExtended_3]  = 14,
    [Enum.ItemCreationContext.RaidHeroic]            = 15,
    [Enum.ItemCreationContext.RaidHeroicExtended]    = 15,
    [Enum.ItemCreationContext.RaidHeroicExtended_2]  = 15,
    [Enum.ItemCreationContext.RaidHeroicExtended_3]  = 15,
    [Enum.ItemCreationContext.RaidMythic]            = 16,
    [Enum.ItemCreationContext.RaidMythicExtended]    = 16,
    [Enum.ItemCreationContext.RaidMythicExtended_2]  = 16,
    [Enum.ItemCreationContext.RaidMythicExtended_3]  = 16,
}

-- Expose on the RR namespace so /rr tmogverify (in Core.lua) can use the
-- same mapping without duplicating it. Keeping a single source of truth
-- ensures the verifier's bucket-assignment check stays in lockstep with
-- the harvester's actual integration logic.
RR.ITEM_CONTEXT_TO_DIFFICULTY = ITEM_CONTEXT_TO_DIFFICULTY

local DIFF_ORDER = { 17, 14, 15, 16 }   -- LFR, Normal, Heroic, Mythic (display order)

-- Map a player class ID (1-13) to its uppercase classFile name. Used when
-- emitting tier-set items: C_TransmogSets returns sets keyed by classMask, and
-- we convert that to the integer classID our data schema stores in `classes`.
local CLASSFILE_TO_CLASSID = {
    WARRIOR     = 1,  PALADIN     = 2,  HUNTER      = 3,  ROGUE       = 4,
    PRIEST      = 5,  DEATHKNIGHT = 6,  SHAMAN      = 7,  MAGE        = 8,
    WARLOCK     = 9,  MONK        = 10, DRUID       = 11, DEMONHUNTER = 12,
    EVOKER      = 13,
}

-- Inventory-slot ID -> our `slot` string used in the data file. Restricted to
-- the five tier slots; tier sets only ever carry these.
local TIER_INVSLOTS = {
    { id = INVSLOT_HEAD,     slot = "Head"     },
    { id = INVSLOT_SHOULDER, slot = "Shoulder" },
    { id = INVSLOT_CHEST,    slot = "Chest"    },
    { id = INVSLOT_HAND,     slot = "Hands"    },
    { id = INVSLOT_LEGS,     slot = "Legs"     },
}

-- Tier-group prefix -> set of class IDs that wear that group's tier.
-- These mappings are stable per-expansion; new expansions add new groups.
-- Borrowed from TokenTransmogTooltips' shadowlandsMultiClassLookup.
-- Token names always START with the group prefix ("Mystic Helm Module",
-- "Conqueror's Coif of Triumph"), so we use these for both directions:
--   - parse a token name -> figure out its group
--   - given a row's classID -> figure out which group's token redeems it
local TIER_GROUPS = {
    -- Shadowlands 9.2 Sepulcher (armor tier sets)
    MYSTIC      = { 11, 3, 8 },          -- Druid, Hunter, Mage
    VENERATED   = { 2, 5, 7 },           -- Paladin, Priest, Shaman
    ZENITH      = { 4, 1, 10, 13 },      -- Rogue, Warrior, Monk, Evoker
    DREADFUL    = { 6, 12, 9 },          -- Death Knight, Demon Hunter, Warlock
    -- Shadowlands 9.0 Castle Nathria (weapon tokens, NOT armor tier sets).
    -- MYSTIC/VENERATED/ZENITH reused from Sepulcher with the same class
    -- membership (ZENITH added Evoker retroactively when DF shipped).
    -- Three families are new to CN:
    --   ABOMINABLE: same class set as Sepulcher's DREADFUL but different
    --               name. Two tokens coexist in TIER_GROUPS with identical
    --               class lists; BuildClassToGroupMap's `activeGroupPrefixes`
    --               filter keeps the Sepulcher and CN resolutions separate.
    --   APOGEE / THAUMATURGIC: both are OFF-HAND token families. Several
    --               classes (Monk, Warrior, Paladin, Priest, Evoker, Druid,
    --               Mage, Shaman, Warlock) belong to BOTH an MH and an OH
    --               family in CN. This means `BuildClassToGroupMap`'s
    --               classID-keyed inverse map is insufficient for CN tier-
    --               set rendering (last-write-wins silently). That's a known
    --               limitation; the `/rr tiersets` token-discovery path
    --               doesn't hit it (it parses token names, not class IDs),
    --               but the per-class-tier-row rendering path will need a
    --               (classID, slot) re-keying before CN tier rows render
    --               correctly. See HANDOFF.md session summary for the full
    --               story.
    ABOMINABLE   = { 6, 12, 9 },          -- DK, DH, Warlock (= CN's Dreadful-equivalent)
    APOGEE       = { 1, 2, 5, 10, 13 },   -- Warrior, Paladin, Priest, Monk, Evoker
    THAUMATURGIC = { 7, 8, 9, 11 },       -- Shaman, Mage, Warlock, Druid
    -- Older tiers (Wrath/Cata/MoP-style) -- add as needed.
    CONQUEROR   = { 2, 5, 9 },           -- Paladin, Priest, Warlock
    PROTECTOR   = { 1, 3, 7 },           -- Warrior, Hunter, Shaman
    VANQUISHER  = { 6, 4, 8, 11 },       -- DK, Rogue, Mage, Druid
}

-- classID -> group prefix (inverted from TIER_GROUPS, expansion-by-expansion).
-- Built lazily because a class belongs to one group per expansion -- when
-- multiple expansions are loaded into TIER_GROUPS we need to know which
-- expansion's mapping to use. We derive this at diagnostic/harvest time
-- by intersecting TIER_GROUPS with the labels actually present in the raid's
-- tier sets, so a Sepulcher harvest only resolves to MYSTIC/VENERATED/ZENITH/
-- DREADFUL, never to CONQUEROR/PROTECTOR/VANQUISHER (which would be wrong).
local function BuildClassToGroupMap(activeGroupPrefixes)
    local map = {}
    for _, prefix in ipairs(activeGroupPrefixes) do
        local classes = TIER_GROUPS[prefix]
        if classes then
            for _, cid in ipairs(classes) do
                map[cid] = prefix
            end
        end
    end
    return map
end

-- Body-keyword vocabulary for resolving a tier token's slot from its
-- tooltip text. Each season Blizzard invents a new naming convention
-- for the token names themselves (Sepulcher used "{Family} {Slot}
-- Module" with the body word, then Vault encoded slot as a gem name,
-- Aberrus shifted to verb-form "Fluid" words, Amirdrassil to
-- adjective-form "Dreamheart" names, and so on). Rather than chase
-- the marketing-copy treadmill, we read the token's actual tooltip
-- via C_TooltipInfo.GetItemByID -- whose body text describes which
-- slot the token converts into using stable English words ("Head",
-- "Shoulders", "Chest", "Hands", "Legs"). The keyword table below
-- only needs the universal body words; it doesn't need extension
-- when a new season ships a new token-name convention.
--
-- Order matters: more specific keywords (helm) come before less
-- specific (head). The first match in the lowercased tooltip text
-- wins. Aligned with TransmogTokenTooltips' ParseSlotFromTooltip
-- vocabulary (canonical reference for token-slot resolution).
local TOKEN_SLOT_KEYWORDS = {
    { keywords = { "helm", "head", "crown", "cowl", "faceguard" }, slot = "Head"     },
    { keywords = { "shoulder", "mantle", "pauldron", "spaulder" }, slot = "Shoulder" },
    { keywords = { "chest", "robe", "tunic", "breastplate",
                                              "hauberk", "vest" }, slot = "Chest"    },
    { keywords = { "hand", "glove", "gauntlet", "grip"          }, slot = "Hands"    },
    { keywords = { "leg", "pant", "breech", "kilt"              }, slot = "Legs"     },
}

-------------------------------------------------------------------------------
-- Drakewatcher Manuscript detection (Dragonflight onward).
--
-- Manuscripts are non-equippable items (equipLoc=INVTYPE_NON_EQUIP_IGNORE)
-- that teach a Dragonriding mount customization by completing a hidden
-- quest when used. Blizzard does not expose them via any C_*Journal API
-- (mount/pet/toy/decor all return nil), so DetectSpecialKind needs a
-- different signal.
--
-- The reliable detection signal: GetItemSpell(itemID).name == "Deciphering".
-- Every Drakewatcher Manuscript shipped to date uses a use-spell named
-- "Deciphering" (the spellID differs per item, but the name is constant).
--
-- The questID is NOT exposed by any clean WoW API -- it's encoded in the
-- spell's server-side effect bytecode. We resolve it via a small static
-- map, keyed by spellID. When we hit a spellID not yet in the map (e.g.
-- a brand-new raid's manuscript), the harvester emits the entry with
-- questID=nil + a TODO comment so the user knows to look it up from
-- ATT/wowdb and add the spellID->questID mapping here.
--
-- IMPORTANT LIMITATION: this detection only catches manuscripts that
-- Blizzard listed in the Encounter Journal. Some manuscripts are hidden
-- from EJ entirely (verified 2026-04-27 via /rr ejprobe 201790 on
-- Raszageth: itemID 201790 doesn't appear in GetLootInfoByIndex despite
-- being a real drop). For hidden manuscripts, hand-curate the
-- specialLoot entry from ATT's mm() data -- DetectManuscript can't help
-- since the item never reaches DetectSpecialKind in the first place.
--
-- To extend the questID map for a new EJ-listed manuscript:
--   1. Run /rr ejprobe <itemID> on the raid's final boss with EJ open.
--   2. Note the GetItemSpell line: name=Deciphering spellID=NNNNN.
--   3. Look up the questID from ATT's mm() entry or wowdb item page.
--   4. Add a line below: [<spellID>] = <questID>,
-------------------------------------------------------------------------------
local MANUSCRIPT_SPELL_NAME = "Deciphering"
local MANUSCRIPT_QUESTID_BY_SPELLID = {
    [394780] = 72367,   -- Vault: Renewed Proto-Drake: Embodiment of the Storm-Eater (Raszageth) [hidden from EJ -- entry kept for completeness]
    [410775] = 75967,   -- Aberrus: Highland Drake: Embodiment of the Hellforged (Sarkareth)
}

-- Returns (true, questID) if the item is a manuscript, where questID may be
-- nil if we recognize the item as a manuscript but don't yet have its
-- questID in the static map. Returns (false, nil) for non-manuscript items.
local function DetectManuscript(itemID)
    if not itemID or not GetItemSpell then return false, nil end
    local spellName, spellID = GetItemSpell(itemID)
    if spellName == MANUSCRIPT_SPELL_NAME then
        return true, MANUSCRIPT_QUESTID_BY_SPELLID[spellID]
    end
    return false, nil
end

-- Resolve a tier token's (group, slot) tuple.
--
-- `group` (DREADFUL/MYSTIC/VENERATED/ZENITH and historical variants) is
-- always the first whole word of the token's name -- that convention has
-- been stable since the modern tier system (9.2 Sepulcher onward).
--
-- `slot` is more interesting. Historically we read it from the token's
-- name too, which forced the keyword table to grow each season as
-- Blizzard invented new naming conventions (gem encoding for Vault,
-- "Fluid" verbs for Aberrus, "Dreamheart" adjectives for Amirdrassil...).
-- Now we read it from the token's TOOLTIP via C_TooltipInfo.GetItemByID,
-- whose body text describes the conversion target with stable English
-- words ("Head", "Shoulders", etc.) regardless of marketing-name
-- conventions. Approach mirrors TransmogTokenTooltips' ParseSlotFromTooltip.
--
-- Falls back to name-based matching against the same keyword table when
-- the tooltip lookup is unavailable (rare; Blizzard caches tooltips
-- aggressively, but a freshly-uncached call from a cold harvest can
-- briefly return nil). The fallback won't catch seasonal-adjective
-- tokens, but on first invocation those resolve via tooltip; the
-- fallback exists to handle race conditions, not as a real plan-B.
--
-- Returns (group, slot). Either or both may be nil if resolution fails.
local function ParseTokenName(itemID, name)
    if not name then return nil, nil end
    local lower = name:lower()

    -- Group prefix: first whole word that matches a known group. Class-
    -- family words live in the token name itself across every tier
    -- season, so this stays name-driven.
    local group
    for prefix in pairs(TIER_GROUPS) do
        if lower:find("^" .. prefix:lower() .. "[%s'%-]") then
            group = prefix
            break
        end
    end

    -- Slot: scan the token's tooltip body for slot keywords first.
    local slot
    if itemID and C_TooltipInfo and C_TooltipInfo.GetItemByID then
        local td = C_TooltipInfo.GetItemByID(itemID)
        if td and td.lines then
            local buf = {}
            for _, line in ipairs(td.lines) do
                if line.leftText then buf[#buf+1] = line.leftText:lower() end
                if line.rightText then buf[#buf+1] = line.rightText:lower() end
            end
            local tooltipText = table.concat(buf, " ")
            for _, def in ipairs(TOKEN_SLOT_KEYWORDS) do
                for _, kw in ipairs(def.keywords) do
                    if tooltipText:find(kw, 1, true) then
                        slot = def.slot
                        break
                    end
                end
                if slot then break end
            end
        end
    end

    -- Fallback: scan the name itself. Only catches tokens whose names
    -- happen to contain a body word (Sepulcher-era "{Family} {Slot}
    -- Module" matches; DF-and-onward marketing-name conventions don't).
    if not slot then
        for _, def in ipairs(TOKEN_SLOT_KEYWORDS) do
            for _, kw in ipairs(def.keywords) do
                if lower:find(kw, 1, true) then
                    slot = def.slot
                    break
                end
            end
            if slot then break end
        end
    end

    return group, slot
end

-------------------------------------------------------------------------------
-- Transmog source diagnostic
-- Dumps, for each item on the current boss, the primary sourceID plus every
-- variant returned by GetAllAppearanceSources. Useful when a new raid's
-- appearance-resolution looks wrong in the UI.
-------------------------------------------------------------------------------

function RR:DebugTransmogSources()
    local step = self.state.activeStep or self:ComputeNextStep()
    local boss = step and self:GetBossByIndex(step.bossIndex)
    if not boss or not boss.loot then
        self:Print("No boss loot data.")
        return
    end

    local lines = {}
    table.insert(lines, ("Boss: %s  |  Active difficulty: %s (ID=%s)"):format(
        boss.name,
        tostring(self.state.currentDifficultyName),
        tostring(self.state.currentDifficultyID)))
    table.insert(lines, "")

    for _, item in ipairs(boss.loot) do
        local appearanceID, primarySource
        if C_TransmogCollection then
            appearanceID, primarySource = C_TransmogCollection.GetItemInfo(item.id)
        end
        table.insert(lines, ("[%s] itemID=%d appearance=%s primary=%s"):format(
            item.name, item.id,
            tostring(appearanceID), tostring(primarySource)))

        -- Dump GetAppearanceInfoBySource result -- this is the call the
        -- Blizzard tooltip uses to decide "you have this appearance from
        -- somewhere." We want to confirm the field name for isCollected.
        if primarySource and C_TransmogCollection.GetAppearanceInfoBySource then
            local apInfo = C_TransmogCollection.GetAppearanceInfoBySource(primarySource)
            if apInfo then
                local parts = {}
                for k, v in pairs(apInfo) do
                    table.insert(parts, ("%s=%s"):format(k, tostring(v)))
                end
                table.sort(parts)
                table.insert(lines, "  AppearanceInfoBySource: { " .. table.concat(parts, ", ") .. " }")
            else
                table.insert(lines, "  AppearanceInfoBySource: nil")
            end
        end

        if appearanceID then
            local allSources = C_TransmogCollection.GetAllAppearanceSources(appearanceID)
            local hasAny = allSources and next(allSources) ~= nil
            if hasAny then
                -- Use pairs not ipairs -- the returned table isn't always a
                -- contiguous array.
                for _, src in pairs(allSources) do
                    local info  = C_TransmogCollection.GetSourceInfo(src)
                    local known = C_TransmogCollection.PlayerHasTransmogItemModifiedAppearance(src)
                    if info then
                        local link = info.itemLink or "?"
                        local compact = link:match("item:[^|%]]+") or link
                        table.insert(lines, ("  src=%d cat=%s type=%s modID=%s itemID=%s known=%s"):format(
                            src,
                            tostring(info.categoryID),
                            tostring(info.sourceType),
                            tostring(info.itemModID),
                            tostring(info.itemID),
                            tostring(known)))
                        table.insert(lines, ("    link=%s"):format(compact))
                    else
                        table.insert(lines, ("  src=%d (no GetSourceInfo) known=%s"):format(
                            src, tostring(known)))
                    end
                end
            else
                table.insert(lines, "  (GetAllAppearanceSources returned nil/empty)")
            end
        end
        table.insert(lines, "")
    end

    self:SetSetting("lastHarvestAll", table.concat(lines, "\n"))
    self:Print("Source dump ready -- use /rr harvest dump to view.")
end

-------------------------------------------------------------------------------
-- EJ encounter diagnostic
-------------------------------------------------------------------------------

function RR:HarvestDiagnose()
    local out = {}
    local function add(line) table.insert(out, line) end

    add("-- /rr ej for: " .. (RR.currentRaid and RR.currentRaid.name or "(no raid loaded)"))
    add("")

    -- === Live GetInstanceInfo() ===
    -- When the player is zoned into a raid, this gives us the authoritative
    -- instanceID (position 8 in the 10-value return). This is the ID used
    -- as the top-level key in Data/*.lua files. When NOT in an instance,
    -- instanceType is "none" and we say so explicitly.
    add("=== Live GetInstanceInfo() ===")
    local ok, iname, itype, _, _, _, _, _, iid =
        pcall(function() return GetInstanceInfo() end)
    if ok and itype and itype ~= "none" then
        add(("  name=%s  type=%s  instanceID=%s"):format(
            tostring(iname), tostring(itype), tostring(iid)))
        add("  (Use instanceID as the Data/*.lua top-level key.)")
    else
        add("  (not zoned into an instance -- instanceID unavailable from")
        add("   GetInstanceInfo(). Zone into the raid to capture it.)")
    end
    add("")

    -- === EJ_GetInstanceInfo for currently-selected journal instance ===
    -- If the player has the Encounter Journal open (or recently selected
    -- a raid in it), this returns the raid's uiMapID at position 10 --
    -- useful for Data/*.lua `maps` table seeding. Works even when NOT
    -- zoned into the raid, which is handy for stubbing out data files
    -- before doing a first run.
    --
    -- Source-of-truth: try EJ_GetSelectedInstance first, then fall back
    -- to EJ_GetEncounterInfoByIndex(1)'s jinstID. Per Aberrus stub
    -- session 2026-04-26, EJ_GetSelectedInstance can return nil even
    -- when the EJ is visibly open on a raid -- the index-based API
    -- reads the same underlying state more reliably.
    add("=== EJ_GetInstanceInfo() for selected journal instance ===")
    local selectedEJ = EJ_GetSelectedInstance and EJ_GetSelectedInstance() or nil
    local source = "EJ_GetSelectedInstance"
    if not selectedEJ then
        local _, _, _, _, _, fallbackJinst = EJ_GetEncounterInfoByIndex(1)
        if fallbackJinst then
            selectedEJ = fallbackJinst
            source = "EJ_GetEncounterInfoByIndex(1).jinstID"
        end
    end
    if selectedEJ then
        local ejName, _, _, _, _, _, _, _, _, ejMapID, _, isRaid =
            EJ_GetInstanceInfo(selectedEJ)
        add(("  journalInstanceID=%d  name=%s  uiMapID=%s  isRaid=%s"):format(
            selectedEJ, tostring(ejName), tostring(ejMapID), tostring(isRaid)))
        add(("  (source: %s)"):format(source))
    else
        add("  (no journal instance selected -- open the Encounter Journal")
        add("   to the raid first so EJ_GetSelectedInstance() returns a value.)")
    end
    add("")

    add("=== Stored journalEncounterIDs for current raid ===")

    if RR.currentRaid then
        for _, boss in ipairs(RR.currentRaid.bosses) do
            if boss.journalEncounterID then
                local name, _, _, _, _, jinstID =
                    EJ_GetEncounterInfo(boss.journalEncounterID)
                add(("  [%d] stored=%d -> name=%s  instID=%s"):format(
                    boss.index, boss.journalEncounterID,
                    tostring(name), tostring(jinstID)))
            else
                add(("  [%d] %s -- (no stored journalEncounterID)"):format(
                    boss.index, tostring(boss.name)))
            end
        end
    else
        add("  (no raid loaded)")
    end

    add("")
    add("=== Live EJ encounters (first 20 by index) ===")
    local found = 0
    for i = 1, 20 do
        local name, _, jeid, _, _, jinstID = EJ_GetEncounterInfoByIndex(i)
        if name then
            add(("  index=%d  name=%s  jeid=%s  jinstID=%s"):format(
                i, tostring(name), tostring(jeid), tostring(jinstID)))
            found = found + 1
        end
    end
    if found == 0 then
        add("  (EJ_GetEncounterInfoByIndex returned nothing -- is the")
        add("   Encounter Journal selected to a raid? Open the EJ to")
        add("   the raid, or zone into it, then retry.)")
    end

    local body = table.concat(out, "\n")
    self:SetSetting("lastEjDump", body)

    self:ShowCopyWindow(
        "|cffF259C7RETRO|r|cff4DCCFFRUNS|r  |cffaaaaaa/rr ej|r",
        body)
    self:Print(("ej diagnostic complete: %d live encounter(s). Window opened."):format(found))
end

-------------------------------------------------------------------------------
-- EjProbe: dump everything EJ knows about the currently-selected encounter's
-- loot. Designed for "why doesn't /rr harvest see this item?" investigations.
--
-- The harvester's loot scrape uses one specific path:
--   numLoot = EJ_GetNumLoot()
--   for i = 1, numLoot do
--       info = C_EncounterJournal.GetLootInfoByIndex(i)
--       if info.encounterID == targetEncounterID then ... end
--
-- If a known item is missing from the harvest, there are three possible
-- causes:
--   A. Returned by GetLootInfoByIndex but its equipLoc puts it in the
--      EXCLUDED_SLOTS bucket AND DetectSpecialKind returns nil for it
--      (case for Drakewatcher Manuscripts: no C_Manuscripts API exists).
--   B. Returned by GetLootInfoByIndex but its info.encounterID doesn't
--      match the target boss (some Blizzard-side attribution quirk).
--   C. Not returned by GetLootInfoByIndex at all -- the API surfaces this
--      class of item through a different EJ call we're not using.
--
-- This probe distinguishes all three cases:
--   1. Reports live EJ state (selected instance/encounter, numLoot).
--   2. Iterates GetLootInfoByIndex and dumps every entry with its
--      encounterID, equipLoc, and DetectSpecialKind result.
--   3. If a needle itemID is provided, highlights its presence/absence
--      and dumps deeper info about it.
--
-- Usage:
--   /rr ejprobe                  (dump all loot for selected EJ encounter)
--   /rr ejprobe <needleItemID>   (also highlight needle and probe APIs)
--
-- Setup: open Encounter Journal, select the raid + encounter you want
-- to probe, then run the command. The selected encounter is what
-- EJ_GetSelectedEncounter() reports.
-------------------------------------------------------------------------------
function RR:EjProbe(needleItemID)
    local out = {}
    local function add(s) table.insert(out, s) end

    needleItemID = tonumber(needleItemID)

    local instID  = EJ_GetSelectedInstance and EJ_GetSelectedInstance() or nil
    local encID   = EJ_GetSelectedEncounter and EJ_GetSelectedEncounter() or nil
    local diffID  = EJ_GetDifficulty and EJ_GetDifficulty() or nil
    local numLoot = EJ_GetNumLoot and EJ_GetNumLoot() or 0

    add(("ejprobe: selected instance=%s  encounter=%s  difficulty=%s  numLoot=%d"):format(
        tostring(instID), tostring(encID), tostring(diffID), numLoot))
    if needleItemID then
        add(("needle itemID=%d"):format(needleItemID))
    end
    add("")

    if not encID then
        add("(no encounter selected -- open Encounter Journal and select a boss first)")
    end

    -- Iterate every loot entry. We DON'T filter by encounterID here -- the
    -- whole point is to surface entries that may have wrong/unexpected
    -- encounterIDs. The "matches encID" column tells us whether the
    -- harvester would have considered this item.
    local foundNeedle      = false
    local entriesForEnc    = 0
    local entriesTotal     = 0
    local missingEquipLoc  = 0

    add("--- All loot entries (1..numLoot), columns: idx | itemID | encID | match | equipLoc | special | name")
    for i = 1, numLoot do
        local info = C_EncounterJournal and C_EncounterJournal.GetLootInfoByIndex
                     and C_EncounterJournal.GetLootInfoByIndex(i) or nil
        if info then
            entriesTotal = entriesTotal + 1
            local matches = (encID and info.encounterID == encID) and "Y" or "n"
            if matches == "Y" then entriesForEnc = entriesForEnc + 1 end

            local _, _, _, _, _, _, _, _, equipLoc = GetItemInfo(info.itemID or 0)
            local equipLocStr = equipLoc or "(nil)"
            if equipLoc == nil then missingEquipLoc = missingEquipLoc + 1 end

            -- DetectSpecialKind is a local in this file; we can't call it
            -- directly from here, but we can replicate its 4 probes inline.
            local specialKind = "-"
            if equipLocStr == "" or equipLocStr == "INVTYPE_NON_EQUIP_IGNORE" then
                local petS = C_PetJournal and C_PetJournal.GetPetInfoByItemID
                             and select(13, C_PetJournal.GetPetInfoByItemID(info.itemID))
                if C_MountJournal and C_MountJournal.GetMountFromItem
                   and C_MountJournal.GetMountFromItem(info.itemID) then
                    specialKind = "mount"
                elseif petS then
                    specialKind = "pet"
                elseif C_ToyBox and C_ToyBox.GetToyInfo
                   and C_ToyBox.GetToyInfo(info.itemID) then
                    specialKind = "toy"
                elseif PlayerHasToy and PlayerHasToy(info.itemID) then
                    specialKind = "toy"
                elseif C_HousingCatalog and C_HousingCatalog.GetCatalogEntryInfoByItem then
                    local ok, entry = pcall(C_HousingCatalog.GetCatalogEntryInfoByItem, info.itemID)
                    if ok and entry then specialKind = "decor" end
                end
                if specialKind == "-" then specialKind = "NONE" end
            end

            local nameStr = info.name or "(no name)"
            local marker  = (needleItemID and info.itemID == needleItemID) and " <-- NEEDLE" or ""

            add(("  [%3d] %7s | %5s | %s | %-22s | %-5s | %s%s"):format(
                i, tostring(info.itemID), tostring(info.encounterID),
                matches, equipLocStr, specialKind, nameStr, marker))

            if needleItemID and info.itemID == needleItemID then
                foundNeedle = true
            end
        else
            add(("  [%3d] (GetLootInfoByIndex returned nil)"):format(i))
        end
    end

    add("")
    add(("--- Summary: %d total entries, %d for selected encounter, %d with missing equipLoc."):format(
        entriesTotal, entriesForEnc, missingEquipLoc))

    if needleItemID then
        add("")
        add(("--- Needle itemID=%d analysis"):format(needleItemID))
        if foundNeedle then
            add("FOUND in GetLootInfoByIndex iteration above. Hypothesis A or B.")
        else
            add("NOT FOUND in GetLootInfoByIndex iteration. Hypothesis C: needs a different EJ API.")
            add("")
            add("Probing other EJ paths for the needle itemID:")

            -- Probe whether GetItemInfo even has data for this itemID. If
            -- not, the item-info cache is cold; the answer is genuinely
            -- "EJ doesn't know about this item via the iteration path."
            local nm, lk, _, _, _, itype, sub, _, eloc = GetItemInfo(needleItemID)
            add(("  GetItemInfo: name=%s type=%s subtype=%s equipLoc=%q link=%s"):format(
                tostring(nm), tostring(itype), tostring(sub), tostring(eloc or ""), tostring(lk)))

            -- Mount/pet/toy/decor probes (mirror DetectSpecialKind).
            -- All wrapped defensively: many of these APIs return zero
            -- values (not nil) when their lookup misses, which trips
            -- tostring() if you inline the call. Capture into a local
            -- first so "no values" collapses to nil cleanly.
            if C_MountJournal and C_MountJournal.GetMountFromItem then
                local mountID = C_MountJournal.GetMountFromItem(needleItemID)
                add(("  C_MountJournal.GetMountFromItem(%d) = %s"):format(
                    needleItemID, tostring(mountID)))
            end
            if C_PetJournal and C_PetJournal.GetPetInfoByItemID then
                local petSpecies = select(13, C_PetJournal.GetPetInfoByItemID(needleItemID))
                add(("  C_PetJournal.GetPetInfoByItemID(%d) speciesID = %s"):format(
                    needleItemID, tostring(petSpecies)))
            end
            if C_ToyBox and C_ToyBox.GetToyInfo then
                local toyItemID = C_ToyBox.GetToyInfo(needleItemID)
                add(("  C_ToyBox.GetToyInfo(%d) = %s"):format(
                    needleItemID, tostring(toyItemID)))
            end
            if C_HousingCatalog and C_HousingCatalog.GetCatalogEntryInfoByItem then
                local ok, entry = pcall(C_HousingCatalog.GetCatalogEntryInfoByItem, needleItemID)
                add(("  C_HousingCatalog.GetCatalogEntryInfoByItem: ok=%s entry=%s"):format(
                    tostring(ok), tostring(entry)))
            end

            -- Drakewatcher hint: most manuscripts have a Use: spell that
            -- completes a hidden quest. GetItemSpell may return zero values
            -- for items with no Use spell, so capture into locals first.
            if GetItemSpell then
                local spellName, spellID = GetItemSpell(needleItemID)
                if spellName or spellID then
                    add(("  GetItemSpell(%d): name=%s spellID=%s"):format(
                        needleItemID, tostring(spellName), tostring(spellID)))
                    add("  ^ Manuscripts typically have a Use: spell that completes a hidden quest.")
                else
                    add(("  GetItemSpell(%d): (no Use spell)"):format(needleItemID))
                end
            end
        end
    end

    local body = table.concat(out, "\n")
    self:SetSetting("lastEjProbe", body)
    self:ShowCopyWindow(
        "|cffF259C7RETRO|r|cff4DCCFFRUNS|r  |cffaaaaaa/rr ejprobe|r",
        body)
    self:Print(("ejprobe complete: %d total entries, %d for selected encounter. Window opened."):format(
        entriesTotal, entriesForEnc))
end

-------------------------------------------------------------------------------
-- TierProbe: dump what C_TransmogSets returns for a given tier itemID.
--
-- Diagnostic for tmogverify ERR rows where the harvester wrote sourceIDs
-- that don't match the row's itemID. Walks every set whose `setInfo.label`
-- matches the current raid (or all sets if no raid loaded), pulls
-- GetSourcesForSlot for every TIER_INVSLOT, and reports which of the
-- returned sources actually have the queried itemID. Read-only --
-- no data is written or modified.
--
-- Usage:
--   /rr tierprobe <itemID>
--
-- Example: /rr tierprobe 207257   (Benevolent Embersage's Robe, the row
-- whose sources came back wrong on Nymue Druid Chest in Amirdrassil)
-------------------------------------------------------------------------------
function RR:TierProbe(needleItemID)
    needleItemID = tonumber(needleItemID)
    if not needleItemID then
        self:Print("Usage: /rr tierprobe <itemID>  (e.g. 207257)")
        return
    end

    local out = {}
    local function add(s) table.insert(out, s) end

    add(("tierprobe: itemID=%d"):format(needleItemID))
    add("")

    if not C_TransmogSets or not C_TransmogSets.GetAllSets then
        add("C_TransmogSets API not available on this client.")
        self:ShowCopyWindow("|cffF259C7RETRO|r|cff4DCCFFRUNS|r  |cffaaaaaa/rr tierprobe|r",
            table.concat(out, "\n"))
        return
    end

    -- Try to scope to the current raid's tierSets.labels. If no raid is
    -- loaded, scan all sets (verbose but useful for cross-raid diagnosis).
    local labelSet = {}
    local currentRaid = self:GetSupportedRaid()
    if currentRaid and currentRaid.tierSets and currentRaid.tierSets.labels then
        for _, lab in ipairs(currentRaid.tierSets.labels) do
            labelSet[lab] = true
        end
        add(("scoping to raid: %s  (labels: %d)"):format(
            currentRaid.name or "?", #currentRaid.tierSets.labels))
    else
        add("no raid loaded -- scanning ALL sets (output may be large)")
    end
    add("")

    local TIER_SLOTS = {
        { invslot = 1,  name = "Head"     },
        { invslot = 3,  name = "Shoulder" },
        { invslot = 5,  name = "Chest"    },
        { invslot = 7,  name = "Legs"     },
        { invslot = 10, name = "Hands"    },
    }

    local allSets = C_TransmogSets.GetAllSets() or {}
    local hits = 0
    local setsExamined = 0

    for _, setInfo in ipairs(allSets) do
        local inScope = (next(labelSet) == nil) or (setInfo.label and labelSet[setInfo.label])
        if inScope and setInfo.classMask and setInfo.classMask > 0 then
            setsExamined = setsExamined + 1
            -- Decode classMask -> classID
            local m = setInfo.classMask
            local bitpos = 0
            while m > 1 do m = bit.rshift(m, 1); bitpos = bitpos + 1 end
            local classID = bitpos + 1

            for _, slotDef in ipairs(TIER_SLOTS) do
                local sources = C_TransmogSets.GetSourcesForSlot(setInfo.setID, slotDef.invslot)
                if sources and #sources > 0 then
                    -- Look for our needle in this slot's source list
                    local needleIdx
                    for i, src in ipairs(sources) do
                        if src.itemID == needleItemID then
                            needleIdx = i
                            break
                        end
                    end

                    if needleIdx then
                        hits = hits + 1
                        add(("--- HIT: setID=%d  classID=%d  slot=%s  desc=%q"):format(
                            setInfo.setID, classID, slotDef.name,
                            setInfo.description or ""))
                        add(("  setLabel: %q"):format(setInfo.label or ""))

                        add(("  GetSourcesForSlot returned %d source(s):"):format(#sources))
                        for i, src in ipairs(sources) do
                            local marker = (i == needleIdx) and "  <-- needle" or ""
                            local pickedByHarvester = (i == 1) and "  [harvester picks this]" or ""

                            -- Tiebreaker probe: count how many OTHER tier sets
                            -- at the same difficulty (same description) return
                            -- this same sourceID for the same slot. Hypothesis:
                            -- the real tier source appears in exactly one set
                            -- (its own); doppelganger appears in multiple.
                            local crossClassCount = 0
                            local crossClassSetIDs = {}
                            for _, otherSetInfo in ipairs(allSets) do
                                if otherSetInfo.setID ~= setInfo.setID
                                   and otherSetInfo.label
                                   and labelSet[otherSetInfo.label]
                                   and otherSetInfo.description == setInfo.description
                                   and otherSetInfo.classMask
                                   and otherSetInfo.classMask > 0 then
                                    local otherSources = C_TransmogSets.GetSourcesForSlot(
                                        otherSetInfo.setID, slotDef.invslot)
                                    if otherSources then
                                        for _, otherSrc in ipairs(otherSources) do
                                            if otherSrc.sourceID == src.sourceID then
                                                crossClassCount = crossClassCount + 1
                                                table.insert(crossClassSetIDs, otherSetInfo.setID)
                                                break
                                            end
                                        end
                                    end
                                end
                            end
                            local crossMarker = (" crossClass=%d"):format(crossClassCount)
                            if crossClassCount > 0 then
                                crossMarker = crossMarker .. " {" ..
                                    table.concat(crossClassSetIDs, ",") .. "}"
                            end

                            -- useError: present when the appearance is class-
                            -- restricted away from the player. nil for non-
                            -- class-restricted items (doppelgangers) and for
                            -- items the player's class CAN wear.
                            local useErrorMarker = ""
                            if C_TransmogCollection and C_TransmogCollection.GetSourceInfo and src.sourceID then
                                local info = C_TransmogCollection.GetSourceInfo(src.sourceID)
                                if info then
                                    if info.useError then
                                        useErrorMarker = " useError=set"
                                    else
                                        useErrorMarker = " useError=nil"
                                    end
                                end
                            end

                            -- Tooltip class-restriction scan: read the item's
                            -- tooltip body and look for "Classes:" or
                            -- "Requires <Class>" lines. The actual tier piece
                            -- is class-restricted; the doppelganger isn't.
                            local classRestrictionMarker = " classRestriction=?"
                            if C_TooltipInfo and C_TooltipInfo.GetItemByID and src.itemID then
                                local td = C_TooltipInfo.GetItemByID(src.itemID)
                                if td and td.lines then
                                    local found
                                    for _, line in ipairs(td.lines) do
                                        local lt = line.leftText
                                        if lt then
                                            -- Match "Classes: Warrior" or
                                            -- "Classes: Death Knight, Warrior" etc.
                                            local cap = lt:match("^Classes:%s*(.+)$")
                                            if cap then
                                                found = cap
                                                break
                                            end
                                        end
                                    end
                                    if found then
                                        classRestrictionMarker = (' classRestriction="%s"'):format(found)
                                    else
                                        classRestrictionMarker = " classRestriction=none"
                                    end
                                else
                                    classRestrictionMarker = " classRestriction=tooltip-not-loaded"
                                end
                            end

                            add(("    [%d]  sourceID=%d  itemID=%d  name=%q%s%s%s%s%s"):format(
                                i,
                                src.sourceID or -1,
                                src.itemID or -1,
                                src.name or "?",
                                useErrorMarker,
                                crossMarker,
                                classRestrictionMarker,
                                pickedByHarvester,
                                marker))
                        end
                        add("")
                    end
                end
            end
        end
    end

    add(("--- Summary: examined %d sets, found %d hit(s) for itemID=%d ---"):format(
        setsExamined, hits, needleItemID))
    if hits == 0 then
        add("")
        add("No tier set in scope contains a source with this itemID.")
        add("Verify the itemID is a real tier piece, or scope to a different raid.")
    end

    local body = table.concat(out, "\n")
    self:SetSetting("lastTierProbe", body)
    self:ShowCopyWindow(
        "|cffF259C7RETRO|r|cff4DCCFFRUNS|r  |cffaaaaaa/rr tierprobe|r",
        body)
    self:Print(("tierprobe complete: %d hit(s). Window opened."):format(hits))
end

-------------------------------------------------------------------------------
-- Source-ID resolution
--
-- Given one itemID, returns source info in one of two shapes:
--
--   (sources, nil)            -- Item has multiple appearance variants
--                                (one per difficulty, or similar).
--                                `sources` is { [diffID] = sourceID, ... }.
--
--   (nil, singleSource)       -- Item has exactly one appearance source
--                                (pre-Sepulcher raids mostly work this way --
--                                one appearanceID shared across all
--                                difficulties at the ilvl-tooltip level, no
--                                per-difficulty sourceIDs). Caller is
--                                expected to promote this to a cloned
--                                4-bucket `sources` during enrichment so
--                                downstream code sees one uniform shape.
--
--   (nil, nil)                -- Item has no transmog data at all
--                                (necks, rings, trinkets, quest items).
--
-- An optional `seedLink` and `seedSourceID` can be passed in. If present, the
-- difficulty bucket for the seed source is taken from the seed link's
-- itemContext directly (avoiding a redundant GetSourceInfo call and giving us
-- a guaranteed-valid bucket assignment for at least one variant).
-------------------------------------------------------------------------------

local function ParseItemContextFromLink(link)
    if not link then return 0 end
    local _, linkOptions = LinkUtil.ExtractLink(link)
    if not linkOptions then return 0 end
    local context = select(12, LinkUtil.SplitLinkOptions(linkOptions))
    return tonumber(context) or 0
end

-- Expose so /rr tmogverify (Core.lua) can reuse the same parser.
RR.ParseItemContextFromLink = ParseItemContextFromLink

-- Map a (link?, modID?) pair to a difficulty ID. Prefers itemContext from the
-- link (reliable across Sepulcher-era loot); falls back to modID for items
-- that lack a usable link or have an unmapped context value.
local function ResolveDifficulty(link, modID)
    local context = ParseItemContextFromLink(link)
    local diffID  = ITEM_CONTEXT_TO_DIFFICULTY[context]
    if diffID then return diffID end
    if modID then return MODID_TO_DIFFICULTY[modID] end
    return nil
end

local function ResolveSourcesForItem(itemID, seedLink, seedSourceID)
    if not C_TransmogCollection or not itemID then return nil end

    -- GetItemInfo returns (itemAppearanceID, itemModifiedAppearanceID).
    -- GetAllAppearanceSources takes the APPEARANCE id (first value), not the
    -- source id -- passing sourceID returns nil and silently fails.
    local appearanceID, singleSource = C_TransmogCollection.GetItemInfo(itemID)
    if not appearanceID then return nil end

    local allSources = C_TransmogCollection.GetAllAppearanceSources(appearanceID)
    if not allSources or next(allSources) == nil then
        -- Single-variant item: one appearance covers every difficulty.
        -- Return the single sourceID; enrichment will clone it across
        -- the 4-bucket `sources` shape.
        return nil, singleSource
    end

    local sources = {}

    -- If we have a seed link from the EJ, pre-assign its source to the
    -- correct bucket -- saves a GetSourceInfo call and guarantees the
    -- primary item lands somewhere even if every other variant fails.
    if seedSourceID and seedLink then
        local seedDiff = ResolveDifficulty(seedLink, nil)
        if seedDiff then sources[seedDiff] = seedSourceID end
    end

    -- For every other variant, fetch its own GetSourceInfo and use its
    -- itemLink's itemContext to assign the difficulty bucket. This is the
    -- whole reason we don't need to iterate EJ_SetDifficulty: each variant's
    -- link already encodes which difficulty it was generated at.
    -- (Use pairs not ipairs -- the returned table is not always contiguous.)
    for _, srcID in pairs(allSources) do
        if srcID ~= seedSourceID then
            local info = C_TransmogCollection.GetSourceInfo(srcID)
            if info then
                local diffID = ResolveDifficulty(info.itemLink, info.itemModID)
                if diffID and not sources[diffID] then
                    sources[diffID] = srcID
                end
            end
        end
    end

    -- If no per-difficulty buckets got populated despite having multiple
    -- appearance sources, this is a genuine resolution failure -- the
    -- harvester couldn't tell which source belongs to which difficulty.
    -- Degrade to returning the single primary source and let enrichment
    -- clone it across buckets, same as the single-variant branch above.
    if not next(sources) then
        return nil, singleSource
    end

    return sources
end

-------------------------------------------------------------------------------
-- EJ loot stabilization
--
-- EJ_GetNumLoot can grow incrementally over multiple EJ_LOOT_DATA_RECIEVED
-- events on legacy raids. Firing on the first event reads a partial list
-- (this is how we missed half of Halondrus's tokens during the first
-- /rr tiersets run). Instead, wait for the count to stop changing for a
-- short quiescent period before reading.
--
-- onSettled: called once EJ_GetNumLoot has been stable for `quietMs`
--            milliseconds, OR after `maxWaitMs` total wait, whichever first.
--            If the EJ never returns any loot at all (e.g. a boss with no
--            loot defined), the maxWait timer eventually fires with count=0.
--
-- Defaults: quietMs=2000, maxWaitMs=10000. The 2000ms quiet window absorbs
-- most EJ "goes quiet then late-bursts" patterns. EJ_LOOT_DATA_RECIEVED
-- events also reset the quiet timer, so any inbound data restarts the wait.
--
-- HISTORY: a previous "two consecutive stable reads" attempt was reverted
-- because it had a stale-data race -- when switching bosses, the EJ retains
-- the previous boss's loot count briefly, and two samples taken before new
-- data arrived would both agree on the wrong number. The simpler "wait for
-- quiet" approach handles this correctly because EJ_LOOT_DATA_RECIEVED
-- events from the new boss reset the timer.
-------------------------------------------------------------------------------

local function WaitForEJLootSettled(quietMs, maxWaitMs, onSettled)
    quietMs   = quietMs   or 2000   -- bumped from 1000 to absorb EJ late-bursts
    maxWaitMs = maxWaitMs or 10000

    local listener   = CreateFrame("Frame")
    local lastCount  = -1
    local lastChange = GetTime()
    local startTime  = GetTime()
    local fired      = false

    local function Fire()
        if fired then return end
        fired = true
        listener:UnregisterAllEvents()
        listener:SetScript("OnUpdate", nil)
        onSettled(EJ_GetNumLoot() or 0)
    end

    local function Poll()
        if fired then return end
        local now    = GetTime()
        local count  = EJ_GetNumLoot() or 0
        if count ~= lastCount then
            lastCount  = count
            lastChange = now
        end
        local quietFor = now - lastChange
        local totalFor = now - startTime
        -- Fire if the count has been stable long enough AND we have something,
        -- OR if we've waited too long regardless of count.
        if (count > 0 and quietFor * 1000 >= quietMs)
           or (totalFor * 1000 >= maxWaitMs) then
            Fire()
        end
    end

    listener:RegisterEvent("EJ_LOOT_DATA_RECIEVED")
    -- Reset the quiet timer on every event so the EJ can keep streaming
    -- without us firing prematurely. This handles the "EJ goes quiet for
    -- 1.5s, then delivers more items" pattern that's common on heavy bosses.
    listener:SetScript("OnEvent", function() lastChange = GetTime() end)
    listener:SetScript("OnUpdate", Poll)
end

-- Test whether an itemID is a "token" -- i.e. an EJ loot item that grants no
-- transmog appearance (consumables, currencies, tier tokens, etc.). Real
-- equippable items always have an appearance; tokens never do.
--
-- This is much more reliable than filtering by `filterType == Other` (which
-- both misses many legacy tier tokens AND wrongly catches certain weapons
-- that the EJ buckets as "Other") or `displaySeasonID == nil` (which
-- erroneously excludes legacy-tier tokens that have a retroactive season ID).
--
-- WARNING: this check is CLASS-SENSITIVE. C_TransmogCollection.GetItemInfo
-- returns nil for items the current character cannot collect (e.g. shields
-- for a Warlock), which produces a false-positive "this is a token" result
-- on class-restricted gear. As a result, this function is unsuitable for
-- filtering NON-tier loot from the EJ -- use the equipLoc-empty check
-- via EXCLUDED_SLOTS[""] for that instead. This function is still safe
-- for finding tokens specifically (where the false-positive set is items
-- with valid equipLocs that we don't want anyway -- they get filtered
-- downstream by ParseTokenName which only matches actual tier tokens).
local function IsTokenItem(itemID)
    if not itemID then return false end
    if not C_TransmogCollection then return false end
    local appearanceID = C_TransmogCollection.GetItemInfo(itemID)
    return appearanceID == nil
end

-------------------------------------------------------------------------------
-- Per-encounter loot collection (non-tier)
--
-- Tokens (no transmog appearance) are filtered out here via the
-- EXCLUDED_SLOTS[""] check (tokens have an empty equipLoc) -- the tier-set
-- step handles per-class tier pieces via C_TransmogSets instead. We do NOT
-- use IsTokenItem here because it produces false positives on
-- class-restricted gear (e.g. shields for Warlocks).
--
-- Special-loot items (mounts/pets/toys) are also caught here: items that
-- would otherwise be filtered out by EXCLUDED_SLOTS[""] (non-equippable)
-- are first tested against the collectible-item APIs; if any match, they
-- go into a separate `specials` list rather than being dropped. Sepulcher's
-- "Fractal Cypher of the Zereth Overseer" is the canonical example -- it's
-- a BoP Use:-learns-mount item with no equipLoc. Without this detection
-- it would be invisible to the harvester.
--
-- callback(items, specials):
--   items    = list of { id, name, slot, sources|singleAppearanceSource }
--   specials = list of { id, name, kind } where kind is "mount"/"pet"/"toy"
-------------------------------------------------------------------------------

-- Classifies a non-equippable itemID as mount/pet/toy or nil. The three
-- Classifies a non-equippable itemID as mount/pet/toy/decor/manuscript or nil.
-- The probes run in a defined order -- mount first (most specific), then pet,
-- then toy (broadest of the journal-API kinds), then decor, then manuscript.
-- An item that somehow matched multiple would be reported as whichever matched
-- first; in practice the collectible-item categories don't overlap.
--
-- Returns (kind, resolvedID?) where the meaning of resolvedID depends on kind:
--   "mount"      -> mountID
--   "pet"        -> speciesID
--   "toy"        -> nil (kind is resolved via itemID alone)
--   "decor"      -> catalogEntryID (or nil if API version doesn't expose one)
--   "manuscript" -> questID (or nil if the spellID isn't yet in
--                   MANUSCRIPT_QUESTID_BY_SPELLID -- the harvester emits
--                   a TODO comment in the data file in that case)
--
-- The UI render path can resolve mount/pet/decor IDs lazily, so pre-populating
-- them in the schema is optional. Manuscript questID is load-bearing
-- (IsQuestFlaggedCompleted needs it), so when nil the user must hand-fill.
local function DetectSpecialKind(itemID)
    if not itemID then return nil end

    if C_MountJournal and C_MountJournal.GetMountFromItem then
        local mountID = C_MountJournal.GetMountFromItem(itemID)
        if mountID then return "mount", mountID end
    end

    if C_PetJournal and C_PetJournal.GetPetInfoByItemID then
        local speciesID = select(13, C_PetJournal.GetPetInfoByItemID(itemID))
        if speciesID then return "pet", speciesID end
    end

    if C_ToyBox and C_ToyBox.GetToyInfo then
        -- GetToyInfo returns the toy's itemID as its 1st return when the
        -- arg IS a toy, nil otherwise. Note: there's an older gotcha where
        -- GetToyInfo may return nil for toys the player doesn't own under
        -- certain filter settings. Belt-and-suspenders with PlayerHasToy
        -- covers the detection case: if the player owns it, it's a toy.
        local toyItemID = C_ToyBox.GetToyInfo(itemID)
        if toyItemID then return "toy", nil end
        if PlayerHasToy and PlayerHasToy(itemID) then return "toy", nil end
    end

    -- Housing decor (Midnight / patch 11.2.7+). pcall-wrapped because
    -- C_HousingCatalog doesn't exist on pre-11.2.7 clients and we'd like
    -- the harvester to still work on older clients rather than hard-error.
    if C_HousingCatalog and C_HousingCatalog.GetCatalogEntryInfoByItem then
        local ok, entry = pcall(
            C_HousingCatalog.GetCatalogEntryInfoByItem, itemID)
        if ok and entry then
            -- The resolved ID could be in several field names depending
            -- on API version. Try to extract one for the schema; if none
            -- of our guesses hit, that's fine -- the UI render path can
            -- resolve lazily from itemID via the same API.
            local resolvedID
            if type(entry) == "table" then
                resolvedID = entry.catalogEntryID or entry.decorID or entry.id
            elseif type(entry) == "number" then
                resolvedID = entry
            end
            return "decor", resolvedID
        end
    end

    -- Drakewatcher Manuscript (DF onward). No dedicated journal API exists;
    -- detected via the use-spell name "Deciphering". questID resolved from
    -- a static map; nil for new-raid spellIDs not yet in the map. See the
    -- block above MANUSCRIPT_QUESTID_BY_SPELLID for the extension procedure.
    local isManuscript, questID = DetectManuscript(itemID)
    if isManuscript then
        return "manuscript", questID
    end

    return nil
end

local function CollectEncounterLoot(journalInstanceID, journalEncounterID,
                                    difficultyID, callback)
    local targetID = journalEncounterID

    -- Core scraping loop, factored out so we can call it repeatedly for
    -- the two-stable-reads check AND for the dedicated Mythic specials
    -- sweep. Given a populated EJ state, walk loot items and classify
    -- them into regular / special. Blizzard's own docs at EJ_GetLootInfo
    -- note "If loot information is not immediately available,
    -- EJ_LOOT_DATA_RECIEVED will fire when it is." -- so callers pair
    -- this with WaitForEJLootSettled and two-stable-reads to absorb
    -- late-burst events.
    local function Scrape()
        local items    = {}
        local specials = {}
        local seen     = {}
        local numLoot  = EJ_GetNumLoot() or 0

        for i = 1, numLoot do
            local info = C_EncounterJournal.GetLootInfoByIndex(i)
            if info and info.itemID and not seen[info.itemID]
                and info.encounterID == targetID then
                seen[info.itemID] = true

                -- Don't use IsTokenItem here. The EXCLUDED_SLOTS[""]
                -- check below already filters out true tokens (tier
                -- pieces have equipLoc=""). Using IsTokenItem additionally
                -- drops class-restricted gear like shields for non-shield
                -- classes -- C_TransmogCollection.GetItemInfo returns nil
                -- for items the current character cannot collect, which
                -- is a false positive for our purposes. Class-restricted
                -- gear keeps its valid equipLoc (INVTYPE_SHIELD etc.) and
                -- should remain in the harvest output.
                local itemName, _, _, _, _, _, _, _, loc =
                    GetItemInfo(info.itemID)
                local equipLocStr = loc or ""

                if not EXCLUDED_SLOTS[equipLocStr] then
                    local sources, singleAppearanceSource =
                        ResolveSourcesForItem(info.itemID, info.link, nil)
                    table.insert(items, {
                        id              = info.itemID,
                        name            = info.name or ("Unknown_%d"):format(info.itemID),
                        slot            = SLOT_LABEL[equipLocStr] or equipLocStr,
                        sources         = sources,
                        singleAppearanceSource  = singleAppearanceSource,
                    })
                else
                    -- Excluded slot: check if it's actually a
                    -- special-loot item (mount/pet/toy/decor) before
                    -- dropping. We probe only the buckets that are
                    -- plausibly collectibles:
                    --   "" (empty string) -- some items use this
                    --   "INVTYPE_NON_EQUIP_IGNORE" -- mounts, pets,
                    --      toys, decor, and most non-equippable items
                    -- use this explicit string (verified via
                    -- /rr specialtest 190768 against the Zereth
                    -- Overseer Cypher: equipLoc="INVTYPE_NON_EQUIP_IGNORE").
                    -- We intentionally don't probe INVTYPE_NECK /
                    -- FINGER / TRINKET / BAG / QUIVER -- those are
                    -- real gear / container slots and probing them
                    -- against mount/pet/toy APIs would be wasted work
                    -- and a false-positive risk.
                    if equipLocStr == ""
                       or equipLocStr == "INVTYPE_NON_EQUIP_IGNORE" then
                        local kind, resolvedID = DetectSpecialKind(info.itemID)
                        if kind then
                            local entry = {
                                id   = info.itemID,
                                name = info.name or itemName
                                          or ("Unknown_%d"):format(info.itemID),
                                kind = kind,
                            }
                            if kind == "mount" then
                                entry.mountID = resolvedID
                            elseif kind == "pet" then
                                entry.speciesID = resolvedID
                            elseif kind == "decor" then
                                entry.catalogEntryID = resolvedID
                            elseif kind == "manuscript" then
                                -- questID may be nil if the spellID isn't yet
                                -- in MANUSCRIPT_QUESTID_BY_SPELLID. The data-
                                -- file emit code below renders a TODO comment
                                -- in that case so the user knows to look it
                                -- up from ATT/wowdb and add the static map
                                -- entry.
                                entry.questID = resolvedID
                            end
                            table.insert(specials, entry)
                        end
                    end
                end
            end
        end

        table.sort(items, function(a, b)
            if a.slot ~= b.slot then return a.slot < b.slot end
            return a.name < b.name
        end)
        table.sort(specials, function(a, b)
            if a.kind ~= b.kind then return a.kind < b.kind end
            return a.name < b.name
        end)

        return items, specials
    end

    local function Finish(items, specials)
        callback(items, specials)
    end

    -- After the Normal-difficulty scrape produces (items, specials), we
    -- do a dedicated Mythic-difficulty sweep purely to pick up specials
    -- (mounts / pets / toys / housing decor) that only appear on higher
    -- difficulties. The Jailer's "Fractal Cypher of the Zereth Overseer"
    -- (190768) is the canonical example -- Mythic-only drop that the
    -- Normal EJ view doesn't show.
    --
    -- Regular items from the Mythic pass are IGNORED. The harvester's
    -- overall strategy is Normal-as-source-of-truth for regular loot;
    -- per-difficulty source IDs for those items are resolved by
    -- EnrichWithPerDifficultySources later. Only specials bypass that
    -- pipeline, because they have no per-difficulty sources.
    --
    -- Costs: adds ~5-7s per boss (one EJ walk + two-stable-reads). For
    -- Sepulcher's 11 bosses that's ~60-75s total. Trade for coverage.
    local function SweepMythicSpecials(itemsFromNormal, specialsFromNormal)
        local MYTHIC = 16

        -- Build a seen-set from Normal's specials so we don't re-add.
        local alreadySeen = {}
        for _, sp in ipairs(specialsFromNormal) do
            alreadySeen[sp.id] = true
        end

        -- Prime EJ at Mythic.
        EJ_SetDifficulty(MYTHIC)
        EJ_SelectInstance(journalInstanceID)
        EJ_ResetLootFilter()

        C_Timer.After(0.2, function()
            pcall(EJ_SelectEncounter, targetID)
            if C_EncounterJournal and C_EncounterJournal.ResetSlotFilter then
                C_EncounterJournal.ResetSlotFilter()
            end
            EJ_SetDifficulty(MYTHIC)

            WaitForEJLootSettled(2000, 10000, function()
                -- Same two-stable-reads pattern as the Normal pass, but
                -- measuring ONLY specials count. Regular items are
                -- collected from the Scrape call but discarded below.
                local iterations     = 0
                local MAX_ITERATIONS = 3
                local lastCount      = -1
                local lastSpecials

                -- Forward-declare so Attempt below can reference it.
                -- The assignment happens further down after Attempt's
                -- closure-capture is in scope.
                local MergeAndFinish

                local function Attempt()
                    iterations = iterations + 1
                    local _, specials = Scrape()
                    local count = #specials

                    if count == lastCount and iterations > 1 then
                        -- Stable: merge and finish.
                        MergeAndFinish()
                        return
                    end

                    lastCount    = count
                    lastSpecials = specials

                    if iterations >= MAX_ITERATIONS then
                        MergeAndFinish()
                        return
                    end

                    C_Timer.After(2.0, function()
                        pcall(EJ_SelectEncounter, targetID)
                        C_Timer.After(0.3, Attempt)
                    end)
                end

                MergeAndFinish = function()
                    -- Merge Mythic specials into Normal specials, dedup
                    -- by itemID. Re-sort for stable output order.
                    local merged = {}
                    for _, sp in ipairs(specialsFromNormal) do
                        table.insert(merged, sp)
                    end
                    if lastSpecials then
                        for _, sp in ipairs(lastSpecials) do
                            if not alreadySeen[sp.id] then
                                alreadySeen[sp.id] = true
                                table.insert(merged, sp)
                            end
                        end
                    end
                    table.sort(merged, function(a, b)
                        if a.kind ~= b.kind then return a.kind < b.kind end
                        return a.name < b.name
                    end)

                    -- Restore EJ to the original difficulty so that
                    -- downstream stages (EnrichWithPerDifficultySources)
                    -- don't inherit a surprising Mythic bias.
                    EJ_SetDifficulty(difficultyID)

                    Finish(itemsFromNormal, merged)
                end

                Attempt()
            end)
        end)
    end

    -- Prime the EJ so our calls land on the right boss at the right difficulty.
    EJ_SetDifficulty(difficultyID)
    EJ_SelectInstance(journalInstanceID)
    EJ_ResetLootFilter()

    C_Timer.After(0.2, function()
        pcall(EJ_SelectEncounter, targetID)
        -- ResetSlotFilter affects slot-group visibility, not class filtering.
        if C_EncounterJournal and C_EncounterJournal.ResetSlotFilter then
            C_EncounterJournal.ResetSlotFilter()
        end
        EJ_SetDifficulty(difficultyID)

        -- quietMs=2000 matches the WaitForEJLootSettled default comment
        -- ("bumped from 1000 to absorb EJ late-bursts"). Earlier, this
        -- caller explicitly passed 1000, overriding the safer default --
        -- which caused premature fires on cold-cache bosses (pre-change,
        -- 7 of 11 Sepulcher bosses returned 0 non-tier items on a fresh
        -- harvest). 2000ms is the minimum reliable window.
        WaitForEJLootSettled(2000, 10000, function()
            -- Two-consecutive-stable-reads: scrape, wait 2s, scrape
            -- again. If item counts match, accept. If they differ, take
            -- the higher count and retry, up to 3 iterations total.
            --
            -- Why this is needed beyond WaitForEJLootSettled's quiet
            -- window: quietMs fires when "no activity for N seconds",
            -- which is satisfied even by a stuck-at-zero state or a
            -- partial population that then goes quiet. Observed on fresh
            -- Sepulcher harvest: Lihuvim returned 6 of its 7 real
            -- non-tier items -- looked "settled" to WaitForEJLootSettled
            -- but was genuinely incomplete. Two-stable-reads catches
            -- both the zero case AND the partial case.
            --
            -- Cost: minimum 2s per boss (the delay before the second
            -- scrape). Bosses that settle cleanly pay exactly 2s;
            -- flaky ones pay up to 6s. For Sepulcher's 11 bosses that's
            -- +22s minimum. Acceptable for a dev tool whose alternative
            -- is incorrect output.
            local iterations     = 0
            local MAX_ITERATIONS = 3
            local lastCount      = -1
            local lastItems, lastSpecials

            local function Attempt()
                iterations = iterations + 1
                local items, specials = Scrape()
                local count = #items + #specials

                if count == lastCount and iterations > 1 then
                    -- Stable: two consecutive scrapes returned the same
                    -- count. Hand off to the Mythic specials sweep,
                    -- which will eventually call Finish.
                    SweepMythicSpecials(items, specials)
                    return
                end

                -- Unstable or first iteration. Remember what we saw and
                -- try again after a delay. Keep the latest snapshot in
                -- case we hit MAX_ITERATIONS without stabilizing.
                lastCount    = count
                lastItems    = items
                lastSpecials = specials

                if iterations >= MAX_ITERATIONS then
                    -- Give up stabilizing; hand off to the Mythic sweep
                    -- with the latest Normal-pass snapshot.
                    SweepMythicSpecials(lastItems, lastSpecials)
                    return
                end

                C_Timer.After(2.0, function()
                    -- Re-select the encounter between attempts in case
                    -- EJ state got clobbered by other addon traffic
                    -- during the wait.
                    pcall(EJ_SelectEncounter, targetID)
                    C_Timer.After(0.3, Attempt)
                end)
            end

            Attempt()
        end)
    end)
end

-------------------------------------------------------------------------------
-- Per-difficulty enrichment fallback
--
-- Single-pass `ResolveSourcesForItem` (which enumerates GetAllAppearanceSources
-- and parses each variant's link) fails for Sepulcher-era loot because the
-- per-variant links don't carry context (modID=0 across the board, and the
-- enumerated source links are EJ-cache artifacts that lose itemContext).
--
-- When that happens, we fall back to walking the EJ at each difficulty.
-- EJ_SetDifficulty(diffID) makes GetLootInfoByIndex return links with the
-- right context for THAT difficulty -- so the per-item sourceID we get from
-- C_TransmogCollection.GetItemInfo(itemID) at each difficulty pass IS the
-- correct per-difficulty sourceID.
--
-- This is more expensive (~4x EJ passes per boss) but it's the only reliable
-- way to recover per-difficulty sources for Sepulcher-era content. We invoke
-- it conditionally: only if any item in the boss's non-tier loot list has
-- an empty `sources` table (i.e. only singleAppearanceSource is populated).
--
-- items: list of items as produced by CollectEncounterLoot.
-- onDone: callback() with no args; items are mutated in place.
-------------------------------------------------------------------------------

local function EnrichWithPerDifficultySources(journalInstanceID, journalEncounterID,
                                              items, onDone)
    -- Quick-exit: if nothing needs enrichment, return immediately.
    local needsEnrichment = false
    local itemsByID = {}
    for _, it in ipairs(items) do
        itemsByID[it.id] = it
        if not it.sources or next(it.sources) == nil then
            needsEnrichment = true
        end
    end
    if not needsEnrichment then
        onDone()
        return
    end

    local PASSES = { 17, 14, 15, 16 }   -- LFR, Normal, Heroic, Mythic
    local idx    = 0
    local targetID = journalEncounterID

    local function NextPass()
        idx = idx + 1
        if idx > #PASSES then
            -- All 4 passes done. Normalize every item to a populated
            -- 4-bucket `sources` table.
            --
            -- Three cases to handle:
            --
            -- (a) Fully per-difficulty items (Sepulcher-era): each pass
            --     found a distinct sourceID per bucket. Nothing to do.
            --
            -- (b) Partially-filled items (Gavel of the First Arbiter --
            --     legendary, single source across all 4 diffs because
            --     the EJ doesn't generate per-difficulty links for it).
            --     Some buckets populated, others empty. Fill missing
            --     buckets from any populated value.
            --
            -- (c) Single-variant items (Sanctum-era armor, most pre-9.2
            --     raid gear): GetAllAppearanceSources returned only one
            --     variant for the appearance, and no EJ pass resolved
            --     a per-difficulty source either. `sources` is nil;
            --     the one appearance source is stashed in
            --     `singleAppearanceSource` from the initial scrape.
            --     Promote it to a 4-bucket clone so downstream code
            --     doesn't need a second render path.
            --
            -- After this loop, every item either has a fully-populated
            -- `sources = { [17]=..., [14]=..., [15]=..., [16]=... }`
            -- or has neither (truly no transmog data, rare).
            for _, it in ipairs(items) do
                if it.sources then
                    -- Case (a) or (b): fill any empty buckets.
                    local fill
                    -- Prefer Normal as the source value to copy (it's the
                    -- difficulty we primed the EJ to and most reliably
                    -- has a populated value); else any other diff.
                    fill = it.sources[14]
                        or it.sources[17]
                        or it.sources[15]
                        or it.sources[16]
                    if fill then
                        for _, d in ipairs(PASSES) do
                            if not it.sources[d] then
                                it.sources[d] = fill
                            end
                        end
                    end

                    -- Collapse warning: if every difficulty resolved to the
                    -- SAME sourceID after all 4 passes, either (i) this
                    -- item legitimately has one source across all diffs
                    -- (rare; legendaries like Gavel of the First Arbiter),
                    -- or (ii) the per-difficulty resolution silently failed
                    -- (Sanctum-era bug where C_TransmogCollection.GetItemInfo
                    -- on each per-difficulty link returned the same canonical
                    -- sourceID instead of the difficulty-specific one). The
                    -- harvester can't distinguish these cases, so it flags
                    -- the item as suspect for manual review. Check against
                    -- Wowhead / ATT / Adventure Guide "show all appearances"
                    -- before shipping the integrated data file.
                    local uniq = {}
                    for _, d in ipairs(PASSES) do
                        if it.sources[d] then uniq[it.sources[d]] = true end
                    end
                    local uniqCount = 0
                    for _ in pairs(uniq) do uniqCount = uniqCount + 1 end
                    if uniqCount == 1 then
                        it.collapsedToSingle = true
                    end
                elseif it.singleAppearanceSource then
                    -- Case (c): promote the single appearance source to
                    -- a cloned 4-bucket sources table. The same sourceID
                    -- in every bucket is faithful to the API --
                    -- PlayerHasTransmogItemModifiedAppearance returns
                    -- the same answer regardless of which bucket the UI
                    -- queries, so all 4 dots will color identically.
                    it.sources = {}
                    for _, d in ipairs(PASSES) do
                        it.sources[d] = it.singleAppearanceSource
                    end
                    it.singleAppearanceSource = nil
                end
            end
            onDone()
            return
        end

        local diffID = PASSES[idx]
        EJ_SetDifficulty(diffID)
        EJ_SelectInstance(journalInstanceID)
        EJ_ResetLootFilter()
        C_Timer.After(0.2, function()
            pcall(EJ_SelectEncounter, targetID)
            if C_EncounterJournal and C_EncounterJournal.ResetSlotFilter then
                C_EncounterJournal.ResetSlotFilter()
            end
            EJ_SetDifficulty(diffID)

            WaitForEJLootSettled(1000, 10000, function(numLoot)
                for i = 1, numLoot do
                    local info = C_EncounterJournal.GetLootInfoByIndex(i)
                    if info and info.itemID and info.encounterID == targetID then
                        local item = itemsByID[info.itemID]
                        if item then
                            -- Resolve the source for this item AT THIS DIFFICULTY.
                            --
                            -- IMPORTANT: pass `info.link` (not `info.itemID`).
                            -- The 1-arg itemID form returns the canonical/Normal
                            -- sourceID regardless of EJ_SetDifficulty state.
                            -- The link form, in contrast, contains the EJ's
                            -- per-difficulty bonus data that biases the API
                            -- to return the correct per-difficulty variant.
                            -- This is the same trick TokenTransmogTooltips'
                            -- DungeonJournalExtractor relies on for its
                            -- itemContext parsing.
                            --
                            -- We trust whatever sourceID the link form returns
                            -- at each pass. Single-variant items (e.g. unique
                            -- legendary drops like Gavel of the First Arbiter)
                            -- legitimately return the same source at all 4
                            -- difficulties -- that's a feature, not a bug.
                            local _, srcID = C_TransmogCollection.GetItemInfo(info.link)
                            if srcID then
                                item.sources = item.sources or {}
                                item.sources[diffID] = srcID
                            end
                        end
                    end
                end
                C_Timer.After(0.2, NextPass)
            end)
        end)
    end

    NextPass()
end

-------------------------------------------------------------------------------
-- Output formatting
-------------------------------------------------------------------------------

local function FormatSources(sources)
    if not sources then return nil end
    local parts = {}
    for _, diffID in ipairs(DIFF_ORDER) do
        if sources[diffID] then
            table.insert(parts, ("[%d]=%d"):format(diffID, sources[diffID]))
        end
    end
    if #parts == 0 then return nil end
    return "{ " .. table.concat(parts, ", ") .. " }"
end

local function FormatItemLine(item, classesField)
    local nameSafe  = item.name:gsub('"', '\\"')
    local srcStr    = FormatSources(item.sources)
    local classes   = classesField and (", classes = { " .. classesField .. " }") or ""
    -- Trailing warning comment when this item's 4 per-difficulty sources
    -- all collapsed to the same sourceID after enrichment. Integration
    -- should verify against ATT / Wowhead before shipping.
    local suspect   = item.collapsedToSingle
                      and "  -- COLLAPSED: verify per-difficulty sources" or ""

    if srcStr then
        return ("    { id=%-7d, slot=\"%s\", name=\"%s\", sources=%s%s },%s"):format(
            item.id, item.slot, nameSafe, srcStr, classes, suspect)
    elseif item.singleAppearanceSource then
        return ("    { id=%-7d, slot=\"%s\", name=\"%s\", singleAppearanceSource=%d%s },%s"):format(
            item.id, item.slot, nameSafe, item.singleAppearanceSource, classes, suspect)
    else
        return ("    { id=%-7d, slot=\"%s\", name=\"%s\"%s },%s"):format(
            item.id, item.slot, nameSafe, classes, suspect)
    end
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Tier-set collection (C_TransmogSets)
--
-- Pulls every per-class per-difficulty set whose label appears in the raid's
-- `tierSets.labels`. For each (class, slot) row, calls GetSourcesForSlot to
-- enumerate per-difficulty source IDs, and routes the row to a bossIndex by
-- looking up the appropriate tier token in `tierSets.tokenSources`.
--
-- Token routing logic:
--   1. Walk every token in `tokenSources`, parse its name with ParseTokenName
--      to get (groupPrefix, slot). Build a map of (group, slot) -> bossIndex.
--   2. Build classID -> groupPrefix using TIER_GROUPS, restricted to the
--      group prefixes actually present among the raid's tokens (so we don't
--      accidentally route Sepulcher's Warlock pieces via a CONQUEROR group
--      mapping that's only valid for older raids).
--   3. For each tier-row: lookup group via classID, lookup boss via
--      (group, row.slot). Rows with no resolvable boss go to result[0]
--      (which the caller surfaces as a warning).
--
-- The Normal-difficulty itemID is preferred as the row's `id` (and its name
-- as the row's `name`); LFR is used as fallback if Normal is missing.
--
-- Returns: { [bossIndex] = { item, item, ... }, ... }
-- Where each `item` is { id, slot, name, classes={cid}, sources={[diff]=src} }
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- setInfo.description (localized) -> difficulty ID. Each tier setID is
-- per-(class, difficulty); the description string identifies which difficulty.
--
-- Built at addon-load time from the client's localized PLAYER_DIFFICULTY
-- globals, which Blizzard sets per-locale. This makes the map work on any
-- client locale without code changes -- as long as setInfo.description
-- matches the same string Blizzard uses for the difficulty selector
-- (true on all locales we've checked).
--
-- The English fallback values are kept in case the globals aren't loaded
-- yet (defensive -- shouldn't happen in practice since this file loads
-- after the standard UI globals).
-------------------------------------------------------------------------------
local SET_DESCRIPTION_TO_DIFFICULTY = {}
SET_DESCRIPTION_TO_DIFFICULTY[PLAYER_DIFFICULTY6 or "Raid Finder"] = 17  -- LFR
SET_DESCRIPTION_TO_DIFFICULTY[PLAYER_DIFFICULTY1 or "Normal"]      = 14  -- Normal
SET_DESCRIPTION_TO_DIFFICULTY[PLAYER_DIFFICULTY2 or "Heroic"]      = 15  -- Heroic
SET_DESCRIPTION_TO_DIFFICULTY[PLAYER_DIFFICULTY3 or "Mythic"]      = 16  -- Mythic

-------------------------------------------------------------------------------
-- Localized class name -> classID map. Built at addon-load time from the
-- client's LOCALIZED_CLASS_NAMES_{MALE,FEMALE} globals so locale-specific
-- tooltip lines like "Classes: Warlock" / "Classes : Démoniste" / etc. can
-- be resolved to a Blizzard classID (1..13).
--
-- Used by ParseItemClassRestriction to disambiguate tier-set sources when
-- C_TransmogSets.GetSourcesForSlot returns multiple candidates for the same
-- (set, slot, difficulty) -- the actual tier piece is class-locked to the
-- set's classID; the doppelganger has no class restriction.
--
-- Both male and female forms are inserted because some locales gender class
-- names. Both keys map to the same classID, so any tooltip line lookup
-- works regardless of which form Blizzard chose.
-------------------------------------------------------------------------------
local CLASSNAME_TO_CLASSID = {}
do
    local CLASS_FILES = {
        WARRIOR     = 1,
        PALADIN     = 2,
        HUNTER      = 3,
        ROGUE       = 4,
        PRIEST      = 5,
        DEATHKNIGHT = 6,
        SHAMAN      = 7,
        MAGE        = 8,
        WARLOCK     = 9,
        MONK        = 10,
        DRUID       = 11,
        DEMONHUNTER = 12,
        EVOKER      = 13,
    }
    for cf, cid in pairs(CLASS_FILES) do
        local male   = LOCALIZED_CLASS_NAMES_MALE   and LOCALIZED_CLASS_NAMES_MALE[cf]
        local female = LOCALIZED_CLASS_NAMES_FEMALE and LOCALIZED_CLASS_NAMES_FEMALE[cf]
        if male   then CLASSNAME_TO_CLASSID[male]   = cid end
        if female then CLASSNAME_TO_CLASSID[female] = cid end
    end
end

-------------------------------------------------------------------------------
-- ParseItemClassRestriction(itemID) -> { [classID] = true, ... } or nil
--
-- Reads the item's tooltip body via C_TooltipInfo.GetItemByID, looks for
-- the locale-aware ITEM_CLASSES_ALLOWED line ("Classes: <list>" in en-US),
-- splits the comma-separated class-name list, and returns a set of classIDs.
-- Returns nil if the item has no class restriction line, or if the tooltip
-- API isn't available.
--
-- Used by the tier resolver to pick the correct source when GetSourcesForSlot
-- returns multiple candidates per (set, slot, difficulty). The class-locked
-- source is the actual tier piece; an unrestricted source is the doppelganger
-- non-tier drop that shares the visual.
-------------------------------------------------------------------------------
local function ParseItemClassRestriction(itemID)
    if not itemID or not C_TooltipInfo or not C_TooltipInfo.GetItemByID then
        return nil
    end
    local td = C_TooltipInfo.GetItemByID(itemID)
    if not td or not td.lines then return nil end

    -- ITEM_CLASSES_ALLOWED is the format string for the "Classes:" tooltip
    -- line (e.g. "Classes: %s" in en-US, "Classes : %s" in French). We
    -- strip the "%s" placeholder to get the literal prefix to match against.
    local prefix
    if ITEM_CLASSES_ALLOWED then
        prefix = ITEM_CLASSES_ALLOWED:gsub("%%s.*$", "")
    end
    -- Defensive fallback for unusual locales where the global is missing.
    if not prefix or prefix == "" then prefix = "Classes:" end

    local classes
    for _, line in ipairs(td.lines) do
        local lt = line.leftText
        if lt and lt:sub(1, #prefix) == prefix then
            local list = lt:sub(#prefix + 1):gsub("^%s+", "")
            -- Split on ", " (single locales may use "、" or others; this
            -- covers the common cases and falls through to single-class).
            classes = {}
            for name in list:gmatch("([^,]+)") do
                local trimmed = name:gsub("^%s+", ""):gsub("%s+$", "")
                local cid = CLASSNAME_TO_CLASSID[trimmed]
                if cid then classes[cid] = true end
            end
            break
        end
    end

    if classes and next(classes) then return classes end
    return nil
end

-- Forward-declared; body below.
local CollectTierSets_Build

local function CollectTierSets(tierSets, onDone)
    if not tierSets or not C_TransmogSets then
        if onDone then onDone({}) end
        return
    end

    local labels       = tierSets.labels       or {}
    local tokenSources = tierSets.tokenSources or {}
    if #labels == 0 then
        if onDone then onDone({}) end
        return
    end

    -- Pre-compute label set for O(1) check.
    local labelSet = {}
    for _, lab in ipairs(labels) do labelSet[lab] = true end

    -- Cache-warming pass: walk every matching set and fire GetItemInfo on
    -- every (class, slot) source itemID. GetItemInfo is async -- the first
    -- call returns nil but queues the server-side fetch; subsequent calls
    -- return cached data. By doing this up front and waiting briefly, we
    -- give the cache time to warm so the row-building pass below can read
    -- names directly. Without this, names come out as Unknown_NNNNNN for
    -- items the player has never seen.
    local allSets = C_TransmogSets.GetAllSets() or {}
    for _, setInfo in ipairs(allSets) do
        if setInfo.label and labelSet[setInfo.label] then
            for _, slotDef in ipairs(TIER_INVSLOTS) do
                local sources =
                    C_TransmogSets.GetSourcesForSlot(setInfo.setID, slotDef.id)
                if sources then
                    -- Warm the GetItemInfo cache for every candidate source,
                    -- not just sources[1]. The class-restriction-aware
                    -- selector below may pick any element of the list, so all
                    -- of them need their names cached for the row builder
                    -- to produce a populated itemName.
                    --
                    -- Also touch C_TooltipInfo.GetItemByID for each candidate
                    -- to prime the tooltip cache. ParseItemClassRestriction
                    -- reads tooltip body lines for the "Classes:" line, and
                    -- the first call returns nil while the data fetches.
                    for _, src in ipairs(sources) do
                        if src.itemID then
                            GetItemInfo(src.itemID)
                            if C_TooltipInfo and C_TooltipInfo.GetItemByID then
                                C_TooltipInfo.GetItemByID(src.itemID)
                            end
                        end
                    end
                end
            end
        end
    end
    -- Also warm token names -- though those are usually already cached
    -- because they're referenced in the tierSets schema directly.
    for tokenID in pairs(tokenSources) do
        GetItemInfo(tokenID)
    end

    C_Timer.After(1.5, function()
        local out = CollectTierSets_Build(tierSets)
        if onDone then onDone(out) end
    end)
end

-- Synchronous row-building body. Extracted from CollectTierSets so the async
-- wrapper above can await cache warming before invoking it. Same return shape
-- as the original CollectTierSets: { [bossIndex] = { item, ... }, ... }.
function CollectTierSets_Build(tierSets)
    local result = {}
    if not tierSets or not C_TransmogSets then return result end

    local labels       = tierSets.labels       or {}
    local tokenSources = tierSets.tokenSources or {}
    if #labels == 0 then return result end

    -- Pre-compute label set for O(1) check.
    local labelSet = {}
    for _, lab in ipairs(labels) do labelSet[lab] = true end

    -- Build (group, slot) -> bossIndex by parsing each token's name.
    -- Also record which groups are "active" (mentioned by any token) so the
    -- classID -> group mapping later doesn't span multiple expansions.
    local groupSlotToBoss = {}      -- ["MYSTIC:Legs"] = 7
    local activeGroups    = {}      -- { "MYSTIC", "VENERATED", ... }
    local activeGroupSeen = {}
    for tokenID, bossIdxVal in pairs(tokenSources) do
        -- GetItemInfo can return cached data; if it returns nil we skip
        -- this token rather than crash. The data file should re-emit
        -- tokenSources via /rr tiersets if names are stale.
        local tokenName = (GetItemInfo(tokenID))
        if tokenName then
            local group, slot = ParseTokenName(tokenID, tokenName)
            if group and slot then
                -- `bossIdxVal` is either a scalar bossIndex (Sepulcher
                -- schema shape) or a list of bossIndexes (Castle Nathria
                -- shape, where tokens drop on multiple bosses). For the
                -- armor-tier pipeline, one (group, slot) resolves to one
                -- primary boss -- pick the smallest bossIndex from a list
                -- (i.e. the earliest-encountered boss that drops it),
                -- matching the prior scalar-only behavior on single-drop
                -- tokens.
                local bossIdx = bossIdxVal
                if type(bossIdxVal) == "table" then
                    local smallest
                    for _, v in ipairs(bossIdxVal) do
                        if not smallest or v < smallest then smallest = v end
                    end
                    bossIdx = smallest
                end
                groupSlotToBoss[group .. ":" .. slot] = bossIdx
                if not activeGroupSeen[group] then
                    activeGroupSeen[group] = true
                    table.insert(activeGroups, group)
                end
            end
        end
    end

    local classToGroup = BuildClassToGroupMap(activeGroups)

    local allSets = C_TransmogSets.GetAllSets()
    if not allSets then return result end

    -- (class, slot) -> {
    --   classID, slot, setLabel,
    --   sources    = { [diff] = sourceID },
    --   itemIDs    = { [diff] = itemID   },
    --   itemNames  = { [diff] = name     },
    -- }
    local rows = {}

    for _, setInfo in ipairs(allSets) do
        if setInfo.label and labelSet[setInfo.label]
           and setInfo.classMask and setInfo.classMask > 0 then
            -- Tier sets are single-class (one bit). Bit position +1 = classID.
            local classMask = setInfo.classMask
            local bitpos = 0
            local m = classMask
            while m > 1 do m = bit.rshift(m, 1); bitpos = bitpos + 1 end
            local classID = bitpos + 1
            -- Each setID is per-(class, difficulty); the description tells us
            -- which difficulty (locale-independent via runtime-built
            -- SET_DESCRIPTION_TO_DIFFICULTY map keyed on PLAYER_DIFFICULTY
            -- globals).
            local setDiffID = setInfo.description and SET_DESCRIPTION_TO_DIFFICULTY[setInfo.description]
            -- Sanity: skip if mask isn't a clean single bit (would mean a
            -- multi-class set, which legacy tier shouldn't produce). Also
            -- skip if we can't identify the difficulty.
            if bit.lshift(1, bitpos) == classMask
               and classID >= 1 and classID <= 13
               and setDiffID then

                for _, slotDef in ipairs(TIER_INVSLOTS) do
                    local sources =
                        C_TransmogSets.GetSourcesForSlot(setInfo.setID, slotDef.id)
                    if sources and #sources > 0 then
                        -- C_TransmogSets.GetSourcesForSlot can return multiple
                        -- sources per (set, slot) -- the canonical class-locked
                        -- tier piece plus zero or more shared-visual non-tier
                        -- doppelgangers. Order is unstable across difficulties,
                        -- so blindly picking sources[1] sometimes returns the
                        -- doppelganger instead of the tier piece, producing
                        -- rows with the wrong itemID + sourceID combination.
                        --
                        -- Disambiguate by class restriction: the tier piece is
                        -- class-locked to this set's classID; a doppelganger
                        -- has no class restriction. Pick the first source
                        -- whose itemID is class-restricted to `classID`.
                        --
                        -- If no source has a matching class restriction (item
                        -- might be cache-cold, or the API surface might change
                        -- in a future patch), fall back to sources[1] so we
                        -- never produce a row with no source. The fallback
                        -- preserves prior behavior for pre-DF tier sets that
                        -- don't exhibit the doppelganger pattern.
                        local primary
                        for _, src in ipairs(sources) do
                            if src.itemID then
                                local restrictions = ParseItemClassRestriction(src.itemID)
                                if restrictions and restrictions[classID] then
                                    primary = src
                                    break
                                end
                            end
                        end
                        if not primary then primary = sources[1] end

                        if primary and primary.sourceID and primary.itemID then
                            local key = classID .. ":" .. slotDef.slot
                            local row = rows[key]
                            if not row then
                                row = {
                                    classID   = classID,
                                    slot      = slotDef.slot,
                                    setLabel  = setInfo.label,
                                    sources   = {},
                                    itemIDs   = {},
                                    itemNames = {},
                                }
                                rows[key] = row
                            end
                            -- Last write wins per (class, slot, difficulty)
                            -- but since each (classID, setDiffID) corresponds
                            -- to exactly one setID per slot, this isn't a race.
                            row.sources[setDiffID]   = primary.sourceID
                            row.itemIDs[setDiffID]   = primary.itemID
                            -- src.name may be nil for items not yet in the
                            -- client's GetItemInfo cache. Fall back to a
                            -- direct GetItemInfo call which queries the cache
                            -- AND queues an async load for next time.
                            row.itemNames[setDiffID] =
                                primary.name or (GetItemInfo(primary.itemID))
                        end
                    end
                end
            end
        end
    end

    -- Convert raw rows to output items, picking display id/name from Normal
    -- (then LFR/Heroic/Mythic in priority order) and bucketing by boss using
    -- the class -> group -> token -> bossIndex lookup chain. Rows that fail
    -- to resolve a boss go to result[0] (the caller handles unrouted rows).
    local DISPLAY_PREF = { 14, 17, 15, 16 }

    for _, row in pairs(rows) do
        local displayID, displayName
        for _, diffID in ipairs(DISPLAY_PREF) do
            if row.itemIDs[diffID] then
                displayID   = row.itemIDs[diffID]
                -- itemNames[diffID] may still be nil even after the fallback
                -- attempt -- happens when the client hasn't cached this
                -- itemID yet. Walk all four difficulty names looking for any
                -- that's populated; if none, leave it for the Unknown fallback.
                displayName = row.itemNames[diffID]
                if not displayName then
                    for _, d in ipairs(DISPLAY_PREF) do
                        if row.itemNames[d] then displayName = row.itemNames[d]; break end
                    end
                end
                break
            end
        end

        if displayID then
            local group  = classToGroup[row.classID]
            local bossID = group and groupSlotToBoss[group .. ":" .. row.slot] or 0

            local item = {
                id       = displayID,
                name     = displayName or ("Unknown_%d"):format(displayID),
                slot     = row.slot,
                sources  = row.sources,
                classes  = { row.classID },
                _setLabel = row.setLabel,
            }

            result[bossID] = result[bossID] or {}
            table.insert(result[bossID], item)
        end
    end

    -- Stable sort within each boss bucket: slot, then class.
    for _, list in pairs(result) do
        table.sort(list, function(a, b)
            if a.slot ~= b.slot then return a.slot < b.slot end
            return (a.classes[1] or 0) < (b.classes[1] or 0)
        end)
    end

    return result
end

-------------------------------------------------------------------------------
-- Full-raid harvest
--
-- Walks every boss, captures non-tier loot via the EJ at NORMAL difficulty.
-- For each item that returns only singleAppearanceSource (no per-difficulty bucket
-- via the link-context path), runs an additional 4-difficulty EJ sweep that
-- queries C_TransmogCollection.GetItemInfo at each difficulty to get the
-- correct per-difficulty sourceID. Then captures tier items via
-- C_TransmogSets and routes them to the boss declared in
-- `tierSets.tokenSources`.
-------------------------------------------------------------------------------

--- HarvestAllBosses(bossFilter, opts)
---
--- bossFilter (optional): substring match against boss name. When set, only
---   matching bosses are harvested. Used for single-boss dev iteration.
---
--- opts (optional): table with two optional fields used by /rr raidcapture
---   to inject just-discovered tier data and bundle the harvest output:
---     tierCfgOverride : table of shape { labels = {...}, tokenSources = {...} }
---                       used in place of RR.currentRaid.tierSets. Lets the
---                       harvester see tier rows without requiring the data
---                       file to be edited first.
---     onComplete      : function(outputText). Called after the harvest finishes
---                       with the assembled output text. When nil, the default
---                       "Harvest complete! Use /rr harvest dump to view." print
---                       fires instead. Either way, lastHarvestAll is saved.
---
--- Existing /rr harvest callers pass no opts; behavior is unchanged.
function RR:HarvestAllBosses(bossFilter, opts)
    opts = opts or {}
    if not RR.currentRaid then
        self:Print("No supported raid loaded. Enter a supported raid first.")
        return
    end

    local bosses = RR.currentRaid.bosses

    -- Normalize the optional boss filter: case-insensitive substring match
    -- against boss.name. Used for single-boss harvests during development
    -- (the full Sepulcher harvest takes 6-7 minutes; a single-boss run
    -- takes ~30-40 seconds and is much friendlier for iterating on
    -- detection / sweep / merge logic).
    local filterLC = bossFilter and bossFilter:lower() or nil
    local harvestCount = #bosses   -- will be overwritten if filter active
    if filterLC then
        local matched = 0
        for _, b in ipairs(bosses) do
            if b.name and b.name:lower():find(filterLC, 1, true) then
                matched = matched + 1
            end
        end
        if matched == 0 then
            self:Print(("No boss matches '%s' in %s."):format(
                bossFilter, RR.currentRaid.name))
            return
        end
        harvestCount = matched
        self:Print(("Filtering to %d boss(es) matching '%s'."):format(
            matched, bossFilter))
    end

    -- Derive the journal instance ID from stored metadata or by probing.
    local journalInstanceID = RR.currentRaid.journalInstanceID
    if not journalInstanceID then
        for _, b in ipairs(bosses) do
            if b.journalEncounterID then
                local _, _, _, _, _, instID = EJ_GetEncounterInfo(b.journalEncounterID)
                if instID and instID > 0 then
                    journalInstanceID = instID
                    break
                end
            end
        end
    end
    if not journalInstanceID then
        self:Print("Could not determine journal instance ID.")
        return
    end

    -- We harvest each boss at Normal (14). Per-difficulty sources are resolved
    -- from each item link's itemContext, so a single EJ difficulty pass yields
    -- all four difficulty sourceIDs per item.
    local HARVEST_DIFFICULTY = 14

    -- Collect tier items up-front (they're indexed by boss for later lookup).
    -- CollectTierSets is async (it warms the GetItemInfo cache before reading
    -- names), so the rest of the setup runs inside the callback.
    self:Print("Warming tier-item cache (~1.5s)...")
    local tierCfg = opts.tierCfgOverride or RR.currentRaid.tierSets
    CollectTierSets(tierCfg, function(tierByBoss)
    local tierConfigured = tierCfg
                       and tierCfg.labels
                       and #tierCfg.labels > 0
    local tierFoundCount = 0
    for _, list in pairs(tierByBoss) do tierFoundCount = tierFoundCount + #list end

    local output = {}
    table.insert(output, ("-- RetroRuns loot harvest: %s"):format(RR.currentRaid.name))
    table.insert(output, ("-- Generated: %s"):format(date("%Y-%m-%d %H:%M")))
    table.insert(output, ("-- Harvest difficulty (for EJ prime): %d (Normal)"):format(
        HARVEST_DIFFICULTY))
    table.insert(output, "-- Per-difficulty sources: itemContext-from-link first, with 4-difficulty EJ sweep fallback per boss.")
    if tierConfigured then
        local labelStr = table.concat(tierCfg.labels, ", ")
        table.insert(output, ("-- Tier: C_TransmogSets matched %d row(s) across labels: %s"):format(
            tierFoundCount, labelStr))
        if tierByBoss[0] and #tierByBoss[0] > 0 then
            table.insert(output, ("-- Tier: %d row(s) had no boss attribution (no matching token in tokenSources)."):format(
                #tierByBoss[0]))
        end
    else
        table.insert(output, "-- Tier: no `tierSets.labels` configured for this raid -- tier rows skipped.")
        table.insert(output, "--       Use /rr tiersets to find labels for the current raid.")
    end
    table.insert(output, "")

    self:Print(("Harvesting %d boss%s -- please wait..."):format(
        harvestCount, harvestCount == 1 and "" or "es"))

    local bossIdx = 0

    local function ProcessNext()
        bossIdx = bossIdx + 1

        if bossIdx > #bosses then
            -- After all bosses processed, surface any tier items whose
            -- bossIndex didn't match a real boss (config error / placeholder).
            for badIdx, list in pairs(tierByBoss) do
                if badIdx < 1 or badIdx > #bosses then
                    if badIdx == 0 then
                        table.insert(output, ("-- WARNING: %d tier row(s) had no boss attribution"):format(#list))
                        table.insert(output, "--          (no entry in tierSets.tokenSources covered the row's class+slot).")
                        table.insert(output, "--          Re-run /rr tiersets to refresh tokenSources.")
                    else
                        table.insert(output, ("-- WARNING: tier rows targeted bossIndex=%s (no such boss); %d row(s) dropped:"):format(
                            tostring(badIdx), #list))
                    end
                    for _, it in ipairs(list) do
                        table.insert(output, ("--   class=%d slot=%s name=%s"):format(
                            it.classes[1], it.slot, it.name))
                    end
                    table.insert(output, "")
                end
            end

            local outputText = table.concat(output, "\n")
            RR:SetSetting("lastHarvestAll", outputText)
            if opts.onComplete then
                opts.onComplete(outputText)
            else
                RR:Print("Harvest complete! Use /rr harvest dump to view.")
            end
            return
        end

        local boss      = bosses[bossIdx]
        local journalID = boss.journalEncounterID

        -- Skip this boss if a filter is active and doesn't match.
        -- The skip is silent (no output emitted) to keep the dump
        -- focused on just the requested boss(es).
        if filterLC and not (boss.name and boss.name:lower():find(filterLC, 1, true)) then
            C_Timer.After(0, ProcessNext)
            return
        end

        if not journalID then
            table.insert(output, ("-- WARNING: '%s' has no journalEncounterID"):format(boss.name))
            table.insert(output, "")
            C_Timer.After(0, ProcessNext)
            return
        end

        CollectEncounterLoot(journalInstanceID, journalID, HARVEST_DIFFICULTY,
        function(regularItems, specials)
            EnrichWithPerDifficultySources(journalInstanceID, journalID, regularItems,
            function()
                local tierItems = tierByBoss[boss.index] or {}

                -- Count how many items still lack any per-difficulty sources
                -- (true single-source items, or items the EJ couldn't resolve).
                local stillEmpty = 0
                for _, it in ipairs(regularItems) do
                    if not it.sources or next(it.sources) == nil then
                        stillEmpty = stillEmpty + 1
                    end
                end

                local headerNote = ""
                if stillEmpty > 0 then
                    headerNote = (" -- %d item(s) still without per-difficulty sources"):format(stillEmpty)
                end

                -- Count items whose 4 per-difficulty sources all collapsed
                -- to the same sourceID. These are suspect -- the Sanctum
                -- re-harvest case taught us that the enrichment sweep can
                -- silently degrade to single-source for every item if the
                -- EJ or transmog APIs don't yield per-difficulty variants.
                -- Surface this in the boss header so integration reviews
                -- the items against ATT / Wowhead before shipping them.
                local collapsed = 0
                for _, it in ipairs(regularItems) do
                    if it.collapsedToSingle then
                        collapsed = collapsed + 1
                    end
                end
                if collapsed > 0 then
                    headerNote = headerNote
                        .. (" -- %d item(s) collapsed to single-source (verify!)"):format(collapsed)
                end

                -- Include special-loot count in the boss header when we
                -- found any, so a glance at the harvest dump shows which
                -- bosses drop collectibles.
                local specialNote = ""
                if specials and #specials > 0 then
                    specialNote = (", %d special"):format(#specials)
                end

                table.insert(output,
                    ("-- Boss %d: %s  (%d non-tier items, %d tier rows%s)%s"):format(
                        boss.index, boss.name, #regularItems, #tierItems,
                        specialNote, headerNote))
                table.insert(output, "loot = {")

                for _, item in ipairs(regularItems) do
                    table.insert(output, FormatItemLine(item, nil))
                end

                if #tierItems > 0 then
                    table.insert(output, ("    -- Tier (%d items)"):format(#tierItems))
                    for _, item in ipairs(tierItems) do
                        table.sort(item.classes)
                        local classStr = table.concat(item.classes, ", ")
                        table.insert(output, FormatItemLine(item, classStr))
                    end
                end

                table.insert(output, "},")

                -- specialLoot block (mounts/pets/toys/decor/manuscripts):
                -- emit only when this boss had any. mounts/pets/toys/decor
                -- collapse to a single-line row (id, kind, name); the UI
                -- resolves their typed IDs (mountID/speciesID/etc) lazily
                -- from itemID, so emitting them in the data file is
                -- optional and we keep it terse.
                --
                -- Manuscripts are special: questID is load-bearing because
                -- IsQuestFlaggedCompleted(questID) drives the unlock-state
                -- check. We emit a multi-line entry to include questID
                -- on its own line. When DetectSpecialKind couldn't resolve
                -- the questID (sp.questID == nil -- spellID not yet in the
                -- static map), we emit `questID = nil` with a TODO comment
                -- so the user knows to look it up from ATT/wowdb and add
                -- the spellID->questID map entry in Harvester.lua.
                if specials and #specials > 0 then
                    table.insert(output, "specialLoot = {")
                    for _, sp in ipairs(specials) do
                        if sp.kind == "manuscript" then
                            table.insert(output, "    {")
                            table.insert(output, ("        id      = %d,"):format(sp.id))
                            table.insert(output, ("        kind    = %q,"):format(sp.kind))
                            table.insert(output, ("        name    = %q,"):format(sp.name))
                            if sp.questID then
                                table.insert(output, ("        questID = %d,"):format(sp.questID))
                            else
                                table.insert(output, "        questID = nil,  -- TODO: look up via ATT/wowdb, then add spellID->questID to MANUSCRIPT_QUESTID_BY_SPELLID in Harvester.lua")
                            end
                            table.insert(output, "    },")
                        else
                            table.insert(output,
                                ("    { id = %d, kind = %q, name = %q },"):format(
                                    sp.id, sp.kind, sp.name))
                        end
                    end
                    table.insert(output, "},")
                end

                table.insert(output, "")

                RR:Print(("[%d/%d] %s done"):format(bossIdx, #bosses, boss.name))
                C_Timer.After(0.4, ProcessNext)
            end)
        end)
    end

    -- Prime the EJ before starting
    EJ_SetDifficulty(HARVEST_DIFFICULTY)
    EJ_SelectInstance(journalInstanceID)
    EJ_ResetLootFilter()
    C_Timer.After(0.5, function()
        if bosses[1] and bosses[1].journalEncounterID then
            pcall(EJ_SelectEncounter, bosses[1].journalEncounterID)
        end
        C_Timer.After(0.5, ProcessNext)
    end)
    end)   -- end CollectTierSets callback
end

-------------------------------------------------------------------------------
-- Per-encounter token collection
--
-- Mirrors CollectEncounterLoot but captures ONLY tokens (items with no
-- transmog appearance). Used by /rr tiersets to attribute each tier set to
-- the boss whose loot contains a name-matching token, and by HarvestAllBosses
-- to build a (tokenItemID -> bossIndex) map for tier-row routing.
--
-- callback(tokens): { { itemID, name }, ... } -- one entry per token itemID,
-- deduped within the boss's loot list.
-------------------------------------------------------------------------------

local function CollectEncounterTokens(journalInstanceID, journalEncounterID,
                                      difficultyID, callback)
    local targetID = journalEncounterID

    EJ_SetDifficulty(difficultyID)
    EJ_SelectInstance(journalInstanceID)
    EJ_ResetLootFilter()

    C_Timer.After(0.2, function()
        pcall(EJ_SelectEncounter, targetID)
        if C_EncounterJournal and C_EncounterJournal.ResetSlotFilter then
            C_EncounterJournal.ResetSlotFilter()
        end
        EJ_SetDifficulty(difficultyID)

        WaitForEJLootSettled(1000, 10000, function(numLoot)
            local tokens = {}
            local seen   = {}

            for i = 1, numLoot do
                local info = C_EncounterJournal.GetLootInfoByIndex(i)
                if info and info.itemID and not seen[info.itemID]
                    and info.encounterID == targetID
                then
                    -- Token-candidate detection: collection-state-independent
                    -- AND modern-token-aware.
                    --
                    -- We accept an item if EITHER:
                    --   (a) equipLoc == "" -- classic token-style item
                    --       (no equip slot, gets exchanged for gear)
                    --   (b) appearanceID == nil AND name matches a tier
                    --       pattern -- modern tokens may have a real equipLoc
                    --       (post-Vault changes) but they still register no
                    --       transmog appearance (until exchanged).
                    --
                    -- Combined, this catches:
                    --   - Classic SL-era tokens (equipLoc empty)
                    --   - Modern DF+ tokens (equipLoc set, no appearance)
                    --   - Tokens whose appearance the player has collected
                    --     (caught by case (a) since equipLoc is still empty)
                    --
                    -- And rejects:
                    --   - Real gear with appearances (both checks fail)
                    --   - Class-restricted gear like shields for Warlocks
                    --     (case (a) fails: real equipLoc; case (b) fails:
                    --     name doesn't match tier pattern)
                    local itemName, _, _, _, _, _, _, _, equipLoc =
                        GetItemInfo(info.itemID)
                    local equipLocStr = equipLoc or ""
                    local nameStr = itemName or info.name

                    local accept = (equipLocStr == "")
                    if not accept and nameStr and C_TransmogCollection then
                        local appearanceID = C_TransmogCollection.GetItemInfo(info.itemID)
                        if appearanceID == nil then
                            local g, s = ParseTokenName(info.itemID, nameStr)
                            if g and s then accept = true end
                        end
                    end

                    if accept then
                        seen[info.itemID] = true
                        table.insert(tokens, {
                            itemID = info.itemID,
                            name   = nameStr or ("Unknown_%d"):format(info.itemID),
                        })
                    end
                end
            end

            callback(tokens)
        end)
    end)
end

-------------------------------------------------------------------------------
-- Tier-set diagnostic (boss-attributed)
--
-- For the loaded raid: walks every boss's EJ loot, identifies tokens, and
-- emits a copy-ready `tierSets = { labels = {...}, tokenSources = {...} }`
-- block. The harvester resolves each per-class per-slot tier-row to a boss
-- by parsing token names (e.g. "Mystic Leg Module" -> Mystic-class Legs go
-- on this token's boss).
--
-- Label discovery: SL+ raids use one raid-wide label that all 4 tier groups
-- share (e.g. "Sepulcher of the First Ones"), distinguished by classMask
-- and description. Older raids use per-tier-group labels (Conqueror,
-- Protector, Vanquisher). We discover candidate labels by matching the
-- raid's name against `setInfo.label` (exact, then substring), and surface
-- per-tier-group labels via TIER_GROUPS prefix matching as a fallback.
-------------------------------------------------------------------------------

-- Map of human-readable expansion name -> Enum.ExpansionID-style integer
-- used by setInfo.expansionID. Indices match Blizzard's ordering. Used to
-- surface same-expansion sets that didn't match -- a safety net in case the
-- raid-name heuristic missed something. Unknown expansions skip the filter.
local EXPANSION_NAME_TO_ID = {
    ["Classic"]                        = 0,
    ["Burning Crusade"]                = 1,
    ["Wrath of the Lich King"]         = 2,
    ["Cataclysm"]                      = 3,
    ["Mists of Pandaria"]              = 4,
    ["Warlords of Draenor"]            = 5,
    ["Legion"]                         = 6,
    ["Battle for Azeroth"]             = 7,
    ["Shadowlands"]                    = 8,
    ["Dragonflight"]                   = 9,
    ["The War Within"]                 = 10,
    ["Midnight"]                       = 11,
}

function RR:DumpTransmogSets()
    if not C_TransmogSets then
        self:Print("C_TransmogSets unavailable.")
        return
    end
    if not RR.currentRaid then
        self:Print("Load a raid first (zone in or use /rr test). " ..
                   "tiersets needs a raid to attribute tokens to bosses.")
        return
    end

    local raid              = RR.currentRaid
    local bosses            = raid.bosses or {}
    local journalInstanceID = raid.journalInstanceID
    if not journalInstanceID then
        for _, b in ipairs(bosses) do
            if b.journalEncounterID then
                local _, _, _, _, _, instID = EJ_GetEncounterInfo(b.journalEncounterID)
                if instID and instID > 0 then
                    journalInstanceID = instID
                    break
                end
            end
        end
    end
    if not journalInstanceID then
        self:Print("Could not determine journal instance ID for the loaded raid.")
        return
    end

    local raidExpansionID = EXPANSION_NAME_TO_ID[raid.expansion]   -- may be nil

    self:Print(("Scanning %d bosses for tier tokens..."):format(#bosses))

    -- Phase 1: walk every boss, collect tokens.
    -- bossIdx -> { { itemID, name }, ... }
    local tokensByBoss = {}
    local bossIdx      = 0

    local function FinishAndDump()
        -- Phase 2: filter the token list to actual tier tokens.
        --
        -- Not every "no-appearance" item is a tier token (some bosses drop
        -- quest items, currencies, or class-specific consumables that also
        -- have no appearance). A tier token's name parses cleanly to
        -- (group, slot) via ParseTokenName -- that's our filter.
        --
        -- bossIdx -> { tierTokens = {...}, otherTokens = {...} }
        local tierTokensByBoss  = {}
        local otherTokensByBoss = {}
        local allTierTokens     = {}    -- flat: { { itemID, name, bossIdx, group, slot }, ... }
        for bIdx, list in pairs(tokensByBoss) do
            for _, tok in ipairs(list) do
                local group, slot = ParseTokenName(tok.itemID, tok.name)
                if group and slot then
                    tierTokensByBoss[bIdx] = tierTokensByBoss[bIdx] or {}
                    table.insert(tierTokensByBoss[bIdx], tok)
                    table.insert(allTierTokens, {
                        itemID  = tok.itemID,
                        name    = tok.name,
                        bossIdx = bIdx,
                        group   = group,
                        slot    = slot,
                    })
                else
                    otherTokensByBoss[bIdx] = otherTokensByBoss[bIdx] or {}
                    table.insert(otherTokensByBoss[bIdx], tok)
                end
            end
        end

        -- Phase 3: discover candidate set labels.
        --
        -- Strategy 1 (SL+): a setInfo.label that equals the raid's name (or
        -- contains it as a substring) is the raid-wide tier label. All 4 tier
        -- groups share this single label.
        --
        -- Strategy 2 (older raids): a setInfo.label that matches one of our
        -- TIER_GROUPS prefixes (Conqueror/Protector/Vanquisher) AND whose
        -- expansionID matches the raid's. One label per group.
        local allSets = C_TransmogSets.GetAllSets() or {}
        local matchedLabels   = {}    -- label -> { setInfo, reason }
        local candidateLabels = {}    -- label -> setInfo  (same expansion, no match)

        local raidNameLower = (raid.name or ""):lower()

        for _, s in ipairs(allSets) do
            local label = s.label
            if label and label ~= "" then
                local labelLower = label:lower()

                local matchReason
                -- Strategy 1: raid-name match
                if labelLower == raidNameLower then
                    matchReason = "exact match to raid name"
                elseif raidNameLower ~= ""
                       and (labelLower:find(raidNameLower, 1, true)
                            or raidNameLower:find(labelLower, 1, true)) then
                    matchReason = "substring match to raid name"
                else
                    -- Strategy 2: TIER_GROUPS prefix match (older raids)
                    for prefix in pairs(TIER_GROUPS) do
                        if labelLower == prefix:lower() then
                            if not raidExpansionID
                               or s.expansionID == raidExpansionID then
                                matchReason = ("matches tier group '%s' in raid expansion"):format(prefix)
                            end
                            break
                        end
                    end
                end

                if matchReason then
                    if not matchedLabels[label] then
                        matchedLabels[label] = { setInfo = s, reason = matchReason }
                    end
                elseif raidExpansionID and s.expansionID == raidExpansionID then
                    if not candidateLabels[label] then
                        candidateLabels[label] = s
                    end
                end
            end
        end

        -- Phase 4: build tokenSources map.
        -- (Trivial -- one entry per tier token, keyed by itemID.)
        local tokenSourceList = {}    -- list of { itemID, bossIdx, name, group, slot }
        for _, tt in ipairs(allTierTokens) do
            table.insert(tokenSourceList, tt)
        end
        table.sort(tokenSourceList, function(a, b)
            -- Sort tokens by group, then slot, then bossIdx for stable readable output
            if a.group ~= b.group then return a.group < b.group end
            local slotOrder = { Head = 1, Shoulder = 2, Chest = 3, Hands = 4, Legs = 5 }
            local as, bs = slotOrder[a.slot] or 99, slotOrder[b.slot] or 99
            if as ~= bs then return as < bs end
            return a.bossIdx < b.bossIdx
        end)

        -- Phase 5: render.
        local out = {}
        local tokenCount = #tokenSourceList
        local nonTierTokenCount = 0
        for _, list in pairs(otherTokensByBoss) do nonTierTokenCount = nonTierTokenCount + #list end

        table.insert(out, ("-- /rr tiersets for: %s"):format(raid.name))
        table.insert(out, ("-- Generated: %s"):format(date("%Y-%m-%d %H:%M")))
        table.insert(out, ("-- Bosses scanned: %d  Tier tokens: %d  Non-tier no-appearance items: %d"):format(
            #bosses, tokenCount, nonTierTokenCount))

        -- WARNING when tokens=0 but a raid label DID match. With tooltip-
        -- based slot resolution this should be very rare -- the body
        -- words ("Head", "Shoulders", etc.) appear in every standard
        -- tier-token tooltip. Triggers indicate either a tooltip-API
        -- failure on every token (improbable; tooltips are aggressively
        -- cached client-side) or a raid that has matching set labels
        -- but no actual tier tokens (e.g. seasonal sets sharing the
        -- raid's name).
        --
        -- In either case, the READY-TO-PASTE block below will be empty.
        -- Don't paste an empty tokenSources over a working one.
        if tokenCount == 0 and next(matchedLabels) ~= nil then
            table.insert(out, "")
            table.insert(out, "-- !! WARNING !! Tier-set labels matched but ZERO tier tokens were")
            table.insert(out, "-- detected. Possible causes: tooltip lookup failed for every")
            table.insert(out, "-- token (try /reload and re-run -- caches refresh on UI reload),")
            table.insert(out, "-- or the raid has set labels but no actual tokens (e.g. some")
            table.insert(out, "-- non-tier seasonal sets share labels with the raid name).")
            table.insert(out, "-- The READY-TO-PASTE block below will be EMPTY -- do NOT paste it")
            table.insert(out, "-- over a working tierSets block in your data file.")
        end
        table.insert(out, "")

        -- 5a: ready-to-paste block.
        table.insert(out, "================================================================")
        table.insert(out, "-- READY-TO-PASTE: drop this into the raid's data file as the")
        table.insert(out, "-- raid's `tierSets = { ... }` block. Paste this entire window")
        table.insert(out, "-- back for review and integration.")
        table.insert(out, "================================================================")

        if next(matchedLabels) == nil then
            table.insert(out, "-- (no tier set labels matched -- see candidates section below)")
            table.insert(out, "tierSets = nil,")
        else
            local labelList = {}
            for label in pairs(matchedLabels) do table.insert(labelList, label) end
            table.sort(labelList)

            table.insert(out, "tierSets = {")
            table.insert(out, "    labels = {")
            for _, label in ipairs(labelList) do
                local m = matchedLabels[label]
                table.insert(out, ("        %q,  -- %s (setID=%d, exp=%d, patch=%s)"):format(
                    label, m.reason, m.setInfo.setID or 0,
                    m.setInfo.expansionID or -1, tostring(m.setInfo.patchID)))
            end
            table.insert(out, "    },")
            table.insert(out, "    tokenSources = {")

            if tokenCount == 0 then
                table.insert(out, "        -- (no tier tokens found in any boss's loot)")
            else
                for _, t in ipairs(tokenSourceList) do
                    local bossName = "?"
                    for _, b in ipairs(bosses) do
                        if b.index == t.bossIdx then bossName = b.name break end
                    end
                    table.insert(out, ("        [%d] = %d,  -- %s -> %s"):format(
                        t.itemID, t.bossIdx, t.name, bossName))
                end
            end
            table.insert(out, "    },")
            table.insert(out, "},")
        end
        table.insert(out, "")

        -- 5b: detail -- tokens per boss.
        table.insert(out, "================================================================")
        table.insert(out, "-- DETAIL: tier tokens detected per boss")
        table.insert(out, "================================================================")
        local sawAnyTier = false
        for _, b in ipairs(bosses) do
            local list = tierTokensByBoss[b.index] or {}
            if #list > 0 then
                sawAnyTier = true
                table.insert(out, ("Boss %d: %s"):format(b.index, b.name))
                for _, tok in ipairs(list) do
                    local g, s = ParseTokenName(tok.itemID, tok.name)
                    table.insert(out, ("    [%d] %s   -- group=%s slot=%s"):format(
                        tok.itemID, tok.name, tostring(g), tostring(s)))
                end
            end
        end
        if not sawAnyTier then
            table.insert(out, "(none)")
        end
        table.insert(out, "")

        -- 5c: non-tier no-appearance items (sanity check).
        if nonTierTokenCount > 0 then
            table.insert(out, "================================================================")
            table.insert(out, ("-- INFO: %d items had no transmog appearance but didn't parse"):format(nonTierTokenCount))
            table.insert(out, "-- as tier tokens (likely currencies, quest items, special drops).")
            table.insert(out, "-- Listed for transparency -- not added to tokenSources.")
            table.insert(out, "================================================================")
            for _, b in ipairs(bosses) do
                local list = otherTokensByBoss[b.index] or {}
                if #list > 0 then
                    table.insert(out, ("Boss %d: %s"):format(b.index, b.name))
                    for _, tok in ipairs(list) do
                        table.insert(out, ("    [%d] %s"):format(tok.itemID, tok.name))
                    end
                end
            end
            table.insert(out, "")
        end

        -- 5d: same-expansion candidates that didn't match.
        if raidExpansionID then
            local candList = {}
            for label, s in pairs(candidateLabels) do
                table.insert(candList, { label = label, sample = s })
            end
            table.sort(candList, function(a, b) return a.label < b.label end)

            if #candList > 0 then
                table.insert(out, "================================================================")
                table.insert(out, ("-- CANDIDATES: same-expansion sets (exp=%d %s) that didn't"):format(
                    raidExpansionID, tostring(raid.expansion)))
                table.insert(out, "-- match the raid's name or any TIER_GROUPS prefix. Likely from")
                table.insert(out, "-- other raids/dungeons -- but worth a glance in case a label")
                table.insert(out, "-- with an unusual name should have matched.")
                table.insert(out, "================================================================")
                for _, c in ipairs(candList) do
                    table.insert(out, ("    %s  (setID=%d, patch=%s)"):format(
                        c.label, c.sample.setID or 0, tostring(c.sample.patchID)))
                end
                table.insert(out, "")
            end
        end

        local body = table.concat(out, "\n")
        self:SetSetting("lastHarvestAll", body)

        self:ShowCopyWindow(
            "|cffF259C7RETRO|r|cff4DCCFFRUNS|r  |cffaaaaaa/rr tiersets|r",
            body)

        local labelCount = 0
        for _ in pairs(matchedLabels) do labelCount = labelCount + 1 end
        self:Print(("tiersets done: %d label(s), %d tier token(s). Window opened."):format(
            labelCount, tokenCount))
    end

    local function NextBoss()
        bossIdx = bossIdx + 1
        if bossIdx > #bosses then
            FinishAndDump()
            return
        end
        local boss = bosses[bossIdx]
        if not boss.journalEncounterID then
            C_Timer.After(0, NextBoss)
            return
        end
        CollectEncounterTokens(journalInstanceID, boss.journalEncounterID, 14,
            function(tokens)
                if #tokens > 0 then
                    tokensByBoss[boss.index] = tokens
                end
                C_Timer.After(0.3, NextBoss)
            end)
    end

    -- Prime the EJ before starting
    EJ_SetDifficulty(14)
    EJ_SelectInstance(journalInstanceID)
    EJ_ResetLootFilter()
    C_Timer.After(0.5, function()
        if bosses[1] and bosses[1].journalEncounterID then
            pcall(EJ_SelectEncounter, bosses[1].journalEncounterID)
        end
        C_Timer.After(0.5, NextBoss)
    end)
end

-------------------------------------------------------------------------------
-- DiscoverTierSets: async tier-set discovery extracted for /rr raidcapture.
--
-- Parallel implementation of DumpTransmogSets's discovery phase (Phase 1+2+3
-- token-walk + label match + tokenSources build), but instead of printing a
-- ready-to-paste block to chat, returns the discovered tierCfg + a formatted
-- paste-block string via callback.
--
-- Why a parallel implementation rather than refactoring DumpTransmogSets to
-- share code: keeps the trusted /rr tiersets command 100% byte-for-byte
-- unchanged (it's been the manual-workflow fallback for 4 prior raids and
-- known-good). Code duplication is the cost; risk-reduction is the benefit.
--
-- Callback signature: onDone(tierCfg, formattedBlock, info)
--   tierCfg        : { labels = {...}, tokenSources = { [itemID] = bossIdx } }
--                    or nil on error (specific error printed to chat first)
--   formattedBlock : string, ready-to-paste tierSets = { ... } block
--                    or nil on error
--   info           : { labelCount = N, tokenCount = N, raidName = "...",
--                      error = "no_api"|"no_raid"|"no_jiid" or nil }
-------------------------------------------------------------------------------
function RR:DiscoverTierSets(onDone)
    if not C_TransmogSets then
        self:Print("C_TransmogSets unavailable.")
        onDone(nil, nil, { error = "no_api" })
        return
    end
    if not RR.currentRaid then
        self:Print("Load a raid first (zone in or use /rr test).")
        onDone(nil, nil, { error = "no_raid" })
        return
    end

    local raid              = RR.currentRaid
    local bosses            = raid.bosses or {}
    local journalInstanceID = raid.journalInstanceID
    if not journalInstanceID then
        for _, b in ipairs(bosses) do
            if b.journalEncounterID then
                local _, _, _, _, _, instID = EJ_GetEncounterInfo(b.journalEncounterID)
                if instID and instID > 0 then
                    journalInstanceID = instID
                    break
                end
            end
        end
    end
    if not journalInstanceID then
        self:Print("Could not determine journal instance ID for the loaded raid.")
        onDone(nil, nil, { error = "no_jiid" })
        return
    end

    local raidExpansionID = EXPANSION_NAME_TO_ID[raid.expansion]

    self:Print(("Discovering tier sets for %d boss(es)..."):format(#bosses))

    local tokensByBoss = {}
    local bossIdx      = 0

    local function FinishAndCallback()
        -- Filter to actual tier tokens (parses cleanly via ParseTokenName).
        local allTierTokens = {}
        for bIdx, list in pairs(tokensByBoss) do
            for _, tok in ipairs(list) do
                local group, slot = ParseTokenName(tok.itemID, tok.name)
                if group and slot then
                    table.insert(allTierTokens, {
                        itemID  = tok.itemID,
                        name    = tok.name,
                        bossIdx = bIdx,
                        group   = group,
                        slot    = slot,
                    })
                end
            end
        end

        -- Match labels via Strategy 1 (raid-name match) and Strategy 2
        -- (TIER_GROUPS prefix at correct expansion). Same logic as
        -- DumpTransmogSets; see that function for the full rationale.
        local allSets       = C_TransmogSets.GetAllSets() or {}
        local matchedLabels = {}
        local raidNameLower = (raid.name or ""):lower()

        for _, s in ipairs(allSets) do
            local label = s.label
            if label and label ~= "" then
                local labelLower = label:lower()
                local matchReason
                if labelLower == raidNameLower then
                    matchReason = "exact match to raid name"
                elseif raidNameLower ~= ""
                       and (labelLower:find(raidNameLower, 1, true)
                            or raidNameLower:find(labelLower, 1, true)) then
                    matchReason = "substring match to raid name"
                else
                    for prefix in pairs(TIER_GROUPS) do
                        if labelLower == prefix:lower() then
                            if not raidExpansionID
                               or s.expansionID == raidExpansionID then
                                matchReason = ("matches tier group '%s' in raid expansion"):format(prefix)
                            end
                            break
                        end
                    end
                end
                if matchReason and not matchedLabels[label] then
                    matchedLabels[label] = { setInfo = s, reason = matchReason }
                end
            end
        end

        -- Build tierCfg ready for injection into harvest.
        local labelList = {}
        for label in pairs(matchedLabels) do table.insert(labelList, label) end
        table.sort(labelList)

        local tokenSources = {}
        for _, t in ipairs(allTierTokens) do
            tokenSources[t.itemID] = t.bossIdx
        end

        local tierCfg = {
            labels       = labelList,
            tokenSources = tokenSources,
        }

        -- Build the formatted paste-block (mirror of DumpTransmogSets's
        -- "READY-TO-PASTE" output, minus the raid-side wrapper). This
        -- is what the bundled raidcapture output prepends to the harvest.
        local out = {}
        table.insert(out, "-- DISCOVERED tierSets block (auto-prepended by /rr raidcapture).")
        table.insert(out, "-- Paste this into the raid's data file as the raid's `tierSets = { ... }` block,")
        table.insert(out, "-- replacing any existing tierSets entry. The harvest below already used these")
        table.insert(out, "-- values, so the loot tables include tier rows accordingly.")
        table.insert(out, "tierSets = {")
        table.insert(out, "    labels = {")
        for _, label in ipairs(labelList) do
            local entry = matchedLabels[label]
            local s     = entry.setInfo
            table.insert(out, ("        %q,  -- %s (setID=%d, exp=%s, patch=%s)"):format(
                label, entry.reason, s.setID,
                tostring(s.expansionID), tostring(s.patch)))
        end
        table.insert(out, "    },")
        table.insert(out, "    tokenSources = {")
        if #allTierTokens == 0 then
            table.insert(out, "        -- (no tier tokens found in any boss's loot)")
        else
            -- Sort tokens by group, then slot, then bossIdx for stable readable output
            local sorted = {}
            for _, t in ipairs(allTierTokens) do table.insert(sorted, t) end
            table.sort(sorted, function(a, b)
                if a.group ~= b.group then return a.group < b.group end
                local slotOrder = { Head = 1, Shoulder = 2, Chest = 3, Hands = 4, Legs = 5 }
                local as, bs = slotOrder[a.slot] or 99, slotOrder[b.slot] or 99
                if as ~= bs then return as < bs end
                return a.bossIdx < b.bossIdx
            end)
            for _, t in ipairs(sorted) do
                local bossName = "?"
                for _, b in ipairs(bosses) do
                    if b.index == t.bossIdx then bossName = b.name break end
                end
                table.insert(out, ("        [%d] = %d,  -- %s -> %s"):format(
                    t.itemID, t.bossIdx, t.name, bossName))
            end
        end
        table.insert(out, "    },")
        table.insert(out, "},")
        table.insert(out, "")

        local formattedBlock = table.concat(out, "\n")
        local info = {
            tokenCount = #allTierTokens,
            labelCount = #labelList,
            raidName   = raid.name,
        }

        onDone(tierCfg, formattedBlock, info)
    end

    local function NextBoss()
        bossIdx = bossIdx + 1
        if bossIdx > #bosses then
            FinishAndCallback()
            return
        end
        local boss = bosses[bossIdx]
        if not boss.journalEncounterID then
            C_Timer.After(0, NextBoss)
            return
        end
        CollectEncounterTokens(journalInstanceID, boss.journalEncounterID, 14,
            function(tokens)
                if #tokens > 0 then
                    tokensByBoss[boss.index] = tokens
                end
                C_Timer.After(0.3, NextBoss)
            end)
    end

    -- Prime the EJ before starting (same sequence as DumpTransmogSets).
    EJ_SetDifficulty(14)
    EJ_SelectInstance(journalInstanceID)
    EJ_ResetLootFilter()
    C_Timer.After(0.5, function()
        if bosses[1] and bosses[1].journalEncounterID then
            pcall(EJ_SelectEncounter, bosses[1].journalEncounterID)
        end
        C_Timer.After(0.5, NextBoss)
    end)
end

-------------------------------------------------------------------------------
-- RaidCapture: single-command flow for new-raid bring-up.
--
-- Runs tier-set discovery, validates the result, and harvests using the
-- just-discovered tierCfg in-memory (no data-file edit required mid-flow).
-- The bundled output includes both the tierSets paste-block and the per-
-- boss loot blocks, so one paste covers everything.
--
-- The discovery (DiscoverTierSets) and harvest (RunHarvest) phases were
-- originally exposed as separate /rr tiersets and /rr harvest commands;
-- those were collapsed into this consolidated flow as of v0.7.0 and are
-- no longer user-facing. The implementation functions remain (RaidCapture
-- calls them internally) but are not invocable from chat.
--
-- DATA-QUALITY SAFEGUARD: if discovery returns labels-with-zero-tokens, abort
-- loudly. With tooltip-based slot resolution this is very rare -- it would
-- indicate either a transient tooltip-cache miss across every token (try
-- /reload and re-run; tooltips refresh on UI reload) or a raid that has
-- matching set labels but no actual tier tokens (e.g. seasonal sets that
-- share the raid's name). Proceeding past this case would silently produce
-- a tier-row-less harvest that LOOKS complete.
-- (Zero labels AND zero tokens is a different case: the raid genuinely has
-- no tier set, like Sanctum -- proceed with a one-line warning.)
-------------------------------------------------------------------------------
function RR:RaidCapture()
    if not RR.currentRaid then
        self:Print("No supported raid loaded. Enter a supported raid first.")
        return
    end

    self:Print(("|cffF259C7raidcapture|r starting for: %s"):format(RR.currentRaid.name))
    self:Print("Phase 1/2: discovering tier sets...")

    self:DiscoverTierSets(function(tierCfg, formattedBlock, info)
        if not tierCfg then
            -- DiscoverTierSets already printed the specific error.
            self:Print("|cffff5555raidcapture aborted|r at discovery phase.")
            return
        end

        if info.labelCount > 0 and info.tokenCount == 0 then
            self:Print("|cffff5555raidcapture aborted:|r tier-set labels matched but ZERO tier")
            self:Print("tokens were detected. Most likely cause: a transient tooltip-cache")
            self:Print("miss. Try /reload and re-run -- tooltip data refreshes on UI reload.")
            self:Print("If the issue persists, the raid may have matching set labels but no")
            self:Print("actual tier tokens (a seasonal set sharing the raid's name).")
            return
        end

        if info.labelCount == 0 then
            self:Print("Discovery complete: 0 labels matched, 0 tokens. Harvest will run")
            self:Print("without tier rows. (Raid may genuinely have no tier sets.)")
        else
            self:Print(("Discovery complete: %d label(s), %d tier token(s)."):format(
                info.labelCount, info.tokenCount))
        end

        self:Print("Phase 2/2: harvesting loot tables (this takes a few minutes)...")

        self:HarvestAllBosses(nil, {
            tierCfgOverride = tierCfg,
            onComplete = function(harvestText)
                local combined = formattedBlock .. "\n" .. harvestText
                self:SetSetting("lastHarvestAll", combined)

                self:ShowCopyWindow(
                    "|cffF259C7RETRO|r|cff4DCCFFRUNS|r  |cffaaaaaa/rr raidcapture|r",
                    combined)

                self:Print(("|cff00ff00raidcapture complete!|r %d label(s), %d token(s) discovered;"):format(
                    info.labelCount, info.tokenCount))
                self:Print("loot harvested. Window opened. Click inside, Ctrl+A, Ctrl+C.")
                self:Print("(Also saved to RetroRunsDB.lastHarvestAll -- /rr harvest dump to re-show.)")
            end,
        })
    end)
end

-------------------------------------------------------------------------------
-- Dump to chat
-------------------------------------------------------------------------------

function RR:HarvestDump()
    local data = self:GetSetting("lastHarvestAll") or self:GetSetting("lastHarvest")
    if not data or data == "" then
        self:Print("Nothing to dump. Run /rr harvest first.")
        return
    end
    self:Print("-------------------------------------")
    for line in (data .. "\n"):gmatch("([^\n]*)\n") do
        DEFAULT_CHAT_FRAME:AddMessage("|cffaaaaaa" .. line .. "|r")
    end
    self:Print("-------------------------------------")
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

    local f = CreateFrame("Frame", "RetroRunsCopyFrame", UIParent, "BackdropTemplate")
    f:SetSize(600, 500)
    f:SetPoint("CENTER")
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetClampedToScreen(true)
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop",  f.StopMovingOrSizing)
    f:SetFrameStrata("DIALOG")
    f:SetBackdrop({
        bgFile   = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    f:SetBackdropColor(0.05, 0.05, 0.05, 0.95)

    f.title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f.title:SetPoint("TOPLEFT", 12, -10)

    local closeBtn = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", -4, -4)
    closeBtn:SetScript("OnClick", function() f:Hide() end)

    local hint = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    hint:SetPoint("TOPLEFT", 12, -28)
    hint:SetText("Click inside the box, press Ctrl+A to select all, then Ctrl+C to copy.")

    local selBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    selBtn:SetSize(90, 22)
    selBtn:SetPoint("TOPRIGHT", -36, -24)
    selBtn:SetText("Select All")

    local scrollFrame = CreateFrame("ScrollFrame", nil, f, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 10, -48)
    scrollFrame:SetPoint("BOTTOMRIGHT", -30, 10)

    local editBox = CreateFrame("EditBox", nil, scrollFrame)
    editBox:SetMultiLine(true)
    editBox:SetMaxLetters(0)
    editBox:SetAutoFocus(false)
    editBox:SetFontObject(GameFontHighlightSmall)
    editBox:SetWidth(scrollFrame:GetWidth())
    editBox:SetScript("OnEscapePressed", function() f:Hide() end)
    scrollFrame:SetScrollChild(editBox)

    selBtn:SetScript("OnClick", function()
        editBox:SetFocus()
        editBox:HighlightText()
    end)

    f.editBox = editBox
    f:Hide()
    return f
end

-- Public helper usable from any module. Pass any title + any body text.
function RR:ShowCopyWindow(title, text)
    local win = GetOrCreateCopyWindow()
    win.title:SetText(title or "|cffF259C7RETRO|r|cff4DCCFFRUNS|r  |cffaaaaaaDebug Output|r")
    win.editBox:SetText(text or "")
    win.editBox:SetCursorPosition(0)
    win:Show()
end

function RR:HarvestShowWindow()
    local data = self:GetSetting("lastHarvestAll") or self:GetSetting("lastHarvest")
    if not data or data == "" then
        self:Print("Nothing to show. Run /rr harvest first.")
        return
    end
    self:ShowCopyWindow(
        "|cffF259C7RETRO|r|cff4DCCFFRUNS|r  |cffaaaaaaHarvest Output|r",
        data)
    self:Print("Harvest window opened. Click inside, Ctrl+A, Ctrl+C.")
end

-------------------------------------------------------------------------------
-- Weapon-token appearance-pool harvester (Castle Nathria)
--
-- Castle Nathria's weapon tokens (Anima Spherules, Anima Beads) redeem into
-- a covenant-themed weapon at the Covenant Sanctum weaponsmith. The game
-- doesn't treat these as Blizzard ensembles (C_Item.GetItemLearnTransmogSet
-- returns nil), so there's no native way to query "what appearances does
-- this token unlock." The TokenTransmogTooltips addon (MIT-licensed, by
-- Relicthus) maintains the authoritative itemID list: 102 weapon itemIDs
-- across 8 pools (lower/higher ilvl, non-mythic/mythic, MH/OH).
--
-- We don't ship TTT's static appearanceID/sourceID data. Instead we ship
-- the itemID list (a lookup key that's public Blizzard data) and harvest
-- the (appearanceID, sourceID) mapping ourselves at runtime via
-- C_TransmogCollection.GetItemInfo -- same API TTT's own DataGenerator
-- uses. This is data derivation, not data import.
--
-- Output format matches TTT's conceptual shape: [appearanceID] = {sourceID,
-- sourceID, ...}, suitable for counting "X of N appearances collected" by
-- checking C_TransmogCollection.PlayerHasTransmogItemModifiedAppearance on
-- any source in the list and GetAppearanceInfoBySource(source).
-- appearanceIsCollected for the global-collection ceiling.
--
-- Attribution: the seed itemID lists below were extracted from
-- TokenTransmogTooltips/Raids/CastleNathria/tokens.lua (Wowhead URL
-- comments embedded next to each appearanceID key). Re-verify/extend by
-- consulting the upstream file if future CN content patches add
-- appearances.
-------------------------------------------------------------------------------

-- Seed itemID lists per pool. Sourced from TokenTransmogTooltips (see
-- attribution block above). Do not hand-edit without cross-reference.
local CN_WEAPON_SEED = {
    LOWER_NM_MH = {
        174298, 175251, 175279, 176098, 177850, 178973, 179497, 179527,
        179544, 179557, 179577, 180000, 180023, 180073, 180260, 180312,
        182351, 182414, 182415, 182416, 182417, 182418, 182419, 182420,
        182421, 182422, 182423, 182424, 184230, 184236, 184244, 184247,
        184248, 184249, 184250, 184251, 184252, 184253, 184254, 184255,
        184272, 184273, 184275,
    },
    HIGHER_NM_MH = {
        174302, 177849, 177855, 177860, 177865, 177872, 178975, 179492,
        179530, 179541, 179561, 179579, 180002, 180022, 180071, 180258,
        180315, 182388, 182389, 182390, 182391, 182392, 182393, 182394,
        182395, 182396, 182397, 182398, 184241, 184243, 184256, 184259,
        184260, 184261, 184262, 184263, 184264, 184265, 184266, 184267,
        184270, 184271, 184274,
    },
    LOWER_M_MH = {
        174298, 175251, 175279, 176098, 177850, 178973, 179497, 179527,
        179544, 179557, 179577, 180000, 180023, 180073, 180260, 180312,
        182351, 182414, 182415, 182416, 182417, 182418, 182419, 182420,
        182421, 182422, 182423, 182424, 184230, 184236, 184244, 184247,
        184248, 184249, 184250, 184251, 184253, 184254, 184255, 184272,
        184273,
    },
    HIGHER_M_MH = {
        174302, 177849, 177855, 177860, 177865, 177872, 178975, 179492,
        179530, 179541, 179561, 179579, 180002, 180022, 180071, 180258,
        180315, 182388, 182389, 182390, 182391, 182392, 182393, 182394,
        182395, 182396, 182397, 182398, 184241, 184243, 184256, 184259,
        184260, 184261, 184262, 184263, 184264, 184265, 184266, 184267,
        184270, 184271, 184274, 184275,
    },
    LOWER_NM_OH = {
        174310, 175254, 179570, 179610, 182425, 182426, 184245, 184246,
    },
    HIGHER_NM_OH = {
        174315, 177870, 179566, 179611, 182399, 182400, 184257, 184258,
    },
    LOWER_M_OH = {
        174310, 175254, 179570, 179610, 182425, 182426, 184245, 184246,
    },
    HIGHER_M_OH = {
        174315, 177870, 179566, 179611, 182399, 182400, 184257, 184258,
    },
}

-- Harvest pool data: walk each pool's itemID list, resolve (appearanceID,
-- sourceID) via C_TransmogCollection.GetItemInfo, group sourceIDs under
-- their appearanceID. Emits a ready-to-paste `weaponTokenPools` block.
--
-- Cache-warm phase first: GetItemInfo is async on cold cache. We call it
-- on every itemID up front, wait 1.5s for loads to settle (same pattern
-- used by CollectTierSets), then run the synchronous harvest body.
function RR:HarvestWeaponPools()
    if not C_TransmogCollection or not C_TransmogCollection.GetItemInfo then
        self:Print("C_TransmogCollection.GetItemInfo unavailable.")
        return
    end

    -- Collect unique itemIDs across all pools for cache-warming.
    local allItems = {}
    local seen = {}
    for _, pool in pairs(CN_WEAPON_SEED) do
        for _, iid in ipairs(pool) do
            if not seen[iid] then
                seen[iid] = true
                table.insert(allItems, iid)
            end
        end
    end
    self:Print(("Warming GetItemInfo cache for %d unique weapon itemIDs..."):format(#allItems))
    for _, iid in ipairs(allItems) do
        GetItemInfo(iid)
    end

    C_Timer.After(1.5, function()
        RR:HarvestWeaponPools_Build()
    end)
end

function RR:HarvestWeaponPools_Build()
    -- Pool emission order (keeps output stable across runs).
    local POOL_ORDER = {
        "LOWER_NM_MH",  "HIGHER_NM_MH",  "LOWER_M_MH",  "HIGHER_M_MH",
        "LOWER_NM_OH",  "HIGHER_NM_OH",  "LOWER_M_OH",  "HIGHER_M_OH",
    }
    -- Human-readable Lua-table names for the output block.
    local POOL_OUTPUT_NAME = {
        LOWER_NM_MH  = "mainHandLowerNonMythic",
        HIGHER_NM_MH = "mainHandHigherNonMythic",
        LOWER_M_MH   = "mainHandLowerMythic",
        HIGHER_M_MH  = "mainHandHigherMythic",
        LOWER_NM_OH  = "offHandLowerNonMythic",
        HIGHER_NM_OH = "offHandHigherNonMythic",
        LOWER_M_OH   = "offHandLowerMythic",
        HIGHER_M_OH  = "offHandHigherMythic",
    }

    local out = {}
    local missing = {}     -- { {pool, itemID}, ... } for items that didn't resolve
    local resolved = 0
    local nilReturns = 0

    table.insert(out, "-- Castle Nathria weapon-token appearance pools.")
    table.insert(out, "-- Harvested via /rr weaponharvest; see attribution in Harvester.lua.")
    table.insert(out, "--")
    table.insert(out, "-- Schema: [appearanceID] = { sourceID, sourceID, ... }. An appearance is")
    table.insert(out, "-- considered collected if any listed sourceID is owned OR if")
    table.insert(out, "-- C_TransmogCollection.GetAppearanceInfoBySource(sourceID).appearanceIsCollected")
    table.insert(out, "-- returns true for any source (the global cross-source check).")
    table.insert(out, "weaponTokenPools = {")

    for _, poolKey in ipairs(POOL_ORDER) do
        local itemList = CN_WEAPON_SEED[poolKey]
        -- appearanceID -> { sourceID, sourceID, ... }  (dedup within pool)
        local byAppID = {}
        local orderOfApps = {}
        for _, iid in ipairs(itemList) do
            local appID, srcID = C_TransmogCollection.GetItemInfo(iid)
            if appID and srcID then
                if not byAppID[appID] then
                    byAppID[appID] = {}
                    table.insert(orderOfApps, appID)
                end
                -- Dedup sourceID within appearance bucket
                local dup = false
                for _, existing in ipairs(byAppID[appID]) do
                    if existing == srcID then dup = true; break end
                end
                if not dup then
                    table.insert(byAppID[appID], srcID)
                end
                resolved = resolved + 1
            else
                nilReturns = nilReturns + 1
                table.insert(missing, { pool = poolKey, itemID = iid })
            end
        end

        -- Emit the pool block.
        table.insert(out, ("    %s = {"):format(POOL_OUTPUT_NAME[poolKey]))
        table.sort(orderOfApps)
        for _, appID in ipairs(orderOfApps) do
            local srcs = byAppID[appID]
            table.sort(srcs)
            table.insert(out, ("        [%d] = { %s },"):format(
                appID, table.concat(srcs, ", ")))
        end
        table.insert(out, ("    },   -- %d appearances, %d sources"):format(
            #orderOfApps, resolved))  -- (resolved is cumulative-across-pools, fine for a post-hoc emit)
        -- Reset resolved for each pool? Actually no; the comment is approximate
        -- and the exact per-pool count isn't critical for paste-back.
    end

    table.insert(out, "},")

    -- Audit section: items that didn't resolve (cache-cold, class-restricted, etc.).
    table.insert(out, "")
    table.insert(out, "-- ============================================================")
    table.insert(out, ("-- Audit: %d resolved, %d failed to resolve."):format(resolved, nilReturns))
    if #missing > 0 then
        table.insert(out, "-- Items that returned nil from C_TransmogCollection.GetItemInfo:")
        for _, m in ipairs(missing) do
            table.insert(out, ("--   %s / itemID=%d"):format(m.pool, m.itemID))
        end
        table.insert(out, "-- (Likely causes: class-restricted on current character -- retry on an")
        table.insert(out, "--  alt with broader armor-type coverage -- or item not in client cache.)")
    end

    self:ShowCopyWindow(
        "|cffF259C7RETRO|r|cff4DCCFFRUNS|r  |cffaaaaaaWeapon Pool Harvest|r",
        table.concat(out, "\n"))
    self:Print(("Weapon pool harvest complete. %d resolved, %d nil. Window opened."):format(
        resolved, nilReturns))
end

-------------------------------------------------------------------------------
-- Merchant-frame scanner.
--
-- When the player right-clicks a Castle Nathria spherule in their bag, or
-- walks up to a Covenant Sanctum weaponsmith, a standard Blizzard merchant
-- frame opens. Blizzard's merchant API exposes the offered items + their
-- costs, so we can inventory exactly which items each spherule type
-- redeems for -- the authoritative answer to whether CN's MH token pool
-- is shared across families (TokenTransmogTooltips' model) or family-
-- restricted (Wowpedia's per-vendor attributions suggest this).
--
-- Usage: walk up to a CN weaponsmith (or right-click a spherule); the
-- merchant window opens; run `/rr vendorscan`. Output lists every item
-- offered, grouped by the spherule-itemID required to buy it.
--
-- WoW merchant API (from experience + Wowpedia):
--   GetMerchantNumItems()                      -> count of items offered
--   GetMerchantItemLink(i)                     -> itemLink for item i
--   GetMerchantItemInfo(i)                     -> (name, texture, price,
--                                                  quantity, numAvailable,
--                                                  isPurchasable, isUsable,
--                                                  extendedCost)
--   GetMerchantItemCostInfo(i)                 -> number of cost items
--   GetMerchantItemCostItem(i, costIndex)      -> (itemTexture, itemValue,
--                                                  itemLink, currencyName)
--
-- The itemLink from GetMerchantItemCostItem carries the cost-item's
-- itemID, which is the spherule. We parse it and use it as the grouping
-- key in our output.
--
-- Note: the merchant frame must be OPEN when this runs. `MERCHANT_CLOSED`
-- fires and the API returns empty when it's closed. The command prints
-- a clear error if so.
-------------------------------------------------------------------------------

-- Parse an itemID out of an item link like "|cff...|Hitem:183892::...:|h[name]|h|r".
local function ExtractItemIDFromLink(link)
    if not link or link == "" then return nil end
    local idStr = link:match("|Hitem:(%d+)") or link:match("item:(%d+)")
    return idStr and tonumber(idStr) or nil
end

function RR:ScanMerchantFrame()
    -- Detect whether a merchant frame is currently open. Blizzard's global
    -- `MerchantFrame` is the standard one; most vendors use it. A few
    -- tradeskill-ish merchants use a custom frame, but CN weaponsmiths
    -- are plain merchants.
    if not MerchantFrame or not MerchantFrame:IsShown() then
        self:Print("No merchant frame open. Walk up to a vendor and right-click them, or right-click the spherule in your bag, then run this again.")
        return
    end

    local count = GetMerchantNumItems and GetMerchantNumItems() or 0
    if count == 0 then
        self:Print("Merchant frame is open but GetMerchantNumItems() returned 0. The merchant may be loading -- try again in a second.")
        return
    end

    -- Group offered items by their cost-spherule itemID. If an item has no
    -- extended cost (costs only gold) we bucket it under the synthetic key
    -- "gold". Most CN weaponsmith offerings will be spherule-costed; the
    -- "gold" bucket exists to catch oddities.
    local byCost = {}       -- costItemID -> { {link, itemID, costQty}, ... }
    local costOrder = {}    -- stable insertion order for display
    local seenCost = {}

    for i = 1, count do
        local link = GetMerchantItemLink and GetMerchantItemLink(i) or nil
        local itemID = ExtractItemIDFromLink(link)
        local name, _, price, quantity, numAvailable, isPurchasable, isUsable, extendedCost
        if GetMerchantItemInfo then
            name, _, price, quantity, numAvailable, isPurchasable, isUsable, extendedCost =
                GetMerchantItemInfo(i)
        end

        -- Resolve the cost. Prefer extended-cost items (currency/spherule);
        -- fall back to gold-only if there's no extended cost.
        local costKey, costKeyLabel
        local costQty
        if extendedCost and GetMerchantItemCostInfo and GetMerchantItemCostItem then
            local numCosts = GetMerchantItemCostInfo(i) or 0
            -- If multiple cost components exist (e.g. spherule + gold),
            -- use the first non-gold component as the grouping key.
            -- The merchant API doesn't distinguish currencies vs items
            -- reliably pre-retail; we rely on the cost-link returning
            -- an item link pattern.
            for ci = 1, numCosts do
                local _, itemValue, itemLink, currencyName = GetMerchantItemCostItem(i, ci)
                local costID = ExtractItemIDFromLink(itemLink)
                if costID then
                    costKey = costID
                    costKeyLabel = itemLink
                    costQty = itemValue
                    break
                elseif currencyName and currencyName ~= "" then
                    -- Currency (not an item) -- use its name as key.
                    costKey = "currency:" .. currencyName
                    costKeyLabel = currencyName
                    costQty = itemValue
                    break
                end
            end
        end
        if not costKey then
            costKey = "gold"
            costKeyLabel = (price and price > 0) and
                ("gold (%d copper)"):format(price) or "gold (0?)"
            costQty = price or 0
        end

        if not seenCost[costKey] then
            seenCost[costKey] = true
            table.insert(costOrder, costKey)
            byCost[costKey] = {
                label = costKeyLabel,
                items = {},
            }
        end
        table.insert(byCost[costKey].items, {
            merchantIndex = i,
            itemID        = itemID,
            link          = link,
            name          = name,
            costQty       = costQty,
            isUsable      = isUsable,
        })
    end

    -- Merchant identity. MerchantFrameTitleText is the standard header;
    -- its text is the NPC's name. Fall back to UnitName("target") if the
    -- player is targeting them.
    local merchantName = "(unknown)"
    if MerchantFrameTitleText and MerchantFrameTitleText:GetText() then
        merchantName = MerchantFrameTitleText:GetText()
    elseif UnitName("npc") then
        merchantName = UnitName("npc")
    elseif UnitName("target") then
        merchantName = UnitName("target")
    end

    -- Player context (class + covenant, since both affect what the vendor
    -- shows). Covenant lookup is via C_Covenants if available.
    local _, classToken, classID = UnitClass("player")
    local covenantName = "(none/unknown)"
    if C_Covenants and C_Covenants.GetActiveCovenantID and C_Covenants.GetCovenantData then
        local covID = C_Covenants.GetActiveCovenantID()
        if covID and covID > 0 then
            local covData = C_Covenants.GetCovenantData(covID)
            if covData and covData.name then covenantName = covData.name end
        end
    end

    -- Emit.
    local out = {}
    table.insert(out, "-- RetroRuns vendorscan")
    table.insert(out, ("-- Merchant: %s"):format(merchantName))
    table.insert(out, ("-- Player:   %s (classID %d, covenant %s)"):format(
        tostring(classToken or "?"), classID or 0, covenantName))
    table.insert(out, ("-- Merchant item count: %d"):format(count))
    table.insert(out, ("-- Cost groups: %d"):format(#costOrder))
    table.insert(out, "")

    for _, costKey in ipairs(costOrder) do
        local bucket = byCost[costKey]
        table.insert(out, ("=== Cost: %s   (%d items offered for this cost)"):format(
            tostring(bucket.label), #bucket.items))
        -- Sort items by itemID for reproducibility across runs.
        table.sort(bucket.items, function(a, b)
            return (a.itemID or 0) < (b.itemID or 0)
        end)
        for _, it in ipairs(bucket.items) do
            local nm = it.name or "(nil name)"
            local usable = it.isUsable and "usable" or "not-usable"
            table.insert(out, ("    [%d]  itemID=%s  %s  (%s)"):format(
                it.merchantIndex, tostring(it.itemID or "?"), nm, usable))
            if it.link then
                table.insert(out, ("          link: %s"):format(it.link))
            end
        end
        table.insert(out, "")
    end

    self:ShowCopyWindow(
        "|cffF259C7RETRO|r|cff4DCCFFRUNS|r  |cffaaaaaaVendor Scan|r",
        table.concat(out, "\n"))
    self:Print(("Vendor scan: %d items across %d cost group(s). Window opened."):format(
        count, #costOrder))
end
