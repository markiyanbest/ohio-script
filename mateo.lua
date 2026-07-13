-- [[ BLOX STRIKE OMNI GHOST v8.3 - DELTA MOBILE AIMBOT FIX ]]
-- Fixes: Mobile Aimbot повністю переписано для Delta Executor
-- Підтримка: Delta, Arceus X, Fluxus, Hydrogen

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local LP = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Safe VIM
local VIM_OK, VirtualInputManager = pcall(function()
    return game:GetService("VirtualInputManager")
end)
if not VIM_OK then VirtualInputManager = nil end

-- ═══════════════════════════════════════
-- [[ CONFIG ]]
-- ═══════════════════════════════════════
local Config = {
    AimSmoothness        = 0.55,
    FOV                  = 110,
    MaxDistance           = 500,
    Prediction           = 0.042,
    TeamCheck            = true,
    WallCheck            = true,
    AimPart              = "Head",

    -- Mobile Aim (переписано)
    MobileAimMethod      = "auto",  -- "auto", "cframe", "touch", "mouse"
    MobileAimStrength    = 0.7,
    MobileAimSmoothing   = 0.65,
    MobileDeadzone       = 5,
    MobileSensitivity    = 1.8,     -- множник чутливості для планшета
    MobileTabletScale    = 1.4,     -- компенсація великого екрану 12.7"

    TriggerDelay         = 0.05,
    HeadSizeMultiplier   = 2.2,
    HeadTransparency     = 0.6,
    ESPMaxDistance        = 800,
    TextSize             = 14,
    TracerThickness      = 1.5,
    TracerTransparency   = 0.6,
    TeamFireColor        = Color3.fromRGB(0, 150, 255),

    BhopBaseSpeed        = 16,
    BhopMaxJumps         = 28,
    BhopMaxSpeed         = 142,
    BhopDecayRate        = 0.993,
    BhopGroundDecay      = 0.78,
    BhopAirAccel         = 0.88,
    BhopSideForce        = 0.38,
    BhopMinTurn          = 0.25,
    BhopJumpWindow       = 0.065,
    BhopNoiseScale       = 0.75,

    ACVelocityNoise      = 2.1,
    ACMaxVelChange       = 17,
    ACJumpNoise          = 0.008,

    ESPUpdateRate        = 1/30,
    HitboxUpdateRate     = 0.22,
    TargetSearchRate     = 0.07,
    WallCheckCacheTime   = 0.07,
    PlayerListCacheTime  = 0.75,
    UIUpdateRate         = 0.4,
    VisCacheCleanup      = 30,
    NoClipTickRate       = 0.03,
    NoClipDamageProtect  = true,
}

local States = {
    Aimbot     = false,
    Triggerbot = false,
    ESP        = false,
    Hitbox     = false,
    Bhop       = false,
    NoClip     = false,
    TeamFire   = false,
}

local Bhop = {
    jumpCount       = 0,
    currentSpeed    = 0,
    peakSpeed       = 0,
    lastCamAngle    = 0,
    turnDirection   = 0,
    turnSpeed       = 0,
    perfectJumps    = 0,
    lastShownStreak = 0,
    wasOnGround     = true,
    onGroundFrames  = 0,
    lastJumpTime    = 0,
    lastLandTime    = 0,
    jumpImpulseDone = false,
    streakActive    = false,
    mobileJumpHeld  = false,
}

local LockedTarget = nil
local statusText   = ""
local hitboxCount  = 0
local aimMethodUsed = "none"

local ResetAllHeads, UpdateUI, RestoreCollision

local IsMobile    = UIS.TouchEnabled and not UIS.KeyboardEnabled
local IsPC        = not IsMobile
local DeviceLabel = IsMobile and "MOB" or "PC"

-- Детекція розміру екрану для планшета
local function GetScreenScale()
    local vp = Camera.ViewportSize
    local diagonal = math.sqrt(vp.X^2 + vp.Y^2)
    -- 12.7" планшет зазвичай ~2560x1600 або 2732x2048
    if diagonal > 2000 then
        return Config.MobileTabletScale
    elseif diagonal > 1500 then
        return Config.MobileTabletScale * 0.85
    end
    return 1.0
end

-- ═══════════════════════════════════════
-- [[ CONNECTIONS MANAGER ]]
-- ═══════════════════════════════════════
local PlayerConnections = {}
local ScriptConnections = {}

local function AddPlayerConn(p, conn)
    if not PlayerConnections[p] then PlayerConnections[p] = {} end
    table.insert(PlayerConnections[p], conn)
end

local function CleanPlayerConns(p)
    if PlayerConnections[p] then
        for _, c in ipairs(PlayerConnections[p]) do
            pcall(function() c:Disconnect() end)
        end
        PlayerConnections[p] = nil
    end
end

local function AddScriptConn(conn)
    table.insert(ScriptConnections, conn)
    return conn
end

-- ═══════════════════════════════════════
-- [[ ОЧИЩЕННЯ СТАРИХ GUI ]]
-- ═══════════════════════════════════════
local CoreGui = game:GetService("CoreGui")
pcall(function()
    local names = {
        "OmniGhostUI_v2","OmniGhostUI_v3","OmniGhostUI_v4","OmniGhostUI_v5",
        "OmniGhostUI_v6","OmniGhostUI_v7","OmniGhostUI_v74","OmniGhostUI_v75",
        "OmniGhostUI_v76","OmniGhostUI_v77","OmniGhostUI_v78","OmniGhostUI_v79",
        "OmniGhostUI_v79f","OmniGhostUI_v80","OmniGhostUI_v81","OmniGhostUI_v82",
        "OmniGhostUI_v83"
    }
    local containers = {CoreGui, LP.PlayerGui}
    if type(gethui) == "function" then table.insert(containers, gethui()) end
    for _, n in ipairs(names) do
        for _, g in ipairs(containers) do
            local o = g:FindFirstChild(n)
            if o then pcall(function() o:Destroy() end) end
        end
    end
end)

-- ═══════════════════════════════════════
-- [[ UI ]]
-- ═══════════════════════════════════════
local uiGui = Instance.new("ScreenGui")
uiGui.Name           = "OmniGhostUI_v83"
uiGui.ResetOnSpawn   = false
uiGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
uiGui.IgnoreGuiInset = true

local parent
pcall(function() parent = gethui and gethui() or CoreGui end)
if not parent then parent = LP:WaitForChild("PlayerGui") end
uiGui.Parent = parent

local mainPanel = Instance.new("Frame", uiGui)
mainPanel.Size                   = UDim2.new(0, 155, 0, 170)
mainPanel.Position               = UDim2.new(0, 8, 0, 35)
mainPanel.BackgroundColor3       = Color3.fromRGB(5, 5, 10)
mainPanel.BackgroundTransparency = 0.08
mainPanel.BorderSizePixel        = 0
mainPanel.Active                 = true
Instance.new("UICorner", mainPanel).CornerRadius = UDim.new(0, 7)

local mainStroke     = Instance.new("UIStroke", mainPanel)
mainStroke.Thickness = 1.2
mainStroke.Color     = Color3.fromRGB(255, 40, 40)

