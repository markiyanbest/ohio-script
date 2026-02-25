-- markiyanbest's script (V51 - MEGA UPGRADE)
-- +Item Picker (пошук/вибір предметів)
-- +Збереження налаштувань
-- +Auto-respawn farm continue
-- +Kill Aura
-- +High Jump (настроюваний)
-- +Фікс червоної кнопки
-- +Фікс усіх функцій

local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local RS = game:GetService("RunService")
local Light = game:GetService("Lighting")
local UIS = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local Camera = workspace.CurrentCamera
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local IsMobile = UIS.TouchEnabled
local IsPC = not IsMobile

-- ============================================================
-- CLEANUP OLD GUI
-- ============================================================
pcall(function()
    for _, sg in pairs({game:GetService("CoreGui"), lp:WaitForChild("PlayerGui")}) do
        for _, v in pairs(sg:GetChildren()) do
            if v:IsA("ScreenGui") and v.Name == "MarkiyanPro" then v:Destroy() end
        end
    end
end)

if IsMobile then
    pcall(function()
        settings().Rendering.QualityLevel = 1
        Light.GlobalShadows = false
        Light.FogEnd = 9e9
        Light.Brightness = 1
        Light.ClockTime = 14
    end)
    for _, v in pairs(Light:GetChildren()) do
        if v:IsA("BloomEffect") or v:IsA("BlurEffect")
            or v:IsA("SunRaysEffect") or v:IsA("DepthOfFieldEffect")
            or v:IsA("ColorCorrectionEffect") then
            pcall(function() v.Enabled = false end)
        end
    end
end

local function SafeFirePrompt(prompt)
    if fireproximityprompt then
        local ok = pcall(fireproximityprompt, prompt)
        if ok then return true end
    end
    local ok2 = pcall(function()
        prompt:InputHoldBegin()
        task.wait(0.05)
        prompt:InputHoldEnd()
    end)
    return ok2
end

local COORDS = {
    GUN_SHOP = Vector3.new(1131, 25, -1344),
    BANK_ENT = Vector3.new(1106, 8, -336),
    BANK_MONEY = Vector3.new(1110, 8, -325),
    SAFE_ZONE = Vector3.new(-37, -27, 3),
}

-- ============================================================
-- FULL ITEMS DATABASE
-- ============================================================
local ALL_ITEMS = {
    -- Зброя
    "Acid Gun","Admin AK-47","Admin Nuke","Admin RPG","AK-47","AR-15",
    "AS VAL","AUG","Barrett M107","Baseball Bat","Baton","Brass Knuckles",
    "C4","Clown Mallet","Crowbar","Deagle","Double barrel","Dragunov",
    "Fireaxe","Fire Extinguisher","Flamethrower","Frag grenade","Glock",
    "Glock 18","Gold AK-47","Gold Deagle","Gravity Gun","Heavy C4",
    "Katana","Knife","Landmines","M1 Garand","M1911","M249 SAW","M4A1",
    "Meat Grinder","Molotov","Money Gun","Mossberg","MP7","Pepper Spray",
    "Python","Raygun","Riot Shield","RPG","RPK","Saber","Saiga 12",
    "Sawn off","Smoke grenade","Flashbang","Spectral Scythe",
    "Spiked baseball bat","Stagecoach","Suitcase Nuke","USP 45","Uzi",
    "SPAS-12","Kunai","Nuke Launcher",
    -- Броня / Медицина
    "Bandage","Heavy Vest","Light vest","Medium Vest","Medkit",
    "Military Vest","Stretcher","Surgeon Mask","X-Ray Goggles",
    -- Принтери / Гроші
    "Money printer","Unusual Money Printer","ATM","Cash Register",
    "Safes","Wallet","Slot machine",
    -- Їжа / Напої / Баффи
    "Apple","Banana","Banana Peel","Beans","Bloxaide","Bloxy Cola",
    "Burger","Cake","Candy Cane","Chicken","Choco Bunny","Chocolates",
    "Coffee","Cookie","Cotton Candy","Diamond Taco","Donut","Hotdog",
    "Pizza","Rose",
    -- Дропи / Ящики / Утиліти
    "Airdrop Marker","Airstrike","Armored Truck","Component Boxes",
    "Crafting table","Drone","Easter Basket","Gems","Green Lucky Block",
    "Gold Lucky Block","Orange Lucky Block","Purple Lucky Block",
    "Red Lucky Block","Large Present","Small Present","Presents",
    "Locker","Lockpick",
    -- Транспорт / Аксесуари
    "Grocery Cart","Shopping Cart","Guitar","Festive Guitar",
    "Hoverboard","Skateboard","Sign","Stop Sign","Dumbell","Maraca",
    "Megaphone",
    -- Святкові
    "4th of July Hat","Balloon","Clover Balloon","Heart Balloon",
    "Firework","Firework Cake","Firework Cone","Firework Mortar",
    "Green Firework","July 4th Firework","Pink Firework","Roman Candle",
    "Sparkler","Sombrero Hat","Bear Trap","Basketball","Beach Ball",
    "Clown","Flashlight","Hockey Mask",
    -- Одяг
    "Black Bandana","Blue Bandana","Red Bandana","Blue Gloves","Red Gloves",
    -- Ключі (лімітед)
    "Keycard","Police Keycard","Military Keycard",
    "Blue Keycard","Red Keycard","Green Keycard",
    "Yellow Keycard","White Keycard","Black Keycard",
    -- Додаткові / Лімітед
    "Blue Candy Cane","Dollar Balloon","Golden Clover Balloon",
    "Night Vision Goggles","Mustang Keys","Helicopter Keys","Cruiser Keys",
    "Fists",
}

-- ============================================================
-- SAVE/LOAD SYSTEM
-- ============================================================
local SAVE_KEY = "MarkiyanProV51_Settings"

local function SaveSettings(config, itemPicker)
    pcall(function()
        local data = {
            config = {},
            itemPicker = {},
            binds = {},
        }
        -- Save config booleans and numbers
        for k, v in pairs(config) do
            if type(v) == "boolean" or type(v) == "number" or type(v) == "string" then
                data.config[k] = v
            end
        end
        -- Save item picker states
        for itemName, state in pairs(itemPicker) do
            data.itemPicker[itemName] = state
        end
        if writefile then
            writefile(SAVE_KEY .. ".json", HttpService:JSONEncode(data))
        end
    end)
end

local function LoadSettings()
    local data = nil
    pcall(function()
        if readfile and isfile and isfile(SAVE_KEY .. ".json") then
            data = HttpService:JSONDecode(readfile(SAVE_KEY .. ".json"))
        end
    end)
    return data
end

-- ============================================================
-- CONFIG
-- ============================================================
local Config = {
    Farm = false,
    Speed = false,
    Armor = false,
    Heal = false,
    AimActive = false,
    FPSBoost = false,
    AntiSeat = false,
    AntiAFK = false,
    Fly = false,
    FlySpeedValue = IsMobile and 35 or 50,
    WalkSpeedValue = IsMobile and 45 or 65,
    ESP = false,
    ItemESP = false,
    Fullbright = false,
    AutoEquip = false,
    InfJump = false,
    Noclip = false,
    Magnet = false,
    MagnetTarget = nil,
    AutoSafe = false,
    SafeHealth = 35,
    SilentAim = false,
    AimFOV = 200,
    AimSmooth = 0.18,
    AimPart = "Head",
    KillAura = false,
    KillAuraRange = 15,
    HighJump = false,
    JumpPowerValue = 50,
}

-- Item Picker: true = pick up, false = ignore
local ItemPickerState = {}
for _, item in pairs(ALL_ITEMS) do
    ItemPickerState[item] = true -- default: pick all
end

local Binds = {
    Fly = Enum.KeyCode.F,
    AimActive = Enum.KeyCode.G,
    Noclip = Enum.KeyCode.V,
    SilentAim = Enum.KeyCode.B,
    ToggleUI = Enum.KeyCode.M,
}

local BindNames = {
    Fly = "FLY",
    AimActive = "AIM LOCK",
    Noclip = "NOCLIP",
    SilentAim = "SILENT AIM",
    ToggleUI = "TOGGLE UI",
}

local waitingForBind = nil

-- Load saved settings
local savedData = LoadSettings()
if savedData then
    if savedData.config then
        for k, v in pairs(savedData.config) do
            if Config[k] ~= nil and type(Config[k]) == type(v) then
                Config[k] = v
            end
        end
    end
    if savedData.itemPicker then
        for itemName, state in pairs(savedData.itemPicker) do
            if ItemPickerState[itemName] ~= nil then
                ItemPickerState[itemName] = state
            end
        end
    end
    if savedData.binds then
        for k, v in pairs(savedData.binds) do
            if Binds[k] ~= nil then
                pcall(function() Binds[k] = Enum.KeyCode[v] end)
            end
        end
    end
end

-- Auto-save periodically
task.spawn(function()
    while task.wait(15) do
        SaveSettings(Config, ItemPickerState)
    end
end)

-- ============================================================
-- PRIORITY / LOOT / BLACKLIST (same as before, abbreviated)
-- ============================================================
local PriorityLoot = {
    ["money printer"]=true,["unusual money printer"]=true,["printer"]=true,
    ["keycard"]=true,["key card"]=true,["police keycard"]=true,
    ["military keycard"]=true,["lockpick"]=true,
    ["gold ak-47"]=true,["gold deagle"]=true,["admin ak-47"]=true,
    ["admin rpg"]=true,["admin nuke"]=true,["suitcase nuke"]=true,
    ["raygun"]=true,["barrett m107"]=true,["spectral scythe"]=true,
    ["diamond taco"]=true,["airdrop marker"]=true,
    ["red keycard"]=true,["blue keycard"]=true,["green keycard"]=true,
    ["yellow keycard"]=true,["white keycard"]=true,["black keycard"]=true,
}

