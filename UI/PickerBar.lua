-------------------------------------------------------------------------------
-- RetroRuns -- PickerBar.lua
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
-- The Picker's bar: the difficulties of the entrance the player stands at,
-- each with its lockout and missing appearances, one click to switch.
-------------------------------------------------------------------------------

local RR = RetroRuns
local UI = RR.UI
local Picker = RR.Picker

local CYAN  = { 0.30, 0.80, 1.00 }
local PINK  = { 0.95, 0.35, 0.78 }
local LABEL = { 0.85, 0.85, 0.85 }
local DIM   = { 0.45, 0.45, 0.45 }
local GREEN_HEX, ORANGE_HEX, GRAY_HEX = "00ff00", "ff9333", "888888"
local LOCK_TEXTURE = "Interface\\PetBattles\\PetBattle-LockIcon"
local LOCK_ALPHA = 0.55

local PAD         = 14
local TITLE_SIZE  = 16
local BUTTON_SIZE = 14
local LINE_SIZE   = 12
local BUTTON_GAP  = 16
local ROW_GAP     = 10
local EDGE_SIZE   = 14
-- Top center. While another addon's entrance bar is switched on, it holds
-- the higher spot and ours sits below it.
local TOP_OFFSET        = -40
local TOP_OFFSET_SHARED = -150

local function DefaultTopOffset()
    local loaded = C_AddOns and C_AddOns.IsAddOnLoaded
        and C_AddOns.IsAddOnLoaded("Plumber")
    if loaded and type(PlumberDB) == "table" and PlumberDB.InstanceDifficulty == true then
        return TOP_OFFSET_SHARED
    end
    return TOP_OFFSET
end

local function NewBarFrame(parent, name)
    local frame = CreateFrame("Frame", name, parent, "BackdropTemplate")
    frame:SetBackdrop(UI.PanelBackdrop(EDGE_SIZE))
    frame:SetBackdropBorderColor(1, 1, 1, 1)
    return frame
end

local bar = NewBarFrame(UIParent, "RetroRunsPickerBar")
bar:SetFrameStrata("MEDIUM")
bar:SetClampedToScreen(true)
bar:EnableMouse(true)
bar:SetMovable(true)
bar:RegisterForDrag("LeftButton")
bar:Hide()

local function Scale()
    return RR:GetSetting("pickerScale", 1.0) or 1.0
end

-- The saved spot is the bar's top center, in screen units from the top
-- center of the screen, so bars of any width stay centered on it.
local function ApplyPosition()
    local scale = Scale()
    local anchor = RR:GetSetting("pickerAnchor", nil)
    local x, y = 0, DefaultTopOffset()
    if type(anchor) == "table" and anchor.x and anchor.y then
        x, y = anchor.x, anchor.y
    end
    bar:SetScale(scale)
    bar:ClearAllPoints()
    bar:SetPoint("TOP", UIParent, "TOP", x / scale, y / scale)
end

local FADE_IN, FADE_OUT = 0.25, 0.4

-- Native fades that keep their end alpha; each starts where the other
-- stopped.
local fadeIn = bar:CreateAnimationGroup()
fadeIn:SetToFinalAlpha(true)
local fadeInAlpha = fadeIn:CreateAnimation("Alpha")
fadeInAlpha:SetToAlpha(1)

local fadeOut = bar:CreateAnimationGroup()
fadeOut:SetToFinalAlpha(true)
local fadeOutAlpha = fadeOut:CreateAnimation("Alpha")
fadeOutAlpha:SetToAlpha(0)
fadeOut:SetScript("OnFinished", function() bar:Hide() end)

local fadeFrom = 0

local function CurrentAlpha()
    if fadeIn:IsPlaying() then
        return fadeFrom + (1 - fadeFrom) * fadeInAlpha:GetProgress()
    elseif fadeOut:IsPlaying() then
        return fadeFrom * (1 - fadeOutAlpha:GetProgress())
    end
    return bar:IsShown() and 1 or 0
