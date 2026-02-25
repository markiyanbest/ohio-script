-- markiyanbest's script (V48 - FIXED & OPTIMIZED)
local Players      = game:GetService("Players")
local lp           = Players.LocalPlayer
local RS           = game:GetService("RunService")
local Light        = game:GetService("Lighting")
local UIS          = game:GetService("UserInputService")
local VirtualUser  = game:GetService("VirtualUser")
local Camera       = workspace.CurrentCamera
local StarterGui   = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")

local IsMobile = UIS.TouchEnabled
local IsPC     = not IsMobile

-- Cleanup old GUIs
pcall(function()
    for _, sg in pairs({game:GetService("CoreGui"), lp:WaitForChild("PlayerGui")}) do
        for _, v in pairs(sg:GetChildren()) do
            if v:IsA("ScreenGui") and v.Name == "MarkiyanPro" then v:Destroy() end
        end
    end
end)

-- Mobile optimization
if IsMobile then
    pcall(function()
        settings().Rendering.QualityLevel = 1
        Light.GlobalShadows = false
        Light.FogEnd        = 9e9
        Light.Brightness    = 1
        Light.ClockTime     = 14
    end)
    for _, v in pairs(Light:GetChildren()) do
        if v:IsA("BloomEffect") or v:IsA("BlurEffect")
        or v:IsA("SunRaysEffect") or v:IsA("DepthOfFieldEffect")
        or v:IsA("ColorCorrectionEffect") then
            pcall(function() v.Enabled = false end)
        end
    end
end

local COORDS = {
    GUN_SHOP   = Vector3.new(1131, 25, -1344),
    BANK_ENT   = Vector3.new(1106, 8,  -336),
    BANK_MONEY = Vector3.new(1110, 8,  -325),
    SAFE_ZONE  = Vector3.new(-37, -27,  3),
}

-- ============================================================
-- CONFIG
-- ============================================================
local Config = {
    Farm           = false,
    Speed          = false,
    Armor          = false,
    Heal           = false,
    AimActive      = false,
    FPSBoost       = false,
    AntiSeat       = false,
    AntiAFK        = false,
    Fly            = false,
    FlySpeedValue  = IsMobile and 35 or 50,
    WalkSpeedValue = IsMobile and 45 or 65,
    ESP            = false,
    InfJump        = false,
    Noclip         = false,
    Magnet         = false,
    MagnetTarget   = nil,
    AutoSafe       = false,
    SafeHealth     = 35,
    SilentAim      = false,
    AimFOV         = 200,
    AimSmooth      = 0.18,
    AimPart        = "Head",
}

local Binds = {
    Fly       = Enum.KeyCode.F,
    AimActive = Enum.KeyCode.G,
    Noclip    = Enum.KeyCode.V,
    SilentAim = Enum.KeyCode.B,
    ToggleUI  = Enum.KeyCode.M,
}

local BindNames = {
    Fly       = "FLY",
    AimActive = "AIM LOCK",
    Noclip    = "NOCLIP",
    SilentAim = "SILENT AIM",
    ToggleUI  = "TOGGLE UI",
}

local waitingForBind = nil

-- ============================================================
-- LOOT TABLES
-- ============================================================
local LootCache = {
    ["medkit"]=true,["bandage"]=true,["pistol"]=true,["rifle"]=true,
    ["shotgun"]=true,["smg"]=true,["lmg"]=true,["armor"]=true,
    ["vest"]=true,["money"]=true,["cash"]=true,["drug"]=true,
    ["cocaine"]=true,["weed"]=true,["ammo"]=true,["weapon"]=true,
}

-- ============================================================
-- BLACKLIST (повний блок)
-- ============================================================
local BlacklistCache = {
    -- базовий блок
    ["spawn"]=true,
    ["door"]=true,
    ["gate"]=true,
    ["sign"]=true,
    ["barrier"]=true,
    ["edit"]=true,
    ["open"]=true,
    ["close"]=true,
    ["vending"]=true,
    ["workbench"]=true,
    ["press"]=true,
    ["turn"]=true,
    -- unlock / cash earned повний блок
    ["unlock after"]=true,
    ["cash earned"]=true,
    ["1m cash"]=true,
    ["2.5"]=true,
    ["2.5m"]=true,
    ["1m"]=true,
    ["unlocks at"]=true,
    ["requires"]=true,
    ["locked until"]=true,
    ["need cash"]=true,
    ["purchase"]=true,
    ["buy to"]=true,
    ["buy for"]=true,
    ["premium"]=true,
    ["vip"]=true,
    ["members only"]=true,
    ["robux"]=true,
    ["locked"]=true,
    ["lock"]=true,
    ["earned"]=true,
    ["after"]=true,
}

-- Повний список pattern блоків для авто фарму
local HardBlockPatterns = {
    "unlock after",
    "cash earned",
    "unlocks at",
    "locked until",
    "locked",
    "requires %d",
    "need %d",
    "purchase to",
    "buy for",
    "premium only",
    "vip only",
    "members only",
    "robux",
    "%d+%.%d+m",   -- 2.5m / 1.5m / 0.5m
    "%d+m cash",   -- 1m cash / 2m cash
    "%d+m earned", -- 1m earned
    "%d+k cash",   -- 500k cash
    "%d+k earned", -- 100k earned
    "after %d",    -- after 2.5
    "after earning",
    "earn %d",
    "%.5m",        -- .5m
    "2%.5",        -- 2.5
    "1%.0",        -- 1.0m
}

