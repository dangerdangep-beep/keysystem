--[[
    ================================================================
    [ SCRIPT INFORMATION ]
    Project: Custom Script
    Author: OYB
    YouTube: https://www.youtube.com/channel/UCAlXXV1Hbvf7WbfXARuVtiQ
    
    [ TERMS AND CONDITIONS ]
    - You ARE allowed to use and modify this script for your own games.
    - You ARE NOT allowed to re-upload, redistribute, or claim 
      ownership of this script.
    - Removing or altering these credits is strictly prohibited.
    
    Copyright (c) 2026 OYB. All rights reserved.
    ================================================================
]]

-- ⚠️ IMPORTANT: Put this code at the VERY TOP of your Main Script (before obfuscating) ⚠️

local ProtectionConfig = {
    -- 🔴 CRITICAL: This MUST exactly match the 'Secret' value in your Key System's Config!
    -- If your Key System has: Secret = "Test"
    -- Then this must also be: SecretKey = "Test"
    SecretKey = "sdflkjfdslks@!#dlfjouqljsxnmcbxvx983274$#@dsflksjdf",
    
    -- The name of your Hub (shown in the kick message if they try to bypass)
    HubName = "OpleoniHub"
}

-- Anti-Bypass Logic: Checks if the Key System successfully set the global variable
if not _G[ProtectionConfig.SecretKey] then
    local player = game:GetService("Players").LocalPlayer
    if player then
        player:Kick("\n🛡️ Unauthorized Execution 🛡️\n\nPlease use the official Key System to run " .. ProtectionConfig.HubName)
    end
    return -- Stops the rest of the script from loading!
end

-------------------------------------------------------------------------------
-- 👇 YOUR MAIN SCRIPT CODE STARTS HERE 👇
-------------------------------------------------------------------------------

print(ProtectionConfig.HubName .. " Loaded Successfully!")
--[[
    Auto Farm Menu — Stump Field + Materials + Sticker Stack + Boost Market
]]

-- [[ GUI ]] --
local TOGGLE_SIZE     = UDim2.new(0, 44, 0, 22)
local TOGGLE_ON_COLOR = Color3.fromRGB(80, 200, 120)
local TOGGLE_OFF_COLOR= Color3.fromRGB(60, 60, 60)
local KNOB_ON_POS     = UDim2.new(0, 24, 0, 2)
local KNOB_OFF_POS    = UDim2.new(0, 2, 0, 2)
local FRAME_COLOR     = Color3.fromRGB(25, 25, 30)
local TEXT_COLOR      = Color3.fromRGB(240, 240, 245)
local HEADER_COLOR    = Color3.fromRGB(35, 35, 45)
local ANIM_TIME       = 0.15

-- [[ АВТОФАРМ ]] --
local DIG_INTERVAL      = 0.15
local STUMP_CENTER      = Vector3.new(-124.678, 157.219, 2590.366)
local STUMP_HALF_X      = 35
local STUMP_HALF_Z      = 40
local STUMP_Y           = 157.219
local STUMP_Z_STEP      = 12
local STUMP_FAR_DIST    = 120
local MOVETO_REFRESH    = 0.4
local TOKEN_RADIUS      = 80
local DUPE_RADIUS       = 200
local DUPE_WAIT         = 2.5
local DUPE_COOLDOWN     = 10

-- [[ МАТЕРИАЛЫ ]] --
local MATERIALS = {
    { name = "Festive Bean",    type = "FestiveBean",    interval = 180,  count = 1, delay = 0 },
    { name = "Marshmallow Bee", type = "MarshmallowBee", interval = 1860, count = 1, delay = 0 },
    { name = "Super Smoothie",  type = "SuperSmoothie",  interval = 1740, count = 1, delay = 0 },
    { name = "Cloud Vial",      type = "CloudVial",      interval = 2,    count = 1, delay = 2.0 },
}

-- [[ STICKER STACK ]] --
local STICKER_STACK_TICKET_COST = 25
local STICKER_STACK_INTERVAL    = 40 * 60

