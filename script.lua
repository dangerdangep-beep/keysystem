--[[ Opleoni Aura v1.5 — Auto Farm + Sprinkler + Dupe Modes + Boost Market ]]

-- ============================================================
-- НАСТРОЙКИ
-- ============================================================
local DIG_INTERVAL      = 0.15
local MOVETO_REFRESH    = 0.25
local TOKEN_RADIUS      = 80
local DUPE_RADIUS       = 200
local DUPE_WAIT         = 2.5
local DUPE_COOLDOWN     = 10
local FIELD_Z_STEP      = 10
local FIELD_SHRINK      = 0.72

local STICKER_STACK_TICKET_COST = 25
local STICKER_STACK_INTERVAL    = 40 * 60

-- Boost Market
local BOOST_MARKET_NAME       = "Boost Market"
local BOOST_MARKET_INTERVAL   = 30 * 60
local BOOST_MARKET_TICKET     = 50
local DEBUG_BM                = true

local BOOST_FIELD_LIST = {
    "Stump Field Market Boost",
    "Pineapple Patch Market Boost",
    "Pumpkin Patch Market Boost",
    "Dandelion Field Market Boost",
    "Sunflower Field Market Boost",
    "Strawberry Field Market Boost",
    "Bamboo Field Market Boost",
    "Blue Flower Field Market Boost",
    "Cactus Field Market Boost",
    "Clover Field Market Boost",
    "Coconut Field Market Boost",
    "Mountain Top Field Market Boost",
    "Mushroom Field Market Boost",
    "Pepper Patch Market Boost",
    "Pine Tree Forest Market Boost",
    "Rose Field Market Boost",
    "Spider Field Market Boost",
}
local selectedBoostField = "Stump Field Market Boost"

local function getBoostBuffName()
    return selectedBoostField
end

local FIRE_SCAN_RADIUS      = 500
local FIRE_SCAN_EVERY       = 3
local FIRE_LOOK_SMOOTH      = 0.15
local FIRE_ROTATE_BODY      = true
local FIRE_ROTATE_CAMERA    = true

-- FLY / WALK
local FLY_SPEED             = 12
local WALK_SPEED            = 32
local FLY_MIN_DURATION      = 0.4
local FLY_MAX_DURATION      = 4
local FIELD_OUT_MARGIN      = 15
local AUTOFARM_FLY_ON_START = true
local FLY_NOCLIP            = true
local FLY_LAND_OFFSET       = 3

-- Sprinkler
local SPRINKLER_TYPE        = "SprinklerBuilder"
local SPRINKLER_USES        = 5
local SPRINKLER_DELAY       = 0.15

-- Dupe modes
local DUPE_MODES = {
    "Any Star Aura",
    "Only Gummy Star Aura",
    "Only Pop Star Aura",
    "Both Stars Active",
    "Always",
}
local currentDupeMode = 1

-- ============================================================
-- ПОЛЯ
-- ============================================================
local STUMP_CENTER = Vector3.new(-124.678, 157.219, 2590.366)
local STUMP_HALF_X = 35
local STUMP_HALF_Z = 40

local FIELDS = {
    { name = "Dandelion Field",     center = Vector3.new(-629.091, 68.306, 3046.47),    size = Vector3.new(143.65, 1, 72.5) },
    { name = "Sunflower Field",     center = Vector3.new(-791.736, 68.326, 2979.465),   size = Vector3.new(80.71, 1, 131.51) },
    { name = "Strawberry Field",    center = Vector3.new(-851.916, 86.826, 2706.075),   size = Vector3.new(89.65, 2, 106.29) },
    { name = "Bamboo Field",        center = Vector3.new(-441.866, 86.826, 2777.12),    size = Vector3.new(156.45, 2, 74.8) },
    { name = "Blue Flower Field",   center = Vector3.new(-444.776, 68.876, 2863.387),   size = Vector3.new(171.63, 2, 67.665) },
    { name = "Cactus Field",        center = Vector3.new(-1061.591, 122.323, 2754.815), size = Vector3.new(135, 1, 68.81) },
    { name = "Clover Field",        center = Vector3.new(-421.338, 87.826, 2973.095),   size = Vector3.new(126.494, 2, 118.75) },
    { name = "Coconut Field",       center = Vector3.new(-849.756, 131.426, 3439.375),  size = Vector3.new(120.31, 1, 84.33),  rot90 = true },
    { name = "Mountain Top Field",  center = Vector3.new(-750.956, 257.326, 2539.61),   size = Vector3.new(97.73, 1, 110.82) },
    { name = "Mushroom Field",      center = Vector3.new(-672.341, 68.826, 2921.47),    size = Vector3.new(128.5, 2, 91.5) },
    { name = "Pepper Patch",        center = Vector3.new(-981.624, 100.326, 3508.885),  size = Vector3.new(82.39, 1, 110.55),  rot90 = true },
    { name = "Pine Tree Forest",    center = Vector3.new(-1090.901, 122.326, 2626.72),  size = Vector3.new(90.62, 1, 130) },
    { name = "Pineapple Patch",     center = Vector3.new(-530.146, 144.826, 2598.383),  size = Vector3.new(130.673, 2, 91.11), rot90 = true },
    { name = "Pumpkin Patch",       center = Vector3.new(-969.996, 122.326, 2623.72),   size = Vector3.new(135, 1, 68.81),     rot90 = true },
    { name = "Rose Field",          center = Vector3.new(-960.625, 107.326, 2981.79),   size = Vector3.new(123.07, 1, 82.86) },
    { name = "Spider Field",        center = Vector3.new(-703.246, 86.419, 2762.71),    size = Vector3.new(112.31, 2, 106.02) },
}

local STUMP_FIELD = {
    name = "Stump Field",
    center = STUMP_CENTER,
    size = Vector3.new(STUMP_HALF_X * 2, 2, STUMP_HALF_Z * 2),
    isStump = true,
}

local selectedField = FIELDS[1]

-- ============================================================
-- МАТЕРИАЛЫ
-- ============================================================
local MATERIALS = {
    { name = "Festive Bean",    type = "FestiveBean",    interval = 180,  count = 1, delay = 0 },
    { name = "Marshmallow Bee", type = "MarshmallowBee", interval = 1860, count = 1, delay = 0 },
    { name = "Super Smoothie",  type = "SuperSmoothie",  interval = 1740, count = 1, delay = 0 },
    { name = "Cloud Vial",      type = "CloudVial",      interval = 2,    count = 1, delay = 2.0 },
}

local Toggles = {
    AutoFarm = false,
    AutoSprinkler = false,
    AutoDig = false,
    AutoCollectTokens = false,
    AutoDupeGlitchTokens = false,
    SquareFarm = false,
    FaceOnFires = false,
    AutoStickerStack = false,
    AutoBoostMarket = false,
}
local MaterialToggles = {}
for _, mat in ipairs(MATERIALS) do MaterialToggles[mat.name] = false end

-- ============================================================
-- СЕРВИСЫ
-- ============================================================
local Players           = game:GetService("Players")
local TweenService      = game:GetService("TweenService")
local Workspace         = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService  = game:GetService("UserInputService")
local player = Players.LocalPlayer

local Events
pcall(function() Events = require(ReplicatedStorage.Shared.Network.Events) end)

local eggTypes
pcall(function() eggTypes = require(ReplicatedStorage.Game.ItemsAndEconomy.EggTypes) end)

local NetworkFolder = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Network")
local EventsFolder  = NetworkFolder:WaitForChild("Events")

local codec
pcall(function() codec = require(NetworkFolder:WaitForChild("RemotePayloadCodec")) end)

