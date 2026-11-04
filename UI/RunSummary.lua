-------------------------------------------------------------------------------
-- RetroRuns -- RunSummary.lua
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
-- The End of Run Summary: what the finished run earned and what is left,
-- drawn in the main panel under the exit note.
-------------------------------------------------------------------------------

local RR = RetroRuns
local UI = RR.UI
local panel = RetroRunsMainFrame

local LABEL_HEX, VALUE_HEX, GREEN_HEX = "4DCCFF", "ffd100", "00ff00"
local GRAY_HEX, PINK_HEX = "9d9d9d", "f259c7"
local BAR_FILL = { 0.15, 0.72, 0.85 }
local BAR_BACK = { 0.08, 0.09, 0.15 }
local BAR_EDGE = { 0.88, 0.36, 0.78 }
local GRID_EDGE = { 0.42, 0.42, 0.50 }
local RULE_COLOR = { 0.95, 0.35, 0.78, 0.6 }
local ARROW = "|TInterface\\AddOns\\RetroRuns\\Media\\Icons\\TriRight:10:10|t"
local ICON_PATH = "Interface\\AddOns\\RetroRuns\\Media\\Icons\\"
-- Section contents start right of the section icons' column.
local CONTENT_X, SUB_INDENT = 24, 12
local LINE_GAP, SECTION_GAP = 3, 12
local SECTION_ICON, ROW_ICON, REP_MARK = 18, 16, 14
local NAMES_MAX, ICONS_PER_ROW, ICON_ROWS = 5, 10, 2
local ICON_SIZE, ICON_GAP = 22, 4
local BAR_WIDTH, BAR_HEIGHT, GAIN_WIDTH = 110, 14, 54
-- Values right-align to one column: the reputation gains', left of the bars.
local VALUE_INSET = BAR_WIDTH + 6
local SPECIALS_MAX = 8
-- Each section's icon, in the footer buttons' framed style.
local SECTION_ICONS = {
    runStats    = "StopwatchIcon",
    reputation  = "HeartIcon",
    appearances = "HangerIcon",
    specialLoot = "StarIcon",
}

local block = CreateFrame("Frame", nil, panel)
block:Hide()
local texts, hits, bars, icons, rules, marks = {}, {}, {}, {}, {}, {}
local used = { texts = 0, hits = 0, bars = 0, icons = 0, rules = 0, marks = 0 }
local cursor = 0
local reloadPending = false

local function FontSize()
    return RR:GetSetting("fontSize", 12)
end

local function Color(hex, text)
    return ("|cff%s%s|r"):format(hex, text)
end

local function AcquireText()
    used.texts = used.texts + 1
    local fs = texts[used.texts]
    if not fs then
        fs = block:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        fs:SetJustifyH("LEFT")
        texts[used.texts] = fs
    end
    UI.SetBodyFont(fs, FontSize(), "")
    fs:SetTextColor(1, 1, 1)
    fs:SetJustifyH("LEFT")
    fs:SetWordWrap(true)
    fs:ClearAllPoints()
    fs:Show()
    return fs
end

-- An invisible frame over a region that shows a tooltip on hover.
local function AddHover(region, width, height, fill)
    used.hits = used.hits + 1
    local hit = hits[used.hits]
    if not hit then
        hit = CreateFrame("Frame", nil, block)
        hit:EnableMouse(true)
        hit:SetScript("OnLeave", GameTooltip_Hide)
        hits[used.hits] = hit
    end
    hit:ClearAllPoints()
    hit:SetPoint("TOPLEFT", region, "TOPLEFT")
    hit:SetSize(math.max(1, width), math.max(1, height))
    hit:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        fill(GameTooltip)
        GameTooltip:Show()
    end)
    hit:Show()
    return hit
end

-- A plain texture from the pool: section icons and item icons.
local function AcquireMark(size)
    used.marks = used.marks + 1
    local mark = marks[used.marks]
    if not mark then
        mark = block:CreateTexture(nil, "ARTWORK")
        marks[used.marks] = mark
    end
    mark:SetTexCoord(0, 1, 0, 1)
    mark:SetVertexColor(1, 1, 1)
    mark:SetSize(size, size)
    mark:ClearAllPoints()
    mark:Show()
    return mark