-- [[ BOOST MARKET ]] --
local BOOST_MARKET_NAME     = "Boost Market"              -- ← обнаружено автоматически
local BOOST_MARKET_BUFF     = "Stump Field Market Boost"  -- ← точное имя буста из GUI
local BOOST_MARKET_INTERVAL = 35 * 60
local BOOST_MARKET_TICKET   = 50
local DEBUG_BM              = true

local Toggles = {
    AutoDig = false,
    AutoFarmStump = false,
    AutoCollectTokens = false,
    AutoDupeGlitchTokens = false,
    AutoStickerStack = false,
    AutoBoostMarket = false,
}

local MaterialToggles = {}
for _, mat in ipairs(MATERIALS) do MaterialToggles[mat.name] = false end

-- [[ СЕРВИСЫ ]] --
local Players           = game:GetService("Players")
local TweenService      = game:GetService("TweenService")
local Workspace         = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService  = game:GetService("UserInputService")

local player = Players.LocalPlayer

local Events
pcall(function()
    Events = require(ReplicatedStorage.Shared.Network.Events)
end)

local eggTypes
pcall(function()
    eggTypes = require(ReplicatedStorage.Game.ItemsAndEconomy.EggTypes)
end)

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

-- [[ BOOST MARKET — состояние ]] --
local boostSummary     = nil
local boostPending     = false
local boostPendingName = nil

local function handleBMResponse(payload)
    if type(payload) ~= "table" then return end
    if DEBUG_BM then print("[BM] in:", payload.Action, payload.MarketName) end

    if payload.Action == "UpdateSummary" then
        if payload.MarketName == boostPendingName then
            boostSummary = payload.Summary
            boostPending = false
        end
    elseif payload.Action == "RegisterPurchase" then
        print("[BM] >> покупка OK:", tostring(payload.MarketName))
    end
end

-- [[ ПЕРЕХВАТ Events.ClientListen (не ломая игру) ]] --
if Events and not Events._AutoFarmHooked then
    Events._AutoFarmHooked = true
    local originalListen = Events.ClientListen
    Events.ClientListen = function(name, callback, ...)
        if name == "BoostMarketEvent" and type(callback) == "function" then
            local wrapped = function(payload)
                pcall(handleBMResponse, payload)
                return callback(payload)
            end
            return originalListen(name, wrapped, ...)
        end
        return originalListen(name, callback, ...)
    end
    print("[AutoFarm] ClientListen hook установлен")
end

-- [[ GUMMY STAR ]] --
local GummyStarActive = false
local buffEvent = EventsFolder:FindFirstChild("ServerBuffEvent")
local fxEvent   = EventsFolder:FindFirstChild("LocalFX")

if buffEvent and buffEvent:IsA("RemoteEvent") then
    buffEvent.OnClientEvent:Connect(function(...)
        local args = decodeArgs(...)
        if args[2] == "Gummy Star Aura" then
            local a = args[1]
            if a == "Apply" or a == "ChangeCombo" or a == "ChangeStartTime" then
                GummyStarActive = true
            elseif a == "Remove" then GummyStarActive = false end
        end
    end)
end

if fxEvent and fxEvent:IsA("RemoteEvent") then
    fxEvent.OnClientEvent:Connect(function(...)
        local args = decodeArgs(...)
        local efName, payload = args[1], args[2]
        local function h(n, p)
            if n ~= "GummyStar" or type(p) ~= "table" then return end
            if p.Action == "Make" then GummyStarActive = true
            elseif p.Action == "Destroy" then GummyStarActive = false end
        end
        if efName == "__Batch" and type(payload) == "table" then
            for _, e in ipairs(payload) do
                if type(e) == "table" then h(e[1], e[2]) end
            end
        else h(efName, payload) end
    end)
end

local function isGummyStarActive() return GummyStarActive end

-- [[ ХЕЛПЕРЫ ]] --
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