local function decodeArgs(...)
    local raw = { ... }
    if #raw == 0 then return raw end
    if type(raw[1]) ~= "buffer" and type(raw[1]) ~= "table" then return raw end
    if codec then
        for _, m in ipairs({ "UnpackArgs", "Unpack", "Decode", "DecodeArgs" }) do
            if type(codec[m]) == "function" then
                local ok, decoded = pcall(codec[m], ...)
                if ok and type(decoded) == "table" then
                    local n = decoded.n or #decoded
                    local out = {}
                    for i = 1, n do out[i] = decoded[i] end
                    return out
                end
            end
        end
    end
    return raw
end

-- ============================================================
-- BOOST MARKET — state + hook
-- ============================================================
local boostSummary, boostPending, boostPendingName = nil, false, nil

local function handleBMResponse(payload)
    if type(payload) ~= "table" then return end
    if DEBUG_BM then print("[BM] in:", payload.Action, payload.MarketName) end
    if payload.Action == "UpdateSummary" then
        if payload.MarketName == boostPendingName then
            boostSummary = payload.Summary
            boostPending = false
        end
    elseif payload.Action == "RegisterPurchase" then
        print("[BM] >> purchase OK:", tostring(payload.MarketName))
    end
end

if Events and not Events._AutoFarmHooked then
    Events._AutoFarmHooked = true
    local orig = Events.ClientListen
    Events.ClientListen = function(name, callback, ...)
        if name == "BoostMarketEvent" and type(callback) == "function" then
            local wrapped = function(p) pcall(handleBMResponse, p); return callback(p) end
            return orig(name, wrapped, ...)
        end
        return orig(name, callback, ...)
    end
end

task.spawn(function()
    local ok, err = pcall(function()
        local bmGui = require(ReplicatedStorage.Client.Gui.Gui.BoostMarketGui)
        local pg = player:WaitForChild("PlayerGui", 10)
        local sg = pg and pg:WaitForChild("ScreenGui", 10)
        if sg then
            bmGui.Init(sg)
            print("[BM] BoostMarketGui.Init OK")
        else
            warn("[BM] ScreenGui not found")
        end
    end)
    if not ok then warn("[BM] init fail:", err) end
end)

-- ============================================================
-- АУРЫ
-- ============================================================
local STAR_BUFFS = {
    ["Gummy Star Aura"] = true,
    ["Pop Star Aura"]   = true,
}
local activeStars = {
    ["Gummy Star Aura"] = false,
    ["Pop Star Aura"]   = false,
}

local starLastApply = {
    ["Gummy Star Aura"] = 0,
    ["Pop Star Aura"]   = 0,
}
local starLastRemove = {
    ["Gummy Star Aura"] = 0,
    ["Pop Star Aura"]   = 0,
}
local STAR_REMOVE_GRACE = 2

local buffEvent = EventsFolder:FindFirstChild("ServerBuffEvent")
local fxEvent   = EventsFolder:FindFirstChild("LocalFX")

local function applyStarRemove(buffName)
    starLastRemove[buffName] = tick()
    if tick() - starLastApply[buffName] <= STAR_REMOVE_GRACE then
        return
    end
    activeStars[buffName] = false
end

if buffEvent and buffEvent:IsA("RemoteEvent") then
    buffEvent.OnClientEvent:Connect(function(...)
        local args = decodeArgs(...)
        local action, buffName = args[1], args[2]
        if STAR_BUFFS[buffName] then
            if action == "Apply" or action == "ChangeCombo" or action == "ChangeStartTime" then
                activeStars[buffName] = true
                starLastApply[buffName] = tick()
            elseif action == "Remove" then
                applyStarRemove(buffName)
            end
        end
    end)
end

if fxEvent and fxEvent:IsA("RemoteEvent") then
    fxEvent.OnClientEvent:Connect(function(...)
        local args = decodeArgs(...)
        local efName, payload = args[1], args[2]
        local function h(n, p)
            if type(p) ~= "table" then return end
            if n == "GummyStar" then
                if p.Action == "Make" then
                    activeStars["Gummy Star Aura"] = true
                    starLastApply["Gummy Star Aura"] = tick()
                elseif p.Action == "Destroy" then
                    applyStarRemove("Gummy Star Aura")
                end
            elseif n == "PopStar" then
                if p.Action == "Make" or p.Action == "Grow" then
                    activeStars["Pop Star Aura"] = true
                    starLastApply["Pop Star Aura"] = tick()
                elseif p.Action == "Destroy" then
                    applyStarRemove("Pop Star Aura")
                end
            end
        end
        if efName == "__Batch" and type(payload) == "table" then
            for _, e in ipairs(payload) do
                if type(e) == "table" then h(e[1], e[2]) end
            end
        else h(efName, payload) end
    end)
end

local function isStarAuraActive()
    return activeStars["Gummy Star Aura"] or activeStars["Pop Star Aura"]
end
local function isGummyStarActive() return isStarAuraActive() end

local function isDupeAllowed()
    local mode = DUPE_MODES[currentDupeMode]
    local gummy = activeStars["Gummy Star Aura"]
    local pop   = activeStars["Pop Star Aura"]

    if mode == "Any Star Aura" then
        if gummy then return true end
        if pop then return true end
        return false
    elseif mode == "Only Gummy Star Aura" then
        return gummy
    elseif mode == "Only Pop Star Aura" then
        return pop
    elseif mode == "Both Stars Active" then
        return gummy and pop
    else
        return true
    end
end

-- ============================================================
-- Helpers
-- ============================================================
local function getChar()
    local char = player.Character
    if not char then return nil, nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return nil, nil end
    return hrp, hum
end

local function fireEvent(eventName, ...)
    if not Events then return end
    local args = { ... }
    task.spawn(function()
        pcall(function() Events.ClientCall(eventName, table.unpack(args)) end)
    end)
end

-- ============================================================
-- FLY TO
-- ============================================================
local flying = false

local function setNoclip(enabled)
    local char = player.Character
    if not char then return end
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") then
            if enabled then
                if p:GetAttribute("_FlySavedCanCollide") == nil then
                    p:SetAttribute("_FlySavedCanCollide", p.CanCollide)
                end
                p.CanCollide = false
            else
                local saved = p:GetAttribute("_FlySavedCanCollide")
                if saved ~= nil then
                    p.CanCollide = saved
                    p:SetAttribute("_FlySavedCanCollide", nil)
                end
            end
        end
    end
end

local function flyTo(targetPos, overrideSpeed)
    if flying then return false end
    local hrp, hum = getChar()
    if not hrp or not hum then return false end

    flying = true
    if FLY_NOCLIP then setNoclip(true) end

    local wasAnchored = hrp.Anchored
    hrp.Anchored = true

    local dir = targetPos - hrp.Position
    local flat = Vector3.new(dir.X, 0, dir.Z)
    local targetCFrame
    if flat.Magnitude > 0.1 then
        targetCFrame = CFrame.lookAt(targetPos, targetPos + flat.Unit)
    else
        targetCFrame = CFrame.new(targetPos)
    end

    local distance = (targetPos - hrp.Position).Magnitude
    local speed = overrideSpeed or FLY_SPEED
    local dur = math.clamp(distance / speed, FLY_MIN_DURATION, FLY_MAX_DURATION)

    local tween = TweenService:Create(
        hrp,
        TweenInfo.new(dur, Enum.EasingStyle.Linear),
        { CFrame = targetCFrame }
    )
    tween:Play()
    tween.Completed:Wait()

    hrp.Anchored = wasAnchored
    if FLY_NOCLIP then setNoclip(false) end
    flying = false
    return true
end

local function fieldLandPos(f)
    return Vector3.new(f.center.X, f.center.Y + FLY_LAND_OFFSET, f.center.Z)
end

-- ============================================================
-- WAYPOINTS
-- ============================================================
local fieldWaypoints, currentWaypoint = {}, 1
local squareWaypoints = {}

