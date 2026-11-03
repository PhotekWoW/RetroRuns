-------------------------------------------------------------------------------
-- RetroRuns -- ScaleGrips.lua
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
-- Corner grips that scale a window: drag any corner and the whole window
-- grows or shrinks evenly while the opposite corner stays put.
-------------------------------------------------------------------------------

local RR = RetroRuns
local UI = RR.UI

local Grips = {}
UI.ScaleGrips = Grips

-- The on-screen scale range for every window, the main panel and the
-- sub-panels alike.
Grips.MIN_SCALE = 0.5
Grips.MAX_SCALE = 2.0

local GRIP_SIZE    = 16
local GRIP_TEXTURE = "Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up"
local GRIP_COLOR   = { 0.45, 0.80, 1.0 }

-- Each corner's opposite, the texture coords that turn the bottom-right art
-- toward it, and which way is inward.
local CORNERS = {
    TOPLEFT     = { pin = "BOTTOMRIGHT", coords = { 1, 0, 1, 0 }, inX =  1, inY = -1 },
    TOPRIGHT    = { pin = "BOTTOMLEFT",  coords = { 0, 1, 1, 0 }, inX = -1, inY = -1 },
    BOTTOMLEFT  = { pin = "TOPRIGHT",    coords = { 1, 0, 0, 1 }, inX =  1, inY =  1 },
    BOTTOMRIGHT = { pin = "TOPLEFT",     coords = { 0, 1, 0, 1 }, inX = -1, inY =  1 },
}
Grips.CORNERS = CORNERS
local CORNER_ORDER = { "TOPLEFT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT" }

-- Where each corner sits in a backdrop edge strip: left, right, top and
-- bottom edges, then the four corners.
local EDGE_SLICE = { TOPLEFT = 4, TOPRIGHT = 5, BOTTOMLEFT = 6, BOTTOMRIGHT = 7 }
Grips.EDGE_SLICE = EDGE_SLICE
local GLOW_BREATH_ALPHA = 0.6
local GLOW_LIT_ALPHA    = 0.9

-- Whole percents, inside the range.
function Grips.ClampScale(scale)
    scale = math.floor(scale * 100 + 0.5) / 100
    return math.max(Grips.MIN_SCALE, math.min(Grips.MAX_SCALE, scale))
end

-- A sub-panel's scale: the Window Scale times the sub-panel's own factor.
function Grips.WindowScale(key)
    return Grips.ClampScale(RR:GetSetting("windowScale", 1.0) * RR:GetSetting(key, 1.0))
end

-- Sets a frame's scale and holds the corner its anchor names in place on
-- screen. Anchor offsets are in the frame's own units, so they scale inversely.
function Grips.SetScaleHoldingAnchor(frame, scale)
    local oldScale = frame:GetScale()
    if not oldScale or math.abs(scale - oldScale) < 0.0001 then return false end
    local point, relativeTo, relativePoint, offsetX, offsetY = frame:GetPoint(1)
    frame:SetScale(scale)
    if point and frame:GetNumPoints() == 1 then
        frame:ClearAllPoints()
        frame:SetPoint(point, relativeTo, relativePoint,
            (offsetX or 0) * oldScale / scale, (offsetY or 0) * oldScale / scale)
    end
    return true
end

-- Re-anchors the main panel by its top-left corner and saves that spot.
local function SavePanelCorner(panel, source)
    local left, top = RR.TopLeftOffsets(panel)
    if not (left and top) then
        local point, _, relativePoint, offsetX, offsetY = panel:GetPoint(1)
        if point ~= "TOPLEFT" or relativePoint ~= "TOPLEFT" then return end
        left, top = offsetX, offsetY
    end
    panel:ClearAllPoints()
    panel:SetPoint("TOPLEFT", UIParent, "TOPLEFT", left, top)
    UI.SavePanelOffset(source, left, top)
end

-- Sets the Window Scale with the main panel's top-left corner held in place,
-- then re-applies everything the scale drives.
function Grips.SetMainScale(scale)
    scale = Grips.ClampScale(scale)
    RR:SetSetting("windowScale", scale)
    local panel = RetroRunsUI
    if panel and Grips.SetScaleHoldingAnchor(panel, scale) then
        SavePanelCorner(panel, "scale")
    end
    UI.ApplySettings()
end

-- Grips show at all times until the player first scales a window with one,
-- then only while the cursor is over one.
function Grips.AlwaysShown()
    return RetroRunsDB ~= nil and not RetroRunsDB.scaleGripsDragged
end

-- Every window with grips, so the first drag can update them all.
Grips.frames = {}

function Grips.RefreshAll()
    for _, frame in ipairs(Grips.frames) do Grips.Refresh(frame) end
end