end

local function PlayFade(group, animation, fromAlpha, toAlpha, duration)
    fadeIn:Stop()
    fadeOut:Stop()
    fadeFrom = fromAlpha
    bar:SetAlpha(fromAlpha)
    animation:SetFromAlpha(fromAlpha)
    animation:SetDuration(duration * math.abs(toAlpha - fromAlpha))
    group:Play()
end

local function SetFont(fontString, size)
    RR.SafeSetFont(fontString, RR:GetChromeFont(), size, "")
end

-- A hidden button forgets its underline key, so a reused one never animates.
local function HideButton(button)
    button.underlineKey = nil
    button:Hide()
end

-- A view is one drawn bar: the live one, or the settings preview.
local function NewView(frame, preview)
    return { frame = frame, rows = {}, preview = preview }
end

local function AcquireRow(view, index)
    local row = view.rows[index]
    if row then return row end
    row = { buttons = {} }
    row.title = view.frame:CreateFontString(nil, "OVERLAY")
    row.title:SetJustifyH("CENTER")
    row.expansion = view.frame:CreateFontString(nil, "OVERLAY")
    row.expansion:SetJustifyH("CENTER")
    view.rows[index] = row
    return row
end

local ShowTip   -- forward declaration; the buttons' hover handler
local OnClick   -- forward declaration; the buttons' click handler

local function AcquireButton(view, row, index)
    local button = row.buttons[index]
    if button then return button end
    button = CreateFrame("Button", nil, view.frame)
    button.view = view
    button.label = button:CreateFontString(nil, "OVERLAY")
    button.label:SetPoint("TOP", button, "TOP", 0, 0)
    button.underline = button:CreateTexture(nil, "ARTWORK")
    button.underline:SetHeight(1)
    button.underline:Hide()
    UI.BuildUnderlineDraw(button.underline)
    button.count = button:CreateFontString(nil, "OVERLAY")
    button.count:SetPoint("LEFT", button.label, "RIGHT", 4, 0)
    button.lockLine = button:CreateFontString(nil, "OVERLAY")
    -- A faint lock over a difficulty the week's shared lockout shuts out.
    button.lock = button:CreateTexture(nil, "OVERLAY")
    button.lock:SetTexture(LOCK_TEXTURE)
    button.lock:SetSize(16, 16)
    button.lock:SetAlpha(LOCK_ALPHA)
    button.lock:SetPoint("CENTER", button.label, "CENTER", 0, 0)
    button.lock:Hide()
    button:SetScript("OnEnter", function(self) ShowTip(self) end)
    button:SetScript("OnLeave", GameTooltip_Hide)
    button:SetScript("OnClick", function(self) OnClick(self) end)
    -- The preview only shows.
    button:EnableMouse(not view.preview)
    row.buttons[index] = button
    return button
end

-- Appearances still missing (then shared) on one bucket, counted the way
-- Transmog Needed counts. Nil when nothing there is countable.
local function MissingCounts(instance, bucket)
    local classID = RR.PlayerClassID and RR.PlayerClassID()
    local needed, shared, seen = 0, 0, 0
    local function Visit(_, state)
        if state == "missing" then
            needed = needed + 1
        elseif state == "shared" then
            shared = shared + 1
        end
    end
    for _, boss in ipairs(instance.bosses or {}) do
        seen = seen + UI.ForEachBossLookAt(boss, bucket, classID, Visit)
    end
    if seen == 0 then return nil end
    return needed, shared
end

-- White word, orange count, as the main panel's Transmog Needed reads.
local function MissingText(instance, bucket)
    local needed, shared = MissingCounts(instance, bucket)
    if not needed then return nil end
    if needed > 0 then
        return ("|cffffffff%s|r |cff%s(%d)|r"):format(RR.L["Missing Appearances"], ORANGE_HEX, needed)
    end
    if shared > 0 then
        return ("|cffffffff%s|r |cff%s(%d)|r"):format(RR.L["Shared Appearances"], ORANGE_HEX, shared)
    end
    return ("|cff%s%s|r"):format(GREEN_HEX, RR.L["Complete"])