local BlacklistCache = {
    ["spawn"]=true,["door"]=true,["gate"]=true,["barrier"]=true,
    ["edit"]=true,["open"]=true,["close"]=true,["vending"]=true,
    ["workbench"]=true,["press"]=true,["turn"]=true,
    ["ammo box"]=true,["ammobox"]=true,["ammo"]=true,
    ["unlock after"]=true,["cash earned"]=true,
    ["purchase"]=true,["buy"]=true,["sell"]=true,["shop"]=true,["store"]=true,
    ["premium"]=true,["vip"]=true,["robux"]=true,["locked"]=true,
    ["sit"]=true,["chair"]=true,["bench"]=true,["interact"]=true,
    ["enter"]=true,["exit"]=true,["drive"]=true,["vehicle"]=true,
    ["car"]=true,["ladder"]=true,["helicopter"]=true,
    ["garage"]=true,
}

local HardBlockPatterns = {
    "ammo%s+box","ammo%s+crate","unlock after","cash earned",
    "purchase","buy for","premium only","vip only","robux",
    "%d+m cash","%d+k cash","after %d","earn %d",
    "paintball","pickaxe",
}

-- ============================================================
-- UTILITIES
-- ============================================================
local function Notify(title, text, dur)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title, Text = text, Duration = dur or 2,
        })
    end)
end

local function GetChar() return lp.Character end
local function GetHum()
    local c = GetChar()
    return c and c:FindFirstChildOfClass("Humanoid")
end
local function GetRoot()
    local c = GetChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end
local function IsHumAlive()
    local h = GetHum()
    return h and h.Health > 0
end

local function SafeTeleport(pos)
    if not IsHumAlive() then return false end
    local root = GetRoot()
    if not root then return false end
    local char = GetChar()
    local ok = pcall(function()
        char:PivotTo(CFrame.new(pos + Vector3.new(0, 3, 0)))
    end)
    if not ok then
        pcall(function() root.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0)) end)
    end
    return true
end

local function IsTargetAlive(target)
    if not target or not target.Parent then return false end
    local char = target.Character
    if not char then return false end
    local h = char:FindFirstChildOfClass("Humanoid")
    return h and h.Health > 0
end

local function IsForceWhitelisted(text)
    -- Check if item is enabled in picker by checking if any ALL_ITEMS match exists
    for _, item in pairs(ALL_ITEMS) do
        local low = item:lower()
        if text:find(low, 1, true) and ItemPickerState[item] then
            return true
        end
    end
    return false
end

local function IsBlocked(text)
    if IsForceWhitelisted(text) then return false end
    for kw in pairs(BlacklistCache) do
        if text:find(kw, 1, true) then return true end
    end
    for _, pattern in pairs(HardBlockPatterns) do
        if text:find(pattern) then return true end
    end
    return false
end

local function IsItemEnabledInPicker(parentName)
    local pLow = parentName:lower()
    for _, item in pairs(ALL_ITEMS) do
        if pLow:find(item:lower(), 1, true) or item:lower():find(pLow, 1, true) then
            return ItemPickerState[item] ~= false
        end
    end
    return true -- unknown items default to enabled
end

local function IsPriority(text, parentName)
    local pLow = parentName:lower()
    if PriorityLoot[pLow] then return true end
    for kw in pairs(PriorityLoot) do
        if text:find(kw, 1, true) then return true end
    end
    return false
end

-- ============================================================
-- AIM SYSTEM
-- ============================================================
local aimRayParams = RaycastParams.new()
aimRayParams.FilterType = Enum.RaycastFilterType.Exclude

local function FindAimPart(char)
    if not char then return nil end
    local name = Config.AimPart or "Head"
    return char:FindFirstChild(name)
        or char:FindFirstChild("Head")
        or char:FindFirstChild("HumanoidRootPart")
end

local function IsVisible(char)
    if not char then return false end
    local myChar = lp.Character
    if not myChar then return false end
    local part = FindAimPart(char)
    if not part then return false end
    local origin = Camera.CFrame.Position
    local target = part.Position
    local dir = target - origin
    local dist = dir.Magnitude
    if dist < 1 then return true end
    aimRayParams.FilterDescendantsInstances = {myChar}
    local result = workspace:Raycast(origin, dir.Unit * (dist - 0.5), aimRayParams)
    if not result then return true end
    if result.Instance:IsDescendantOf(char) then return true end
    if result.Instance.Transparency >= 0.8 then return true end
    return false
end

local function ScreenDist(part)
    if not part then return math.huge end
    local pos, on = Camera:WorldToViewportPoint(part.Position)
    if not on then return math.huge end
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    return (Vector2.new(pos.X, pos.Y) - center).Magnitude
end

local aimTarget = nil
local aimLocked = false
local aimLastSwitch = 0
local aimSwitchCD = 0.35
local aimLostFrames = 0
local lastPing = 0
local pingTick = 0

local function FindNewAimTarget()
    local fov = Config.AimFOV
    local best, bestDist = nil, math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p == lp then continue end
        local char = p.Character
        if not char then continue end
        local h = char:FindFirstChildOfClass("Humanoid")
        if not h or h.Health <= 0 then continue end
        local part = FindAimPart(char)
        if not part then continue end
        local sd = ScreenDist(part)
        if sd > fov then continue end
        if not IsVisible(char) then continue end
        if sd < bestDist then bestDist = sd; best = p end
    end
    return best
end

local function GetBestAimTarget()
    local now = tick()
    local fov = Config.AimFOV
    if aimTarget and aimLocked then
        local char = aimTarget.Character
        if char then
            local h = char:FindFirstChildOfClass("Humanoid")
            if h and h.Health > 0 then
                local part = FindAimPart(char)
                if part then
                    local sd = ScreenDist(part)
                    local vis = IsVisible(char)
                    if sd <= fov * 1.8 and vis then
                        aimLostFrames = 0; return char
                    end
                    aimLostFrames += 1
                    if aimLostFrames < 12 then return char end
                end
            end
        end
        aimTarget = nil; aimLocked = false; aimLostFrames = 0
    end
    if now - aimLastSwitch < aimSwitchCD then return nil end
    local best = FindNewAimTarget()
    if best then
        aimTarget = best; aimLocked = true
        aimLostFrames = 0; aimLastSwitch = now
        return best.Character
    end
    return nil
end

local function GetClosestByDist()
    local root = GetRoot()
    if not root then return nil end
    local best, bestD = nil, math.huge
    for _, v in pairs(Players:GetPlayers()) do
        if v == lp then continue end
        if not IsTargetAlive(v) then continue end
        local hrp = v.Character and v.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local d = (hrp.Position - root.Position).Magnitude
            if d < bestD then bestD = d; best = v end
        end
    end
    return best
end

-- ============================================================
-- MOBILE CONTROLS
-- ============================================================
local Controls = nil
task.spawn(function()
    if not game:IsLoaded() then game.Loaded:Wait() end
    task.wait(1)
    pcall(function()
        Controls = require(
            lp:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule", 5)
        ):GetControls()
    end)
end)

local MobUp, MobDn = false, false

-- ============================================================
-- SILENT AIM
-- ============================================================
local lastSilentT = 0
local isTouching = false
UIS.TouchStarted:Connect(function() isTouching = true end)
UIS.TouchEnded:Connect(function() isTouching = false end)

local function DoSilentAim()
    if not Config.SilentAim then return end
    local now = tick()
    if now - lastSilentT < (IsMobile and 0.05 or 0.016) then return end
    lastSilentT = now
    local shooting = IsPC
        and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
        or isTouching
    if not shooting then return end
    local tgtChar = GetBestAimTarget()
    if not tgtChar then return end
    local head = FindAimPart(tgtChar)
    if not head then return end
    Camera.CFrame = Camera.CFrame:Lerp(
        CFrame.new(Camera.CFrame.Position, head.Position),
        IsMobile and 0.35 or 0.45)
end

-- ============================================================
-- KILL AURA
-- ============================================================
task.spawn(function()
    while task.wait(IsMobile and 0.3 or 0.15) do
        if not Config.KillAura then continue end
        if not IsHumAlive() then continue end
        local root = GetRoot()
        local char = GetChar()
        local hum = GetHum()
        if not root or not char or not hum then continue end

        -- Find equipped tool
        local tool = char:FindFirstChildOfClass("Tool")
        if not tool then continue end

        local range = Config.KillAuraRange or 15

        for _, p in pairs(Players:GetPlayers()) do
            if p == lp then continue end
            if not IsTargetAlive(p) then continue end
            local tChar = p.Character
            local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
            if not tRoot then continue end
            local dist = (tRoot.Position - root.Position).Magnitude
            if dist > range then continue end

            -- Face target and activate tool
            pcall(function()
                root.CFrame = CFrame.new(root.Position, tRoot.Position)
            end)
            pcall(function()
                tool:Activate()
            end)
            -- Try clicking remote events (for melee weapons)
            pcall(function()
                for _, v in pairs(tool:GetDescendants()) do
                    if v:IsA("RemoteEvent") then
                        v:FireServer(tChar, tRoot.Position)
                    end
                end
            end)
        end
    end
end)

-- ============================================================
-- FPS BOOST
-- ============================================================
local fpsApplied = false
local function ApplyFPS()
    if fpsApplied then Notify("FPS","Вже ✓",2); return end
    fpsApplied = true
    pcall(function()
        settings().Rendering.QualityLevel = 1
        Light.GlobalShadows = false
        Light.FogEnd = 9e9
    end)
    for _, v in pairs(Light:GetChildren()) do
        pcall(function()
            if v:IsA("BloomEffect") or v:IsA("BlurEffect")
                or v:IsA("SunRaysEffect") or v:IsA("DepthOfFieldEffect")
                or v:IsA("ColorCorrectionEffect") then v.Enabled = false end
        end)
    end
    task.spawn(function()
        for _, v in pairs(workspace:GetDescendants()) do
            pcall(function()
                if v:IsA("ParticleEmitter") or v:IsA("Trail")
                    or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
                    v.Enabled = false
                end
            end)
        end
    end)
    Notify("FPS BOOST","Оптимізовано ✓",2)
end

-- ============================================================
-- FULLBRIGHT
-- ============================================================
local savedLighting = {}