task.spawn(function()
    local cols = {
        Color3.fromRGB(255, 40, 40),
        Color3.fromRGB(255, 100, 0),
        Color3.fromRGB(255, 200, 0),
        Color3.fromRGB(255, 40, 40),
    }
    local i = 1
    while uiGui.Parent do
        i = (i % #cols) + 1
        TweenService:Create(mainStroke,
            TweenInfo.new(1.8, Enum.EasingStyle.Sine), {Color = cols[i]}
        ):Play()
        task.wait(1.8)
    end
end)

local titleText = Instance.new("TextLabel", mainPanel)
titleText.Size                   = UDim2.new(1, 0, 0, 14)
titleText.BackgroundTransparency = 1
titleText.Text                   = "⚡ OMNI v8.3 △"
titleText.Font                   = Enum.Font.GothamBlack
titleText.TextSize               = 9
titleText.TextColor3             = Color3.fromRGB(255, 60, 60)

local uiText = Instance.new("TextLabel", mainPanel)
uiText.Size                   = UDim2.new(1, -8, 1, -28)
uiText.Position               = UDim2.new(0, 4, 0, 15)
uiText.BackgroundTransparency = 1
uiText.RichText               = true
uiText.TextXAlignment         = Enum.TextXAlignment.Left
uiText.TextYAlignment         = Enum.TextYAlignment.Top
uiText.Font                   = Enum.Font.GothamBold
uiText.TextSize               = 9
uiText.TextColor3             = Color3.fromRGB(210, 210, 210)
uiText.TextWrapped            = true

-- Bhop bar
local bhopBarBg = Instance.new("Frame", mainPanel)
bhopBarBg.Size             = UDim2.new(1, -10, 0, 5)
bhopBarBg.Position         = UDim2.new(0, 5, 1, -18)
bhopBarBg.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
bhopBarBg.BorderSizePixel  = 0
Instance.new("UICorner", bhopBarBg).CornerRadius = UDim.new(0, 3)

local bhopBarLabel = Instance.new("TextLabel", bhopBarBg)
bhopBarLabel.Size                   = UDim2.new(1, 0, 0, 9)
bhopBarLabel.Position               = UDim2.new(0, 0, -2.2, 0)
bhopBarLabel.BackgroundTransparency = 1
bhopBarLabel.Font                   = Enum.Font.GothamBold
bhopBarLabel.TextSize               = 7
bhopBarLabel.TextColor3             = Color3.fromRGB(150, 150, 150)
bhopBarLabel.Text                   = "BHOP"
bhopBarLabel.TextXAlignment         = Enum.TextXAlignment.Left

local bhopBarFill = Instance.new("Frame", bhopBarBg)
bhopBarFill.Size             = UDim2.new(0, 0, 1, 0)
bhopBarFill.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
bhopBarFill.BorderSizePixel  = 0
Instance.new("UICorner", bhopBarFill).CornerRadius = UDim.new(0, 3)

-- Speed bar
local speedBarBg = Instance.new("Frame", mainPanel)
speedBarBg.Size             = UDim2.new(1, -10, 0, 5)
speedBarBg.Position         = UDim2.new(0, 5, 1, -9)
speedBarBg.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
speedBarBg.BorderSizePixel  = 0
Instance.new("UICorner", speedBarBg).CornerRadius = UDim.new(0, 3)

local speedBarLabel = Instance.new("TextLabel", speedBarBg)
speedBarLabel.Size                   = UDim2.new(1, 0, 0, 9)
speedBarLabel.Position               = UDim2.new(0, 0, -2.2, 0)
speedBarLabel.BackgroundTransparency = 1
speedBarLabel.Font                   = Enum.Font.GothamBold
speedBarLabel.TextSize               = 7
speedBarLabel.TextColor3             = Color3.fromRGB(150, 150, 150)
speedBarLabel.Text                   = "SPD"
speedBarLabel.TextXAlignment         = Enum.TextXAlignment.Left

local speedBarFill = Instance.new("Frame", speedBarBg)
speedBarFill.Size             = UDim2.new(0, 0, 1, 0)
speedBarFill.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
speedBarFill.BorderSizePixel  = 0
Instance.new("UICorner", speedBarFill).CornerRadius = UDim.new(0, 3)

-- Lock indicator
local lockIndicator = Instance.new("TextLabel", uiGui)
lockIndicator.Size                   = UDim2.new(0, 140, 0, 15)
lockIndicator.Position               = UDim2.new(0.5, -70, 0, 22)
lockIndicator.BackgroundColor3       = Color3.fromRGB(15, 15, 25)
lockIndicator.BackgroundTransparency = 0.35
lockIndicator.BorderSizePixel        = 0
lockIndicator.Font                   = Enum.Font.GothamBold
lockIndicator.TextSize               = 9
lockIndicator.TextColor3             = Color3.fromRGB(255, 255, 255)
lockIndicator.Visible                = false
Instance.new("UICorner", lockIndicator).CornerRadius = UDim.new(0, 4)

-- TeamFire banner
local teamFireBanner = Instance.new("TextLabel", uiGui)
teamFireBanner.Size                   = UDim2.new(0, 90, 0, 13)
teamFireBanner.Position               = UDim2.new(0.5, -45, 0, 8)
teamFireBanner.BackgroundColor3       = Color3.fromRGB(0, 80, 200)
teamFireBanner.BackgroundTransparency = 0.45
teamFireBanner.BorderSizePixel        = 0
teamFireBanner.Font                   = Enum.Font.GothamBold
teamFireBanner.TextSize               = 8
teamFireBanner.TextColor3             = Color3.fromRGB(255, 255, 255)
teamFireBanner.Text                   = "🔵 TEAMFIRE ON"
teamFireBanner.Visible                = false
Instance.new("UICorner", teamFireBanner).CornerRadius = UDim.new(0, 3)

-- Aim method indicator
local aimMethodLabel = Instance.new("TextLabel", uiGui)
aimMethodLabel.Size                   = UDim2.new(0, 100, 0, 12)
aimMethodLabel.Position               = UDim2.new(0.5, -50, 0, 38)
aimMethodLabel.BackgroundColor3       = Color3.fromRGB(10, 10, 20)
aimMethodLabel.BackgroundTransparency = 0.5
aimMethodLabel.BorderSizePixel        = 0
aimMethodLabel.Font                   = Enum.Font.GothamBold
aimMethodLabel.TextSize               = 7
aimMethodLabel.TextColor3             = Color3.fromRGB(180, 180, 180)
aimMethodLabel.Visible                = false
Instance.new("UICorner", aimMethodLabel).CornerRadius = UDim.new(0, 3)

-- Streak label
local streakLabel = Instance.new("TextLabel", uiGui)
streakLabel.Size                   = UDim2.new(0, 140, 0, 20)
streakLabel.Position               = UDim2.new(0.5, -70, 0.5, -60)
streakLabel.BackgroundColor3       = Color3.fromRGB(255, 150, 0)
streakLabel.BackgroundTransparency = 0.3
streakLabel.BorderSizePixel        = 0
streakLabel.Font                   = Enum.Font.GothamBlack
streakLabel.TextSize               = 11
streakLabel.TextColor3             = Color3.fromRGB(255, 255, 255)
streakLabel.Text                   = ""
streakLabel.Visible                = false
Instance.new("UICorner", streakLabel).CornerRadius = UDim.new(0, 5)

local function ShowStreak(text, color)
    if not streakLabel or not streakLabel.Parent then return end
    streakLabel.Text                   = text
    streakLabel.BackgroundColor3       = color or Color3.fromRGB(255, 150, 0)
    streakLabel.Visible                = true
    streakLabel.TextTransparency       = 0
    streakLabel.BackgroundTransparency = 0.3
    TweenService:Create(streakLabel, TweenInfo.new(1.5, Enum.EasingStyle.Quad), {
        TextTransparency       = 1,
        BackgroundTransparency = 1,
    }):Play()
    task.delay(1.6, function()
        if streakLabel then streakLabel.Visible = false end
    end)
end

-- ═══════════════════════════════════════
-- [[ МОБІЛЬНІ КНОПКИ ]]
-- ═══════════════════════════════════════
local BtnStrokes = {}
local btnFrame, mobileJumpBtn

if IsMobile then
    btnFrame = Instance.new("Frame", uiGui)
    btnFrame.Size                   = UDim2.new(0, 50, 0, 400)
    btnFrame.Position               = UDim2.new(1, -58, 0.5, -200)
    btnFrame.BackgroundTransparency = 1
    btnFrame.Active                 = true

    local layout = Instance.new("UIListLayout", btnFrame)
    layout.SortOrder           = Enum.SortOrder.LayoutOrder
    layout.Padding             = UDim.new(0, 4)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local function MkBtn(icon, label, key, order, cb)
        local btn = Instance.new("TextButton")
        btn.Size                   = UDim2.new(0, 46, 0, 46)
        btn.BackgroundColor3       = Color3.fromRGB(10, 10, 18)
        btn.BackgroundTransparency = 0.06
        btn.BorderSizePixel        = 0
        btn.Text                   = icon.."\n"..label
        btn.TextColor3             = Color3.fromRGB(200, 200, 200)
        btn.Font                   = Enum.Font.GothamBold
        btn.TextSize               = 7
        btn.AutoButtonColor        = false
        btn.LayoutOrder            = order
        btn.Parent                 = btnFrame
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 9)

        local bs     = Instance.new("UIStroke", btn)
        bs.Color     = Color3.fromRGB(50, 50, 50)
        bs.Thickness = 1
        BtnStrokes[key] = bs

        btn.MouseButton1Click:Connect(function()
            if cb then
                cb()
            else
                States[key] = not States[key]
                if key == "Hitbox" and not States.Hitbox and ResetAllHeads then
                    ResetAllHeads()
                end
                if key == "Aimbot" then
                    LockedTarget          = nil
                    lockIndicator.Visible = false
                    aimMethodLabel.Visible = false
                end
                if key == "NoClip" and not States.NoClip and RestoreCollision then
                    RestoreCollision()
                end
                if key == "TeamFire" then
                    teamFireBanner.Visible = States.TeamFire
                    LockedTarget           = nil
                    if ResetAllHeads then ResetAllHeads() end
                end
                if key == "Bhop" and not States.Bhop then
                    Bhop.jumpCount    = 0
                    Bhop.currentSpeed = 0
                    Bhop.peakSpeed    = 0
                    Bhop.streakActive = false
                end
            end
            if UpdateUI then UpdateUI() end
            TweenService:Create(btn, TweenInfo.new(0.06), {
                Size = UDim2.new(0, 40, 0, 40)
            }):Play()
            task.wait(0.06)
            TweenService:Create(btn,
                TweenInfo.new(0.12, Enum.EasingStyle.Back),
                {Size = UDim2.new(0, 46, 0, 46)}
            ):Play()
        end)
    end

    MkBtn("🎯","AIM",  "Aimbot",    1)
    MkBtn("🔫","TRIG", "Triggerbot",2)
    MkBtn("👁","ESP",  "ESP",       3)
    MkBtn("💀","HEAD", "Hitbox",    4)
    MkBtn("🐇","BHOP", "Bhop",      5)
    MkBtn("👻","CLIP", "NoClip",    6)
    MkBtn("🔵","TEAM", "TeamFire",  7)

    mobileJumpBtn = Instance.new("TextButton", uiGui)
    mobileJumpBtn.Size                   = UDim2.new(0, 75, 0, 75)
    mobileJumpBtn.Position               = UDim2.new(1, -90, 1, -100)
    mobileJumpBtn.BackgroundColor3       = Color3.fromRGB(255, 180, 0)
    mobileJumpBtn.BackgroundTransparency = 0.22
    mobileJumpBtn.BorderSizePixel        = 0
    mobileJumpBtn.Text                   = "🐇"
    mobileJumpBtn.Font                   = Enum.Font.GothamBlack
    mobileJumpBtn.TextSize               = 26
    mobileJumpBtn.AutoButtonColor        = false
    mobileJumpBtn.Visible                = false
    Instance.new("UICorner", mobileJumpBtn).CornerRadius = UDim.new(0.5, 0)

    mobileJumpBtn.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch then
            Bhop.mobileJumpHeld = true
        end
    end)
    mobileJumpBtn.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch then
            Bhop.mobileJumpHeld = false
        end
    end)
