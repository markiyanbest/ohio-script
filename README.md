-- markiyanbest's script (V47 - FULL FIX EDITION)
-- Mobile optimized | Custom Binds | Fixed AutoHeal/Armor | Fixed Paralysis | Beautiful GUI

local Players      = game:GetService("Players")
local lp           = Players.LocalPlayer
local RS           = game:GetService("RunService")
local Light        = game:GetService("Lighting")
local UIS          = game:GetService("UserInputService")
local VirtualUser  = game:GetService("VirtualUser")
local Camera       = workspace.CurrentCamera
local StarterGui   = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")

-- ============================================================
-- [[ ПЛАТФОРМА ]]
-- ============================================================
local IsMobile = UIS.TouchEnabled
local IsPC     = not IsMobile

-- ============================================================
-- [[ ОЧИЩЕННЯ ]]
-- ============================================================
pcall(function()
    for _, sg in pairs({ game:GetService("CoreGui"), lp:WaitForChild("PlayerGui") }) do
        for _, v in pairs(sg:GetChildren()) do
            if v:IsA("ScreenGui") and v.Name == "MarkiyanPro" then
                v:Destroy()
            end
        end
    end
end)

-- ============================================================
-- [[ МОБІЛЬНА АВТО-ОПТИМІЗАЦІЯ ]]
-- ============================================================
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
            pcall(function() v:Destroy() end)
        end
    end
    task.spawn(function()
        task.wait(2)
        for _, v in pairs(workspace:GetDescendants()) do
            pcall(function()
                if v:IsA("BasePart") then
                    v.CastShadow  = false
                    v.Reflectance = 0
                elseif v:IsA("ParticleEmitter") or v:IsA("Trail")
                or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
                    v:Destroy()
                end
            end)
        end
    end)
end

-- ============================================================
-- [[ КООРДИНАТИ ]]
-- ============================================================
local COORDS = {
    GUN_SHOP   = Vector3.new(1131, 25, -1344),
    BANK_ENT   = Vector3.new(1106, 8,  -336),
    BANK_MONEY = Vector3.new(1110, 8,  -325),
    SAFE_ZONE  = Vector3.new(-37, -27,  3),
}

-- ============================================================
-- [[ КОНФІГ ]]
-- ============================================================
local Config = {
    Farm           = false,
    Speed          = false,
    Armor          = false,
    Heal           = false,
    AimActive      = false,
    LockedTarget   = nil,
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
-- [[ ЛУТ ]]
-- ============================================================
local LootCache      = {}
local BlacklistCache = {}

for _, v in pairs({
    "void","gem","shard","suitcase nuke","nuke","nextbot","ninja star",
    "stop sign","printer","money printer","materials","candy","gold ak",
    "gold deagle","gold glock","gold knife","flamethrower","barrett","m107",
    "rpg","launcher","c4","molotov","scrap","cane","scar l","m4","ak",
    "sniper","weapon parts","explosives","helimail","helicopter",
    "mobile dealer","lockpick","santa","blue","key","card","cash","money",
    "wallet","electronics","atm","safe","diamond","gold bar","limited",
    "box","crate","mustang","mattery","medkit","heavy armor","medium armor",
    "light armor","vest","phone","bandage","balloon","cookies","air","drop",
    "dark","lucky","m1911","glock","usp45","python","deagle","uzi",
    "mossberg","sawnoff","saiga12","ar15","ak47","m4a1","aug","tommygun",
    "asval","rpk","dragunov","m249","mp7","fnfal","p90","scarl","awp",
    "m1garand","barrettm107","cannonrpg","minigun",
}) do LootCache[v] = true end

for _, v in pairs({
    "trash","newspaper","bottle","leaf","stick","shoe","apple","soda",
    "burger","hotdog","stop","ore","ladder","fireworks","press","paintball",
    "spawn","cola","spin","requires","door","gate","barrier","cell",
    "cash earned","garage","ammo","pickaxe","sign","equip","food","gloves",
    "spray","ignite","steal","brew","latte","espresso","drink",
    "vending machine","bloxy","bat","katana","flashbang","skateboard",
    "bike","ninja","workbench","edit","open","fill","drain","close","guitar",
}) do BlacklistCache[v] = true end

-- ============================================================
-- [[ УТИЛІТИ ]]
-- ============================================================
local function Notify(title, text, dur)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title, Text = text, Duration = dur or 2
        })
    end)
end

local function GetChar()  return lp.Character end
local function GetHum()   local c = GetChar(); return c and c:FindFirstChildOfClass("Humanoid") end
local function GetRoot()  local c = GetChar(); return c and c:FindFirstChild("HumanoidRootPart") end

local function IsHumAlive()
    local h = GetHum()
    return h and h.Health > 0