function Grips.Refresh(frame)
    local grips = frame and frame._scaleGrips
    if not grips then return end
    local enabled = not grips.options.enabled or grips.options.enabled()
    local always = Grips.AlwaysShown()
    local drag = frame._scaleDrag
    for _, grip in ipairs(grips) do
        grip:SetShown(enabled)
        local active = grip.hovered or (drag and drag.grip == grip) or false
        if grip.breath then
            -- A lit corner breathes until the first drag and lights fully
            -- while hovered or dragged.
            grip.breath:SetShown(always)
            UI.SetBreathing(grip.breath, always, 0)
            grip.art:SetShown(active)
        else
            grip.art:SetShown(always or active)
        end
    end
end

-- A corner's screen position, in the units GetCursorPosition reports.
local function CornerOnScreen(frame, corner)
    local left, right = frame:GetLeft(), frame:GetRight()
    local top, bottom = frame:GetTop(), frame:GetBottom()
    if not (left and right and top and bottom) then return nil end
    local scale = frame:GetEffectiveScale()
    local x = corner:find("LEFT", 1, true) and left or right
    local y = corner:find("TOP", 1, true) and top or bottom
    return x * scale, y * scale
end

-- The scale that puts the grabbed corner under the cursor, measured along the
-- window's diagonal so both axes count.
function Grips.DragScale(drag, cursorX, cursorY)
    local wantX = cursorX - drag.grabOffsetX - drag.pinX
    local wantY = cursorY - drag.grabOffsetY - drag.pinY
    local ratio = (wantX * drag.diagX + wantY * drag.diagY) / drag.diagSq
    return Grips.ClampScale(drag.startScale * ratio)
end

-- Scales the frame for one drag step with the pinned corner held still.
function Grips.ApplyDragScale(frame, drag, scale)
    frame:SetScale(scale)
    frame:ClearAllPoints()
    if drag.keep then
        frame:SetPoint(drag.pin, drag.keep.relativeTo, drag.keep.relativePoint,
            drag.keep.offsetX * drag.startScale / scale,
            drag.keep.offsetY * drag.startScale / scale)
    else
        local effective = frame:GetEffectiveScale()
        local originScale = UIParent:GetEffectiveScale()
        frame:SetPoint(drag.pin, UIParent, "BOTTOMLEFT",
            (drag.pinX - (UIParent:GetLeft() or 0) * originScale) / effective,
            (drag.pinY - (UIParent:GetBottom() or 0) * originScale) / effective)
    end
end

local function StepDrag(grip)
    local frame = grip.owner
    local drag = frame._scaleDrag
    if not drag then
        grip:SetScript("OnUpdate", nil)
        return
    end
    local scale = Grips.DragScale(drag, GetCursorPosition())
    if scale ~= drag.scale then
        drag.scale = scale
        Grips.ApplyDragScale(frame, drag, scale)
        local onStep = frame._scaleGrips.options.onStep
        if onStep then onStep(frame, scale) end
    end
end

-- The press records the pinned corner and the window's diagonal. A window
-- already anchored by the pinned corner keeps that anchor; any other is
-- anchored to the screen at that corner for the drag.
function Grips.BeginDrag(grip)
    local frame = grip.owner
    if frame._scaleDrag then return end
    local corner = CORNERS[grip.corner]
    local pinX, pinY = CornerOnScreen(frame, corner.pin)
    local grabX, grabY = CornerOnScreen(frame, grip.corner)
    local cursorX, cursorY = GetCursorPosition()
    if not (pinX and grabX and cursorX) then return end
    local diagX, diagY = grabX - pinX, grabY - pinY
    local diagSq = diagX * diagX + diagY * diagY
    if diagSq < 1 then return end
    local drag = {
        grip = grip, pin = corner.pin, pinX = pinX, pinY = pinY,
        diagX = diagX, diagY = diagY, diagSq = diagSq,
        grabOffsetX = cursorX - grabX, grabOffsetY = cursorY - grabY,
        startScale = frame:GetScale(),
    }
    drag.scale = drag.startScale
    local point, relativeTo, relativePoint, offsetX, offsetY = frame:GetPoint(1)
    if frame:GetNumPoints() == 1 and point == corner.pin then
        drag.keep = { relativeTo = relativeTo, relativePoint = relativePoint,
                      offsetX = offsetX or 0, offsetY = offsetY or 0 }
    end
    frame._scaleDrag = drag
    grip:SetScript("OnUpdate", StepDrag)
    Grips.Refresh(frame)
end

function Grips.EndDrag(frame)
    local drag = frame._scaleDrag
    if not drag then return end
    drag.grip:SetScript("OnUpdate", nil)
    frame._scaleDrag = nil
    frame._scaleGrips.options.commit(frame, frame:GetScale(), drag.keep == nil)
    -- A press that changed nothing does not count as the first drag.
    if drag.scale ~= drag.startScale and Grips.AlwaysShown() then
        RetroRunsDB.scaleGripsDragged = true
        Grips.RefreshAll()
    else
        Grips.Refresh(frame)
    end
end