-- ============================================================
-- UTILITIES
-- ============================================================
local function Notify(title, text, dur)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title    = title,
            Text     = text,
            Duration = dur or 2,
        })
    end)
end

local function GetChar()  return lp.Character end
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
    pcall(function()
        char:PivotTo(CFrame.new(pos + Vector3.new(0, 3, 0)))
    end)
    return true
end

local function IsTargetAlive(target)
    if not target or not target.Parent then return false end
    local char = target.Character
    if not char then return false end
    local h = char:FindFirstChildOfClass("Humanoid")
    return h and h.Health > 0
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
    local dir    = target - origin
    local dist   = dir.Magnitude
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

local aimTarget     = nil
local aimLocked     = false
local aimLastSwitch = 0
local aimSwitchCD   = 0.35
local aimLostFrames = 0
local lastPing      = 0
local pingTick      = 0

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
                    local sd  = ScreenDist(part)
                    local vis = IsVisible(char)
                    if sd <= fov * 1.8 and vis then
                        aimLostFrames = 0
                        return char
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
        aimTarget     = best
        aimLocked     = true
        aimLostFrames = 0
        aimLastSwitch = now
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
local function DoSilentAim()
    if not Config.SilentAim then return end
    local now = tick()
    if now - lastSilentT < (IsMobile and 0.05 or 0.016) then return end
    lastSilentT = now
    if not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then return end
    local tgtChar = GetBestAimTarget()
    if not tgtChar then return end
    local head = FindAimPart(tgtChar)
    if not head then return end
    Camera.CFrame = Camera.CFrame:Lerp(
        CFrame.new(Camera.CFrame.Position, head.Position),
        IsMobile and 0.35 or 0.45
    )
end

-- ============================================================
-- FPS BOOST
-- ============================================================
local fpsApplied = false
local function ApplyFPS()
    if fpsApplied then Notify("FPS BOOST","Вже застосовано",2); return end
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
            or v:IsA("ColorCorrectionEffect") then
                v.Enabled = false
            end
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
-- AUTO HEAL / ARMOR
-- ============================================================
local healCooldown = 0

task.spawn(function()
    while task.wait(IsMobile and 1.5 or 0.8) do
        if not IsHumAlive() then continue end
        local now = tick()
        if now - healCooldown < 2 then continue end

        local hum  = GetHum()
        local char = GetChar()
        if not hum or not char then continue end

        local function TryUseItem(keywords)
            local found = nil
            for _, item in pairs(lp.Backpack:GetChildren()) do
                local n = item.Name:lower()
                for _, kw in pairs(keywords) do
                    if n:find(kw, 1, true) then found = item; break end
                end
                if found then break end
            end
            if not found then
                for _, item in pairs(char:GetChildren()) do
                    if item:IsA("Tool") then
                        local n = item.Name:lower()
                        for _, kw in pairs(keywords) do
                            if n:find(kw, 1, true) then found = item; break end
                        end
                    end
                    if found then break end
                end
            end
            if not found then return end
            pcall(function()
                if found.Parent == lp.Backpack then
                    hum:EquipTool(found)
                    task.wait(0.2)
                end
                local tool = char:FindFirstChild(found.Name)
                if tool then tool:Activate() end
            end)
            task.wait(0.6)
            pcall(function() hum:UnequipTools() end)
            healCooldown = tick()
        end

        if Config.Heal and hum.Health < hum.MaxHealth * 0.75 then
            TryUseItem({"medkit","bandage","firstaid","aid"})
        end
        if Config.Armor then
            TryUseItem({"armor","vest","helmet"})
        end
    end
end)

-- ============================================================
-- ANTI-AFK
-- ============================================================
lp.Idled:Connect(function()
    if Config.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)
task.spawn(function()
    while task.wait(55) do
        if Config.AntiAFK then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end
    end
end)

-- ============================================================
-- AUTO ROB
-- ============================================================
local function StartRobbery()
    Notify("BANK ROB","Починаємо...",2)
    if not SafeTeleport(COORDS.BANK_MONEY) then
        Notify("BANK ROB","Помилка телепорту!",2)
        return
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
                        fireproximityprompt(v)
                    end
                end
            end
        end)
        task.wait(0.5)
    end
    SafeTeleport(COORDS.SAFE_ZONE)
    Notify("BANK ROB","Готово! ✓",3)
end

-- ============================================================
-- ESP
-- ============================================================
local ESPCache = {}

