-------------------------------------------------------------------------------
-- RetroRuns -- Picker.lua
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
-- Offers an instance's difficulties when the player walks up to its entrance.
-------------------------------------------------------------------------------

local RR = RetroRuns

local Picker = {}
RR.Picker = Picker

-- Yards from an entrance where the bar appears.
Picker.RADIUS = 50
-- Once showing, the bar stays until the player is this much further out.
Picker.HIDE_MARGIN = 3
-- Entrances closer than this are stacked doors and share the bar.
Picker.STACKED_GAP = 15

-- Game difficulty ids each model offers at the door, in button order.
local DOOR_OPTIONS = {
    dungeon          = { 1, 2, 23 },
    independent      = { 14, 15, 16 },
    independentTw    = { 14, 15, 16 },
    single           = { 14 },
    singleTw         = { 14 },
    shared           = { 3, 4, 5, 6 },
    sharedLfr        = { 3, 4, 5, 6 },
    sizesShared      = { 3, 4 },
    sizesHeroic      = { 3, 4, 5, 6 },
    difficultyLocked = { 3, 4, 5, 6 },
}
DOOR_OPTIONS.dungeonBinary = DOOR_OPTIONS.dungeon
DOOR_OPTIONS.dungeonTiered = DOOR_OPTIONS.dungeon

-- The difficulties an instance's door offers, each with the bucket its
-- lockout and loot are counted under.
function Picker.Options(instance)
    local ids = DOOR_OPTIONS[instance.difficultyModel or "independent"]
        or DOOR_OPTIONS.independent
    local fold = RR:GetDifficultyModel(instance).fold
    local shown = {}
    for _, bucket in ipairs(RR:GetDisplayBuckets(instance)) do
        shown[bucket] = true
    end
    local options = {}
    for _, difficultyID in ipairs(ids) do
        local bucket = fold[difficultyID]
        if bucket and shown[bucket] then
            local kind = "raid"
            if instance.kind == "dungeon" then
                kind = "dungeon"
            elseif difficultyID >= 3 and difficultyID <= 6 then
                kind = "legacy"
            end
            options[#options + 1] = {
                difficultyID = difficultyID, bucket = bucket, kind = kind,
            }
        end
    end
    return options
end

-- The difficulty the game will use at a door of this kind. Legacy raids
-- combine the raid setting (Normal or Heroic) with the legacy size.
function Picker.CurrentDifficulty(kind)
    if kind == "dungeon" then
        return GetDungeonDifficultyID and GetDungeonDifficultyID()
    end
    local raidID = GetRaidDifficultyID and GetRaidDifficultyID()
    if kind == "raid" then return raidID end
    local size = GetLegacyRaidDifficultyID and GetLegacyRaidDifficultyID() or 3
    if size == 5 or size == 6 then size = size - 2 end
    if size ~= 3 and size ~= 4 then size = 3 end
    if raidID == 15 then return size + 2 end
    return size
end

function Picker.SetDifficulty(option)
    if option.kind == "dungeon" then
        SetDungeonDifficultyID(option.difficultyID)
    elseif option.kind == "raid" then
        SetRaidDifficultyID(option.difficultyID)
    else
        local id = option.difficultyID
        SetRaidDifficultyID(id >= 5 and 15 or 14)
        if SetLegacyRaidDifficultyID then
            SetLegacyRaidDifficultyID((id == 3 or id == 5) and 3 or 4)
        end
    end
end

-- Why the player cannot change difficulty right now, or nil.
function Picker.ChangeBlocked()
    if IsInGroup(LE_PARTY_CATEGORY_INSTANCE or 2) then return "finder" end
    if IsInGroup() and not UnitIsGroupLeader("player") then return "leader" end
    return nil
end

local function Distance(a, b)
    local dx, dy = a.x - b.x, a.y - b.y
    return math.sqrt(dx * dx + dy * dy)
end
Picker.Distance = Distance