end

local function SafeTeleport(pos)
    if not IsHumAlive() then return false end
    local root = GetRoot()
    if not root then return false end
    pcall(function()
        lp.Character:PivotTo(CFrame.new(pos + Vector3.new(0, 3, 0)))
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

local function GetClosestToScreen()
    local best, bestD = nil, IsMobile and 600 or 1000
    local cx = Camera.ViewportSize.X / 2
    local cy = Camera.ViewportSize.Y / 2
    for _, v in pairs(Players:GetPlayers()) do
        if v == lp then continue end
        local char = v.Character
        if not char then continue end
        local head = char:FindFirstChild("Head")
        local hum  = char:FindFirstChildOfClass("Humanoid")
        if not head or not hum or hum.Health <= 0 then continue end
        local pos, on = Camera:WorldToViewportPoint(head.Position)
        if not on then continue end
        local d = (Vector2.new(pos.X, pos.Y) - Vector2.new(cx, cy)).Magnitude
        if d < bestD then bestD = d; best = v end
    end
    return best
end

local function GetClosestByDist()
    local root = GetRoot()
    if not root then return nil end
    local best, bestD = nil, math.huge
    for _, v in pairs(Players:GetPlayers()) do
        if v == lp then continue end
        if not IsTargetAlive(v) then continue end
        local hrp = v.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local d = (hrp.Position - root.Position).Magnitude
            if d < bestD then bestD = d; best = v end
        end
    end
    return best
end

-- ============================================================
-- [[ МОБІЛЬНІ КОНТРОЛЕРИ ]]
-- ============================================================
local Controls = nil
task.spawn(function()
    if not game:IsLoaded() then game.Loaded:Wait() end
    task.wait(1)
    pcall(function()
        Controls = require(
            lp.PlayerScripts:WaitForChild("PlayerModule", 5)
        ):GetControls()
    end)
end)

-- ============================================================
-- [[ SILENT AIM ]]
-- ============================================================
local silentActive  = false
local hookInstalled = false

pcall(function()
    local mt = getrawmetatable(game)
    if not mt then return end
    local oldNC = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if silentActive and self == workspace
        and (method == "Raycast"
          or method == "FindPartOnRay"
          or method == "FindPartOnRayWithIgnoreList") then
            local args   = { ... }
            local target = GetClosestToScreen()
            if target and target.Character then
                local head = target.Character:FindFirstChild("Head")
                if head then
                    local origin = Camera.CFrame.Position
                    if typeof(args[2]) == "Vector3" then
                        args[2] = (head.Position - origin).Unit * args[2].Magnitude
                    elseif typeof(args[1]) == "Ray" then
                        args[1] = Ray.new(origin,
                            (head.Position - origin).Unit * args[1].Direction.Magnitude)
                    end
                end
            end
            return oldNC(self, table.unpack(args))
        end
        return oldNC(self, ...)
    end)
    setreadonly(mt, true)
    hookInstalled = true
end)

local lastSilentT = 0
local function FallbackSilentAim()
    if not Config.SilentAim then return end
    local now = tick()
    if now - lastSilentT < (IsMobile and 0.06 or 0.02) then return end
    lastSilentT = now
    if not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then return end
    local target = GetClosestToScreen()
    if not target or not target.Character then return end
    local head = target.Character:FindFirstChild("Head")
    if not head then return end
    Camera.CFrame = Camera.CFrame:Lerp(
        CFrame.new(Camera.CFrame.Position, head.Position),
        IsMobile and 0.3 or 0.4
    )
end

-- ============================================================
-- [[ FPS BOOST ]]
-- ============================================================
local function ApplyFPS()
    pcall(function()
        settings().Rendering.QualityLevel = 1
        Light.GlobalShadows = false
        for _, v in pairs(workspace:GetDescendants()) do
            pcall(function()
                if v:IsA("BasePart") then
                    v.CastShadow  = false
                    v.Reflectance = 0
                    v.Material    = Enum.Material.SmoothPlastic
                elseif v:IsA("Decal") or v:IsA("Texture")
                or v:IsA("ParticleEmitter") or v:IsA("Trail")
                or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
                    v:Destroy()
                end
            end)
        end
    end)
    Notify("FPS BOOST", "Графіку знижено ✓", 2)
end

