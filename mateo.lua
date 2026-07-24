-- [[ BLOX STRIKE OMNI GHOST v8.12 - ULTIMATE MERGED EDITION ]]
-- Features: 
--   - Undetectable GUI (GUID + ProtectGui) with Keybind Rebinding (from v8.11)
--   - Progressive Bhop with Gaussian Noise & AC Evasion (from v8.0)
--   - Safe NoClip with Wall-check & Damage Protect (from v8.0)
--   - Leak-free ESP & Hitbox (from v8.0)
--   - Config NaN Validation (from v8.0)

local function getService(name)
    local service = game:GetService(name)
    if typeof(cloneref) == "function" then
        return cloneref(service)
    end
    return service
end

local Players = getService("Players")
local RunService = getService("RunService")
local UIS = getService("UserInputService")
local Workspace = getService("Workspace")
local VirtualInputManager = getService("VirtualInputManager")
local TweenService = getService("TweenService")
local HttpService = getService("HttpService")
local CoreGui = getService("CoreGui")

local LP = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local IsMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled
local IsPC = not IsMobile
local DeviceLabel = IsMobile and "MOB" or "PC"

-- ═══════════════════════════════════════
-- [[ CONFIG З ВАЛІДАЦІЄЮ ]]
-- ═══════════════════════════════════════
local RawConfig = {
    -- Aimbot General
    AimSmoothness       = 0.35,
    AimSmoothnessDelta  = 0.25,
    FOV                 = 130,
    MaxDistance         = 500,
    Prediction          = 0.040,
    TeamCheck           = true,
    WallCheck           = true,
    AimPart             = "Head",
    UseDeltaAim         = IsMobile,

    -- Keybinds (Динамічні)
    Keybinds = {
        Aimbot     = Enum.KeyCode.T,
        Triggerbot = Enum.KeyCode.Y,
        ESP        = Enum.KeyCode.U,
        Hitbox     = Enum.KeyCode.H,
        Bhop       = Enum.KeyCode.L,
        NoClip     = Enum.KeyCode.K,
        TeamFire   = Enum.KeyCode.F,
    },

    -- Triggerbot
    TriggerDelay        = 0.05,

    -- Hitbox
    HeadSizeMultiplier  = 2.2,
    HeadTransparency    = 0.6,

    -- ESP
    ESPMaxDistance      = 800,
    TextSize            = 12,
    TracerThickness     = 1.2,
    TracerTransparency  = 0.6,
    TeamFireColor       = Color3.fromRGB(0, 150, 255),

    -- BHOP — прогресивна швидкість
    BhopBaseSpeed       = 18,
    BhopSpeedPerJump    = 4.5,
    BhopMaxJumps        = 30,
    BhopMaxSpeed        = 135,
    BhopDecayRate       = 0.965,
    BhopGroundDecay     = 0.78,
    BhopAirAccel        = 0.88,
    BhopSideForce       = 0.38,
    BhopMinTurn         = 0.25,
    BhopJumpWindow      = 0.065,
    BhopNoiseScale      = 0.8,

    -- Anticheat evasion
    ACVelocityNoise     = 2.2,
    ACJumpNoise         = 0.008,
    ACMaxVelChange      = 18,
    ACFakeDecay         = true,

    -- NoClip
    NoClipSafeMode      = true,
    NoClipDamageProtect = true,
    NoClipTickRate      = 0.03,

    -- Performance Limits
    ESPUpdateRate       = 1/30,
    HitboxUpdateRate    = 0.25,
    TargetSearchRate    = 0.08,
    WallCheckCacheTime  = 0.08,
    PlayerListCacheTime = 0.8,
    UIUpdateRate        = 0.5,
    VisCacheCleanup     = 30,
}

local Config = {}
do
    local function Validate(k, v)
        if type(v) == "number" then
            if v ~= v or v == math.huge or v == -math.huge then return 1 end
        end
        return v
    end
    for k, v in pairs(RawConfig) do Config[k] = Validate(k, v) end
    if Config.BhopMaxSpeed   <= 0 then Config.BhopMaxSpeed   = 135 end
    if Config.BhopMaxJumps   <= 0 then Config.BhopMaxJumps   = 30  end
    if Config.VisCacheCleanup <= 0 then Config.VisCacheCleanup = 30  end
end

local States = {
    Aimbot     = false, Triggerbot = false, ESP        = false,
    Hitbox     = false, Bhop       = false, NoClip     = false,
    TeamFire   = false,
}

local Bhop = {
    jumpCount = 0, currentSpeed = 0, peakSpeed = 0,
    lastCamAngle = 0, turnSpeed = 0, turnDirection = 0,
    wasOnGround = true, onGroundFrames = 0, lastJumpTime = 0,
    lastLandTime = 0, jumpQueued = false, jumpImpulseDone = false,
    lastVelReport = Vector3.zero, noiseOffset = 0, mobileJumpHeld = false,
    totalTurned = 0, perfectJumps = 0, streakActive = false,
}

local LockedTarget = nil
local isRebinding = false
local rebindFeature = nil
local statusText = ""
local hitboxCount = 0

local ResetAllHeads, UpdateUI, RestoreCollision

local function GetKeyName(kc)
    if not kc then return "NONE" end
    if typeof(kc) == "EnumItem" and kc.EnumType == Enum.UserInputType then
        local name = kc.Name
        if name == "MouseButton1" then return "MB1" end
        if name == "MouseButton2" then return "MB2" end
        if name == "MouseButton3" then return "MB3" end
        return name
    end
    local name = kc.Name
    if name == "LeftShift" then return "LShift" end
    if name == "RightShift" then return "RShift" end
    if name == "LeftControl" then return "LCtrl" end
    if name == "RightControl" then return "RCtrl" end
    return name
end

-- ═══════════════════════════════════════
-- [[ GUI З ЗАХИСТОМ ВІД ANTI-CHEAT ]]
-- ═══════════════════════════════════════
local uiGui = Instance.new("ScreenGui")
uiGui.Name = HttpService:GenerateGUID(false)
uiGui.ResetOnSpawn = false
uiGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
uiGui.IgnoreGuiInset = true