local function rebuildWaypoints()
    fieldWaypoints = {}
    squareWaypoints = {}
    currentWaypoint = 1
    local f = selectedField

    if f.isStump then
        local cx, cy, cz = STUMP_CENTER.X, STUMP_CENTER.Y, STUMP_CENTER.Z
        local xMin, xMax = cx - STUMP_HALF_X, cx + STUMP_HALF_X
        local zMin, zMax = cz - STUMP_HALF_Z, cz + STUMP_HALF_Z
        local row, z = 0, zMin
        while z <= zMax do
            if row % 2 == 0 then
                table.insert(fieldWaypoints, Vector3.new(xMin, cy, z))
                table.insert(fieldWaypoints, Vector3.new(xMax, cy, z))
            else
                table.insert(fieldWaypoints, Vector3.new(xMax, cy, z))
                table.insert(fieldWaypoints, Vector3.new(xMin, cy, z))
            end
            row = row + 1
            z = z + 12
        end
        squareWaypoints = {
            Vector3.new(xMin, cy, zMin),
            Vector3.new(xMax, cy, zMin),
            Vector3.new(xMax, cy, zMax),
            Vector3.new(xMin, cy, zMax),
        }
        return
    end

    local cx, cy, cz = f.center.X, f.center.Y, f.center.Z
    local sizeX, sizeZ = f.size.X, f.size.Z
    if f.rot90 then sizeX, sizeZ = sizeZ, sizeX end
    local hx = (sizeX / 2) * FIELD_SHRINK
    local hz = (sizeZ / 2) * FIELD_SHRINK
    local xMin, xMax = cx - hx, cx + hx
    local zMin, zMax = cz - hz, cz + hz
    local step = FIELD_Z_STEP
    local row, z = 0, zMin
    while z <= zMax + 0.01 do
        if row % 2 == 0 then
            table.insert(fieldWaypoints, Vector3.new(xMin, cy, z))
            table.insert(fieldWaypoints, Vector3.new(xMax, cy, z))
        else
            table.insert(fieldWaypoints, Vector3.new(xMax, cy, z))
            table.insert(fieldWaypoints, Vector3.new(xMin, cy, z))
        end
        row = row + 1
        z = zMin + row * step
    end
    squareWaypoints = {
        Vector3.new(xMin, cy, zMin),
        Vector3.new(xMax, cy, zMin),
        Vector3.new(xMax, cy, zMax),
        Vector3.new(xMin, cy, zMax),
    }
end
rebuildWaypoints()

local function isInsideField(hrp, f)
    local cx, cy, cz = f.center.X, f.center.Y, f.center.Z
    local hx, hz
    if f.isStump then
        hx, hz = STUMP_HALF_X, STUMP_HALF_Z
    else
        hx = f.size.X / 2
        hz = f.size.Z / 2
        if f.rot90 then hx, hz = hz, hx end
    end
    local dx = math.abs(hrp.Position.X - cx)
    local dz = math.abs(hrp.Position.Z - cz)
    return dx <= hx + FIELD_OUT_MARGIN and dz <= hz + FIELD_OUT_MARGIN
end

local function getCurrentFieldName(hrp)
    for _, f in ipairs(FIELDS) do
        if isInsideField(hrp, f) then return f.name end
    end
    if isInsideField(hrp, STUMP_FIELD) then return STUMP_FIELD.name end
    return nil
end

-- ============================================================
-- FIRES
-- ============================================================
local fireList = {}
local function refreshFireList()
    local newList = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Fire") then
            local parent = obj.Parent
            if parent and parent:IsA("BasePart") then
                table.insert(newList, parent)
            end
        end
    end
    fireList = newList
end
task.spawn(function()
    while true do
        pcall(refreshFireList)
        task.wait(FIRE_SCAN_EVERY)
    end
end)

local function getNearestFire(hrp)
    local best, bestD = nil, FIRE_SCAN_RADIUS
    for _, f in ipairs(fireList) do
        if f.Parent then
            local d = (f.Position - hrp.Position).Magnitude
            if d < bestD then best, bestD = f, d end
        end
    end
    return best
end

-- ============================================================
-- UI
-- ============================================================
local playerGui = player:WaitForChild("PlayerGui")

local C = {
    bg         = Color3.fromRGB(20, 20, 24),
    sidebar    = Color3.fromRGB(26, 26, 32),
    sidebarTop = Color3.fromRGB(16, 16, 20),
    content    = Color3.fromRGB(30, 30, 38),
    itemHover  = Color3.fromRGB(40, 40, 50),
    itemActive = Color3.fromRGB(48, 46, 68),
    accent     = Color3.fromRGB(120, 110, 220),
    text       = Color3.fromRGB(235, 235, 240),
    textDim    = Color3.fromRGB(140, 140, 155),
    border     = Color3.fromRGB(45, 45, 58),
    toggleOn   = Color3.fromRGB(100, 90, 200),
    toggleOff  = Color3.fromRGB(46, 46, 58),
    section    = Color3.fromRGB(24, 24, 30),
}

local FONT_BOLD = Enum.Font.GothamBold

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "OpleoniAura"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

local WINDOW_W, WINDOW_H = 560, 400
local SIDEBAR_W = 150

local shadow = Instance.new("ImageLabel")
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://5028857084"
shadow.ImageColor3 = Color3.new(0, 0, 0)
shadow.ImageTransparency = 0.5
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(24, 24, 276, 276)
shadow.Size = UDim2.new(0, WINDOW_W + 16, 0, WINDOW_H + 16)
shadow.Position = UDim2.new(0, 92, 0, 142)
shadow.ZIndex = 0
shadow.Parent = screenGui

local main = Instance.new("Frame")
main.Size = UDim2.new(0, WINDOW_W, 0, WINDOW_H)
main.Position = UDim2.new(0, 100, 0, 150)
main.BackgroundColor3 = C.bg
main.BorderSizePixel = 0
main.Active = true
main.Parent = screenGui
main.ZIndex = 1
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = C.border
mainStroke.Thickness = 1
mainStroke.Parent = main

local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, SIDEBAR_W, 1, 0)
sidebar.BackgroundColor3 = C.sidebar
sidebar.BorderSizePixel = 0
sidebar.Parent = main
sidebar.ZIndex = 2
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 10)

local sidebarMask = Instance.new("Frame")
sidebarMask.Size = UDim2.new(0, 10, 1, 0)
sidebarMask.Position = UDim2.new(1, -10, 0, 0)
sidebarMask.BackgroundColor3 = C.sidebar
sidebarMask.BorderSizePixel = 0
sidebarMask.ZIndex = 2
sidebarMask.Parent = sidebar

local logoFrame = Instance.new("Frame")
logoFrame.Size = UDim2.new(1, 0, 0, 40)
logoFrame.BackgroundColor3 = C.sidebarTop
logoFrame.BorderSizePixel = 0
logoFrame.Parent = sidebar
logoFrame.ZIndex = 3
Instance.new("UICorner", logoFrame).CornerRadius = UDim.new(0, 10)

local logoMask = Instance.new("Frame")
logoMask.Size = UDim2.new(1, 0, 0, 10)
logoMask.Position = UDim2.new(0, 0, 1, -10)
logoMask.BackgroundColor3 = C.sidebarTop
logoMask.BorderSizePixel = 0
logoMask.ZIndex = 3
logoMask.Parent = logoFrame

local logoDot = Instance.new("Frame")
logoDot.Size = UDim2.new(0, 8, 0, 8)
logoDot.Position = UDim2.new(0, 12, 0.5, -4)
logoDot.BackgroundColor3 = C.accent
logoDot.BorderSizePixel = 0
logoDot.Parent = logoFrame
logoDot.ZIndex = 4
Instance.new("UICorner", logoDot).CornerRadius = UDim.new(1, 0)