-- ============================================================
-- [[ AUTO HEAL / ARMOR ]]
-- ============================================================
task.spawn(function()
    while task.wait(IsMobile and 1.2 or 0.6) do
        pcall(function()
            if not IsHumAlive() then return end
            local hum  = GetHum()
            local char = GetChar()
            if not hum or not char then return end

            if Config.Heal and hum.Health < hum.MaxHealth * 0.75 then
                local med = nil
                for _, item in pairs(lp.Backpack:GetChildren()) do
                    local n = item.Name:lower()
                    if n:find("medkit") or n:find("bandage") or n:find("firstaid") then
                        med = item; break
                    end
                end
                if not med then
                    for _, item in pairs(char:GetChildren()) do
                        if item:IsA("Tool") then
                            local n = item.Name:lower()
                            if n:find("medkit") or n:find("bandage") or n:find("firstaid") then
                                med = item; break
                            end
                        end
                    end
                end
                if med then
                    if med.Parent == lp.Backpack then
                        hum:EquipTool(med)
                        task.wait(0.15)
                    end
                    local tool = char:FindFirstChild(med.Name)
                    if tool then
                        pcall(function() tool:Activate() end)
                        pcall(function()
                            for _, v in pairs(tool:GetDescendants()) do
                                if v:IsA("RemoteEvent") and
                                (v.Name:lower():find("use") or v.Name:lower():find("heal")) then
                                    v:FireServer()
                                end
                            end
                        end)
                    end
                    task.wait(0.5)
                    pcall(function() hum:UnequipTools() end)
                end
            end

            if Config.Armor then
                local arm = nil
                for _, item in pairs(lp.Backpack:GetChildren()) do
                    local n = item.Name:lower()
                    if n:find("armor") or n:find("vest") or n:find("helmet") then
                        arm = item; break
                    end
                end
                if not arm then
                    for _, item in pairs(char:GetChildren()) do
                        if item:IsA("Tool") then
                            local n = item.Name:lower()
                            if n:find("armor") or n:find("vest") or n:find("helmet") then
                                arm = item; break
                            end
                        end
                    end
                end
                if arm then
                    if arm.Parent == lp.Backpack then
                        hum:EquipTool(arm)
                        task.wait(0.15)
                    end
                    local tool = char:FindFirstChild(arm.Name)
                    if tool then
                        pcall(function() tool:Activate() end)
                        pcall(function()
                            for _, v in pairs(tool:GetDescendants()) do
                                if v:IsA("RemoteEvent") then
                                    v:FireServer()
                                end
                            end
                        end)
                    end
                    task.wait(0.5)
                    pcall(function() hum:UnequipTools() end)
                end
            end
        end)
    end
end)

-- ============================================================
-- [[ ANTI-AFK ]]
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
-- [[ AUTO ROB ]]
-- ============================================================
local function StartRobbery()
    Notify("BANK ROB", "Починаємо...", 2)
    if not SafeTeleport(COORDS.BANK_MONEY) then
        Notify("BANK ROB", "Помилка!", 2); return
    end
    task.wait(0.8)
    for i = 1, 20 do
        if not IsHumAlive() then break end
        pcall(function()
            for _, v in pairs(workspace:GetDescendants()) do
                if not v:IsA("ProximityPrompt") or not v.Enabled then continue end
                local root = GetRoot()
                if not root then continue end
                if (root.Position - v.Parent:GetPivot().Position).Magnitude < 15 then
                    fireproximityprompt(v)
                end
            end
        end)
        task.wait(0.5)
    end
    SafeTeleport(COORDS.SAFE_ZONE)
    Notify("BANK ROB", "Готово! ✓", 3)
end