-- [[ GUI ]] --
local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoFarmMenu"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 260, 0, 385)
mainFrame.Position = UDim2.new(0, 40, 0, 150)
mainFrame.BackgroundColor3 = FRAME_COLOR
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

local frameStroke = Instance.new("UIStroke")
frameStroke.Color = Color3.fromRGB(60, 60, 70)
frameStroke.Thickness = 1.5
frameStroke.Parent = mainFrame

local header = Instance.new("TextLabel")
header.Size = UDim2.new(1, 0, 0, 38)
header.BackgroundColor3 = HEADER_COLOR
header.BorderSizePixel = 0
header.Text = "Auto Farm Menu"
header.TextColor3 = TEXT_COLOR
header.Font = Enum.Font.GothamBold
header.TextSize = 15
header.Parent = mainFrame
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 10)

local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, -16, 0, 28)
tabBar.Position = UDim2.new(0, 8, 0, 44)
tabBar.BackgroundTransparency = 1
tabBar.Parent = mainFrame
local tl = Instance.new("UIListLayout", tabBar)
tl.FillDirection = Enum.FillDirection.Horizontal
tl.Padding = UDim.new(0, 6)

local page1 = Instance.new("Frame")
page1.Size = UDim2.new(1, -16, 1, -120)
page1.Position = UDim2.new(0, 8, 0, 78)
page1.BackgroundTransparency = 1
page1.Visible = true
page1.Parent = mainFrame
local p1l = Instance.new("UIListLayout", page1)
p1l.Padding = UDim.new(0, 6)

local page2 = Instance.new("Frame")
page2.Size = UDim2.new(1, -16, 1, -120)
page2.Position = UDim2.new(0, 8, 0, 78)
page2.BackgroundTransparency = 1
page2.Visible = false
page2.Parent = mainFrame
local p2l = Instance.new("UIListLayout", page2)
p2l.Padding = UDim.new(0, 6)

local function createToggle(name, labelText, parent, toggleTable)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 30)
    row.BackgroundTransparency = 1
    row.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -55, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = TEXT_COLOR
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row

    local toggleBg = Instance.new("Frame")
    toggleBg.Size = TOGGLE_SIZE
    toggleBg.Position = UDim2.new(1, -48, 0.5, -11)
    toggleBg.BackgroundColor3 = TOGGLE_OFF_COLOR
    toggleBg.BorderSizePixel = 0
    toggleBg.Parent = row
    Instance.new("UICorner", toggleBg).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = KNOB_OFF_POS
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Parent = toggleBg
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local clickArea = Instance.new("TextButton")
    clickArea.Size = UDim2.new(1, 0, 1, 0)
    clickArea.BackgroundTransparency = 1
    clickArea.Text = ""
    clickArea.Parent = row

    local isOn = false
    clickArea.MouseButton1Click:Connect(function()
        isOn = not isOn
        toggleTable[name] = isOn
        TweenService:Create(toggleBg, TweenInfo.new(ANIM_TIME), {
            BackgroundColor3 = isOn and TOGGLE_ON_COLOR or TOGGLE_OFF_COLOR }):Play()
        TweenService:Create(knob, TweenInfo.new(ANIM_TIME), {
            Position = isOn and KNOB_ON_POS or KNOB_OFF_POS }):Play()
    end)
end

local function createTab(text, targetPage)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 110, 1, 0)
    btn.BackgroundColor3 = HEADER_COLOR
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = TEXT_COLOR
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 13
    btn.Parent = tabBar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(function()
        page1.Visible = (targetPage == page1)
        page2.Visible = (targetPage == page2)
    end)
end

createTab("Farm", page1)
createTab("Materials", page2)

createToggle("AutoDig",              "Auto Dig",                    page1, Toggles)
createToggle("AutoFarmStump",        "Auto Farm Stump",             page1, Toggles)
createToggle("AutoCollectTokens",    "Auto Collect Tokens",         page1, Toggles)
createToggle("AutoDupeGlitchTokens", "Auto Dupe/Glitch Tokens",     page1, Toggles)
createToggle("AutoStickerStack",     "Auto Sticker Stack (40 min)", page1, Toggles)
createToggle("AutoBoostMarket",      "Auto Boost Market (35 min)",  page1, Toggles)