end

-- One line of text at the cursor, in the content column unless told
-- otherwise; returns its FontString.
local function AddLine(text, indent, width, fontSize)
    local fs = AcquireText()
    if fontSize then UI.SetBodyFont(fs, fontSize, "") end
    indent = indent or CONTENT_X
    fs:SetPoint("TOPLEFT", block, "TOPLEFT", indent, cursor)
    fs:SetWidth(width or (UI.BODY_WIDTH - indent))
    fs:SetText(text)
    cursor = cursor - math.ceil(fs:GetStringHeight()) - LINE_GAP
    return fs
end

-- A label and its value, the value right-aligned to the content's edge;
-- returns the label so a hover can cover the row.
local function AddPair(label, value)
    local labelText = AcquireText()
    labelText:SetPoint("TOPLEFT", block, "TOPLEFT", CONTENT_X, cursor)
    labelText:SetWidth(0)
    labelText:SetWordWrap(false)
    labelText:SetText(label)
    local valueText = AcquireText()
    valueText:SetPoint("TOPRIGHT", block, "TOPLEFT", UI.BODY_WIDTH - VALUE_INSET, cursor)
    valueText:SetWidth(0)
    valueText:SetWordWrap(false)
    valueText:SetJustifyH("RIGHT")
    valueText:SetText(value)
    cursor = cursor - math.ceil(math.max(labelText:GetStringHeight(), valueText:GetStringHeight()))
        - LINE_GAP
    return labelText
end

-- An item's icon, then its name; returns the name's FontString.
local function AddItemRow(iconTexture, text)
    local mark = AcquireMark(ROW_ICON)
    mark:SetTexture(iconTexture or 134400)
    mark:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    local fs = AcquireText()
    fs:SetPoint("TOPLEFT", block, "TOPLEFT", CONTENT_X + ROW_ICON + 6, cursor)
    fs:SetWidth(UI.BODY_WIDTH - CONTENT_X - ROW_ICON - 6)
    fs:SetText(text)
    local height = math.max(ROW_ICON, math.ceil(fs:GetStringHeight()))
    mark:SetPoint("LEFT", fs, "LEFT", -(ROW_ICON + 6), 0)
    cursor = cursor - height - LINE_GAP
    return fs
end

local function AddSection(title, iconKey)
    if cursor < 0 then cursor = cursor - SECTION_GAP + LINE_GAP end
    local fs = AcquireText()
    UI.SetBodyFont(fs, FontSize() + 1, "")
    fs:SetPoint("TOPLEFT", block, "TOPLEFT", CONTENT_X, cursor)
    fs:SetWidth(0)
    fs:SetWordWrap(false)
    fs:SetText(Color(LABEL_HEX, title))
    local iconName = iconKey and SECTION_ICONS[iconKey]
    if iconName then
        local mark = AcquireMark(SECTION_ICON)
        mark:SetTexture(ICON_PATH .. iconName)
        mark:SetPoint("RIGHT", fs, "LEFT", -6, 0)
    end
    used.rules = used.rules + 1
    local rule = rules[used.rules]
    if not rule then
        rule = block:CreateTexture(nil, "ARTWORK")
        rule:SetColorTexture(RULE_COLOR[1], RULE_COLOR[2], RULE_COLOR[3], RULE_COLOR[4])
        rule:SetHeight(1)
        rules[used.rules] = rule
    end
    rule:ClearAllPoints()
    rule:SetPoint("LEFT", fs, "RIGHT", 6, 0)
    rule:SetWidth(math.max(1, UI.BODY_WIDTH - CONTENT_X - fs:GetStringWidth() - 6))
    rule:Show()
    local height = math.max(iconName and SECTION_ICON or 0, math.ceil(fs:GetStringHeight()))
    cursor = cursor - height - LINE_GAP - 1
    return fs
end