local function EnableFullbright()
    pcall(function()
        savedLighting.Brightness = Light.Brightness
        savedLighting.ClockTime = Light.ClockTime
        savedLighting.FogEnd = Light.FogEnd
        savedLighting.Ambient = Light.Ambient
        savedLighting.OutdoorAmbient = Light.OutdoorAmbient
        savedLighting.GlobalShadows = Light.GlobalShadows
        Light.Brightness = 2
        Light.ClockTime = 14
        Light.FogEnd = 100000
        Light.Ambient = Color3.fromRGB(178, 178, 178)
        Light.OutdoorAmbient = Color3.fromRGB(178, 178, 178)
        Light.GlobalShadows = false
    end)
    for _, v in pairs(Light:GetChildren()) do
        pcall(function()
            if v:IsA("Atmosphere") then
                v.Density = 0; v.Offset = 0
            end
        end)
    end
    Notify("FULLBRIGHT","Увімкнено ✓",2)
end

local function DisableFullbright()
    pcall(function()
        if savedLighting.Brightness then
            Light.Brightness = savedLighting.Brightness
            Light.ClockTime = savedLighting.ClockTime
            Light.FogEnd = savedLighting.FogEnd
            Light.Ambient = savedLighting.Ambient
            Light.OutdoorAmbient = savedLighting.OutdoorAmbient
            Light.GlobalShadows = savedLighting.GlobalShadows
        end
    end)
    Notify("FULLBRIGHT","Вимкнено ✗",2)
end

-- ============================================================
-- AUTO EQUIP
-- ============================================================
local weaponKeywords = {
    "ak","ar","m4","m1","glock","deagle","uzi","rpg","rpk","mp7",
    "aug","dragunov","barrett","mossberg","python","raygun","saiga",
    "shotgun","rifle","pistol","smg","lmg","gun","tommy","spas",
    "sawn","sniper","usp","flamethrower","scar","awp","p90","famas",
    "mac","stagecoach","revolver","minigun","acid","money gun",
    "gravity","crossbow","taser","katana","machete","bat","knife",
    "crowbar","saber","fireaxe","kunai"
}

task.spawn(function()
    while task.wait(1.5) do
        if not Config.AutoEquip then continue end
        if not IsHumAlive() then continue end
        local root = GetRoot()
        local hum = GetHum()
        local char = GetChar()
        if not root or not hum or not char then continue end
        local enemyNear = false
        for _, p in pairs(Players:GetPlayers()) do
            if p == lp then continue end
            if not IsTargetAlive(p) then continue end
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp and (hrp.Position - root.Position).Magnitude < 50 then
                enemyNear = true; break
            end
        end
        if not enemyNear then continue end
        local equipped = char:FindFirstChildOfClass("Tool")
        if equipped then
            local en = equipped.Name:lower()
            local isWeapon = false
            for _, kw in pairs(weaponKeywords) do
                if en:find(kw, 1, true) then isWeapon = true; break end
            end
            if isWeapon then continue end
        end
        local bestTool = nil
        for _, item in pairs(lp.Backpack:GetChildren()) do
            if not item:IsA("Tool") then continue end
            local n = item.Name:lower()
            for _, kw in pairs(weaponKeywords) do
                if n:find(kw, 1, true) then bestTool = item; break end
            end
            if bestTool then break end
        end
        if bestTool then
            pcall(function() hum:EquipTool(bestTool) end)
        end
    end
end)

-- ============================================================
-- AUTO HEAL / ARMOR
-- ============================================================
local healCooldown = 0

task.spawn(function()
    while task.wait(IsMobile and 1.5 or 0.8) do
        if not IsHumAlive() then continue end
        local now = tick()
        if now - healCooldown < 2 then continue end
        local hum = GetHum()
        local char = GetChar()
        if not hum or not char then continue end
        local function TryUseItem(keywords)
            local found = nil
            for _, item in pairs(lp.Backpack:GetChildren()) do
                if not item:IsA("Tool") then continue end
                local n = item.Name:lower()
                for _, kw in pairs(keywords) do
                    if n:find(kw, 1, true) then found = item; break end
                end
                if found then break end
            end
            if not found then
                for _, item in pairs(char:GetChildren()) do
                    if not item:IsA("Tool") then continue end
                    local n = item.Name:lower()
                    for _, kw in pairs(keywords) do
                        if n:find(kw, 1, true) then found = item; break end
                    end
                    if found then break end
                end
            end
            if not found then return end
            pcall(function()
                if found.Parent == lp.Backpack then
                    hum:EquipTool(found); task.wait(0.25)
                end
                local tool = char:FindFirstChild(found.Name)
                if tool then tool:Activate() end
            end)
            task.wait(0.7)
            pcall(function() hum:UnequipTools() end)
            healCooldown = tick()
        end
        if Config.Heal and hum.Health < hum.MaxHealth * 0.75 then
            TryUseItem({"medkit","bandage","firstaid","aid","heal","health","first aid"})
        end
        if Config.Armor then
            TryUseItem({"armor","vest","helmet","shield","kevlar"})
        end
    end
end)

-- ============================================================
-- ANTI-AFK
-- ============================================================
lp.Idled:Connect(function()
    if Config.AntiAFK then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end)
task.spawn(function()
    while task.wait(50) do
        if Config.AntiAFK then
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end
    end
end)

-- ============================================================
-- AUTO ROB
-- ============================================================
local function StartRobbery()
    Notify("BANK ROB","Починаємо...",2)
    if not SafeTeleport(COORDS.BANK_MONEY) then
        Notify("BANK ROB","Помилка!",2); return
    end
    task.wait(0.8)
    for i = 1, 20 do
        if not IsHumAlive() then break end
        pcall(function()
            local root = GetRoot()
            if not root then return end
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("ProximityPrompt") and v.Enabled then
                    local pp = v.Parent
                    if pp and (root.Position - pp:GetPivot().Position).Magnitude < 15 then
                        SafeFirePrompt(v)
                    end
                end
            end
        end)
        task.wait(0.5)
    end
    SafeTeleport(COORDS.SAFE_ZONE)
    Notify("BANK ROB","Готово ✓",3)
end

-- ============================================================
-- ESP (PLAYERS)
-- ============================================================
local ESPCache = {}

local function ClearESP(char)
    if not char then return end
    pcall(function()
        local head = char:FindFirstChild("Head")
        if head then local g = head:FindFirstChild("MrkESP"); if g then g:Destroy() end end
        local hl = char:FindFirstChild("MrkHL"); if hl then hl:Destroy() end
    end)
end

local function ClearAllESP()
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= lp then ClearESP(v.Character) end
    end
    ESPCache = {}
end

task.spawn(function()
    while task.wait(IsMobile and 0.2 or 0.08) do
        if not Config.ESP then continue end
        local myRoot = GetRoot()
        for _, v in pairs(Players:GetPlayers()) do
            if v == lp then continue end
            local char = v.Character
            local head = char and char:FindFirstChild("Head")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if not char or not head or not hum or hum.Health <= 0 then
                if ESPCache[v] then ClearESP(char); ESPCache[v] = nil end
                continue
            end
            local cache = ESPCache[v]
            if not cache or not cache.gui or not cache.gui.Parent then
                if cache then ClearESP(char) end
                local gui = Instance.new("BillboardGui")
                gui.Name = "MrkESP"
                gui.Size = UDim2.new(0, IsMobile and 150 or 185, 0, IsMobile and 42 or 50)
                gui.StudsOffset = Vector3.new(0, 3.2, 0)
                gui.AlwaysOnTop = true
                gui.MaxDistance = IsMobile and 250 or 450
                gui.Parent = head
                local bg = Instance.new("Frame", gui)
                bg.Size = UDim2.new(1, 0, 1, 0)
                bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                bg.BackgroundTransparency = 0.45
                bg.BorderSizePixel = 0
                Instance.new("UICorner", bg)
                local lbl = Instance.new("TextLabel", bg)
                lbl.Name = "L"
                lbl.Size = UDim2.new(1, 0, 1, 0)
                lbl.BackgroundTransparency = 1
                lbl.Font = Enum.Font.GothamBold
                lbl.TextSize = IsMobile and 10 or 12
                lbl.TextWrapped = true
                lbl.TextStrokeTransparency = 0.3
                if IsPC then
                    pcall(function()
                        local hl = Instance.new("Highlight")
                        hl.Name = "MrkHL"
                        hl.FillColor = Color3.new(1, 0, 0)
                        hl.OutlineColor = Color3.new(1, 1, 1)
                        hl.FillTransparency = 0.65
                        hl.OutlineTransparency = 0
                        hl.Adornee = char; hl.Parent = char
                    end)
                end
                ESPCache[v] = {gui = gui, lbl = lbl}
                cache = ESPCache[v]
            end
            local dist = myRoot and math.floor((myRoot.Position - head.Position).Magnitude) or 0
            local hp = math.floor(hum.Health)
            local maxHp = math.max(math.floor(hum.MaxHealth), 1)
            local ratio = hp / maxHp
            cache.lbl.Text = string.format("[%s]\nHP:%d/%d | %dm", v.Name, hp, maxHp, dist)
            cache.lbl.TextColor3 = ratio >= 0.6
                and Color3.fromRGB(0, 255, 100)
                or ratio >= 0.3
                and Color3.fromRGB(255, 220, 0)
                or Color3.fromRGB(255, 60, 60)
        end
    end
end)

Players.PlayerRemoving:Connect(function(p)
    if ESPCache[p] then ClearESP(p.Character); ESPCache[p] = nil end
end)
for _, p in pairs(Players:GetPlayers()) do
    if p ~= lp then
        p.CharacterRemoving:Connect(function(char)
            if ESPCache[p] then ClearESP(char); ESPCache[p] = nil end
        end)
    end
end
Players.PlayerAdded:Connect(function(p)
    p.CharacterRemoving:Connect(function(char)
        if ESPCache[p] then ClearESP(char); ESPCache[p] = nil end
    end)
end)

-- ============================================================
-- ITEM ESP
-- ============================================================
local ItemESPCache = {}

local function ClearAllItemESP()
    for obj, gui in pairs(ItemESPCache) do
        pcall(function() gui:Destroy() end)
    end
    ItemESPCache = {}
end