for _, mat in ipairs(MATERIALS) do
    createToggle(mat.name, "Auto Use: " .. mat.name, page2, MaterialToggles)
end

-- [[ DRAG ]] --
local dragging, dragInput, dragStart, startPos
header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local d = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + d.X,
            startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)

-- [[ WAYPOINTS ]] --
local STUMP_WAYPOINTS = {}
do
    local xMin, xMax = STUMP_CENTER.X - STUMP_HALF_X, STUMP_CENTER.X + STUMP_HALF_X
    local zMin, zMax = STUMP_CENTER.Z - STUMP_HALF_Z, STUMP_CENTER.Z + STUMP_HALF_Z
    local row, z = 0, zMin
    while z <= zMax do
        if row % 2 == 0 then
            table.insert(STUMP_WAYPOINTS, Vector3.new(xMin, STUMP_Y, z))
            table.insert(STUMP_WAYPOINTS, Vector3.new(xMax, STUMP_Y, z))
        else
            table.insert(STUMP_WAYPOINTS, Vector3.new(xMax, STUMP_Y, z))
            table.insert(STUMP_WAYPOINTS, Vector3.new(xMin, STUMP_Y, z))
        end
        row = row + 1
        z = z + STUMP_Z_STEP
    end
end
local currentWaypoint = 1

-- [[ ТОКЕНЫ ]] --
local function findNearestToken()
    if not Toggles.AutoCollectTokens then return nil end
    local hrp = getChar(); if not hrp then return nil end
    local coll = Workspace:FindFirstChild("Collectibles")
    if not coll then return nil end
    local best, bestD = nil, TOKEN_RADIUS
    for _, t in ipairs(coll:GetChildren()) do
        if t:IsA("BasePart") then
            local d = (t.Position - hrp.Position).Magnitude
            if d < bestD then best, bestD = t, d end
        end
    end
    return best
end

local lastDupeCollect = 0
local function dupeOnCooldown() return (tick() - lastDupeCollect) < DUPE_COOLDOWN end

local function findNearestDupeToken()
    if not Toggles.AutoDupeGlitchTokens then return nil end
    if not isGummyStarActive() then return nil end
    if dupeOnCooldown() then return nil end
    local hrp = getChar(); if not hrp then return nil end
    local cam = Workspace.CurrentCamera; if not cam then return nil end
    local duped = cam:FindFirstChild("DupedTokens")
    if not duped then return nil end
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

-- [[ МАТЕРИАЛЫ ]] --
local materialCache = {}
local function getMaterialInfo(t)
    if materialCache[t] ~= nil then return materialCache[t] end
    if not eggTypes then materialCache[t] = false; return false end
    local item = eggTypes.Get(t)
    materialCache[t] = item or false
    return item or false
end

local function canUseMaterial(t)
    local item = getMaterialInfo(t)
    if not item then return false end
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
    else warn("[SS] module load fail:", res) end
    return stickerMods
end

local function tryActivateStickerStack()
    local mods = loadStickerMods()
    if not mods then print("[SS] mods=nil"); return false end

    local okC, cache = pcall(function() return mods.Cache:Get() end)
    if not okC or not cache then print("[SS] cache fail:", cache); return false end

    local tickets = tonumber(cache.Eggs and cache.Eggs.Ticket) or 0
    local offCd, anim = true, false
    pcall(function() offCd = mods.Stack.IsOffCooldown(cache) end)
    pcall(function() anim = mods.Machine.IsAnimating() end)

    print("[SS] tickets=", tickets, "offCd=", offCd, "anim=", anim)

    if not offCd then print("[SS] skip: cooldown"); return false end
    if anim then print("[SS] skip: animating"); return false end
    if tickets < STICKER_STACK_TICKET_COST then
        print("[SS] skip: не хватает тикетов (" .. tickets .. "/" .. STICKER_STACK_TICKET_COST .. ")")
        return false
    end

    print("[SS] >> StickerStackActivate Tickets")
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
        else
            stickerWasOn = false
        end
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