if syn and typeof(syn.protect_gui) == "function" then
    syn.protect_gui(uiGui)
    uiGui.Parent = CoreGui
elseif typeof(gethui) == "function" then
    uiGui.Parent = gethui()
elseif CoreGui then
    uiGui.Parent = CoreGui
else
    uiGui.Parent = LP:WaitForChild("PlayerGui")
end

local fullSize = UDim2.new(0, 185, 0, 260)
local minSize  = UDim2.new(0, 185, 0, 24)

local mainPanel = Instance.new("Frame", uiGui)
mainPanel.Size = fullSize
mainPanel.Position = UDim2.new(0, 12, 0, 40)
mainPanel.BackgroundColor3 = Color3.fromRGB(10, 10, 16)
mainPanel.BackgroundTransparency = 0.08
mainPanel.BorderSizePixel = 0
mainPanel.Active = true
mainPanel.ClipsDescendants = true
Instance.new("UICorner", mainPanel).CornerRadius = UDim.new(0, 8)

local mainStroke = Instance.new("UIStroke", mainPanel)
mainStroke.Thickness = 1.2
mainStroke.Color = Color3.fromRGB(255, 50, 50)

task.spawn(function()
    local cols = {Color3.fromRGB(255,40,40), Color3.fromRGB(255,100,0), Color3.fromRGB(255,200,0), Color3.fromRGB(255,40,40)}
    local i = 1
    while uiGui.Parent do
        i = (i % #cols) + 1
        TweenService:Create(mainStroke, TweenInfo.new(1.8, Enum.EasingStyle.Sine), {Color = cols[i]}):Play()
        task.wait(1.8)
    end
end)

local titleText = Instance.new("TextLabel", mainPanel)
titleText.Size = UDim2.new(1, -28, 0, 22)
titleText.Position = UDim2.new(0, 6, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "⚡ OMNI v8.12 [AC BYPASS]"
titleText.Font = Enum.Font.GothamBlack
titleText.TextSize = 9
titleText.TextColor3 = Color3.fromRGB(255, 70, 70)
titleText.TextXAlignment = Enum.TextXAlignment.Left

local listContainer = Instance.new("Frame", mainPanel)
listContainer.Size = UDim2.new(1, -12, 1, -70)
listContainer.Position = UDim2.new(0, 6, 0, 24)
listContainer.BackgroundTransparency = 1

local listLayout = Instance.new("UIListLayout", listContainer)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 3)

local minBtn = Instance.new("TextButton", mainPanel)
minBtn.Size = UDim2.new(0, 22, 0, 22)
minBtn.Position = UDim2.new(1, -24, 0, 0)
minBtn.BackgroundTransparency = 1
minBtn.Text = "—"
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 14
minBtn.TextColor3 = Color3.fromRGB(200, 200, 200)

local isMinimized = false
minBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        listContainer.Visible = false
        TweenService:Create(mainPanel, TweenInfo.new(0.2), {Size = minSize}):Play()
        minBtn.Text = "+"; minBtn.TextColor3 = Color3.fromRGB(0, 255, 120)
    else
        TweenService:Create(mainPanel, TweenInfo.new(0.2), {Size = fullSize}):Play()
        task.delay(0.15, function() if not isMinimized then listContainer.Visible = true end end)
        minBtn.Text = "—"; minBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    end
end)

local featureRows = {}
local featuresList = {
    {Name = "Aimbot", Key = "Aimbot"}, {Name = "Triggerbot", Key = "Triggerbot"},
    {Name = "ESP", Key = "ESP"}, {Name = "Hitbox", Key = "Hitbox"},
    {Name = "Bhop", Key = "Bhop"}, {Name = "NoClip", Key = "NoClip"},
    {Name = "TeamFire", Key = "TeamFire"},
}

local function ToggleFeature(key)
    States[key] = not States[key]
    if key == "Hitbox" and not States.Hitbox then if ResetAllHeads then ResetAllHeads() end end
    elseif key == "NoClip" and not States.NoClip then if RestoreCollision then RestoreCollision() end end
    elseif key == "TeamFire" then LockedTarget = nil; if ResetAllHeads then ResetAllHeads() end end
    elseif key == "Aimbot" and not States.Aimbot then LockedTarget = nil end
    elseif key == "Bhop" and not States.Bhop then
        Bhop.jumpCount = 0; Bhop.currentSpeed = 0; Bhop.peakSpeed = 0; Bhop.streakActive = false
    end
    UpdateUI()
end

local function StartRebind(keyName)
    if isRebinding then return end
    isRebinding = true; rebindFeature = keyName; UpdateUI()
    local connection
    connection = UIS.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Keyboard then
            if input.KeyCode ~= Enum.KeyCode.Escape then Config.Keybinds[keyName] = input.KeyCode end
            connection:Disconnect(); isRebinding = false; rebindFeature = nil; UpdateUI()
        elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.MouseButton3 then
            Config.Keybinds[keyName] = input.UserInputType
            connection:Disconnect(); isRebinding = false; rebindFeature = nil; UpdateUI()
        end
    end)
end

for i, item in ipairs(featuresList) do
    local row = Instance.new("Frame", listContainer)
    row.Size = UDim2.new(1, 0, 0, 21)
    row.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
    row.BorderSizePixel = 0
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 4)

    local toggleBtn = Instance.new("TextButton", row)
    toggleBtn.Size = UDim2.new(0.72, 0, 1, 0)
    toggleBtn.Position = UDim2.new(0, 4, 0, 0)
    toggleBtn.BackgroundTransparency = 1
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextSize = 9
    toggleBtn.TextXAlignment = Enum.TextXAlignment.Left
    toggleBtn.MouseButton1Click:Connect(function() ToggleFeature(item.Key) end)

    local bindBtn = Instance.new("TextButton", row)
    bindBtn.Size = UDim2.new(0.25, 0, 1, -4)
    bindBtn.Position = UDim2.new(0.73, 0, 0, 2)
    bindBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 40)
    bindBtn.BorderSizePixel = 0
    bindBtn.Font = Enum.Font.GothamBold
    bindBtn.TextSize = 8
    Instance.new("UICorner", bindBtn).CornerRadius = UDim.new(0, 3)
    bindBtn.MouseButton1Click:Connect(function() StartRebind(item.Key) end)

    table.insert(featureRows, {Key = item.Key, Name = item.Name, ToggleBtn = toggleBtn, BindBtn = bindBtn})