local logoText = Instance.new("TextLabel")
logoText.Size = UDim2.new(1, -30, 1, 0)
logoText.Position = UDim2.new(0, 28, 0, 0)
logoText.BackgroundTransparency = 1
logoText.Text = "Opleoni Aura"
logoText.TextColor3 = C.text
logoText.Font = FONT_BOLD
logoText.TextSize = 13
logoText.TextXAlignment = Enum.TextXAlignment.Left
logoText.Parent = logoFrame
logoText.ZIndex = 4

local navHolder = Instance.new("Frame")
navHolder.Size = UDim2.new(1, -16, 1, -56)
navHolder.Position = UDim2.new(0, 8, 0, 48)
navHolder.BackgroundTransparency = 1
navHolder.Parent = sidebar
navHolder.ZIndex = 3
Instance.new("UIListLayout", navHolder).Padding = UDim.new(0, 2)

local pages = {}
local navBtns = {}
local activePage = nil

local function setPage(name)
    activePage = name
    for n, page in pairs(pages) do page.Visible = (n == name) end
    for n, btn in pairs(navBtns) do
        local active = (n == name)
        TweenService:Create(btn, TweenInfo.new(0.15), {
            BackgroundColor3 = active and C.itemActive or C.sidebar,
            TextColor3 = active and C.text or C.textDim,
        }):Play()
    end
end

local NAV_ITEMS = { "Home", "Farming", "Combat", "Quests", "Planters", "Toys", "RBC", "Webhook", "Settings" }

local contentHolder = Instance.new("Frame")
contentHolder.Size = UDim2.new(1, -SIDEBAR_W, 1, 0)
contentHolder.Position = UDim2.new(0, SIDEBAR_W, 0, 0)
contentHolder.BackgroundTransparency = 1
contentHolder.Parent = main
contentHolder.ZIndex = 2

for _, name in ipairs(NAV_ITEMS) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 28)
    btn.BackgroundColor3 = C.sidebar
    btn.BorderSizePixel = 0
    btn.Text = "   " .. name
    btn.TextColor3 = C.textDim
    btn.Font = FONT_BOLD
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = navHolder
    btn.ZIndex = 3
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, -16, 1, -16)
    page.Position = UDim2.new(0, 8, 0, 8)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = C.accent
    page.CanvasSize = UDim2.new(0, 0, 0, 500)
    page.Visible = false
    page.Parent = contentHolder
    page.ZIndex = 2
    local layout = Instance.new("UIListLayout", page)
    layout.Padding = UDim.new(0, 6)

    pages[name] = page
    navBtns[name] = btn

    btn.MouseButton1Click:Connect(function() setPage(name) end)
    btn.MouseEnter:Connect(function()
        if activePage ~= name then
            TweenService:Create(btn, TweenInfo.new(0.12), {
                BackgroundColor3 = C.itemHover }):Play()
        end
    end)
    btn.MouseLeave:Connect(function()
        if activePage ~= name then
            TweenService:Create(btn, TweenInfo.new(0.12), {
                BackgroundColor3 = C.sidebar }):Play()
        end
    end)
end

local function makeSection(parent, title)
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, 0, 0, 28)
    section.BackgroundColor3 = C.section
    section.BorderSizePixel = 0
    section.Parent = parent
    Instance.new("UICorner", section).CornerRadius = UDim.new(0, 6)
    local stroke = Instance.new("UIStroke", section)
    stroke.Color = C.border
    stroke.Thickness = 1
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -16, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = title
    label.TextColor3 = C.text
    label.Font = FONT_BOLD
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = section
    return section
end

local function makeToggle(parent, name, labelText, toggleTable)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 28)
    card.BackgroundColor3 = C.content
    card.BorderSizePixel = 0
    card.Parent = parent
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 5)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = C.text
    label.Font = FONT_BOLD
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = card

    local box = Instance.new("Frame")
    box.Size = UDim2.new(0, 16, 0, 16)
    box.Position = UDim2.new(1, -28, 0.5, -8)
    box.BackgroundColor3 = C.toggleOff
    box.BorderSizePixel = 0
    box.Parent = card
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)
    local boxStroke = Instance.new("UIStroke", box)
    boxStroke.Color = C.border
    boxStroke.Thickness = 1

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 8, 0, 8)
    dot.Position = UDim2.new(0.5, -4, 0.5, -4)
    dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    dot.BorderSizePixel = 0
    dot.BackgroundTransparency = 1
    dot.Parent = box
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

    local click = Instance.new("TextButton")
    click.Size = UDim2.new(1, 0, 1, 0)
    click.BackgroundTransparency = 1
    click.Text = ""
    click.Parent = card

    local on = false
    click.MouseButton1Click:Connect(function()
        on = not on
        toggleTable[name] = on
        TweenService:Create(box, TweenInfo.new(0.15), {
            BackgroundColor3 = on and C.toggleOn or C.toggleOff }):Play()
        TweenService:Create(dot, TweenInfo.new(0.15), {
            BackgroundTransparency = on and 0 or 1 }):Play()
        TweenService:Create(card, TweenInfo.new(0.15), {
            BackgroundColor3 = on and C.itemActive or C.content }):Play()
    end)
    click.MouseEnter:Connect(function()
        if not on then TweenService:Create(card, TweenInfo.new(0.1), { BackgroundColor3 = C.itemHover }):Play() end
    end)
    click.MouseLeave:Connect(function()
        if not on then TweenService:Create(card, TweenInfo.new(0.1), { BackgroundColor3 = C.content }):Play() end
    end)
    return card
end