local function AcquireBar()
    used.bars = used.bars + 1
    local bar = bars[used.bars]
    if not bar then
        bar = CreateFrame("Frame", nil, block)
        bar.edge = bar:CreateTexture(nil, "BACKGROUND")
        bar.edge:SetAllPoints()
        bar.edge:SetColorTexture(BAR_EDGE[1], BAR_EDGE[2], BAR_EDGE[3], 1)
        bar.back = bar:CreateTexture(nil, "BORDER")
        bar.back:SetPoint("TOPLEFT", 1, -1)
        bar.back:SetPoint("BOTTOMRIGHT", -1, 1)
        bar.back:SetColorTexture(BAR_BACK[1], BAR_BACK[2], BAR_BACK[3], 1)
        bar.fill = bar:CreateTexture(nil, "ARTWORK")
        bar.fill:SetPoint("TOPLEFT", 1, -1)
        bar.fill:SetPoint("BOTTOMLEFT", 1, 1)
        bar.fill:SetColorTexture(BAR_FILL[1], BAR_FILL[2], BAR_FILL[3], 1)
        bar.label = bar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        bar.label:SetPoint("CENTER", 0, 0)
        bars[used.bars] = bar
    end
    UI.SetBodyFont(bar.label, math.max(8, FontSize() - 3), "")
    bar.label:SetTextColor(1, 1, 1)
    bar:SetSize(BAR_WIDTH, BAR_HEIGHT)
    bar:Show()
    return bar
end

local function AcquireIcon()
    used.icons = used.icons + 1
    local icon = icons[used.icons]
    if not icon then
        icon = CreateFrame("Frame", nil, block)
        icon:EnableMouse(true)
        icon:SetScript("OnLeave", GameTooltip_Hide)
        icon.edge = icon:CreateTexture(nil, "BACKGROUND")
        icon.edge:SetAllPoints()
        icon.art = icon:CreateTexture(nil, "ARTWORK")
        icon.art:SetPoint("TOPLEFT", 1, -1)
        icon.art:SetPoint("BOTTOMRIGHT", -1, 1)
        icon.art:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        icon.more = icon:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        icon.more:SetPoint("CENTER", 0, 0)
        icons[used.icons] = icon
    end
    icon:SetSize(ICON_SIZE, ICON_SIZE)
    icon.more:SetText("")
    icon:Show()
    return icon
end

local function QualityColor(quality)
    local r, g, b = 1, 1, 1
    if C_Item and C_Item.GetItemQualityColor and quality then
        r, g, b = C_Item.GetItemQualityColor(quality)
    end
    return r or 1, g or 1, b or 1
end

local function QualityText(quality, text)
    local r, g, b = QualityColor(quality)
    return ("|cff%02x%02x%02x%s|r"):format(r * 255, g * 255, b * 255, text)
end

-- Item names arrive late on a cold cache; one repaint picks them up.
local function RepaintSoon()
    if reloadPending then return end
    reloadPending = true
    C_Timer.After(0.5, function()
        reloadPending = false
        if block:IsShown() then UI.Update() end
    end)
end

-------------------------------------------------------------------------------
-- Run Stats
-------------------------------------------------------------------------------