task.spawn(function()
    while task.wait(IsMobile and 2.0 or 1.0) do
        if not Config.ItemESP then
            if next(ItemESPCache) then ClearAllItemESP() end
            continue
        end
        local myRoot = GetRoot()
        if not myRoot then continue end

        for obj, gui in pairs(ItemESPCache) do
            if not obj or not obj.Parent then
                pcall(function() gui:Destroy() end)
                ItemESPCache[obj] = nil
            end
        end

        for _, v in pairs(workspace:GetDescendants()) do
            if not v:IsA("ProximityPrompt") or not v.Enabled then continue end
            local par = v.Parent
            if not par then continue end

            local parentName = par.Name or ""
            local pLow = parentName:lower()
            local text = (pLow .. " " .. (v.ActionText or "") .. " " .. (v.ObjectText or "")):lower()

            if not IsItemEnabledInPicker(parentName) then continue end

            local isLootItem = false
            if PriorityLoot[pLow] then
                isLootItem = true
            elseif not IsBlocked(text) then
                if IsPriority(text, parentName) then
                    isLootItem = true
                else
                    -- Check against ALL_ITEMS
                    for _, item in pairs(ALL_ITEMS) do
                        if pLow:find(item:lower(), 1, true) then
                            isLootItem = true; break
                        end
                    end
                end
            end
            if not isLootItem then continue end

            local pos = Vector3.zero
            pcall(function() pos = par:GetPivot().Position end)
            if pos.Magnitude < 1 then continue end
            local dist = (myRoot.Position - pos).Magnitude
            if dist > (IsMobile and 200 or 400) then continue end

            if not ItemESPCache[par] then
                local gui = Instance.new("BillboardGui")
                gui.Name = "MrkItemESP"
                gui.Size = UDim2.new(0, IsMobile and 120 or 150, 0, 28)
                gui.StudsOffset = Vector3.new(0, 2, 0)
                gui.AlwaysOnTop = true
                gui.MaxDistance = IsMobile and 200 or 400

                local bg = Instance.new("Frame", gui)
                bg.Size = UDim2.new(1, 0, 1, 0)
                bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                bg.BackgroundTransparency = 0.35
                bg.BorderSizePixel = 0
                Instance.new("UICorner", bg)

                local lbl = Instance.new("TextLabel", bg)
                lbl.Name = "L"
                lbl.Size = UDim2.new(1, 0, 1, 0)
                lbl.BackgroundTransparency = 1
                lbl.Font = Enum.Font.GothamBold
                lbl.TextSize = IsMobile and 9 or 11
                lbl.TextWrapped = true
                lbl.TextStrokeTransparency = 0.3

                pcall(function() gui.Parent = par end)
                if not gui.Parent then
                    gui:Destroy()
                    continue
                end
                ItemESPCache[par] = gui
            end

            local gui = ItemESPCache[par]
            local bg = gui:FindFirstChild("Frame")
            local lbl = bg and bg:FindFirstChild("L")
            if lbl then
                local d = math.floor(dist)
                local isPrio = PriorityLoot[pLow] or IsPriority(text, parentName)
                lbl.Text = (isPrio and "⭐ " or "📦 ") .. parentName .. " [" .. d .. "m]"
                lbl.TextColor3 = isPrio
                    and Color3.fromRGB(255, 215, 0)
                    or Color3.fromRGB(0, 200, 255)
            end
        end
    end
end)

-- ============================================================
-- NOCLIP
-- ============================================================
local function RestoreCollision()
    local char = GetChar()
    if not char then return end
    for _, v in pairs(char:GetDescendants()) do
        if v:IsA("BasePart") then pcall(function() v.CanCollide = true end) end
    end
end

-- ============================================================
-- AUTO FARM with Item Picker filter + continue after death
-- ============================================================
local farmRunning = false

local function CollectPrompt(v)
    if not v or not v.Parent then return end
    if not v.Enabled then return end
    if not IsHumAlive() then return end
    local pos = nil
    pcall(function() pos = v.Parent:GetPivot().Position end)
    if not pos then return end
    if pos.Magnitude < 1 then return end
    SafeTeleport(pos)
    task.wait(IsMobile and 0.4 or 0.25)
    SafeFirePrompt(v)
    task.wait(IsMobile and 0.3 or 0.2)
end

local function GetPromptPos(v)
    local p = Vector3.zero
    pcall(function() p = v.Parent:GetPivot().Position end)
    return p
end

task.spawn(function()
    while task.wait(IsMobile and 1.0 or 0.5) do
        if not Config.Farm then continue end
        if farmRunning then continue end

        -- Wait for alive (auto continue after death)
        if not IsHumAlive() then
            task.wait(2)
            continue
        end

        farmRunning = true
        pcall(function()
            local prompts = {}
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("ProximityPrompt") and v.Enabled then
                    table.insert(prompts, v)
                end
            end

            local priorityList = {}
            local normalList = {}
            local myRoot = GetRoot()

            for _, v in pairs(prompts) do
                if not v or not v.Parent or not v.Enabled then continue end
                local parentName = v.Parent and v.Parent.Name or ""
                local pLow = parentName:lower()
                local text = (pLow.." "..(v.ActionText or "").." "..(v.ObjectText or "")):lower()

                -- Check Item Picker filter
                if not IsItemEnabledInPicker(parentName) then continue end

                if PriorityLoot[pLow] then
                    table.insert(priorityList, v); continue
                end
                if IsBlocked(text) then continue end
                if IsPriority(text, parentName) then
                    table.insert(priorityList, v)
                else
                    -- Check against ALL_ITEMS
                    local found = false
                    for _, item in pairs(ALL_ITEMS) do
                        if pLow:find(item:lower(), 1, true) then
                            found = true; break
                        end
                    end
                    if found then
                        table.insert(normalList, v)
                    end
                end
            end

            if myRoot then
                local myPos = myRoot.Position
                table.sort(priorityList, function(a, b)
                    return (GetPromptPos(a) - myPos).Magnitude
                         < (GetPromptPos(b) - myPos).Magnitude
                end)
                table.sort(normalList, function(a, b)
                    return (GetPromptPos(a) - myPos).Magnitude
                         < (GetPromptPos(b) - myPos).Magnitude
                end)
            end

            for _, v in pairs(priorityList) do
                if not Config.Farm or not IsHumAlive() then break end
                CollectPrompt(v)
            end
            for _, v in pairs(normalList) do
                if not Config.Farm or not IsHumAlive() then break end
                CollectPrompt(v)
            end
        end)
        farmRunning = false
    end
end)

-- ============================================================
-- RENDER STEPPED
-- ============================================================
RS.RenderStepped:Connect(function(dt)
    local now = tick()
    if now - pingTick > 3 then
        pingTick = now
        pcall(function() lastPing = lp:GetNetworkPing() end)
    end
    if Config.SilentAim then DoSilentAim() end
    if Config.AimActive then
        local target = GetBestAimTarget()
        local part = target and FindAimPart(target)
        if part then
            local predTime = math.clamp(lastPing, 0.01, 0.2)
            local vel = part.AssemblyLinearVelocity
            local dist = (Camera.CFrame.Position - part.Position).Magnitude
            local predMul = math.clamp(dist / 100, 0.3, 1.5)
            local predicted = part.Position + vel * predTime * predMul
            local smooth = Config.AimSmooth
            local sd = ScreenDist(part)
            if sd < 30 then smooth *= 0.3 elseif sd < 80 then smooth *= 0.6 end
            Camera.CFrame = Camera.CFrame:Lerp(
                CFrame.new(Camera.CFrame.Position, predicted), smooth)
        end
    else
        aimTarget = nil; aimLocked = false; aimLostFrames = 0
    end
    if Config.Fly and IsHumAlive() then
        local root = GetRoot()
        local hum = GetHum()
        if root and hum then
            local moveX, moveZ = 0, 0
            if IsMobile and Controls then
                local mv = Controls:GetMoveVector()
                moveX = mv.X; moveZ = mv.Z
            elseif IsPC then
                if UIS:IsKeyDown(Enum.KeyCode.W) then moveZ = -1 end
                if UIS:IsKeyDown(Enum.KeyCode.S) then moveZ = 1 end
                if UIS:IsKeyDown(Enum.KeyCode.A) then moveX = -1 end
                if UIS:IsKeyDown(Enum.KeyCode.D) then moveX = 1 end
            end
            local camCF = Camera.CFrame
            local dir = camCF.LookVector * -moveZ + camCF.RightVector * moveX
            local upD = 0
            if UIS:IsKeyDown(Enum.KeyCode.Space) or MobUp then upD = 1 end
            if UIS:IsKeyDown(Enum.KeyCode.LeftControl) or MobDn then upD = -1 end
            dir = dir + Vector3.new(0, upD, 0)
            if dir.Magnitude > 1 then dir = dir.Unit end
            root.CFrame = root.CFrame + dir * Config.FlySpeedValue * dt
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
        end
    end
end)

-- ============================================================
-- HEARTBEAT
-- ============================================================
RS.Heartbeat:Connect(function(dt)
    local hum = GetHum()
    local root = GetRoot()
    if not hum or not root then return end
    if Config.AntiSeat and hum.SeatPart then
        pcall(function() hum.Sit = false end)
    end
    if Config.Speed and not Config.Fly and IsHumAlive() then
        if hum.WalkSpeed ~= Config.WalkSpeedValue then
            hum.WalkSpeed = Config.WalkSpeedValue
        end
    elseif not Config.Fly and not Config.Speed then
        if hum.WalkSpeed ~= 16 then hum.WalkSpeed = 16 end
    end
    if not Config.Fly and hum.PlatformStand then
        pcall(function() hum.PlatformStand = false end)
    end
    -- High Jump
    if Config.HighJump and IsHumAlive() then
        if hum.JumpPower ~= Config.JumpPowerValue then
            hum.JumpPower = Config.JumpPowerValue
        end
    elseif not Config.HighJump and IsHumAlive() then
        if hum.JumpPower ~= 50 then hum.JumpPower = 50 end
    end
    if Config.Noclip then
        local char = GetChar()
        if char then
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") then pcall(function() v.CanCollide = false end) end
            end
        end
    end
    if Config.Magnet then
        if not IsTargetAlive(Config.MagnetTarget) then
            Config.MagnetTarget = GetClosestByDist()
        end
        if Config.MagnetTarget then
            local tHRP = Config.MagnetTarget.Character
                and Config.MagnetTarget.Character:FindFirstChild("HumanoidRootPart")
            if tHRP then
                pcall(function()
                    root.CFrame = root.CFrame:Lerp(
                        tHRP.CFrame * CFrame.new(0, 0, 3),
                        IsMobile and 0.15 or 0.22)
                    root.AssemblyLinearVelocity = tHRP.AssemblyLinearVelocity
                end)
            end
        end
    else
        Config.MagnetTarget = nil
    end
    if Config.AutoSafe and (not Config.Farm) and IsHumAlive() and hum.Health <= Config.SafeHealth then
        if (root.Position - COORDS.SAFE_ZONE).Magnitude > 20 then
            SafeTeleport(COORDS.SAFE_ZONE)
            Notify("AUTO SAFE","HP: "..math.floor(hum.Health),3)
        end
    end
end)

