-------------------------------------------------------------------------------
-- RetroRuns -- MinimapButton.lua
-- Circular minimap button. Left-click toggles the panel, right-click
-- opens settings. Drag to reposition. Position saved in RetroRunsDB.
-------------------------------------------------------------------------------

local RR = RetroRuns

local btn = CreateFrame("Button", "RetroRunsMinimapButton", Minimap)
btn:SetSize(36, 36)
btn:SetFrameStrata("HIGH")
btn:SetMovable(true)
btn:EnableMouse(true)
btn:RegisterForDrag("LeftButton", "RightButton")
btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")

-- Icon texture
local texture = btn:CreateTexture(nil, "BACKGROUND")
texture:SetTexture("Interface\\AddOns\\RetroRuns\\Media\\MinimapIcon")
texture:SetAllPoints()
texture:Show()

-- Highlight on mouseover
btn:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

-------------------------------------------------------------------------------
-- Position logic -- orbits the minimap edge, respects minimap shape
-------------------------------------------------------------------------------

local MinimapShapes = {
    ["ROUND"]                = {true,  true,  true,  true },
    ["SQUARE"]               = {false, false, false, false},
    ["CORNER-TOPLEFT"]       = {false, false, false, true },
    ["CORNER-TOPRIGHT"]      = {false, false, true,  false},
    ["CORNER-BOTTOMLEFT"]    = {false, true,  false, false},
    ["CORNER-BOTTOMRIGHT"]   = {true,  false, false, false},
    ["SIDE-LEFT"]            = {false, true,  false, true },
    ["SIDE-RIGHT"]           = {true,  false, true,  false},
    ["SIDE-TOP"]             = {false, false, true,  true },
    ["SIDE-BOTTOM"]          = {true,  true,  false, false},
    ["TRICORNER-TOPLEFT"]    = {false, true,  true,  true },
    ["TRICORNER-TOPRIGHT"]   = {true,  false, true,  true },
    ["TRICORNER-BOTTOMLEFT"] = {true,  true,  false, true },
    ["TRICORNER-BOTTOMRIGHT"]= {true,  true,  true,  false},
}

local function UpdatePosition()
    local position = RR:GetSetting("minimapAngle", 220)
    local angle    = math.rad(position)
    local x, y     = math.cos(angle), math.sin(angle)
    local q        = 1
    if x < 0 then q = q + 1 end
    if y > 0 then q = q + 2 end

    local rounding = 10
    local width    = (Minimap:GetWidth()  * 0.5) + 5
    local height   = (Minimap:GetHeight() * 0.5) + 5
    local shape    = GetMinimapShape and GetMinimapShape() or "ROUND"

    if MinimapShapes[shape] and MinimapShapes[shape][q] then
        x, y = x * width, y * height
    else
        x = math.max(-width,  math.min(x * (math.sqrt(2 * width^2)  - rounding), width))
        y = math.max(-height, math.min(y * (math.sqrt(2 * height^2) - rounding), height))
    end

    btn:ClearAllPoints()
    btn:SetPoint("CENTER", Minimap, "CENTER", math.floor(x), math.floor(y))
end

-------------------------------------------------------------------------------
-- Drag
-------------------------------------------------------------------------------

local function OnUpdate(self)
    local mx, my  = Minimap:GetCenter()
    local px, py  = GetCursorPosition()
    local scale   = Minimap:GetEffectiveScale()
    local angle   = math.deg(math.atan2((py / scale) - my, (px / scale) - mx)) % 360
    RR:SetSetting("minimapAngle", angle)
    UpdatePosition()
end

btn:SetScript("OnDragStart", function(self)
    self:SetScript("OnUpdate", OnUpdate)
end)
btn:SetScript("OnDragStop", function(self)
    self:SetScript("OnUpdate", nil)
end)

-------------------------------------------------------------------------------
-- Click
-------------------------------------------------------------------------------

btn:SetScript("OnClick", function(self, button)
    if button == "RightButton" then
        RR.UI.ToggleSettings()
    else
        SlashCmdList["RETRORUNS"]("toggle")
    end
end)

-------------------------------------------------------------------------------
-- Tooltip
-------------------------------------------------------------------------------

btn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:ClearLines()
    GameTooltip:AddLine("|cffF259C7RETRO|r|cff4DCCFFRUNS|r")
    GameTooltip:AddLine("Left-click to toggle", 1, 1, 1)
    GameTooltip:AddLine("Right-click for settings", 1, 1, 1)
    GameTooltip:AddLine("Drag to reposition", 0.7, 0.7, 0.7)
    GameTooltip:Show()
end)

btn:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

btn:RegisterEvent("LOADING_SCREEN_DISABLED")
btn:SetScript("OnEvent", UpdatePosition)

-------------------------------------------------------------------------------
-- Init (called from Core after DB is ready)
-------------------------------------------------------------------------------

function RR:InitMinimapButton()
    UpdatePosition()
    -- showMinimap default is "true" (button visible). Use `== false` so
    -- only an explicit user-set false hides the button; nil/missing is
    -- treated as the default-visible state.
    if self:GetSetting("showMinimap") == false then
        btn:Hide()
    else
        btn:Show()
    end
end

RR.minimapButton = btn