end

-- The count beside a difficulty's name: missing, else shared, in orange, a
-- green 0 once nothing is left. The tooltip says which.
local function NameCount(instance, bucket)
    local needed, shared = MissingCounts(instance, bucket)
    if not needed then return nil end
    if needed > 0 or shared > 0 then
        return ("|cff%s(%d)|r"):format(ORANGE_HEX, needed > 0 and needed or shared)
    end
    return ("|cff%s(0)|r"):format(GREEN_HEX)
end

-- A difficulty's lockout count, or nil for one that never saves.
local function LockCount(instance, option, counts)
    if RR:BucketNeverSaves(instance, option.bucket) then return nil end
    local count = counts[option.bucket]
    if not count or count.total == 0 then return nil end
    return count
end

local function LockText(count)
    local hex = GRAY_HEX
    if count.complete >= count.total then
        hex = GREEN_HEX
    elseif count.complete > 0 then
        hex = ORANGE_HEX
    end
    return ("|cff%s%d/%d|r"):format(hex, count.complete, count.total)
end


local function DifficultyName(difficultyID)
    return (GetDifficultyInfo and GetDifficultyInfo(difficultyID)) or tostring(difficultyID)
end

-- Sets one line's text, returning its size, or hides it.
local function FillLine(fontString, text)
    if not text then
        fontString:Hide()
        return 0, 0
    end
    SetFont(fontString, LINE_SIZE)
    fontString:SetText(text)
    fontString:Show()
    return fontString:GetStringWidth(), math.ceil(fontString:GetStringHeight())
end