end

-- Статус текст (спідометр та статистика)
local uiText = Instance.new("TextLabel", mainPanel)
uiText.Size = UDim2.new(1, -10, 0, 20)
uiText.Position = UDim2.new(0, 5, 1, -38)
uiText.BackgroundTransparency = 1
uiText.Font = Enum.Font.GothamBold
uiText.TextSize = 8
uiText.TextColor3 = Color3.fromRGB(150, 150, 150)
uiText.TextXAlignment = Enum.TextXAlignment.Left
uiText.Text = ""

-- Bhop прогрес-бар
local bhopBarBg = Instance.new("Frame", mainPanel)
bhopBarBg.Size = UDim2.new(1, -10, 0, 5)
bhopBarBg.Position = UDim2.new(0, 5, 1, -18)
bhopBarBg.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
bhopBarBg.BorderSizePixel = 0
Instance.new("UICorner", bhopBarBg).CornerRadius = UDim.new(0, 3)

local bhopBarFill = Instance.new("Frame", bhopBarBg)
bhopBarFill.Size = UDim2.new(0, 0, 1, 0)
bhopBarFill.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
bhopBarFill.BorderSizePixel = 0
Instance.new("UICorner", bhopBarFill).CornerRadius = UDim.new(0, 3)

-- Спідометр
local speedBarBg = Instance.new("Frame", mainPanel)
speedBarBg.Size = UDim2.new(1, -10, 0, 5)
speedBarBg.Position = UDim2.new(0, 5, 1, -9)
speedBarBg.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
speedBarBg.BorderSizePixel = 0
Instance.new("UICorner", speedBarBg).CornerRadius = UDim.new(0, 3)

local speedBarFill = Instance.new("Frame", speedBarBg)
speedBarFill.Size = UDim2.new(0, 0, 1, 0)
speedBarFill.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
speedBarFill.BorderSizePixel = 0
Instance.new("UICorner", speedBarFill).CornerRadius = UDim.new(0, 3)

local lockIndicator = Instance.new("TextLabel", uiGui)
lockIndicator.Size = UDim2.new(0, 130, 0, 16)
lockIndicator.Position = UDim2.new(0.5, -65, 0, 25)
lockIndicator.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
lockIndicator.BackgroundTransparency = 0.3
lockIndicator.Font = Enum.Font.GothamBold
lockIndicator.TextSize = 9
lockIndicator.TextColor3 = Color3.fromRGB(255, 255, 255)
lockIndicator.Visible = false
Instance.new("UICorner", lockIndicator).CornerRadius = UDim.new(0, 4)

local mobileJumpBtn
if IsMobile then
    mobileJumpBtn = Instance.new("TextButton", uiGui)
    mobileJumpBtn.Size = UDim2.new(0, 70, 0, 70)
    mobileJumpBtn.Position = UDim2.new(1, -85, 1, -95)
    mobileJumpBtn.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
    mobileJumpBtn.BackgroundTransparency = 0.3
    mobileJumpBtn.Text = "🐇"
    mobileJumpBtn.Font = Enum.Font.GothamBlack
    mobileJumpBtn.TextSize = 24
    mobileJumpBtn.Visible = false
    Instance.new("UICorner", mobileJumpBtn).CornerRadius = UDim.new(0.5, 0)
    mobileJumpBtn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch then Bhop.mobileJumpHeld = true end end)
    mobileJumpBtn.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch then Bhop.mobileJumpHeld = false end end)
end

UpdateUI = function()
    for _, item in ipairs(featureRows) do
        local key = item.Key; local st = States[key]; local kb = Config.Keybinds[key]
        item.ToggleBtn.Text = item.Name .. ": " .. (st and "ON" or "OFF")
        item.ToggleBtn.TextColor3 = st and (key == "TeamFire" and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(0, 255, 120)) or Color3.fromRGB(255, 70, 70)
        if isRebinding and rebindFeature == key then
            item.BindBtn.Text = "..."; item.BindBtn.TextColor3 = Color3.fromRGB(255, 200, 0)
        else
            item.BindBtn.Text = "[" .. GetKeyName(kb) .. "]"; item.BindBtn.TextColor3 = Color3.fromRGB(180, 180, 255)
        end
    end
    if mobileJumpBtn then mobileJumpBtn.Visible = States.Bhop end
end
UpdateUI()

local function MakeDraggable(frame)
    local dragging, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = frame.Position
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
end
MakeDraggable(mainPanel)

local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(255, 40, 40)
FOVCircle.Thickness = 1.2
FOVCircle.Radius = Config.FOV
FOVCircle.Filled = false
FOVCircle.Visible = false
FOVCircle.Transparency = 0.5

-- ═══════════════════════════════════════
-- [[ УТИЛІТИ ]]
-- ═══════════════════════════════════════
local function SafeNumber(n, fallback)
    if type(n) ~= "number" or n ~= n or n == math.huge or n == -math.huge then return fallback or 0 end
    return n
end

local function GetTeam(p) return p:GetAttribute("Team") end
local function IsTeammate(p)
    if States.TeamFire then return false end
    if not Config.TeamCheck then return false end
    local my, their = GetTeam(LP), GetTeam(p)
    return my and their and my == their
end
local function IsRealTeammate(p)
    if not Config.TeamCheck then return false end
    local my, their = GetTeam(LP), GetTeam(p)
    return my and their and my == their