local function ClearESP(char)
    if not char then return end
    local head = char:FindFirstChild("Head")
    if head then
        local g = head:FindFirstChild("MrkESP")
        if g then g:Destroy() end
    end
    local hl = char:FindFirstChild("MrkHL")
    if hl then hl:Destroy() end
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
            local hum  = char and char:FindFirstChildOfClass("Humanoid")
            if not char or not head or not hum or hum.Health <= 0 then
                if ESPCache[v] then ClearESP(char); ESPCache[v] = nil end
                continue
            end
            local cache = ESPCache[v]
            if not cache or not cache.gui or not cache.gui.Parent then
                if cache then ClearESP(char) end
                local gui = Instance.new("BillboardGui")
                gui.Name        = "MrkESP"
                gui.Size        = UDim2.new(0, IsMobile and 150 or 185, 0, IsMobile and 42 or 50)
                gui.StudsOffset = Vector3.new(0, 3.2, 0)
                gui.AlwaysOnTop = true
                gui.MaxDistance = IsMobile and 250 or 450
                gui.Parent      = head
                local bg = Instance.new("Frame", gui)
                bg.Size                   = UDim2.new(1, 0, 1, 0)
                bg.BackgroundColor3       = Color3.fromRGB(0, 0, 0)
                bg.BackgroundTransparency = 0.45
                bg.BorderSizePixel        = 0
                Instance.new("UICorner", bg)
                local lbl = Instance.new("TextLabel", bg)
                lbl.Name                   = "L"
                lbl.Size                   = UDim2.new(1, 0, 1, 0)
                lbl.BackgroundTransparency = 1
                lbl.Font                   = Enum.Font.GothamBold
                lbl.TextSize               = IsMobile and 10 or 12
                lbl.TextWrapped            = true
                lbl.TextStrokeTransparency = 0.3
                if IsPC then
                    local hl = Instance.new("Highlight")
                    hl.Name                = "MrkHL"
                    hl.FillColor           = Color3.new(1, 0, 0)
                    hl.OutlineColor        = Color3.new(1, 1, 1)
                    hl.FillTransparency    = 0.65
                    hl.OutlineTransparency = 0
                    hl.Parent              = char
                end
                ESPCache[v] = {gui = gui, lbl = lbl}
                cache = ESPCache[v]
            end
            local dist  = myRoot and math.floor((myRoot.Position - head.Position).Magnitude) or 0
            local hp    = math.floor(hum.Health)
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

-- ============================================================
-- NOCLIP
-- ============================================================
local function RestoreCollision()
    local char = GetChar()
    if not char then return end
    for _, v in pairs(char:GetDescendants()) do
        if v:IsA("BasePart") then v.CanCollide = true end
    end
end

-- ============================================================
-- AUTO FARM (повний блок перевірки)
-- ============================================================
local function IsBlocked(text)
    -- Перевірка 1: точний збіг у BlacklistCache
    for kw in pairs(BlacklistCache) do
        if text:find(kw, 1, true) then
            return true
        end
    end
    -- Перевірка 2: pattern блок (unlock/cash earned/числа)
    for _, pattern in pairs(HardBlockPatterns) do
        if text:find(pattern) then
            return true
        end
    end
    return false
end