-- ============================================================
-- [[ ESP ]]
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
    while task.wait(IsMobile and 0.15 or 0.05) do
        if not Config.ESP then continue end
        local myRoot = GetRoot()
        for _, v in pairs(Players:GetPlayers()) do
            if v == lp then continue end
            local char = v.Character
            local head = char and char:FindFirstChild("Head")
            local hum  = char and char:FindFirstChildOfClass("Humanoid")
            if not char or not head or not hum or hum.Health <= 0 then
                ClearESP(char); ESPCache[v] = nil; continue
            end
            if IsMobile then
                local _, on = Camera:WorldToViewportPoint(head.Position)
                if not on then continue end
            end
            local cache = ESPCache[v]
            if not cache or not cache.gui or not cache.gui.Parent then
                if cache then ClearESP(char) end
                local gui = Instance.new("BillboardGui")
                gui.Name        = "MrkESP"
                gui.Size        = UDim2.new(0, IsMobile and 155 or 195, 0, IsMobile and 44 or 54)
                gui.StudsOffset = Vector3.new(0, 3.2, 0)
                gui.AlwaysOnTop = true
                gui.MaxDistance = IsMobile and 300 or 500
                gui.Parent      = head
                local bg = Instance.new("Frame", gui)
                bg.Size = UDim2.new(1,0,1,0)
                bg.BackgroundColor3 = Color3.fromRGB(0,0,0)
                bg.BackgroundTransparency = 0.45
                bg.BorderSizePixel = 0
                Instance.new("UICorner", bg)
                local lbl = Instance.new("TextLabel", bg)
                lbl.Name = "L"
                lbl.Size = UDim2.new(1,0,1,0)
                lbl.BackgroundTransparency = 1
                lbl.Font = Enum.Font.GothamBold
                lbl.TextSize = IsMobile and 11 or 13
                lbl.TextWrapped = true
                lbl.TextStrokeTransparency = 0.3
                if IsPC then
                    local hl = Instance.new("Highlight")
                    hl.Name = "MrkHL"
                    hl.FillColor = Color3.new(1,0,0)
                    hl.OutlineColor = Color3.new(1,1,1)
                    hl.FillTransparency = 0.6
                    hl.OutlineTransparency = 0
                    hl.Parent = char
                end
                ESPCache[v] = { gui = gui, lbl = lbl }
                cache = ESPCache[v]
            end
            local lbl   = cache.lbl
            local dist  = myRoot and math.floor((myRoot.Position - head.Position).Magnitude) or 0
            local hp    = math.floor(hum.Health)
            local maxHp = math.max(math.floor(hum.MaxHealth), 1)
            local ratio = hp / maxHp
            lbl.Text = string.format("[%s]\nHP: %d/%d | %dm", v.Name, hp, maxHp, dist)
            lbl.TextColor3 = ratio >= 0.6
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
-- [[ RENDER: AIM + SILENT AIM ]]
-- ============================================================
local lastAimT = 0
RS.RenderStepped:Connect(function()
    if Config.SilentAim and not hookInstalled then FallbackSilentAim() end
    if not Config.AimActive then
        Config.LockedTarget = nil; return
    end
    local now = tick()
    if now - lastAimT < (IsMobile and 0.05 or 0.01) then return end
    lastAimT = now
    if not IsTargetAlive(Config.LockedTarget) then
        Config.LockedTarget = GetClosestToScreen()
    end
    if Config.LockedTarget then
        local char = Config.LockedTarget.Character
        local head = char and char:FindFirstChild("Head")
        if head then
            if IsMobile then
                Camera.CFrame = Camera.CFrame:Lerp(
                    CFrame.new(Camera.CFrame.Position, head.Position), 0.3)
            else
                Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, head.Position)
            end
        end
    end
end)

-- ============================================================
-- [[ AUTO FARM ]]
-- ============================================================
local farmRunning = false
task.spawn(function()
    while task.wait(IsMobile and 0.8 or 0.4) do
        if not Config.Farm or farmRunning then continue end
        farmRunning = true
        pcall(function()
            if not IsHumAlive() then return end
            for _, v in pairs(workspace:GetDescendants()) do
                if not Config.Farm then break end
                if not v:IsA("ProximityPrompt") or not v.Enabled then continue end
                local text = (v.Parent.Name..v.ActionText..v.ObjectText):lower()
                local ok = false
                for item in pairs(LootCache) do
                    if text:find(item, 1, true) then ok = true; break end
                end
                if ok then
                    for item in pairs(BlacklistCache) do
                        if text:find(item, 1, true) then ok = false; break end
                    end
                end
                if ok then
                    SafeTeleport(v.Parent:GetPivot().Position)
                    task.wait(IsMobile and 0.35 or 0.2)
                    pcall(fireproximityprompt, v)
                    task.wait(IsMobile and 0.35 or 0.2)
                end
            end
        end)
        farmRunning = false
    end
end)

-- ============================================================
-- [[ NOCLIP ]]
-- ============================================================
local function RestoreCollision()
    local char = GetChar()
    if not char then return end
    for _, v in pairs(char:GetDescendants()) do
        if v:IsA("BasePart") then v.CanCollide = true end
    end
end

RS.Stepped:Connect(function()
    if not Config.Noclip then return end
    local char = GetChar()
    if not char then return end
    for _, v in pairs(char:GetDescendants()) do
        if v:IsA("BasePart") then v.CanCollide = false end
    end
end)