end
local function IsAlive(p)
    local c = p.Character
    if not c then return false end
    local h = c:FindFirstChildOfClass("Humanoid")
    return h and h.Health > 0 and c:FindFirstChild("HumanoidRootPart") ~= nil
end
local function GetAimPart(char)
    return char:FindFirstChild(Config.AimPart) or char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
end

local cachedPlayers = {}
local lastPlayerCache = 0
local function GetAllPlayers()
    local now = tick()
    if (now - lastPlayerCache) < Config.PlayerListCacheTime then return cachedPlayers end
    lastPlayerCache = now; cachedPlayers = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then table.insert(cachedPlayers, p) end
    end
    return cachedPlayers
end

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
rayParams.IgnoreWater = true

local visibilityCache = {}
local lastVisCacheCleanup = tick()
local function CleanVisibilityCache()
    local now, maxAge, cleaned = tick(), Config.WallCheckCacheTime * 3, 0
    for id, c in pairs(visibilityCache) do
        if (now - c.time) > maxAge then visibilityCache[id] = nil; cleaned = cleaned + 1 end
    end
end
local function IsVisible(tp, tc)
    if not tp or not tc or not LP.Character then return false end
    local o, d = Camera.CFrame.Position, tp.Position - Camera.CFrame.Position
    if d.Magnitude < 1 then return true end
    rayParams.FilterDescendantsInstances = {LP.Character, Camera}
    local r = Workspace:Raycast(o, d, rayParams)
    if not r then return true end
    return r.Instance:IsDescendantOf(tc)
end
local function IsVisibleCached(tp, tc, id)
    local now = tick()
    if (now - lastVisCacheCleanup) > Config.VisCacheCleanup then lastVisCacheCleanup = now; CleanVisibilityCache() end
    local c = visibilityCache[id]
    if c and (now - c.time) < Config.WallCheckCacheTime then return c.value end
    local r = IsVisible(tp, tc)
    visibilityCache[id] = {value = r, time = now}
    return r
end

-- ═══════════════════════════════════════
-- [[ BHOP -- ПРОГРЕСИВНА ШВИДКІСТЬ + ANTICHEAT ]]
-- ═══════════════════════════════════════
local function GetCameraYaw()
    local look = Camera.CFrame.LookVector
    if look.Magnitude < 0.001 then return Bhop.lastCamAngle end
    return math.atan2(look.X, look.Z)
end
local function NormalizeAngle(angle)
    while angle > math.pi do angle = angle - math.pi * 2 end
    while angle < -math.pi do angle = angle + math.pi * 2 end
    return angle
end
local function IsJumpHeld()
    if IsPC then return UIS:IsKeyDown(Enum.KeyCode.Space) end
    return Bhop.mobileJumpHeld
end
local function GetMoveDir()
    local char = LP.Character
    if not char then return Vector3.zero end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return Vector3.zero end
    if IsPC then
        local dir, cf = Vector3.zero, Camera.CFrame
        local fwdRaw = Vector3.new(cf.LookVector.X, 0, cf.LookVector.Z)
        local fwd = fwdRaw.Magnitude > 0.001 and fwdRaw.Unit or Vector3.zero
        local rgtRaw = Vector3.new(cf.RightVector.X, 0, cf.RightVector.Z)
        local rgt = rgtRaw.Magnitude > 0.001 and rgtRaw.Unit or Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + fwd end
        if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - fwd end
        if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - rgt end
        if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + rgt end
        return dir.Magnitude > 0.001 and dir.Unit or Vector3.zero
    else
        local vel, h = hrp.AssemblyLinearVelocity, Vector3.zero
        h = Vector3.new(vel.X, 0, vel.Z)
        return h.Magnitude > 2 and h.Unit or Vector3.zero
    end
end
local function ClampVelocityDelta(oldV, newV, maxDelta)
    local dx, dz = newV.X - oldV.X, newV.Z - oldV.Z
    local mag = math.sqrt(dx*dx + dz*dz)
    if mag > maxDelta then
        local scale = maxDelta / mag
        return Vector3.new(oldV.X + dx * scale, newV.Y, oldV.Z + dz * scale)
    end
    return newV
end
local function GaussianNoise(sigma)
    local u1 = math.max(1e-9, math.random())
    local u2 = math.random()
    return math.sqrt(-2 * math.log(u1)) * math.cos(2 * math.pi * u2) * sigma
end
local function GetTargetSpeed()
    local j = math.clamp(Bhop.jumpCount, 0, Config.BhopMaxJumps)
    local t = j / Config.BhopMaxJumps
    local spd = Config.BhopBaseSpeed + (Config.BhopMaxSpeed - Config.BhopBaseSpeed) * (1 - math.exp(-t * 4))
    return math.min(spd, Config.BhopMaxSpeed)
end