local farmRunning = false
task.spawn(function()
    while task.wait(IsMobile and 1.0 or 0.5) do
        if not Config.Farm or farmRunning then continue end
        if not IsHumAlive() then continue end
        farmRunning = true
        pcall(function()
            for _, v in pairs(workspace:GetDescendants()) do
                if not Config.Farm then break end
                if not v:IsA("ProximityPrompt") or not v.Enabled then continue end

                -- Збираємо весь текст промпту
                local text = (
                    v.Parent.Name .. " " ..
                    v.ActionText  .. " " ..
                    v.ObjectText
                ):lower()

                -- Перевірка whitelist
                local ok = false
                for kw in pairs(LootCache) do
                    if text:find(kw, 1, true) then ok = true; break end
                end

                -- Повна перевірка блоку
                if ok and IsBlocked(text) then
                    ok = false
                end

                if ok then
                    SafeTeleport(v.Parent:GetPivot().Position)
                    task.wait(IsMobile and 0.4 or 0.25)
                    pcall(function() fireproximityprompt(v) end)
                    task.wait(IsMobile and 0.3 or 0.2)
                end
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
        local part   = target and FindAimPart(target)
        if part then
            local predTime  = math.clamp(lastPing, 0.01, 0.2)
            local vel       = part.AssemblyLinearVelocity
            local dist      = (Camera.CFrame.Position - part.Position).Magnitude
            local predMul   = math.clamp(dist / 100, 0.3, 1.5)
            local predicted = part.Position + vel * predTime * predMul
            local smooth    = Config.AimSmooth
            local sd        = ScreenDist(part)
            if sd < 30 then smooth = smooth * 0.3
            elseif sd < 80 then smooth = smooth * 0.6 end
            Camera.CFrame = Camera.CFrame:Lerp(
                CFrame.new(Camera.CFrame.Position, predicted), smooth)
        end
    else
        aimTarget = nil; aimLocked = false; aimLostFrames = 0
    end

    if Config.Fly and IsHumAlive() then
        local root = GetRoot()
        local hum  = GetHum()
        if root and hum then
            hum.PlatformStand = false
            local moveX, moveZ = 0, 0
            if IsMobile and Controls then
                local mv = Controls:GetMoveVector()
                moveX = mv.X; moveZ = mv.Z
            elseif IsPC then
                if UIS:IsKeyDown(Enum.KeyCode.W) then moveZ = -1 end
                if UIS:IsKeyDown(Enum.KeyCode.S) then moveZ =  1 end
                if UIS:IsKeyDown(Enum.KeyCode.A) then moveX = -1 end
                if UIS:IsKeyDown(Enum.KeyCode.D) then moveX =  1 end
            end
            local camCF = Camera.CFrame
            local dir   = camCF.LookVector * -moveZ + camCF.RightVector * moveX
            local upD   = 0
            if UIS:IsKeyDown(Enum.KeyCode.Space) or MobUp       then upD =  1 end
            if UIS:IsKeyDown(Enum.KeyCode.LeftControl) or MobDn then upD = -1 end
            dir = dir + Vector3.new(0, upD, 0)
            if dir.Magnitude > 1 then dir = dir.Unit end
            root.CFrame += dir * Config.FlySpeedValue * dt
            root.AssemblyLinearVelocity  = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
        end
    end
end)

-- ============================================================
-- HEARTBEAT
-- ============================================================
RS.Heartbeat:Connect(function(dt)
    local hum  = GetHum()
    local root = GetRoot()
    if not hum or not root then return end

    if Config.AntiSeat and hum.SeatPart then hum.Sit = false end

    if Config.Speed and not Config.Fly and IsHumAlive() then
        hum.WalkSpeed = Config.WalkSpeedValue
    elseif not Config.Fly and not Config.Speed then
        if hum.WalkSpeed ~= 16 then hum.WalkSpeed = 16 end
    end

    if not Config.Fly then
        if hum.PlatformStand then hum.PlatformStand = false end
    end

    if Config.Noclip then
        local char = GetChar()
        if char then
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
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
                root.CFrame = root.CFrame:Lerp(
                    tHRP.CFrame * CFrame.new(0, 0, 3),
                    IsMobile and 0.15 or 0.22
                )
                root.AssemblyLinearVelocity = tHRP.AssemblyLinearVelocity
            end
        end
    else
        Config.MagnetTarget = nil
    end

    if Config.AutoSafe and IsHumAlive() and hum.Health <= Config.SafeHealth then
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
    if Config.InfJump then
        local hum = GetHum()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- ============================================================
-- CLEANUP ON RESPAWN
-- ============================================================
lp.CharacterRemoving:Connect(function()
    Config.Fly    = false
    Config.Noclip = false
    aimTarget = nil; aimLocked = false; aimLostFrames = 0
end)

lp.CharacterAdded:Connect(function(char)
    Config.Fly    = false
    Config.Noclip = false
    Config.Magnet = false
    aimTarget = nil; aimLocked = false; aimLostFrames = 0
    task.wait(1)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then hum.PlatformStand = false; hum.WalkSpeed = 16 end
end)

-- ============================================================
-- GUI
-- ============================================================
local SG = Instance.new("ScreenGui")
SG.Name           = "MarkiyanPro"
SG.ResetOnSpawn   = false
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() SG.Parent = game:GetService("CoreGui") end)
if not SG.Parent or not SG.Parent.Name then
    SG.Parent = lp:WaitForChild("PlayerGui")
end

local MW = IsMobile and 252 or 385
local MH = IsMobile and 475 or 620

local Main = Instance.new("Frame", SG)
Main.Size             = UDim2.new(0, MW, 0, MH)
Main.AnchorPoint      = Vector2.new(0.5, 0.5)
Main.Position         = UDim2.new(0.5, 0, 0.5, 0)
Main.BackgroundColor3 = Color3.fromRGB(8, 8, 14)
Main.BorderSizePixel  = 0
Main.Visible          = false
Instance.new("UICorner", Main)
local mainStroke = Instance.new("UIStroke", Main)
mainStroke.Color     = Color3.fromRGB(0, 120, 255)
mainStroke.Thickness = 2

local Header = Instance.new("Frame", Main)
Header.Size             = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
Header.BorderSizePixel  = 0
Instance.new("UICorner", Header)
local HGrad = Instance.new("UIGradient", Header)
HGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,   Color3.fromRGB(0,  50, 180)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 130, 255)),
    ColorSequenceKeypoint.new(1,   Color3.fromRGB(0,  50, 180)),
})
local HeaderLbl = Instance.new("TextLabel", Header)
HeaderLbl.Size                   = UDim2.new(1, -36, 1, 0)
HeaderLbl.BackgroundTransparency = 1
HeaderLbl.TextColor3             = Color3.fromRGB(255, 255, 255)
HeaderLbl.Font                   = Enum.Font.GothamBlack
HeaderLbl.TextSize               = IsMobile and 13 or 15
HeaderLbl.Text                   = "⚡ Markiyan PRO V48" .. (IsMobile and " [MOB]" or "")

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size             = UDim2.new(0, 28, 0, 28)
CloseBtn.Position         = UDim2.new(1, -32, 0.5, -14)
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
CloseBtn.Text             = "✕"
CloseBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
CloseBtn.Font             = Enum.Font.GothamBold
CloseBtn.TextSize         = 13
CloseBtn.BorderSizePixel  = 0
CloseBtn.ZIndex           = 3
Instance.new("UICorner", CloseBtn)
CloseBtn.MouseButton1Click:Connect(function() Main.Visible = false end)

local TabBar = Instance.new("Frame", Main)
TabBar.Size             = UDim2.new(1, -8, 0, 28)
TabBar.Position         = UDim2.new(0, 4, 0, 44)
TabBar.BackgroundColor3 = Color3.fromRGB(12, 12, 20)
TabBar.BorderSizePixel  = 0
Instance.new("UICorner", TabBar)
local TabLayout = Instance.new("UIListLayout", TabBar)
TabLayout.FillDirection       = Enum.FillDirection.Horizontal
TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabLayout.VerticalAlignment   = Enum.VerticalAlignment.Center
TabLayout.Padding             = UDim.new(0, 3)

local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size                   = UDim2.new(1, -8, 1, -80)
Scroll.Position               = UDim2.new(0, 4, 0, 76)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness     = IsPC and 3 or 0
Scroll.ScrollBarImageColor3   = Color3.fromRGB(0, 120, 255)
Scroll.BorderSizePixel        = 0
Scroll.ClipsDescendants       = true

local ListLayout = Instance.new("UIListLayout", Scroll)
ListLayout.Padding             = UDim.new(0, 4)
ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local LP2 = Instance.new("UIPadding", Scroll)
LP2.PaddingTop    = UDim.new(0, 4)
LP2.PaddingBottom = UDim.new(0, 6)

ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Scroll.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 10)
end)