-- ============================================================
-- [[ HEARTBEAT ]]
-- ============================================================
RS.Heartbeat:Connect(function()
    local hum  = GetHum()
    local root = GetRoot()
    if not hum or not root then return end

    if Config.AntiSeat and hum.SeatPart then
        hum.Sit = false
    end

    if Config.Speed and not Config.Fly and IsHumAlive() then
        hum.WalkSpeed = Config.WalkSpeedValue
    elseif not Config.Fly and not Config.Speed then
        if hum.WalkSpeed ~= 16 then hum.WalkSpeed = 16 end
    end

    if Config.Fly and IsHumAlive() then
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

        local dir = Camera.CFrame.LookVector  * -moveZ
                  + Camera.CFrame.RightVector *  moveX

        if IsPC then
            if UIS:IsKeyDown(Enum.KeyCode.Space)       then dir += Vector3.new(0,1,0) end
            if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0,1,0) end
        end

        if dir.Magnitude > 1 then dir = dir.Unit end

        local bv = root:FindFirstChild("MrkFlyBV")
        if not bv then
            bv          = Instance.new("BodyVelocity")
            bv.Name     = "MrkFlyBV"
            bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            bv.Parent   = root
        end
        bv.Velocity       = dir * Config.FlySpeedValue
        hum.PlatformStand = false
        hum.WalkSpeed     = 0
    else
        local bv = root:FindFirstChild("MrkFlyBV")
        if bv then bv:Destroy() end
        if hum.PlatformStand then hum.PlatformStand = false end
        if not Config.Speed   then hum.WalkSpeed     = 16   end
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
                    IsMobile and 0.18 or 0.25
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
            Notify("AUTO SAFE", "HP: "..math.floor(hum.Health), 3)
        end
    end
end)

-- ============================================================
-- [[ INFINITE JUMP ]]
-- ============================================================
UIS.JumpRequest:Connect(function()
    if not Config.InfJump then return end
    local hum = GetHum()
    if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

-- ============================================================
-- [[ CLEANUP ]]
-- ============================================================
lp.CharacterRemoving:Connect(function()
    Config.Fly    = false
    Config.Noclip = false
    local root = GetRoot()
    if root then
        local bv = root:FindFirstChild("MrkFlyBV")
        if bv then bv:Destroy() end
    end
end)

lp.CharacterAdded:Connect(function(char)
    Config.Fly    = false
    Config.Noclip = false
    Config.Magnet = false
    task.wait(1)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.PlatformStand = false
        hum.WalkSpeed     = 16
    end
end)

-- ============================================================
-- [[ GUI ]]
-- ============================================================
local SG = Instance.new("ScreenGui")
SG.Name           = "MarkiyanPro"
SG.ResetOnSpawn   = false
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function() SG.Parent = game:GetService("CoreGui") end)
if not SG.Parent then SG.Parent = lp:WaitForChild("PlayerGui") end

local MW = IsMobile and 250 or 370
local MH = IsMobile and 440 or 590

local Main = Instance.new("Frame", SG)
Main.Size             = UDim2.new(0, MW, 0, MH)
Main.AnchorPoint      = Vector2.new(0.5, 0.5)
Main.Position         = UDim2.new(0.5, 0, 0.5, 0)
Main.BackgroundColor3 = Color3.fromRGB(8, 8, 14)
Main.BorderSizePixel  = 0
Main.Visible          = false
Instance.new("UICorner", Main)

local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Color     = Color3.fromRGB(0, 120, 255)
MainStroke.Thickness = 2

-- Header
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
HeaderLbl.Text                   = "⚡ Markiyan PRO V47"
    .. (IsMobile and " [MOB]" or "")
HeaderLbl.ZIndex                 = 2

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

-- Tab Bar
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

-- Scroll
local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size                   = UDim2.new(1, -8, 1, -80)
Scroll.Position               = UDim2.new(0, 4, 0, 76)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness     = IsMobile and 0 or 3
Scroll.ScrollBarImageColor3   = Color3.fromRGB(0, 120, 255)
Scroll.BorderSizePixel        = 0

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
-- [[ TABS ]]
-- ============================================================
local Sections   = {}
local TabButtons = {}
local ActiveTab  = nil

local function ShowTab(name)
    ActiveTab = name
    for n, frames in pairs(Sections) do
        for _, f in pairs(frames) do
            f.Visible = (n == name)
        end
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

local tabNames = {"Combat", "Movement", "Misc", "Binds"}
local tabW     = IsMobile and 54 or 76

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
-- [[ DRAGGABLE (ВИПРАВЛЕНО ShiftLock баг) ]]
-- ============================================================
local function MakeDraggable(handle, target)
    local drag   = false
    local dStart = nil
    local dPos   = nil

    handle.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            drag   = true
            dStart = inp.Position
            dPos   = target.Position
        end
    end)

    -- Локальний на handle — не конфліктує з ShiftLock
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
        or inp.UserInputType == Enum.UserInputType.Touch then
            drag = false
        end
    end)

    -- Запасний щоб drag не завис
    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            drag = false
        end
    end)
end

MakeDraggable(Header, Main)

-- ============================================================
-- [[ UI КОМПОНЕНТИ ]]
-- ============================================================
local BtnH    = IsMobile and 36 or 32
local Buttons = {}
local UpdFuncs = {}

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
    l.Text                   = "── "..text.." ──"
    table.insert(Sections[tabName], f)
end