local function makeDropdown(parent, labelText, items, defaultIndex, onChange)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 30)
    card.BackgroundColor3 = C.content
    card.BorderSizePixel = 0
    card.Parent = parent
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 5)

    local stroke = Instance.new("UIStroke", card)
    stroke.Color = C.border
    stroke.Thickness = 1

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 90, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = C.textDim
    label.Font = FONT_BOLD
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = card

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(1, -140, 1, 0)
    valueLabel.Position = UDim2.new(0, 102, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = items[defaultIndex or 1]
    valueLabel.TextColor3 = C.text
    valueLabel.Font = FONT_BOLD
    valueLabel.TextSize = 12
    valueLabel.TextXAlignment = Enum.TextXAlignment.Left
    valueLabel.TextTruncate = Enum.TextTruncate.AtEnd
    valueLabel.Parent = card

    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 20, 1, 0)
    arrow.Position = UDim2.new(1, -26, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "v"
    arrow.TextColor3 = C.textDim
    arrow.Font = FONT_BOLD
    arrow.TextSize = 12
    arrow.Parent = card

    local click = Instance.new("TextButton")
    click.Size = UDim2.new(1, 0, 1, 0)
    click.BackgroundTransparency = 1
    click.Text = ""
    click.Parent = card

    local listHolder = nil
    local currentIndex = defaultIndex or 1

    local function closeList()
        if listHolder then listHolder:Destroy(); listHolder = nil end
    end

    click.MouseButton1Click:Connect(function()
        if listHolder then closeList(); return end
        local abs = card.AbsolutePosition
        local sz = card.AbsoluteSize
        local listHeight = math.min(#items * 22 + 8, 220)

        listHolder = Instance.new("Frame")
        listHolder.Size = UDim2.new(0, sz.X, 0, listHeight)
        listHolder.Position = UDim2.new(0, abs.X, 0, abs.Y + sz.Y + 4)
        listHolder.BackgroundColor3 = Color3.fromRGB(34, 34, 44)
        listHolder.BorderSizePixel = 0
        listHolder.ZIndex = 999
        listHolder.Parent = screenGui
        Instance.new("UICorner", listHolder).CornerRadius = UDim.new(0, 6)
        local ls = Instance.new("UIStroke", listHolder)
        ls.Color = C.accent
        ls.Thickness = 1
        ls.Transparency = 0.4

        local scroll = Instance.new("ScrollingFrame")
        scroll.Size = UDim2.new(1, -4, 1, -4)
        scroll.Position = UDim2.new(0, 2, 0, 2)
        scroll.BackgroundTransparency = 1
        scroll.BorderSizePixel = 0
        scroll.ScrollBarThickness = 2
        scroll.ScrollBarImageColor3 = C.accent
        scroll.CanvasSize = UDim2.new(0, 0, 0, #items * 22)
        scroll.ZIndex = 1000
        scroll.Parent = listHolder
        local ll = Instance.new("UIListLayout", scroll)
        ll.Padding = UDim.new(0, 1)

        for i, txt in ipairs(items) do
            local it = Instance.new("TextButton")
            it.Size = UDim2.new(1, 0, 0, 20)
            it.BackgroundColor3 = (i == currentIndex) and C.itemActive or Color3.fromRGB(34, 34, 44)
            it.BorderSizePixel = 0
            it.Text = "  " .. txt
            it.TextColor3 = C.text
            it.Font = FONT_BOLD
            it.TextSize = 11
            it.TextXAlignment = Enum.TextXAlignment.Left
            it.TextTruncate = Enum.TextTruncate.AtEnd
            it.ZIndex = 1001
            it.Parent = scroll
            Instance.new("UICorner", it).CornerRadius = UDim.new(0, 4)

            it.MouseButton1Click:Connect(function()
                currentIndex = i
                valueLabel.Text = txt
                if onChange then onChange(i, txt) end
                closeList()
            end)
            it.MouseEnter:Connect(function() it.BackgroundColor3 = C.itemHover end)
            it.MouseLeave:Connect(function()
                it.BackgroundColor3 = (i == currentIndex) and C.itemActive or Color3.fromRGB(34, 34, 44)
            end)
        end
    end)
    return card
end

local function makeSlider(parent, labelText, minVal, maxVal, defaultValue, onChange)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 52)
    card.BackgroundColor3 = C.content
    card.BorderSizePixel = 0
    card.Parent = parent
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 5)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -80, 0, 20)
    label.Position = UDim2.new(0, 12, 0, 2)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = C.text
    label.Font = FONT_BOLD
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = card

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 60, 0, 20)
    valueLabel.Position = UDim2.new(1, -70, 0, 2)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(defaultValue)
    valueLabel.TextColor3 = C.accent
    valueLabel.Font = FONT_BOLD
    valueLabel.TextSize = 12
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = card

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -24, 0, 8)
    track.Position = UDim2.new(0, 12, 0, 32)
    track.BackgroundColor3 = C.toggleOff
    track.BorderSizePixel = 0
    track.Parent = card
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = C.accent
    fill.BorderSizePixel = 0
    fill.Parent = track
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new(0, -7, 0.5, -7)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Parent = track
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local clickArea = Instance.new("TextButton")
    clickArea.Size = UDim2.new(1, 0, 1, 0)
    clickArea.BackgroundTransparency = 1
    clickArea.Text = ""
    clickArea.Parent = card

    local currentVal = defaultValue

    local function setValueFromX(x)
        local relX = x - track.AbsolutePosition.X
        local trackWidth = track.AbsoluteSize.X
        local alpha = math.clamp(relX / trackWidth, 0, 1)
        currentVal = math.floor(minVal + (maxVal - minVal) * alpha + 0.5)
        fill.Size = UDim2.new(alpha, 0, 1, 0)
        knob.Position = UDim2.new(alpha, -7, 0.5, -7)
        valueLabel.Text = tostring(currentVal)
        if onChange then onChange(currentVal) end
    end

    local initAlpha = (defaultValue - minVal) / (maxVal - minVal)
    fill.Size = UDim2.new(initAlpha, 0, 1, 0)
    knob.Position = UDim2.new(initAlpha, -7, 0.5, -7)

    local sDragging = false
    clickArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            sDragging = true
            setValueFromX(input.Position.X)
        end
    end)
    clickArea.InputChanged:Connect(function(input)
        if sDragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            setValueFromX(input.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            sDragging = false
        end
    end)
end

-- ============================================================
-- HOME
-- ============================================================
local pageHome = pages["Home"]
makeSection(pageHome, "Welcome")

local welcomeCard = Instance.new("Frame")
welcomeCard.Size = UDim2.new(1, 0, 0, 60)
welcomeCard.BackgroundColor3 = C.content
welcomeCard.BorderSizePixel = 0
welcomeCard.Parent = pageHome
Instance.new("UICorner", welcomeCard).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", welcomeCard).Color = C.border

local welcomeText = Instance.new("TextLabel")
welcomeText.Size = UDim2.new(1, -20, 1, 0)
welcomeText.Position = UDim2.new(0, 14, 0, 0)
welcomeText.BackgroundTransparency = 1
welcomeText.Text = "Opleoni Aura v1.5\nBoost Market Full Buff Names"
welcomeText.TextColor3 = C.textDim
welcomeText.Font = FONT_BOLD
welcomeText.TextSize = 11
welcomeText.TextXAlignment = Enum.TextXAlignment.Left
welcomeText.TextYAlignment = Enum.TextYAlignment.Top
welcomeText.Parent = welcomeCard

makeSection(pageHome, "Status")

local function makeStatusRow(parent, labelText)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 24)
    row.BackgroundColor3 = C.content
    row.BorderSizePixel = 0
    row.Parent = parent
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 5)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = C.textDim
    label.Font = FONT_BOLD
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row
    local val = Instance.new("TextLabel")
    val.Size = UDim2.new(0, 200, 1, 0)
    val.Position = UDim2.new(1, -210, 0, 0)
    val.BackgroundTransparency = 1
    val.Text = "-"
    val.TextColor3 = C.text
    val.Font = FONT_BOLD
    val.TextSize = 11
    val.TextXAlignment = Enum.TextXAlignment.Right
    val.TextTruncate = Enum.TextTruncate.AtEnd
    val.Parent = row
    return val
end

local statusField       = makeStatusRow(pageHome, "Selected Field")
local statusCurrent     = makeStatusRow(pageHome, "Current Field")
local statusAura        = makeStatusRow(pageHome, "Star Aura")
local statusDupeMode    = makeStatusRow(pageHome, "Dupe Mode")
local statusBoostField  = makeStatusRow(pageHome, "Boost Buff")
local statusTickets     = makeStatusRow(pageHome, "Tickets")
local statusFire        = makeStatusRow(pageHome, "Fires found")
local statusFlying      = makeStatusRow(pageHome, "Flying")

statusField.Text = selectedField.name
statusDupeMode.Text = DUPE_MODES[currentDupeMode]
statusBoostField.Text = selectedBoostField