-- ============================================================
-- INFINITE JUMP
-- ============================================================
UIS.JumpRequest:Connect(function()
    if not Config.InfJump then return end
    local hum = GetHum()
    if hum and hum:GetState() ~= Enum.HumanoidStateType.Jumping then
        pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end)
    end
end)

-- ============================================================
-- CLEANUP ON RESPAWN (Farm continues!)
-- ============================================================
lp.CharacterRemoving:Connect(function(char)
    if Config.Noclip then
        pcall(function()
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = true end
            end
        end)
    end
    Config.Fly = false; Config.Noclip = false
    aimTarget = nil; aimLocked = false; aimLostFrames = 0
    -- NOTE: Config.Farm stays ON so it continues after respawn
end)

lp.CharacterAdded:Connect(function(char)
    Config.Fly = false; Config.Noclip = false; Config.Magnet = false
    aimTarget = nil; aimLocked = false; aimLostFrames = 0
    pcall(function()
        if UpdFuncs then
            if UpdFuncs.Fly then UpdFuncs.Fly(false) end
            if UpdFuncs.Noclip then UpdFuncs.Noclip(false) end
            if UpdFuncs.Magnet then UpdFuncs.Magnet(false) end
        end
    end)
    task.wait(1)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        pcall(function()
            hum.PlatformStand = false
            hum.WalkSpeed = 16
            hum.JumpPower = Config.HighJump and Config.JumpPowerValue or 50
        end)
    end
end)

-- ============================================================
-- GUI
-- ============================================================
local SG = Instance.new("ScreenGui")
SG.Name = "MarkiyanPro"
SG.ResetOnSpawn = false
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() SG.Parent = game:GetService("CoreGui") end)
if not SG.Parent or not SG.Parent.Name then
    SG.Parent = lp:WaitForChild("PlayerGui")
end

local MW = IsMobile and 280 or 420
local MH = IsMobile and 520 or 660

local Main = Instance.new("Frame", SG)
Main.Size = UDim2.new(0, MW, 0, MH)
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.Position = UDim2.new(0.5, 0, 0.5, 0)
Main.BackgroundColor3 = Color3.fromRGB(8, 8, 14)
Main.BorderSizePixel = 0; Main.Visible = false
Instance.new("UICorner", Main)
local mainStroke = Instance.new("UIStroke", Main)
mainStroke.Color = Color3.fromRGB(0, 120, 255); mainStroke.Thickness = 2

local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
Header.BorderSizePixel = 0
Instance.new("UICorner", Header)
local HGrad = Instance.new("UIGradient", Header)
HGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 50, 180)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 130, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 50, 180)),
})
local HeaderLbl = Instance.new("TextLabel", Header)
HeaderLbl.Size = UDim2.new(1, -50, 1, 0)
HeaderLbl.Position = UDim2.new(0, 8, 0, 0)
HeaderLbl.BackgroundTransparency = 1
HeaderLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
HeaderLbl.Font = Enum.Font.GothamBlack
HeaderLbl.TextSize = IsMobile and 12 or 14
HeaderLbl.TextXAlignment = Enum.TextXAlignment.Left
HeaderLbl.Text = "⚡ Markiyan PRO V51" .. (IsMobile and " [MOB]" or "")

-- FIXED: Close button doesn't overlap text
local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 26, 0, 26)
CloseBtn.Position = UDim2.new(1, -34, 0, 7)
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
CloseBtn.Text = "✕"; CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold; CloseBtn.TextSize = 12
CloseBtn.BorderSizePixel = 0; CloseBtn.ZIndex = 5
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
CloseBtn.MouseButton1Click:Connect(function() Main.Visible = false end)

local TabBar = Instance.new("Frame", Main)
TabBar.Size = UDim2.new(1, -8, 0, 28)
TabBar.Position = UDim2.new(0, 4, 0, 44)
TabBar.BackgroundColor3 = Color3.fromRGB(12, 12, 20)
TabBar.BorderSizePixel = 0
Instance.new("UICorner", TabBar)
local TabLayout = Instance.new("UIListLayout", TabBar)
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
TabLayout.Padding = UDim.new(0, 3)

local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1, -8, 1, -80)
Scroll.Position = UDim2.new(0, 4, 0, 76)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = IsPC and 3 or 0
Scroll.ScrollBarImageColor3 = Color3.fromRGB(0, 120, 255)
Scroll.BorderSizePixel = 0; Scroll.ClipsDescendants = true

local ListLayout = Instance.new("UIListLayout", Scroll)
ListLayout.Padding = UDim.new(0, 4)
ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local LP2 = Instance.new("UIPadding", Scroll)
LP2.PaddingTop = UDim.new(0, 4); LP2.PaddingBottom = UDim.new(0, 6)

ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Scroll.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 10)
end)

-- ============================================================
-- FOV CIRCLE
-- ============================================================
local fovCircle = Instance.new("Frame", SG)
fovCircle.Size = UDim2.new(0, Config.AimFOV * 2, 0, Config.AimFOV * 2)
fovCircle.Position = UDim2.new(0.5, -Config.AimFOV, 0.5, -Config.AimFOV)
fovCircle.BackgroundTransparency = 1; fovCircle.BorderSizePixel = 0
fovCircle.Visible = false; fovCircle.ZIndex = 10
Instance.new("UICorner", fovCircle).CornerRadius = UDim.new(1, 0)
local fovStroke = Instance.new("UIStroke", fovCircle)
fovStroke.Color = Color3.fromRGB(0, 120, 255)
fovStroke.Thickness = 1.5; fovStroke.Transparency = 0.3

local tgtInfo = Instance.new("TextLabel", SG)
tgtInfo.Size = UDim2.new(0, 200, 0, 22)
tgtInfo.Position = UDim2.new(0.5, -100, 0.5, -(Config.AimFOV + 32))
tgtInfo.BackgroundColor3 = Color3.fromRGB(10, 10, 16)
tgtInfo.BackgroundTransparency = 0.25; tgtInfo.BorderSizePixel = 0
tgtInfo.TextColor3 = Color3.fromRGB(0, 200, 100)
tgtInfo.Font = Enum.Font.GothamBold; tgtInfo.TextSize = 11
tgtInfo.Text = ""; tgtInfo.Visible = false; tgtInfo.ZIndex = 12
Instance.new("UICorner", tgtInfo).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", tgtInfo).Color = Color3.fromRGB(40, 40, 58)

local function UpdateFOVCircle()
    local r = Config.AimFOV
    fovCircle.Size = UDim2.new(0, r * 2, 0, r * 2)
    fovCircle.Position = UDim2.new(0.5, -r, 0.5, -r)
    tgtInfo.Position = UDim2.new(0.5, -100, 0.5, -(r + 32))
end

local fovUpdateTick = 0
RS.RenderStepped:Connect(function()
    local now = tick()
    if now - fovUpdateTick < 0.05 then return end
    fovUpdateTick = now
    fovCircle.Visible = Config.AimActive or Config.SilentAim
    tgtInfo.Visible = false
    if Config.AimActive then
        local targetChar = aimTarget and aimTarget.Character
        local part = targetChar and FindAimPart(targetChar)
        if part and aimLocked then
            local plr = Players:GetPlayerFromCharacter(targetChar)
            local dist = math.floor((Camera.CFrame.Position - part.Position).Magnitude)
            tgtInfo.Text = "🔒 "..(plr and plr.Name or "?").." ["..dist.."m]"
            tgtInfo.TextColor3 = Color3.fromRGB(0, 230, 120)
            tgtInfo.Visible = true
            fovStroke.Color = Color3.fromRGB(0, 200, 100)
        else
            tgtInfo.Text = "No target"
            tgtInfo.TextColor3 = Color3.fromRGB(120, 120, 145)
            tgtInfo.Visible = true
            fovStroke.Color = Color3.fromRGB(100, 100, 180)
        end
    elseif Config.SilentAim then
        local tgtChar = aimTarget and aimTarget.Character
        local part = tgtChar and FindAimPart(tgtChar)
        if part then
            local plr = Players:GetPlayerFromCharacter(tgtChar)
            local dist = math.floor((Camera.CFrame.Position - part.Position).Magnitude)
            tgtInfo.Text = "🔇 "..(plr and plr.Name or "?").." ["..dist.."m]"
            tgtInfo.TextColor3 = Color3.fromRGB(255, 200, 50)
            tgtInfo.Visible = true
            fovStroke.Color = Color3.fromRGB(255, 200, 50)
        else
            tgtInfo.Text = "No target"
            tgtInfo.TextColor3 = Color3.fromRGB(120, 120, 145)
            tgtInfo.Visible = true
            fovStroke.Color = Color3.fromRGB(100, 100, 180)
        end
    end
end)

-- ============================================================
-- MOBILE FLY BUTTONS
-- ============================================================
local flyHolder = Instance.new("Frame", SG)
flyHolder.Size = UDim2.new(0, 134, 0, 60)
flyHolder.Position = UDim2.new(1, -148, 1, -76)
flyHolder.BackgroundTransparency = 1; flyHolder.Visible = false; flyHolder.ZIndex = 50