-- ============================================================
-- FOV CIRCLE
-- ============================================================
local fovCircle = Instance.new("Frame", SG)
fovCircle.Size                   = UDim2.new(0, Config.AimFOV*2, 0, Config.AimFOV*2)
fovCircle.Position               = UDim2.new(0.5, -Config.AimFOV, 0.5, -Config.AimFOV)
fovCircle.BackgroundTransparency = 1
fovCircle.BorderSizePixel        = 0
fovCircle.Visible                = false
fovCircle.ZIndex                 = 10
Instance.new("UICorner", fovCircle).CornerRadius = UDim.new(1, 0)
local fovStroke = Instance.new("UIStroke", fovCircle)
fovStroke.Color        = Color3.fromRGB(0, 120, 255)
fovStroke.Thickness    = 1.5
fovStroke.Transparency = 0.3

local tgtInfo = Instance.new("TextLabel", SG)
tgtInfo.Size                   = UDim2.new(0, 200, 0, 22)
tgtInfo.Position               = UDim2.new(0.5, -100, 0.5, -(Config.AimFOV + 32))
tgtInfo.BackgroundColor3       = Color3.fromRGB(10, 10, 16)
tgtInfo.BackgroundTransparency = 0.25
tgtInfo.BorderSizePixel        = 0
tgtInfo.TextColor3             = Color3.fromRGB(0, 200, 100)
tgtInfo.Font                   = Enum.Font.GothamBold
tgtInfo.TextSize               = 11
tgtInfo.Text                   = ""
tgtInfo.Visible                = false
tgtInfo.ZIndex                 = 12
Instance.new("UICorner", tgtInfo).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", tgtInfo).Color        = Color3.fromRGB(40, 40, 58)

local function UpdateFOVCircle()
    local r = Config.AimFOV
    fovCircle.Size     = UDim2.new(0, r*2, 0, r*2)
    fovCircle.Position = UDim2.new(0.5, -r, 0.5, -r)
    tgtInfo.Position   = UDim2.new(0.5, -100, 0.5, -(r + 32))
end

local fovUpdateTick = 0
RS.RenderStepped:Connect(function()
    local now = tick()
    if now - fovUpdateTick < 0.05 then return end
    fovUpdateTick = now
    fovCircle.Visible = Config.AimActive or Config.SilentAim
    tgtInfo.Visible   = false
    if Config.AimActive then
        local targetChar = aimTarget and aimTarget.Character
        local part = targetChar and FindAimPart(targetChar)
        if part and aimLocked then
            local plr  = Players:GetPlayerFromCharacter(targetChar)
            local dist = math.floor((Camera.CFrame.Position - part.Position).Magnitude)
            tgtInfo.Text       = "🔒 "..(plr and plr.Name or "?").." ["..dist.."m]"
            tgtInfo.TextColor3 = Color3.fromRGB(0, 230, 120)
            tgtInfo.Visible    = true
            fovStroke.Color    = Color3.fromRGB(0, 200, 100)
        else
            tgtInfo.Text       = "No target"
            tgtInfo.TextColor3 = Color3.fromRGB(120, 120, 145)
            tgtInfo.Visible    = true
            fovStroke.Color    = Color3.fromRGB(100, 100, 180)
        end
    elseif Config.SilentAim then
        local tgtChar = aimTarget and aimTarget.Character
        local part    = tgtChar and FindAimPart(tgtChar)
        if part then
            local plr  = Players:GetPlayerFromCharacter(tgtChar)
            local dist = math.floor((Camera.CFrame.Position - part.Position).Magnitude)
            tgtInfo.Text       = "🔇 "..(plr and plr.Name or "?").." ["..dist.."m]"
            tgtInfo.TextColor3 = Color3.fromRGB(255, 200, 50)
            tgtInfo.Visible    = true
            fovStroke.Color    = Color3.fromRGB(255, 200, 50)
        else
            tgtInfo.Text       = "No target"
            tgtInfo.TextColor3 = Color3.fromRGB(120, 120, 145)
            tgtInfo.Visible    = true
            fovStroke.Color    = Color3.fromRGB(100, 100, 180)
        end
    end
end)

-- ============================================================
-- MOBILE FLY BUTTONS
-- ============================================================
local flyHolder = Instance.new("Frame", SG)
flyHolder.Size                   = UDim2.new(0, 134, 0, 60)
flyHolder.Position               = UDim2.new(1, -148, 1, -76)
flyHolder.BackgroundTransparency = 1
flyHolder.Visible                = false
flyHolder.ZIndex                 = 50

local function MkFlyBtn(label, xOff, callback)
    local b = Instance.new("TextButton", flyHolder)
    b.Size             = UDim2.new(0, 60, 0, 56)
    b.Position         = UDim2.new(0, xOff, 0, 0)
    b.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
    b.Text             = label
    b.TextColor3       = Color3.fromRGB(255, 255, 255)
    b.Font             = Enum.Font.GothamBlack
    b.TextSize         = 26
    b.BorderSizePixel  = 0
    b.ZIndex           = 51
    b.AutoButtonColor  = false
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)
    Instance.new("UIStroke", b).Color        = Color3.fromRGB(40, 40, 58)
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
MkFlyBtn("▲", 0,  function(v) MobUp = v end)
MkFlyBtn("▼", 70, function(v) MobDn = v end)

local function UpdateFlyBtns()
    flyHolder.Visible = Config.Fly and IsMobile
end

-- ============================================================
-- TABS SYSTEM
-- ============================================================
local Sections   = {}
local TabButtons = {}
local ActiveTab  = nil