-- ============================================================
-- [[ TOGGLE (ВИПРАВЛЕНО: крапка не налазить на текст) ]]
-- ============================================================
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
    -- Відступ зліва щоб текст НЕ налазив на крапку
    btn.Text             = "         "..name..": OFF"
    Instance.new("UICorner", btn)

    -- Крапка поверх тексту (ZIndex +1), фіксована позиція
    local dot = Instance.new("Frame", btn)
    dot.Name             = "D"
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
            btn.Text             = "         "..name..": ON"
        else
            btn.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
            btn.TextColor3       = Color3.fromRGB(190, 190, 200)
            dot.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            btn.Text             = "         "..name..": OFF"
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
        Notify(name, Config[key] and "ON ✓" or "OFF ✗", 1.5)
    end)

    return Upd
end

local function AddSlider(tabName, label, min, max, default, configKey)
    local f = Instance.new("Frame", Scroll)
    f.Size             = UDim2.new(0.97, 0, 0, IsMobile and 50 or 52)
    f.BackgroundColor3 = Color3.fromRGB(16, 16, 24)
    f.BorderSizePixel  = 0
    f.Visible          = false
    Instance.new("UICorner", f)
    table.insert(Sections[tabName], f)

    local lbl = Instance.new("TextLabel", f)
    lbl.Size               = UDim2.new(1,-8,0,20)
    lbl.Position           = UDim2.new(0,4,0,2)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3         = Color3.fromRGB(200,200,210)
    lbl.Font               = Enum.Font.GothamBold
    lbl.TextSize           = IsMobile and 11 or 12
    lbl.TextXAlignment     = Enum.TextXAlignment.Left
    lbl.Text               = label..": "..default

    local track = Instance.new("Frame", f)
    track.Size             = UDim2.new(0.92,0,0,IsMobile and 9 or 8)
    track.Position         = UDim2.new(0.04,0,0,IsMobile and 32 or 34)
    track.BackgroundColor3 = Color3.fromRGB(35,35,50)
    track.BorderSizePixel  = 0
    Instance.new("UICorner", track)

    local fill = Instance.new("Frame", track)
    fill.Size             = UDim2.new((default-min)/(max-min),0,1,0)
    fill.BackgroundColor3 = Color3.fromRGB(0,100,255)
    fill.BorderSizePixel  = 0
    Instance.new("UICorner", fill)

    local kSz = IsMobile and 16 or 13
    local knob = Instance.new("Frame", track)
    knob.Size             = UDim2.new(0,kSz,0,kSz)
    knob.Position         = UDim2.new((default-min)/(max-min),-kSz/2,0.5,-kSz/2)
    knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
    knob.BorderSizePixel  = 0
    Instance.new("UICorner", knob)

    local drag = false
    local function Upd(inp)
        local rel = math.clamp(
            (inp.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + rel*(max-min))
        fill.Size     = UDim2.new(rel,0,1,0)
        knob.Position = UDim2.new(rel,-kSz/2,0.5,-kSz/2)
        lbl.Text      = label..": "..val
        Config[configKey] = val
    end

    track.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1
        or inp.UserInputType==Enum.UserInputType.Touch then drag=true; Upd(inp) end
    end)
    UIS.InputChanged:Connect(function(inp)
        if not drag then return end
        if inp.UserInputType==Enum.UserInputType.MouseMovement
        or inp.UserInputType==Enum.UserInputType.Touch then Upd(inp) end
    end)
    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1
        or inp.UserInputType==Enum.UserInputType.Touch then drag=false end
    end)
end

local function AddAction(tabName, name, color, cb)
    local f   = MakeFrame(tabName)
    local btn = Instance.new("TextButton", f)
    btn.Size             = UDim2.new(1,0,1,0)
    btn.BackgroundColor3 = color or Color3.fromRGB(130,0,0)
    btn.TextColor3       = Color3.fromRGB(255,255,255)
    btn.Font             = Enum.Font.GothamBold
    btn.TextSize         = IsMobile and 11 or 13
    btn.BorderSizePixel  = 0
    btn.AutoButtonColor  = false
    btn.Text             = name
    Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(function()
        local orig = btn.BackgroundColor3
        btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
        task.wait(0.1)
        btn.BackgroundColor3 = orig
        task.spawn(cb)
    end)
end

local function AddTP(tabName, name, vec)
    local f   = MakeFrame(tabName)
    local btn = Instance.new("TextButton", f)
    btn.Size             = UDim2.new(1,0,1,0)
    btn.BackgroundColor3 = Color3.fromRGB(18,18,32)
    btn.TextColor3       = Color3.fromRGB(255,215,0)
    btn.Font             = Enum.Font.GothamBold
    btn.TextSize         = IsMobile and 11 or 12
    btn.BorderSizePixel  = 0
    btn.AutoButtonColor  = false
    btn.Text             = "📍 "..name
    Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(function()
        if SafeTeleport(vec) then Notify("TP","➜ "..name,2) end
    end)