end

local function UpdateButtons()
    if not IsMobile then return end
    local onC  = Color3.fromRGB(0, 255, 100)
    local offC = Color3.fromRGB(50, 50, 50)
    local blC  = Color3.fromRGB(0, 150, 255)
    for k, s in pairs(BtnStrokes) do
        local target = States[k]
            and (k == "TeamFire" and blC or onC)
            or offC
        TweenService:Create(s, TweenInfo.new(0.12), {Color = target}):Play()
    end
    if mobileJumpBtn then
        mobileJumpBtn.Visible = States.Bhop
    end
end

UpdateUI = function()
    local on   = "<font color='#00ff77'>ON</font>"
    local off  = "<font color='#ff3333'>OFF</font>"
    local tfon = "<font color='#0096ff'>ON</font>"

    local bhopLine = ""
    if States.Bhop then
        local arrow = Bhop.turnDirection > 0 and "→"
                   or Bhop.turnDirection < 0 and "←"
                   or "·"
        bhopLine = string.format(
            "\n<font color='#ffcc00'>%s J%d %.0fst/s</font>",
            arrow, Bhop.jumpCount, math.floor(Bhop.currentSpeed)
        )
    end

    local aimLine = ""
    if States.Aimbot and IsMobile then
        aimLine = string.format("\n<font color='#88aaff'>AIM:%s</font>", aimMethodUsed)
    end

    uiText.Text = string.format(
        "<font color='#ff6644'>T</font>Aim:%s <font color='#ff6644'>Y</font>Trig:%s\n"..
        "<font color='#ff6644'>U</font>ESP:%s <font color='#ff6644'>H</font>Head:%s\n"..
        "<font color='#ff6644'>L</font>Bhop:%s <font color='#ff6644'>K</font>Clip:%s\n"..
        "<font color='#0096ff'>F</font>TFire:%s%s%s\n"..
        "<font color='#555555'>%s</font>",
        States.Aimbot     and on   or off,
        States.Triggerbot and on   or off,
        States.ESP        and on   or off,
        States.Hitbox     and on   or off,
        States.Bhop       and on   or off,
        States.NoClip     and on   or off,
        States.TeamFire   and tfon or off,
        bhopLine,
        aimLine,
        statusText
    )
    UpdateButtons()

    local ratio = math.clamp(Bhop.jumpCount / math.max(Config.BhopMaxJumps, 1), 0, 1)
    local col
    if     ratio < 0.33 then col = Color3.fromRGB(0, 255, 100)
    elseif ratio < 0.66 then col = Color3.fromRGB(255, 220, 0)
    else                      col = Color3.fromRGB(255, 80, 0) end

    TweenService:Create(bhopBarFill, TweenInfo.new(0.08), {
        Size             = UDim2.new(ratio, 0, 1, 0),
        BackgroundColor3 = col,
    }):Play()
end
UpdateUI()

-- ═══════════════════════════════════════
-- [[ MAKEDRAGGABLE ]]
-- ═══════════════════════════════════════
local function MakeDraggable(frame)
    local dragging  = false
    local dragStart = Vector3.zero
    local startPos  = UDim2.new()
    local dragConn  = nil

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = input.Position
            startPos  = frame.Position
            if dragConn then dragConn:Disconnect() end
            dragConn = UIS.InputChanged:Connect(function(inp)
                if not dragging then
                    dragConn:Disconnect()
                    dragConn = nil
                    return
                end
                if inp.UserInputType == Enum.UserInputType.MouseMovement
                or inp.UserInputType == Enum.UserInputType.Touch then
                    local d = inp.Position - dragStart
                    frame.Position = UDim2.new(
                        startPos.X.Scale, startPos.X.Offset + d.X,
                        startPos.Y.Scale, startPos.Y.Offset + d.Y
                    )
                end
            end)
        end
    end)

    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            if dragConn then
                dragConn:Disconnect()
                dragConn = nil
            end
        end
    end)
end

MakeDraggable(mainPanel)
if btnFrame      then MakeDraggable(btnFrame)      end
if mobileJumpBtn then MakeDraggable(mobileJumpBtn) end

-- ═══════════════════════════════════════
-- [[ FOV CIRCLE ]]
-- ═══════════════════════════════════════
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness    = 1.8
FOVCircle.Filled       = false
FOVCircle.Transparency = 0.65
FOVCircle.Visible      = false
pcall(function() FOVCircle.NumSides = 64 end)

-- ═══════════════════════════════════════
-- [[ УТИЛІТИ ]]
-- ═══════════════════════════════════════
local function SafeNumber(n, fallback)
    if type(n) ~= "number" or n ~= n or n == math.huge or n == -math.huge then
        return fallback or 0
    end
    return n
end

local function IsTeammate(p)
    if States.TeamFire then return false end
    if not Config.TeamCheck then return false end
    local my    = LP:GetAttribute("Team")
    local their = p:GetAttribute("Team")
    if not my or not their then return false end
    return my == their
end

local function IsRealTeammate(p)
    if not Config.TeamCheck then return false end
    local my    = LP:GetAttribute("Team")
    local their = p:GetAttribute("Team")
    if not my or not their then return false end
    return my == their
end

local function IsAlive(p)
    local c = p.Character
    if not c then return false end
    local h = c:FindFirstChildOfClass("Humanoid")
    if not h or h.Health <= 0 then return false end
    if p:GetAttribute("IsSpectating") then return false end
    return c:FindFirstChild("HumanoidRootPart") ~= nil
end

local function GetAimPart(char)
    if not char then return nil end
    local direct = char:FindFirstChild(Config.AimPart)
    if direct and direct:IsA("BasePart") then return direct end
    local recursive = char:FindFirstChild(Config.AimPart, true)
    if recursive and recursive:IsA("BasePart") then return recursive end
    local head = char:FindFirstChild("Head") or char:FindFirstChild("Head", true)
    if head and head:IsA("BasePart") then return head end
    local hrp = char:FindFirstChild("HumanoidRootPart")
        or char:FindFirstChild("HumanoidRootPart", true)
    if hrp and hrp:IsA("BasePart") then return hrp end
    for _, v in ipairs(char:GetDescendants()) do
        if v:IsA("BasePart") then return v end
    end
    return nil
end

local cachedEnemies   = {}
local lastPlayerCache = 0

local function GetAllPlayers()
    local now = tick()
    if (now - lastPlayerCache) < Config.PlayerListCacheTime then
        return cachedEnemies
    end
    lastPlayerCache = now
    cachedEnemies   = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then table.insert(cachedEnemies, p) end
    end
    return cachedEnemies
end

local rayParams = RaycastParams.new()
rayParams.FilterType  = Enum.RaycastFilterType.Exclude
rayParams.IgnoreWater = true

local visibilityCache     = {}
local lastVisCacheCleanup = tick()

local function CleanVisibilityCache()
    local now    = tick()
    local maxAge = Config.WallCheckCacheTime * 3
    for id, c in pairs(visibilityCache) do
        if (now - c.time) > maxAge then
            visibilityCache[id] = nil
        end
    end
end

local function IsVisible(tp, tc)
    if not tp or not tc or not LP.Character then return false end
    local o = Camera.CFrame.Position
    local d = tp.Position - o
    if d.Magnitude < 1 then return true end
    rayParams.FilterDescendantsInstances = {LP.Character, Camera}
    local r = Workspace:Raycast(o, d, rayParams)
    if not r then return true end
    return r.Instance:IsDescendantOf(tc)