local function MkFlyBtn(label, xOff, callback)
    local b = Instance.new("TextButton", flyHolder)
    b.Size = UDim2.new(0, 60, 0, 56)
    b.Position = UDim2.new(0, xOff, 0, 0)
    b.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
    b.Text = label; b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Font = Enum.Font.GothamBlack; b.TextSize = 26
    b.BorderSizePixel = 0; b.ZIndex = 51; b.AutoButtonColor = false
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)
    Instance.new("UIStroke", b).Color = Color3.fromRGB(40, 40, 58)
    b.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch
            or inp.UserInputType == Enum.UserInputType.MouseButton1 then
            callback(true); b.BackgroundColor3 = Color3.fromRGB(32, 32, 48)
        end
    end)
    b.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch
            or inp.UserInputType == Enum.UserInputType.MouseButton1 then
            callback(false); b.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
        end
    end)
end
MkFlyBtn("▲", 0, function(v) MobUp = v end)
MkFlyBtn("▼", 70, function(v) MobDn = v end)

local function UpdateFlyBtns()
    flyHolder.Visible = Config.Fly and IsMobile
end

-- ============================================================
-- TABS SYSTEM
-- ============================================================
local Sections = {}
local TabButtons = {}
local ActiveTab = nil

local function ShowTab(name)
    ActiveTab = name
    for n, frames in pairs(Sections) do
        for _, f in pairs(frames) do pcall(function() f.Visible = (n == name) end) end
    end
    for n, btn in pairs(TabButtons) do
        if n == name then
            btn.BackgroundColor3 = Color3.fromRGB(0, 100, 220)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            btn.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
            btn.TextColor3 = Color3.fromRGB(150, 150, 170)
        end
    end
    task.wait()
    Scroll.CanvasPosition = Vector2.zero
    Scroll.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 10)
end

local tabNames = {"Combat","Move","Misc","Items","Binds"}
local tabW = IsMobile and 46 or 64

for _, name in pairs(tabNames) do
    Sections[name] = {}
    local btn = Instance.new("TextButton", TabBar)
    btn.Size = UDim2.new(0, tabW, 0, 22)
    btn.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
    btn.TextColor3 = Color3.fromRGB(150, 150, 170)
    btn.Font = Enum.Font.GothamBold; btn.TextSize = IsMobile and 9 or 11
    btn.Text = name; btn.BorderSizePixel = 0; btn.AutoButtonColor = false
    Instance.new("UICorner", btn)
    TabButtons[name] = btn
    btn.MouseButton1Click:Connect(function() ShowTab(name) end)
end

-- DRAGGABLE
local function MakeDraggable(handle, target)
    local drag, dStart, dPos = false, nil, nil
    handle.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
            or inp.UserInputType == Enum.UserInputType.Touch then
            drag = true; dStart = inp.Position; dPos = target.Position
        end
    end)
    handle.InputChanged:Connect(function(inp)
        if not drag then return end
        if inp.UserInputType == Enum.UserInputType.MouseMovement
            or inp.UserInputType == Enum.UserInputType.Touch then
            local d = inp.Position - dStart
            target.Position = UDim2.new(dPos.X.Scale, dPos.X.Offset + d.X,
                dPos.Y.Scale, dPos.Y.Offset + d.Y)
        end
    end)
    handle.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
            or inp.UserInputType == Enum.UserInputType.Touch then drag = false end
    end)
    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
            or inp.UserInputType == Enum.UserInputType.Touch then drag = false end
    end)
end
MakeDraggable(Header, Main)

-- ============================================================
-- UI HELPERS
-- ============================================================
local BtnH = IsMobile and 36 or 32
local UpdFuncs = {}
local Buttons = {}

local function MakeFrame(tabName)
    local f = Instance.new("Frame", Scroll)
    f.Size = UDim2.new(0.97, 0, 0, BtnH)
    f.BackgroundTransparency = 1; f.BorderSizePixel = 0; f.Visible = false
    table.insert(Sections[tabName], f)
    return f
end

local function AddCategory(tabName, text)
    local f = Instance.new("Frame", Scroll)
    f.Size = UDim2.new(0.97, 0, 0, 20)
    f.BackgroundColor3 = Color3.fromRGB(0, 55, 155)
    f.BorderSizePixel = 0; f.Visible = false
    Instance.new("UICorner", f)
    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(1, 0, 1, 0); l.BackgroundTransparency = 1
    l.TextColor3 = Color3.fromRGB(255, 255, 255)
    l.Font = Enum.Font.GothamBold; l.TextSize = 11
    l.Text = "── " .. text .. " ──"
    table.insert(Sections[tabName], f)
end

local function AddToggle(tabName, name, key, cbOn, cbOff)
    local f = MakeFrame(tabName)
    local btn = Instance.new("TextButton", f)
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    btn.TextColor3 = Color3.fromRGB(190, 190, 200)
    btn.Font = Enum.Font.GothamBold; btn.TextSize = IsMobile and 11 or 13
    btn.BorderSizePixel = 0; btn.AutoButtonColor = false
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Text = "       " .. name .. ": OFF"
    Instance.new("UICorner", btn)
    -- FIXED: dot positioned properly, not overlapping text
    local dot = Instance.new("Frame", btn)
    dot.Size = UDim2.new(0, 8, 0, 8)
    dot.AnchorPoint = Vector2.new(0, 0.5)
    dot.Position = UDim2.new(0, 10, 0.5, 0)
    dot.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    dot.BorderSizePixel = 0; dot.ZIndex = btn.ZIndex + 1
    Instance.new("UICorner", dot)
    Buttons[key] = btn
    local function Upd(state)
        if state then
            btn.BackgroundColor3 = Color3.fromRGB(0, 70, 190)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            dot.BackgroundColor3 = Color3.fromRGB(0, 220, 80)
            btn.Text = "       " .. name .. ": ON"
        else
            btn.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
            btn.TextColor3 = Color3.fromRGB(190, 190, 200)
            dot.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            btn.Text = "       " .. name .. ": OFF"
        end
    end
    UpdFuncs[key] = Upd
    -- Apply saved state
    if Config[key] then Upd(true) end
    btn.MouseButton1Click:Connect(function()
        Config[key] = not Config[key]
        Upd(Config[key])
        if Config[key] then
            if cbOn then task.spawn(cbOn) end
        else
            if cbOff then task.spawn(cbOff) end
        end
        if key == "Fly" then UpdateFlyBtns() end
        if key == "AimActive" and not Config[key] then
            aimTarget = nil; aimLocked = false; aimLostFrames = 0
        end
        if key == "ESP" and not Config[key] then ClearAllESP() end
        if key == "ItemESP" and not Config[key] then ClearAllItemESP() end
        SaveSettings(Config, ItemPickerState)
        Notify(name, Config[key] and "ON ✓" or "OFF ✗", 1.5)
    end)
    return Upd
end