RunService.Stepped:Connect(function(_, dt)
    if dt <= 0 or dt > 0.5 then return end
    if not States.Bhop then
        if Bhop.currentSpeed > 0 then Bhop.currentSpeed = 0; Bhop.jumpCount = 0; Bhop.streakActive = false end
        return
    end
    local char = LP.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local onGround = hum.FloorMaterial ~= Enum.Material.Air
    local jumpHeld = IsJumpHeld()
    local moveDir = GetMoveDir()
    local isMoving = moveDir.Magnitude > 0.1
    local now = tick()

    local currentYaw = GetCameraYaw()
    local deltaYaw = NormalizeAngle(currentYaw - Bhop.lastCamAngle)
    Bhop.lastCamAngle = currentYaw
    deltaYaw = SafeNumber(deltaYaw, 0)
    local deltaDeg = math.abs(math.deg(deltaYaw))
    Bhop.turnSpeed = Bhop.turnSpeed * 0.72 + deltaDeg * 0.28

    if deltaYaw > 0.002 then Bhop.turnDirection = 1
    elseif deltaYaw < -0.002 then Bhop.turnDirection = -1
    else Bhop.turnDirection = 0 end

    local currentVel = hrp.AssemblyLinearVelocity
    local hVel = Vector3.new(currentVel.X, 0, currentVel.Z)
    local hSpeed = hVel.Magnitude
    Bhop.currentSpeed = hSpeed

    if onGround then
        if jumpHeld and isMoving then
            Bhop.currentSpeed = Bhop.currentSpeed * 0.995
        else
            Bhop.currentSpeed = Bhop.currentSpeed * Config.BhopGroundDecay
            if (now - Bhop.lastJumpTime) > 0.4 then
                Bhop.jumpCount = 0; Bhop.streakActive = false
            end
        end
    else
        Bhop.currentSpeed = Bhop.currentSpeed * Config.BhopDecayRate
    end

    if not onGround and isMoving and Bhop.turnDirection ~= 0 then
        local rgtRaw = Camera.CFrame.RightVector
        local rgt = Vector3.new(rgtRaw.X, 0, rgtRaw.Z)
        if rgt.Magnitude > 0.001 then rgt = rgt.Unit end
        local sideForce = rgt * Bhop.turnDirection * Config.BhopSideForce * Bhop.currentSpeed * dt
        local bonus = 0
        if deltaDeg > Config.BhopMinTurn then
            bonus = math.min(deltaDeg * 0.15 * dt * Bhop.jumpCount * 0.5, 3)
        end
        local newX = currentVel.X + sideForce.X + bonus * moveDir.X
        local newZ = currentVel.Z + sideForce.Z + bonus * moveDir.Z
        local targetVel = Vector3.new(newX, currentVel.Y, newZ)
        targetVel = ClampVelocityDelta(currentVel, targetVel, Config.ACMaxVelChange * dt * 60)
        local noiseX = GaussianNoise(Config.ACVelocityNoise * 0.4)
        local noiseZ = GaussianNoise(Config.ACVelocityNoise * 0.4)
        local finalX = math.clamp(targetVel.X + noiseX, -Config.BhopMaxSpeed, Config.BhopMaxSpeed)
        local finalZ = math.clamp(targetVel.Z + noiseZ, -Config.BhopMaxSpeed, Config.BhopMaxSpeed)
        pcall(function() hrp.AssemblyLinearVelocity = Vector3.new(finalX, currentVel.Y, finalZ) end)
    end

    if isMoving and not onGround and Bhop.jumpCount > 0 then
        local targetSpeed = GetTargetSpeed()
        local diff = targetSpeed - hSpeed
        if diff > 0 then
            local accel = math.min(diff * Config.BhopAirAccel * dt * 3.5, Config.ACMaxVelChange * dt * 60 * 0.5)
            if moveDir.Magnitude > 0.001 then
                local cv = hrp.AssemblyLinearVelocity
                local nX = math.clamp(cv.X + moveDir.X * accel, -Config.BhopMaxSpeed, Config.BhopMaxSpeed)
                local nZ = math.clamp(cv.Z + moveDir.Z * accel, -Config.BhopMaxSpeed, Config.BhopMaxSpeed)
                pcall(function() hrp.AssemblyLinearVelocity = Vector3.new(nX, cv.Y, nZ) end)
            end
        end
    end

    if onGround and not Bhop.wasOnGround then
        Bhop.lastLandTime = now; Bhop.jumpImpulseDone = false; Bhop.onGroundFrames = 0
    end
    if onGround then Bhop.onGroundFrames = Bhop.onGroundFrames + 1 else Bhop.onGroundFrames = 0 end
    Bhop.wasOnGround = onGround

    if jumpHeld and onGround and isMoving then
        local jitterDelay = Config.ACJumpNoise * math.random()
        if (now - Bhop.lastJumpTime) >= (0.015 + jitterDelay) and Bhop.onGroundFrames <= 3 then
            Bhop.lastJumpTime = now; Bhop.jumpCount = Bhop.jumpCount + 1; Bhop.streakActive = true
            local landDelta = now - Bhop.lastLandTime
            local isPerfect = landDelta < Config.BhopJumpWindow
            if isPerfect then Bhop.perfectJumps = Bhop.perfectJumps + 1 end

            if not Bhop.jumpImpulseDone then
                Bhop.jumpImpulseDone = true
                local targetSpeed = GetTargetSpeed()
                local impulseScale = math.clamp(targetSpeed / math.max(hSpeed, 1), 0.8, 2.2)
                if isPerfect then impulseScale = impulseScale * 1.15 end
                local noiseX = GaussianNoise(Config.BhopNoiseScale)
                local noiseZ = GaussianNoise(Config.BhopNoiseScale)
                pcall(function()
                    local cv = hrp.AssemblyLinearVelocity
                    local impX = moveDir.X * targetSpeed * impulseScale * 0.12 + noiseX
                    local impZ = moveDir.Z * targetSpeed * impulseScale * 0.12 + noiseZ
                    local newX = math.clamp(cv.X + impX, -Config.BhopMaxSpeed, Config.BhopMaxSpeed)
                    local newZ = math.clamp(cv.Z + impZ, -Config.BhopMaxSpeed, Config.BhopMaxSpeed)
                    local newY = cv.Y + 1.5 + (isPerfect and 0.5 or 0)
                    hrp.AssemblyLinearVelocity = Vector3.new(newX, newY, newZ)
                end)
            end
            pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end)
            local sv, sp = hrp.AssemblyLinearVelocity, 0
            sp = Vector3.new(sv.X, 0, sv.Z).Magnitude
            if sp > Bhop.peakSpeed then Bhop.peakSpeed = sp end
        end
    end
end)

-- ═══════════════════════════════════════
-- [[ NOCLIP SAFE MODE ]]
-- ═══════════════════════════════════════
local noClipParts = {}
local lastSafePos, lastSafePosTime, noClipTimer = nil, 0, 0