task.spawn(function()
    while true do
        task.wait(0.5)
        local gummy = activeStars["Gummy Star Aura"]
        local pop   = activeStars["Pop Star Aura"]
        if gummy and pop then
            statusAura.Text = "Gummy + Pop"
            statusAura.TextColor3 = Color3.fromRGB(80, 220, 140)
        elseif gummy then
            statusAura.Text = "Gummy"
            statusAura.TextColor3 = Color3.fromRGB(160, 220, 80)
        elseif pop then
            statusAura.Text = "Pop"
            statusAura.TextColor3 = Color3.fromRGB(220, 160, 240)
        else
            statusAura.Text = "-"
            statusAura.TextColor3 = C.text
        end

        statusDupeMode.Text = DUPE_MODES[currentDupeMode]
        statusBoostField.Text = selectedBoostField
        statusFire.Text = tostring(#fireList)
        statusFlying.Text = flying and "Yes" or "No"
        statusFlying.TextColor3 = flying and Color3.fromRGB(120, 200, 255) or C.text

        local hrp = getChar()
        if hrp then
            local cur = getCurrentFieldName(hrp)
            statusCurrent.Text = cur or "None"
            statusCurrent.TextColor3 = cur and Color3.fromRGB(80, 220, 140) or Color3.fromRGB(220, 90, 110)
        end
        pcall(function()
            local stats = require(ReplicatedStorage.Client.Systems.ClientStatCache):Get()
            if stats and stats.Eggs then
                statusTickets.Text = tostring(stats.Eggs.Ticket or 0)
            end
        end)
    end
end)

-- ============================================================
-- FARMING
-- ============================================================
local pageFarm = pages["Farming"]
makeSection(pageFarm, "Field Selection")

local fieldNames = {}
for _, f in ipairs(FIELDS) do table.insert(fieldNames, f.name) end
table.insert(fieldNames, "Stump Field")

local defaultIdx = 1
for i, f in ipairs(FIELDS) do
    if f.name == selectedField.name then defaultIdx = i; break end
end

makeDropdown(pageFarm, "Field:", fieldNames, defaultIdx, function(idx, name)
    for _, f in ipairs(FIELDS) do
        if f.name == name then
            selectedField = f
            rebuildWaypoints()
            statusField.Text = f.name
            print("[Opleoni] Поле:", f.name)
            return
        end
    end
    if name == "Stump Field" then
        selectedField = STUMP_FIELD
        rebuildWaypoints()
        statusField.Text = STUMP_FIELD.name
        print("[Opleoni] Поле: Stump Field")
    end
end)

makeSection(pageFarm, "Farming")
makeToggle(pageFarm, "AutoFarm", "Auto Farm", Toggles)
makeToggle(pageFarm, "AutoSprinkler", "Auto Sprinkler (5x per field)", Toggles)
makeToggle(pageFarm, "AutoDig", "Auto Dig", Toggles)
makeToggle(pageFarm, "SquareFarm", "Square Farm (Perimeter)", Toggles)
makeToggle(pageFarm, "AutoCollectTokens", "Auto Collect Tokens", Toggles)
makeToggle(pageFarm, "AutoDupeGlitchTokens", "Auto Dupe/Glitch Tokens", Toggles)
makeDropdown(pageFarm, "Dupe Mode:", DUPE_MODES, currentDupeMode, function(idx, name)
    currentDupeMode = idx
    print("[Opleoni] Dupe Mode:", name)
end)
makeToggle(pageFarm, "FaceOnFires", "Face on Fires", Toggles)

-- ============================================================
-- TOYS
-- ============================================================
local pageToys = pages["Toys"]
makeSection(pageToys, "Materials")
for _, mat in ipairs(MATERIALS) do
    makeToggle(pageToys, mat.name, "Auto Use: " .. mat.name, MaterialToggles)
end

makeSection(pageToys, "Sticker Stack & Market")
makeToggle(pageToys, "AutoStickerStack", "Sticker Stack (40 min)", Toggles)
makeToggle(pageToys, "AutoBoostMarket", "Boost Market (30 min)", Toggles)
makeDropdown(pageToys, "Boost Buff:", BOOST_FIELD_LIST, 1, function(idx, name)
    selectedBoostField = name
    print("[Opleoni] Boost Buff:", name)
end)

-- Заглушки
for _, name in ipairs({ "Combat", "Quests", "Planters", "RBC", "Webhook" }) do
    makeSection(pages[name], name)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 50)
    card.BackgroundColor3 = C.content
    card.BorderSizePixel = 0
    card.Parent = pages[name]
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 6)
    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, -20, 1, 0)
    t.Position = UDim2.new(0, 14, 0, 0)
    t.BackgroundTransparency = 1
    t.Text = name .. " features coming soon..."
    t.TextColor3 = C.textDim
    t.Font = FONT_BOLD
    t.TextSize = 11
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.Parent = card
end

-- ============================================================
-- SETTINGS
-- ============================================================
local pageSettings = pages["Settings"]

makeSection(pageSettings, "Movement")
makeSlider(pageSettings, "Fly Speed (Tween)", 3, 40, FLY_SPEED, function(val)
    FLY_SPEED = val
end)
makeSlider(pageSettings, "Walk Speed", 16, 120, WALK_SPEED, function(val)
    WALK_SPEED = val
    local _, hum = getChar()
    if hum then hum.WalkSpeed = val end
end)

makeSection(pageSettings, "Keybinds")
local kb = Instance.new("Frame")
kb.Size = UDim2.new(1, 0, 0, 40)
kb.BackgroundColor3 = C.content
kb.BorderSizePixel = 0
kb.Parent = pageSettings
Instance.new("UICorner", kb).CornerRadius = UDim.new(0, 6)
local kbt = Instance.new("TextLabel")
kbt.Size = UDim2.new(1, -20, 1, 0)
kbt.Position = UDim2.new(0, 14, 0, 0)
kbt.BackgroundTransparency = 1
kbt.Text = "RightShift - open/close menu"
kbt.TextColor3 = C.text
kbt.Font = FONT_BOLD
kbt.TextSize = 11
kbt.TextXAlignment = Enum.TextXAlignment.Left
kbt.Parent = kb

setPage("Farming")

-- DRAG
local dragging, dragInput, dragStart, startPos
logoFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
logoFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local d = input.Position - dragStart
        main.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + d.X,
            startPos.Y.Scale, startPos.Y.Offset + d.Y)
        shadow.Position = UDim2.new(
            main.Position.X.Scale, main.Position.X.Offset - 8,
            main.Position.Y.Scale, main.Position.Y.Offset - 8)
    end
end)

-- REOPEN
local reopenBtn = Instance.new("TextButton")
reopenBtn.Size = UDim2.new(0, 44, 0, 44)
reopenBtn.Position = UDim2.new(0, 20, 0.5, -22)
reopenBtn.BackgroundColor3 = C.accent
reopenBtn.BorderSizePixel = 0
reopenBtn.Text = "O"
reopenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
reopenBtn.Font = FONT_BOLD
reopenBtn.TextSize = 20
reopenBtn.Visible = false
reopenBtn.Parent = screenGui
reopenBtn.ZIndex = 100
Instance.new("UICorner", reopenBtn).CornerRadius = UDim.new(1, 0)
local rs = Instance.new("UIStroke", reopenBtn)
rs.Color = Color3.fromRGB(160, 150, 255)
rs.Thickness = 2
rs.Transparency = 0.3

local function hideMenu() main.Visible = false; shadow.Visible = false; reopenBtn.Visible = true end
local function showMenu() main.Visible = true; shadow.Visible = true; reopenBtn.Visible = false end

reopenBtn.MouseButton1Click:Connect(showMenu)
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        if main.Visible then hideMenu() else showMenu() end
    end
end)

-- ============================================================
-- ТОКЕНЫ
-- ============================================================
local function findNearestToken()
    if not Toggles.AutoCollectTokens then return nil end
    local hrp = getChar(); if not hrp then return nil end
    local coll = Workspace:FindFirstChild("Collectibles"); if not coll then return nil end
    local best, bestD = nil, TOKEN_RADIUS
    for _, t in ipairs(coll:GetChildren()) do
        if t:IsA("BasePart") then
            local d = (t.Position - hrp.Position).Magnitude
            if d < bestD then best, bestD = t, d end
        end
    end
    return best
end

local function collectToken(token)
    local hrp, hum = getChar()
    if not hrp or not hum or not token then return end
    local startT = tick()
    while tick() - startT < 2 do
        if not token.Parent then return end
        local _, newHum = getChar()
        if not newHum then return end
        hrp = getChar()
        local pos = token.Position
        local d = (hrp.Position - pos).Magnitude
        if d < 6 then return end
        newHum:MoveTo(Vector3.new(pos.X, hrp.Position.Y, pos.Z))
        task.wait(0.03)
    end