-- A copy of the frame's own corner art, added over it to light it up.
local function EdgeCorner(grip, frame, cornerName, edge, alpha)
    local slice = EDGE_SLICE[cornerName]
    local texture = grip:CreateTexture(nil, "OVERLAY")
    texture:SetTexture(edge.edgeFile)
    texture:SetTexCoord(slice / 8, (slice + 1) / 8, 0, 1)
    texture:SetSize(edge.edgeSize, edge.edgeSize)
    texture:SetPoint(cornerName, frame, cornerName, 0, 0)
    texture:SetBlendMode("ADD")
    texture:SetVertexColor(1, 1, 1, alpha)
    return texture
end

local function MakeGrip(frame, cornerName, options)
    local corner = CORNERS[cornerName]
    local inset, size = options.inset or 0, options.size or GRIP_SIZE
    local grip = CreateFrame("Button", nil, frame)
    grip:SetSize(size, size)
    grip:SetPoint("CENTER", frame, cornerName, corner.inX * inset, corner.inY * inset)
    grip:SetFrameLevel(frame:GetFrameLevel() + 10)
    grip:EnableMouse(true)
    if options.edge then
        grip.art = EdgeCorner(grip, frame, cornerName, options.edge, GLOW_LIT_ALPHA)
        grip.breath = EdgeCorner(grip, frame, cornerName, options.edge, GLOW_BREATH_ALPHA)
    else
        local art = grip:CreateTexture(nil, "OVERLAY")
        art:SetAllPoints(grip)
        art:SetTexture(GRIP_TEXTURE)
        art:SetTexCoord(corner.coords[1], corner.coords[2], corner.coords[3], corner.coords[4])
        art:SetVertexColor(GRIP_COLOR[1], GRIP_COLOR[2], GRIP_COLOR[3], 1)
        grip.art = art
    end
    grip.owner = frame
    grip.corner = cornerName
    grip:SetScript("OnEnter", function(self)
        self.hovered = true
        Grips.Refresh(frame)
    end)
    grip:SetScript("OnLeave", function(self)
        self.hovered = nil
        Grips.Refresh(frame)
    end)
    grip:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then Grips.BeginDrag(self) end
    end)
    grip:SetScript("OnMouseUp", function(_, button)
        if button == "LeftButton" then Grips.EndDrag(frame) end
    end)
    return grip
end

-- options: inset (grip center from the corner, inward), size, edge (light
-- the frame's own corner art instead of drawing a grip), enabled,
-- onStep(frame, scale) after each scale change mid-drag,
-- commit(frame, scale, reanchored).
function Grips.Attach(frame, options)
    local grips = { options = options }
    for _, cornerName in ipairs(CORNER_ORDER) do
        grips[#grips + 1] = MakeGrip(frame, cornerName, options)
    end
    frame._scaleGrips = grips
    Grips.frames[#Grips.frames + 1] = frame
    -- A window hidden mid-drag keeps the scale it reached.
    frame:HookScript("OnHide", function(self) Grips.EndDrag(self) end)
    frame:HookScript("OnShow", function(self) Grips.Refresh(self) end)
    Grips.Refresh(frame)
end

-- A sub-panel follows the Window Scale and keeps a factor of its own, which
-- its grips set. Scaling from a corner away from its anchor undocks it, the
-- same as moving it would.
function Grips.AttachSubPanel(frame, key)
    -- Saves the factor and re-renders at that scale, at every drag step and
    -- on release.
    local function Relayout(window, scale)
        local base = math.max(RR:GetSetting("windowScale", 1.0), 0.01)
        RR:SetSetting(key, scale / base)
        UI.RefitWindow(window, scale, RR:GetSetting("panelOpacity", 1.0), true)
        UI.SnapProgressCells()
    end
    Grips.Attach(frame, {
        inset  = 0,
        onStep = Relayout,
        commit = function(window, scale, reanchored)
            if reanchored then
                local left, top = window:GetLeft(), window:GetTop()
                if left and top then
                    window:ClearAllPoints()
                    window:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", left, top)
                end
                window.userPlaced = true
            end
            if window.userPlaced then UI.SaveWindowSpot(window) end
            Relayout(window, scale)
        end,
    })
end

-- Sets the Window Scale and re-lays out everything it drives, at every drag
-- step and on release.
local function RelayoutMainPanel(_, scale)
    RR:SetSetting("windowScale", scale)
    UI.ApplySettings()
    UI.ApplyMinimizedState()
    UI.SnapProgressCells()
    UI.PlaceUseButton()
end

-- The main panel: its ornate corners are the handles, lit rather than
-- marked. Hidden while minimized; a release saves the panel's corner the way
-- a move does.
Grips.Attach(RetroRunsUI, {
    inset   = 10,
    size    = 20,
    edge    = UI.PanelBackdrop(UI.PANEL_EDGE_SIZE_FULL),
    enabled = function() return not UI.IsMinimized() end,
    onStep  = RelayoutMainPanel,
    commit  = function(panel, scale)
        SavePanelCorner(panel, "scale-drag")
        RelayoutMainPanel(panel, scale)
        if UI.RefreshSettingsControls then UI.RefreshSettingsControls() end
    end,
})