local function AddSlider(tabName, label, minV, maxV, default, configKey, cb)
    local f = Instance.new("Frame", Scroll)
    f.Size = UDim2.new(0.97, 0, 0, IsMobile and 50 or 52)
    f.BackgroundColor3 = Color3.fromRGB(16, 16, 24)
    f.BorderSizePixel = 0; f.Visible = false
    Instance.new("UICorner", f)
    table.insert(Sections[tabName], f)
    local lbl = Instance.new("TextLabel", f)
    lbl.Size = UDim2.new(1, -8, 0, 20)
    lbl.Position = UDim2.new(0, 4, 0, 2)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(200, 200, 210)
    lbl.Font = Enum.Font.GothamBold; lbl.TextSize = IsMobile and 11 or 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = label .. ": " .. default
    local track = Instance.new("Frame", f)
    track.Size = UDim2.new(0.92, 0, 0, IsMobile and 9 or 8)
    track.Position = UDim2.new(0.04, 0, 0, IsMobile and 32 or 34)
    track.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    track.BorderSizePixel = 0
    Instance.new("UICorner", track)
    local fill = Instance.new("Frame", track)
    fill.Size = UDim2.new((default - minV) / (maxV - minV), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
    fill.BorderSizePixel = 0
    Instance.new("UICorner", fill)
    local kSz = IsMobile and 16 or 13
    local knob = Instance.new("Frame", track)
    knob.Size = UDim2.new(0, kSz, 0, kSz)
    knob.Position = UDim2.new((default - minV) / (maxV - minV), -kSz/2, 0.5, -kSz/2)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    Instance.new("UICorner", knob)
    local dragging = false
    local function UpdateSlider(inp)
        local rel = math.clamp(
            (inp.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local val = math.floor(minV + rel * (maxV - minV))
        fill.Size = UDim2.new(rel, 0, 1, 0)
        knob.Position = UDim2.new(rel, -kSz/2, 0.5, -kSz/2)
        lbl.Text = label .. ": " .. val
        Config[configKey] = val
        if cb then cb(val) end
    end
    track.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
            or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = true; UpdateSlider(inp)
        end
    end)
    UIS.InputChanged:Connect(function(inp)
        if not dragging then return end
        if inp.UserInputType == Enum.UserInputType.MouseMovement
            or inp.UserInputType == Enum.UserInputType.Touch then UpdateSlider(inp) end
    end)
    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
            or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            SaveSettings(Config, ItemPickerState)
        end
    end)
end

local function AddAction(tabName, name, color, cb)
    local f = MakeFrame(tabName)
    local btn = Instance.new("TextButton", f)
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundColor3 = color or Color3.fromRGB(130, 0, 0)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold; btn.TextSize = IsMobile and 11 or 13
    btn.BorderSizePixel = 0; btn.AutoButtonColor = false; btn.Text = name
    Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(function()
        local orig = btn.BackgroundColor3
        btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        task.wait(0.08); btn.BackgroundColor3 = orig
        task.spawn(cb)
    end)
end

local function AddTP(tabName, name, vec)
    local f = MakeFrame(tabName)
    local btn = Instance.new("TextButton", f)
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(18, 18, 32)
    btn.TextColor3 = Color3.fromRGB(255, 215, 0)
    btn.Font = Enum.Font.GothamBold; btn.TextSize = IsMobile and 11 or 12
    btn.BorderSizePixel = 0; btn.AutoButtonColor = false
    btn.Text = "📍 " .. name
    Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(function()
        if SafeTeleport(vec) then Notify("TP","➜ "..name,2) end
    end)
end

-- ============================================================
-- POPULATE TABS
-- ============================================================
-- COMBAT TAB
AddCategory("Combat","COMBAT")
AddToggle("Combat","AIM LOCK","AimActive",
    function() aimTarget=nil;aimLocked=false;aimLostFrames=0;aimLastSwitch=0 end,
    function() aimTarget=nil;aimLocked=false;aimLostFrames=0 end)
AddToggle("Combat","SILENT AIM","SilentAim")
AddToggle("Combat","KILL AURA","KillAura")
AddSlider("Combat","Kill Aura Range",5,30,Config.KillAuraRange,"KillAuraRange")
AddToggle("Combat","ESP (PLAYERS)","ESP",nil,function() ClearAllESP() end)
AddToggle("Combat","ITEM ESP","ItemESP",nil,function() ClearAllItemESP() end)
AddToggle("Combat","MAGNET","Magnet",nil,function() Config.MagnetTarget=nil end)
AddToggle("Combat","AUTO EQUIP","AutoEquip")
AddCategory("Combat","AIM CONFIG")
AddSlider("Combat","Aim FOV",50,500,Config.AimFOV,"AimFOV",function(v)
    Config.AimFOV=v; UpdateFOVCircle()
end)
AddSlider("Combat","Aim Smooth (x100)",5,100,
    math.floor(Config.AimSmooth*100),"AimSmooth",
    function(v) Config.AimSmooth=v/100 end)

-- MOVEMENT TAB
AddCategory("Move","MOVEMENT")
AddToggle("Move","FLY","Fly",
    function() UpdateFlyBtns() end,
    function()
        UpdateFlyBtns()
        local hum=GetHum()
        if hum then hum.PlatformStand=false; hum.WalkSpeed=16 end
    end)
AddSlider("Move","FLY SPEED",10,IsPC and 250 or 150,Config.FlySpeedValue,"FlySpeedValue")
AddToggle("Move","SPEED HACK","Speed",
    nil,function() local h=GetHum(); if h then h.WalkSpeed=16 end end)
AddSlider("Move","WALK SPEED",16,IsPC and 150 or 100,Config.WalkSpeedValue,"WalkSpeedValue")
AddToggle("Move","NOCLIP","Noclip",nil,function() RestoreCollision() end)
AddToggle("Move","INF JUMP","InfJump")
AddToggle("Move","HIGH JUMP","HighJump",
    function()
        local hum = GetHum()
        if hum then hum.JumpPower = Config.JumpPowerValue end
    end,
    function()
        local hum = GetHum()
        if hum then hum.JumpPower = 50 end
    end)
AddSlider("Move","JUMP POWER",50,300,Config.JumpPowerValue,"JumpPowerValue",function(v)
    if Config.HighJump then
        local hum = GetHum()
        if hum then hum.JumpPower = v end
    end
end)
AddCategory("Move","TELEPORTS")
AddTP("Move","GUN SHOP", COORDS.GUN_SHOP)
AddTP("Move","BANK", COORDS.BANK_ENT)
AddTP("Move","SAFE ZONE", COORDS.SAFE_ZONE)

-- MISC TAB
AddCategory("Misc","SURVIVAL")
AddToggle("Misc","AUTO SAFE HP","AutoSafe")
AddToggle("Misc","AUTO HEAL", "Heal")
AddToggle("Misc","AUTO ARMOR", "Armor")
AddCategory("Misc","FARM & VISUALS")
AddToggle("Misc","AUTO FARM","Farm")
AddToggle("Misc","FULLBRIGHT","Fullbright",
    function() EnableFullbright() end,
    function() DisableFullbright() end)
AddToggle("Misc","FPS BOOST","FPSBoost",function() ApplyFPS() end)
AddCategory("Misc","UTILITIES")
AddToggle("Misc","ANTI-SEAT","AntiSeat")
AddToggle("Misc","ANTI-AFK", "AntiAFK")
AddCategory("Misc","ACTIONS")
AddAction("Misc","🏦 AUTO ROB BANK",Color3.fromRGB(150,20,20),StartRobbery)

-- ============================================================
-- ITEMS TAB — Item Picker with Search
-- ============================================================
AddCategory("Items","ITEM PICKER")

-- Info label
local itemInfoF = Instance.new("Frame", Scroll)
itemInfoF.Size = UDim2.new(0.97, 0, 0, IsMobile and 36 or 28)
itemInfoF.BackgroundColor3 = Color3.fromRGB(12, 12, 22)
itemInfoF.BorderSizePixel = 0; itemInfoF.Visible = false
Instance.new("UICorner", itemInfoF)
table.insert(Sections["Items"], itemInfoF)
local itemInfoL = Instance.new("TextLabel", itemInfoF)
itemInfoL.Size = UDim2.new(1, 0, 1, 0); itemInfoL.BackgroundTransparency = 1
itemInfoL.TextColor3 = Color3.fromRGB(120, 160, 255)
itemInfoL.Font = Enum.Font.Gotham; itemInfoL.TextSize = IsMobile and 9 or 10
itemInfoL.TextWrapped = true
itemInfoL.Text = "🔍 Пошук предметів. Зелений = збирає, Червоний = ігнорує"

-- Search box
local searchFrame = Instance.new("Frame", Scroll)
searchFrame.Size = UDim2.new(0.97, 0, 0, IsMobile and 38 or 34)
searchFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 26)
searchFrame.BorderSizePixel = 0; searchFrame.Visible = false
Instance.new("UICorner", searchFrame)
table.insert(Sections["Items"], searchFrame)

local searchBox = Instance.new("TextBox", searchFrame)
searchBox.Size = UDim2.new(0.65, -4, 0, IsMobile and 28 or 24)
searchBox.Position = UDim2.new(0, 6, 0.5, IsMobile and -14 or -12)
searchBox.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
searchBox.PlaceholderText = "🔍 Search items..."
searchBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 130)
searchBox.Font = Enum.Font.Gotham; searchBox.TextSize = IsMobile and 11 or 12
searchBox.ClearTextOnFocus = false; searchBox.BorderSizePixel = 0
Instance.new("UICorner", searchBox)

local enableAllBtn = Instance.new("TextButton", searchFrame)
enableAllBtn.Size = UDim2.new(0.15, 0, 0, IsMobile and 28 or 24)
enableAllBtn.Position = UDim2.new(0.66, 2, 0.5, IsMobile and -14 or -12)
enableAllBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 50)
enableAllBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
enableAllBtn.Font = Enum.Font.GothamBold; enableAllBtn.TextSize = IsMobile and 9 or 10
enableAllBtn.Text = "ALL ✓"; enableAllBtn.BorderSizePixel = 0
Instance.new("UICorner", enableAllBtn)

local disableAllBtn = Instance.new("TextButton", searchFrame)
disableAllBtn.Size = UDim2.new(0.15, 0, 0, IsMobile and 28 or 24)
disableAllBtn.Position = UDim2.new(0.83, 2, 0.5, IsMobile and -14 or -12)
disableAllBtn.BackgroundColor3 = Color3.fromRGB(150, 30, 30)
disableAllBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
disableAllBtn.Font = Enum.Font.GothamBold; disableAllBtn.TextSize = IsMobile and 9 or 10
disableAllBtn.Text = "ALL ✗"; disableAllBtn.BorderSizePixel = 0
Instance.new("UICorner", disableAllBtn)

-- Item buttons container
local itemButtons = {} -- {frame, btn, itemName}

for _, itemName in ipairs(ALL_ITEMS) do
    local f = Instance.new("Frame", Scroll)
    f.Size = UDim2.new(0.97, 0, 0, IsMobile and 30 or 28)
    f.BackgroundTransparency = 1; f.BorderSizePixel = 0; f.Visible = false
    table.insert(Sections["Items"], f)

    local btn = Instance.new("TextButton", f)
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.Font = Enum.Font.GothamBold; btn.TextSize = IsMobile and 10 or 11
    btn.BorderSizePixel = 0; btn.AutoButtonColor = false
    btn.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", btn)

    local enabled = ItemPickerState[itemName] ~= false

    local function UpdateItemBtn()
        if ItemPickerState[itemName] then
            btn.BackgroundColor3 = Color3.fromRGB(10, 60, 30)
            btn.TextColor3 = Color3.fromRGB(100, 255, 130)
            btn.Text = "  ✓ " .. itemName
        else
            btn.BackgroundColor3 = Color3.fromRGB(50, 15, 15)
            btn.TextColor3 = Color3.fromRGB(255, 120, 120)
            btn.Text = "  ✗ " .. itemName
        end
    end
    UpdateItemBtn()

    btn.MouseButton1Click:Connect(function()
        ItemPickerState[itemName] = not ItemPickerState[itemName]
        UpdateItemBtn()
        SaveSettings(Config, ItemPickerState)
    end)

    table.insert(itemButtons, {frame = f, btn = btn, itemName = itemName, update = UpdateItemBtn})
end

-- Search filtering
local function FilterItems(query)
    local q = query:lower()
    for _, entry in pairs(itemButtons) do
        local match = q == "" or entry.itemName:lower():find(q, 1, true)
        entry.frame.Visible = (ActiveTab == "Items") and (match and true or false)
    end
    task.wait()
    Scroll.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 10)
end

searchBox:GetPropertyChangedSignal("Text"):Connect(function()
    FilterItems(searchBox.Text)
end)

enableAllBtn.MouseButton1Click:Connect(function()
    local q = searchBox.Text:lower()
    for _, entry in pairs(itemButtons) do
        local match = q == "" or entry.itemName:lower():find(q, 1, true)
        if match then
            ItemPickerState[entry.itemName] = true
            entry.update()
        end
    end
    SaveSettings(Config, ItemPickerState)
    Notify("ITEMS", "Всі видимі = ON ✓", 1.5)
end)

disableAllBtn.MouseButton1Click:Connect(function()
    local q = searchBox.Text:lower()
    for _, entry in pairs(itemButtons) do
        local match = q == "" or entry.itemName:lower():find(q, 1, true)
        if match then
            ItemPickerState[entry.itemName] = false
            entry.update()
        end
    end
    SaveSettings(Config, ItemPickerState)
    Notify("ITEMS", "Всі видимі = OFF ✗", 1.5)
end)

