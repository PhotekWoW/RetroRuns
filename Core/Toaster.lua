-------------------------------------------------------------------------------
-- RetroRuns -- Toaster.lua
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
-- Replaces the game's center-screen loot popups with our own presentation.
--
-- Three concerns:
--   * Suppressor  -- stops the native popups.
--   * Source      -- listens for drop events and supplies the item data.
--   * Presenter   -- a pooled stack of fading frames, with same-item merging.
-------------------------------------------------------------------------------

local RR = RetroRuns

-- Drop notifications that produce a native popup, grouped by kind.
local EVENT_KIND = {
    SHOW_LOOT_TOAST                          = "item",
    SHOW_LOOT_TOAST_UPGRADE                  = "item",
    SHOW_LOOT_TOAST_LEGENDARY_LOOTED         = "item",
    NEW_MOUNT_ADDED                          = "collection",
    NEW_PET_ADDED                            = "collection",
    NEW_TOY_ADDED                            = "collection",
    NEW_HOUSING_ITEM_ACQUIRED                = "housing",
    TRANSMOG_COLLECTION_SOURCE_ADDED         = "appearance",
    TRANSMOG_COSMETIC_COLLECTION_SOURCE_ADDED = "appearance",
}

-- The same events, sorted, so the register/unregister loops run in a fixed
-- order (pairs order is undefined).
local EVENT_LIST = {}
for eventName in pairs(EVENT_KIND) do EVENT_LIST[#EVENT_LIST + 1] = eventName end
table.sort(EVENT_LIST)

-------------------------------------------------------------------------------
-- Module state
-------------------------------------------------------------------------------

local M = {
    enabled    = false,
    source     = nil,   -- our capture frame
    guardHook  = false, -- AlertFrame.RegisterEvent re-detach guard installed
    chatFilterInstalled = false,
    -- Window through which the appearance-collected line is suppressed.
    appearanceLineWindowUntil = 0,
}

-- How long after an appearance event the suppression window stays open.
-- Long enough to cover the chat line arriving a few frames later (observed
-- lines trail their event by up to ~0.3s, sometimes just past the loot
-- bracket), short enough that an unrelated secret system line is very
-- unlikely to fall inside it.
local APPEARANCE_LINE_WINDOW = 0.5

-- Route AlertFrame detach/attach through a protected call.
local function Protected(fn, ...)
    local ok, err = pcall(fn, ...)
    if not ok then
        RR:ZoneLog("[Toaster] protected call failed: " .. tostring(err))
    end
    return ok
end

-------------------------------------------------------------------------------
-- Suppressor
-------------------------------------------------------------------------------

local Suppressor = {}

function Suppressor.Detach()
    if not AlertFrame then return end
    for _, ev in ipairs(EVENT_LIST) do
        Protected(AlertFrame.UnregisterEvent, AlertFrame, ev)
    end
end

function Suppressor.Reattach()
    if not AlertFrame then return end
    for _, ev in ipairs(EVENT_LIST) do
        Protected(AlertFrame.RegisterEvent, AlertFrame, ev)
    end
end

-- Re-detach if the game re-registers one of our events while active. Installed
-- once; inert while the feature is off (gates on M.enabled).
function Suppressor.InstallGuard()
    if M.guardHook or not AlertFrame then return end
    hooksecurefunc(AlertFrame, "RegisterEvent", function(self, event)
        if M.enabled and event and EVENT_KIND[event] then
            Protected(self.UnregisterEvent, self, event)
        end
    end)
    M.guardHook = true
end

-------------------------------------------------------------------------------
-- Hides Blizzard's boss-kill loot banner; Suppressor handles corner toasts.
-------------------------------------------------------------------------------

local BannerSuppressor = {}

function BannerSuppressor.Hold()
    if BannerSuppressor.held then return end
    local banner = _G.BossBanner
    if not banner then return end
    if BannerSuppressor.original == nil then
        BannerSuppressor.original = banner:GetScript("OnEvent") or false
    end
    banner:SetScript("OnEvent", function(self, event, ...)
        -- Drop the loot-row driver; forward everything else.
        if event == "ENCOUNTER_LOOT_RECEIVED" then return end
        local orig = BannerSuppressor.original
        if orig then orig(self, event, ...) end
    end)
    BannerSuppressor.held = true
end

function BannerSuppressor.Release()
    if not BannerSuppressor.held then return end
    local banner = _G.BossBanner
    if banner and BannerSuppressor.original ~= nil then
        banner:SetScript("OnEvent", BannerSuppressor.original or nil)
    end
    BannerSuppressor.held = false
end

-- Reconcile banner-hide state against the setting. Default on (suppress) while
-- the Toaster is active.
local function BannerHideOn()
    return (RR.GetSetting and RR:GetSetting("toasterHideBossBanner", true)) ~= false
end

local function RefreshBannerSuppression()
    if M.enabled and BannerHideOn() then
        BannerSuppressor.Hold()
    else
        BannerSuppressor.Release()
    end
end
RR._RefreshToasterBannerSuppression = RefreshBannerSuppression

-------------------------------------------------------------------------------
-- Presenter: pooled, fading toast frames stacked upward from a base point.
-------------------------------------------------------------------------------

local Presenter = {
    pool    = {},   -- reusable hidden frames
    live    = {},   -- currently shown, oldest first (head pins to anchor)
}

local TOAST_H, GAP = 96, 26
-- Toast width: TOAST_H at the banner art's 4:1 ratio.
local TOAST_W_FIXED = math.floor(TOAST_H * (512 / 128) + 0.5)  -- 384 at H=96
-- Icon placement inside the banner art's baked well.
local BANNER_ICON_SIZE  = 44
local BANNER_ICON_INSET = 22
local BASE_X, BASE_Y        = 0, 140          -- fallback offset from screen center
local TOAST_SCALE           = 0.7
local ANCHOR_GAP            = 8               -- gap between panel and toast stack
local FADE_IN, FADE_OUT = 0.12, 0.9          -- seconds (hold is dynamic; see EffectiveHold)
local STAGGER               = 0.20           -- delay between batch reveals
local COIN_SOUND            = "Interface\\AddOns\\RetroRuns\\Media\\Sounds\\coin.ogg"
local COIN_FINAL_SOUND      = "Interface\\AddOns\\RetroRuns\\Media\\Sounds\\coin_ringout_v3.ogg"

-- Brand constants, mirroring the file-local tokens in UI.lua.
local TITLE_FONT = "Interface\\AddOns\\RetroRuns\\Media\\Fonts\\04B_03.TTF"
local C_PINK = { 0.95, 0.35, 0.78 }

-- Click-hint text size. A step under the item name (20) so the hint reads as
-- an aside rather than as a second headline.
local HINT_FONT_SIZE = 19

-- Every toast takes the body font, sized as built. A font object goes on first
-- so a koKR/zhTW cold start still renders when the font file fails to apply.
local function ApplyToastFonts(toastFrame)
    local bodyFont = RR:GetBodyFont()
    for fontString, size in pairs({ [toastFrame.header] = 16,
                                    [toastFrame.itemNameText] = 20,
                                    [toastFrame.hint or false] = HINT_FONT_SIZE }) do
        if fontString then
            fontString:SetFontObject("GameFontNormal")
            RR.SafeSetFont(fontString, bodyFont, size, "OUTLINE")
        end
    end
end

-- A toast header, upper-cased only when plain ASCII: string.upper skips
-- accented and non-Latin letters.
local function ToastHeaderText(key)
    local text = RR.L[key]
    if not text:find("[\128-\255]") then text = text:upper() end
    return text
end

-- The colored "RR:" tag prepended to every line RetroRuns prints to chat.
-- Kept as one constant so the loot-summary emitter and the AddMessage guard
-- (which must recognize and never suppress RetroRuns' own lines) share it.
local CHAT_PREFIX = "|cff4DCCFFR|cffF259C7R|r|cff7f7f7f:|r "

-- Lifecycle trace: a bounded ring of recent pipeline decision points,
-- surfaced in the toaster debug dump. Sized to hold a full loot burst
-- so no decision points are lost between the drop and the dump.
local TRACE_MAX = 200
local Trace = {}
local function T(msg)
    -- Millisecond timestamps. At 0.1s resolution an appearance event and
    -- the secret system line it triggers land on the same printed tick,
    -- hiding their true ordering; %.3f exposes whether the line precedes
    -- or follows the window-arm on the same frame, which distinguishes a
    -- filter-pipeline bypass from a window-arm race.
    Trace[#Trace + 1] = ("%.3f  %s"):format(GetTime and GetTime() or 0, msg)
    if #Trace > TRACE_MAX then
        table.remove(Trace, 1)
    end
end

-- Construct a toast frame's visuals on a parent. Shared by the live pool and
-- the settings preview. Does not pool or set live behavior.
local function ConstructToastFrame(parent)
    local toastFrame = CreateFrame("Button", nil, parent or UIParent)
    toastFrame:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    toastFrame:SetSize(TOAST_W_FIXED, TOAST_H)
    toastFrame:SetScale(TOAST_SCALE)
    toastFrame:SetFrameStrata("HIGH")

    -- Glow: soft rectangular halo (EpicGlow), additive, tinted/pulsed per
    -- quality (forced pink for appearances). Anchored wider than the frame.
    toastFrame.glow = toastFrame:CreateTexture(nil, "BACKGROUND", nil, -1)
    toastFrame.glow:SetTexture("Interface\\AddOns\\RetroRuns\\Media\\Toast\\EpicGlow")
    toastFrame.glow:SetPoint("TOPLEFT", -115, 115)
    toastFrame.glow:SetPoint("BOTTOMRIGHT", 115, -115)
    toastFrame.glow:SetBlendMode("ADD")
    toastFrame.glow:Hide()

    -- Per-kind banner frame art (512x128); texture set in ApplyContent.
    toastFrame.banner = toastFrame:CreateTexture(nil, "BORDER")
    toastFrame.banner:SetAllPoints()

    -- Icon, seated in the banner art's baked well.
    toastFrame.icon = toastFrame:CreateTexture(nil, "ARTWORK")
    toastFrame.icon:SetSize(BANNER_ICON_SIZE, BANNER_ICON_SIZE)
    toastFrame.icon:SetPoint("LEFT", BANNER_ICON_INSET, 0)
    toastFrame.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

    -- Quality-tinted icon ring (the rarity cue the banner doesn't carry).
    -- Tint/show set in ApplyContent.
    toastFrame.iconRing = toastFrame:CreateTexture(nil, "OVERLAY")
    toastFrame.iconRing:SetTexture("Interface\\AddOns\\RetroRuns\\Media\\Icons\\icon-border-white")
    toastFrame.iconRing:SetPoint("TOPLEFT", toastFrame.icon, "TOPLEFT", -5, 5)
    toastFrame.iconRing:SetPoint("BOTTOMRIGHT", toastFrame.icon, "BOTTOMRIGHT", 5, -5)
    toastFrame.iconRing:Hide()

    -- Header: green pixel-font category label ("NEW APPEARANCE", "SPECIAL LOOT").
    toastFrame.header = toastFrame:CreateFontString(nil, "OVERLAY")
    toastFrame.header:SetPoint("TOPLEFT", toastFrame.icon, "TOPRIGHT", 9, -4)
    toastFrame.header:SetPoint("RIGHT", -8, 0)
    toastFrame.header:SetJustifyH("LEFT")
    toastFrame.header:SetTextColor(0.49, 0.99, 0.0)  -- C_LABEL green

    -- Body: item name, quality-colored. Wraps to a second line, capped at 2.
    toastFrame.itemNameText = toastFrame:CreateFontString(nil, "OVERLAY")
    toastFrame.itemNameText:SetPoint("TOPLEFT", toastFrame.header, "BOTTOMLEFT", 0, -3)
    toastFrame.itemNameText:SetPoint("RIGHT", -8, 0)
    toastFrame.itemNameText:SetJustifyH("LEFT")
    toastFrame.itemNameText:SetJustifyV("TOP")
    toastFrame.itemNameText:SetWordWrap(true)
    if toastFrame.itemNameText.SetMaxLines then toastFrame.itemNameText:SetMaxLines(2) end

    -- Click hint, anchored to the toast's right edge. Body font, not the
    -- pixel face.
    toastFrame.hint = toastFrame:CreateFontString(nil, "OVERLAY")
    toastFrame.hint:SetPoint("LEFT", toastFrame, "RIGHT", 10, 0)
    toastFrame.hint:SetJustifyH("LEFT")
    toastFrame.hint:SetTextColor(1, 0.82, 0)
    toastFrame.hint:Hide()

    ApplyToastFonts(toastFrame)
    return toastFrame
end

local function AcquireFrame()
    local toastFrame = table.remove(Presenter.pool)
    if toastFrame then return toastFrame end
    return ConstructToastFrame(UIParent)
end

-- Halts a toast's fade: the hold timer, both fade animations, and anything a
-- hover had paused.
local function StopToastFade(toastFrame)
    if toastFrame.holdTimer then toastFrame.holdTimer:Cancel() end
    toastFrame.holdTimer, toastFrame.holdEnds = nil, nil
    toastFrame.holdLeft, toastFrame.resumeAlpha = nil, nil
    if toastFrame.fadeIn then toastFrame.fadeIn:Stop() end
    if toastFrame.fadeOut then toastFrame.fadeOut:Stop() end
end

local function ReleaseFrame(toastFrame)
    toastFrame:Hide()
    StopToastFade(toastFrame)
    -- Clear mouse wiring before pooling.
    toastFrame:SetScript("OnMouseDown", nil)
    toastFrame:EnableMouse(false)
    -- Clear hover-pause wiring. A pooled frame keeps its scripts and its
    -- mouse-motion flag, so a stale hoverStart would freeze the next toast's
    -- countdown at a timestamp from the previous one.
    toastFrame:SetScript("OnEnter", nil)
    toastFrame:SetScript("OnLeave", nil)
    toastFrame.hoverStart = nil
    if toastFrame.SetMouseMotionEnabled then
        toastFrame:SetMouseMotionEnabled(false)
    end
    toastFrame.glowOn = nil
    RR.UI.SetBreathing(toastFrame.glow, false)
    -- Clear click wiring and identity. A pooled frame that kept these would
    -- act on the previous drop.
    toastFrame:SetScript("OnClick", nil)
    toastFrame.sourceID = nil
    toastFrame.mountID = nil
    toastFrame.petID = nil
    toastFrame.toyID = nil
    if toastFrame.glow then toastFrame.glow:Hide() end
    -- Clear the click hint and invalidate any pending hide timer, so a
    -- pooled frame doesn't reopen carrying the previous drop's hint.
    if toastFrame.hint then toastFrame.hint:Hide() end
    toastFrame.hintToken = (toastFrame.hintToken or 0) + 1
    Presenter.pool[#Presenter.pool + 1] = toastFrame
end

-- Returns the user's saved free-floating anchor as point,x,y if they've moved
-- the toasts via the unlock-drag feature, else nil (use the default
-- panel-relative anchor). Stored as toasterAnchor = { point, x, y } where point
-- is the toast corner pinned to the matching UIParent corner, and x,y are the
-- screen-space offset from that corner.
local function GetSavedAnchor()
    local anchorSetting = RR.GetSetting and RR:GetSetting("toasterAnchor", nil)
    if type(anchorSetting) == "table" and anchorSetting.point and anchorSetting.x and anchorSetting.y then
        return anchorSetting.point, anchorSetting.x, anchorSetting.y
    end
    return nil
end

-- Derive a stable anchor from a frame's on-screen rect: bind vertically to the
-- screen top, horizontally to the nearer screen edge. Returns point (TOPLEFT or
-- TOPRIGHT) and the x,y offset for that corner.
local function DeriveAnchor(frame)
    local cx = frame:GetCenter()
    local screenW = UIParent:GetRight() or 0
    local screenH = UIParent:GetTop() or 0
    if not cx then return "TOPLEFT", 0, 0 end

    local topOffset = (frame:GetTop() or 0) - screenH         -- negative: down from screen top
    local point, x
    if cx >= screenW / 2 then
        point = "TOPRIGHT"
        x = (frame:GetRight() or 0) - screenW         -- negative: left from screen right
    else
        point = "TOPLEFT"
        x = (frame:GetLeft() or 0)                    -- positive: right from screen left
    end

    return point, math.floor(x + 0.5), math.floor(topOffset + 0.5)
end

local function Restack()
    -- Anchor priority: saved free-floating position, else the panel's
    -- top-right, else screen-center. Head of the list (index 1) pins to the
    -- anchor; the rest chain downward, so the stack cascades top-to-bottom.
    local panel = _G.RetroRunsMainFrame
    local anchored = panel and panel:IsShown()
    local savedPoint, savedX, savedY = GetSavedAnchor()

    for i, f in ipairs(Presenter.live) do
        f:ClearAllPoints()
        if i == 1 then
            if savedPoint then
                -- Saved offsets are in the toast's scaled space; divide by
                -- effective scale.
                local eff = f:GetScale()
                if eff == 0 then eff = 1 end
                f:SetPoint(savedPoint, UIParent, savedPoint, savedX / eff, savedY / eff)
            elseif anchored then
                -- Align to the panel's visible top (3px backdrop inset).
                f:SetPoint("TOPLEFT", panel, "TOPRIGHT", ANCHOR_GAP, -3)
            else
                f:SetPoint("CENTER", UIParent, "CENTER", BASE_X, BASE_Y)
            end
        else
            f:SetPoint("TOPLEFT", Presenter.live[i - 1], "BOTTOMLEFT", 0, -GAP)
        end
    end
end

-- Retro-pink base for the epic glow; pulse modulates its brightness.
local GLOW_PINK = { 1.0, 0.15, 0.55 }

-- Banner art per toast kind.
local BANNER_BY_KIND = {
    appearance = "Interface\\AddOns\\RetroRuns\\Media\\Toast\\toast-bg-appearance",
    special    = "Interface\\AddOns\\RetroRuns\\Media\\Toast\\toast-bg-special",
}

-- The glow's brightest alpha; a live toast's halo breathes down to
-- GLOW_BREATH_LOW of it and back, 1.6s each way.
local GLOW_PEAK_ALPHA  = 0.85 * 0.75
local GLOW_BREATH_LOW  = 0.55 / 0.75
local GLOW_BREATH_HALF = 1.6

-- Quality colors the icon ring (the rarity cue the banner doesn't carry) and,
-- unless glowColor forces one, the glow behind the toast. Every toast glows;
-- live ones breathe it (ShowOne). No quality falls back to brand pink.
local function StyleByQuality(toastFrame, quality, glowColor)
    local r, g, b
    if quality then
        r, g, b = C_Item.GetItemQualityColor(quality)
    end
    if not r then r, g, b = C_PINK[1], C_PINK[2], C_PINK[3] end
    toastFrame.iconRing:SetVertexColor(r, g, b, 1)
    toastFrame.iconRing:Show()
    toastFrame.glowColor = glowColor or { r, g, b }
    toastFrame.glowOn = true
    local glow = toastFrame.glowColor
    toastFrame.glow:SetVertexColor(glow[1], glow[2], glow[3], GLOW_PEAK_ALPHA)
    toastFrame.glow:Show()
end

-- Full-opacity hold (seconds) from toasterDuration, clamped 1.5..8.0.
local function EffectiveHold()
    local duration = (RR.GetSetting and RR:GetSetting("toasterDuration", 5.0)) or 5.0
    if duration < 1.5 then duration = 1.5 elseif duration > 8.0 then duration = 8.0 end
    return duration
end

local function StayUntilClick()
    return (RR.GetSetting and RR:GetSetting("toasterStayUntilClick", false)) and true or false
end

-- Remove a toast immediately: a right-click, or the end of its fade.
local function DismissToast(toastFrame)
    for i, lf in ipairs(Presenter.live) do
        if lf == toastFrame then table.remove(Presenter.live, i) break end
    end
    ReleaseFrame(toastFrame)
    Restack()
end

-- Open the dressing-room preview for whatever the toast represents. Preview
-- works in combat, so this path is deliberately not combat-gated.
local function PreviewToastItem(toastFrame)
    if toastFrame.sourceID and DressUpVisual then
        DressUpVisual(toastFrame.sourceID)
        return true
    elseif toastFrame.mountID and DressUpMount then
        DressUpMount(toastFrame.mountID)
        return true
    elseif toastFrame.petID and DressUpBattlePet and C_PetJournal then
        local speciesID, _, _, _, _, displayID, _, _, _, _, creatureID =
            C_PetJournal.GetPetInfoByPetID(toastFrame.petID)
        if creatureID and displayID and speciesID then
            DressUpBattlePet(creatureID, displayID, speciesID)
            return true
        end
    end
    return false
end

-- Opens the collection journal at this drop; ignored in combat. These helpers
-- retarget the wardrobe's class filter before navigating and restore it on
-- close.

-- One-shot restore: the player's class filter is captured before a retarget
-- and reapplied the first time the wardrobe hides after. Kept as file state
-- (not per-toast) because the restore fires on the wardrobe, not the toast.
local pendingClassFilterRestore = nil

local function RestoreClassFilterOnHide()
    if pendingClassFilterRestore == nil then return end
    local restoreTo = pendingClassFilterRestore
    pendingClassFilterRestore = nil
    if C_TransmogCollection and C_TransmogCollection.SetClassFilter then
        C_TransmogCollection.SetClassFilter(restoreTo)
    end
end

-- The wardrobe's class dropdown does not redraw its label when the filter
-- changes underneath it, so a filter switched while the frame is already
-- open keeps showing the old class. GenerateMenu re-evaluates the
-- selection from the live filter.
local function RefreshClassDropdownLabel()
    local dropdown = WardrobeCollectionFrame
        and WardrobeCollectionFrame.ClassDropdown
    if dropdown and dropdown.GenerateMenu
        and WardrobeCollectionFrame:IsShown() then
        pcall(dropdown.GenerateMenu, dropdown)
    end
end

-- Hook the wardrobe's OnHide exactly once. The frame is load-on-demand, so
-- this runs after the collection has been opened at least once.
local classFilterHookInstalled = false
local function EnsureClassFilterRestoreHook()
    if classFilterHookInstalled then return end
    local wardrobe = WardrobeCollectionFrame
    if not wardrobe then return end
    wardrobe:HookScript("OnHide", RestoreClassFilterOnHide)
    classFilterHookInstalled = true
end

-- The appearance's visualID drives the per-class validity check. GetSourceInfo
-- returns it under .visualID; the check itself takes the visualID, NOT the
-- sourceID.
local function VisualIDForSource(sourceID)
    if not (C_TransmogCollection and C_TransmogCollection.GetSourceInfo) then
        return nil
    end
    local info = C_TransmogCollection.GetSourceInfo(sourceID)
    return info and info.visualID or nil
end

local function ClassCanViewVisual(visualID, classID)
    if not (C_TransmogCollection
        and C_TransmogCollection.GetValidAppearanceSourcesForClass) then
        return true   -- can't check -> don't block the normal open
    end
    local sources = C_TransmogCollection.GetValidAppearanceSourcesForClass(
        visualID, classID)
    return sources ~= nil and #sources > 0
end

-- If the current class can't view the drop, pick the lowest-numbered class
-- that can and set the wardrobe filter to it, remembering the player's own
-- filter for restore. No-op (and no restore scheduled) when the current class
-- can already see it, or when the appearance can't be resolved.
local NUM_CLASSES = 13

-- False when the wardrobe cannot reach the drop at all, with the reason for
-- the click hint. Only a faction-locked source or a category no class is
-- offered. Unresolvable answers true.
local USE_ERROR_FACTION = 9

-- Which classes can use this sourceID, read from our own loot rows
-- (`classes` or `equipClasses`) rather than the client. Built once and cached.
local sourceClassIndex

local function BuildSourceClassIndex()
    sourceClassIndex = {}
    local function IndexLoot(loot)
        for _, item in ipairs(loot or {}) do
            local classes = item.classes or item.equipClasses
                or (item.restrictedToClass and { item.restrictedToClass })
            if classes and #classes > 0 and item.sources then
                for _, sourceID in pairs(item.sources) do
                    sourceClassIndex[sourceID] = classes
                end
                -- A faction pair's twin serves the same class.
                if item.mirror and item.mirror.sources then
                    for _, sourceID in pairs(item.mirror.sources) do
                        sourceClassIndex[sourceID] = classes
                    end
                end
            end
        end
    end
    for _, dataTable in ipairs({ RetroRuns_Data, RetroRuns_DataHorde }) do
        if type(dataTable) == "table" then
            for _, raid in pairs(dataTable) do
                for _, boss in ipairs(raid.bosses or {}) do
                    IndexLoot(boss.loot)
                end
                -- Trash is held at raid level, not under a boss, and it
                -- carries class-locked rows (Molten Core ships the whole
                -- T1 belt and bracer run there).
                IndexLoot(raid.trashLoot)
            end
        end
    end
end

-- A drop the data folds onto a same-look row has no row of its own, so the
-- classes of any indexed source sharing its appearance answer for it.
local function DataClassesForSource(sourceID, visualID)
    if not sourceClassIndex then
        BuildSourceClassIndex()
    end
    if sourceClassIndex[sourceID] or not visualID then
        return sourceClassIndex[sourceID]
    end
    local siblings = C_TransmogCollection.GetAllAppearanceSources
        and C_TransmogCollection.GetAllAppearanceSources(visualID)
    for _, siblingID in pairs(siblings or {}) do
        if sourceClassIndex[siblingID] then
            T(("retarget: classes from same-look source %d"):format(siblingID))
            return sourceClassIndex[siblingID]
        end
    end
    return nil
end

-- Is this category offered under the current class filter? Only the NAME from
-- GetCategoryInfo answers it.
--
-- The TransmogLocation for a category: GetSlotFromCategoryID for the slot
-- name, and GetTransmogLocation's third argument is the isSecondary boolean.
local FALLBACK_CATEGORY_SLOTS = {
    [1] = "HEADSLOT",  [2] = "SHOULDERSLOT", [3] = "BACKSLOT",
    [4] = "CHESTSLOT", [5] = "SHIRTSLOT",    [6] = "TABARDSLOT",
    [7] = "WRISTSLOT", [8] = "HANDSSLOT",    [9] = "WAISTSLOT",
    [10] = "LEGSSLOT", [11] = "FEETSLOT",
}

local function LocationForCategory(categoryID)
    if not categoryID then return nil end
    if not (TransmogUtil and TransmogUtil.GetTransmogLocation and Enum) then
        return nil
    end
    local slot
    if CollectionWardrobeUtil and CollectionWardrobeUtil.GetSlotFromCategoryID then
        slot = CollectionWardrobeUtil.GetSlotFromCategoryID(categoryID)
    end
    slot = slot or FALLBACK_CATEGORY_SLOTS[categoryID]
    -- GetSlotFromCategoryID doesn't cover weapon types. Shields report false
    -- for both hand flags, so anything without main hand takes secondary.
    if not slot then
        local name, isWeapon, _, canMainHand =
            C_TransmogCollection.GetCategoryInfo(categoryID)
        if name and isWeapon then
            slot = canMainHand and "MAINHANDSLOT" or "SECONDARYHANDSLOT"
        end
    end
    if not slot then return nil end
    return TransmogUtil.GetTransmogLocation(slot,
        Enum.TransmogType.Appearance, false)
end

-- Can the standard jump reach this category for this character? Armor always;
-- weapon types only when the player's own class can use them. The rest route
-- through direct navigation.
local function WeaponCategoryRange()
    local first = FIRST_TRANSMOG_COLLECTION_WEAPON_TYPE
    local last  = LAST_TRANSMOG_COLLECTION_WEAPON_TYPE
    if type(first) == "number" and type(last) == "number" then
        return first, last, true
    end
    return 12, 40, false
end

-- Mirrors WardrobeItemsCollectionMixin:IsValidWeaponCategoryForSlot for the
-- weapon-type half. Blizzard's SetActiveSlot shows the cost of getting it
-- wrong: an invalid category is nilled and replaced by the FIRST valid
-- weapon category, which is the wrong-page landing, in their own code.
local function CategoryNavigableForPlayer(categoryID)
    if not C_TransmogCollection.GetCategoryInfo then return nil, "no API" end
    local first, last, fromClient = WeaponCategoryRange()
    if categoryID < first or categoryID > last then
        return true, "armor slot"
    end

    local name, isWeapon, _, canMainHand, canOffHand =
        C_TransmogCollection.GetCategoryInfo(categoryID)
    if name == nil or name == "" then
        return false, ("unnamed%s"):format(fromClient and "" or " (range guessed)")
    end
    if not isWeapon then return true, name end

    local location = LocationForCategory(categoryID)
    if not location then return nil, "no location" end
    local isMainHand = location.IsMainHand and location:IsMainHand()
    local isOffHand  = location.IsOffHand  and location:IsOffHand()
    if (isMainHand and canMainHand) or (isOffHand and canOffHand) then
        return true, name
    end
    return false, ("%s: hand mismatch mh=%s/%s oh=%s/%s"):format(
        name, tostring(isMainHand), tostring(canMainHand),
        tostring(isOffHand), tostring(canOffHand))
end

-- Which class filter, if any, is offered this weapon-type category. Asked
-- with each candidate filter in effect and the original restored by the
-- caller. Synchronous: GetCategoryInfo answers immediately, unlike the
-- appearance list.

-- Set by the guard when a click's category is not offered to the player's
-- own class. Carries the class filter and category the direct navigation
-- will use.
local navPlan = nil

local function ClassOfferedCategory(categoryID, currentFilter)
    for classID = 1, NUM_CLASSES do
        if classID ~= currentFilter then
            C_TransmogCollection.SetClassFilter(classID)
            local name = C_TransmogCollection.GetCategoryInfo(categoryID)
            if name and name ~= "" then
                T(("crossclass: category %d offered to class %d (%s)")
                    :format(categoryID, classID, name))
                return classID
            end
        end
    end
    return nil
end

local function CategoryForSource(sourceID)
    if not C_TransmogCollection.GetAppearanceSourceInfo then return nil end
    local resolved = C_TransmogCollection.GetAppearanceSourceInfo(sourceID)
    if resolved then return resolved.category end
    return nil
end

local function PlayerCanBrowseSource(sourceID)
    if C_TransmogCollection and C_TransmogCollection.GetSourceInfo then
        local info = C_TransmogCollection.GetSourceInfo(sourceID)
        T(("guard: src=%s item=%s vis=%s valid=%s err=%s"):format(
            tostring(sourceID),
            tostring(info and info.itemID), tostring(info and info.visualID),
            tostring(info and info.isValidSourceForPlayer),
            tostring(info and info.useErrorType)))
        if info and info.isValidSourceForPlayer == false
            and info.useErrorType == USE_ERROR_FACTION then
            T("guard: refuse (faction)")
            return false, "faction"
        end
    end
    -- Hand-slot categories (weapon types, shields, held-in-off-hand) are
    -- offered per class filter; armor slots always are. Asked of the
    -- client, never inferred from the item's class.
    local categoryID = CategoryForSource(sourceID)
    if not categoryID then
        T("guard: allow (no category resolved)")
        return true
    end
    -- Against the player's own class. Failures route to direct navigation.
    local _, _, playerClassID = UnitClass("player")
    local originalFilter = C_TransmogCollection.GetClassFilter
        and C_TransmogCollection.GetClassFilter()
    if originalFilter == nil then
        T("guard: allow (no class filter available)")
        return true
    end
    local restoreNeeded = false
    if playerClassID and originalFilter ~= playerClassID then
        C_TransmogCollection.SetClassFilter(playerClassID)
        restoreNeeded = true
    end
    local offered, detail = CategoryNavigableForPlayer(categoryID)
    if restoreNeeded then
        C_TransmogCollection.SetClassFilter(originalFilter)
    end
    T(("guard: category=%d ownClass=%s offered=%s (%s)"):format(
        categoryID, tostring(playerClassID), tostring(offered),
        tostring(detail)))
    navPlan = nil
    if offered ~= false then return true end   -- nil = could not ask

    -- GoToSourceID with the category's own location and the force flag
    -- bypasses Blizzard's silent substitution.
    local target = ClassOfferedCategory(categoryID, originalFilter)
    C_TransmogCollection.SetClassFilter(originalFilter)
    if not target then
        T(("guard: refuse (no class is offered category %d)"):format(categoryID))
        return false, "class"
    end
    navPlan = { categoryID = categoryID, classID = target }
    T(("guard: allow (direct navigation, category %d via class %d)")
        :format(categoryID, target))
    return true
end

-- The hint text for a refusal, naming why the wardrobe won't go there.
-- The faction line names the faction that CAN browse it, which is always
-- the one the player is not.
local function HintTextForReason(reason)
    if reason == "faction" then
        local otherFaction = (UnitFactionGroup("player") == "Horde")
            and (FACTION_ALLIANCE or RR.L["Alliance"])
            or  (FACTION_HORDE or RR.L["Horde"])
        return (RR.L["Browse locked to %s. Ctrl+Left Click for Preview"])
            :format(otherFaction)
    end
    return RR.L["Browse locked to classes that can equip this. Ctrl+Left Click for Preview"]
end

-- How long a click hint stays up before hiding itself.
local HINT_HOLD = 4

-- Show the click hint beside a toast. The token guards the timer: a second
-- click (or the frame being pooled) invalidates an earlier pending hide, so
-- the hint never vanishes early or outlives its toast.
local function ShowToastHint(toastFrame, text)
    if not toastFrame.hint then return end
    toastFrame.hint:SetText(text)
    toastFrame.hint:Show()
    toastFrame.hintToken = (toastFrame.hintToken or 0) + 1
    local token = toastFrame.hintToken
    C_Timer.After(HINT_HOLD, function()
        if toastFrame.hintToken == token and toastFrame.hint then
            toastFrame.hint:Hide()
        end
    end)
end


-- Returns true when the filter was actually changed.
local function RetargetClassFilterForSource(sourceID)
    if not (C_TransmogCollection
        and C_TransmogCollection.GetClassFilter
        and C_TransmogCollection.SetClassFilter) then
        return false
    end
    local visualID = VisualIDForSource(sourceID)
    if not visualID then return false end

    local currentFilter = C_TransmogCollection.GetClassFilter
        and C_TransmogCollection.GetClassFilter()
    if currentFilter == nil then return false end

    -- Our data first, where it has an answer. A row listing the classes that
    -- can use the drop settles which filter to browse under, and is trusted
    -- over the capability API, which over-reports for class-locked gear.
    local dataClasses = DataClassesForSource(sourceID, visualID)
    if dataClasses then
        for _, classID in ipairs(dataClasses) do
            if classID == currentFilter then
                T(("retarget: data says current filter %d already fits")
                    :format(currentFilter))
                return false
            end
        end
        local target = dataClasses[1]
        T(("retarget: data classes -> filter %s (was %s)"):format(
            tostring(target), tostring(currentFilter)))
        if target then
            -- Capture only the first un-restored filter: consecutive toast
            -- clicks with the wardrobe still open must restore to the
            -- filter the PLAYER had, not to an intermediate borrowed one.
            if pendingClassFilterRestore == nil then
                pendingClassFilterRestore = currentFilter
            end
            C_TransmogCollection.SetClassFilter(target)
            RefreshClassDropdownLabel()
            return true
        end
        return false
    end

    -- No row for this source or any sharing its look: fall back to the
    -- capability API, which over-reports only for class-locked gear.
    if ClassCanViewVisual(visualID, currentFilter) then
        return false   -- current class already sees it; leave the filter alone
    end

    for classID = 1, NUM_CLASSES do
        if classID ~= currentFilter and ClassCanViewVisual(visualID, classID) then
            T(("retarget: capability -> filter %d (was %s)"):format(
                classID, tostring(currentFilter)))
            if pendingClassFilterRestore == nil then
                pendingClassFilterRestore = currentFilter
            end
            C_TransmogCollection.SetClassFilter(classID)
            RefreshClassDropdownLabel()
            return true
        end
    end
    -- No class can view it (nothing to do; the normal open still runs).
    return false
end

-- Rebuilds the items collection after a class-filter change. The wardrobe
-- does this itself only when the frame is already visible.
local function RefreshItemsCollectionAfterFilterChange()
    local itemsFrame = WardrobeCollectionFrame
        and WardrobeCollectionFrame.ItemsCollectionFrame
    if not (itemsFrame and itemsFrame.IsVisible and itemsFrame:IsVisible()) then
        T("refresh: items collection not visible, nothing to rebuild")
        return
    end
    -- Re-dress every model for the landed slot, as the wardrobe's own OnShow
    -- does: a slot change only diffs gear against the previous slot.
    if itemsFrame.ChangeModelsSlot and itemsFrame.transmogLocation then
        pcall(itemsFrame.ChangeModelsSlot, itemsFrame, itemsFrame.transmogLocation)
    end
    if itemsFrame.RefreshVisualsList then
        pcall(itemsFrame.RefreshVisualsList, itemsFrame)
    end
    if itemsFrame.UpdateItems then
        pcall(itemsFrame.UpdateItems, itemsFrame)
    end
    T("refresh: items collection rebuilt after filter change")
end

local function OpenToastInJournal(toastFrame)
    -- Every path below ends in a Blizzard call that toggles the Collections
    -- journal, and that journal's tabs are protected: called in combat it
    -- blocks on MountJournal:SetShown() and blames this addon. The block
    -- surfaces LATER, on some unrelated protected action, so the click that
    -- caused it is long gone by the time anything looks wrong.
    if InCombatLockdown and InCombatLockdown() then
        T("open: refused -- in combat")
        ShowToastHint(toastFrame, RR.L["Browse locked in combat"])
        return true
    end
    if toastFrame.sourceID then
        -- An appearance the wardrobe won't navigate to for this character
        -- has no page to open, so a normal click would strand the player on
        -- an unrelated default page. Say why instead, and point at the
        -- preview, which works for any appearance.
        local canBrowse, reason = PlayerCanBrowseSource(toastFrame.sourceID)
        if not canBrowse then
            -- hint is nil on a frame built without one; the hint would then
            -- be silently dropped and the click would look like a no-op.
            T(("open: hint reason=%s hintFrame=%s"):format(
                tostring(reason), tostring(toastFrame.hint ~= nil)))
            ShowToastHint(toastFrame, HintTextForReason(reason))
            return true
        end
        if TransmogUtil and TransmogUtil.OpenCollectionToItem then
            -- Load the wardrobe first so the OnHide restore hook can attach
            -- before the filter is retargeted. It's load-on-demand, so on the
            -- first appearance-toast click the frame otherwise wouldn't exist
            -- yet when the retarget runs, and the changed filter would never
            -- be restored.
            if not CollectionsJournal and CollectionsJournal_LoadUI then
                CollectionsJournal_LoadUI()
            end
            EnsureClassFilterRestoreHook()

            -- Not offered to the player's class, so navigate directly.
            local plan = navPlan
            navPlan = nil
            if plan and classFilterHookInstalled then
                local itemsFrame = WardrobeCollectionFrame
                    and WardrobeCollectionFrame.ItemsCollectionFrame
                if itemsFrame and itemsFrame.GoToSourceID then
                    -- The filter switches before the location is built:
                    -- weapon-category slots resolve from GetCategoryInfo,
                    -- which only answers under a filter whose class can use
                    -- the category.
                    local currentFilter = C_TransmogCollection.GetClassFilter
                        and C_TransmogCollection.GetClassFilter()
                    local filterSwitched = false
                    if currentFilter and currentFilter ~= plan.classID then
                        if pendingClassFilterRestore == nil then
                            pendingClassFilterRestore = currentFilter
                        end
                        C_TransmogCollection.SetClassFilter(plan.classID)
                        filterSwitched = true
                    end
                    local location = LocationForCategory(plan.categoryID)
                    if not location then
                        -- Put the filter back; the plain open below runs on
                        -- the player's own settings.
                        if filterSwitched then
                            RestoreClassFilterOnHide()
                        end
                        T(("open: no location for category %d, falling back "
                            .. "to plain open"):format(plan.categoryID))
                    else
                        if CollectionsJournal
                            and not CollectionsJournal:IsShown()
                            and SetCollectionsJournalShown then
                            SetCollectionsJournalShown(true,
                                COLLECTIONS_JOURNAL_TAB_INDEX_APPEARANCES)
                        end
                        local sourceID = toastFrame.sourceID
                        T(("open: direct GoToSourceID(%d) category %d via class %d")
                            :format(sourceID, plan.categoryID, plan.classID))
                        -- One frame's delay lets the filter change and the
                        -- wardrobe's show settle before the jump.
                        C_Timer.After(0.1, function()
                            pcall(itemsFrame.GoToSourceID, itemsFrame,
                                sourceID, location, true)
                            RefreshClassDropdownLabel()
                            T("open: direct navigation done")
                        end)
                        return true
                    end
                else
                    T("open: direct navigation unavailable, falling back to plain open")
                end
            end

            -- Only retarget if the restore hook is in place; a filter change
            -- with no way to undo it would silently alter the player's
            -- wardrobe. If the hook didn't install, fall through to a plain
            -- open on the player's own filter.
            local filterRetargeted = false
            if classFilterHookInstalled then
                filterRetargeted =
                    RetargetClassFilterForSource(toastFrame.sourceID)
            end
            -- After a new appearance the wardrobe's OnShow first jumps to that
            -- appearance's slot, and our jump then diffs gear away from it.
            local wardrobeItems = WardrobeCollectionFrame
                and WardrobeCollectionFrame.ItemsCollectionFrame
            local latestJump = wardrobeItems and wardrobeItems.jumpToLatestCategoryID
                and not (CollectionsJournal and CollectionsJournal:IsShown())
            T(("open: OpenCollectionToItem(%s) journalLoaded=%s hook=%s latestJump=%s"):format(
                tostring(toastFrame.sourceID),
                tostring(CollectionsJournal ~= nil),
                tostring(classFilterHookInstalled), tostring(latestJump)))
            TransmogUtil.OpenCollectionToItem(toastFrame.sourceID)
            T("open: OpenCollectionToItem returned; journalShown="
                .. tostring(CollectionsJournal and CollectionsJournal:IsShown()))
            -- Next frame, so the show and the jump have both settled.
            if filterRetargeted or latestJump then
                C_Timer.After(0, RefreshItemsCollectionAfterFilterChange)
            end
            return true
        end
        T("open: no TransmogUtil.OpenCollectionToItem -- unhandled")
        return false
    end

    if not (toastFrame.mountID or toastFrame.petID or toastFrame.toyID) then
        return false
    end
    if not CollectionsJournal and CollectionsJournal_LoadUI then
        CollectionsJournal_LoadUI()
    end
    if not CollectionsJournal or not SetCollectionsJournalShown then return false end

    if toastFrame.mountID then
        SetCollectionsJournalShown(true, COLLECTIONS_JOURNAL_TAB_INDEX_MOUNTS)
        if MountJournal_SelectByMountID then
            MountJournal_SelectByMountID(toastFrame.mountID)
        end
    elseif toastFrame.petID then
        SetCollectionsJournalShown(true, COLLECTIONS_JOURNAL_TAB_INDEX_PETS)
        if PetJournal_SelectPet then
            PetJournal_SelectPet(PetJournal, toastFrame.petID)
        end
    else
        SetCollectionsJournalShown(true, COLLECTIONS_JOURNAL_TAB_INDEX_TOYS)
    end
    return true
end

-- Right-click dismisses; left-click opens the collection journal, or previews
-- with the dress-up modifier held. Every click writes to the trace ring.
local function ToastOnClick(toastFrame, button)
    T(("click: button=%s src=%s mount=%s pet=%s toy=%s special=%s"):format(
        tostring(button), tostring(toastFrame.sourceID),
        tostring(toastFrame.mountID), tostring(toastFrame.petID),
        tostring(toastFrame.toyID), tostring(toastFrame.specialKind)))
    if button == "RightButton" then
        T("click: right -> dismiss")
        DismissToast(toastFrame)
        return
    end
    if IsModifiedClick and IsModifiedClick("DRESSUP") then
        local previewed = PreviewToastItem(toastFrame)
        T("click: dressup-modifier -> preview handled=" .. tostring(previewed))
    else
        local opened = OpenToastInJournal(toastFrame)
        T("click: left -> journal handled=" .. tostring(opened))
    end
end

-- A toast's fade-in: alpha 0 to 1 over FADE_IN, kept at 1 when done. Live
-- toasts and the settings preview share it.
local function BuildFadeIn(toastFrame)
    if toastFrame.fadeIn then return end
    toastFrame.fadeIn = toastFrame:CreateAnimationGroup()
    toastFrame.fadeIn:SetToFinalAlpha(true)
    local rise = toastFrame.fadeIn:CreateAnimation("Alpha")
    rise:SetFromAlpha(0)
    rise:SetToAlpha(1)
    rise:SetDuration(FADE_IN)
end

-- A live toast fades in, holds, then fades out over FADE_OUT. The fades are
-- native animations that keep their end alpha; the hold is a timer counted
-- from the start. Built once per pooled frame.
local function BuildToastFade(toastFrame)
    if toastFrame.fadeOut then return end
    BuildFadeIn(toastFrame)
    toastFrame.fadeOut = toastFrame:CreateAnimationGroup()
    toastFrame.fadeOut:SetToFinalAlpha(true)
    toastFrame.fadeOutAlpha = toastFrame.fadeOut:CreateAnimation("Alpha")
    toastFrame.fadeOutAlpha:SetToAlpha(0)
    toastFrame.fadeOut:SetScript("OnFinished", function() DismissToast(toastFrame) end)
end

-- The fade-out from `fromAlpha` (1, or wherever a hover stopped it), at the
-- full fade's rate.
local function PlayFadeOut(toastFrame, fromAlpha)
    toastFrame.fadeFrom = fromAlpha
    toastFrame.fadeOutAlpha:SetFromAlpha(fromAlpha)
    toastFrame.fadeOutAlpha:SetDuration(FADE_OUT * fromAlpha)
    toastFrame.fadeOut:Play()
end

local function StartHold(toastFrame, seconds)
    toastFrame.holdEnds = GetTime() + seconds
    toastFrame.holdTimer = C_Timer.NewTimer(seconds, function()
        toastFrame.holdTimer, toastFrame.holdEnds = nil, nil
        PlayFadeOut(toastFrame, 1)
    end)
end

-- Starts a live toast's fade, or restarts it on a merge. Hovering brings it
-- to full opacity and pauses whatever hold or fade-out was left.
local function StartFade(toastFrame)
    toastFrame:EnableMouse(true)
    toastFrame:SetScript("OnMouseDown", nil)
    toastFrame:SetScript("OnClick", ToastOnClick)

    BuildToastFade(toastFrame)
    StopToastFade(toastFrame)
    toastFrame.hoverStart = nil
    toastFrame:SetScript("OnEnter", function(self)
        self.hoverStart = GetTime()
        if self.holdTimer then
            self.holdLeft = self.holdEnds - self.hoverStart
            self.holdTimer:Cancel()
            self.holdTimer, self.holdEnds = nil, nil
        end
        if self.fadeOut:IsPlaying() then
            self.resumeAlpha = self.fadeFrom * (1 - self.fadeOutAlpha:GetProgress())
        end
        self.fadeIn:Stop()
        self.fadeOut:Stop()
        self:SetAlpha(1)
    end)
    toastFrame:SetScript("OnLeave", function(self)
        if not self.hoverStart then return end
        self.hoverStart = nil
        if self.resumeAlpha then
            PlayFadeOut(self, self.resumeAlpha)
            self.resumeAlpha = nil
        elseif self.holdLeft then
            StartHold(self, math.max(0, self.holdLeft))
            self.holdLeft = nil
        end
    end)

    toastFrame:SetAlpha(0)
    toastFrame.fadeIn:Play()
    if not StayUntilClick() then
        StartHold(toastFrame, FADE_IN + EffectiveHold())
    end
end

-- Apply item content (icon, name, quality, banner, glow) to a frame from a
-- descriptor. Separate from ShowOne so an async name load can refresh a visible
-- toast in place.
local function ApplyContent(toastFrame, toast)
    toastFrame.icon:SetTexture(toast.icon or "Interface\\Icons\\INV_Misc_QuestionMark")
    toastFrame.itemNameText:SetText(toast.name or "")
    local r, g, b
    if toast.quality then r, g, b = C_Item.GetItemQualityColor(toast.quality) end
    toastFrame.itemNameText:SetTextColor(r or 1, g or 1, b or 1)
    toastFrame.banner:SetTexture(BANNER_BY_KIND[toast.isSpecial and "special" or "appearance"])
    StyleByQuality(toastFrame, toast.quality, toast.glowColor)
end

-- Scale = base x windowScale x toasterScale.
local function EffectiveToastScale()
    local userScale  = (RR.GetSetting and RR:GetSetting("windowScale", 1.0)) or 1.0
    local toastScale = (RR.GetSetting and RR:GetSetting("toasterScale", 1.0)) or 1.0
    return TOAST_SCALE * userScale * toastScale
end

local function ShowOne(toast)
    local toastFrame = AcquireFrame()

    -- Click-action identity. Only set on live toasts; the settings preview
    -- builds frames through the same constructor but never populates these,
    -- so a preview toast has nothing to act on.
    toastFrame.sourceID = toast.sourceID
    toastFrame.mountID  = toast.mountID
    toastFrame.petID    = toast.petID
    toastFrame.toyID    = toast.isSpecial and toast.itemID or nil

    toastFrame:SetScale(EffectiveToastScale())

    ApplyToastFonts(toastFrame)

    toastFrame.header:SetText(toast.header and ToastHeaderText(toast.header) or "RETRORUNS")
    ApplyContent(toastFrame, toast)
    RR.UI.SetBreathing(toastFrame.glow, true, GLOW_BREATH_LOW, GLOW_BREATH_HALF)

    -- Let a pending item load refresh this frame.
    toast.frame = toastFrame

    -- Append at the tail so every toast joins the bottom of the stack, no
    -- matter which batch it came from or when its reveal timer fires. Restack
    -- pins the head to the anchor and chains the rest downward, so the stack
    -- always cascades top-to-bottom. Front-inserting here let a later reveal
    -- jump to the top and flip the growth direction mid-cascade.
    Presenter.live[#Presenter.live + 1] = toastFrame
    toastFrame:SetAlpha(0)
    toastFrame:Show()
    Restack()
    StartFade(toastFrame)

    -- Coin chime on the SFX channel. Final toast in a batch plays the ring-out.
    -- No-ops if the file is missing; off via the sound setting.
    if RR:GetSetting("toasterSound", true) ~= false then
        PlaySoundFile(toast.isFinal and COIN_FINAL_SOUND or COIN_SOUND, "SFX")
    end

    return toastFrame
end

local APPEARANCE_TOAST_CAP = 5   -- max individual appearance toasts before collapsing the rest

function Presenter.RevealBatch(batch)
    if not batch or #batch == 0 then return end

    -- Keep all special loot and the first APPEARANCE_TOAST_CAP appearances;
    -- collapse the rest into one summary toast.
    local appearanceCount = 0
    for _, toast in ipairs(batch) do
        if toast.isAppearance then appearanceCount = appearanceCount + 1 end
    end

    if appearanceCount > APPEARANCE_TOAST_CAP then
        local kept = {}
        local shownAppearances = 0
        local overflowIcon
        for _, toast in ipairs(batch) do
            if toast.isAppearance then
                if shownAppearances < APPEARANCE_TOAST_CAP then
                    kept[#kept + 1] = toast
                    shownAppearances = shownAppearances + 1
                else
                    overflowIcon = overflowIcon or toast.icon
                end
            else
                kept[#kept + 1] = toast   -- special loot always kept
            end
        end
        local overflow = appearanceCount - APPEARANCE_TOAST_CAP
        -- Summary toast: appearance banner, name is the overflow count.
        kept[#kept + 1] = {
            header       = "New Appearance",
            icon         = overflowIcon,
            name         = (RR.L["Plus %d others..."]):format(overflow),
            quality      = nil,
            glowColor    = GLOW_PINK,
            isAppearance = true,
            isOverflow   = true,
        }
        batch = kept
    end

    local delay = 0
    for i, toast in ipairs(batch) do
        toast.isFinal = (i == #batch)
        C_Timer.After(delay, function()
            if M.enabled then ShowOne(toast) end
        end)
        delay = delay + STAGGER
    end
end

-- Resolve uncached names (bounded wait), then reveal once, so the toasts open
-- with their final names.
local function RevealWhenNamesReady(batch, attempt)
    if not batch or #batch == 0 then return end
    attempt = attempt or 0

    local pending = false
    for _, toast in ipairs(batch) do
        -- Special Loot toasts may have no item name; don't wait on those.
        if toast.itemID and (not toast.name or toast.name == "") then
            local name, _, quality = C_Item.GetItemInfo(toast.itemID)
            if name then
                toast.name = name
                toast.quality = toast.quality or quality
            else
                pending = true
            end
        end
    end

    if pending and attempt < 20 then          -- ~2s at 0.1s spacing, then reveal anyway
        C_Timer.After(0.1, function() RevealWhenNamesReady(batch, attempt + 1) end)
        return
    end

    Presenter.RevealBatch(batch)
end

function Presenter.Clear()
    for _, f in ipairs(Presenter.live) do ReleaseFrame(f) end
    wipe(Presenter.live)
end

-- Forward declarations: the unlock overlay (built lazily below) is referenced
-- by ApplyToasterScale, which is defined first.
local UnlockOverlay
local PositionUnlockOverlay

-- Push the current scale settings to any on-screen toasts immediately, so a
-- change to the toast-scale slider takes effect live rather than only on the
-- next drop.
function RR:ApplyToasterScale()
    local scale = EffectiveToastScale()
    for _, f in ipairs(Presenter.live) do
        f:SetScale(scale)
    end
    Restack()
    if UnlockOverlay and UnlockOverlay:IsShown() then PositionUnlockOverlay() end
end

-- A sample toast for the settings previews and the drag overlay, built from
-- { header, itemID, icon?, name? }. Not pooled, never live: the glow is tinted
-- once, and an uncached item's name fills in when it loads. A sample with its
-- own name mirrors a mount row, whose live toast shows the journal name.
local function BuildSampleToast(parent, sample)
    local toast = ConstructToastFrame(parent)
    local isAppearance = (sample.header == "New Appearance")
    local name = (sample.name and RR.L[sample.name])
        or C_Item.GetItemInfo(sample.itemID) or ""
    ApplyContent(toast, {
        icon = sample.icon or C_Item.GetItemIconByID(sample.itemID),
        name = name, quality = 4,
        glowColor = isAppearance and GLOW_PINK or nil,
        isAppearance = isAppearance, isSpecial = not isAppearance,
    })
    toast.header:SetText(ToastHeaderText(sample.header))
    -- Boosted and still, since the samples sit small and only live toasts
    -- breathe.
    local glow = toast.glowColor
    toast.glow:SetVertexColor(math.min(glow[1] * 1.35, 1), math.min(glow[2] * 1.35, 1),
        math.min(glow[3] * 1.35, 1), 1)
    if name == "" then
        local waiter = CreateFrame("Frame")
        waiter:RegisterEvent("GET_ITEM_INFO_RECEIVED")
        waiter:SetScript("OnEvent", function()
            local itemName = C_Item.GetItemInfo(sample.itemID)
            if itemName then
                toast.itemNameText:SetText(itemName)
                local icon = not sample.icon and C_Item.GetItemIconByID(sample.itemID)
                if icon then toast.icon:SetTexture(icon) end
                waiter:UnregisterAllEvents()
            end
        end)
    end
    return toast
end

-------------------------------------------------------------------------------
-- Unlock overlay: a free-floating sample stack the user drags to set the toast
-- position. Hidden while locked (the default); shown when "Lock" is unchecked.
-------------------------------------------------------------------------------
local function BuildUnlockOverlay()
    if UnlockOverlay then return UnlockOverlay end

    local overlay = CreateFrame("Button", "RetroRunsToasterUnlock", UIParent)
    overlay:SetFrameStrata("FULLSCREEN_DIALOG")
    overlay:SetMovable(true)
    overlay:EnableMouse(true)
    overlay:RegisterForDrag("LeftButton")
    overlay:SetClampedToScreen(true)
    -- No backdrop/border on the overlay itself; it's the drag-catcher. The two
    -- sample toasts carry their own borders.

    -- Two sample toasts inside the frame, mouse-disabled so the drag is caught
    -- by the overlay button.
    local SAMPLES = {
        { header = "New Appearance", itemID = 18832, icon = "Interface\\Icons\\INV_Sword_39" },
        { header = "Special Loot",   itemID = 43953, icon = "Interface\\Icons\\Ability_Mount_Drake_Blue" },
    }
    overlay.samples = {}
    for i, sample in ipairs(SAMPLES) do
        local toast = BuildSampleToast(overlay, sample)
        toast:EnableMouse(false)
        toast:SetFrameStrata(overlay:GetFrameStrata())
        toast:SetFrameLevel(overlay:GetFrameLevel() + 1)
        overlay.samples[i] = toast
    end

    -- Hint caption above the frame. Carries a translated string, so it takes
    -- the chrome font: the pixel face covers ASCII only.
    local label = overlay:CreateFontString(nil, "OVERLAY")
    RR.SafeSetFont(label, RR:GetChromeFont(), 12, "OUTLINE")
    label:SetPoint("BOTTOMLEFT", overlay, "TOPLEFT", 0, 4)
    label:SetText(RR.L["Drag to move"])
    label:SetJustifyH("LEFT")
    label:SetTextColor(1, 0.7, 0.9, 1)
    overlay.label = label

    overlay:SetScript("OnDragStart", function(self)
        self:StartMoving()
        self.isMoving = true
    end)
    overlay:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        self.isMoving = nil
        -- Save a stable anchor from where the frame landed.
        local point, x, y = DeriveAnchor(self)
        RR:SetSetting("toasterAnchor", { point = point, x = x, y = y })
        Restack()
    end)

    overlay:Hide()
    UnlockOverlay = overlay
    return overlay
end

-- Position + size the overlay to match a 2-toast sample stack at the current
-- scale, at the toasts' current anchor.
PositionUnlockOverlay = function()
    local overlay = UnlockOverlay
    if not overlay then return end
    local eff = EffectiveToastScale()
    local overlayWidth = TOAST_W_FIXED * eff
    local overlayHeight = (TOAST_H * 2 + GAP) * eff
    overlay:SetSize(overlayWidth, overlayHeight)

    -- Lay the samples at the live scale, chained with GAP, mirroring Restack.
    if overlay.samples then
        for i, t in ipairs(overlay.samples) do
            t:SetScale(eff)
            t:ClearAllPoints()
            if i == 1 then
                t:SetPoint("TOPLEFT", overlay, "TOPLEFT", 0, 0)
            else
                t:SetPoint("TOPLEFT", overlay.samples[i - 1], "BOTTOMLEFT", 0, -GAP)
            end
            t:Show()
        end
    end

    overlay:ClearAllPoints()
    local savedPoint, savedX, savedY = GetSavedAnchor()
    if savedPoint then
        overlay:SetPoint(savedPoint, UIParent, savedPoint, savedX, savedY)
    else
        local panel = _G.RetroRunsMainFrame
        if panel then
            overlay:SetPoint("TOPLEFT", panel, "TOPRIGHT", ANCHOR_GAP * eff, -3 * eff)
        else
            overlay:SetPoint("CENTER", UIParent, "CENTER", BASE_X, BASE_Y)
        end
    end
end

-- Public lock/unlock entry points driven by the Customize "Lock" checkbox.
function RR:UnlockToasterAnchor()
    BuildUnlockOverlay()
    PositionUnlockOverlay()
    UnlockOverlay:Show()
end
function RR:LockToasterAnchor()
    if UnlockOverlay then UnlockOverlay:Hide() end
end
-- Reset the toast position back to the panel-relative default.
function RR:ResetToasterAnchor()
    if RR.SetSetting then RR:SetSetting("toasterAnchor", nil) end
    if UnlockOverlay and UnlockOverlay:IsShown() then PositionUnlockOverlay() end
    Restack()
end

-- Re-fonts every toast on screen or in settings after a font change.
function RR:RefreshToasterFonts()
    for _, toastFrame in ipairs(Presenter.live) do ApplyToastFonts(toastFrame) end
    for _, toastFrame in ipairs((UnlockOverlay and UnlockOverlay.samples) or {}) do
        ApplyToastFonts(toastFrame)
    end
    if RR._toasterPreviewGroup then RR._toasterPreviewGroup:RefreshFonts() end
    if RR._toasterMock then RR._toasterMock:RefreshFonts() end
end

-------------------------------------------------------------------------------
-- Source: capture the same drop events and route to the presenter.
-------------------------------------------------------------------------------

-- Summary subsystem state. Drops accumulate into one batch that flushes once no
-- new drop has arrived for QUIET_FLUSH seconds (not on LOOT_CLOSED).
local Summary = {
    frame      = nil,    -- listens for the loot bracket events
    capturing  = false,  -- capture gate: open from LOOT_OPENED until the flush runs
    windowOpen = false,  -- true between LOOT_OPENED and LOOT_CLOSED
    batch      = nil,    -- toast descriptors accumulating for the current flush
    links      = nil,    -- vendor-grade item links for the current flush
    newApp     = nil,    -- set: itemID -> true for new appearances this flush
    seenVisual = nil,    -- set: visualID -> true, to dedupe sources of one appearance
    flushTimer = nil,    -- pending C_Timer handle for the quiet-period flush
    lockout    = nil,    -- lockout id the store belongs to
    store      = {},     -- lineID -> { items = {...} }
    nextID     = 1,      -- monotonic line id within a lockout
    clickHooked = false,
    expected   = 0,      -- item slots seen in the loot windows of this batch
    received   = 0,      -- loot lines captured in this batch
    windowCounted = false, -- this window's slots already added to expected
}
-- Flush once no new drop has arrived for this long. The longer grace after
-- LOOT_CLOSED catches the straggler wave.
local QUIET_FLUSH = 0.5
local POST_CLOSE_GRACE = 1.5
-- Once every counted item has its loot line and the window is shut, only the
-- appearance events are still to come, a few frames behind their lines.
local COMPLETE_TAIL = 0.2

local FlushBatch  -- forward declaration (defined below, after the formatters)
local QualityColoredLink  -- forward declaration (FlushBatch needs it as an upvalue)

-- True when itemID is a tier token for the current raid. Listed in the raid
-- data's tierSets.tokenSources.
local function IsTierToken(itemID)
    if not itemID then return false end
    local raid = RR.currentRaid
    local tokenSources = raid and raid.tierSets and raid.tierSets.tokenSources
    return tokenSources ~= nil and tokenSources[itemID] ~= nil
end

-- (Re)arm the quiet-period flush; re-arming cancels the prior pending flush.
-- delay defaults to QUIET_FLUSH; LOOT_CLOSED passes POST_CLOSE_GRACE to give
-- the straggler wave more slack.
local function ArmFlush(delay)
    if Summary.flushTimer then
        Summary.flushTimer:Cancel()
    end
    delay = delay or QUIET_FLUSH
    -- Every counted item has arrived: nothing but the appearance events is
    -- left to wait for, so the straggler grace no longer applies.
    if Summary.expected > 0 and Summary.received >= Summary.expected
        and not Summary.windowOpen and delay > COMPLETE_TAIL then
        delay = COMPLETE_TAIL
    end
    Summary.flushTimer = C_Timer.NewTimer(delay, function()
        Summary.flushTimer = nil
        -- Don't flush while the loot window is still open; re-arm instead.
        if Summary.windowOpen then
            ArmFlush()
            return
        end
        FlushBatch()
    end)
end

-- Resolve a special-loot collection event (mount/pet/toy) to a name, icon, and
-- chat link. Returns name, icon, itemID (toys only), kindLabel, link; any may
-- be nil if the journal can't resolve it yet.
local function ResolveSpecialLoot(event, id)
    if event == "NEW_MOUNT_ADDED" then
        if C_MountJournal and C_MountJournal.GetMountInfoByID then
            local name, spellID, icon = C_MountJournal.GetMountInfoByID(id)
            -- Mounts link via their summon spell.
            local link
            if spellID then
                link = C_Spell.GetSpellLink(spellID)
            end
            return name, icon, nil, "Mount", link
        end
    elseif event == "NEW_PET_ADDED" then
        if C_PetJournal and C_PetJournal.GetPetInfoByPetID then
            local _, _, _, _, _, _, _, name, icon = C_PetJournal.GetPetInfoByPetID(id)
            local link = C_PetJournal.GetBattlePetLink and C_PetJournal.GetBattlePetLink(id)
            return name, icon, nil, "Pet", link
        end
    elseif event == "NEW_TOY_ADDED" then
        if C_ToyBox and C_ToyBox.GetToyInfo then
            local itemID, toyName, icon = C_ToyBox.GetToyInfo(id)
            local link = itemID and select(2, C_Item.GetItemInfo("item:" .. itemID))
            return toyName, icon, itemID, "Toy", link
        end
    end
    return nil, nil, nil, "Special", nil
end

local function QueueToast(toast)
    -- Lazily created so a drop outside any LOOT_OPENED window still joins.
    if not Summary.batch then Summary.batch = {} end
    Summary.batch[#Summary.batch + 1] = toast
    ArmFlush()
end

-- Pattern matching Blizzard's "You've collected the appearance" system line,
-- built from the localized global. Nil (no filtering) if the global is missing.
local TRANSMOG_COLLECTED_PATTERN
do
    local learnTemplate = _G.ERR_LEARN_TRANSMOG_S  -- "%s has been added to your appearance collection."
    if type(learnTemplate) == "string" then
        -- Escape Lua magic chars, then turn the %s into a wildcard.
        local lit = learnTemplate:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")
        TRANSMOG_COLLECTED_PATTERN = lit:gsub("%%%%s", ".*")
    end
end

local function OnDropEvent(_, event, ...)
    if not M.enabled then return end

    -- Raw system-line stream. Logs every CHAT_MSG_SYSTEM the client
    -- receives, with secret-status and (if readable) pattern-match, so the
    -- event-to-line relationship and the secret-leak path can be
    -- correlated against the appearance events in a single debug dump.
    if event == "CHAT_MSG_SYSTEM" then
        local rawmsg = ...
        local isSecret = issecretvalue and issecretvalue(rawmsg) or false
        -- lineID (arg 11 of CHAT_MSG_SYSTEM) is a per-message id. Logging it
        -- lets the same system line be correlated across the raw event stream
        -- and any other interception layer, confirming whether the event we see
        -- and the line that reaches chat are literally the same message.
        local lineID = select(11, ...)
        local matched = "n/a"
        if not isSecret and type(rawmsg) == "string" and TRANSMOG_COLLECTED_PATTERN then
            matched = rawmsg:match(TRANSMOG_COLLECTED_PATTERN) and "MATCH" or "nomatch"
        end
        T(("RAW CHAT_MSG_SYSTEM  secret=%s  match=%s  capturing=%s  lineID=%s")
            :format(tostring(isSecret), matched, tostring(Summary.capturing),
                    tostring(lineID)))
        return
    end

    local kind = EVENT_KIND[event]
    if not kind then return end
    T("OnDropEvent " .. tostring(event) .. " kind=" .. tostring(kind))

    if kind == "collection" then
        local id = ...
        -- Toast only a genuinely new collection; suppress for an item the
        -- player already owns.
        if event == "NEW_PET_ADDED" and C_PetJournal then
            -- Toast only the first of a pet species; suppress owned dupes.
            local speciesID
            if C_PetJournal.GetPetInfoByPetID then
                speciesID = select(1, C_PetJournal.GetPetInfoByPetID(id))
            end
            if speciesID and C_PetJournal.GetNumCollectedInfo then
                local numCollected = C_PetJournal.GetNumCollectedInfo(speciesID)
                if numCollected and numCollected > 1 then
                    T("NEW_PET_ADDED suppressed (dupe, owned " .. numCollected .. ")")
                    return
                end
            end
        elseif event == "NEW_MOUNT_ADDED" and C_MountJournal then
            -- isCollected is position 11; suppress the popup for an owned mount.
            if C_MountJournal.GetMountInfoByID then
                local isCollected = select(11, C_MountJournal.GetMountInfoByID(id))
                if isCollected == false then
                    -- genuinely new, allow toast
                elseif isCollected == true then
                    T("NEW_MOUNT_ADDED suppressed (already collected)")
                    return
                end
            end
        end
        local name, icon, toyItemID, kindLabel, link = ResolveSpecialLoot(event, id)
        local toast = {
            header      = "Special Loot",
            icon        = icon,
            name        = name or "",
            quality     = nil,
            isSpecial   = true,
            specialKind = kindLabel,   -- Mount / Pet / Toy (expansion label)
            itemID      = toyItemID,    -- toys only; nil for mount/pet
            link        = link,         -- chat hyperlink for the expansion row
            mountID     = (event == "NEW_MOUNT_ADDED") and id or nil,
            petID       = (event == "NEW_PET_ADDED") and id or nil,
        }
        -- Retry briefly if the journal wasn't ready. Bounded; toast shows now.
        if (not name or name == "") and event ~= nil then
            local tries = 0
            local function retry()
                tries = tries + 1
                local n, ic, _, _, lk = ResolveSpecialLoot(event, id)
                if n and n ~= "" then
                    toast.name = n
                    if not toast.icon then toast.icon = ic end
                    if lk then toast.link = lk end
                    if toast.frame and toast.frame:IsShown() then
                        ApplyContent(toast.frame, toast)
                    end
                elseif tries < 20 then
                    C_Timer.After(0.1, retry)
                end
            end
            C_Timer.After(0.1, retry)
        end
        QueueToast(toast)

    elseif kind == "housing" then
        -- NEW_HOUSING_ITEM_ACQUIRED fires with (itemType, itemName, itemIcon),
        -- where itemType is an Enum.HousingItemToastType. Only Decor is flagged
        -- as special loot; the other housing types are left to the native UI.
        local itemType, itemName, itemIcon = ...
        local decorType = Enum and Enum.HousingItemToastType and Enum.HousingItemToastType.Decor
        if decorType == nil or itemType ~= decorType then
            T("NEW_HOUSING_ITEM_ACQUIRED ignored (type=" .. tostring(itemType) .. ", not Decor)")
            return
        end
        T("NEW_HOUSING_ITEM_ACQUIRED Decor: " .. tostring(itemName))
        QueueToast({
            header      = "Special Loot",
            icon        = itemIcon,
            name        = itemName or "",
            quality     = nil,
            isSpecial   = true,
            specialKind = "Decor",
            itemID      = nil,
            link        = nil,
        })

    elseif kind == "appearance" then
        -- An appearance was just learned, so its "added to your appearance
        -- collection" system line is imminent. Open the suppression window so
        -- the filter drops that line even if it arrives as a secret value the
        -- text pattern can't read. Armed before the sourceID guard because the
        -- line comes regardless of whether we can resolve the source for a toast.
        local nowT = (GetTime and GetTime() or 0)
        M.appearanceLineWindowUntil = nowT + APPEARANCE_LINE_WINDOW
        -- Record the exact armed-until deadline so each raw secret line's
        -- timestamp can be checked against it directly. This is the test
        -- for whether a leaked line fell inside or outside the window, and
        -- whether it arrived before the arm (a same-frame race) or after
        -- it (a pipeline bypass).
        T(("APPEARANCE-ARM  now=%.3f  windowUntil=%.3f")
            :format(nowT, M.appearanceLineWindowUntil))

        local sourceID = ...
        if not sourceID then return end

        -- visualID (for dedupe), icon, and the source's item link for the chat.
        local srcIcon, srcLink, visualID
        if C_TransmogCollection and C_TransmogCollection.GetAppearanceSourceInfo then
            local sourceInfo = C_TransmogCollection.GetAppearanceSourceInfo(sourceID)
            if sourceInfo then
                visualID = sourceInfo.itemAppearanceID
                srcIcon  = sourceInfo.icon
                srcLink  = sourceInfo.itemLink
            end
        end

        -- Dedupe by visualID: toast only the first source seen per visual this
        -- window; later sources of the same appearance are skipped.
        if visualID then
            if not Summary.seenVisual then Summary.seenVisual = {} end
            if Summary.seenVisual[visualID] then
                return
            end
            Summary.seenVisual[visualID] = true
        end

        -- Resolve the underlying itemID from the source so we can load name and
        -- quality. The toast is queued NOW regardless; if the item is uncached,
        -- we enrich the visible toast in place once it loads.
        local itemID
        if C_TransmogCollection and C_TransmogCollection.GetSourceInfo then
            local info = C_TransmogCollection.GetSourceInfo(sourceID)
            if info then itemID = info.itemID end
        end
        T(("APPEARANCE src=%s item=%s visual=%s link=%s")
            :format(tostring(sourceID), tostring(itemID), tostring(visualID),
                    tostring(srcLink)))

        -- Remember this itemID gave a new appearance this loot window, so its
        -- loot line is surfaced as its own pink chat line rather than folded
        -- into the vendor-grade summary.
        if itemID then
            if not Summary.newApp then Summary.newApp = {} end
            Summary.newApp[itemID] = true
        end

        local toast = {
            header       = "New Appearance",
            icon         = srcIcon,
            name         = "",
            quality      = nil,
            glowColor    = GLOW_PINK,
            isAppearance = true,        -- emit a pink chat line for this one
            itemID       = itemID,      -- for name/quality resolution
            link         = srcLink,     -- canonical source link (correct variant) for the chat line
            sourceID     = sourceID,    -- appearance identity for preview / journal
        }

        if itemID then
            -- The looted link outranks the bare item: a legacy dungeon's
            -- Normal drop is the same item carrying a bonus that lowers
            -- its quality, and the bare item reads as the Heroic epic.
            local lootedLink
            for _, entry in ipairs(Summary.links or {}) do
                if tonumber(entry.link:match("item:(%d+)")) == itemID then
                    lootedLink = entry.link
                    break
                end
            end
            -- Synchronous attempt first (cached items fill in immediately).
            local name, _, quality = C_Item.GetItemInfo(lootedLink or itemID)
            if name then
                toast.name = name
                toast.quality = quality
                if not toast.icon then toast.icon = C_Item.GetItemIconByID(itemID) end
            else
                -- Enrich when the item loads. Updates visible content but does
                -- NOT re-fit the frame width (the batch shares one width).
                local item = lootedLink and Item:CreateFromItemLink(lootedLink)
                    or Item:CreateFromItemID(itemID)
                item:ContinueOnItemLoad(function()
                    toast.name = item:GetItemName() or toast.name
                    toast.quality = item:GetItemQuality() or toast.quality
                    if not toast.icon then toast.icon = item:GetItemIcon() end
                    -- Grab the source link if it wasn't ready at detection.
                    if not toast.link and C_TransmogCollection
                       and C_TransmogCollection.GetAppearanceSourceInfo then
                        local sourceInfo =
                            C_TransmogCollection.GetAppearanceSourceInfo(sourceID)
                        if sourceInfo and sourceInfo.itemLink then
                            toast.link = sourceInfo.itemLink
                        end
                    end
                    if toast.frame and toast.frame:IsShown() then
                        ApplyContent(toast.frame, toast)
                    end
                end)
            end
        end

        QueueToast(toast)
    end
    if kind == "item" then
        -- kind == "item": intentionally no toast; counted as vendor-grade.
        -- CONFIRM-REARM: plain item toasts currently do NOT arm the quiet
        -- flush. If a straggler wave of only plain items arrives after
        -- LOOT_CLOSED and after the flush has run, none of them re-arm and
        -- they are dropped. This trace records each such fall-through with
        -- the current capture/window state so the gap can be confirmed
        -- against a real slow-loot corpse.
        T(("PLAIN-ITEM fallthrough (no arm)  capturing=%s  windowOpen=%s  "
           .. "flushTimer=%s"):format(
            tostring(Summary.capturing), tostring(Summary.windowOpen),
            tostring(Summary.flushTimer ~= nil)))
    end
end

-------------------------------------------------------------------------------
-- Collapses a corpse's vendor-grade loot into one chat line with an expand
-- link. Lists are kept for the current lockout.
-------------------------------------------------------------------------------

local LINK_ADDON = "RetroRuns"

-- Drop stored lists on lockout change.
local function EnsureLockout()
    local cur = RR.GetCurrentLockoutId and RR:GetCurrentLockoutId() or nil
    if cur ~= Summary.lockout then
        wipe(Summary.store)
        Summary.nextID  = 1
        Summary.lockout = cur
    end
end

-- Pure chat filter: swallow the loot lines the summary will re-print, which
-- are the ones inside a capture window. A vendor purchase, a quest reward
-- or a mail pickup opens no loot window, so its line reaches chat as it
-- always did. Side-effect-free; capture happens in the event handlers. When
-- Loot Summary is off, chat passes through untouched and FlushBatch prints
-- nothing.
local function LootSummaryOn()
    return (RR.GetSetting and RR:GetSetting("toasterLootSummary", true)) ~= false
end

local function LootChatFilter()
    if M.enabled and LootSummaryOn() and Summary.capturing then return true end  -- discard
    return false
end

local function TransmogChatFilter(_, _, msg)
    -- TRANSMOG_COLLECTION_SOURCE_ADDED fires just before the collected line,
    -- so a window opened on it catches the line even when it arrives secret.
    -- Stays open across several lines; gated on the event, not the bracket.
    if M.enabled and LootSummaryOn()
       and (GetTime and GetTime() or 0) <= M.appearanceLineWindowUntil then
        T("TransmogChatFilter EVENT-WINDOW -> DROP")
        return true
    end

    if issecretvalue and issecretvalue(msg) then
        T(("TransmogChatFilter SECRET -> PASS  enabled=%s capturing=%s newApp=%s")
            :format(tostring(M.enabled), tostring(Summary.capturing),
                    tostring(Summary.newApp ~= nil)))
        return false
    end
    if M.enabled and LootSummaryOn() and TRANSMOG_COLLECTED_PATTERN and msg
       and msg:match(TRANSMOG_COLLECTED_PATTERN) then
        T("TransmogChatFilter MATCH -> DROP")
        return true  -- discard only the appearance-collected line
    end
    if Summary.capturing then
        T(("TransmogChatFilter NOMATCH -> PASS  enabled=%s")
            :format(tostring(M.enabled)))
    end
    return false
end

-- A secret system line skips the ChatFrame filter chain entirely, and
-- AddMessage is the one point it cannot route around. Drops only secret lines
-- inside the window, and never inspects text.
local function ShouldSuppressChatLine(chatFrame, msg)
    if not (M.enabled and LootSummaryOn()) then return false end
    if (GetTime and GetTime() or 0) > M.appearanceLineWindowUntil then
        return false
    end
    local frameName = chatFrame and chatFrame.GetName and chatFrame:GetName()
    if issecretvalue and issecretvalue(msg) then
        T("AddMessageGuard EVENT-WINDOW SECRET -> DROP  frame=" .. tostring(frameName))
        return true
    end
    T("AddMessageGuard EVENT-WINDOW readable -> PASS  frame=" .. tostring(frameName))
    return false
end

-- Wrap each chat frame's AddMessage once, storing the original so the wrapper
-- can choose to call through or drop. Idempotent: a frame already carrying the
-- guard is skipped, and new frames (e.g. combat log, added later) are covered
-- on the next install pass.
local function InstallAddMessageGuard()
    local function wrap(frame)
        if not frame or frame.rrToasterOrigAddMessage then return end
        local orig = frame.AddMessage
        if type(orig) ~= "function" then return end
        frame.rrToasterOrigAddMessage = orig
        frame.AddMessage = function(self, msg, ...)
            if ShouldSuppressChatLine(self, msg) then return end
            return orig(self, msg, ...)
        end
    end
    local guarded = {}
    for i = 1, (NUM_CHAT_WINDOWS or 10) do
        local chatFrame = _G["ChatFrame" .. i]
        wrap(chatFrame)
        if chatFrame and chatFrame.rrToasterOrigAddMessage then
            guarded[#guarded + 1] = i .. (chatFrame:IsVisible() and "" or "(hidden)")
        end
    end
    T("AddMessageGuard installed on ChatFrame " .. table.concat(guarded, ","))
end

-- Flush the batch: reveal the toast cascade, print one consolidated chat line,
-- and store the expansion list. Guarded against a double call.
FlushBatch = function()
    local batch = Summary.batch
    local links = Summary.links
    local newApp = Summary.newApp or {}

    T(("FlushBatch  raid=%s  toasts=%d  loot=%d"):format(
        tostring(RR.currentRaid and RR.currentRaid.name or "nil"),
        batch and #batch or 0,
        links and #links or 0))
    -- Reset batch state up front so a mid-flush drop starts a fresh batch.
    Summary.capturing = false
    Summary.batch = nil
    Summary.links = nil
    Summary.newApp = nil
    Summary.seenVisual = nil
    Summary.expected = 0
    Summary.received = 0

    -- Partition captured links into tier tokens, vendor-grade, and excluded
    -- appearance dupes. One copy per appearance itemID is the appearance;
    -- surplus copies fall through to vendor-grade. Entries are { link, qty }.
    local vendor = {}
    local tokens = {}
    local lootSpecials = {}
    local excludedAsApp = 0
    local appSeen = {}
    if links then
        for _, entry in ipairs(links) do
            local itemID = tonumber(entry.link:match("item:(%d+)"))
            local _, _, _, _, _, classID, subClassID = C_Item.GetItemInfoInstant(itemID or 0)
            -- Flag collectible items as special loot, classed by item type:
            --   Pet:   class 17 (caged), or 15/2 (companion collection item)
            --   Mount: class 15 / subclass 5
            --   Decor: class 20 / subclass 0 (Housing / Decor)
            --   Toy:   no unique class; identified via C_Item.IsItemToy
            local specialKind
            if classID == 17 or (classID == 15 and subClassID == 2) then
                specialKind = "Pet"
            elseif classID == 15 and subClassID == 5 then
                specialKind = "Mount"
            elseif classID == 20 and subClassID == 0 then
                specialKind = "Decor"
            elseif itemID and C_Item.IsItemToy and C_Item.IsItemToy(itemID) then
                specialKind = "Toy"
            end
            if specialKind then
                local name = itemID and C_Item.GetItemInfo("item:" .. itemID)
                lootSpecials[#lootSpecials + 1] =
                    { name = name, link = entry.link, itemID = itemID, kind = specialKind }
            elseif itemID and newApp[itemID] and not appSeen[itemID] then
                appSeen[itemID] = true
                excludedAsApp = excludedAsApp + 1
            elseif IsTierToken(itemID) then
                tokens[#tokens + 1] = entry
            else
                vendor[#vendor + 1] = entry
            end
        end
    end

    -- Tally the toast batch by kind.
    local appCount, specialCount = 0, 0
    if batch then
        for _, toast in ipairs(batch) do
            if toast.isAppearance then appCount = appCount + 1
            elseif toast.isSpecial then specialCount = specialCount + 1 end
        end
    end
    -- Collectibles detected in this loot window count as special on the line.
    specialCount = specialCount + #lootSpecials
    -- The run tally counts appearances whether or not the chat line prints.
    if appCount > 0 and RR.RecordRunAppearances then
        RR:RecordRunAppearances(appCount)
    end

    -- Reveal the toasts as one batch.
    if batch and #batch > 0 then
        RevealWhenNamesReady(batch)
    end

    -- Loot Summary off: toasts already showed, chat is left alone.
    if not LootSummaryOn() then return end

    -- Suppression floor: a collectible always warrants a line; vendor-grade
    -- needs at least two items. For a lone vendor drop, re-emit Blizzard's
    -- default loot line (the filter already swallowed the native one).
    if appCount == 0 and specialCount == 0 and #tokens == 0 and #vendor <= 1 then
        if #vendor == 1 then
            local entry = vendor[1]
            local shownLink = QualityColoredLink(entry.link)
            local line
            if entry.qty and entry.qty > 1 and LOOT_ITEM_SELF_MULTIPLE then
                line = LOOT_ITEM_SELF_MULTIPLE:format(shownLink, entry.qty)
            elseif LOOT_ITEM_SELF then
                line = LOOT_ITEM_SELF:format(shownLink)
            else
                line = "You receive loot: " .. shownLink .. "."
            end
            -- Re-emit with the RR prefix, label tinted loot-green; the item
            -- link keeps its own quality color.
            local lootChatInfo = ChatTypeInfo and ChatTypeInfo["LOOT"]
            local r, g, b = 0, 0.667, 0
            if lootChatInfo and (lootChatInfo.r ~= 1 or lootChatInfo.g ~= 1 or lootChatInfo.b ~= 1) then
                r, g, b = lootChatInfo.r, lootChatInfo.g, lootChatInfo.b
            end
            DEFAULT_CHAT_FRAME:AddMessage(CHAT_PREFIX .. line, r, g, b)
        end
        return
    end

    -- Map looted itemID -> the looted link captured this window (preferred over
    -- the catalog link for appearance lines).
    local lootedByItemID = {}
    if links then
        for _, entry in ipairs(links) do
            local lid = tonumber(entry.link:match("item:(%d+)"))
            if lid and not lootedByItemID[lid] then lootedByItemID[lid] = entry.link end
        end
    end

    -- Build the expansion list: collected items first (tagged), then vendor.
    EnsureLockout()
    local id = Summary.nextID
    Summary.nextID = id + 1
    local items = {}
    if batch then
        for _, toast in ipairs(batch) do
            if toast.isAppearance then
                -- Link priority: looted link > source link > nil.
                local appLink = (toast.itemID and lootedByItemID[toast.itemID]) or toast.link
                items[#items + 1] = { kind = "appearance", itemID = toast.itemID,
                                      name = toast.name, link = appLink }
            elseif toast.isSpecial then
                items[#items + 1] = { kind = "special", name = toast.name,
                                      specialKind = toast.specialKind,
                                      itemID = toast.itemID, link = toast.link }
            end
        end
    end
    for _, entry in ipairs(tokens) do
        items[#items + 1] = { kind = "token", link = entry.link, qty = entry.qty }
    end
    for _, sp in ipairs(lootSpecials) do
        items[#items + 1] = { kind = "special", name = sp.name,
                              specialKind = sp.kind, itemID = sp.itemID, link = sp.link }
    end
    for _, entry in ipairs(vendor) do
        items[#items + 1] = { kind = "vendor", link = entry.link, qty = entry.qty }
    end
    Summary.store[id] = { items = items }

    RR:Print(RR.FormatCollectionSummaryLine(specialCount, appCount, #tokens, #vendor, id))
end

-- Consolidated per-corpse summary line. Shows only the sections with a
-- nonzero count, joined by a middot, with a clickable [view] expander.
--   RR: Special: 1 · Appearances: 3 · Vendor-grade: 3  [view]
function RR.FormatCollectionSummaryLine(specialCount, appCount, tokenCount, vendorCount, viewID)
    local parts = {}
    if specialCount and specialCount > 0 then
        parts[#parts + 1] = ("|cff4DCCFF" .. RR.L["Special: %d"] .. "|r"):format(specialCount)
    end
    if appCount and appCount > 0 then
        parts[#parts + 1] = ("|cffF259C7" .. RR.L["Appearances: %d"] .. "|r"):format(appCount)
    end
    if tokenCount and tokenCount > 0 then
        parts[#parts + 1] = ("|cffff8000" .. RR.L["Tier Token: %d"] .. "|r"):format(tokenCount)
    end
    if vendorCount and vendorCount > 0 then
        parts[#parts + 1] = ("|cff999999" .. RR.L["Vendor-grade: %d"] .. "|r"):format(vendorCount)
    end
    if #parts == 0 then return "" end
    return table.concat(parts, " |cff666666·|r ")
        .. ("  |cffffd100|Haddon:%s:vg:%d|h[" .. RR.L["view"] .. "]|h|r"):format(LINK_ADDON, viewID or 0)
end

-- Re-color a link by its true quality (strip the outer wrapper, rewrap). Falls
-- back to the link untouched if unresolved.
QualityColoredLink = function(link)
    local itemID = link:match("|Hitem:(%d+)")
    if not itemID then return link end

    local quality = select(3, C_Item.GetItemInfo(link))
    if not quality then
        quality = select(3, C_Item.GetItemInfoInstant(link))
    end
    if not quality then return link end

    local _, _, _, hexStr = C_Item.GetItemQualityColor(quality)
    if not hexStr then return link end

    -- Strip a leading |cXXXXXXXX and a trailing |r if present, then rewrap.
    local bare = link:gsub("^|c%x%x%x%x%x%x%x%x", ""):gsub("|r$", "")
    return "|c" .. hexStr .. bare .. "|r"
end

-- "New!" tag appended to newly-collected items (appearances + special) in the
-- expansion. Pink to match the appearance theme. Resolved per call: this file
-- loads before the locale table is applied, so a load-time constant would
-- bake in English.
local function NewTag()
    return "  " .. RR.L["|cffF259C7[New!]|r"]
end

local function ShowVendorList(id)
    local entry = Summary.store[id]
    if not entry then
        RR:Print(RR.L["|cff999999(That loot list is from an earlier lockout and is no longer available.)|r"])
        return
    end
    -- A list expands once.
    if entry.expanded then return end
    entry.expanded = true

    -- A reputation line expands to one row per faction, largest gain first.
    if entry.reputation then
        for _, gain in ipairs(entry.reputation) do
            local color = gain.amount < 0 and "ffff4040" or "ff00ff00"
            RR:Print(("  %s |c%s(%+d)|r"):format(gain.faction, color, gain.amount))
        end
        return
    end

    RR:Print(RR.L["|cff999999Looted:|r"])
    for _, it in ipairs(entry.items) do
        if it.kind == "appearance" then
            -- Prefer the source link (correct collection state); fall back to a
            -- rebuilt link / name.
            local shown = it.link
                or (it.itemID and select(2, C_Item.GetItemInfo("item:" .. it.itemID)))
                or (it.name and ("|cffa335ee[" .. it.name .. "]|r"))
                or ("item " .. tostring(it.itemID))
            RR:Print("  " .. shown .. NewTag())
        elseif it.kind == "special" then
            -- Prefer the real chat link; plain name is the last resort.
            local shown = it.link
            if not shown and it.itemID then
                shown = select(2, C_Item.GetItemInfo("item:" .. it.itemID))
            end
            if not shown then
                shown = (it.name and it.name ~= "" and it.name) or "Special loot"
            end
            -- specialKind is stored in English (it is a data value, compared
            -- against "Special"); translate at render.
            local tag = it.specialKind and it.specialKind ~= "Special"
                and (" |cff999999(" .. (RR.L[it.specialKind] or it.specialKind) .. ")|r") or ""
            RR:Print("  " .. shown .. tag)
        elseif it.kind == "token" then
            -- Tier token: quality-colored link, tagged, quantity if stacked.
            local qtyTag = (it.qty and it.qty > 1)
                and (" |cff999999x" .. it.qty .. "|r") or ""
            RR:Print("  " .. QualityColoredLink(it.link) .. " |cffff8000(" .. RR.L["Tier Token"] .. ")|r" .. qtyTag)
        else
            local qtyTag = (it.qty and it.qty > 1)
                and (" |cff999999x" .. it.qty .. "|r") or ""
            RR:Print("  " .. QualityColoredLink(it.link) .. qtyTag)
        end
    end
end

local function InstallClickHandler()
    if Summary.clickHooked then return end
    if EventRegistry and EventRegistry.RegisterCallback then
        EventRegistry:RegisterCallback("SetItemRef", function(_, link)
            local linkType, addonName, kind, idStr = strsplit(":", link)
            if linkType == "addon" and addonName == LINK_ADDON and kind == "vg" then
                ShowVendorList(tonumber(idStr))
            end
        end)
        Summary.clickHooked = true
    end
end

-------------------------------------------------------------------------------
-- Reputation summary: one chat line per burst of faction gains.
-------------------------------------------------------------------------------
-- Blizzard prints one line per faction per kill, so a Wrath dungeon pull
-- that feeds five factions prints five lines. Inside a supported instance
-- the lines are swallowed, accumulated per faction, and re-printed as one
-- line with a [view] expander once the gains go quiet. Each gain is also
-- added to the run tally.

local Rep = {
    batch      = nil,   -- faction -> amount for the pending line
    flushTimer = nil,   -- pending C_Timer handle for the quiet-period flush
}
-- Pulls in quick succession keep re-arming this; the line prints once the
-- gains stop for this long. A quiet window that ends mid-fight holds the
-- line until combat drops, so the whole fight prints as one line.
local REP_QUIET_FLUSH = 3.0

local function RepSummaryOn()
    return (RR.GetSetting and RR:GetSetting("toasterReputationSummary", true)) ~= false
end

-- Turn a Blizzard message template into an anchored capture pattern. The
-- placeholders are swapped for markers first so the escape pass leaves
-- them alone: %s becomes a lazy capture, %d a signed number capture,
-- %.1f an uncaptured decimal.
local function FactionTemplateToPattern(template)
    if type(template) ~= "string" or template == "" then return nil end
    local marked = template:gsub("%%%.1f", "\1"):gsub("%%d", "\2"):gsub("%%s", "\3")
    local escaped = marked:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")
    local pattern = escaped:gsub("\1", "[%%d%%.,]+"):gsub("\2", "(%%-?%%d+)"):gsub("\3", "(.-)")
    return "^" .. pattern .. "$"
end

-- The templates that carry an amount. Generic forms ("increased.") carry
-- none and pass through untouched. Built once; missing globals are skipped.
local FACTION_PATTERNS
local function BuildFactionPatterns()
    if FACTION_PATTERNS then return FACTION_PATTERNS end
    FACTION_PATTERNS = {}
    local templates = {
        { "FACTION_STANDING_INCREASED_DOUBLE_BONUS", 1 },
        { "FACTION_STANDING_INCREASED_ACH_BONUS",    1 },
        { "FACTION_STANDING_INCREASED_BONUS",        1 },
        { "FACTION_STANDING_INCREASED",              1 },
        { "FACTION_STANDING_DECREASED",             -1 },
    }
    for _, entry in ipairs(templates) do
        local pattern = FactionTemplateToPattern(_G[entry[1]])
        if pattern then
            FACTION_PATTERNS[#FACTION_PATTERNS + 1] = { pattern = pattern, sign = entry[2] }
        end
    end
    return FACTION_PATTERNS
end

-- faction name and signed amount from a faction-change chat line, or nil
-- when the line is not one the summary understands.
local function ParseFactionLine(msg)
    if type(msg) ~= "string" then return nil end
    for _, entry in ipairs(BuildFactionPatterns()) do
        local faction, amount = msg:match(entry.pattern)
        if faction and amount then
            return faction, tonumber(amount) * entry.sign
        end
    end
    return nil
end

local FlushReputation  -- forward declaration

local function ArmRepFlush()
    if Rep.flushTimer then Rep.flushTimer:Cancel() end
    Rep.flushTimer = C_Timer.NewTimer(REP_QUIET_FLUSH, function()
        Rep.flushTimer = nil
        if UnitAffectingCombat and UnitAffectingCombat("player") then
            -- PLAYER_REGEN_ENABLED re-arms the window.
            Rep.heldForCombat = true
            T("ReputationFlush held -- in combat")
            return
        end
        FlushReputation()
    end)
end

-- Combat ended with a line held back: give the trailing gains their quiet
-- window, then print.
local function OnCombatEnded()
    if not Rep.heldForCombat then return end
    Rep.heldForCombat = nil
    if Rep.batch then ArmRepFlush() end
end

-- Chat filter: swallow a parseable faction line while the summary is
-- active, tallying it for the pending line and for the run. A secret line
-- cannot be read, so it passes through; so does anything unparsed.
local function ReputationChatFilter(_, _, msg)
    if not (M.enabled and RepSummaryOn()) then return false end
    if issecretvalue and issecretvalue(msg) then
        T("ReputationChatFilter SECRET -> PASS")
        return false
    end
    local faction, amount = ParseFactionLine(msg)
    if not faction then return false end
    if not Rep.batch then Rep.batch = {} end
    Rep.batch[faction] = (Rep.batch[faction] or 0) + amount
    if RR.RecordRunReputation then RR:RecordRunReputation(faction, amount) end
    ArmRepFlush()
    return true
end

-- Sorted rows for a faction -> amount table: largest gain first, ties by
-- name.
local function SortedReputationRows(byFaction)
    local rows = {}
    for faction, amount in pairs(byFaction) do
        rows[#rows + 1] = { faction = faction, amount = amount }
    end
    table.sort(rows, function(a, b)
        if a.amount ~= b.amount then return a.amount > b.amount end
        return a.faction < b.faction
    end)
    return rows
end

--   RR: Reputation Gains: 4  [view]
function RR.FormatReputationSummaryLine(factionCount, viewID)
    return ("|cff4DCCFF" .. RR.L["Reputation Gains: %d"] .. "|r"):format(factionCount)
        .. ("  |cffffd100|Haddon:%s:vg:%d|h[" .. RR.L["view"] .. "]|h|r"):format(LINK_ADDON, viewID or 0)
end

FlushReputation = function()
    local byFaction = Rep.batch
    Rep.batch = nil
    if not byFaction or not next(byFaction) then return end
    if not (M.enabled and RepSummaryOn()) then return end
    local rows = SortedReputationRows(byFaction)
    EnsureLockout()
    local id = Summary.nextID
    Summary.nextID = id + 1
    Summary.store[id] = { reputation = rows }
    RR:Print(RR.FormatReputationSummaryLine(#rows, id))
end

-- Pull the item link out of a CHAT_MSG_LOOT message ("You receive loot: |c..|h[..]|h|r").
local function ExtractItemLink(msg)
    if not msg then return nil end
    if issecretvalue and issecretvalue(msg) then return nil end
    return msg:match("(|c%x+|Hitem:.-|h.-|h|r)") or msg:match("(|Hitem:.-|h.-|h|r)")
end

local function OnLootBracket(_, event, ...)
    if not M.enabled then
        if event == "LOOT_OPENED" then T("LOOT_OPENED ignored (toaster disabled)") end
        return
    end

    if event == "PLAYER_REGEN_ENABLED" then
        OnCombatEnded()
        return
    end

    if event == "LOOT_OPENED" or event == "LOOT_READY" then
        -- Open the vendor-capture gate on either event; don't reset the
        -- toast batch.
        Summary.capturing = true
        Summary.windowOpen = true
        -- Count the window's item slots once per window; the counts add up
        -- until the flush.
        if not Summary.windowCounted then
            Summary.windowCounted = true
            local itemType = Enum.LootSlotType and Enum.LootSlotType.Item or 1
            for slot = 1, (GetNumLootItems and GetNumLootItems() or 0) do
                if GetLootSlotType(slot) == itemType then
                    Summary.expected = Summary.expected + 1
                end
            end
        end
        T(event .. "  capturing=on  expected=" .. Summary.expected
            .. "  currentRaid=" .. tostring(RR.currentRaid and RR.currentRaid.name or "nil"))
        ArmFlush()

    elseif event == "LOOT_CLOSED" then
        -- Don't close the gate here; capture stays open until the flush runs
        -- so the post-close straggler wave is still captured. Arm the longer
        -- post-close grace: the wave can lag the close by ~1s, and plain-item
        -- toasts in it do not re-arm the timer themselves. ArmFlush cuts it
        -- short when every counted item has already arrived.
        Summary.windowOpen = false
        Summary.windowCounted = false
        T(("LOOT_CLOSED  expected=%d  received=%d"):format(
            Summary.expected, Summary.received))
        ArmFlush(POST_CLOSE_GRACE)

    elseif event == "CHAT_MSG_LOOT" then
        local raw = (...)
        -- Secret-tainted in 12.0.0+; skip (re-summarized from the loot window).
        if issecretvalue and issecretvalue(raw) then return end
        local link = ExtractItemLink(raw)
        local itemID = link and link:match("|Hitem:(%d+)")
        -- Quantity from the trailing "x<digits>"; single drops default to 1.
        local qty = 1
        if raw then
            local stackCount = raw:match("|h|rx(%d+)") or raw:match("|hx(%d+)")
            if stackCount then qty = tonumber(stackCount) or 1 end
        end
        if Summary.capturing then
            if link then
                if not Summary.links then Summary.links = {} end
                Summary.links[#Summary.links + 1] = { link = link, qty = qty }
                Summary.received = Summary.received + 1
                T(("CHAT_MSG_LOOT captured item:%s x%d  received=%d/%d"):format(
                    tostring(itemID), qty, Summary.received, Summary.expected))
                ArmFlush()
            else
                T("CHAT_MSG_LOOT no link extracted (raw kept out)")
            end
        else
            T("CHAT_MSG_LOOT dropped (not capturing) item:" .. tostring(itemID))
        end
    end
end

-------------------------------------------------------------------------------
-- Public lifecycle (stable surface; slash + future settings call these)
-------------------------------------------------------------------------------

-- Runtime activation: starts suppression and drop-event listening. Called by
-- the lifecycle, not the user (the user-facing toggle is RR:SetToaster).
local function ActivateToaster()
    if M.enabled then return end
    if not M.source then
        M.source = CreateFrame("Frame")
        M.source:SetScript("OnEvent", OnDropEvent)
    end
    for _, ev in ipairs(EVENT_LIST) do
        Protected(M.source.RegisterEvent, M.source, ev)
    end
    -- Also feed raw CHAT_MSG_SYSTEM into OnDropEvent's logging branch so
    -- the system-line stream above sees every message.
    Protected(M.source.RegisterEvent, M.source, "CHAT_MSG_SYSTEM")

    -- Summary listener: the loot bracket + CHAT_MSG_LOOT (for link capture).
    if not Summary.frame then
        Summary.frame = CreateFrame("Frame")
        Summary.frame:SetScript("OnEvent", OnLootBracket)
    end
    Protected(Summary.frame.RegisterEvent, Summary.frame, "LOOT_READY")
    Protected(Summary.frame.RegisterEvent, Summary.frame, "LOOT_OPENED")
    Protected(Summary.frame.RegisterEvent, Summary.frame, "LOOT_CLOSED")
    Protected(Summary.frame.RegisterEvent, Summary.frame, "CHAT_MSG_LOOT")
    Protected(Summary.frame.RegisterEvent, Summary.frame, "PLAYER_REGEN_ENABLED")
    InstallClickHandler()
    EnsureLockout()

    if not M.chatFilterInstalled then
        ChatFrame_AddMessageEventFilter("CHAT_MSG_LOOT", LootChatFilter)
        ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", TransmogChatFilter)
        ChatFrame_AddMessageEventFilter("CHAT_MSG_COMBAT_FACTION_CHANGE", ReputationChatFilter)

        M.chatFilterInstalled = true
    end
    -- The AddMessage guard is (re)installed every activation, not gated on
    -- chatFilterInstalled: it's idempotent per frame and picks up any chat
    -- window created since the last pass.
    InstallAddMessageGuard()

    M.enabled = true
    Suppressor.InstallGuard()
    Suppressor.Detach()
    RefreshBannerSuppression()
    T("ActivateToaster  currentRaid=" .. tostring(RR.currentRaid and RR.currentRaid.name or "nil"))
end

-- Runtime deactivation: restores native popups and stops listening. Called by
-- the lifecycle (raid exit) or when the master switch is turned off.
local function DeactivateToaster()
    if not M.enabled then return end
    M.enabled = false
    if M.source then M.source:UnregisterAllEvents() end
    if Summary.frame then Summary.frame:UnregisterAllEvents() end
    Summary.capturing = false
    Summary.windowOpen = false
    Summary.windowCounted = false
    Summary.expected = 0
    Summary.received = 0
    Summary.batch  = nil
    Summary.links  = nil
    Summary.newApp = nil
    Summary.seenVisual = nil
    if Summary.flushTimer then
        Summary.flushTimer:Cancel()
        Summary.flushTimer = nil
    end
    Rep.batch = nil
    Rep.heldForCombat = nil
    if Rep.flushTimer then
        Rep.flushTimer:Cancel()
        Rep.flushTimer = nil
    end
    Presenter.Clear()
    Suppressor.Reattach()
    BannerSuppressor.Release()
    -- Chat filter left installed; inert when M.enabled is false.
end

-- True when the player is in a RetroRuns-supported raid.
local function InRaidContext()
    return RR.currentRaid ~= nil
end

-- Dump the lifecycle trace and live gate state to the copy window.
function RR:ToasterDebug()
    local lines = {}
    local function add(line) lines[#lines + 1] = line end
    add("== Toaster state ==")
    add("enabled        = " .. tostring(M.enabled))
    add("currentRaid    = " .. tostring(RR.currentRaid and RR.currentRaid.name or "nil"))
    add("capturing      = " .. tostring(Summary.capturing))
    add(("loot lines     = %d of %d counted"):format(Summary.received, Summary.expected))
    add("windowOpen     = " .. tostring(Summary.windowOpen))
    add("batch size     = " .. tostring(Summary.batch and #Summary.batch or 0))
    add("loot captured  = " .. tostring(Summary.links and #Summary.links or 0))
    add("flushTimer     = " .. tostring(Summary.flushTimer ~= nil))
    add("toasterEnabled setting = " .. tostring(RR:GetSetting("toasterEnabled", false)))
    add("lootSummary    setting = " .. tostring(RR:GetSetting("toasterLootSummary", true)))
    add("repSummary     setting = " .. tostring(RR:GetSetting("toasterReputationSummary", true)))
    local pendingFactions = 0
    for _ in pairs(Rep.batch or {}) do pendingFactions = pendingFactions + 1 end
    add("rep pending    = " .. pendingFactions .. " faction(s), timer=" .. tostring(Rep.flushTimer ~= nil))
    local stats = RR.state and RR.state.runStats
    if stats then
        local runFactions = {}
        for faction, amount in pairs(stats.reputation or {}) do
            runFactions[#runFactions + 1] = ("%s %+d"):format(faction, amount)
        end
        table.sort(runFactions)
        add("run appearances = " .. tostring(stats.appearances or 0)
            .. "  remaining = " .. tostring(RR.InstanceAppearancesStillNeeded and RR:InstanceAppearancesStillNeeded() or "?"))
        add("run reputation  = " .. (#runFactions > 0 and table.concat(runFactions, ", ") or "(none)"))
    end
    add("")
    add("== Live toasts (top to bottom) ==")
    if #Presenter.live == 0 then
        add("(none on screen)")
    end
    for i, f in ipairs(Presenter.live) do
        local glowShown = f.glow and f.glow:IsShown() or false
        local r, g, b, a = 0, 0, 0, 0
        if f.glow and f.glow.GetVertexColor then r, g, b, a = f.glow:GetVertexColor() end
        add(("  [%d] %s  glowOn=%s  glowShown=%s  glowRGBA=%.2f,%.2f,%.2f,%.2f  frameAlpha=%.2f")
            :format(i, tostring(f.itemNameText and f.itemNameText:GetText() or "?"),
                    tostring(f.glowOn), tostring(glowShown),
                    r or 0, g or 0, b or 0, a or 0, f:GetAlpha()))
    end
    add("")
    add("== Recent trace (oldest first) ==")
    if #Trace == 0 then
        add("(empty -- no toaster activity recorded since login/reload)")
    else
        for _, t in ipairs(Trace) do add(t) end
    end
    RR:ShowCopyWindow("Toaster Debug", table.concat(lines, "\n"))
end

-- Wipe the trace ring so a later debug dump shows only the events after
-- this point. Run right before a loot burst to isolate it from unrelated
-- system messages that would otherwise fill the bounded ring.
function RR:ToasterClearTrace()
    for i = #Trace, 1, -1 do Trace[i] = nil end
    RR:Print(RR.L["Toaster trace cleared."])
end

-- The settings page's stacked sample toasts, independent of the live pool.
-- Returns the group with a :PlayReveal() that staggers the fade-ins.
function RR:BuildPreviewBatch(parent)
    -- Real itemIDs so name and icon resolve from the same source. The mount
    -- itemID matches the Loot Summary Preview's special-loot sample.
    local samples = {
        { header = "New Appearance", itemID = 18832 },
        { header = "New Appearance", itemID = 12640 },
        { header = "Special Loot",   itemID = 43952, name = "Azure Drake" },
    }

    local PREVIEW_SCALE = 0.55
    local PREVIEW_GAP   = 6           -- vertical gap between stacked previews
    local frames = {}

    for i, sample in ipairs(samples) do
        local toastFrame = BuildSampleToast(parent, sample)
        toastFrame:SetScale(PREVIEW_SCALE)
        toastFrame:SetFrameStrata(parent and parent:GetFrameStrata() or "DIALOG")
        -- Glow bleed, scaled down from the live values for the cramped pane.
        toastFrame.glow:ClearAllPoints()
        toastFrame.glow:SetPoint("TOPLEFT", -90, 28)
        toastFrame.glow:SetPoint("BOTTOMRIGHT", 90, -28)
        frames[i] = toastFrame
    end

    -- Stack them top-down inside the parent. Scaled height drives the spacing.
    local stepY = (TOAST_H * PREVIEW_SCALE) + PREVIEW_GAP
    for i, f in ipairs(frames) do
        f:ClearAllPoints()
        -- Anchor relative to the parent's TOPLEFT; divide by scale because
        -- SetPoint offsets are in the frame's own (scaled) coordinate space.
        f:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -((i - 1) * stepY) / PREVIEW_SCALE)
    end
    -- The stack's true vertical extent in the parent's coordinate space:
    -- gaps between frames plus the last frame's scaled height. The settings
    -- page lays out below the stack from this number.
    local stackHeight = (#frames - 1) * stepY + (TOAST_H * PREVIEW_SCALE)

    -- Group handle with a staggered reveal across all frames.
    local group = { frames = frames, stackHeight = stackHeight }

    -- Built before SavedVariables exist, so re-fonted once they load and
    -- again whenever the font settings change.
    function group:RefreshFonts()
        for _, toastFrame in ipairs(self.frames) do
            ApplyToastFonts(toastFrame)
        end
    end
    function group:PlayReveal()
        local soundOn = RR:GetSetting("toasterSound", true) ~= false
        local frameCount = #self.frames
        for i, f in ipairs(self.frames) do
            BuildFadeIn(f)
            f.fadeIn:Stop()
            f:SetAlpha(0)
            f:Show()
            local delay = (i - 1) * 0.20
            C_Timer.After(delay, function()
                f.fadeIn:Play()
                -- Coin per toast, ring-out on the last (SFX channel).
                if soundOn then
                    PlaySoundFile((i == frameCount) and COIN_FINAL_SOUND or COIN_SOUND, "SFX")
                end
            end)
        end
    end

    -- Start fully visible (static); Play replays the cascade.
    for _, f in ipairs(frames) do f:SetAlpha(1); f:Show() end

    -- Chat-line preview data: expose the ingredients; the settings UI renders
    -- and re-resolves on cache. Vendor count is a cosmetic sample.
    group.vendorCount = 6
    group.appearanceIDs = {}
    for _, sample in ipairs(samples) do
        if sample.header == "New Appearance" then
            group.appearanceIDs[#group.appearanceIDs + 1] = sample.itemID
        end
    end
    -- Special-loot sample (mount) for the expansion, name colored to its type.
    -- Live mount rows carry the mount-journal name, which the client localizes,
    -- so the sample uses the same name through the locale table. kind stays
    -- English; it is a lookup key.
    group.specials = {
        { name = RR.L["Azure Drake"], kind = "Mount", color = "ffffffff" },
    }

    -- Summary line: Special / Appearances / Vendor-grade (no token sample).
    function group:GetSummaryLine()
        return RR.FormatCollectionSummaryLine(#self.specials, #self.appearanceIDs, 0, self.vendorCount, 0)
    end
    -- Expansion rows for "Looted:": appearances (pink [New!]) and the
    -- special. Returns rows, allResolved.
    function group:GetExpansionRows()
        local rows, allResolved = {}, true
        rows[#rows + 1] = RR.L["|cff999999Looted:|r"]
        for _, apprID in ipairs(self.appearanceIDs) do
            local name = C_Item.GetItemInfo("item:" .. apprID)
            if not name then allResolved = false end
            rows[#rows + 1] = "  " .. (name and ("|cffa335ee[" .. name .. "]|r") or ("item:" .. apprID))
                .. "  " .. RR.L["|cffF259C7[New!]|r"]
        end
        local sp = self.specials[1]
        if sp then
            rows[#rows + 1] = ("  |c%s%s|r |cff999999(%s)|r")
                :format(sp.color, sp.name, RR.L[sp.kind] or sp.kind)
        end
        return rows, allResolved
    end

    return group
end

-- Ratio-correct customization mockup: a scaled stand-in for the main panel with
-- a sample toast anchored as it sits in-game, drawn at MOCK_SCALE off the real
-- dimensions so proportions match. The toast-scale setting multiplies on top.
local MOCK_MAIN_W, MOCK_MAIN_H = 430, 460   -- mirror UI.lua PANEL_W / PANEL_H
function RR:BuildToasterMockup(parent, mockScale)
    local MOCK_SCALE = mockScale or 0.5

    -- Container sized for the scaled panel + gap + toast.
    local mock = CreateFrame("Frame", nil, parent)
    local panelW = MOCK_MAIN_W * MOCK_SCALE
    local panelH = MOCK_MAIN_H * MOCK_SCALE
    local gap    = ANCHOR_GAP * MOCK_SCALE
    mock:SetSize(panelW + gap + (TOAST_W_FIXED * MOCK_SCALE), panelH)

    -- ---- Main UI stand-in (left) -----------------------------------------
    -- A silhouette: dark fill, cyan border, title bar, a few list rows.
    local pBox = CreateFrame("Frame", nil, mock)
    pBox:SetSize(panelW, panelH)
    pBox:SetPoint("TOPLEFT", 0, 0)

    local pbg = pBox:CreateTexture(nil, "BACKGROUND")
    pbg:SetAllPoints()
    pbg:SetColorTexture(0.04, 0.04, 0.06, 0.92)

    local function boxEdge(box)
        local tex = box:CreateTexture(nil, "BORDER")
        tex:SetColorTexture(0.30, 0.80, 1.0, 0.5)   -- canonical RR cyan, dimmed
        return tex
    end
    local eT = boxEdge(pBox); eT:SetPoint("TOPLEFT");    eT:SetPoint("TOPRIGHT");    eT:SetHeight(1)
    local eB = boxEdge(pBox); eB:SetPoint("BOTTOMLEFT"); eB:SetPoint("BOTTOMRIGHT"); eB:SetHeight(1)
    local eL = boxEdge(pBox); eL:SetPoint("TOPLEFT");    eL:SetPoint("BOTTOMLEFT");  eL:SetWidth(1)
    local eR = boxEdge(pBox); eR:SetPoint("TOPRIGHT");   eR:SetPoint("BOTTOMRIGHT"); eR:SetWidth(1)

    -- Title strip + "RETRORUNS"-ish label, scaled.
    local titleBar = pBox:CreateTexture(nil, "ARTWORK")
    titleBar:SetColorTexture(0.10, 0.10, 0.14, 0.95)
    titleBar:SetPoint("TOPLEFT", 1, -1)
    titleBar:SetPoint("TOPRIGHT", -1, -1)
    titleBar:SetHeight(18 * MOCK_SCALE + 8)

    local titleTxt = pBox:CreateFontString(nil, "OVERLAY")
    RR.SafeSetFont(titleTxt, TITLE_FONT, math.max(8, 12 * MOCK_SCALE + 2), "OUTLINE")
    titleTxt:SetPoint("LEFT", titleBar, "LEFT", 6, 0)
    titleTxt:SetText("|cffF259C7RETRO|r|cff4DCCFFRUNS|r")

    -- A few list rows to suggest content.
    local rowY = -(18 * MOCK_SCALE + 8) - 6
    for _ = 1, 5 do
        local rowTex = pBox:CreateTexture(nil, "ARTWORK")
        rowTex:SetColorTexture(0.16, 0.16, 0.20, 0.8)
        rowTex:SetPoint("TOPLEFT", 6, rowY)
        rowTex:SetPoint("TOPRIGHT", -6, rowY)
        rowTex:SetHeight(10 * MOCK_SCALE + 3)
        rowY = rowY - (10 * MOCK_SCALE + 3) - 5
    end

    -- ---- Sample toast (right, anchored to the panel) ---------------------
    local toast = BuildSampleToast(mock, { header = "New Appearance", itemID = 18832,
                                           icon = "Interface\\Icons\\INV_Sword_39" })
    toast:SetFrameStrata(parent:GetFrameStrata())

    local handle = { frame = mock, panel = pBox, toast = toast, mockScale = MOCK_SCALE }

    -- Built before SavedVariables exist, so re-fonted once they load and
    -- again whenever the font settings change.
    function handle:RefreshFonts()
        ApplyToastFonts(self.toast)
    end

    -- Apply the user's toast scale (mock factor * user scale), anchored to the
    -- stand-in's top-right.
    function handle:SetToastScale(userScale)
        userScale = userScale or 1.0
        local eff = self.mockScale * userScale
        self.toast:SetScale(eff)
        self.toast:ClearAllPoints()
        self.toast:SetPoint("TOPLEFT", self.panel, "TOPRIGHT",
            (ANCHOR_GAP / eff), (-3 * self.mockScale) / eff)
        self.toast:Show()
    end

    handle:SetToastScale(RR:GetSetting("toasterScale", 1.0))
    return handle
end

-- Reconcile runtime state with the master switch + current zone. Activates only
-- when enabled AND in a raid; deactivates otherwise.
function RR:RefreshToasterLifecycle()
    local want = self:GetSetting("toasterEnabled", false) and InRaidContext()
    if want and not M.enabled then
        ActivateToaster()
    elseif not want and M.enabled then
        DeactivateToaster()
    end
    -- Refresh the settings panel's Toaster control state if open.
    if self.UI and self.UI.RefreshSettingsToasterState then
        self.UI.RefreshSettingsToasterState()
    end
    -- Keep the footer status slot in sync.
    if self.UI and self.UI.RefreshFooterStatus then
        self.UI.RefreshFooterStatus()
    end
end

-- Master switch (user-facing). Persists, then reconciles.
function RR:SetToaster(on)
    self:SetSetting("toasterEnabled", on and true or false)
    self:RefreshToasterLifecycle()
end

-- Slash convenience: on/off set the master switch; bare toggles it.
function RR:EnableToaster()  self:SetToaster(true)  end
function RR:DisableToaster() self:SetToaster(false) end
function RR:ToggleToaster()
    self:SetToaster(not self:GetSetting("toasterEnabled", false))
end

-- True when the master switch is on, regardless of current zone.
function RR:IsToasterEnabled()
    return self:GetSetting("toasterEnabled", false) == true
end

-- Push a fully-formed descriptor through the live display path.
RR._ToasterShowOne = function(toast) ShowOne(toast) end