end

local lastDupeCollect = 0
local function findNearestDupeToken()
    if not Toggles.AutoDupeGlitchTokens then return nil end
    if not isDupeAllowed() then return nil end
    if (tick() - lastDupeCollect) < DUPE_COOLDOWN then return nil end
    local hrp = getChar(); if not hrp then return nil end
    local cam = Workspace.CurrentCamera; if not cam then return nil end
    local duped = cam:FindFirstChild("DupedTokens"); if not duped then return nil end
    local best, bestD = nil, DUPE_RADIUS
    for _, t in ipairs(duped:GetChildren()) do
        if t:IsA("BasePart") then
            local a = Vector3.new(t.Position.X, 0, t.Position.Z)
            local b = Vector3.new(hrp.Position.X, 0, hrp.Position.Z)
            local d = (a - b).Magnitude
            if d < bestD then best, bestD = t, d end
        end
    end
    return best
end

local function walkTo(pos, timeout)
    local hrp, hum = getChar()
    if not hrp or not hum then return false end
    local startT, lastMove = tick(), 0
    while tick() - startT < (timeout or 8) do
        if tick() - lastMove > MOVETO_REFRESH then
            hum:MoveTo(pos); lastMove = tick()
        end
        task.wait(0.08)
        local newHrp = getChar()
        if not newHrp then return false end
        if (newHrp.Position - pos).Magnitude < 5 then return true end
        if Toggles.AutoDig and Events then fireEvent("ToolCollect") end
    end
    return false
end

-- ============================================================
-- МАТЕРИАЛЫ
-- ============================================================
local materialCache = {}
local function getMaterialInfo(t)
    if materialCache[t] ~= nil then return materialCache[t] end
    if not eggTypes then materialCache[t] = false; return false end
    local item = eggTypes.Get(t)
    materialCache[t] = item or false
    return item or false
end
local function canUseMaterial(t)
    local item = getMaterialInfo(t); if not item then return false end
    local pa = item.PlayerActive
    if pa and pa.CanActivate then
        local ok, c = pcall(function() return pa:CanActivate() end)
        if ok and c == false then return false end
    end
    return true
end
local materialInFlight = {}
local function useMaterialAsync(t, count, delay)
    task.spawn(function()
        for i = 1, (count or 1) do
            pcall(function()
                Events.ClientCall("ItemPackageEvent", "Take", {
                    Category = "Eggs", Type = t, Amount = 1 })
            end)
            if delay and delay > 0 and i < count then task.wait(delay) end
        end
    end)
end

local materialTimers = {}
for _, mat in ipairs(MATERIALS) do materialTimers[mat.name] = 0 end
local function materialsLoop()
    while true do
        task.wait(0.5)
        local now = tick()
        for _, mat in ipairs(MATERIALS) do
            if MaterialToggles[mat.name]
                and not materialInFlight[mat.name]
                and now - materialTimers[mat.name] >= mat.interval
                and canUseMaterial(mat.type) then
                materialTimers[mat.name] = now
                materialInFlight[mat.name] = true
                task.spawn(function()
                    useMaterialAsync(mat.type, mat.count, mat.delay)
                    task.wait(0.2)
                    materialInFlight[mat.name] = false
                end)
            end
        end
    end
end

-- ============================================================
-- STICKER STACK
-- ============================================================
local stickerMods = nil
local function loadStickerMods()
    if stickerMods then return stickerMods end
    local ok, res = pcall(function()
        return {
            Stack   = require(ReplicatedStorage.Game.Cosmetics.StickerStack),
            Machine = require(ReplicatedStorage.Game.Cosmetics.StickerStack.StickerStackMachine),
            Cache   = require(ReplicatedStorage.Client.Systems.ClientStatCache),
        }
    end)
    if ok and res then
        stickerMods = res
        pcall(function() res.Machine.InitListeners() end)
    end
    return stickerMods
end

local function tryActivateStickerStack()
    local mods = loadStickerMods(); if not mods then return false end
    local okC, cache = pcall(function() return mods.Cache:Get() end)
    if not okC or not cache then return false end
    local tickets = tonumber(cache.Eggs and cache.Eggs.Ticket) or 0
    local offCd, anim = true, false
    pcall(function() offCd = mods.Stack.IsOffCooldown(cache) end)
    pcall(function() anim = mods.Machine.IsAnimating() end)
    if not offCd or anim or tickets < STICKER_STACK_TICKET_COST then return false end
    print("[SS] StickerStackActivate")
    fireEvent("StickerStackActivate", "Tickets")
    return true
end

local lastStickerTry, stickerWasOn = 0, false
local function stickerStackLoop()
    while true do
        task.wait(1)
        local now = tick()
        if Toggles.AutoStickerStack then
            if not stickerWasOn then
                lastStickerTry = now - STICKER_STACK_INTERVAL
                stickerWasOn = true
            end
            if now - lastStickerTry >= STICKER_STACK_INTERVAL then
                lastStickerTry = now
                pcall(tryActivateStickerStack)
            end
        else stickerWasOn = false end
    end
end

-- ============================================================
-- BOOST MARKET
-- ============================================================
local function requestSummary(name, timeout)
    boostSummary, boostPending, boostPendingName = nil, true, name
    fireEvent("BoostMarketEvent", { Action = "FetchSummary", MarketName = name })
    local waited = 0
    timeout = timeout or 3
    while boostPending and waited < timeout do
        task.wait(0.1); waited = waited + 0.1
    end
    boostPending = false
    return boostSummary
end

local function getBoostMarketCooldown()
    local ok, remain = pcall(function()
        local statTools = require(ReplicatedStorage.Shared.Core.StatTools)
        local cst = require(ReplicatedStorage.Client.Systems.ClientStatCache):Get()
        local key = "BMBuy" .. BOOST_MARKET_NAME
        local lastBuy = statTools.GetLastCooldownTime(cst, key) or 0
        local osTime = require(ReplicatedStorage.Shared.Core.OsTime)
        return 1800 - (osTime() - lastBuy)
    end)
    if ok and type(remain) == "number" then return remain end
    return 0
end

local function forceOpenBoostMarket()
    local bmGui
    local ok = pcall(function()
        bmGui = require(ReplicatedStorage.Client.Gui.Gui.BoostMarketGui)
    end)
    if not ok or not bmGui then return nil, nil end

    local origIsOpen = bmGui.IsOpen
    bmGui.IsOpen = function() return true end

    pcall(function()
        if bmGui.OpenMarket then
            bmGui.OpenMarket(BOOST_MARKET_NAME)
        end
    end)
    return bmGui, origIsOpen
end

local function releaseBoostMarket(bmGui, origIsOpen)
    task.delay(3, function()
        if bmGui then
            if origIsOpen then bmGui.IsOpen = origIsOpen end
            pcall(function()
                if bmGui.Close then bmGui.Close() end
            end)
        end
    end)
end