end

-- ============================================================
-- [[ НАПОВНЕННЯ ]]
-- ============================================================

-- COMBAT
AddCategory("Combat", "COMBAT")
AddToggle("Combat","AIM LOCK",  "AimActive",
    nil, function() Config.LockedTarget = nil end)
AddToggle("Combat","SILENT AIM","SilentAim",
    function() silentActive = true  end,
    function() silentActive = false end)
AddToggle("Combat","ESP","ESP",
    nil, function() ClearAllESP() end)
AddToggle("Combat","MAGNET","Magnet",
    nil, function() Config.MagnetTarget = nil end)

-- MOVEMENT
AddCategory("Movement","MOVEMENT")
AddToggle("Movement","FLY","Fly",
    nil,
    function()
        local hum  = GetHum()
        local root = GetRoot()
        if hum  then hum.PlatformStand = false; hum.WalkSpeed = 16 end
        if root then
            local bv = root:FindFirstChild("MrkFlyBV")
            if bv then bv:Destroy() end
        end
    end)
AddSlider("Movement","FLY SPEED",10,IsMobile and 150 or 250,
    Config.FlySpeedValue,"FlySpeedValue")
AddToggle("Movement","SPEED HACK","Speed",
    nil,
    function()
        local hum = GetHum()
        if hum then hum.WalkSpeed = 16 end
    end)
AddSlider("Movement","WALK SPEED",16,IsMobile and 100 or 150,
    Config.WalkSpeedValue,"WalkSpeedValue")
AddToggle("Movement","NOCLIP","Noclip",
    nil, function() RestoreCollision() end)
AddToggle("Movement","INF JUMP","InfJump")

AddCategory("Movement","TELEPORTS")
AddTP("Movement","GUN SHOP",  COORDS.GUN_SHOP)
AddTP("Movement","BANK",      COORDS.BANK_ENT)
AddTP("Movement","SAFE ZONE", COORDS.SAFE_ZONE)

-- MISC
AddCategory("Misc","SURVIVAL")
AddToggle("Misc","AUTO SAFE HP","AutoSafe")
AddToggle("Misc","AUTO HEAL",   "Heal")
AddToggle("Misc","AUTO ARMOR",  "Armor")

AddCategory("Misc","FARM & MISC")
AddToggle("Misc","AUTO FARM","Farm")
AddToggle("Misc","ANTI-SEAT","AntiSeat")
AddToggle("Misc","ANTI-AFK", "AntiAFK")
AddToggle("Misc","FPS BOOST","FPSBoost",
    function() ApplyFPS() end)

AddCategory("Misc","ACTIONS")
AddAction("Misc","🏦 AUTO ROB BANK",Color3.fromRGB(150,20,20),StartRobbery)

-- ============================================================
-- [[ BINDS ТАБ ]]
-- ============================================================
local bindableActions = {
    { key = "Fly",       name = "FLY"       },
    { key = "AimActive", name = "AIM LOCK"  },
    { key = "Noclip",    name = "NOCLIP"    },
    { key = "SilentAim", name = "SILENT AIM"},
    { key = "ToggleUI",  name = "TOGGLE UI" },
}

local BindBtns = {}

-- Info frame
local infoF = Instance.new("Frame", Scroll)
infoF.Size             = UDim2.new(0.97,0,0,IsMobile and 38 or 28)
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
        and tostring(curBind):gsub("Enum.KeyCode.","")
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

for _, entry in pairs(bindableActions) do
    AddBindRow("Binds", entry.key, entry.name)
end