end

local function IsVisibleCached(tp, tc, id)
    local now = tick()
    if (now - lastVisCacheCleanup) > Config.VisCacheCleanup then
        lastVisCacheCleanup = now
        CleanVisibilityCache()
    end
    local c = visibilityCache[id]
    if c and (now - c.time) < Config.WallCheckCacheTime then return c.value end
    local r = IsVisible(tp, tc)
    visibilityCache[id] = {value = r, time = now}
    return r
end

-- ═══════════════════════════════════════
-- [[ MOBILE AIMBOT — DELTA FIX v3 ]]
-- ═══════════════════════════════════════
-- Три методи: CFrame (найнадійніший), Touch (VIM), Mouse (VIM fallback)

local MobileAim = {
    method       = "none",    -- поточний метод
    tested       = false,     -- чи вже протестували
    touchActive  = false,
    touchPos     = Vector2.new(0, 0),
    touchId      = 987654,    -- великий ID щоб не конфліктувати
    lastMoveTime = 0,
    accumX       = 0,
    accumY       = 0,
    smoothVelX   = 0,
    smoothVelY   = 0,
}

-- Метод 1: CFrame — напряму повертаємо камеру (найнадійніший для Delta)
local function AimMethod_CFrame(targetPos, dt)
    local camPos = Camera.CFrame.Position
    local dir = (targetPos - camPos)
    if dir.Magnitude < 0.01 then return true end
    dir = dir.Unit

    local targetCF = CFrame.lookAt(camPos, camPos + dir)
    local currentCF = Camera.CFrame

    -- Плавна інтерполяція
    local smooth = Config.MobileAimSmoothing * Config.MobileSensitivity
    smooth = math.clamp(smooth, 0.05, 0.95)

    local newCF = currentCF:Lerp(targetCF, smooth)

    local ok = pcall(function()
        Camera.CFrame = newCF
    end)
    return ok
end

-- Метод 2: VIM SendMouseMoveEvent (емуляція миші)
local function AimMethod_Mouse(screenDiff, dt)
    if not VirtualInputManager then return false end

    local scale = GetScreenScale()
    local str = Config.MobileAimStrength * Config.MobileSensitivity * scale

    -- Адаптивна сила
    local dist = screenDiff.Magnitude
    local factor
    if     dist < 5   then factor = 0.1
    elseif dist < 15  then factor = 0.3
    elseif dist < 50  then factor = 0.6
    elseif dist < 150 then factor = 0.85
    else                    factor = 1.0 end

    local moveX = screenDiff.X * str * factor
    local moveY = screenDiff.Y * str * factor

    -- Плавність
    MobileAim.smoothVelX = MobileAim.smoothVelX * (1 - Config.MobileAimSmoothing) + moveX * Config.MobileAimSmoothing
    MobileAim.smoothVelY = MobileAim.smoothVelY * (1 - Config.MobileAimSmoothing) + moveY * Config.MobileAimSmoothing

    local ok = pcall(function()
        -- Delta підтримує mousemoverel через VIM
        VirtualInputManager:SendMouseMoveEvent(MobileAim.smoothVelX, MobileAim.smoothVelY, game)
    end)
    return ok
end

-- Метод 3: VIM Touch свайп (оригінальний, виправлений для Delta)
local function AimMethod_Touch(screenDiff, dt)
    if not VirtualInputManager then return false end

    local vp = Camera.ViewportSize
    local scale = GetScreenScale()
    local str = Config.MobileAimStrength * Config.MobileSensitivity * scale * 0.4

    local dist = screenDiff.Magnitude
    if dist < Config.MobileDeadzone then
        return true -- в мертвій зоні, все ок
    end

    local factor = math.clamp(dist / 200, 0.05, 1.0)
    local moveX = screenDiff.X * str * factor
    local moveY = screenDiff.Y * str * factor

    -- Плавність
    MobileAim.smoothVelX = MobileAim.smoothVelX * 0.3 + moveX * 0.7
    MobileAim.smoothVelY = MobileAim.smoothVelY * 0.3 + moveY * 0.7

    local now = tick()

    -- Починаємо новий тач цикл кожні 0.15 сек (Delta скидає довгі тачі)
    if not MobileAim.touchActive or (now - MobileAim.lastMoveTime) > 0.15 then
        -- Завершити попередній
        if MobileAim.touchActive then
            pcall(function()
                -- Delta: 0 = ended
                VirtualInputManager:SendTouchEvent(
                    MobileAim.touchId,
                    0, -- state: ended
                    MobileAim.touchPos.X,
                    MobileAim.touchPos.Y
                )
            end)
            task.wait(0.001)
        end

        -- Стартова позиція — правий центр екрану (зона огляду)
        MobileAim.touchPos = Vector2.new(vp.X * 0.7, vp.Y * 0.5)
        MobileAim.touchId = MobileAim.touchId + 1
        if MobileAim.touchId > 999999 then MobileAim.touchId = 987654 end

        -- Спробувати різні формати SendTouchEvent
        local ok = false

        -- Формат 1: (id, state, x, y) — деякі версії Delta
        if not ok then
            ok = pcall(function()
                VirtualInputManager:SendTouchEvent(
                    MobileAim.touchId,
                    1, -- state: began
                    MobileAim.touchPos.X,
                    MobileAim.touchPos.Y
                )
            end)
        end

        -- Формат 2: (id, Vector2, bool) — стандартний
        if not ok then
            ok = pcall(function()
                VirtualInputManager:SendTouchEvent(
                    MobileAim.touchId,
                    MobileAim.touchPos,
                    true
                )
            end)
        end

        if not ok then return false end
        MobileAim.touchActive = true
        MobileAim.lastMoveTime = now
        task.wait(0.001)
    end

    -- Рухаємо палець
    local newPos = Vector2.new(
        math.clamp(MobileAim.touchPos.X + MobileAim.smoothVelX, 10, vp.X - 10),
        math.clamp(MobileAim.touchPos.Y + MobileAim.smoothVelY, 10, vp.Y - 10)
    )

    local ok = false

    -- Формат 1: (id, state, x, y)
    if not ok then
        ok = pcall(function()
            VirtualInputManager:SendTouchEvent(
                MobileAim.touchId,
                2, -- state: moved
                newPos.X,
                newPos.Y
            )
        end)
    end

    -- Формат 2: (id, Vector2, bool)
    if not ok then
        ok = pcall(function()
            VirtualInputManager:SendTouchEvent(
                MobileAim.touchId,
                newPos,
                false
            )
        end)
    end

    if ok then
        MobileAim.touchPos = newPos
        MobileAim.lastMoveTime = now
    end

    return ok
end

-- Завершити всі тачі
local function StopMobileAim()
    if MobileAim.touchActive and VirtualInputManager then
        pcall(function()
            VirtualInputManager:SendTouchEvent(MobileAim.touchId, 0, MobileAim.touchPos.X, MobileAim.touchPos.Y)
        end)
        pcall(function()
            VirtualInputManager:SendTouchEvent(MobileAim.touchId, MobileAim.touchPos, true)
        end)
    end
    MobileAim.touchActive = false
    MobileAim.smoothVelX  = 0
    MobileAim.smoothVelY  = 0
end

-- Автовизначення найкращого методу для Delta
local function DetectBestAimMethod()
    if MobileAim.tested then return MobileAim.method end
    MobileAim.tested = true

    -- Тест 1: CFrame (завжди працює)
    local cframeWorks = pcall(function()
        local old = Camera.CFrame
        Camera.CFrame = old
    end)

    -- Тест 2: mousemoverel
    local mmrWorks = false
    if type(mousemoverel) == "function" then
        mmrWorks = pcall(function() mousemoverel(0, 0) end)
    end

    -- Тест 3: VIM mouse
    local vimMouseWorks = false
    if VirtualInputManager then
        vimMouseWorks = pcall(function()
            VirtualInputManager:SendMouseMoveEvent(0, 0, game)
        end)
    end

    -- Тест 4: VIM touch
    local vimTouchWorks = false
    if VirtualInputManager then
        -- Спробувати обидва формати
        vimTouchWorks = pcall(function()
            VirtualInputManager:SendTouchEvent(999999, 1, 0, 0)
            VirtualInputManager:SendTouchEvent(999999, 0, 0, 0)
        end)
        if not vimTouchWorks then
            vimTouchWorks = pcall(function()
                VirtualInputManager:SendTouchEvent(999999, Vector2.new(0,0), true)
                VirtualInputManager:SendTouchEvent(999999, Vector2.new(0,0), true)
            end)
        end
    end

    -- Пріоритет для мобільних:
    -- 1. CFrame — найнадійніший, працює скрізь
    -- 2. mousemoverel — якщо є
    -- 3. VIM Mouse — емуляція
    -- 4. VIM Touch — складний, часто баганий
    if IsMobile then
        if cframeWorks then
            MobileAim.method = "cframe"
        elseif mmrWorks then
            MobileAim.method = "mousemoverel"
        elseif vimMouseWorks then
            MobileAim.method = "vimmouse"
        elseif vimTouchWorks then
            MobileAim.method = "vimtouch"
        else
            MobileAim.method = "cframe" -- fallback
        end
    else
        if mmrWorks then
            MobileAim.method = "mousemoverel"
        else
            MobileAim.method = "cframe"
        end
    end

    aimMethodUsed = MobileAim.method
    print("[OMNI] Aim method: " .. MobileAim.method)
    print("[OMNI] CFrame:" .. tostring(cframeWorks) ..
          " MMR:" .. tostring(mmrWorks) ..
          " VIM-M:" .. tostring(vimMouseWorks) ..
          " VIM-T:" .. tostring(vimTouchWorks))

    return MobileAim.method