local function IsInsideWall()
    local char = LP.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    local cp = RaycastParams.new()
    cp.FilterType = Enum.RaycastFilterType.Exclude
    cp.FilterDescendantsInstances = {char}
    local wc = 0
    for _, d in ipairs({Vector3.new(1,0,0), Vector3.new(-1,0,0), Vector3.new(0,0,1), Vector3.new(0,0,-1), Vector3.new(0,1,0), Vector3.new(0,-1,0)}) do
        if Workspace:Raycast(hrp.Position, d * 2.5, cp) then wc = wc + 1 end
    end
    return wc >= 4
end

local function UpdateSafePosition()
    local char = LP.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local cp = RaycastParams.new()
    cp.FilterType = Enum.RaycastFilterType.Exclude
    cp.FilterDescendantsInstances = {char}
    if Workspace:Raycast(hrp.Position, Vector3.new(0, -10, 0), cp) then
        lastSafePos = hrp.CFrame; lastSafePosTime = tick()
    end
end

RestoreCollision = function()
    for part, val in pairs(noClipParts) do
        pcall(function() if part and part.Parent then part.CanCollide = val end end)
    end
    noClipParts = {}
end

local function RunNoClip(dt)
    if not States.NoClip then
        if next(noClipParts) then RestoreCollision() end
        if (tick() - lastSafePosTime) > 0.5 then UpdateSafePosition() end
        return
    end
    local char = LP.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    if Config.NoClipDamageProtect and IsInsideWall() then
        if hum.Health < hum.MaxHealth * 0.8 and lastSafePos then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then pcall(function() hrp.CFrame = lastSafePos; hrp.AssemblyLinearVelocity = Vector3.zero end) end
            return
        end
    end

    noClipTimer = noClipTimer + dt
    if noClipTimer >= Config.NoClipTickRate then
        noClipTimer = 0
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                if noClipParts[part] == nil then noClipParts[part] = part.CanCollide end
                part.CanCollide = false
            end
        end
    end
    if not IsInsideWall() and (tick() - lastSafePosTime) > 0.3 then UpdateSafePosition() end
end

-- ═══════════════════════════════════════
-- [[ HITBOX & ESP ]]
-- ═══════════════════════════════════════
local OriginalHeads = {}
local function EnlargeHead(p)
    local c = p.Character
    if not c then return end
    local h = c:FindFirstChild("Head")
    if not h then return end
    if not OriginalHeads[p] then
        OriginalHeads[p] = {Size = h.Size, Transparency = h.Transparency, Color = h.Color, Material = h.Material, CanCollide = h.CanCollide, Massless = h.Massless}
    end
    pcall(function()
        h.Size = OriginalHeads[p].Size * Config.HeadSizeMultiplier
        h.Transparency = Config.HeadTransparency
        h.Color = Color3.fromRGB(255, 40, 40)
        h.Material = Enum.Material.Neon
        h.CanCollide = false; h.Massless = true
    end)
end
local function RestoreHead(p)
    local o = OriginalHeads[p]
    if not o then return end
    local c = p.Character
    if c then
        local h = c:FindFirstChild("Head")
        if h then pcall(function() h.Size = o.Size; h.Transparency = o.Transparency; h.Color = o.Color; h.Material = o.Material; h.CanCollide = o.CanCollide; h.Massless = o.Massless end) end
    end
    OriginalHeads[p] = nil
end
ResetAllHeads = function()
    for p in pairs(OriginalHeads) do pcall(function() RestoreHead(p) end) end
    OriginalHeads = {}
end
local function UpdateHitboxes()
    if not States.Hitbox then if next(OriginalHeads) then ResetAllHeads() end; hitboxCount = 0; return end
    hitboxCount = 0
    for _, p in ipairs(GetAllPlayers()) do
        if not IsAlive(p) then if OriginalHeads[p] then RestoreHead(p) end; continue end
        local ra = IsRealTeammate(p)
        if (ra and States.TeamFire) or not ra then EnlargeHead(p); hitboxCount = hitboxCount + 1
        else if OriginalHeads[p] then RestoreHead(p) end end
    end
end

local ESPObjects, AllDrawings = {}, {}
local function TrackDrawing(d) AllDrawings[d] = true; return d end
local function CreateESP(p)
    if ESPObjects[p] then
        for _, d in pairs(ESPObjects[p]) do pcall(function() AllDrawings[d] = nil; d:Remove() end) end
    end
    local function ND(t) return TrackDrawing(Drawing.new(t)) end
    local e = {}
    e.boxOut = ND("Square"); e.boxOut.Thickness = 3; e.boxOut.Color = Color3.new(0,0,0); e.boxOut.Filled = false; e.boxOut.Visible = false; e.boxOut.Transparency = 0.5
    e.box = ND("Square"); e.box.Thickness = 1.5; e.box.Filled = false; e.box.Visible = false
    e.name = ND("Text"); e.name.Size = Config.TextSize; e.name.Color = Color3.new(1,1,1); e.name.Outline = true; e.name.Center = true; e.name.Visible = false
    e.dist = ND("Text"); e.dist.Size = 11; e.dist.Color = Color3.fromRGB(180,180,180); e.dist.Outline = true; e.dist.Center = true; e.dist.Visible = false
    e.hpBg = ND("Line"); e.hpBg.Thickness = 5; e.hpBg.Color = Color3.fromRGB(25,25,25); e.hpBg.Visible = false
    e.hp = ND("Line"); e.hp.Thickness = 3; e.hp.Visible = false
    e.tr = ND("Line"); e.tr.Thickness = Config.TracerThickness; e.tr.Transparency = Config.TracerTransparency; e.tr.Visible = false
    ESPObjects[p] = e; return e
end
local function HideESP(e)
    if not e then return end
    for _, d in pairs(e) do if d.Visible ~= nil then d.Visible = false end end
end
local function RemoveESP(p)
    local e = ESPObjects[p]
    if not e then return end
    for _, d in pairs(e) do pcall(function() AllDrawings[d] = nil; d:Remove() end) end
    ESPObjects[p] = nil