local function ShowTab(name)
    ActiveTab = name
    for n, frames in pairs(Sections) do
        for _, f in pairs(frames) do f.Visible = (n == name) end
    end
    for n, btn in pairs(TabButtons) do
        if n == name then
            btn.BackgroundColor3 = Color3.fromRGB(0, 100, 220)
            btn.TextColor3       = Color3.fromRGB(255, 255, 255)
        else
            btn.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
            btn.TextColor3       = Color3.fromRGB(150, 150, 170)
        end
    end
    task.wait()
    Scroll.CanvasPosition = Vector2.zero
    Scroll.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 10)
end

local tabNames = {"Combat","Movement","Misc","Binds"}
local tabW     = IsMobile and 52 or 74

for _, name in pairs(tabNames) do
    Sections[name] = {}
    local btn = Instance.new("TextButton", TabBar)
    btn.Size             = UDim2.new(0, tabW, 0, 22)
    btn.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
    btn.TextColor3       = Color3.fromRGB(150, 150, 170)
    btn.Font             = Enum.Font.GothamBold
    btn.TextSize         = IsMobile and 10 or 11
    btn.Text             = name
    btn.BorderSizePixel  = 0
    btn.AutoButtonColor  = false
    Instance.new("UICorner", btn)
    TabButtons[name] = btn
    btn.MouseButton1Click:Connect(function() ShowTab(name) end)
end

-- ============================================================
-- DRAGGABLE
-- ============================================================
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
            target.Position = UDim2.new(
                dPos.X.Scale, dPos.X.Offset + d.X,
                dPos.Y.Scale, dPos.Y.Offset + d.Y
            )
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
local BtnH     = IsMobile and 36 or 32
local UpdFuncs = {}
local Buttons  = {}

local function MakeFrame(tabName)
    local f = Instance.new("Frame", Scroll)
    f.Size                   = UDim2.new(0.97, 0, 0, BtnH)
    f.BackgroundTransparency = 1
    f.BorderSizePixel        = 0
    f.Visible                = false
    table.insert(Sections[tabName], f)
    return f
end

local function AddCategory(tabName, text)
    local f = Instance.new("Frame", Scroll)
    f.Size             = UDim2.new(0.97, 0, 0, 20)
    f.BackgroundColor3 = Color3.fromRGB(0, 55, 155)
    f.BorderSizePixel  = 0
    f.Visible          = false
    Instance.new("UICorner", f)
    local l = Instance.new("TextLabel", f)
    l.Size                   = UDim2.new(1, 0, 1, 0)
    l.BackgroundTransparency = 1
    l.TextColor3             = Color3.fromRGB(255, 255, 255)
    l.Font                   = Enum.Font.GothamBold
    l.TextSize               = 11
    l.Text                   = "── " .. text .. " ──"
    table.insert(Sections[tabName], f)
end