end

-- Головна функція мобільного аімботу
local function RunMobileAimbot(targetPart, predicted, dt)
    if not targetPart then
        StopMobileAim()
        return
    end

    local method = DetectBestAimMethod()
    local targetPos = predicted or targetPart.Position

    if method == "cframe" then
        -- CFrame метод — напряму повертаємо камеру
        AimMethod_CFrame(targetPos, dt or 0.016)
        aimMethodUsed = "CF"

    elseif method == "mousemoverel" then
        -- mousemoverel
        local vp = Camera.ViewportSize
        local center = Vector2.new(vp.X / 2, vp.Y / 2)
        local sp, onS = Camera:WorldToViewportPoint(targetPos)
        if not onS then return end
        local diff = Vector2.new(sp.X, sp.Y) - center
        if diff.Magnitude < Config.MobileDeadzone then return end

        local scale = GetScreenScale()
        local sm = Config.MobileAimSmoothing * Config.MobileSensitivity * scale
        if diff.Magnitude < 5 then sm = sm * 0.15
        elseif diff.Magnitude < 15 then sm = sm * 0.4
        elseif diff.Magnitude < 40 then sm = sm * 0.7 end

        pcall(mousemoverel, diff.X * sm, diff.Y * sm)
        aimMethodUsed = "MMR"

    elseif method == "vimmouse" then
        -- VIM Mouse
        local vp = Camera.ViewportSize
        local center = Vector2.new(vp.X / 2, vp.Y / 2)
        local sp, onS = Camera:WorldToViewportPoint(targetPos)
        if not onS then return end
        local diff = Vector2.new(sp.X, sp.Y) - center
        if diff.Magnitude < Config.MobileDeadzone then return end

        if AimMethod_Mouse(diff, dt or 0.016) then
            aimMethodUsed = "VM"
        else
            -- Fallback до CFrame
            AimMethod_CFrame(targetPos, dt or 0.016)
            aimMethodUsed = "CF*"
        end

    elseif method == "vimtouch" then
        -- VIM Touch свайп
        local vp = Camera.ViewportSize
        local center = Vector2.new(vp.X / 2, vp.Y / 2)
        local sp, onS = Camera:WorldToViewportPoint(targetPos)
        if not onS then
            StopMobileAim()
            return
        end
        local diff = Vector2.new(sp.X, sp.Y) - center
        if diff.Magnitude < Config.MobileDeadzone then return end

        if AimMethod_Touch(diff, dt or 0.016) then
            aimMethodUsed = "VT"
        else
            -- Fallback до CFrame
            AimMethod_CFrame(targetPos, dt or 0.016)
            aimMethodUsed = "CF*"
        end
    else
        -- Невідомий метод — CFrame
        AimMethod_CFrame(targetPos, dt or 0.016)
        aimMethodUsed = "CF?"
    end
end

-- ═══════════════════════════════════════
-- [[ BHOP ]]
-- ═══════════════════════════════════════
local function GetCameraYaw()
    local look = Camera.CFrame.LookVector
    if look.Magnitude < 0.001 then return Bhop.lastCamAngle end
    return math.atan2(look.X, look.Z)
end

local function NormalizeAngle(a)
    while a >  math.pi do a = a - math.pi * 2 end
    while a < -math.pi do a = a + math.pi * 2 end
    return a
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
        local dir    = Vector3.zero
        local cf     = Camera.CFrame
        local fwdRaw = Vector3.new(cf.LookVector.X, 0, cf.LookVector.Z)
        local fwd    = fwdRaw.Magnitude > 0.001 and fwdRaw.Unit or Vector3.zero
        local rgtRaw = Vector3.new(cf.RightVector.X, 0, cf.RightVector.Z)
        local rgt    = rgtRaw.Magnitude > 0.001 and rgtRaw.Unit or Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + fwd end
        if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - fwd end
        if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - rgt end
        if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + rgt end
        return dir.Magnitude > 0.001 and dir.Unit or Vector3.zero
    else
        local vel = hrp.AssemblyLinearVelocity
        local h   = Vector3.new(vel.X, 0, vel.Z)
        return h.Magnitude > 2 and h.Unit or Vector3.zero
    end
end

local function ClampVelDelta(old, new_, max)
    local dx  = new_.X - old.X
    local dz  = new_.Z - old.Z
    local mag = math.sqrt(dx*dx + dz*dz)
    if mag > max then
        local s = max / mag
        return Vector3.new(old.X + dx*s, new_.Y, old.Z + dz*s)
    end
    return new_
end

local function GaussianNoise(sigma)
    local u1 = math.max(1e-9, math.random())
    local u2 = math.random()
    local n  = math.sqrt(-2 * math.log(u1)) * math.cos(2 * math.pi * u2)
    return math.clamp(n * sigma, -sigma * 3, sigma * 3)
end

local function GetTargetSpeed()
    local j   = math.clamp(Bhop.jumpCount, 0, Config.BhopMaxJumps)
    local t   = j / Config.BhopMaxJumps
    local spd = Config.BhopBaseSpeed
              + (Config.BhopMaxSpeed - Config.BhopBaseSpeed)
              * (1 - math.exp(-t * 4))
    return math.min(spd, Config.BhopMaxSpeed)
end