end
uiGui.Destroying:Connect(function()
    for p in pairs(ESPObjects) do RemoveESP(p) end
    pcall(function() FOVCircle:Remove() end)
    for d in pairs(AllDrawings) do pcall(function() d:Remove() end) end
    AllDrawings = {}
end)
local function UpdateESP()
    if not States.ESP then for _, e in pairs(ESPObjects) do HideESP(e) end; return end
    local vp = Camera.ViewportSize
    local tO = Vector2.new(vp.X / 2, vp.Y)
    local cp = Camera.CFrame.Position
    for p in pairs(ESPObjects) do if not p or not p.Parent then RemoveESP(p) end end
    for _, p in ipairs(GetAllPlayers()) do
        local e = ESPObjects[p] or CreateESP(p)
        if not IsAlive(p) then HideESP(e); continue end
        local ra = IsRealTeammate(p)
        if not States.TeamFire and ra then HideESP(e); continue end
        local ch, hrp = p.Character, p.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then HideESP(e); continue end
        local d3 = (cp - hrp.Position).Magnitude
        if d3 > Config.ESPMaxDistance then HideESP(e); continue end
        local rp, onS = Camera:WorldToViewportPoint(hrp.Position)
        if not onS then HideESP(e); continue end
        local hd = ch:FindFirstChild("Head")
        if not hd then HideESP(e); continue end
        local hsp = Camera:WorldToViewportPoint(hd.Position + Vector3.new(0, .8, 0))
        local fY, h, w = rp.Y + (rp.Y - hsp.Y) * 1.5, math.abs((rp.Y + (rp.Y - hsp.Y) * 1.5) - hsp.Y), h * 0.55
        local vis = IsVisibleCached(hd, ch, p.UserId)
        local mc = ra and (vis and Config.TeamFireColor or Color3.fromRGB(0, 80, 180)) or (vis and Color3.fromRGB(50, 255, 80) or Color3.fromRGB(255, 50, 50))
        e.boxOut.Size = Vector2.new(w + 2, h + 2); e.boxOut.Position = Vector2.new(rp.X - w/2 - 1, hsp.Y - 1); e.boxOut.Visible = true
        e.box.Color = mc; e.box.Size = Vector2.new(w, h); e.box.Position = Vector2.new(rp.X - w/2, hsp.Y); e.box.Visible = true
        e.name.Text = p.DisplayName; e.name.Position = Vector2.new(rp.X, hsp.Y - 17); e.name.Color = ra and Color3.fromRGB(100, 200, 255) or Color3.new(1,1,1); e.name.Visible = true
        e.dist.Text = math.floor(d3).."m"; e.dist.Position = Vector2.new(rp.X, fY + 3); e.dist.Visible = true
        local hum = ch:FindFirstChildOfClass("Humanoid")
        if hum then
            local r = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
            local bx = rp.X - w/2 - 6
            e.hpBg.From = Vector2.new(bx, fY); e.hpBg.To = Vector2.new(bx, hsp.Y); e.hpBg.Visible = true
            e.hp.From = Vector2.new(bx, fY); e.hp.To = Vector2.new(bx, fY - h * r); e.hp.Color = ra and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(255 * (1 - r), 255 * r, 0); e.hp.Visible = true
        end
        e.tr.From = tO; e.tr.To = Vector2.new(rp.X, fY); e.tr.Color = mc; e.tr.Visible = true
    end
end
Players.PlayerRemoving:Connect(function(p)
    if OriginalHeads[p] then RestoreHead(p) end
    visibilityCache[p.UserId] = nil
    RemoveESP(p)
    lastPlayerCache = 0
end)

-- ═══════════════════════════════════════
-- [[ AIMBOT & TRIGGERBOT ]]
-- ═══════════════════════════════════════
local lastTargetSearch = 0
local function GetClosestTarget()
    local closest, minDist = nil, Config.FOV
    local c2 = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local cp = Camera.CFrame.Position
    for _, p in ipairs(GetAllPlayers()) do
        if not IsAlive(p) or IsTeammate(p) then continue end
        local hrp = p.Character:FindFirstChild("HumanoidRootPart")
        if not hrp or (cp - hrp.Position).Magnitude > Config.MaxDistance then continue end
        local ap = GetAimPart(p.Character)
        if not ap then continue end
        local sp, onS = Camera:WorldToViewportPoint(ap.Position)
        if not onS then continue end
        local d = (Vector2.new(sp.X, sp.Y) - c2).Magnitude
        if d >= minDist then continue end
        if Config.WallCheck and not IsVisibleCached(ap, p.Character, p.UserId) then continue end
        minDist = d; closest = {Part = ap, Player = p, Character = p.Character}
    end
    return closest
end

local function RunAimbot()
    if not States.Aimbot then LockedTarget = nil; lockIndicator.Visible = false; return end
    if LockedTarget then
        local p, valid = LockedTarget.Player, true
        if not IsAlive(p) or IsTeammate(p) then valid = false
        else
            local ap = GetAimPart(LockedTarget.Character)
            if not ap then valid = false
            else
                LockedTarget.Part = ap
                local hrp = LockedTarget.Character:FindFirstChild("HumanoidRootPart")
                if not hrp or (Camera.CFrame.Position - hrp.Position).Magnitude > Config.MaxDistance then valid = false
                elseif Config.WallCheck and not IsVisibleCached(ap, LockedTarget.Character, p.UserId) then valid = false end
            end
        end
        if not valid then LockedTarget = nil end
    end
    local now = tick()
    if not LockedTarget and (now - lastTargetSearch) >= Config.TargetSearchRate then
        lastTargetSearch = now; LockedTarget = GetClosestTarget()
    end
    if LockedTarget then
        lockIndicator.Text = (IsRealTeammate(LockedTarget.Player) and "🔵 " or "🔒 ")..LockedTarget.Player.DisplayName
        lockIndicator.Visible = true
    else lockIndicator.Visible = false; return end
    local ap = LockedTarget.Part
    if not ap or not ap.Parent then LockedTarget = nil; return end
    local vel = Vector3.zero
    local hrp = LockedTarget.Character:FindFirstChild("HumanoidRootPart")
    if hrp then vel = hrp.AssemblyLinearVelocity end
    local pred = ap.Position + vel * Config.Prediction
    local c2 = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local sp, onS = Camera:WorldToViewportPoint(pred)
    if not onS then LockedTarget = nil; return end
    local d, sm = (Vector2.new(sp.X, sp.Y) - c2).Magnitude, Config.AimSmoothness
    if d < 5 then sm = sm * 0.15 elseif d < 15 then sm = sm * 0.45 elseif d < 40 then sm = sm * 0.75 end
    if mousemoverel then pcall(mousemoverel, (sp.X - c2.X) * sm, (sp.Y - c2.Y) * sm) end