local function tryBuyBoostMarket()
    local stats
    pcall(function() stats = require(ReplicatedStorage.Client.Systems.ClientStatCache):Get() end)
    if not stats then print("[BM] no stats"); return false end

    local tickets = tonumber(stats.Eggs and stats.Eggs.Ticket) or 0
    print("[BM] tickets =", tickets)
    if tickets < BOOST_MARKET_TICKET then
        print("[BM] skip: not enough tickets")
        return false
    end

    local cd = getBoostMarketCooldown()
    if cd > 0 then
        print("[BM] skip: cooldown " .. math.floor(cd) .. "s")
        return false
    end

    local summary = requestSummary(BOOST_MARKET_NAME, 4)
    if not summary then
        print("[BM] no summary for", BOOST_MARKET_NAME)
        return false
    end

    local boosts = summary.Boosts or {}
    print("[BM] market '" .. BOOST_MARKET_NAME .. "' has " .. #boosts .. " boosts")
    for _, b in ipairs(boosts) do
        print("[BM]   - " .. tostring(b.Buff)
            .. "  tickets=" .. tostring(b.TicketCost)
            .. "  honey=" .. tostring(b.Cost))
    end
    if #boosts == 0 then print("[BM] empty market"); return false end

    local targetBuff = getBoostBuffName()
    local target = nil
    for _, b in ipairs(boosts) do
        if b.Buff == targetBuff then target = b; break end
    end
    if not target then
        print("[BM] buff not found:", targetBuff)
        return false
    end

    local bmGui, origIsOpen = forceOpenBoostMarket()
    print("[BM] forceOpen:", bmGui ~= nil)
    task.wait(0.2)

    print("[BM] >> PurchaseBoost:", target.Buff)
    fireEvent("BoostMarketEvent", {
        Action = "PurchaseBoost",
        MarketName = BOOST_MARKET_NAME,
        Boost = target.Buff,
    })

    releaseBoostMarket(bmGui, origIsOpen)
    return true
end

local lastBoostTry, boostWasOn = 0, false
local function boostMarketLoop()
    while true do
        task.wait(1)
        local now = tick()
        if Toggles.AutoBoostMarket then
            if not boostWasOn then
                lastBoostTry = now - BOOST_MARKET_INTERVAL
                boostWasOn = true
            end
            if now - lastBoostTry >= BOOST_MARKET_INTERVAL then
                lastBoostTry = now
                pcall(tryBuyBoostMarket)
            end
        else boostWasOn = false end
    end
end

-- ============================================================
-- FACE ON FIRES
-- ============================================================
local function faceOnFiresLoop()
    while true do
        task.wait(0.05)
        if Toggles.FaceOnFires and #fireList > 0 and not flying then
            local hrp = getChar()
            if hrp then
                local fire = getNearestFire(hrp)
                if fire then
                    local targetPos = fire.Position
                    if FIRE_ROTATE_BODY then
                        local flatTarget = Vector3.new(targetPos.X, hrp.Position.Y, targetPos.Z)
                        pcall(function() hrp.CFrame = CFrame.lookAt(hrp.Position, flatTarget) end)
                    end
                    if FIRE_ROTATE_CAMERA then
                        local cam = Workspace.CurrentCamera
                        if cam then
                            local look = CFrame.lookAt(cam.CFrame.Position, targetPos)
                            cam.CFrame = cam.CFrame:Lerp(look, FIRE_LOOK_SMOOTH)
                        end
                    end
                end
            end
        end
    end
end

-- ============================================================
-- SPRINKLER
-- ============================================================
local sprinklerBusy = false

local function useSprinklerOnce()
    pcall(function()
        Events.ClientCall("ItemPackageEvent", "Take", {
            Category = "Eggs",
            Type = SPRINKLER_TYPE,
            Amount = 1,
        })
    end)
end

local function useSprinkler5x()
    if sprinklerBusy then return end
    sprinklerBusy = true
    task.spawn(function()
        for i = 1, SPRINKLER_USES do
            useSprinklerOnce()
            print("[Opleoni] Sprinkler (" .. i .. "/" .. SPRINKLER_USES .. ")")
            task.wait(SPRINKLER_DELAY)
        end
        sprinklerBusy = false
    end)
end

-- ============================================================
-- AUTO DIG
-- ============================================================
local lastDig = 0
local function autoDig()
    if not Toggles.AutoDig or not Events then return end
    if tick() - lastDig < DIG_INTERVAL then return end
    lastDig = tick()
    fireEvent("ToolCollect")
end

-- ============================================================
-- MAIN LOOP
-- ============================================================
local wasAutoFarmOn = false
local lastSprinklerField = nil

local function mainLoop()
    while true do
        local hrp, hum = getChar()
        if not hrp then
            task.wait(0.5)
        else
            if hum.WalkSpeed ~= WALK_SPEED then
                hum.WalkSpeed = WALK_SPEED
            end

            autoDig()

            if Toggles.AutoSprinkler then
                local curField = getCurrentFieldName(hrp)
                if curField and curField ~= lastSprinklerField then
                    lastSprinklerField = curField
                    print("[Opleoni] Sprinkler on field:", curField)
                    useSprinkler5x()
                end
            else
                lastSprinklerField = nil
            end

            local dupe = findNearestDupeToken()
            if dupe then
                lastDupeCollect = tick()
                local target = Vector3.new(dupe.Position.X, hrp.Position.Y, dupe.Position.Z)
                if (hrp.Position - target).Magnitude > 6 then
                    walkTo(target, 12)
                end
                local t0 = tick()
                while tick() - t0 < DUPE_WAIT do
                    autoDig()
                    task.wait(0.1)
                end
            else
                local token = findNearestToken()
                if token then
                    collectToken(token)
                elseif Toggles.AutoFarm then
                    local f = selectedField

                    if not wasAutoFarmOn and AUTOFARM_FLY_ON_START then
                        local land = fieldLandPos(f)
                        if (hrp.Position - land).Magnitude > 30 then
                            print("[Opleoni] Fly to field:", f.name)
                            flyTo(land)
                        end
                    end
                    wasAutoFarmOn = true

                    if not isInsideField(hrp, f) then
                        print("[Opleoni] Out of field -> fly to center")
                        flyTo(fieldLandPos(f))
                    else
                        local wps = Toggles.SquareFarm and squareWaypoints or fieldWaypoints
                        local wp = wps[currentWaypoint]
                        if wp then
                            local reachDist = Toggles.SquareFarm and 5 or 8
                            if (hrp.Position - wp).Magnitude < reachDist then
                                currentWaypoint = currentWaypoint % #wps + 1
                                wp = wps[currentWaypoint]
                            end
                            hum:MoveTo(wp)
                        end
                    end
                else
                    wasAutoFarmOn = false
                end
            end
            task.wait(0.03)
        end
    end
end

-- ============================================================
-- DEBUG
-- ============================================================
_G.OpleoniAura = Toggles
_G.TestSticker = function() pcall(tryActivateStickerStack) end
_G.TestBoostMarket = function() pcall(tryBuyBoostMarket) end
_G.TestFly = function()
    local f = selectedField
    flyTo(fieldLandPos(f))
end
_G.TestSprinkler = function()
    print("[Opleoni] Test sprinkler")
    useSprinkler5x()
end
_G.SetFlySpeed = function(v) FLY_SPEED = v end
_G.SetWalkSpeed = function(v)
    WALK_SPEED = v
    local _, hum = getChar()
    if hum then hum.WalkSpeed = v end
end
_G.GetStarStatus = function()
    return {
        Gummy = activeStars["Gummy Star Aura"],
        Pop = activeStars["Pop Star Aura"],
        Mode = DUPE_MODES[currentDupeMode],
        Allowed = isDupeAllowed(),
    }
end
_G.SetDupeMode = function(idx)
    if idx >= 1 and idx <= #DUPE_MODES then
        currentDupeMode = idx
        print("[Opleoni] Dupe Mode:", DUPE_MODES[idx])
    end
end
_G.SetBoostField = function(name)
    selectedBoostField = name
    print("[BM] Boost Buff:", name)
end
_G.ListBoostFields = function()
    for i, n in ipairs(BOOST_FIELD_LIST) do print(i .. ".", n) end
end

print("[Opleoni Aura] v1.5 loaded!")

task.spawn(mainLoop)
task.spawn(materialsLoop)
task.spawn(stickerStackLoop)
task.spawn(boostMarketLoop)
task.spawn(faceOnFiresLoop)