AddScriptConn(RunService.Stepped:Connect(function(_, dt)
    if dt <= 0 or dt > 0.5 then return end

    if not States.Bhop then
        if Bhop.currentSpeed > 0 then
            Bhop.currentSpeed = 0
            Bhop.jumpCount    = 0
            Bhop.streakActive = false
        end
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
    local moveDir  = GetMoveDir()
    local isMoving = moveDir.Magnitude > 0.1
    local now      = tick()

    local currentYaw = GetCameraYaw()
    local deltaYaw   = NormalizeAngle(currentYaw - Bhop.lastCamAngle)
    Bhop.lastCamAngle = currentYaw
    deltaYaw = SafeNumber(deltaYaw, 0)
    local deltaDeg = math.abs(math.deg(deltaYaw))

    Bhop.turnSpeed = Bhop.turnSpeed * 0.72 + deltaDeg * 0.28

    if     deltaYaw >  0.002 then Bhop.turnDirection =  1
    elseif deltaYaw < -0.002 then Bhop.turnDirection = -1
    else                          Bhop.turnDirection =  0 end

    local currentVel = hrp.AssemblyLinearVelocity
    local hVel       = Vector3.new(currentVel.X, 0, currentVel.Z)
    local hSpeed     = hVel.Magnitude
    Bhop.currentSpeed = hSpeed

    local velX     = currentVel.X
    local velY     = currentVel.Y
    local velZ     = currentVel.Z
    local velChanged = false

    if onGround then
        if jumpHeld and isMoving then
            Bhop.currentSpeed = Bhop.currentSpeed * 0.995
        else
            Bhop.currentSpeed = Bhop.currentSpeed * Config.BhopGroundDecay
            if (now - Bhop.lastJumpTime) > 0.4 then
                if Bhop.jumpCount > 3 and Bhop.jumpCount ~= Bhop.lastShownStreak then
                    Bhop.lastShownStreak = Bhop.jumpCount
                    task.spawn(function()
                        ShowStreak(
                            "🏆 x"..Bhop.jumpCount.." | "..math.floor(Bhop.peakSpeed).."st/s",
                            Color3.fromRGB(255, 180, 0)
                        )
                    end)
                end
                Bhop.jumpCount    = 0
                Bhop.streakActive = false
            end
        end
    else
        Bhop.currentSpeed = Bhop.currentSpeed * Config.BhopDecayRate
    end

    if not onGround and isMoving and Bhop.turnDirection ~= 0 then
        local rgtRaw = Camera.CFrame.RightVector
        local rgt    = Vector3.new(rgtRaw.X, 0, rgtRaw.Z)
        if rgt.Magnitude > 0.001 then rgt = rgt.Unit end
        local sideForce = rgt * Bhop.turnDirection * Config.BhopSideForce * Bhop.currentSpeed * dt
        local bonus = 0
        if deltaDeg > Config.BhopMinTurn then
            bonus = math.min(deltaDeg * 0.15 * dt * Bhop.jumpCount * 0.5, 3)
        end
        velX = velX + sideForce.X + bonus * moveDir.X
        velZ = velZ + sideForce.Z + bonus * moveDir.Z
        velChanged = true
    end

    if isMoving and not onGround and Bhop.jumpCount > 0 then
        local targetSpeed = GetTargetSpeed()
        local diff = targetSpeed - hSpeed
        if diff > 0 then
            local accel = math.min(diff * Config.BhopAirAccel * dt * 3.5, Config.ACMaxVelChange * dt * 60 * 0.5)
            if moveDir.Magnitude > 0.001 then
                velX = velX + moveDir.X * accel
                velZ = velZ + moveDir.Z * accel
                velChanged = true
            end
        end
    end

    if velChanged then
        velX = velX + GaussianNoise(Config.ACVelocityNoise * 0.4)
        velZ = velZ + GaussianNoise(Config.ACVelocityNoise * 0.4)
    end

    if jumpHeld and onGround and isMoving then
        local jitter = Config.ACJumpNoise * math.random()
        if (now - Bhop.lastJumpTime) >= (0.015 + jitter) and Bhop.onGroundFrames <= 3 then
            Bhop.lastJumpTime = now
            Bhop.jumpCount    = Bhop.jumpCount + 1
            Bhop.streakActive = true

            local landDelta = now - Bhop.lastLandTime
            local isPerfect = landDelta < Config.BhopJumpWindow

            if isPerfect then
                Bhop.perfectJumps = Bhop.perfectJumps + 1
                if Bhop.jumpCount % 5 == 0 and Bhop.jumpCount ~= Bhop.lastShownStreak then
                    Bhop.lastShownStreak = Bhop.jumpCount
                    task.spawn(function()
                        ShowStreak("✨ PERFECT x"..Bhop.perfectJumps, Color3.fromRGB(0, 220, 255))
                    end)
                end
            end

            if not Bhop.jumpImpulseDone then
                Bhop.jumpImpulseDone = true
                local targetSpeed  = GetTargetSpeed()
                local impulseScale = math.clamp(targetSpeed / math.max(hSpeed, 1), 0.8, 2.2)
                if isPerfect then impulseScale = impulseScale * 1.15 end
                velX = velX + moveDir.X * targetSpeed * impulseScale * 0.12 + GaussianNoise(Config.BhopNoiseScale)
                velZ = velZ + moveDir.Z * targetSpeed * impulseScale * 0.12 + GaussianNoise(Config.BhopNoiseScale)
                velY = velY + 1.5 + (isPerfect and 0.5 or 0)
                velChanged = true
            end

            pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end)

            local sp2 = Vector3.new(velX, 0, velZ).Magnitude
            if sp2 > Bhop.peakSpeed then Bhop.peakSpeed = sp2 end
        end
    end

    if onGround and not Bhop.wasOnGround then
        Bhop.lastLandTime    = now
        Bhop.jumpImpulseDone = false
        Bhop.onGroundFrames  = 0
    end
    if onGround then Bhop.onGroundFrames = Bhop.onGroundFrames + 1
    else              Bhop.onGroundFrames = 0 end
    Bhop.wasOnGround = onGround

    if velChanged then
        velX = math.clamp(velX, -Config.BhopMaxSpeed, Config.BhopMaxSpeed)
        velZ = math.clamp(velZ, -Config.BhopMaxSpeed, Config.BhopMaxSpeed)
        local newVel  = Vector3.new(velX, velY, velZ)
        local clamped = ClampVelDelta(currentVel, newVel, Config.ACMaxVelChange * dt * 60)
        pcall(function() hrp.AssemblyLinearVelocity = clamped end)
    end
end))

-- ═══════════════════════════════════════
-- [[ NOCLIP ]]
-- ═══════════════════════════════════════
local noClipParts     = {}
local lastSafePos     = nil
local lastSafePosTime = 0
local noClipTimer     = 0

local function IsInsideWall()
    local char = LP.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    local cp = RaycastParams.new()
    cp.FilterType                 = Enum.RaycastFilterType.Exclude
    cp.FilterDescendantsInstances = {char}
    local wc = 0
    for _, d in ipairs({
        Vector3.new(1,0,0), Vector3.new(-1,0,0),
        Vector3.new(0,0,1), Vector3.new(0,0,-1),
        Vector3.new(0,1,0), Vector3.new(0,-1,0),
    }) do
        if Workspace:Raycast(hrp.Position, d * 2.5, cp) then wc = wc + 1 end
    end
    return wc >= 4
end

local function UpdateSafePos()
    local char = LP.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local cp = RaycastParams.new()
    cp.FilterType                 = Enum.RaycastFilterType.Exclude
    cp.FilterDescendantsInstances = {char}
    if Workspace:Raycast(hrp.Position, Vector3.new(0, -10, 0), cp) then
        lastSafePos     = hrp.CFrame
        lastSafePosTime = tick()
    end
end

RestoreCollision = function()
    for part, val in pairs(noClipParts) do
        pcall(function()
            if part and part.Parent then part.CanCollide = val end
        end)
    end
    noClipParts = {}
end

local function RunNoClip(dt)
    if not States.NoClip then
        if next(noClipParts) then RestoreCollision() end
        if (tick() - lastSafePosTime) > 0.5 then UpdateSafePos() end
        return
    end
    local char = LP.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    if Config.NoClipDamageProtect and IsInsideWall() then
        if hum.Health < hum.MaxHealth * 0.8 and lastSafePos then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                pcall(function()
                    hrp.CFrame                 = lastSafePos
                    hrp.AssemblyLinearVelocity = Vector3.zero
                end)
            end
            return
        end
    end

    noClipTimer = noClipTimer + dt
    if noClipTimer >= Config.NoClipTickRate then
        noClipTimer = 0
        local toClean = {}
        for part in pairs(noClipParts) do
            if not part or not part.Parent then table.insert(toClean, part) end
        end
        for _, p2 in ipairs(toClean) do noClipParts[p2] = nil end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                if noClipParts[part] == nil then noClipParts[part] = part.CanCollide end
                part.CanCollide = false
            end
        end
    end

    if not IsInsideWall() and (tick() - lastSafePosTime) > 0.3 then UpdateSafePos() end
end

-- ═══════════════════════════════════════
-- [[ HITBOX ]]
-- ═══════════════════════════════════════
local OriginalHeads = {}

local function EnlargeHead(p)
    local c = p.Character
    if not c then return end
    local h = c:FindFirstChild("Head") or c:FindFirstChild("Head", true)
    if not h or not h:IsA("BasePart") then return end
    if not OriginalHeads[p] then
        OriginalHeads[p] = {
            Size = h.Size, Transparency = h.Transparency,
            Color = h.Color, Material = h.Material,
            CanCollide = h.CanCollide, Massless = h.Massless,
        }
    end
    pcall(function()
        h.Size         = OriginalHeads[p].Size * Config.HeadSizeMultiplier
        h.Transparency = Config.HeadTransparency
        h.Color        = Color3.fromRGB(255, 40, 40)
        h.Material     = Enum.Material.Neon
        h.CanCollide   = false
        h.Massless     = true
    end)
end

local function RestoreHead(p)
    local o = OriginalHeads[p]
    if not o then return end
    local c = p.Character
    if c then
        local h = c:FindFirstChild("Head") or c:FindFirstChild("Head", true)
        if h and h:IsA("BasePart") then
            pcall(function()
                h.Size = o.Size; h.Transparency = o.Transparency
                h.Color = o.Color; h.Material = o.Material
                h.CanCollide = o.CanCollide; h.Massless = o.Massless
            end)
        end
    end
    OriginalHeads[p] = nil
end

ResetAllHeads = function()
    for p in pairs(OriginalHeads) do pcall(function() RestoreHead(p) end) end
    OriginalHeads = {}
end

local function UpdateHitboxes()
    if not States.Hitbox then
        if next(OriginalHeads) then ResetAllHeads() end
        hitboxCount = 0
        return
    end
    hitboxCount = 0
    for _, p in ipairs(GetAllPlayers()) do
        if not IsAlive(p) then
            if OriginalHeads[p] then RestoreHead(p) end
            continue
        end
        local ra = IsRealTeammate(p)
        if (ra and States.TeamFire) or not ra then
            EnlargeHead(p)
            hitboxCount = hitboxCount + 1
        else
            if OriginalHeads[p] then RestoreHead(p) end
        end
    end
end

local function SetupPlayer(p)
    local conn = p.CharacterAdded:Connect(function()
        OriginalHeads[p] = nil
        task.wait(1)
        if States.Hitbox and IsAlive(p) then
            pcall(function() EnlargeHead(p) end)
        end
    end)
    AddPlayerConn(p, conn)
end

for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LP then SetupPlayer(p) end
end

AddScriptConn(Players.PlayerAdded:Connect(function(p)
    SetupPlayer(p)
    lastPlayerCache = 0
end))