local function AddToggle(tabName, name, key, cbOn, cbOff)
    local f   = MakeFrame(tabName)
    local btn = Instance.new("TextButton", f)
    btn.Size             = UDim2.new(1, 0, 1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    btn.TextColor3       = Color3.fromRGB(190, 190, 200)
    btn.Font             = Enum.Font.GothamBold
    btn.TextSize         = IsMobile and 11 or 13
    btn.BorderSizePixel  = 0
    btn.AutoButtonColor  = false
    btn.TextXAlignment   = Enum.TextXAlignment.Left
    btn.Text             = "         " .. name .. ": OFF"
    Instance.new("UICorner", btn)
    local dot = Instance.new("Frame", btn)
    dot.Size             = UDim2.new(0, 8, 0, 8)
    dot.AnchorPoint      = Vector2.new(0, 0.5)
    dot.Position         = UDim2.new(0, 10, 0.5, 0)
    dot.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    dot.BorderSizePixel  = 0
    dot.ZIndex           = btn.ZIndex + 1
    Instance.new("UICorner", dot)
    Buttons[key] = btn
    local function Upd(state)
        if state then
            btn.BackgroundColor3 = Color3.fromRGB(0, 70, 190)
            btn.TextColor3       = Color3.fromRGB(255, 255, 255)
            dot.BackgroundColor3 = Color3.fromRGB(0, 220, 80)
            btn.Text             = "         " .. name .. ": ON"
        else
            btn.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
            btn.TextColor3       = Color3.fromRGB(190, 190, 200)
            dot.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            btn.Text             = "         " .. name .. ": OFF"
        end
    end
    UpdFuncs[key] = Upd
    btn.MouseButton1Click:Connect(function()
        Config[key] = not Config[key]
        Upd(Config[key])
        if Config[key] then
            if cbOn  then task.spawn(cbOn)  end
        else
            if cbOff then task.spawn(cbOff) end
        end
        if key == "Fly" then UpdateFlyBtns() end
        if key == "AimActive" and not Config[key] then
            aimTarget = nil; aimLocked = false; aimLostFrames = 0
        end
        Notify(name, Config[key] and "ON ✓" or "OFF ✗", 1.5)
    end)
    return Upd
end

local function AddSlider(tabName, label, minV, maxV, default, configKey, cb)
    local f = Instance.new("Frame", Scroll)
    f.Size             = UDim2.new(0.97, 0, 0, IsMobile and 50 or 52)
    f.BackgroundColor3 = Color3.fromRGB(16, 16, 24)
    f.BorderSizePixel  = 0
    f.Visible          = false
    Instance.new("UICorner", f)
    table.insert(Sections[tabName], f)
    local lbl = Instance.new("TextLabel", f)
    lbl.Size               = UDim2.new(1, -8, 0, 20)
    lbl.Position           = UDim2.new(0, 4, 0, 2)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3         = Color3.fromRGB(200, 200, 210)
    lbl.Font               = Enum.Font.GothamBold
    lbl.TextSize           = IsMobile and 11 or 12
    lbl.TextXAlignment     = Enum.TextXAlignment.Left
    lbl.Text               = label .. ": " .. default
    local track = Instance.new("Frame", f)
    track.Size             = UDim2.new(0.92, 0, 0, IsMobile and 9 or 8)
    track.Position         = UDim2.new(0.04, 0, 0, IsMobile and 32 or 34)
    track.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    track.BorderSizePixel  = 0
    Instance.new("UICorner", track)
    local fill = Instance.new("Frame", track)
    fill.Size             = UDim2.new((default - minV) / (maxV - minV), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
    fill.BorderSizePixel  = 0
    Instance.new("UICorner", fill)
    local kSz  = IsMobile and 16 or 13
    local knob = Instance.new("Frame", track)
    knob.Size             = UDim2.new(0, kSz, 0, kSz)
    knob.Position         = UDim2.new((default - minV) / (maxV - minV), -kSz/2, 0.5, -kSz/2)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel  = 0
    Instance.new("UICorner", knob)
    local dragging = false
    local function UpdateSlider(inp)
        local rel = math.clamp(
            (inp.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local val = math.floor(minV + rel * (maxV - minV))
        fill.Size     = UDim2.new(rel, 0, 1, 0)
        knob.Position = UDim2.new(rel, -kSz/2, 0.5, -kSz/2)
        lbl.Text      = label .. ": " .. val
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
        or inp.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
end

local function AddAction(tabName, name, color, cb)
    local f   = MakeFrame(tabName)
    local btn = Instance.new("TextButton", f)
    btn.Size             = UDim2.new(1, 0, 1, 0)
    btn.BackgroundColor3 = color or Color3.fromRGB(130, 0, 0)
    btn.TextColor3       = Color3.fromRGB(255, 255, 255)
    btn.Font             = Enum.Font.GothamBold
    btn.TextSize         = IsMobile and 11 or 13
    btn.BorderSizePixel  = 0
    btn.AutoButtonColor  = false
    btn.Text             = name
    Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(function()
        local orig = btn.BackgroundColor3
        btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        task.wait(0.08)
        btn.BackgroundColor3 = orig
        task.spawn(cb)
    end)
end

local function AddTP(tabName, name, vec)
    local f   = MakeFrame(tabName)
    local btn = Instance.new("TextButton", f)
    btn.Size             = UDim2.new(1, 0, 1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(18, 18, 32)
    btn.TextColor3       = Color3.fromRGB(255, 215, 0)
    btn.Font             = Enum.Font.GothamBold
    btn.TextSize         = IsMobile and 11 or 12
    btn.BorderSizePixel  = 0
    btn.AutoButtonColor  = false
    btn.Text             = "📍 " .. name
    Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(function()
        if SafeTeleport(vec) then Notify("TP","➜ "..name,2) end
    end)
end

-- ============================================================
-- POPULATE TABS
-- ============================================================
AddCategory("Combat","COMBAT")
AddToggle("Combat","AIM LOCK","AimActive",
    function() aimTarget=nil;aimLocked=false;aimLostFrames=0;aimLastSwitch=0 end,
    function() aimTarget=nil;aimLocked=false;aimLostFrames=0 end)
AddToggle("Combat","SILENT AIM","SilentAim")
AddToggle("Combat","ESP","ESP",nil,function() ClearAllESP() end)
AddToggle("Combat","MAGNET","Magnet",nil,function() Config.MagnetTarget=nil end)
AddCategory("Combat","AIM CONFIG")
AddSlider("Combat","Aim FOV",50,500,Config.AimFOV,"AimFOV",function(v)
    Config.AimFOV=v; UpdateFOVCircle()
end)
AddSlider("Combat","Aim Smooth (x100)",5,100,
    math.floor(Config.AimSmooth*100),"AimSmooth",
    function(v) Config.AimSmooth=v/100 end)

AddCategory("Movement","MOVEMENT")
AddToggle("Movement","FLY","Fly",
    function() UpdateFlyBtns() end,
    function()
        UpdateFlyBtns()
        local hum=GetHum()
        if hum then hum.PlatformStand=false; hum.WalkSpeed=16 end
    end)
AddSlider("Movement","FLY SPEED",10,IsPC and 250 or 150,Config.FlySpeedValue,"FlySpeedValue")
AddToggle("Movement","SPEED HACK","Speed",
    nil,function() local h=GetHum(); if h then h.WalkSpeed=16 end end)
AddSlider("Movement","WALK SPEED",16,IsPC and 150 or 100,Config.WalkSpeedValue,"WalkSpeedValue")
AddToggle("Movement","NOCLIP","Noclip",nil,function() RestoreCollision() end)
AddToggle("Movement","INF JUMP","InfJump")
AddCategory("Movement","TELEPORTS")
AddTP("Movement","GUN SHOP",  COORDS.GUN_SHOP)
AddTP("Movement","BANK",      COORDS.BANK_ENT)
AddTP("Movement","SAFE ZONE", COORDS.SAFE_ZONE)

AddCategory("Misc","SURVIVAL")
AddToggle("Misc","AUTO SAFE HP","AutoSafe")
AddToggle("Misc","AUTO HEAL",   "Heal")
AddToggle("Misc","AUTO ARMOR",  "Armor")
AddCategory("Misc","FARM & MISC")
AddToggle("Misc","AUTO FARM","Farm")
AddToggle("Misc","ANTI-SEAT","AntiSeat")
AddToggle("Misc","ANTI-AFK", "AntiAFK")
AddToggle("Misc","FPS BOOST","FPSBoost",function() ApplyFPS() end)
AddCategory("Misc","ACTIONS")
AddAction("Misc","🏦 AUTO ROB BANK",Color3.fromRGB(150,20,20),StartRobbery)

-- BINDS
local bindActions = {
    {key="Fly",       name="FLY"},
    {key="AimActive", name="AIM LOCK"},
    {key="Noclip",    name="NOCLIP"},
    {key="SilentAim", name="SILENT AIM"},
    {key="ToggleUI",  name="TOGGLE UI"},
}

local infoF = Instance.new("Frame", Scroll)
infoF.Size             = UDim2.new(0.97,0,0,IsMobile and 36 or 26)
infoF.BackgroundColor3 = Color3.fromRGB(12,12,22)
infoF.BorderSizePixel  = 0
infoF.Visible          = false
Instance.new("UICorner", infoF)
table.insert(Sections["Binds"], infoF)
local infoL = Instance.new("TextLabel", infoF)
infoL.Size                   = UDim2.new(1,0,1,0)
infoL.BackgroundTransparency = 1
infoL.TextColor3             = Color3.fromRGB(120,160,255)
infoL.Font                   = Enum.Font.Gotham
infoL.TextSize               = IsMobile and 10 or 11
infoL.TextWrapped            = true
infoL.Text                   = "Натисни кнопку → натисни клавішу → збережено"

AddCategory("Binds","CUSTOM BINDS")

local BindBtns = {}

local function AddBindRow(tabName, actionKey, actionName)
    local f = Instance.new("Frame", Scroll)
    f.Size             = UDim2.new(0.97,0,0,IsMobile and 40 or 36)
    f.BackgroundColor3 = Color3.fromRGB(16,16,26)
    f.BorderSizePixel  = 0
    f.Visible          = false
    Instance.new("UICorner", f)
    table.insert(Sections[tabName], f)
    local nameLbl = Instance.new("TextLabel", f)
    nameLbl.Size               = UDim2.new(0.52,0,1,0)
    nameLbl.Position           = UDim2.new(0,10,0,0)
    nameLbl.BackgroundTransparency = 1
    nameLbl.TextColor3         = Color3.fromRGB(200,200,210)
    nameLbl.Font               = Enum.Font.GothamBold
    nameLbl.TextSize           = IsMobile and 11 or 13
    nameLbl.TextXAlignment     = Enum.TextXAlignment.Left
    nameLbl.Text               = actionName
    local bindBtn = Instance.new("TextButton", f)
    bindBtn.Size             = UDim2.new(0.4,0,0,IsMobile and 28 or 24)
    bindBtn.Position         = UDim2.new(0.56,0,0.5,IsMobile and -14 or -12)
    bindBtn.BackgroundColor3 = Color3.fromRGB(22,22,38)
    bindBtn.TextColor3       = Color3.fromRGB(170,200,255)
    bindBtn.Font             = Enum.Font.GothamBold
    bindBtn.TextSize         = IsMobile and 10 or 11
    bindBtn.BorderSizePixel  = 0
    bindBtn.AutoButtonColor  = false
    local curBind = Binds[actionKey]
    bindBtn.Text = curBind
        and tostring(curBind):gsub("Enum%.KeyCode%.","")
        or "NONE"
    Instance.new("UICorner", bindBtn)
    local bSt = Instance.new("UIStroke", bindBtn)
    bSt.Color = Color3.fromRGB(0,100,200); bSt.Thickness = 1
    BindBtns[actionKey] = bindBtn
    bindBtn.MouseButton1Click:Connect(function()
        if waitingForBind then return end
        waitingForBind     = actionKey
        bindBtn.Text       = "[ Press key ]"
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
                BindBtns[action].Text       = tostring(inp.KeyCode):gsub("Enum%.KeyCode%.","")
                BindBtns[action].TextColor3 = Color3.fromRGB(170,200,255)
            end
            Notify("BIND",
                (BindNames[action] or action).." → "..
                tostring(inp.KeyCode):gsub("Enum%.KeyCode%.",""),2)
            waitingForBind = nil
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
-- M BUTTON
-- ============================================================
local MBtnSz = IsMobile and 52 or 42
local MBtn = Instance.new("TextButton", SG)
MBtn.Size             = UDim2.new(0, MBtnSz, 0, MBtnSz)
MBtn.Position         = UDim2.new(0, 10, 0.28, 0)
MBtn.Text             = "M"
MBtn.Font             = Enum.Font.GothamBlack
MBtn.TextSize         = IsMobile and 22 or 18
MBtn.BackgroundColor3 = Color3.fromRGB(0, 80, 200)
MBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
MBtn.BorderSizePixel  = 0
MBtn.AutoButtonColor  = false
MBtn.ZIndex           = 100
Instance.new("UICorner", MBtn)
local mStroke = Instance.new("UIStroke", MBtn)
mStroke.Color     = Color3.fromRGB(255, 255, 255)
mStroke.Thickness = 2

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
            MBtn.Position=UDim2.new(
                mPos.X.Scale,mPos.X.Offset+d.X,
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
Notify("Markiyan PRO V48",
    IsMobile
        and "📱 Mobile | M=меню | FOV ✓"
        or  "M=меню | G=aim | F=fly | V=noclip ✓",4)