local function RenderRunStats(raid, record)
    AddSection(RR.L["Run Stats"], "runStats")
    local rowWidth = UI.BODY_WIDTH - CONTENT_X
    if record and record.startedAt and record.completedAt then
        local seconds = math.max(0, record.completedAt - record.startedAt)
        AddPair(RR.L["Run Length:"], Color(VALUE_HEX, SecondsToTime(seconds, false, false, 2)))
    end

    -- The account's fastest clear here: green when this run set it, with the
    -- holder named when it is another character.
    local best = RR.RunHistory and RR.RunHistory.BestTime(raid,
        record and record.difficultyID or RR.state.currentDifficultyID)
    if best then
        local value = Color((best.mine and record and record.newBest) and GREEN_HEX or VALUE_HEX,
            SecondsToTime(best.seconds, false, false, 2))
        if not best.mine then
            local color = best.class and RAID_CLASS_COLORS and RAID_CLASS_COLORS[best.class]
            local name = color and color:WrapTextInColorCode(best.name) or best.name
            value = value .. " " .. Color(GRAY_HEX, "(") .. name .. Color(GRAY_HEX, ")")
        end
        AddPair(RR.L["Best Time:"], value)
    end

    local bucket = RR:FoldDifficulty(raid, RR.state.currentDifficultyID)
    local counts = RR:GetPerDifficultyKillCountsForRaid(raid)
    local count = bucket and counts and counts[bucket]
    if count and count.total and count.total > 0 then
        local hex = (count.complete >= count.total) and GREEN_HEX or VALUE_HEX
        local fs = AddPair(RR.L["Bosses Defeated:"],
            Color(hex, ("%d/%d"):format(count.complete, count.total)))
        local skipped = {}
        for _, boss in ipairs(raid.bosses or {}) do
            if RR:BossReachableHere(boss.index) and not RR:IsBossKilled(boss.index) then
                skipped[#skipped + 1] = RR:GetLocalizedBossName(boss) or boss.name
            end
        end
        if #skipped > 0 then
            AddHover(fs, rowWidth, fs:GetStringHeight(), function(tip)
                GameTooltip_SetTitle(tip, RR.L["Skipped:"])
                for _, name in ipairs(skipped) do GameTooltip_AddNormalLine(tip, name) end
            end)
        end
    end

    if record and record.gold then
        local value = record.gold > 0 and Color(VALUE_HEX, GetMoneyString(record.gold, true))
            or Color(GRAY_HEX, RR.L["None"])
        AddPair(RR.L["Gold Looted:"], value)
    end
end

-------------------------------------------------------------------------------
-- Reputation Gained
-------------------------------------------------------------------------------

-- Where each standing begins, Hated through Exalted.
local REACTION_FLOORS = { -42000, -6000, -3000, 0, 3000, 9000, 21000, 42000 }

local function StandingLabel(reaction, sex)
    return GetText("FACTION_STANDING_LABEL" .. tostring(reaction), sex or UnitSex("player"))
        or tostring(reaction)
end

-- The standing label for a raw reputation value.
local function LabelForStanding(standing, sex)
    local reaction = 1
    for index, threshold in ipairs(REACTION_FLOORS) do
        if standing >= threshold then reaction = index end
    end
    return StandingLabel(reaction, sex)
end

-- Label, progress into the current standing, its span, and the label
-- before this run's gain when the gain crossed into it.
local function Standing(factionID, data, gained)
    if C_GossipInfo and C_GossipInfo.GetFriendshipReputation then
        local friend = C_GossipInfo.GetFriendshipReputation(factionID)
        if friend and friend.friendshipFactionID and friend.friendshipFactionID > 0 then
            local low = friend.reactionThreshold or 0
            local high = friend.nextThreshold
            local into = (friend.standing or 0) - low
            return friend.reaction or "", into, high and (high - low) or into
        end
    end
    local label = StandingLabel(data.reaction)
    if C_Reputation.IsFactionParagon and C_Reputation.IsFactionParagon(factionID) then
        local value, threshold = C_Reputation.GetFactionParagonInfo(factionID)
        if value and threshold and threshold > 0 then
            return label, value % threshold, threshold
        end
    end
    local low, high = data.currentReactionThreshold or 0, data.nextReactionThreshold or 0
    local into, span = (data.currentStanding or 0) - low, high - low
    local before
    if gained > 0 and (data.currentStanding or 0) - gained < low and (data.reaction or 1) > 1 then
        before = StandingLabel(data.reaction - 1)
    end
    if span <= 0 then return label, 1, 1, before end
    return label, into, span, before
end

-- The character's name in its class color.
local function CharacterName()
    local name = UnitName("player") or "?"
    local _, classToken = UnitClass("player")
    local color = classToken and RAID_CLASS_COLORS and RAID_CLASS_COLORS[classToken]
    return color and color:WrapTextInColorCode(name) or name
end

-- Each row opens with its scope: the game's Warband crest for an
-- account-wide faction, the silhouette in the class color for this
-- character's own.
local function AddReputationRow(row)
    local mark = AcquireMark(REP_MARK)
    if row.accountWide then
        mark:SetAtlas("warbands-icon")
    else
        mark:SetTexture(ICON_PATH .. "PersonIcon")
        local _, classToken = UnitClass("player")
        local color = classToken and RAID_CLASS_COLORS and RAID_CLASS_COLORS[classToken]
        if color then mark:SetVertexColor(color.r, color.g, color.b) end
    end
    mark:SetSize(REP_MARK, REP_MARK)
    local nameX = CONTENT_X + REP_MARK + 6
    local nameText = AcquireText()
    nameText:SetPoint("TOPLEFT", block, "TOPLEFT", nameX, cursor)
    nameText:SetWidth(UI.BODY_WIDTH - nameX - BAR_WIDTH - GAIN_WIDTH - 8)
    nameText:SetWordWrap(false)
    nameText:SetText(row.name)
    mark:SetPoint("RIGHT", nameText, "LEFT", -6, 0)

    local gainText = AcquireText()
    gainText:SetPoint("TOPRIGHT", block, "TOPLEFT", UI.BODY_WIDTH - VALUE_INSET, cursor)
    gainText:SetWidth(GAIN_WIDTH)
    gainText:SetJustifyH("RIGHT")
    gainText:SetWordWrap(false)
    local sign = row.amount >= 0 and "+" or ""
    gainText:SetText(Color(row.amount >= 0 and GREEN_HEX or "ff4040",
        sign .. BreakUpLargeNumbers(row.amount)))

    local lineHeight = math.ceil(nameText:GetStringHeight())
    local label, into, span, before
    if row.data then
        local bar = AcquireBar()
        label, into, span, before = Standing(row.factionID, row.data, row.amount)
        bar:SetPoint("TOPRIGHT", block, "TOPLEFT", UI.BODY_WIDTH,
            cursor - math.floor((lineHeight - BAR_HEIGHT) / 2))
        local fraction = (span and span > 0) and math.min(1, math.max(0, into / span)) or 1
        bar.fill:SetWidth(math.max(0.01, (BAR_WIDTH - 2) * fraction))
        bar.fill:SetShown(fraction > 0)
        bar.label:SetText(before and Color(GREEN_HEX, label) or label)
    end
    AddHover(mark, UI.BODY_WIDTH - CONTENT_X, lineHeight, function(tip)
        GameTooltip_SetTitle(tip, row.name)
        if row.accountWide then
            GameTooltip_AddNormalLine(tip, REPUTATION_TOOLTIP_ACCOUNT_WIDE_LABEL
                or REPUTATION_SORT_TYPE_ACCOUNT or "")
        else
            GameTooltip_AddNormalLine(tip, CharacterName())
        end
        if before then
            GameTooltip_AddNormalLine(tip, before .. " " .. ARROW .. " " .. label)
        elseif label then
            GameTooltip_AddNormalLine(tip, label)
        end
        if span and span > 1 then
            GameTooltip_AddHighlightLine(tip, ("%s / %s"):format(
                BreakUpLargeNumbers(into), BreakUpLargeNumbers(span)))
        end
        -- Another character further along with this character-only faction.
        local highest = not row.accountWide and row.data and RR.GetHighestReputation
            and RR:GetHighestReputation(row.factionID)
        if highest and highest.standing > (row.data.currentStanding or 0) then
            local color = highest.class and RAID_CLASS_COLORS and RAID_CLASS_COLORS[highest.class]
            local name = color and color:WrapTextInColorCode(highest.name) or highest.name
            GameTooltip_AddNormalLine(tip, (RR.L["Warband leader: %s (%s)"]):format(
                name, LabelForStanding(highest.standing, highest.sex)))
        end
    end)
    cursor = cursor - math.max(lineHeight, BAR_HEIGHT) - LINE_GAP
end

local function RenderReputation(record)
    AddSection(RR.L["Reputation Gained"], "reputation")
    local warband, character = {}, {}
    for name, amount in pairs(record and record.reputation or {}) do
        if amount ~= 0 then
            local factionID = record.factionIDs and record.factionIDs[name]
            local data = factionID and C_Reputation and C_Reputation.GetFactionDataByID
                and C_Reputation.GetFactionDataByID(factionID)
            local row = { name = name, amount = amount, factionID = factionID, data = data }
            local accountWide = data and (data.isAccountWide
                or (C_Reputation.IsAccountWideReputation
                    and C_Reputation.IsAccountWideReputation(factionID)))
            row.accountWide = accountWide and true or false
            if accountWide then
                warband[#warband + 1] = row
            else
                character[#character + 1] = row
            end
        end
    end
    if #warband == 0 and #character == 0 then
        AddLine(Color(GRAY_HEX, RR.L["None"]))
        return
    end
    local function ByGain(a, b)
        if a.amount ~= b.amount then return a.amount > b.amount end
        return a.name < b.name
    end
    table.sort(warband, ByGain)
    table.sort(character, ByGain)
    -- Warband rows first, then this character's own.
    for _, row in ipairs(warband) do AddReputationRow(row) end
    for _, row in ipairs(character) do AddReputationRow(row) end
end

-------------------------------------------------------------------------------
-- Appearances and special loot
-------------------------------------------------------------------------------

-- The items this run's new appearances came from, one per item, by name.
local function UnlockedItems(record)
    local items, seen, missingName = {}, {}, false
    if not (C_TransmogCollection and C_TransmogCollection.GetSourceInfo) then return items end
    for sourceID in pairs(record and record.sources or {}) do
        local info = C_TransmogCollection.GetSourceInfo(sourceID)
        local itemID = info and info.itemID
        if itemID and not seen[itemID] then
            seen[itemID] = true
            local name = info.name or (C_Item.GetItemNameByID and C_Item.GetItemNameByID(itemID))
            if not name then
                missingName = true
                if C_Item.RequestLoadItemDataByID then C_Item.RequestLoadItemDataByID(itemID) end
            end
            items[#items + 1] = {
                itemID = itemID, name = name or ("item:" .. itemID), quality = info.quality,
                icon = C_Item.GetItemIconByID and C_Item.GetItemIconByID(itemID),
            }
        end
    end
    if missingName then RepaintSoon() end
    table.sort(items, function(a, b) return a.name < b.name end)
    return items
end

local function ItemTooltip(itemID)
    return function(tip) tip:SetItemByID(itemID) end
end

local function AddIconGrid(items)
    local shown = #items
    local capacity = ICONS_PER_ROW * ICON_ROWS
    local overflow = 0
    if shown > capacity then
        shown = capacity - 1
        overflow = #items - shown
    end
    local slots = shown + (overflow > 0 and 1 or 0)
    for index = 1, slots do
        local icon = AcquireIcon()
        local column = (index - 1) % ICONS_PER_ROW
        local rowIndex = math.floor((index - 1) / ICONS_PER_ROW)
        icon:ClearAllPoints()
        icon:SetPoint("TOPLEFT", block, "TOPLEFT", CONTENT_X + column * (ICON_SIZE + ICON_GAP),
            cursor - rowIndex * (ICON_SIZE + ICON_GAP))
        if index <= shown then
            local item = items[index]
            local r, g, b = QualityColor(item.quality)
            icon.edge:SetColorTexture(r, g, b, 1)
            icon.art:SetTexture(item.icon or 134400)
            icon.art:Show()
            icon:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetItemByID(item.itemID)
                GameTooltip:Show()
            end)
        else
            icon.edge:SetColorTexture(GRID_EDGE[1], GRID_EDGE[2], GRID_EDGE[3], 1)
            icon.art:Hide()
            UI.SetBodyFont(icon.more, math.max(8, FontSize() - 2), "")
            icon.more:SetText("+" .. overflow)
            icon:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                for rest = shown + 1, #items do
                    GameTooltip_AddNormalLine(GameTooltip, QualityText(items[rest].quality, items[rest].name))
                end
                GameTooltip:Show()
            end)
        end
    end
    local rowsUsed = math.ceil(slots / ICONS_PER_ROW)
    cursor = cursor - rowsUsed * (ICON_SIZE + ICON_GAP) + ICON_GAP - LINE_GAP
end

-- Missing and shared counts over looks, optionally leaving out every look
-- in `except`.
local function CountLooks(looks, except)
    local needed, shared = 0, 0
    for key, state in pairs(looks) do
        if not (except and except[key] ~= nil) then
            if state == "missing" then
                needed = needed + 1
            elseif state == "shared" then
                shared = shared + 1
            end
        end
    end
    return needed, shared
end

local function RenderAppearances(raid, record)
    AddSection(RR.L["Appearances"], "appearances")
    local items = UnlockedItems(record)
    local header = Color(GREEN_HEX, (RR.L["Unlocked This Run (%d):"]):format(#items))
    if #items == 0 then
        AddLine(header .. " " .. Color(GRAY_HEX, RR.L["None"]))
    else
        AddLine(header)
        if #items <= NAMES_MAX then
            for _, item in ipairs(items) do
                local fs = AddItemRow(item.icon, QualityText(item.quality, item.name))
                AddHover(fs, fs:GetStringWidth(), fs:GetStringHeight(), ItemTooltip(item.itemID))
            end
        else
            AddIconGrid(items)
        end
    end

    local options = RR.Picker and RR.Picker.Options(raid) or {}
    local bucket = RR:FoldDifficulty(raid, RR.state.currentDifficultyID)
    local current, others = nil, {}
    for _, option in ipairs(options) do
        if option.bucket == bucket and not current then
            current = option
        else
            others[#others + 1] = option
        end
    end
    -- Other difficulties count only the looks this one cannot drop; with
    -- none still owed there, the current count stands alone on one line,
    -- reading "None" once it is zero.
    local leftToCollect = Color(VALUE_HEX, RR.L["Left to Collect:"])
    if UI.InstanceLooks then
        local currentLooks, _, currentSeen = {}, nil, 0
        if current then currentLooks, _, currentSeen = UI.InstanceLooks(raid, { current }) end
        local otherNeeded, otherShared = 0, 0
        if #others > 0 then
            local otherLooks = UI.InstanceLooks(raid, others)
            otherNeeded, otherShared = CountLooks(otherLooks, currentLooks)
        end
        local needed, shared = CountLooks(currentLooks)
        if otherNeeded + otherShared == 0 then
            if currentSeen > 0 and needed + shared == 0 then
                AddLine(leftToCollect .. " " .. Color(GREEN_HEX, RR.L["None"]))
            elseif currentSeen > 0 then
                AddLine(leftToCollect .. " " .. UI.FormatStatsFragment(needed, shared))
            end
        else
            AddLine(leftToCollect)
            if currentSeen > 0 then
                AddLine(("- %s (|cff%s%s|r): %s"):format(RR.L["Current"], PINK_HEX,
                    UI.DifficultyTabLabel(current.difficultyID), UI.FormatStatsFragment(needed, shared)),
                    CONTENT_X + SUB_INDENT)
            end
            AddLine(("- %s: %s"):format(RR.L["Other difficulties"],
                UI.FormatStatsFragment(otherNeeded, otherShared)), CONTENT_X + SUB_INDENT)
        end
    end
end

local function SpecialName(item)
    local name = C_Item.GetItemNameByID and C_Item.GetItemNameByID(item.id)
    return RR.L[item.name] ~= item.name and RR.L[item.name] or name or item.name or "?"
end

-- A special-loot row's icon: the item's own where it is an item, an
-- illusion's from the wardrobe, else the question mark.
local function SpecialIcon(item)
    if item.kind == "mount" or item.kind == "pet" or item.kind == "toy" then
        return C_Item.GetItemIconByID and C_Item.GetItemIconByID(item.id)
    end
    if item.kind == "illusion" and C_TransmogCollection and C_TransmogCollection.GetIllusionInfo then
        local info = C_TransmogCollection.GetIllusionInfo(item.id)
        return info and info.icon
    end
    return nil
end

local function AddSpecialLine(row, withSource)
    local item = row.item
    local text = QualityText(4, SpecialName(item))
    if withSource and row.boss then
        text = text .. " " .. Color(GRAY_HEX, RR:GetLocalizedBossName(row.boss) or row.boss.name)
    end
    local fs = AddItemRow(SpecialIcon(item), text)
    if item.kind == "mount" or item.kind == "pet" or item.kind == "toy" then
        AddHover(fs, fs:GetStringWidth(), fs:GetStringHeight(), ItemTooltip(item.id))
    end
end

local function RenderSpecialLoot(raid, record)
    local rows = RR.RunHistory and RR.RunHistory.SpecialRows(raid) or {}
    if #rows == 0 then return end
    AddSection(RR.L["Special Loot"], "specialLoot")
    local unlocked, missing = {}, {}
    local wasMissing = record and record.specialsMissing or {}
    for _, row in ipairs(rows) do
        local collected = RR.SpecialCollectionStateForItem(row.item) == "collected"
        if collected and wasMissing[RR.RunHistory.SpecialKey(row.item)] then
            unlocked[#unlocked + 1] = row
        elseif not collected then
            missing[#missing + 1] = row
        end
    end
    if #unlocked > 0 then
        AddLine(Color(GREEN_HEX, (RR.L["Unlocked This Run (%d):"]):format(#unlocked)))
        for _, row in ipairs(unlocked) do AddSpecialLine(row, false) end
    end
    local leftToCollect = Color(VALUE_HEX, RR.L["Left to Collect:"])
    if #missing == 0 then
        AddLine(leftToCollect .. " " .. Color(GREEN_HEX, RR.L["None"]))
        return
    end
    AddLine(leftToCollect)
    for index, row in ipairs(missing) do
        if index > SPECIALS_MAX then
            AddLine(Color(GRAY_HEX, "+" .. (#missing - SPECIALS_MAX)), CONTENT_X + ROW_ICON + 6)
            break
        end
        AddSpecialLine(row, true)
    end
end

-------------------------------------------------------------------------------
-- Entry points
-------------------------------------------------------------------------------

function UI.HideRunSummary()
    for index = 1, used.texts do texts[index]:Hide() end
    for index = 1, used.hits do hits[index]:Hide() end
    for index = 1, used.bars do bars[index]:Hide() end
    for index = 1, used.icons do icons[index]:Hide() end
    for index = 1, used.rules do rules[index]:Hide() end
    for index = 1, used.marks do marks[index]:Hide() end
    used.texts, used.hits, used.bars, used.icons, used.rules, used.marks = 0, 0, 0, 0, 0, 0
    block:Hide()
    panel._runSummaryH = nil
end

function UI.RunSummaryShown()
    return block:IsShown()
end

-- The minimized bar hides the body; a drawn summary comes back with it.
function UI.SetRunSummaryVisible(visible)
    block:SetShown(visible and used.texts > 0)
end

-- Draws the summary under the list header; the panel sizes to it.
function UI.RenderRunSummary(raid)
    UI.HideRunSummary()
    if not raid then return end
    if RR.RunHistory then RR.RunHistory.CheckComplete() end
    local record = RR.RunHistory and RR.RunHistory.CurrentRun(false)
    -- The list header is the summary's title here, set larger than in the
    -- other states; the settings pass restores it on the next repaint.
    UI.SetBodyFont(panel.listHeader, FontSize() + 4, "OUTLINE")
    panel.listHeader:SetWidth(panel.listHeader:GetWidth())
    block:ClearAllPoints()
    block:SetPoint("TOPLEFT", panel.listHeader, "BOTTOMLEFT", 0, -8)
    block:SetSize(UI.BODY_WIDTH, 1)
    block:Show()
    cursor = 0
    RenderRunStats(raid, record)
    RenderReputation(record)
    RenderAppearances(raid, record)
    RenderSpecialLoot(raid, record)
    local height = math.max(1, -cursor)
    block:SetHeight(height)
    panel._runSummaryH = height
end