AddScriptConn(Players.PlayerRemoving:Connect(function(p)
    CleanPlayerConns(p)
    if OriginalHeads[p] then RestoreHead(p) end
    visibilityCache[p.UserId] = nil
    lastPlayerCache = 0
end))

-- ═══════════════════════════════════════
-- [[ ESP ]]
-- ═══════════════════════════════════════
local ESPObjects  = {}
local AllDrawings = {}

local function TrackDrawing(d)
    AllDrawings[d] = true
    return d
end

local function CreateESP(p)
    if ESPObjects[p] then
        local old = ESPObjects[p]
        for _, d in pairs(old) do
            pcall(function() AllDrawings[d] = nil; d:Remove() end)
        end
    end
    local function ND(t) return TrackDrawing(Drawing.new(t)) end
    local e = {}

    e.boxOut              = ND("Square")
    e.boxOut.Thickness    = 3
    e.boxOut.Color        = Color3.new(0,0,0)
    e.boxOut.Filled       = false
    e.boxOut.Visible      = false
    e.boxOut.Transparency = 0.5

    e.box           = ND("Square")
    e.box.Thickness = 1.5
    e.box.Filled    = false
    e.box.Visible   = false

    e.name         = ND("Text")
    e.name.Size    = Config.TextSize
    e.name.Color   = Color3.new(1,1,1)
    e.name.Outline = true
    e.name.Center  = true
    e.name.Visible = false

    e.tl         = ND("Text")
    e.tl.Size    = 9
    e.tl.Outline = true
    e.tl.Center  = true
    e.tl.Visible = false

    e.dist         = ND("Text")
    e.dist.Size    = 11
    e.dist.Color   = Color3.fromRGB(180,180,180)
    e.dist.Outline = true
    e.dist.Center  = true
    e.dist.Visible = false

    e.hpBg           = ND("Line")
    e.hpBg.Thickness = 5
    e.hpBg.Color     = Color3.fromRGB(25,25,25)
    e.hpBg.Visible   = false

    e.hp           = ND("Line")
    e.hp.Thickness = 3
    e.hp.Visible   = false

    e.tr              = ND("Line")
    e.tr.Thickness    = Config.TracerThickness
    e.tr.Transparency = Config.TracerTransparency
    e.tr.Visible      = false

    ESPObjects[p] = e
    return e
end

local function HideESP(e)
    if not e then return end
    e.box.Visible = false; e.boxOut.Visible = false
    e.name.Visible = false; e.tl.Visible = false
    e.dist.Visible = false; e.hp.Visible = false
    e.hpBg.Visible = false; e.tr.Visible = false
end

local function RemoveESP(p)
    local e = ESPObjects[p]
    if not e then return end
    for _, d in pairs(e) do
        pcall(function() AllDrawings[d] = nil; d:Remove() end)
    end
    ESPObjects[p] = nil
end

uiGui.Destroying:Connect(function()
    for _, c in ipairs(ScriptConnections) do pcall(function() c:Disconnect() end) end
    for p in pairs(PlayerConnections) do CleanPlayerConns(p) end
    for p in pairs(ESPObjects) do RemoveESP(p) end
    pcall(function() FOVCircle:Remove() end)
    for d in pairs(AllDrawings) do pcall(function() d:Remove() end) end
    AllDrawings = {}
    StopMobileAim()
end)

local function UpdateESP()
    if not States.ESP then
        for _, e in pairs(ESPObjects) do HideESP(e) end
        return
    end
    local vp = Camera.ViewportSize
    local tO = Vector2.new(vp.X / 2, vp.Y)
    local cp = Camera.CFrame.Position

    local toRemove = {}
    for p in pairs(ESPObjects) do
        if not p or not p.Parent then table.insert(toRemove, p) end
    end
    for _, p in ipairs(toRemove) do RemoveESP(p) end

    for _, p in ipairs(GetAllPlayers()) do
        local e = ESPObjects[p] or CreateESP(p)
        if not IsAlive(p) then HideESP(e); continue end
        local ra = IsRealTeammate(p)
        if not States.TeamFire and ra then HideESP(e); continue end
        local ch  = p.Character
        local hrp = ch:FindFirstChild("HumanoidRootPart")
        if not hrp then HideESP(e); continue end
        local d3 = (cp - hrp.Position).Magnitude
        if d3 > Config.ESPMaxDistance then HideESP(e); continue end
        local rp, onS = Camera:WorldToViewportPoint(hrp.Position)
        if not onS then HideESP(e); continue end
        local hd = ch:FindFirstChild("Head")
        if not hd then HideESP(e); continue end
        local hsp = Camera:WorldToViewportPoint(hd.Position + Vector3.new(0, .8, 0))
        local fY  = rp.Y + (rp.Y - hsp.Y) * 1.5
        local h   = math.abs(fY - hsp.Y)
        local w   = h * 0.55
        local vis = IsVisibleCached(hd, ch, p.UserId)
        local mc  = ra
            and (vis and Config.TeamFireColor or Color3.fromRGB(0, 80, 180))
            or  (vis and Color3.fromRGB(50, 255, 80) or Color3.fromRGB(255, 50, 50))

        e.boxOut.Size = Vector2.new(w+2, h+2)
        e.boxOut.Position = Vector2.new(rp.X - w/2 - 1, hsp.Y - 1)
        e.boxOut.Visible = true
        e.box.Color = mc
        e.box.Size = Vector2.new(w, h)
        e.box.Position = Vector2.new(rp.X - w/2, hsp.Y)
        e.box.Visible = true
        e.name.Text = p.DisplayName
        e.name.Position = Vector2.new(rp.X, hsp.Y - 17)
        e.name.Color = ra and Color3.fromRGB(100, 200, 255) or Color3.new(1,1,1)
        e.name.Visible = true
        if ra and States.TeamFire then
            e.tl.Text = "💙ALLY"
            e.tl.Position = Vector2.new(rp.X, hsp.Y - 27)
            e.tl.Color = Color3.fromRGB(0, 180, 255)
            e.tl.Visible = true
        else
            e.tl.Visible = false
        end
        e.dist.Text = math.floor(d3).."m"
        e.dist.Position = Vector2.new(rp.X, fY + 3)
        e.dist.Visible = true
        local hum = ch:FindFirstChildOfClass("Humanoid")
        if hum then
            local r  = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
            local bx = rp.X - w/2 - 6
            e.hpBg.From = Vector2.new(bx, fY)
            e.hpBg.To   = Vector2.new(bx, hsp.Y)
            e.hpBg.Visible = true
            e.hp.From = Vector2.new(bx, fY)
            e.hp.To   = Vector2.new(bx, fY - h*r)
            e.hp.Color = ra and Color3.fromRGB(0, 150, 255)
                or Color3.fromRGB(255*(1-r), 255*r, 0)
            e.hp.Visible = true
        end
        e.tr.From = tO
        e.tr.To   = Vector2.new(rp.X, fY)
        e.tr.Color = mc
        e.tr.Visible = true
    end
end

AddScriptConn(Players.PlayerRemoving:Connect(RemoveESP))

-- ═══════════════════════════════════════
-- [[ AIMBOT ]]
-- ═══════════════════════════════════════
local lastTargetSearch = 0

local function GetClosestTarget()
    local closest, minDist = nil, math.huge
    local vp     = Camera.ViewportSize
    local center = Vector2.new(vp.X / 2, vp.Y / 2)
    local cp     = Camera.CFrame.Position

    local fovPx = Config.FOV
    if IsMobile then
        fovPx = Config.FOV * (vp.X / 1080) * 2.5
    end

    for _, p in ipairs(GetAllPlayers()) do
        if not IsAlive(p) or IsTeammate(p) then continue end
        local ch  = p.Character
        if not ch then continue end
        local hrp = ch:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        if (cp - hrp.Position).Magnitude > Config.MaxDistance then continue end

        local ap = GetAimPart(ch)
        if not ap then continue end

        local sp, onS = Camera:WorldToViewportPoint(ap.Position)
        if not onS then continue end

        local screenDist = (Vector2.new(sp.X, sp.Y) - center).Magnitude
        if screenDist >= fovPx then continue end
        if Config.WallCheck and not IsVisibleCached(ap, ch, p.UserId) then continue end

        if screenDist < minDist then
            minDist = screenDist
            closest = {Part = ap, Player = p, Character = ch}
        end
    end
    return closest
end