-- Override ShowTab to handle item filtering
local origShowTab = ShowTab
ShowTab = function(name)
    ActiveTab = name
    for n, frames in pairs(Sections) do
        if n == "Items" then
            -- Items tab: show/hide based on search
            for _, f in pairs(frames) do
                pcall(function() f.Visible = (n == name) end)
            end
            if name == "Items" then
                FilterItems(searchBox.Text)
            end
        else
            for _, f in pairs(frames) do pcall(function() f.Visible = (n == name) end) end
        end
    end
    for n, btn in pairs(TabButtons) do
        if n == name then
            btn.BackgroundColor3 = Color3.fromRGB(0, 100, 220)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            btn.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
            btn.TextColor3 = Color3.fromRGB(150, 150, 170)
        end
    end
    task.wait()
    Scroll.CanvasPosition = Vector2.zero
    Scroll.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 10)
end

-- ============================================================
-- BINDS TAB
-- ============================================================
local bindActions = {
    {key="Fly", name="FLY"},
    {key="AimActive", name="AIM LOCK"},
    {key="Noclip", name="NOCLIP"},
    {key="SilentAim", name="SILENT AIM"},
    {key="ToggleUI", name="TOGGLE UI"},
}

local infoF = Instance.new("Frame", Scroll)
infoF.Size = UDim2.new(0.97,0,0,IsMobile and 36 or 26)
infoF.BackgroundColor3 = Color3.fromRGB(12,12,22)
infoF.BorderSizePixel = 0; infoF.Visible = false
Instance.new("UICorner", infoF)
table.insert(Sections["Binds"], infoF)
local infoL = Instance.new("TextLabel", infoF)
infoL.Size = UDim2.new(1,0,1,0); infoL.BackgroundTransparency = 1
infoL.TextColor3 = Color3.fromRGB(120,160,255)
infoL.Font = Enum.Font.Gotham; infoL.TextSize = IsMobile and 10 or 11
infoL.TextWrapped = true
infoL.Text = "Натисни кнопку → натисни клавішу → збережено"

AddCategory("Binds","CUSTOM BINDS")

local BindBtns = {}

local function AddBindRow(tabName, actionKey, actionName)
    local f = Instance.new("Frame", Scroll)
    f.Size = UDim2.new(0.97,0,0,IsMobile and 40 or 36)
    f.BackgroundColor3 = Color3.fromRGB(16,16,26)
    f.BorderSizePixel = 0; f.Visible = false
    Instance.new("UICorner", f)
    table.insert(Sections[tabName], f)
    local nameLbl = Instance.new("TextLabel", f)
    nameLbl.Size = UDim2.new(0.52,0,1,0)
    nameLbl.Position = UDim2.new(0,10,0,0)
    nameLbl.BackgroundTransparency = 1
    nameLbl.TextColor3 = Color3.fromRGB(200,200,210)
    nameLbl.Font = Enum.Font.GothamBold; nameLbl.TextSize = IsMobile and 11 or 13
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left; nameLbl.Text = actionName
    local bindBtn = Instance.new("TextButton", f)
    bindBtn.Size = UDim2.new(0.4,0,0,IsMobile and 28 or 24)
    bindBtn.Position = UDim2.new(0.56,0,0.5,IsMobile and -14 or -12)
    bindBtn.BackgroundColor3 = Color3.fromRGB(22,22,38)
    bindBtn.TextColor3 = Color3.fromRGB(170,200,255)
    bindBtn.Font = Enum.Font.GothamBold; bindBtn.TextSize = IsMobile and 10 or 11
    bindBtn.BorderSizePixel = 0; bindBtn.AutoButtonColor = false
    local curBind = Binds[actionKey]
    bindBtn.Text = curBind and tostring(curBind):gsub("Enum%.KeyCode%.","") or "NONE"
    Instance.new("UICorner", bindBtn)
    local bSt = Instance.new("UIStroke", bindBtn)
    bSt.Color = Color3.fromRGB(0,100,200); bSt.Thickness = 1
    BindBtns[actionKey] = bindBtn
    bindBtn.MouseButton1Click:Connect(function()
        if waitingForBind then return end
        waitingForBind = actionKey
        bindBtn.Text = "[ Press key ]"
        bindBtn.TextColor3 = Color3.fromRGB(255,220,50)
        Notify("BIND","Натисни клавішу для: "..actionName,3)
    end)
end

for _, entry in pairs(bindActions) do
    AddBindRow("Binds", entry.key, entry.name)
end

-- ============================================================
-- INPUT HANDLER
-- ============================================================
UIS.InputBegan:Connect(function(inp, gpe)
    if waitingForBind then
        if inp.UserInputType == Enum.UserInputType.Keyboard then
            local action = waitingForBind
            Binds[action] = inp.KeyCode
            if BindBtns[action] then
                BindBtns[action].Text = tostring(inp.KeyCode):gsub("Enum%.KeyCode%.","")
                BindBtns[action].TextColor3 = Color3.fromRGB(170,200,255)
            end
            Notify("BIND",(BindNames[action] or action).." → "..
                tostring(inp.KeyCode):gsub("Enum%.KeyCode%.",""),2)
            waitingForBind = nil
            SaveSettings(Config, ItemPickerState)
        end
        return
    end
    if gpe then return end
    for action, key in pairs(Binds) do
        if inp.KeyCode ~= key then continue end
        if action == "ToggleUI" then
            Main.Visible = not Main.Visible
            if Main.Visible then Notify("Markiyan PRO","Меню ✓",1) end
        elseif action == "Fly" then
            Config.Fly = not Config.Fly
            if UpdFuncs.Fly then UpdFuncs.Fly(Config.Fly) end
            UpdateFlyBtns()
            if not Config.Fly then
                local hum=GetHum()
                if hum then hum.PlatformStand=false; hum.WalkSpeed=16 end
            end
            Notify("FLY",Config.Fly and "ON ✓" or "OFF ✗",1.5)
        elseif action == "AimActive" then
            Config.AimActive = not Config.AimActive
            if UpdFuncs.AimActive then UpdFuncs.AimActive(Config.AimActive) end
            aimTarget=nil; aimLocked=false; aimLostFrames=0
            if Config.AimActive then aimLastSwitch=0 end
            Notify("AIM LOCK",Config.AimActive and "ON ✓" or "OFF ✗",1.5)
        elseif action == "Noclip" then
            Config.Noclip = not Config.Noclip
            if UpdFuncs.Noclip then UpdFuncs.Noclip(Config.Noclip) end
            if not Config.Noclip then RestoreCollision() end
            Notify("NOCLIP",Config.Noclip and "ON ✓" or "OFF ✗",1.5)
        elseif action == "SilentAim" then
            Config.SilentAim = not Config.SilentAim
            if UpdFuncs.SilentAim then UpdFuncs.SilentAim(Config.SilentAim) end
            Notify("SILENT AIM",Config.SilentAim and "ON ✓" or "OFF ✗",1.5)
        end
    end
end)

-- ============================================================
-- M BUTTON (FIXED - no overlap)
-- ============================================================
local MBtnSz = IsMobile and 52 or 42
local MBtn = Instance.new("TextButton", SG)
MBtn.Size = UDim2.new(0, MBtnSz, 0, MBtnSz)
MBtn.Position = UDim2.new(0, 10, 0.28, 0)
MBtn.Text = "M"; MBtn.Font = Enum.Font.GothamBlack
MBtn.TextSize = IsMobile and 22 or 18
MBtn.BackgroundColor3 = Color3.fromRGB(0, 80, 200)
MBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MBtn.BorderSizePixel = 0; MBtn.AutoButtonColor = false; MBtn.ZIndex = 100
Instance.new("UICorner", MBtn)
local mStroke = Instance.new("UIStroke", MBtn)
mStroke.Color = Color3.fromRGB(255, 255, 255); mStroke.Thickness = 2

task.spawn(function()
    while true do
        TweenService:Create(MBtn,TweenInfo.new(1.6),
            {BackgroundColor3=Color3.fromRGB(0,40,160)}):Play()
        task.wait(1.6)
        TweenService:Create(MBtn,TweenInfo.new(1.6),
            {BackgroundColor3=Color3.fromRGB(0,110,255)}):Play()
        task.wait(1.6)
    end
end)

do
    local mDrag,mStart,mPos,mTick,mMoved=false,nil,nil,0,false
    MBtn.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1
            or inp.UserInputType==Enum.UserInputType.Touch then
            mDrag=true; mStart=inp.Position
            mPos=MBtn.Position; mTick=tick(); mMoved=false
        end
    end)
    MBtn.InputChanged:Connect(function(inp)
        if not mDrag then return end
        if inp.UserInputType==Enum.UserInputType.MouseMovement
            or inp.UserInputType==Enum.UserInputType.Touch then
            local d=inp.Position-mStart
            if d.Magnitude>6 then mMoved=true end
            MBtn.Position=UDim2.new(mPos.X.Scale,mPos.X.Offset+d.X,
                mPos.Y.Scale,mPos.Y.Offset+d.Y)
        end
    end)
    MBtn.InputEnded:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1
            or inp.UserInputType==Enum.UserInputType.Touch then
            if mDrag and not mMoved and tick()-mTick<0.28 then
                Main.Visible=not Main.Visible
                if Main.Visible then Notify("Markiyan PRO","Меню ✓",1) end
            end
            mDrag=false
        end
    end)
    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1
            or inp.UserInputType==Enum.UserInputType.Touch then mDrag=false end
    end)
end

-- ============================================================
-- START
-- ============================================================
ShowTab("Combat")

-- Apply saved states that need callbacks
if Config.Fullbright then EnableFullbright() end
if Config.FPSBoost then ApplyFPS() end
if Config.HighJump then
    local hum = GetHum()
    if hum then hum.JumpPower = Config.JumpPowerValue end
end

Notify("⚡ Markiyan PRO V51",
    IsMobile
        and "📱 +ItemPicker +KillAura +HighJump +Save ✓"
        or "M=меню | +ItemPicker +KillAura +HighJump +Save ✓", 5)