-- Each entrance's radius: the default, or half the gap to its nearest
-- neighbour when that is closer. Stacked doors do not shrink each other.
function Picker.AssignRadii(entries)
    for _, entry in ipairs(entries) do
        local nearest
        for _, other in ipairs(entries) do
            if other ~= entry and other.continentID == entry.continentID then
                local gap = Distance(entry, other)
                if gap >= Picker.STACKED_GAP and (not nearest or gap < nearest) then
                    nearest = gap
                end
            end
        end
        entry.radius = Picker.RADIUS
        if nearest and nearest / 2 < entry.radius then
            entry.radius = nearest / 2
        end
    end
end

-- Entrances covering the point: the nearest one plus any door stacked with
-- it. A door already showing keeps its margin.
function Picker.InRange(entries, continentID, x, y, showing)
    local here = { x = x, y = y }
    local hits = {}
    for _, entry in ipairs(entries) do
        if entry.continentID == continentID then
            local distance = Distance(entry, here)
            local limit = entry.radius
            if showing and showing[entry.key] then
                limit = limit + Picker.HIDE_MARGIN
            end
            if distance <= limit then
                hits[#hits + 1] = { entry = entry, distance = distance }
            end
        end
    end
    if #hits == 0 then return hits end
    table.sort(hits, function(a, b) return a.distance < b.distance end)
    local nearest = hits[1].entry
    local kept = { hits[1] }
    for index = 2, #hits do
        if Distance(hits[index].entry, nearest) < Picker.STACKED_GAP then
            kept[#kept + 1] = hits[index]
        end
    end
    return kept
end

local function WorldPosition(mapID, x, y)
    if not (mapID and x and y and C_Map and C_Map.GetWorldPosFromMapPos
        and CreateVector2D) then
        return nil
    end
    local continentID, world = C_Map.GetWorldPosFromMapPos(mapID, CreateVector2D(x, y))
    if not (continentID and world) then return nil end
    return continentID, world.x, world.y
end

-- Every supported instance's entrance in world yards, built once.
function Picker.EntranceIndex()
    if Picker.index then return Picker.index end
    local entries = {}
    local function Add(instance, kind)
        if type(instance) ~= "table" or not instance.instanceID
            or instance.instanceID == 0 then
            return
        end
        local entrance = RR:GetRaidEntrance(instance)
        if not entrance then return end
        local continentID, x, y = WorldPosition(entrance.mapID, entrance.x, entrance.y)
        if not continentID then return end
        entries[#entries + 1] = {
            instance = instance,
            key = kind .. ":" .. (instance.journalInstanceID or instance.instanceID),
            continentID = continentID, x = x, y = y,
        }
    end
    for instanceID in pairs(RetroRuns_Data or {}) do
        Add(RR:GetRaidByInstanceID(instanceID), "raid")
    end
    for _, dungeon in pairs(RetroRuns_DungeonData or {}) do
        Add(dungeon, "dungeon")
    end
    Picker.AssignRadii(entries)
    Picker.index = entries
    return entries
end

local function PlayerWorldPosition()
    local mapID = C_Map and C_Map.GetBestMapForUnit and C_Map.GetBestMapForUnit("player")
    if not mapID then return nil end
    local position = C_Map.GetPlayerMapPosition(mapID, "player")
    if not position then return nil end
    local x, y = position:GetXY()
    if issecretvalue and (issecretvalue(x) or issecretvalue(y)) then return nil end
    return WorldPosition(mapID, x, y)
end

local function SameKeys(a, b)
    if not a or not b then return false end
    for key in pairs(a) do if not b[key] then return false end end
    for key in pairs(b) do if not a[key] then return false end end
    return true
end

-- Runs on the heartbeat: shows the bar at an entrance, hides it elsewhere.
function RR:PickerTick()
    local bar = self.UI and self.UI.PickerBar
    if not bar then return end
    local hits
    if self:GetSetting("pickerEnabled", true) and not IsInInstance() then
        local ok, continentID, x, y = pcall(PlayerWorldPosition)
        if ok and continentID then
            hits = Picker.InRange(Picker.EntranceIndex(), continentID, x, y, Picker.showing)
        end
    end
    if not hits or #hits == 0 then
        Picker.showing = nil
        bar.Hide()
        return
    end
    local showing = {}
    for _, hit in ipairs(hits) do showing[hit.entry.key] = true end
    if not SameKeys(showing, Picker.showing) then
        Picker.showing = showing
        bar.Show(hits)
    end
end