local function RunAimbot(dt)
    if not States.Aimbot then
        LockedTarget          = nil
        lockIndicator.Visible = false
        aimMethodLabel.Visible = false
        if IsMobile then StopMobileAim() end
        return
    end

    -- Валідація цілі
    if LockedTarget then
        local p     = LockedTarget.Player
        local valid = true
        if not IsAlive(p) or IsTeammate(p) then
            valid = false
        else
            local ap = GetAimPart(LockedTarget.Character)
            if not ap then
                valid = false
            else
                LockedTarget.Part = ap
                local hrp = LockedTarget.Character:FindFirstChild("HumanoidRootPart")
                if not hrp or (Camera.CFrame.Position - hrp.Position).Magnitude > Config.MaxDistance then
                    valid = false
                elseif Config.WallCheck and not IsVisibleCached(ap, LockedTarget.Character, p.UserId) then
                    valid = false
                end
            end
        end
        if not valid then
            LockedTarget = nil
            if IsMobile then StopMobileAim() end
        end
    end

    local now = tick()
    if not LockedTarget and (now - lastTargetSearch) >= Config.TargetSearchRate then
        lastTargetSearch = now
        LockedTarget     = GetClosestTarget()
    end

    if LockedTarget then
        local isAlly = IsRealTeammate(LockedTarget.Player)
        lockIndicator.Text    = (isAlly and "🔵 " or "🔒 ")..LockedTarget.Player.DisplayName
        lockIndicator.Visible = true
        if IsMobile then
            aimMethodLabel.Text    = "🎯 " .. aimMethodUsed
            aimMethodLabel.Visible = true
        end
    else
        lockIndicator.Visible  = false
        aimMethodLabel.Visible = false
        if IsMobile then StopMobileAim() end
        return
    end

    local ap = LockedTarget.Part
    if not ap or not ap.Parent then
        LockedTarget = nil
        if IsMobile then StopMobileAim() end
        return
    end

    local vel = Vector3.zero
    local hrp = LockedTarget.Character:FindFirstChild("HumanoidRootPart")
    if hrp then vel = hrp.AssemblyLinearVelocity end

    local pred = ap.Position + vel * Config.Prediction

    if IsPC then
        -- PC: mousemoverel
        local vp     = Camera.ViewportSize
        local center = Vector2.new(vp.X / 2, vp.Y / 2)
        local sp, onS = Camera:WorldToViewportPoint(pred)
        if not onS then LockedTarget = nil; return end

        local d  = (Vector2.new(sp.X, sp.Y) - center).Magnitude
        local sm = Config.AimSmoothness
        if     d < 5  then sm = sm * 0.15
        elseif d < 15 then sm = sm * 0.45
        elseif d < 40 then sm = sm * 0.75 end
        if mousemoverel then
            pcall(mousemoverel, (sp.X - center.X) * sm, (sp.Y - center.Y) * sm)
        end
    else
        -- MOBILE: автоматичний вибір методу
        RunMobileAimbot(ap, pred, dt)
    end
end

-- ═══════════════════════════════════════
-- [[ TRIGGERBOT ]]
-- ═══════════════════════════════════════
local canShoot = true
local trigP    = RaycastParams.new()
trigP.FilterType = Enum.RaycastFilterType.Exclude

local function RunTriggerbot()
    if not States.Triggerbot or not canShoot or not LP.Character then return end
    trigP.FilterDescendantsInstances = {LP.Character, Camera}
    local hit = Workspace:Raycast(
        Camera.CFrame.Position,
        Camera.CFrame.LookVector * 1000,
        trigP
    )
    if not hit or not hit.Instance then return end
    local m = hit.Instance:FindFirstAncestorOfClass("Model")
    if not m then return end
    local p = Players:GetPlayerFromCharacter(m)
    if not p or p == LP or not IsAlive(p) or IsTeammate(p) then return end
    canShoot = false
    local vc = Camera.ViewportSize / 2
    pcall(function()
        if VirtualInputManager then
            VirtualInputManager:SendMouseButtonEvent(vc.X, vc.Y, 0, true,  game, 1)
            task.wait(0.012 + math.random() * 0.01)
            VirtualInputManager:SendMouseButtonEvent(vc.X, vc.Y, 0, false, game, 1)
        end
    end)
    task.delay(Config.TriggerDelay + math.random() * 0.03, function()
        canShoot = true
    end)
end

-- ═══════════════════════════════════════
-- [[ КЛАВІШІ ]]
-- ═══════════════════════════════════════
AddScriptConn(UIS.InputBegan:Connect(function(input)
    if UIS:GetFocusedTextBox() then return end
    local k = input.KeyCode

    if     k == Enum.KeyCode.T then
        States.Aimbot         = not States.Aimbot
        LockedTarget          = nil
        lockIndicator.Visible = false
        aimMethodLabel.Visible = false
        if IsMobile and not States.Aimbot then StopMobileAim() end

    elseif k == Enum.KeyCode.Y then
        States.Triggerbot = not States.Triggerbot

    elseif k == Enum.KeyCode.U then
        States.ESP = not States.ESP

    elseif k == Enum.KeyCode.H then
        States.Hitbox = not States.Hitbox
        if not States.Hitbox then ResetAllHeads() end

    elseif k == Enum.KeyCode.L then
        States.Bhop = not States.Bhop
        if not States.Bhop then
            Bhop.jumpCount = 0; Bhop.currentSpeed = 0
            Bhop.peakSpeed = 0; Bhop.streakActive = false
        end

    elseif k == Enum.KeyCode.K then
        States.NoClip = not States.NoClip
        if not States.NoClip then RestoreCollision() end

    elseif k == Enum.KeyCode.F then
        States.TeamFire        = not States.TeamFire
        teamFireBanner.Visible = States.TeamFire
        LockedTarget           = nil
        if ResetAllHeads then ResetAllHeads() end
    else
        return
    end
    UpdateUI()
end))

-- Respawn
AddScriptConn(LP.CharacterAdded:Connect(function(char)
    noClipParts           = {}
    Bhop.jumpCount        = 0; Bhop.currentSpeed = 0
    Bhop.peakSpeed        = 0; Bhop.jumpImpulseDone = false
    Bhop.streakActive     = false; Bhop.lastShownStreak = 0
    LockedTarget          = nil
    lockIndicator.Visible = false
    lastSafePos           = nil
    if IsMobile then StopMobileAim() end

    char.DescendantAdded:Connect(function(part)
        if part:IsA("BasePart") and States.NoClip then
            task.wait(0.05)
            pcall(function() part.CanCollide = false end)
        end
    end)
end))

if LP.Character then
    LP.Character.DescendantAdded:Connect(function(part)
        if part:IsA("BasePart") and States.NoClip then
            task.wait(0.05)
            pcall(function() part.CanCollide = false end)
        end
    end)
end

-- ═══════════════════════════════════════
-- [[ HEARTBEAT ]]
-- ═══════════════════════════════════════
AddScriptConn(RunService.Heartbeat:Connect(function(dt)
    if dt <= 0 or dt > 0.5 then return end
    RunNoClip(dt)
end))

-- ═══════════════════════════════════════
-- [[ RENDER STEPPED ]]
-- ═══════════════════════════════════════
local espT, hitT, uiT = 0, 0, 0
Bhop.lastCamAngle = GetCameraYaw()

AddScriptConn(RunService.RenderStepped:Connect(function(dt)
    Camera = Workspace.CurrentCamera
    local vp     = Camera.ViewportSize
    local center = Vector2.new(vp.X / 2, vp.Y / 2)

    local fovRadius = Config.FOV
    if IsMobile then
        fovRadius = Config.FOV * (vp.X / 1080) * 2.5
    end
    FOVCircle.Color    = States.TeamFire
        and Color3.fromRGB(0, 150, 255)
        or  Color3.fromRGB(255, 40, 40)
    FOVCircle.Position = center
    FOVCircle.Radius   = fovRadius
    FOVCircle.Visible  = States.Aimbot

    RunAimbot(dt)
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
        statusText = string.format(
            "💨%d %s | 🏆%.0f | ✨%d",
            math.floor(spd), DeviceLabel, Bhop.peakSpeed, Bhop.perfectJumps
        )
        UpdateUI()

        local spdRatio = math.clamp(spd / Config.BhopMaxSpeed, 0, 1)
        local sCol
        if     spdRatio < 0.33 then sCol = Color3.fromRGB(0, 200, 255)
        elseif spdRatio < 0.66 then sCol = Color3.fromRGB(0, 255, 200)
        else                         sCol = Color3.fromRGB(100, 255, 0) end
        TweenService:Create(speedBarFill, TweenInfo.new(0.08), {
            Size = UDim2.new(spdRatio, 0, 1, 0),
            BackgroundColor3 = sCol,
        }):Play()
    end
end))

-- Початковий тест методу
task.spawn(function()
    task.wait(1)
    DetectBestAimMethod()
    print("[OMNI] Screen: " .. tostring(Camera.ViewportSize) .. " Scale: " .. tostring(GetScreenScale()))
end)

-- ═══════════════════════════════════════
print("════════════════════════════════")
print("⚡ OMNI GHOST v8.3 — LOADED")
print("T=Aim Y=Trig U=ESP H=Head")
print("L=Bhop K=Clip F=TeamFire")
print("────────────────────────────────")
print("Mobile Aimbot: AUTO DETECT")
print("Methods: CFrame/MMR/VIM-Mouse/VIM-Touch")
print("Delta Executor: FULL SUPPORT")
print("Tablet 12.7\": Scale compensated")
print("════════════════════════════════")