-- Lays out one row per entrance in range, centered, and sizes the bar to
-- fit. Every button in a row reserves the same lines.
local function Render(view)
    local currentHits = view.hits
    if not currentHits then return end
    local frame, rows = view.frame, view.rows
    local blocked = Picker.ChangeBlocked()
    local showLock = RR:GetSetting("pickerShowLockouts", true) ~= false
    local showMiss = RR:GetSetting("pickerShowMissing", true) ~= false
    local dungeonRows = 0
    for _, hit in ipairs(currentHits) do
        if hit.entry.instance.kind == "dungeon" then dungeonRows = dungeonRows + 1 end
    end

    frame:SetBackdropColor(1, 1, 1, RR:GetSetting("panelOpacity", 1.0))
    local layouts, widest = {}, 160
    for rowIndex, hit in ipairs(currentHits) do
        local instance = hit.entry.instance
        local row = AcquireRow(view, rowIndex)
        SetFont(row.title, TITLE_SIZE)
        row.title:SetTextColor(unpack(CYAN))
        row.title:SetText(RR:GetLocalizedRaidName(instance) or instance.name)
        row.title:Show()
        -- The expansion in the locale table's wording, as the browser shows it.
        SetFont(row.expansion, LINE_SIZE)
        row.expansion:SetTextColor(unpack(PINK))
        row.expansion:SetText(instance.expansion and RR.L[instance.expansion] or "")
        row.expansion:SetShown(instance.expansion ~= nil)
        local layout = { row = row, cells = {}, labelH = 0, lockH = 0, width = 0 }
        layouts[rowIndex] = layout
        widest = math.max(widest, row.title:GetStringWidth() + 2 * PAD,
            row.expansion:GetStringWidth() + 2 * PAD)

        local options = Picker.Options(instance)
        local counts = RR:GetPerDifficultyKillCountsForRaid(instance) or {}
        local resets = RR:GetResetsByBucket(instance)
        local locked, lockedOn, lockedOnBucket = {}, nil, nil
        for _, bucket in ipairs(RR:GetLockedOutBuckets(instance, counts) or {}) do
            locked[bucket] = true
        end
        for _, option in ipairs(options) do
            local count = counts[option.bucket]
            if not lockedOn and count and count.complete > 0 then
                lockedOn = DifficultyName(option.difficultyID)
                lockedOnBucket = option.bucket
            end
        end

        for index, option in ipairs(options) do
            local button = AcquireButton(view, row, index)
            local name = DifficultyName(option.difficultyID)
            local selected = Picker.CurrentDifficulty(option.kind) == option.difficultyID
            local count = LockCount(instance, option, counts)
            local missText = MissingText(instance, option.bucket)
            local shutOut = locked[option.bucket] == true
            local muted = (blocked ~= nil) or shutOut
            button.data = {
                option = option, name = name, selected = selected,
                count = count, missText = missText,
                shutOut = shutOut, lockedOn = lockedOn,
                reset = resets[option.bucket] or (shutOut and resets[lockedOnBucket]) or nil,
                sharedNote = instance.kind == "dungeon" and dungeonRows > 1,
            }
            button.lock:SetShown(shutOut)

            SetFont(button.label, BUTTON_SIZE)
            button.label:SetText(name)
            button.label:SetTextColor(unpack(selected and CYAN or (muted and DIM or LABEL)))
            local nameCount = showMiss and NameCount(instance, option.bucket) or nil
            SetFont(button.count, BUTTON_SIZE)
            button.count:SetText(nameCount or "")
            button.count:SetShown(nameCount ~= nil)
            local countW = nameCount and (4 + button.count:GetStringWidth()) or 0
            button.nameWidth = button.label:GetStringWidth() + countW
            -- A line shrinking away keeps the color it had.
            if selected then
                local underline = blocked and DIM or PINK
                button.underline:SetColorTexture(underline[1], underline[2], underline[3], 1)
            end
            -- Keyed to the entrance and difficulty, so a button reused for
            -- another entrance never animates.
            UI.SetUnderlineDrawn(button, selected, hit.entry.key .. ":" .. option.difficultyID)
            UI.SetBreathing(button.underline, selected and not blocked)

            -- A difficulty that never saves reads "- / -".
            local lockLine
            if showLock and not shutOut then
                lockLine = count and LockText(count) or ("|cff%s- / -|r"):format(GRAY_HEX)
            end
            local lockW, lockH = FillLine(button.lockLine, lockLine)
            local width = math.ceil(math.max(button.nameWidth, lockW)) + 4
            layout.labelH = math.max(layout.labelH, math.ceil(button.label:GetStringHeight()))
            layout.lockH = math.max(layout.lockH, lockH)
            layout.cells[index] = { button = button, width = width }
            layout.width = layout.width + width + (index > 1 and BUTTON_GAP or 0)
        end
        for index = #options + 1, #row.buttons do HideButton(row.buttons[index]) end
        widest = math.max(widest, layout.width + 2 * PAD)
    end

    -- Second pass: every row centered in the widest one.
    local y = -PAD
    for _, layout in ipairs(layouts) do
        layout.row.title:ClearAllPoints()
        layout.row.title:SetPoint("TOP", frame, "TOP", 0, y)
        y = y - math.ceil(layout.row.title:GetStringHeight())
        if layout.row.expansion:IsShown() then
            layout.row.expansion:ClearAllPoints()
            layout.row.expansion:SetPoint("TOP", frame, "TOP", 0, y - 3)
            y = y - (math.ceil(layout.row.expansion:GetStringHeight()) + 3)
        end
        y = y - 6
        local lockTop = layout.labelH + 5
        local height = lockTop + layout.lockH
        local x = math.floor((widest - layout.width) / 2)
        for _, cell in ipairs(layout.cells) do
            local button = cell.button
            -- Name and count centered together, the underline under both.
            button.label:ClearAllPoints()
            button.label:SetPoint("TOPLEFT", button, "TOPLEFT",
                math.floor((cell.width - button.nameWidth) / 2), 0)
            button.underline:ClearAllPoints()
            button.underline:SetPoint("TOPLEFT", button.label, "BOTTOMLEFT", 0, -2)
            button.underline:SetPoint("TOPRIGHT",
                button.count:IsShown() and button.count or button.label, "BOTTOMRIGHT", 0, -2)
            button.lockLine:ClearAllPoints()
            button.lockLine:SetPoint("TOP", button, "TOP", 0, -lockTop)
            button:SetSize(cell.width, height)
            button:ClearAllPoints()
            button:SetPoint("TOPLEFT", frame, "TOPLEFT", x, y)
            button:Show()
            x = x + cell.width + BUTTON_GAP
        end
        y = y - height - ROW_GAP
    end
    for index = #currentHits + 1, #rows do
        rows[index].title:Hide()
        rows[index].expansion:Hide()
        for _, button in ipairs(rows[index].buttons) do HideButton(button) end
    end
    frame:SetSize(widest, -y - ROW_GAP + PAD)