end

local canShoot = true
local trigP = RaycastParams.new()
trigP.FilterType = Enum.RaycastFilterType.Exclude
local function RunTriggerbot()
    if not States.Triggerbot or not canShoot or not LP.Character then return end
    trigP.FilterDescendantsInstances = {LP.Character, Camera}
    local hit = Workspace:Raycast(Camera.CFrame.Position, Camera.CFrame.LookVector * 1000, trigP)
    if not hit or not hit.Instance then return end
    local m = hit.Instance:FindFirstAncestorOfClass("Model")
    if not m then return end
    local p = Players:GetPlayerFromCharacter(m)
    if not p or p == LP or not IsAlive(p) or IsTeammate(p) then return end
    canShoot = false
    local vc = Camera.ViewportSize / 2
    pcall(function()
        VirtualInputManager:SendMouseButtonEvent(vc.X, vc.Y, 0, true, game, 1)
        task.wait(0.012 + math.random() * 0.01)
        VirtualInputManager:SendMouseButtonEvent(vc.X, vc.Y, 0, false, game, 1)
    end)
    task.delay(Config.TriggerDelay + math.random() * 0.03, function() canShoot = true end)
end

-- ═══════════════════════════════════════
-- [[ КЛАВІШІ ТА ОБРОБКА ДИНАМІЧНИХ БІНДІВ ]]
-- ═══════════════════════════════════════
UIS.InputBegan:Connect(function(input, gpe)
    if UIS:GetFocusedTextBox() or isRebinding then return end
    
    local triggered = false
    for featureName, bind in pairs(Config.Keybinds) do
        local isMatch = false
        if typeof(bind) == "EnumItem" then
            if bind.EnumType == Enum.KeyCode and input.KeyCode == bind then isMatch = true end
            if bind.EnumType == Enum.UserInputType and input.UserInputType == bind then isMatch = true end
        end
        
        if isMatch then
            ToggleFeature(featureName)
            triggered = true
            break
        end
    end
end)

LP.CharacterAdded:Connect(function(char)
    noClipParts = {}
    Bhop.jumpCount = 0; Bhop.currentSpeed = 0; Bhop.peakSpeed = 0
    Bhop.jumpImpulseDone = false; Bhop.streakActive = false
    LockedTarget = nil; lockIndicator.Visible = false; lastSafePos = nil
    char.DescendantAdded:Connect(function(part)
        if part:IsA("BasePart") and States.NoClip then task.wait(0.05); pcall(function() part.CanCollide = false end) end
    end)
end)

-- ═══════════════════════════════════════
-- [[ ЦИКЛИ (HEARTBEAT/RENDER) ]]
-- ═══════════════════════════════════════
RunService.Heartbeat:Connect(function(dt)
    if dt <= 0 or dt > 0.5 then return end
    RunNoClip(dt)
end)

local espT, hitT, uiT = 0, 0, 0
Bhop.lastCamAngle = GetCameraYaw()

RunService.RenderStepped:Connect(function(dt)
    Camera = Workspace.CurrentCamera
    local c = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    FOVCircle.Color = States.TeamFire and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(255, 40, 40)
    FOVCircle.Position = c
    FOVCircle.Visible = States.Aimbot

    RunAimbot()
    RunTriggerbot()

    espT = espT + dt
    if espT >= Config.ESPUpdateRate then espT = 0; UpdateESP() end

    hitT = hitT + dt
    if hitT >= Config.HitboxUpdateRate then hitT = 0; UpdateHitboxes() end

    uiT = uiT + dt
    if uiT >= Config.UIUpdateRate then
        uiT = 0
        local spd = 0
        pcall(function()
            if LP.Character then
                local hrp = LP.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local v = hrp.AssemblyLinearVelocity
                    spd = SafeNumber(Vector3.new(v.X, 0, v.Z).Magnitude, 0)
                end
            end
        end)

        uiText.Text = string.format("💨%d %s | 🏆%.0f | ✨%d", math.floor(spd), DeviceLabel, Bhop.peakSpeed, Bhop.perfectJumps)
        
        local ratio = math.clamp(Bhop.jumpCount / math.max(Config.BhopMaxJumps, 1), 0, 1)
        local col = ratio < 0.33 and Color3.fromRGB(0, 255, 100) or (ratio < 0.66 and Color3.fromRGB(255, 220, 0) or Color3.fromRGB(255, 80, 0))
        TweenService:Create(bhopBarFill, TweenInfo.new(0.08), {Size = UDim2.new(ratio, 0, 1, 0), BackgroundColor3 = col}):Play()

        local spdRatio = math.clamp(spd / Config.BhopMaxSpeed, 0, 1)
        local sCol = spdRatio < 0.33 and Color3.fromRGB(0, 200, 255) or (spdRatio < 0.66 and Color3.fromRGB(0, 255, 200) or Color3.fromRGB(100, 255, 0))
        TweenService:Create(speedBarFill, TweenInfo.new(0.08), {Size = UDim2.new(spdRatio, 0, 1, 0), BackgroundColor3 = sCol}):Play()
    end
end)

print("════════════════════════════════")
print("⚡ OMNI GHOST v8.12 — MERGED LOADED")
print("GUI: Rebindable Keys + AC Bypass")
print("BHOP: Progressive + AC Evasion")
print("NOCLIP: Safe Mode + WallCheck")
print("────────────────────────────────")