-- ============================================================
-- [[ BIND INPUT HANDLER ]]
-- ============================================================
UIS.InputBegan:Connect(function(inp, gpe)
    -- Чекаємо новий бінд
    if waitingForBind then
        if inp.UserInputType == Enum.UserInputType.Keyboard then
            local newKey = inp.KeyCode
            local action = waitingForBind
            Binds[action] = newKey
            if BindBtns[action] then
                BindBtns[action].Text      = tostring(newKey):gsub("Enum.KeyCode.","")
                BindBtns[action].TextColor3 = Color3.fromRGB(170,200,255)
            end
            Notify("BIND", (BindNames[action] or action).." → "
                ..tostring(newKey):gsub("Enum.KeyCode.",""), 2)
            waitingForBind = nil
        end
        return
    end

    if gpe then return end

    -- Перевіряємо бінди
    for action, key in pairs(Binds) do
        if inp.KeyCode ~= key then continue end

        if action == "ToggleUI" then
            Main.Visible = not Main.Visible
            if Main.Visible then Notify("Markiyan PRO","Меню ✓",1) end

        elseif action == "Fly" then
            Config.Fly = not Config.Fly
            if UpdFuncs.Fly then UpdFuncs.Fly(Config.Fly) end
            if not Config.Fly then
                local hum  = GetHum()
                local root = GetRoot()
                if hum  then hum.PlatformStand = false; hum.WalkSpeed = 16 end
                if root then
                    local bv = root:FindFirstChild("MrkFlyBV")
                    if bv then bv:Destroy() end
                end
            end
            Notify("FLY", Config.Fly and "ON ✓" or "OFF ✗", 1.5)

        elseif action == "AimActive" then
            Config.AimActive = not Config.AimActive
            if UpdFuncs.AimActive then UpdFuncs.AimActive(Config.AimActive) end
            if not Config.AimActive then Config.LockedTarget = nil end
            Notify("AIM LOCK", Config.AimActive and "ON ✓" or "OFF ✗", 1.5)

        elseif action == "Noclip" then
            Config.Noclip = not Config.Noclip
            if UpdFuncs.Noclip then UpdFuncs.Noclip(Config.Noclip) end
            if not Config.Noclip then RestoreCollision() end
            Notify("NOCLIP", Config.Noclip and "ON ✓" or "OFF ✗", 1.5)

        elseif action == "SilentAim" then
            Config.SilentAim = not Config.SilentAim
            silentActive     = Config.SilentAim
            if UpdFuncs.SilentAim then UpdFuncs.SilentAim(Config.SilentAim) end
            Notify("SILENT AIM", Config.SilentAim and "ON ✓" or "OFF ✗", 1.5)
        end
    end
end)

-- ============================================================
-- [[ M КНОПКА (ВИПРАВЛЕНО ShiftLock баг) ]]
-- ============================================================
local MBtnSz = IsMobile and 54 or 44

local MBtn = Instance.new("TextButton", SG)
MBtn.Size             = UDim2.new(0, MBtnSz, 0, MBtnSz)
MBtn.Position         = UDim2.new(0, 10, 0.28, 0)
MBtn.Text             = "M"
MBtn.Font             = Enum.Font.GothamBlack
MBtn.TextSize         = IsMobile and 24 or 19
MBtn.BackgroundColor3 = Color3.fromRGB(0, 80, 200)
MBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
MBtn.BorderSizePixel  = 0
MBtn.AutoButtonColor  = false
MBtn.ZIndex           = 100
Instance.new("UICorner", MBtn)

local mSt = Instance.new("UIStroke", MBtn)
mSt.Color     = Color3.fromRGB(255, 255, 255)
mSt.Thickness = 2

-- Пульсація
task.spawn(function()
    while true do
        TweenService:Create(MBtn, TweenInfo.new(1.5), {
            BackgroundColor3 = Color3.fromRGB(0, 40, 160)
        }):Play()
        task.wait(1.5)
        TweenService:Create(MBtn, TweenInfo.new(1.5), {
            BackgroundColor3 = Color3.fromRGB(0, 100, 255)
        }):Play()
        task.wait(1.5)
    end
end)

-- Drag M кнопки (локальний InputChanged — не баить ShiftLock)
do
    local mDrag  = false
    local mStart = nil
    local mPos   = nil
    local mTick  = 0
    local mMoved = false

    MBtn.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            mDrag  = true
            mStart = inp.Position
            mPos   = MBtn.Position
            mTick  = tick()
            mMoved = false
        end
    end)

    -- ЛОКАЛЬНИЙ InputChanged на кнопці
    MBtn.InputChanged:Connect(function(inp)
        if not mDrag then return end
        if inp.UserInputType == Enum.UserInputType.MouseMovement
        or inp.UserInputType == Enum.UserInputType.Touch then
            local d = inp.Position - mStart
            if d.Magnitude > 6 then mMoved = true end
            MBtn.Position = UDim2.new(
                mPos.X.Scale, mPos.X.Offset + d.X,
                mPos.Y.Scale, mPos.Y.Offset + d.Y
            )
        end
    end)

    MBtn.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            if mDrag and not mMoved and tick() - mTick < 0.28 then
                Main.Visible = not Main.Visible
                if Main.Visible then Notify("Markiyan PRO","Меню ✓",1) end
            end
            mDrag = false
        end
    end)

    -- Запасний
    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            mDrag = false
        end
    end)
end

-- ============================================================
-- [[ СТАРТ ]]
-- ============================================================
ShowTab("Combat")

Notify("Markiyan PRO V47",
    IsMobile
        and "📱 Mobile оптимізовано | M=меню | Binds→таб"
        or  "M=меню | G=aim | F=fly | V=noclip | Binds→таб",
    4)