end

ShowTip = function(button)
    local data = button.data
    if not data then return end
    GameTooltip:SetOwner(button, "ANCHOR_BOTTOM")
    GameTooltip_SetTitle(GameTooltip, data.name)
    local saved = data.shutOut
    if data.shutOut then
        GameTooltip_AddNormalLine(GameTooltip,
            (RR.L["Locked for this week: your lockout is on %s."]):format(data.lockedOn or ""))
        if data.selected then
            GameTooltip_AddNormalLine(GameTooltip,
                RR.L["You can't enter on this difficulty this week. Pick another."])
        end
    elseif data.count then
        if data.count.complete >= data.count.total then
            GameTooltip_AddNormalLine(GameTooltip, RR.L["Cleared."])
            saved = true
        elseif data.count.complete > 0 then
            -- The bar already shows the count; the tooltip adds the reset.
            saved = true
        else
            GameTooltip_AddNormalLine(GameTooltip, RR.L["Not saved"])
        end
    end
    if saved and data.reset then
        GameTooltip_AddNormalLine(GameTooltip, RR:ResetText(data.reset))
    end
    if data.missText then GameTooltip_AddNormalLine(GameTooltip, data.missText) end
    if data.sharedNote then
        GameTooltip_AddNormalLine(GameTooltip, RR.L["Dungeon difficulty applies to every dungeon."])
    end
    local blocked = Picker.ChangeBlocked()
    if blocked == "leader" then
        GameTooltip_AddNormalLine(GameTooltip, RR.L["Only the group leader can change the difficulty."])
    elseif blocked == "finder" then
        GameTooltip_AddNormalLine(GameTooltip, RR.L["Difficulty can't be changed in a group finder group."])
    elseif not data.selected and not data.shutOut then
        GameTooltip_AddNormalLine(GameTooltip, (RR.L["Click to set %s."]):format(data.name))
    end
    GameTooltip:Show()
end

OnClick = function(button)
    local data = button.data
    if not data or data.selected or data.shutOut or Picker.ChangeBlocked() then return end
    Picker.SetDifficulty(data.option)
    Render(button.view)
    if GameTooltip:GetOwner() == button then ShowTip(button) end
end

local live = NewView(bar, false)
local liveHits      -- the entrances the player stands at, or nil
local unlocked = false

-- What an unlocked bar and the preview show: Bloodmaul Slag Mines, or the
-- first dungeon with data when it is missing.
local function SampleHits()
    local sample
    for _, dungeon in pairs(RetroRuns_DungeonData or {}) do
        if type(dungeon) == "table" and dungeon.instanceID and dungeon.bosses then
            if dungeon.instanceID == 1175 then sample = dungeon; break end
            sample = sample or dungeon
        end
    end
    if not sample then return nil end
    return { { entry = { instance = sample, key = "sample" }, distance = 0 } }
end

