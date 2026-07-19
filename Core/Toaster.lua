-------------------------------------------------------------------------------
-- RetroRuns -- Toaster.lua
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

-- Stable iteration order for register/unregister loops (pairs order is
-- undefined; an explicit list keeps logs and behavior deterministic).
local EVENT_LIST = {
    "SHOW_LOOT_TOAST",
    "SHOW_LOOT_TOAST_UPGRADE",
    "SHOW_LOOT_TOAST_LEGENDARY_LOOTED",
    "NEW_MOUNT_ADDED",
    "NEW_PET_ADDED",
    "NEW_TOY_ADDED",
    "NEW_HOUSING_ITEM_ACQUIRED",
    "TRANSMOG_COLLECTION_SOURCE_ADDED",
    "TRANSMOG_COSMETIC_COLLECTION_SOURCE_ADDED",
}

-------------------------------------------------------------------------------
-- Module state
-------------------------------------------------------------------------------

local M = {
    enabled    = false,
    source     = nil,   -- our capture frame
    guardHook  = false, -- AlertFrame.RegisterEvent re-detach guard installed
    chatFilterInstalled = false,
    -- Timestamp (GetTime) through which the appearance-collected system line
    -- should be suppressed regardless of whether it's readable. Set when a
    -- TRANSMOG_COLLECTION_SOURCE_ADDED event fires; the event is positive
    -- proof an "added to your appearance collection" line is imminent, so the
    -- filter can drop the line even when it arrives as a secret value (which
    -- can't be pattern-matched). Covers the case the text-match path misses.
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
-- BannerSuppressor: optionally hides Blizzard's boss-kill loot banner (the
-- BossBanner frame). Separate from Suppressor above (corner toasts via
-- AlertFrame). Swaps the banner's OnEvent for a wrapper and restores it on
-- release.
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
-- Same-item drops within the visible window merge and bump a count badge
-- rather than spawning a second frame.
-------------------------------------------------------------------------------

local Presenter = {
    pool    = {},   -- reusable hidden frames
    live    = {},   -- currently shown, oldest first (head pins to anchor)
    byKey   = {},   -- mergeKey -> live frame, for coalescing
}

local TOAST_W, TOAST_H, GAP = 340, 96, 26
-- Fixed icon size (not derived from TOAST_H).
local TOAST_ICON = 60
local TOAST_W_MIN, TOAST_W_MAX = 300, 460   -- clamp for measured width
-- Fixed width when banner art is active: TOAST_H at the art's 4:1 ratio.
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
    local toastFrame = CreateFrame("Frame", nil, parent or UIParent)
    toastFrame:SetSize(TOAST_W, TOAST_H)
    toastFrame:SetScale(TOAST_SCALE)
    toastFrame:SetFrameStrata("HIGH")

    -- Glow: soft rectangular halo (EpicGlow), additive, tinted/pulsed per
    -- quality (forced pink for appearances). Anchored wider than the frame.
    toastFrame.glow = toastFrame:CreateTexture(nil, "BACKGROUND", nil, -1)
    toastFrame.glow:SetTexture("Interface\\AddOns\\RetroRuns\\Media\\EpicGlow")
    toastFrame.glow:SetPoint("TOPLEFT", -180, 50)
    toastFrame.glow:SetPoint("BOTTOMRIGHT", 180, -50)
    toastFrame.glow:SetBlendMode("ADD")
    toastFrame.glow:Hide()

    -- Backdrop: dark fill behind the banner art. Takes the per-kind tint.
    toastFrame.bg = toastFrame:CreateTexture(nil, "BACKGROUND")
    toastFrame.bg:SetAllPoints()
    toastFrame.bg:SetColorTexture(0.04, 0.04, 0.06, 0.92)

    -- Per-kind banner frame art (512x128). Texture set in ApplyContent; hidden
    -- until then.
    toastFrame.banner = toastFrame:CreateTexture(nil, "BORDER")
    toastFrame.banner:SetAllPoints()

    -- Edge slivers: the no-art fallback frame, quality-colored. Hidden when
    -- banner art is active.
    local function edge()
        local tex = toastFrame:CreateTexture(nil, "BORDER")
        tex:SetColorTexture(1, 1, 1, 1)
        return tex
    end
    toastFrame.edgeT = edge(); toastFrame.edgeT:SetPoint("TOPLEFT", 0, 0);    toastFrame.edgeT:SetPoint("TOPRIGHT", 0, 0);    toastFrame.edgeT:SetHeight(2)
    toastFrame.edgeB = edge(); toastFrame.edgeB:SetPoint("BOTTOMLEFT", 0, 0); toastFrame.edgeB:SetPoint("BOTTOMRIGHT", 0, 0); toastFrame.edgeB:SetHeight(2)
    toastFrame.edgeL = edge(); toastFrame.edgeL:SetPoint("TOPLEFT", 0, 0);    toastFrame.edgeL:SetPoint("BOTTOMLEFT", 0, 0);  toastFrame.edgeL:SetWidth(2)
    toastFrame.edgeR = edge(); toastFrame.edgeR:SetPoint("TOPRIGHT", 0, 0);   toastFrame.edgeR:SetPoint("BOTTOMRIGHT", 0, 0); toastFrame.edgeR:SetWidth(2)

    -- Icon with a thin frame to match panel item rows. Centered vertically.
    toastFrame.icon = toastFrame:CreateTexture(nil, "ARTWORK")
    toastFrame.icon:SetSize(TOAST_ICON, TOAST_ICON)
    toastFrame.icon:SetPoint("LEFT", 6, 0)
    toastFrame.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

    toastFrame.iconEdge = toastFrame:CreateTexture(nil, "BORDER")
    toastFrame.iconEdge:SetColorTexture(0, 0, 0, 1)
    toastFrame.iconEdge:SetPoint("TOPLEFT", toastFrame.icon, "TOPLEFT", -1, 1)
    toastFrame.iconEdge:SetPoint("BOTTOMRIGHT", toastFrame.icon, "BOTTOMRIGHT", 1, -1)

    -- Quality-tinted icon ring (the rarity cue the banner doesn't carry).
    -- Tint/show set in ApplyContent.
    toastFrame.iconRing = toastFrame:CreateTexture(nil, "OVERLAY")
    toastFrame.iconRing:SetTexture("Interface\\AddOns\\RetroRuns\\Media\\icon-border-white")
    toastFrame.iconRing:SetPoint("TOPLEFT", toastFrame.icon, "TOPLEFT", -5, 5)
    toastFrame.iconRing:SetPoint("BOTTOMRIGHT", toastFrame.icon, "BOTTOMRIGHT", 5, -5)
    toastFrame.iconRing:Hide()

    -- Header: green pixel-font category label ("NEW APPEARANCE", "SPECIAL LOOT").
    toastFrame.header = toastFrame:CreateFontString(nil, "OVERLAY")
    toastFrame.header:SetFont(TITLE_FONT, 16, "OUTLINE")
    toastFrame.header:SetPoint("TOPLEFT", toastFrame.icon, "TOPRIGHT", 9, -4)
    toastFrame.header:SetPoint("RIGHT", -8, 0)
    toastFrame.header:SetJustifyH("LEFT")
    toastFrame.header:SetTextColor(0.49, 0.99, 0.0)  -- C_LABEL green

    -- Body: item name, quality-colored. Wraps to a second line, capped at 2.
    toastFrame.itemNameText = toastFrame:CreateFontString(nil, "OVERLAY")
    toastFrame.itemNameText:SetFont(TITLE_FONT, 20, "OUTLINE")
    toastFrame.itemNameText:SetPoint("TOPLEFT", toastFrame.header, "BOTTOMLEFT", 0, -3)
    toastFrame.itemNameText:SetPoint("RIGHT", -8, 0)
    toastFrame.itemNameText:SetJustifyH("LEFT")
    toastFrame.itemNameText:SetJustifyV("TOP")
    toastFrame.itemNameText:SetWordWrap(true)
    if toastFrame.itemNameText.SetMaxLines then toastFrame.itemNameText:SetMaxLines(2) end

    toastFrame.count = toastFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    toastFrame.count:SetPoint("BOTTOMRIGHT", toastFrame.icon, "BOTTOMRIGHT", 1, 0)

    return toastFrame
end

local function AcquireFrame()
    local toastFrame = table.remove(Presenter.pool)
    if toastFrame then return toastFrame end
    return ConstructToastFrame(UIParent)
end

local function ReleaseFrame(toastFrame)
    toastFrame:Hide()
    toastFrame:SetScript("OnUpdate", nil)
    -- Clear stay-until-click wiring before pooling.
    toastFrame:SetScript("OnMouseDown", nil)
    toastFrame:EnableMouse(false)
    if toastFrame.mergeKey then Presenter.byKey[toastFrame.mergeKey] = nil end
    toastFrame.mergeKey = nil
    toastFrame.qty = nil
    toastFrame.glowOn = nil
    toastFrame.quality = nil
    if toastFrame.glow then toastFrame.glow:Hide() end
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

local function SetCount(toastFrame)
    if (toastFrame.qty or 1) > 1 then
        toastFrame.count:SetText("x" .. toastFrame.qty)
    else
        toastFrame.count:SetText("")
    end
end

-- Retro-pink base for the epic glow; pulse modulates its brightness.
local GLOW_PINK = { 1.0, 0.15, 0.55 }
local GLOW_QUALITY_FLOOR = 4  -- epic+

-- Color the border + body by quality and enable the pink glow for epic+.
-- quality nil falls back to brand pink, no glow. glowColor (optional) forces
-- the glow tint. Per-kind background tint: appearances pink, special loot cyan,
-- no kind keeps the neutral dark fill.
local BG_NEUTRAL    = { 0.04, 0.04, 0.06, 0.92 }   -- current default fill
local BG_APPEARANCE = { 0.10, 0.055, 0.095, 0.92 }  -- pink-black
local BG_SPECIAL    = { 0.025, 0.08, 0.105, 0.92 }  -- cyan-black
local function StyleBgByKind(toastFrame, toast)
    local bgColor = BG_NEUTRAL
    if toast then
        if toast.isAppearance then bgColor = BG_APPEARANCE
        elseif toast.isSpecial then bgColor = BG_SPECIAL end
    end
    toastFrame.bg:SetColorTexture(bgColor[1], bgColor[2], bgColor[3], bgColor[4])
end

-- Banner art paths per toast kind. No kind (preview/overlay) falls back to the
-- code-drawn frame.
local BANNER_BY_KIND = {
    appearance = "Interface\\AddOns\\RetroRuns\\Media\\toast-bg-appearance",
    special    = "Interface\\AddOns\\RetroRuns\\Media\\toast-bg-special",
    token      = "Interface\\AddOns\\RetroRuns\\Media\\toast-bg-token",
}

-- Apply the per-kind banner art. With a banner, hide the edge slivers, glow,
-- and bg fill (the icon ring stays). With no kind, leave the legacy frame.
local function StyleBannerByKind(toastFrame, toast)
    local kind
    if toast then
        if toast.isAppearance then kind = "appearance"
        elseif toast.isSpecial then kind = "special" end
    end
    local path = kind and BANNER_BY_KIND[kind]
    if path then
        toastFrame.banner:SetTexture(path)
        toastFrame.banner:Show()
        toastFrame.bg:Hide()
        toastFrame.edgeT:Hide(); toastFrame.edgeB:Hide(); toastFrame.edgeL:Hide(); toastFrame.edgeR:Hide()
        toastFrame.iconEdge:Hide()
        toastFrame.glow:Hide()        -- the banner art supplies its own glow
        toastFrame.glowOn = false
        toastFrame.useBanner = true
        -- Seat the icon in the art's baked well.
        toastFrame.icon:SetSize(BANNER_ICON_SIZE, BANNER_ICON_SIZE)
        toastFrame.icon:ClearAllPoints()
        toastFrame.icon:SetPoint("LEFT", BANNER_ICON_INSET, 0)
    else
        toastFrame.banner:Hide()
        toastFrame.bg:Show()
        toastFrame.edgeT:Show(); toastFrame.edgeB:Show(); toastFrame.edgeL:Show(); toastFrame.edgeR:Show()
        toastFrame.iconEdge:Show()
        toastFrame.useBanner = false
        toastFrame.icon:SetSize(TOAST_ICON, TOAST_ICON)
        toastFrame.icon:ClearAllPoints()
        toastFrame.icon:SetPoint("LEFT", 6, 0)
    end
end

local function StyleByQuality(toastFrame, quality, glowColor)
    toastFrame.quality = quality
    local r, g, b
    if quality then
        r, g, b = C_Item.GetItemQualityColor(quality)
    end
    if not r then r, g, b = C_PINK[1], C_PINK[2], C_PINK[3] end

    for _, e in ipairs({ toastFrame.edgeT, toastFrame.edgeB, toastFrame.edgeL, toastFrame.edgeR }) do
        e:SetVertexColor(r, g, b, 0.95)
    end

    -- Quality-colored icon ring, shown when banner art is active.
    if toastFrame.useBanner then
        toastFrame.iconRing:SetVertexColor(r, g, b, 1)
        toastFrame.iconRing:Show()
    else
        toastFrame.iconRing:Hide()
    end

    -- Glow color: forced override if given, else the quality color.
    toastFrame.glowColor = glowColor or { r, g, b }

    -- Glow shows for epic+ or a forced color, never with banner art.
    if not toastFrame.useBanner and (glowColor or (quality and quality >= GLOW_QUALITY_FLOOR)) then
        toastFrame.glowOn = true
        toastFrame.glow:Show()
    else
        toastFrame.glowOn = false
        toastFrame.glow:Hide()
    end
end

-- Full-opacity hold (seconds) from toasterDuration, clamped 1.5..8.0.
local function EffectiveHold()
    local duration = (RR.GetSetting and RR:GetSetting("toasterDuration", 3.0)) or 3.0
    if duration < 1.5 then duration = 1.5 elseif duration > 8.0 then duration = 8.0 end
    return duration
end

local function StayUntilClick()
    return (RR.GetSetting and RR:GetSetting("toasterStayUntilClick", false)) and true or false
end

-- Remove a toast immediately (click-to-dismiss in stay-until-click mode).
local function DismissToast(toastFrame)
    toastFrame:SetScript("OnUpdate", nil)
    for i, lf in ipairs(Presenter.live) do
        if lf == toastFrame then table.remove(Presenter.live, i) break end
    end
    ReleaseFrame(toastFrame)
    Restack()
end

-- Drive fade with OnUpdate against elapsed wall-clock; resets on a merge so a
-- re-hit refreshes the dwell time instead of letting an old toast expire.
-- In stay-until-click mode the toast fades in then holds at full opacity
-- indefinitely; a mouse click dismisses it (wired here, cleared on release).
local function StartFade(toastFrame)
    toastFrame.born = GetTime()

    local stay = StayUntilClick()
    if stay then
        -- Clickable, dismiss-on-click; cleared in ReleaseFrame.
        toastFrame:EnableMouse(true)
        toastFrame:SetScript("OnMouseDown", function(self) DismissToast(self) end)
    else
        toastFrame:EnableMouse(false)
        toastFrame:SetScript("OnMouseDown", nil)
    end

    local hold = EffectiveHold()
    toastFrame:SetScript("OnUpdate", function(self)
        local elapsed = GetTime() - self.born
        local a
        if elapsed < FADE_IN then
            a = elapsed / FADE_IN
        elseif stay then
            -- Hold at full opacity until clicked; never auto-expire.
            a = 1
        elseif elapsed < FADE_IN + hold then
            a = 1
        elseif elapsed < FADE_IN + hold + FADE_OUT then
            a = 1 - (elapsed - FADE_IN - hold) / FADE_OUT
        else
            -- expired
            self:SetScript("OnUpdate", nil)
            for i, lf in ipairs(Presenter.live) do
                if lf == self then table.remove(Presenter.live, i) break end
            end
            ReleaseFrame(self)
            Restack()
            return
        end
        self:SetAlpha(a)
    end)
end

-- Pulse every live glowing toast off the same cosine phase as the map rings.
C_Timer.NewTicker(0.05, function()
    local pulse = (RR.GetRingPulseRed and RR:GetRingPulseRed()) or 1.0
    for _, f in ipairs(Presenter.live) do
        if f.glowOn and f.glow then
            local glow = f.glowColor or GLOW_PINK
            f.glow:SetVertexColor(glow[1], glow[2], glow[3], 0.85 * pulse)
        end
    end
end)

-- Apply item content (icon, name, quality, banner, glow) to a frame from a
-- descriptor. Separate from ShowOne so an async name load can refresh a visible
-- toast in place. mergeKey groups identical drops; nil disables merging.
local function ApplyContent(toastFrame, toast)
    toastFrame.icon:SetTexture(toast.icon or "Interface\\Icons\\INV_Misc_QuestionMark")
    toastFrame.itemNameText:SetText(toast.name or "")
    local r, g, b
    if toast.quality then r, g, b = C_Item.GetItemQualityColor(toast.quality) end
    toastFrame.itemNameText:SetTextColor(r or 1, g or 1, b or 1)
    StyleBgByKind(toastFrame, toast)
    StyleBannerByKind(toastFrame, toast)
    StyleByQuality(toastFrame, toast.quality, toast.glowColor)
end

local function ShowOne(toast)
    local toastFrame = AcquireFrame()
    toastFrame.mergeKey = nil
    toastFrame.qty = 1

    -- Scale = base x windowScale x toasterScale.
    local userScale  = (RR.GetSetting and RR:GetSetting("windowScale", 1.0)) or 1.0
    local toastScale = (RR.GetSetting and RR:GetSetting("toasterScale", 1.0)) or 1.0
    toastFrame:SetScale(TOAST_SCALE * userScale * toastScale)

    -- Typeface follows bodyFontStyle; sizes fixed.
    local bodyFont = (RR.GetBodyFont and RR:GetBodyFont()) or TITLE_FONT
    toastFrame.header:SetFont(bodyFont, 16, "OUTLINE")
    toastFrame.itemNameText:SetFont(bodyFont, 20, "OUTLINE")

    if toast.width then toastFrame:SetWidth(toast.width) end
    toastFrame.header:SetText(toast.header and RR.L[toast.header]:upper() or "RETRORUNS")
    ApplyContent(toastFrame, toast)

    -- Let a pending item load refresh this frame.
    toast.frame = toastFrame

    SetCount(toastFrame)
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

-- Reveal a batch: measure every name, set all to the widest (clamped), then
-- stagger the reveals.
local measureFS  -- lazily-created offscreen FontString for width measurement

-- Width needed to fit the wider of name/header at the body font (clamped).
local function FrameWidthFor(name, header)
    if not measureFS then
        measureFS = UIParent:CreateFontString(nil, "OVERLAY")
        measureFS:Hide()
    end
    local bodyFont = (RR.GetBodyFont and RR:GetBodyFont()) or TITLE_FONT
    measureFS:SetFont(bodyFont, 20, "OUTLINE")
    measureFS:SetText(name or "")
    local widest = measureFS:GetStringWidth()
    measureFS:SetText((header or ""):upper())
    local hw = measureFS:GetStringWidth()
    if hw > widest then widest = hw end
    -- left inset + measured string + right pad + outline slack.
    local LEFT_INSET  = 6 + TOAST_ICON + 9   -- icon margin + icon + gap to text
    local RIGHT_PAD   = 8                         -- matches itemNameText RIGHT,-8
    local OUTLINE_SLACK = 10
    local frameW = LEFT_INSET + widest + RIGHT_PAD + OUTLINE_SLACK
    if frameW < TOAST_W_MIN then frameW = TOAST_W_MIN end
    if frameW > TOAST_W_MAX then frameW = TOAST_W_MAX end
    return frameW
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

    -- Banner toasts pin to the fixed art-ratio width; the no-art path measures.
    local usesBanner = false
    for _, toast in ipairs(batch) do
        if toast.isAppearance or toast.isSpecial then usesBanner = true break end
    end

    local frameW
    if usesBanner then
        frameW = TOAST_W_FIXED
    else
        -- Widest frame across the batch, so all toasts share a uniform width.
        frameW = 0
        for _, toast in ipairs(batch) do
            local frameWidth = FrameWidthFor(toast.name, toast.header)
            if frameWidth > frameW then frameW = frameWidth end
        end
    end

    local delay = 0
    for i, toast in ipairs(batch) do
        toast.width = frameW
        toast.isFinal = (i == #batch)
        C_Timer.After(delay, function()
            if M.enabled then ShowOne(toast) end
        end)
        delay = delay + STAGGER
    end
end

-- Resolve uncached names (bounded wait), then reveal once so the uniform width
-- is measured against final names.
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
    wipe(Presenter.byKey)
end

-- Forward declarations: the unlock overlay (built lazily below) is referenced
-- by ApplyToasterScale, which is defined first.
local UnlockOverlay
local PositionUnlockOverlay

-- Push the current scale settings to any on-screen toasts immediately, so a
-- change to the toast-scale slider takes effect live rather than only on the
-- next drop. Matches the scale formula used in ShowOne.
function RR:ApplyToasterScale()
    local userScale  = (self.GetSetting and self:GetSetting("windowScale", 1.0)) or 1.0
    local toastScale = (self.GetSetting and self:GetSetting("toasterScale", 1.0)) or 1.0
    for _, f in ipairs(Presenter.live) do
        f:SetScale(TOAST_SCALE * userScale * toastScale)
    end
    Restack()
    if UnlockOverlay and UnlockOverlay:IsShown() then PositionUnlockOverlay() end
end

-------------------------------------------------------------------------------
-- Unlock overlay: a free-floating sample stack the user drags to set the toast
-- position. Hidden while locked (the default); shown when "Lock" is unchecked.
-------------------------------------------------------------------------------
local function EffectiveToastScale()
    local userScale  = (RR.GetSetting and RR:GetSetting("windowScale", 1.0)) or 1.0
    local toastScale = (RR.GetSetting and RR:GetSetting("toasterScale", 1.0)) or 1.0
    return TOAST_SCALE * userScale * toastScale
end

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
        { icon = "Interface\\Icons\\INV_Sword_39",          name = 18832, header = "New Appearance", isAppearance = true },
        { icon = "Interface\\Icons\\Ability_Mount_Drake_Blue", name = 43953, header = "Special Loot", isSpecial = true },
    }
    overlay.samples = {}
    for i, s in ipairs(SAMPLES) do
        local toast = ConstructToastFrame(overlay)
        toast:EnableMouse(false)
        toast:SetFrameStrata(overlay:GetFrameStrata())
        toast:SetFrameLevel(overlay:GetFrameLevel() + 1)
        local nm = (s.name and GetItemInfo and GetItemInfo(s.name)) or ""
        ApplyContent(toast, { icon = s.icon, name = nm, quality = 4,
                          glowColor = (s.header == "New Appearance") and GLOW_PINK or nil,
                          isAppearance = s.isAppearance, isSpecial = s.isSpecial,
                          header = s.header })
        toast.header:SetText(s.header)
        -- Async name fill if the item wasn't cached.
        if nm == "" and s.name and GetItemInfo then
            local itemID = s.name
            local frame = toast
            local waiter = CreateFrame("Frame")
            waiter:RegisterEvent("GET_ITEM_INFO_RECEIVED")
            waiter:SetScript("OnEvent", function(self)
                local itemName = GetItemInfo(itemID)
                if itemName then frame.itemNameText:SetText(itemName); self:UnregisterAllEvents() end
            end)
            GetItemInfo(itemID)
        end
        if toast.glowOn and toast.glow then
            local glow = toast.glowColor or GLOW_PINK
            toast.glow:SetVertexColor(math.min(glow[1]*1.35,1), math.min(glow[2]*1.35,1), math.min(glow[3]*1.35,1), 1)
        end
        overlay.samples[i] = toast
    end

    -- Hint caption above the frame.
    local label = overlay:CreateFontString(nil, "OVERLAY")
    label:SetFont(TITLE_FONT, 12, "OUTLINE")
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
            if t.useBanner then t:SetWidth(TOAST_W_FIXED) end
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
}
-- Flush once no new drop has arrived for this long. Two windows: while the
-- loot window is open (or drops are actively streaming), a short quiet
-- period keeps the batch tight; after LOOT_CLOSED a longer grace covers the
-- straggler wave, which can lag the close by roughly a second under realm
-- latency (plain-item toasts in that wave do not re-arm the timer, so the
-- grace, not re-arming, is what catches them).
local QUIET_FLUSH = 0.5
local POST_CLOSE_GRACE = 1.5

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
    Summary.flushTimer = C_Timer.NewTimer(delay or QUIET_FLUSH, function()
        Summary.flushTimer = nil
        -- Don't flush while the loot window is still open; re-arm instead.
        if Summary.windowOpen then
            ArmFlush()
            return
        end
        FlushBatch()
    end)
end

-- Pink "New appearance:" line. Retained for the settings preview.
function RR.FormatAppearanceLine(shownLinkOrName)
    return ("|cffF259C7New appearance:|r %s"):format(shownLinkOrName or "")
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
                link = (C_Spell and C_Spell.GetSpellLink and C_Spell.GetSpellLink(spellID))
                    or (GetSpellLink and GetSpellLink(spellID))
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
        -- Build the match pattern locally (the file-level
        -- TRANSMOG_COLLECTED_PATTERN is declared later in the chunk and so
        -- isn't in scope here -- a Lua 5.1 forward-reference trap).
        local matched = "n/a"
        if not isSecret and type(rawmsg) == "string" then
            local learnTemplate = _G.ERR_LEARN_TRANSMOG_S
            if type(learnTemplate) == "string" then
                local lit = learnTemplate:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")
                local pat = lit:gsub("%%%%s", ".*")
                matched = rawmsg:match(pat) and "MATCH" or "nomatch"
            end
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

        -- visualID (for dedupe), icon, and the source's canonical item link.
        -- GetAppearanceSourceInfo: categoryID(1) visualID(2) canEnchant(3)
        -- icon(4) isCollected(5) itemLink(6). Keep itemLink(6) for the chat.
        local srcIcon, srcLink, visualID
        if C_TransmogCollection and C_TransmogCollection.GetAppearanceSourceInfo then
            local ok, _, vID, _, icon, _, itemLink = pcall(C_TransmogCollection.GetAppearanceSourceInfo, sourceID)
            if ok then visualID = vID; srcIcon = icon; srcLink = itemLink end
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
            local ok, info = pcall(C_TransmogCollection.GetSourceInfo, sourceID)
            if ok and info then itemID = info.itemID end
        end

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
        }

        if itemID then
            -- Synchronous attempt first (cached items fill in immediately).
            local name, _, quality = C_Item.GetItemInfo(itemID)
            if name then
                toast.name = name
                toast.quality = quality
                if not toast.icon then toast.icon = C_Item.GetItemIconByID(itemID) end
            else
                -- Enrich when the item loads. Updates visible content but does
                -- NOT re-fit the frame width (the batch shares one width).
                local item = Item:CreateFromItemID(itemID)
                item:ContinueOnItemLoad(function()
                    toast.name = item:GetItemName() or toast.name
                    toast.quality = item:GetItemQuality() or toast.quality
                    if not toast.icon then toast.icon = item:GetItemIcon() end
                    -- Grab the source link if it wasn't ready at detection.
                    if not toast.link and C_TransmogCollection
                       and C_TransmogCollection.GetAppearanceSourceInfo then
                        local ok, _, _, _, _, _, itemLink =
                            pcall(C_TransmogCollection.GetAppearanceSourceInfo, sourceID)
                        if ok and itemLink then toast.link = itemLink end
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
-- Summary: collapse a corpse's vendor-grade loot into one chat line with a
-- clickable expand link. Appearances and special loot are handled in
-- OnDropEvent. Brackets LOOT_OPENED..LOOT_CLOSED per corpse; lists are kept
-- per-corpse for the current lockout and wiped on lockout change. Click handled
-- via a custom `addon:RetroRuns` hyperlink through EventRegistry's SetItemRef.
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

-- Pure chat filter: swallow loot lines while the feature is on. Side-effect-
-- free; capture happens in the event handlers. When Loot Summary is off, chat
-- passes through untouched and FlushBatch prints nothing.
local function LootSummaryOn()
    return (RR.GetSetting and RR:GetSetting("toasterLootSummary", true)) ~= false
end

local function LootChatFilter()
    if M.enabled and LootSummaryOn() then return true end  -- discard
    return false
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

local function TransmogChatFilter(_, _, msg)
    -- Event-keyed suppression. When an appearance is learned the game fires
    -- TRANSMOG_COLLECTION_SOURCE_ADDED just before the "added to your
    -- appearance collection" system line. We open a short window on that event
    -- and drop the system line(s) that follow even when they arrive as secret
    -- values (which the text pattern below can't read). This runs BEFORE the
    -- secret-value bail so secret appearance lines are caught instead of
    -- passed.
    --
    -- The window is NOT closed on the first drop: a multi-appearance loot can
    -- produce several "collected" lines (all uniformly secret), so every line
    -- inside the window is dropped. The window is only open for a short span
    -- after an actual appearance event, and the line can arrive just past the
    -- loot bracket (observed firing with capturing already false), so the drop
    -- is gated on the event window alone -- not on an open loot bracket.
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

-- The appearance-collected line reaches chat as a secret value under certain
-- loot conditions, and a secret system line skips the ChatFrame message-event
-- filter chain entirely -- so TransmogChatFilter above never runs on it and the
-- line leaks. Every displayed line, secret or not, still passes through a chat
-- frame's AddMessage method, so a wrapper there is the one interception point
-- the secret line cannot route around. During the same appearance window the
-- filter uses, the wrapper drops the secret line by timing alone.
--
-- Scope is deliberately narrow: the guard drops ONLY secret lines inside the
-- window -- the exact case the filter misses. Non-secret appearance lines are
-- already caught by the filter's EVENT-WINDOW/MATCH branches before they reach
-- AddMessage (confirmed in traces), so passing every non-secret line here keeps
-- the guard from ever suppressing an unrelated system message that happens to
-- land in the window, and RetroRuns' own (non-secret) lines are never at risk.
-- A secret value errors under string operations, so the guard never inspects
-- message text -- it decides on secret-status and the timing window alone.
local function ShouldSuppressChatLine(msg)
    if not (M.enabled and LootSummaryOn()) then return false end
    if (GetTime and GetTime() or 0) > M.appearanceLineWindowUntil then
        return false
    end
    if issecretvalue and issecretvalue(msg) then
        T("AddMessageGuard EVENT-WINDOW SECRET -> DROP")
        return true
    end
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
            if ShouldSuppressChatLine(msg) then return end
            return orig(self, msg, ...)
        end
    end
    for i = 1, (NUM_CHAT_WINDOWS or 10) do
        wrap(_G["ChatFrame" .. i])
    end
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

-- Gray vendor-grade line with [view]. Retained for the settings preview's
-- legacy two-line format.
function RR.FormatVendorSummaryLine(count, viewID)
    return ("|cff999999" .. RR.L["%d vendor-grade item%s collected"] .. "|r  |cffffd100|Haddon:%s:vg:%d|h[" .. RR.L["view"] .. "]|h|r")
        :format(count, count == 1 and "" or "s", LINK_ADDON, viewID or 0)
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
-- expansion. Pink to match the appearance theme.
local NEW_TAG = "  |cffF259C7[New!]|r"

local function ShowVendorList(id)
    local entry = Summary.store[id]
    if not entry then
        RR:Print(RR.L["|cff999999(That loot list is from an earlier lockout and is no longer available.)|r"])
        return
    end
    -- A list expands once.
    if entry.expanded then return end
    entry.expanded = true

    RR:Print(RR.L["|cff999999From that kill:|r"])
    for _, it in ipairs(entry.items) do
        if it.kind == "appearance" then
            -- Prefer the source link (correct collection state); fall back to a
            -- rebuilt link / name.
            local shown = it.link
                or (it.itemID and select(2, C_Item.GetItemInfo("item:" .. it.itemID)))
                or (it.name and ("|cffa335ee[" .. it.name .. "]|r"))
                or ("item " .. tostring(it.itemID))
            RR:Print("  " .. shown .. NEW_TAG)
        elseif it.kind == "special" then
            -- Prefer the real chat link; plain name is the last resort.
            local shown = it.link
            if not shown and it.itemID then
                shown = select(2, C_Item.GetItemInfo("item:" .. it.itemID))
            end
            if not shown then
                shown = (it.name and it.name ~= "" and it.name) or "Special loot"
            end
            local tag = it.specialKind and it.specialKind ~= "Special"
                and (" |cff999999(" .. it.specialKind .. ")|r") or ""
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

    if event == "LOOT_OPENED" then
        -- Open the vendor-capture gate; don't reset the toast batch.
        Summary.capturing = true
        Summary.windowOpen = true
        T("LOOT_OPENED  capturing=on  currentRaid=" .. tostring(RR.currentRaid and RR.currentRaid.name or "nil"))
        ArmFlush()

    elseif event == "LOOT_CLOSED" then
        -- Don't close the gate here; capture stays open until the flush runs
        -- so the post-close straggler wave is still captured. Arm the longer
        -- post-close grace: the wave can lag the close by ~1s, and plain-item
        -- toasts in it do not re-arm the timer themselves.
        Summary.windowOpen = false
        T("LOOT_CLOSED")
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
                T("CHAT_MSG_LOOT captured item:" .. tostring(itemID) .. " x" .. qty)
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
    Protected(Summary.frame.RegisterEvent, Summary.frame, "LOOT_OPENED")
    Protected(Summary.frame.RegisterEvent, Summary.frame, "LOOT_CLOSED")
    Protected(Summary.frame.RegisterEvent, Summary.frame, "CHAT_MSG_LOOT")
    InstallClickHandler()
    EnsureLockout()

    if not M.chatFilterInstalled then
        ChatFrame_AddMessageEventFilter("CHAT_MSG_LOOT", LootChatFilter)
        ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", TransmogChatFilter)

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
    Summary.batch  = nil
    Summary.links  = nil
    Summary.newApp = nil
    Summary.seenVisual = nil
    if Summary.flushTimer then
        Summary.flushTimer:Cancel()
        Summary.flushTimer = nil
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

-- Build a stacked batch of sample toasts for the settings preview, using the
-- real construction/styling, independent of the live pool. Names/icons come
-- from real items. Returns the group with a :PlayReveal() that staggers the
-- fade-ins.
-- Dump the lifecycle trace and live gate state to the copy window.
function RR:ToasterDebug()
    local lines = {}
    local function add(line) lines[#lines + 1] = line end
    add("== Toaster state ==")
    add("enabled        = " .. tostring(M.enabled))
    add("currentRaid    = " .. tostring(RR.currentRaid and RR.currentRaid.name or "nil"))
    add("capturing      = " .. tostring(Summary.capturing))
    add("windowOpen     = " .. tostring(Summary.windowOpen))
    add("batch size     = " .. tostring(Summary.batch and #Summary.batch or 0))
    add("loot captured  = " .. tostring(Summary.links and #Summary.links or 0))
    add("flushTimer     = " .. tostring(Summary.flushTimer ~= nil))
    add("toasterEnabled setting = " .. tostring(RR:GetSetting("toasterEnabled", false)))
    add("lootSummary    setting = " .. tostring(RR:GetSetting("toasterLootSummary", true)))
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

function RR:BuildPreviewBatch(parent)
    -- Real itemIDs so name and icon resolve from the same source. The mount
    -- itemID matches the Loot Summary Preview's special-loot sample.
    local function IconFor(itemID)
        return (C_Item and C_Item.GetItemIconByID and C_Item.GetItemIconByID(itemID))
            or "Interface\\Icons\\INV_Misc_QuestionMark"
    end
    local samples = {
        { header = "New Appearance", id = 18832, icon = IconFor(18832), quality = 4, glowColor = GLOW_PINK, appearance = true },
        { header = "New Appearance", id = 12640, icon = IconFor(12640), quality = 4, glowColor = GLOW_PINK, appearance = true },
        { header = "Special Loot",   id = 43952, icon = IconFor(43952), quality = 4, glowColor = nil,       appearance = false },
    }

    local PREVIEW_SCALE = 0.55
    local PREVIEW_GAP   = 6           -- vertical gap between stacked previews
    local frames = {}

    for i, s in ipairs(samples) do
        local toastFrame = ConstructToastFrame(parent)
        toastFrame:SetScale(PREVIEW_SCALE)
        toastFrame:SetFrameStrata(parent and parent:GetFrameStrata() or "DIALOG")

        -- Glow bleed, scaled down from the live values for the cramped pane.
        toastFrame.glow:ClearAllPoints()
        toastFrame.glow:SetPoint("TOPLEFT", -90, 28)
        toastFrame.glow:SetPoint("BOTTOMRIGHT", 90, -28)

        toastFrame.header:SetText(RR.L[s.header]:upper())
        local nm = (GetItemInfo and GetItemInfo(s.id)) or ""
        ApplyContent(toastFrame, {
            icon = s.icon, name = nm, quality = s.quality, glowColor = s.glowColor,
            isAppearance = s.appearance, isSpecial = (not s.appearance),
        })
        -- Banner toasts use the fixed art-ratio width.
        if toastFrame.useBanner then toastFrame:SetWidth(TOAST_W_FIXED) end

        -- Not in the live pool, so tint the glow statically (boosted for the
        -- small preview scale).
        if toastFrame.glowOn and toastFrame.glow then
            local glow = toastFrame.glowColor or GLOW_PINK
            local boost = 1.35
            toastFrame.glow:SetVertexColor(
                math.min(glow[1] * boost, 1),
                math.min(glow[2] * boost, 1),
                math.min(glow[3] * boost, 1), 1.0)
        end

        -- Async fill (name + icon) if the item wasn't cached.
        if nm == "" and GetItemInfo then
            local waiter = CreateFrame("Frame")
            waiter:RegisterEvent("GET_ITEM_INFO_RECEIVED")
            waiter:SetScript("OnEvent", function()
                local itemName = GetItemInfo(s.id)
                if itemName then
                    toastFrame.itemNameText:SetText(itemName)
                    local ic = C_Item and C_Item.GetItemIconByID and C_Item.GetItemIconByID(s.id)
                    if ic then toastFrame.icon:SetTexture(ic) end
                    waiter:UnregisterAllEvents()
                end
            end)
            GetItemInfo(s.id)
        end

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

    -- Group handle with a staggered reveal across all frames.
    local group = { frames = frames }
    function group:PlayReveal()
        local soundOn = RR:GetSetting("toasterSound", true) ~= false
        local frameCount = #self.frames
        for i, f in ipairs(self.frames) do
            f:SetAlpha(0)
            f:Show()
            local delay = (i - 1) * 0.20
            C_Timer.After(delay, function()
                f.born = GetTime()
                f:SetScript("OnUpdate", function()
                    local elapsed = GetTime() - f.born
                    if elapsed < FADE_IN then
                        f:SetAlpha(elapsed / FADE_IN)
                    else
                        f:SetAlpha(1)
                        f:SetScript("OnUpdate", nil)
                    end
                end)
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
    for _, s in ipairs(samples) do
        if s.appearance then
            group.appearanceIDs[#group.appearanceIDs + 1] = s.id
        end
    end
    -- Special-loot sample (mount) for the expansion, name colored to its type.
    group.specials = {
        { name = "Reins of the Azure Drake", kind = "Mount", color = "ffffffff" },
    }

    -- Summary line: Special / Appearances / Vendor-grade (no token sample).
    function group:GetSummaryLine()
        return RR.FormatCollectionSummaryLine(#self.specials, #self.appearanceIDs, 0, self.vendorCount, 0)
    end
    -- Expansion rows for "From that kill:": appearances (pink [New!]) and the
    -- special. Returns rows, allResolved.
    function group:GetExpansionRows()
        local rows, allResolved = {}, true
        rows[#rows + 1] = "|cff999999From that kill:|r"
        for _, apprID in ipairs(self.appearanceIDs) do
            local name = C_Item.GetItemInfo("item:" .. apprID)
            if not name then allResolved = false end
            rows[#rows + 1] = "  " .. (name and ("|cffa335ee[" .. name .. "]|r") or ("item:" .. apprID))
                .. "  |cffF259C7[New!]|r"
        end
        local sp = self.specials[1]
        if sp then
            rows[#rows + 1] = ("  |c%s%s|r |cff999999(%s)|r")
                :format(sp.color, sp.name, sp.kind)
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
    titleTxt:SetFont(TITLE_FONT, math.max(8, 12 * MOCK_SCALE + 2), "OUTLINE")
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
    local toast = ConstructToastFrame(mock)
    toast:SetFrameStrata(parent:GetFrameStrata())
    local nm = (GetItemInfo and GetItemInfo(18832)) or ""
    ApplyContent(toast, { icon = "Interface\\Icons\\INV_Sword_39", name = nm,
                          quality = 4, glowColor = GLOW_PINK, isAppearance = true })
    -- Banner toasts use the art's fixed 4:1 width.
    if toast.useBanner then toast:SetWidth(TOAST_W_FIXED) end
    -- ApplyContent doesn't set the header; set it here (no :upper(), matching
    -- the unlock-drag sample).
    toast.header:SetText(RR.L["New Appearance"])
    -- Static glow tint (the live pulse ticker doesn't run here).
    if toast.glowOn and toast.glow then
        local glow = toast.glowColor or GLOW_PINK
        toast.glow:SetVertexColor(math.min(glow[1]*1.35,1), math.min(glow[2]*1.35,1), math.min(glow[3]*1.35,1), 1)
    end
    if nm == "" and GetItemInfo then
        local waiter = CreateFrame("Frame")
        waiter:RegisterEvent("GET_ITEM_INFO_RECEIVED")
        waiter:SetScript("OnEvent", function()
            local itemName = GetItemInfo(18832)
            if itemName then toast.itemNameText:SetText(itemName); waiter:UnregisterAllEvents() end
        end)
        GetItemInfo(18832)
    end

    local handle = { frame = mock, panel = pBox, toast = toast, mockScale = MOCK_SCALE }

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
    -- Keep the footer status arrow in sync.
    if self.UI and self.UI.RefreshFooterToasterStatus then
        self.UI.RefreshFooterToasterStatus()
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