local function tryBuyBoostMarket()
    local stats
    pcall(function() stats = require(ReplicatedStorage.Client.Systems.ClientStatCache):Get() end)
    if not stats then print("[BM] no stats"); return false end

    local tickets = tonumber(stats.Eggs and stats.Eggs.Ticket) or 0
    if DEBUG_BM then print("[BM] tickets=", tickets) end
    if tickets < BOOST_MARKET_TICKET then
        print("[BM] skip: мало тикетов"); return false
    end

    local summary = requestSummary(BOOST_MARKET_NAME, 3)
    if not summary then
        print("[BM] нет summary для '" .. BOOST_MARKET_NAME .. "'")
        return false
    end

    local boosts = summary.Boosts or {}
    if #boosts == 0 then print("[BM] бустов нет"); return false end

    local target = nil
    for _, b in ipairs(boosts) do
        if DEBUG_BM then print("[BM] offer:", b.Buff, "tickets:", b.TicketCost) end
        if b.Buff == BOOST_MARKET_BUFF then target = b; break end
    end

    if not target then
        print("[BM] буст '" .. BOOST_MARKET_BUFF .. "' не найден. Доступные:")
        for _, b in ipairs(boosts) do print("   -", b.Buff) end
        return false
    end

    print("[BM] >> покупка: " .. target.Buff)
    fireEvent("BoostMarketEvent", {
        Action = "PurchaseBoost",
        MarketName = BOOST_MARKET_NAME,
        Boost = target.Buff,
    })
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
        else
            boostWasOn = false
        end
    end
end

-- [[ АВТО-КОПАНИЕ ]] --
local lastDig = 0
local function autoDig()
    if not Toggles.AutoDig or not Events then return end
    if tick() - lastDig < DIG_INTERVAL then return end
    lastDig = tick()
    fireEvent("ToolCollect")
end

-- [[ ГЛАВНЫЙ ЦИКЛ ]] --
local function mainLoop()
    while true do
        local hrp, hum = getChar()
        if not hrp then task.wait(1)
        else
            autoDig()
            local dupe = findNearestDupeToken()
            if dupe then
                lastDupeCollect = tick()
                local target = Vector3.new(dupe.Position.X, hrp.Position.Y, dupe.Position.Z)
                walkTo(target, 12)
                local t0 = tick()
                while tick() - t0 < DUPE_WAIT do autoDig(); task.wait(0.1) end
            else
                local token = findNearestToken()
                if token then
                    local target = Vector3.new(token.Position.X, hrp.Position.Y, token.Position.Z)
                    walkTo(target, 5); task.wait(0.2)
                elseif Toggles.AutoFarmStump then
                    local dist = (hrp.Position - STUMP_CENTER).Magnitude
                    if dist > STUMP_FAR_DIST then walkTo(STUMP_CENTER, 25)
                    else
                        local wp = STUMP_WAYPOINTS[currentWaypoint]
                        if wp then
                            if (hrp.Position - wp).Magnitude < 6 then
                                currentWaypoint = currentWaypoint % #STUMP_WAYPOINTS + 1
                                wp = STUMP_WAYPOINTS[currentWaypoint]
                            end
                            hum:MoveTo(wp)
                        end
                    end
                end
            end
            task.wait(0.08)
        end
    end
end

-- [[ ОТЛАДКА ]] --
_G.AutoFarmToggles = Toggles
_G.TestSticker = function() pcall(tryActivateStickerStack) end
_G.TestBoostMarket = function() pcall(tryBuyBoostMarket) end

print("[AutoFarm] GUI загружено!")

task.spawn(mainLoop)
task.spawn(materialsLoop)
task.spawn(stickerStackLoop)
task.spawn(boostMarketLoop)