-- Shows the bar for the entrances in range, or the sample while unlocked;
-- fades it out when there is neither.
local function Sync()
    local hits = liveHits or (unlocked and SampleHits()) or nil
    if not hits then
        if not bar:IsShown() or fadeOut:IsPlaying() then return end
        live.hits = nil
        PlayFade(fadeOut, fadeOutAlpha, CurrentAlpha(), 0, FADE_OUT)
        return
    end
    live.hits = hits
    Render(live)
    local fromAlpha = CurrentAlpha()
    bar:Show()
    if fromAlpha < 1 and not fadeIn:IsPlaying() then
        PlayFade(fadeIn, fadeInAlpha, fromAlpha, 1, FADE_IN)
    end
end

-- Hint caption above an unlocked bar.
local dragLabel = bar:CreateFontString(nil, "OVERLAY")
dragLabel:SetPoint("BOTTOMLEFT", bar, "TOPLEFT", 0, 4)
dragLabel:Hide()

bar:SetScript("OnDragStart", function(self)
    if unlocked then self:StartMoving() end
end)
bar:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    if not unlocked then return end
    local scale = self:GetScale()
    local centerX = self:GetCenter()
    local top = self:GetTop()
    if centerX and top then
        RR:SetSetting("pickerAnchor", {
            x = math.floor(centerX * scale - (UIParent:GetWidth() or 0) / 2 + 0.5),
            y = math.floor(top * scale - (UIParent:GetHeight() or 0) + 0.5),
        })
    end
    ApplyPosition()
end)

-- The settings preview: a second bar on the given parent, drawn from the
-- sample at the live bar's on-screen size.
local function BuildPreview(parent)
    local frame = NewBarFrame(parent)
    local view = NewView(frame, true)
    local handle = { frame = frame }
    -- Matches the live bar's effective scale; shrinks only past
    -- handle.maxWidth.
    function handle:Refresh()
        view.hits = SampleHits()
        Render(view)
        local scale = Scale() * UIParent:GetEffectiveScale()
            / math.max(parent:GetEffectiveScale(), 0.01)
        local width = frame:GetWidth() or 0
        if self.maxWidth and width > 0 and width * scale > self.maxWidth then
            scale = self.maxWidth / width
        end
        frame:SetScale(scale)
        frame:SetShown(view.hits ~= nil)
    end
    return handle
end

local previews = {}

-- Difficulty, group and lockout changes repaint an open bar.
local events = CreateFrame("Frame")
for _, eventName in ipairs({ "PLAYER_DIFFICULTY_CHANGED", "UPDATE_INSTANCE_INFO",
        "GROUP_ROSTER_UPDATE", "PARTY_LEADER_CHANGED" }) do
    events:RegisterEvent(eventName)
end
events:SetScript("OnEvent", function()
    if bar:IsShown() and live.hits then Render(live) end
end)

UI.PickerBar = {
    Show = function(hits)
        liveHits = hits
        ApplyPosition()
        Sync()
        if RequestRaidInfo then RequestRaidInfo() end
    end,
    Hide = function()
        if liveHits == nil then return end
        liveHits = nil
        Sync()
    end,
    -- Settings changes repaint an open bar and the previews.
    Refresh = function()
        ApplyPosition()
        if bar:IsShown() and live.hits then Render(live) end
        for _, preview in ipairs(previews) do
            if preview.frame:IsVisible() then preview:Refresh() end
        end
    end,
    Unlock = function()
        unlocked = true
        RR.SafeSetFont(dragLabel, RR:GetChromeFont(), 12, "OUTLINE")
        dragLabel:SetText(RR.L["Drag to move"])
        dragLabel:SetTextColor(1, 0.7, 0.9, 1)
        dragLabel:Show()
        -- Above the settings window while it is being placed.
        bar:SetFrameStrata("FULLSCREEN_DIALOG")
        ApplyPosition()
        Sync()
    end,
    Lock = function()
        unlocked = false
        dragLabel:Hide()
        bar:SetFrameStrata("MEDIUM")
        Sync()
    end,
    ResetPosition = function()
        RR:SetSetting("pickerAnchor", nil)
        ApplyPosition()
    end,
    BuildPreview = function(parent)
        local preview = BuildPreview(parent)
        previews[#previews + 1] = preview
        return preview
    end,
}
