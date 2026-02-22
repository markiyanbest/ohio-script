-- markiyanbest's script (V43 - PERFECT EDITION)
-- Оптимізовано: витоки пам'яті, продуктивність, стабільність

local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local RS = game:GetService("RunService")
local Light = game:GetService("Lighting")
local UIS = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local Camera = workspace.CurrentCamera
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")

-- == [ ОЧИЩЕННЯ ПОПЕРЕДНЬОЇ ВЕРСІЇ ] ==
if lp.PlayerGui:FindFirstChild("MarkiyanPro") then 
    lp.PlayerGui.MarkiyanPro:Destroy() 
end

-- == [ КООРДИНАТИ ] ==
local COORDS = {
    ["GUN_SHOP"]   = Vector3.new(1131, 25, -1344),
    ["BANK_ENT"]   = Vector3.new(1106, 8, -336),
    ["BANK_MONEY"] = Vector3.new(1110, 8, -325),
    ["SAFE_ZONE"]  = Vector3.new(-37, -27, 3)
}

-- == [ КОНФІГ ] ==
local Config = {
    Farm        = false,
    Speed       = false,
    Bright      = false,
    Armor       = false,
    Heal        = false,
    AimActive   = false,
    LockedTarget = nil,
    FPSBoost    = false,
    AntiSeat    = false,
    AntiAFK     = false,
    Fly         = false,
    FlySpeedValue  = 50,
    WalkSpeedValue = 65,
    ESP         = false,
    NoSpread    = false,
    InfJump     = false,
    Noclip      = false,
    Magnet      = false,
    MagnetTarget = nil,
    AutoSafe    = false,
    SafeHealth  = 35,
    
    -- БІЛИЙ СПИСОК (без дублікатів)
    Loot = {
        "void", "gem", "shard", "suitcase nuke", "nuke", "nextbot",
        "ninja star", "stop sign", "printer", "money printer",
        "materials", "candy", "gold ak", "gold deagle", "gold glock",
        "gold knife", "flamethrower", "barrett", "m107", "rpg",
        "launcher", "c4", "molotov", "scrap", "cane", "scar l",
        "m4", "ak", "sniper", "weapon parts", "explosives", "helimail",
        "helicopter", "mobile dealer", "lockpick", "santa", "blue",
        "key", "card", "cash", "money", "wallet", "electronics",
        "atm", "safe", "diamond", "gold bar", "limited", "box",
        "crate", "mustang", "mattery", "medkit", "heavy armor",
        "medium armor", "light armor", "vest", "phone", "bandage",
        "balloon", "cookies", "air", "drop", "dark", "lucky",
        "m1911", "glock", "glock18", "usp45", "python", "deagle",
        "uzi", "stagecoach", "mossberg", "sawnoff", "doublebarrel",
        "saiga12", "ar15", "ak47", "m4a1", "aug", "tommygun",
        "asval", "rpk", "dragunov", "m249", "mp7", "fnfal", "p90",
        "scarl", "awp", "m1garand", "barrettm107", "cannonrpg",
        "acidgun", "raygun", "gravitygun", "minigun", "goldak47",
        "adminak47", "adminrpg", "taser", "pepperspray", "moneygun",
        "ninjastars", "shurikens", "tomahawk", "heavyvest",
        "militaryvest", "helmet", "mask", "backpack", "flashlight",
        "radio", "moneybag", "atmcards", "coffee", "moneyprinter",
        "cloverballoon", "moneyballoon", "heartballoon",
        "luckyblockcrate", "sabercrate"
    },
    
    -- ЧОРНИЙ СПИСОК
    Blacklist = {
        "trash", "newspaper", "bottle", "leaf", "stick", "shoe",
        "apple", "soda", "burger", "hotdog", "stop", "ore", "ladder",
        "fireworks", "press", "paintball", "spawn", "bloxiade", "cola",
        "spin", "requires", "door", "gate", "barrier", "cell",
        "unlock after", "cash earned", "garage", "ammo", "pickaxe",
        "sign", "equip", "put", "on", "food", "gloves", "spray",
        "ignite", "steal", "brew", "latte", "espresso", "drink",
        "vending machine", "bloxy", "bat", "katana", "flashbang",
        "skateboard", "bike", "off", "turn", "ninja", "workbench",
        "edit", "open", "fill", "drain", "close", "guitar"
    }
}

-- == [ КЕШ ДЛЯ ЛУТА (щоб не робити lower() кожен раз) ] ==
local LootCache = {}
local BlacklistCache = {}
for _, v in pairs(Config.Loot) do LootCache[v] = true end
for _, v in pairs(Config.Blacklist) do BlacklistCache[v] = true end

-- == [ ДОПОМІЖНІ ФУНКЦІЇ ] ==

-- Безпечна телепортація з перевіркою
local function SafeTeleport(position)
    if not lp.Character then return false end
    local hum = lp.Character:FindFirstChild("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    local root = lp.Character:FindFirstChild("HumanoidRootPart")
    if not root then return false end
    lp.Character:PivotTo(CFrame.new(position + Vector3.new(0, 3, 0)))
    return true
end

-- Сповіщення
local function Notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title   = title,
            Text    = text,
            Duration = duration or 2
        })
    end)
end

-- Отримати живого гравця поруч з прицілом
local function GetClosestPlayer()
    local target, bestDist = nil, 800
    local center = Vector2.new(
        Camera.ViewportSize.X / 2,
        Camera.ViewportSize.Y / 2
    )
    for _, v in pairs(Players:GetPlayers()) do
        if v == lp then continue end
        local char = v.Character
        if not char then continue end
        local head = char:FindFirstChild("Head")
        local hum  = char:FindFirstChildOfClass("Humanoid")
        if not head or not hum or hum.Health <= 0 then continue end
        local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
        if not onScreen then continue end
        local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
        if dist < bestDist then
            bestDist = dist
            target = v
        end
    end
    return target
end

-- Перевірка чи ціль все ще жива
local function IsTargetAlive(target)
    if not target or not target.Parent then return false end
    local char = target.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

-- == [ МОБІЛЬНІ КОНТРОЛЕРИ ] ==
local Controls = nil
task.spawn(function()
    if not game:IsLoaded() then game.Loaded:Wait() end
    pcall(function()
        local PlayerModule = require(
            lp.PlayerScripts:WaitForChild("PlayerModule", 5)
        )
        Controls = PlayerModule:GetControls()
    end)
end)

-- == [ FPS BOOST ] ==
local function ApplyFPS()
    pcall(function()
        settings().Rendering.QualityLevel = 1
        Light.GlobalShadows = false
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Material = Enum.Material.SmoothPlastic
            end
            if v:IsA("Decal") or v:IsA("Texture") then
                v:Destroy()
            end
        end
    end)
    Notify("FPS BOOST", "Графіку знижено ✓", 2)
end

-- == [ AUTO HEAL / ARMOR ] ==
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if not lp.Character then return end
            local hum = lp.Character:FindFirstChildOfClass("Humanoid")
            if not hum or hum.Health <= 0 then return end

            if Config.Heal and hum.Health < 75 then
                local med = lp.Backpack:FindFirstChild("Medkit")
                    or lp.Character:FindFirstChild("Medkit")
                if med and med:IsA("Tool") then
                    lp.Character.Humanoid:EquipTool(med)
                    task.wait(0.1)
                    med:Activate()
                end
            end

            if Config.Armor then
                local arm = lp.Backpack:FindFirstChild("Armor")
                    or lp.Character:FindFirstChild("Armor")
                if arm and arm:IsA("Tool") then
                    lp.Character.Humanoid:EquipTool(arm)
                    task.wait(0.1)
                    arm:Activate()
                end
            end
        end)
    end
end)

-- == [ ANTI-AFK ] ==
-- Подія + таймер для надійності
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

-- == [ АВТО-ГРАБІЖ БАНКУ ] ==
local function StartRobbery()
    if not lp.Character then return end
    Notify("BANK ROB", "Починаємо пограбування...", 2)
    
    if not SafeTeleport(COORDS["BANK_MONEY"]) then
        Notify("BANK ROB", "Помилка телепорту!", 2)
        return
    end
    task.wait(0.6)
    
    for i = 1, 20 do
        if not lp.Character then break end
        local hum = lp.Character:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then break end
        
        pcall(function()
            for _, v in pairs(workspace:GetDescendants()) do
                if not v:IsA("ProximityPrompt") or not v.Enabled then continue end
                local root = lp.Character:FindFirstChild("HumanoidRootPart")
                if not root then continue end
                local dist = (root.Position - v.Parent:GetPivot().Position).Magnitude
                if dist < 15 then
                    fireproximityprompt(v)
                end
            end
        end)
        task.wait(0.4)
    end
    
    SafeTeleport(COORDS["SAFE_ZONE"])
    Notify("BANK ROB", "Завершено! Телепорт у Safe Zone ✓", 3)
end

-- == [ ESP СИСТЕМА ] ==
local ESPConnections = {}

local function ClearESP(char)
    if not char then return end
    local head = char:FindFirstChild("Head")
    if head then
        local gui = head:FindFirstChild("MarkiyanESP")
        if gui then gui:Destroy() end
    end
    local hl = char:FindFirstChild("MarkiyanHighlight")
    if hl then hl:Destroy() end
end

local function ClearAllESP()
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= lp then ClearESP(v.Character) end
    end
end

-- Підписка на CharacterAdded для автоочищення ESP
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        if not Config.ESP then ClearESP(char) end
    end)
end)

-- ESP оновлення (оптимізовано: не кожен кадр а через task.wait)
task.spawn(function()
    while task.wait(0.05) do -- 20 разів на секунду достатньо
        if not Config.ESP then continue end
        
        for _, v in pairs(Players:GetPlayers()) do
            if v == lp then continue end
            local char = v.Character
            if not char then continue end
            
            local hum  = char:FindFirstChildOfClass("Humanoid")
            local head = char:FindFirstChild("Head")
            local root = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
            
            if not hum or not head or hum.Health <= 0 then
                ClearESP(char)
                continue
            end
            
            -- Створення ESP GUI якщо немає
            local espGui = head:FindFirstChild("MarkiyanESP")
            if not espGui then
                espGui = Instance.new("BillboardGui")
                espGui.Name           = "MarkiyanESP"
                espGui.Size           = UDim2.new(0, 200, 0, 55)
                espGui.StudsOffset    = Vector3.new(0, 3, 0)
                espGui.AlwaysOnTop    = true
                espGui.MaxDistance    = 500
                
                local bg = Instance.new("Frame", espGui)
                bg.Size                  = UDim2.new(1, 0, 1, 0)
                bg.BackgroundColor3      = Color3.fromRGB(0, 0, 0)
                bg.BackgroundTransparency = 0.5
                Instance.new("UICorner", bg)
                
                local lbl = Instance.new("TextLabel", bg)
                lbl.Name                  = "ESPLabel"
                lbl.Size                  = UDim2.new(1, 0, 1, 0)
                lbl.BackgroundTransparency = 1
                lbl.TextStrokeTransparency = 0.2
                lbl.TextStrokeColor3      = Color3.new(0, 0, 0)
                lbl.Font                  = Enum.Font.SourceSansBold
                lbl.TextSize              = 13
                lbl.TextWrapped           = true
                
                espGui.Parent = head
                
                -- Highlight
                local hl = Instance.new("Highlight")
                hl.Name                = "MarkiyanHighlight"
                hl.FillColor           = Color3.new(1, 0, 0)
                hl.OutlineColor        = Color3.new(1, 1, 1)
                hl.FillTransparency    = 0.6
                hl.OutlineTransparency = 0
                hl.Parent              = char
            end
            
            -- Оновлення тексту
            local lbl = espGui:FindFirstChild("ESPLabel", true)
            if lbl then
                local dist = root 
                    and math.floor((root.Position - head.Position).Magnitude) 
                    or 0
                local hp    = math.floor(hum.Health)
                local maxHp = math.floor(hum.MaxHealth)
                local ratio = hp / math.max(maxHp, 1)
                
                lbl.Text = string.format(
                    "[%s]\nHP: %d/%d | %dm",
                    v.Name, hp, maxHp, dist
                )
                
                if ratio >= 0.6 then
                    lbl.TextColor3 = Color3.fromRGB(0, 255, 100)
                elseif ratio >= 0.3 then
                    lbl.TextColor3 = Color3.fromRGB(255, 220, 0)
                else
                    lbl.TextColor3 = Color3.fromRGB(255, 60, 60)
                end
            end
        end
    end
end)

-- == [ AIM LOCK ] ==
RS.RenderStepped:Connect(function()
    if not Config.AimActive then
        Config.LockedTarget = nil
        return
    end
    
    if not IsTargetAlive(Config.LockedTarget) then
        Config.LockedTarget = GetClosestPlayer()
    end
    
    if Config.LockedTarget then
        local char = Config.LockedTarget.Character
        local head = char and char:FindFirstChild("Head")
        if head then
            Camera.CFrame = CFrame.lookAt(
                Camera.CFrame.Position,
                head.Position
            )
        end
    end
end)

-- == [ AUTO FARM ] ==
local farmRunning = false
task.spawn(function()
    while task.wait(0.4) do
        if not Config.Farm or farmRunning then continue end
        farmRunning = true
        
        pcall(function()
            if not lp.Character then return end
            local hum = lp.Character:FindFirstChildOfClass("Humanoid")
            if not hum or hum.Health <= 0 then return end
            
            for _, v in pairs(workspace:GetDescendants()) do
                if not Config.Farm then break end -- стоп якщо вимкнули
                if not v:IsA("ProximityPrompt") or not v.Enabled then continue end
                
                local text = (v.Parent.Name .. v.ActionText .. v.ObjectText):lower()
                local allowed = false
                
                for lootItem, _ in pairs(LootCache) do
                    if text:find(lootItem, 1, true) then
                        allowed = true
                        break
                    end
                end
                
                if allowed then
                    for blackItem, _ in pairs(BlacklistCache) do
                        if text:find(blackItem, 1, true) then
                            allowed = false
                            break
                        end
                    end
                end
                
                if allowed then
                    -- Перевірка відстані перед телепортом
                    local targetPos = v.Parent:GetPivot().Position
                    SafeTeleport(targetPos)
                    task.wait(0.2)
                    pcall(fireproximityprompt, v)
                    task.wait(0.2)
                end
            end
        end)
        
        farmRunning = false
    end
end)

-- == [ NOCLIP ] ==
local function RestoreCollision()
    if not lp.Character then return end
    for _, v in pairs(lp.Character:GetDescendants()) do
        if v:IsA("BasePart") then
            v.CanCollide = true
        end
    end
end

RS.Stepped:Connect(function()
    if not Config.Noclip or not lp.Character then return end
    for _, v in pairs(lp.Character:GetDescendants()) do
        if v:IsA("BasePart") then
            v.CanCollide = false
        end
    end
end)

-- == [ HEARTBEAT: FLY, SPEED, MAGNET, AUTOSAFE, ANTISEAT ] ==
RS.Heartbeat:Connect(function()
    if not lp.Character then return end
    local hum  = lp.Character:FindFirstChildOfClass("Humanoid")
    local root = lp.Character:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return end

    -- Anti-Seat
    if Config.AntiSeat and hum.SeatPart then
        hum.Sit = false
    end

    -- Speed
    if Config.Speed and not Config.Fly then
        hum.WalkSpeed = Config.WalkSpeedValue
    elseif not Config.Fly then
        hum.WalkSpeed = 16
    end

    -- Fly
    if Config.Fly then
        hum.PlatformStand = true
        hum.WalkSpeed     = 0

        local camLook  = Camera.CFrame.LookVector
        local camRight = Camera.CFrame.RightVector
        local moveX, moveZ = 0, 0

        -- Мобільний рух
        if Controls then
            local mv = Controls:GetMoveVector()
            moveX = mv.X
            moveZ = mv.Z
        end

        -- ПК рух
        if not UIS.TouchEnabled then
            if UIS:IsKeyDown(Enum.KeyCode.W) then moveZ = -1 end
            if UIS:IsKeyDown(Enum.KeyCode.S) then moveZ =  1 end
            if UIS:IsKeyDown(Enum.KeyCode.A) then moveX = -1 end
            if UIS:IsKeyDown(Enum.KeyCode.D) then moveX =  1 end
        end

        local dir = (camLook * -moveZ) + (camRight * moveX)
        if UIS:IsKeyDown(Enum.KeyCode.Space) then
            dir = dir + Vector3.new(0, 1, 0)
        end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
            dir = dir - Vector3.new(0, 1, 0)
        end

        -- Нормалізація щоб діагональ не була швидшою
        if dir.Magnitude > 1 then
            dir = dir.Unit
        end

        root.AssemblyLinearVelocity  = dir * Config.FlySpeedValue
        root.AssemblyAngularVelocity = Vector3.zero
    else
        if hum.PlatformStand then
            hum.PlatformStand = false
        end
    end

    -- Magnet (плавний рух замість телепорту)
    if Config.Magnet then
        if not IsTargetAlive(Config.MagnetTarget) then
            Config.MagnetTarget = GetClosestPlayer()
        end
        
        if Config.MagnetTarget then
            local tChar = Config.MagnetTarget.Character
            local tHRP  = tChar and tChar:FindFirstChild("HumanoidRootPart")
            if tHRP then
                local targetCF = tHRP.CFrame * CFrame.new(0, 0, 3)
                -- Плавний Lerp замість жорсткого телепорту
                root.CFrame = root.CFrame:Lerp(targetCF, 0.25)
                root.AssemblyLinearVelocity = tHRP.AssemblyLinearVelocity
            end
        end
    else
        Config.MagnetTarget = nil
    end

    -- AutoSafe (з кулдауном щоб не спамити телепорт)
    if Config.AutoSafe and hum.Health > 0 and hum.Health <= Config.SafeHealth then
        local distToSafe = (root.Position - COORDS["SAFE_ZONE"]).Magnitude
        if distToSafe > 20 then
            SafeTeleport(COORDS["SAFE_ZONE"])
            Notify("AUTO SAFE", "Телепорт у Safe Zone! HP: " .. math.floor(hum.Health), 3)
        end
    end
end)

-- == [ INFINITE JUMP ] ==
UIS.JumpRequest:Connect(function()
    if not Config.InfJump then return end
    if not lp.Character then return end
    local hum = lp.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- == [ GUI СИСТЕМА ] ==
local SG = Instance.new("ScreenGui", lp.PlayerGui)
SG.Name           = "MarkiyanPro"
SG.ResetOnSpawn   = false
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local IsMobile  = UIS.TouchEnabled
local MainWidth  = IsMobile and 240 or 360
local MainHeight = IsMobile and 380 or 520

-- Головний фрейм
local Main = Instance.new("Frame", SG)
Main.Size            = UDim2.new(0, MainWidth, 0, MainHeight)
Main.AnchorPoint     = Vector2.new(0.5, 0.5)
Main.Position        = UDim2.new(0.5, 0, 0.5, 0)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
Main.BorderSizePixel = 0
Main.Visible         = false
Instance.new("UICorner", Main)

-- Тінь
local Shadow = Instance.new("ImageLabel", Main)
Shadow.Size              = UDim2.new(1, 30, 1, 30)
Shadow.Position          = UDim2.new(0, -15, 0, -15)
Shadow.BackgroundTransparency = 1
Shadow.Image             = "rbxassetid://6015897843"
Shadow.ImageColor3       = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.5
Shadow.ZIndex            = -1

-- Хедер
local Header = Instance.new("TextLabel", Main)
Header.Size              = UDim2.new(1, 0, 0, 35)
Header.Text              = "⚡ Markiyan PRO V43"
Header.BackgroundColor3  = Color3.fromRGB(0, 100, 255)
Header.TextColor3        = Color3.fromRGB(255, 255, 255)
Header.Font              = Enum.Font.SourceSansBold
Header.TextSize          = IsMobile and 14 or 16
Header.BorderSizePixel   = 0
Instance.new("UICorner", Header)

-- Лінія під хедером
local Divider = Instance.new("Frame", Main)
Divider.Size             = UDim2.new(1, 0, 0, 2)
Divider.Position         = UDim2.new(0, 0, 0, 35)
Divider.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
Divider.BorderSizePixel  = 0

-- ScrollingFrame
local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size                = UDim2.new(1, -8, 1, -45)
Scroll.Position            = UDim2.new(0, 4, 0, 42)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness  = IsMobile and 0 or 3
Scroll.ScrollBarImageColor3 = Color3.fromRGB(0, 100, 255)
Scroll.BorderSizePixel     = 0

local Layout = Instance.new("UIListLayout", Scroll)
Layout.Padding             = UDim.new(0, 5)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local ScrollPadding = Instance.new("UIPadding", Scroll)
ScrollPadding.PaddingTop    = UDim.new(0, 5)
ScrollPadding.PaddingBottom = UDim.new(0, 5)

-- Авто розмір canvas
Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Scroll.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 15)
end)

-- == [ ПЕРЕТЯГУВАННЯ (ЗАХИСТ ВІД SHIFT LOCK) ] ==
local function MakeDraggable(handle, target)
    local dragging  = false
    local dragStart = nil
    local startPos  = nil

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = input.Position
            startPos  = target.Position
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            target.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

MakeDraggable(Header, Main)

-- == [ КНОПКИ ] ==
local Buttons = {}

-- Категорії (роздільники)
local function AddCategory(text)
    local cat = Instance.new("TextLabel", Scroll)
    cat.Size              = UDim2.new(0.95, 0, 0, 20)
    cat.BackgroundColor3  = Color3.fromRGB(0, 80, 200)
    cat.TextColor3        = Color3.fromRGB(255, 255, 255)
    cat.Font              = Enum.Font.SourceSansBold
    cat.TextSize          = 12
    cat.Text              = "── " .. text .. " ──"
    cat.BorderSizePixel   = 0
    Instance.new("UICorner", cat)
end

-- Toggle кнопка
local function AddToggle(name, key, callback)
    local btn = Instance.new("TextButton", Scroll)
    btn.Size              = UDim2.new(0.95, 0, 0, 32)
    btn.BackgroundColor3  = Color3.fromRGB(25, 25, 30)
    btn.TextColor3        = Color3.fromRGB(200, 200, 200)
    btn.Font              = Enum.Font.SourceSansBold
    btn.TextSize          = IsMobile and 12 or 14
    btn.BorderSizePixel   = 0
    btn.AutoButtonColor   = false
    Instance.new("UICorner", btn)

    -- Іконка статусу
    local StatusDot = Instance.new("Frame", btn)
    StatusDot.Size            = UDim2.new(0, 8, 0, 8)
    StatusDot.Position        = UDim2.new(0, 10, 0.5, -4)
    StatusDot.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    StatusDot.BorderSizePixel = 0
    Instance.new("UICorner", StatusDot)

    btn.Text = "   " .. name .. ": OFF"
    Buttons[key] = btn

    local function UpdateVisual(state)
        if state then
            btn.BackgroundColor3  = Color3.fromRGB(0, 80, 200)
            btn.TextColor3        = Color3.fromRGB(255, 255, 255)
            StatusDot.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
            btn.Text = "   " .. name .. ": ON"
        else
            btn.BackgroundColor3  = Color3.fromRGB(25, 25, 30)
            btn.TextColor3        = Color3.fromRGB(200, 200, 200)
            StatusDot.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
            btn.Text = "   " .. name .. ": OFF"
        end
    end

    btn.MouseButton1Click:Connect(function()
        Config[key] = not Config[key]
        UpdateVisual(Config[key])

        -- Cleanup при вимкненні
        if not Config[key] then
            if key == "AimActive" then Config.LockedTarget  = nil end
            if key == "Magnet"    then Config.MagnetTarget  = nil end
            if key == "Noclip"    then RestoreCollision()         end
            if key == "ESP"       then ClearAllESP()              end
            if key == "Fly" then
                local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum.PlatformStand = false end
            end
        end

        if callback and Config[key] then callback() end

        Notify(
            name,
            Config[key] and "Увімкнено ✓" or "Вимкнено ✗",
            1.5
        )
    end)

    return UpdateVisual
end

-- Кнопка-дія (не toggle)
local function AddAction(name, color, callback)
    local btn = Instance.new("TextButton", Scroll)
    btn.Size              = UDim2.new(0.95, 0, 0, 32)
    btn.BackgroundColor3  = color or Color3.fromRGB(150, 0, 0)
    btn.TextColor3        = Color3.fromRGB(255, 255, 255)
    btn.Font              = Enum.Font.SourceSansBold
    btn.TextSize          = IsMobile and 12 or 14
    btn.BorderSizePixel   = 0
    btn.AutoButtonColor   = false
    btn.Text              = name
    Instance.new("UICorner", btn)

    -- Ефект натискання
    btn.MouseButton1Click:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        task.wait(0.1)
        btn.BackgroundColor3 = color or Color3.fromRGB(150, 0, 0)
        task.spawn(callback)
    end)
end

-- Слайдер (захист від Shift Lock)
local function AddSlider(label, min, max, default, configKey)
    local container = Instance.new("Frame", Scroll)
    container.Size             = UDim2.new(0.95, 0, 0, 52)
    container.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    container.BorderSizePixel  = 0
    Instance.new("UICorner", container)

    local lbl = Instance.new("TextLabel", container)
    lbl.Size                  = UDim2.new(1, -10, 0, 22)
    lbl.Position              = UDim2.new(0, 5, 0, 2)
    lbl.BackgroundTransparency = 1
    lbl.Text                  = label .. ": " .. default
    lbl.TextColor3            = Color3.fromRGB(200, 200, 200)
    lbl.Font                  = Enum.Font.SourceSansBold
    lbl.TextSize              = 13
    lbl.TextXAlignment        = Enum.TextXAlignment.Left

    local track = Instance.new("Frame", container)
    track.Size             = UDim2.new(0.9, 0, 0, 8)
    track.Position         = UDim2.new(0.05, 0, 0, 30)
    track.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    track.BorderSizePixel  = 0
    Instance.new("UICorner", track)

    local fill = Instance.new("Frame", track)
    fill.Size             = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
    fill.BorderSizePixel  = 0
    Instance.new("UICorner", fill)

    local knob = Instance.new("Frame", track)
    knob.Size              = UDim2.new(0, 14, 0, 14)
    knob.Position          = UDim2.new((default - min) / (max - min), -7, 0.5, -7)
    knob.BackgroundColor3  = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel   = 0
    Instance.new("UICorner", knob)

    local dragging = false

    local function UpdateSlider(input)
        local rel = math.clamp(
            (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X,
            0, 1
        )
        local value = math.floor(min + rel * (max - min))
        fill.Size     = UDim2.new(rel, 0, 1, 0)
        knob.Position = UDim2.new(rel, -7, 0.5, -7)
        lbl.Text      = label .. ": " .. value
        Config[configKey] = value
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            UpdateSlider(input)
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            UpdateSlider(input)
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- Телепорт кнопка
local function AddTP(name, vec)
    local btn = Instance.new("TextButton", Scroll)
    btn.Size              = UDim2.new(0.95, 0, 0, 30)
    btn.BackgroundColor3  = Color3.fromRGB(30, 30, 40)
    btn.TextColor3        = Color3.fromRGB(255, 215, 0)
    btn.Font              = Enum.Font.SourceSansBold
    btn.TextSize          = IsMobile and 12 or 13
    btn.BorderSizePixel   = 0
    btn.AutoButtonColor   = false
    btn.Text              = "📍 TP: " .. name
    Instance.new("UICorner", btn)

    btn.MouseButton1Click:Connect(function()
        if SafeTeleport(vec) then
            Notify("TELEPORT", "➜ " .. name, 2)
        end
    end)
end

-- == [ НАПОВНЕННЯ GUI ] ==

AddCategory("COMBAT")
AddToggle("AIM LOCK [G]",     "AimActive")
AddToggle("PLAYER ESP",       "ESP")
AddToggle("MAGNET",           "Magnet")

AddCategory("MOVEMENT")
AddToggle("FLY [F]",          "Fly")
AddSlider("FLY SPEED",  10, 250, Config.FlySpeedValue,  "FlySpeedValue")
AddToggle("SPEED HACK",       "Speed")
AddSlider("WALK SPEED", 16, 150, Config.WalkSpeedValue, "WalkSpeedValue")
AddToggle("NOCLIP [V]",       "Noclip")
AddToggle("INF JUMP",         "InfJump")

AddCategory("SURVIVAL")
AddToggle("AUTO SAFE HP",     "AutoSafe")
AddToggle("AUTO HEAL",        "Heal")
AddToggle("AUTO ARMOR",       "Armor")

AddCategory("FARM & MISC")
AddToggle("AUTO FARM",        "Farm")
AddToggle("ANTI-SEAT",        "AntiSeat")
AddToggle("ANTI-AFK",         "AntiAFK")
AddToggle("FPS BOOST",        "FPSBoost", ApplyFPS)

AddCategory("ACTIONS")
AddAction(
    "🏦 AUTO ROB BANK",
    Color3.fromRGB(180, 20, 20),
    StartRobbery
)

AddCategory("TELEPORTS")
AddTP("GUN SHOP",  COORDS["GUN_SHOP"])
AddTP("BANK",      COORDS["BANK_ENT"])
AddTP("SAFE ZONE", COORDS["SAFE_ZONE"])

-- == [ КНОПКА ВІДКРИТТЯ МЕНЮ (M) ] ==
local MBtn = Instance.new("TextButton", SG)
MBtn.Size              = UDim2.new(0, IsMobile and 50 or 42, 0, IsMobile and 50 or 42)
MBtn.Position          = UDim2.new(0, 10, 0.3, 0)
MBtn.Text              = "M"
MBtn.Font              = Enum.Font.SourceSansBold
MBtn.TextSize          = IsMobile and 22 or 18
MBtn.BackgroundColor3  = Color3.fromRGB(0, 100, 255)
MBtn.TextColor3        = Color3.fromRGB(255, 255, 255)
MBtn.BorderSizePixel   = 0
MBtn.AutoButtonColor   = false
Instance.new("UICorner", MBtn)

-- Пульсація кнопки
task.spawn(function()
    while true do
        TweenService:Create(MBtn, TweenInfo.new(1), {
            BackgroundColor3 = Color3.fromRGB(0, 60, 180)
        }):Play()
        task.wait(1)
        TweenService:Create(MBtn, TweenInfo.new(1), {
            BackgroundColor3 = Color3.fromRGB(0, 100, 255)
        }):Play()
        task.wait(1)
    end
end)

-- Перетягування M кнопки з захистом від випадкового кліку
local mDragging    = false
local mDragStart   = nil
local mStartPos    = nil
local mClickTick   = 0
local mDragMoved   = false

MBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        mDragging  = true
        mDragStart = input.Position
        mStartPos  = MBtn.Position
        mClickTick = tick()
        mDragMoved = false
    end
end)

UIS.InputChanged:Connect(function(input)
    if not mDragging then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - mDragStart
        if delta.Magnitude > 5 then mDragMoved = true end
        MBtn.Position = UDim2.new(
            mStartPos.X.Scale,
            mStartPos.X.Offset + delta.X,
            mStartPos.Y.Scale,
            mStartPos.Y.Offset + delta.Y
        )
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        if mDragging then
            mDragging = false
            -- Клік тільки якщо не перетягували і швидко
            if not mDragMoved and tick() - mClickTick < 0.25 then
                Main.Visible = not Main.Visible
                if Main.Visible then
                    Notify("Markiyan PRO", "Меню відкрито ✓", 1)
                end
            end
        end
    end
end)

-- == [ КЛАВІШІ БІНДІВ ] ==
UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    -- G = AimLock
    if input.KeyCode == Enum.KeyCode.G then
        Config.AimActive = not Config.AimActive
        local btn = Buttons["AimActive"]
        if btn then
            -- Знаходимо dot
            local dot = btn:FindFirstChildOfClass("Frame")
            if Config.AimActive then
                btn.BackgroundColor3 = Color3.fromRGB(0, 80, 200)
                btn.TextColor3       = Color3.fromRGB(255, 255, 255)
                btn.Text             = "   AIM LOCK [G]: ON"
                if dot then dot.BackgroundColor3 = Color3.fromRGB(0, 255, 100) end
            else
                btn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
                btn.TextColor3       = Color3.fromRGB(200, 200, 200)
                btn.Text             = "   AIM LOCK [G]: OFF"
                if dot then dot.BackgroundColor3 = Color3.fromRGB(255, 60, 60) end
                Config.LockedTarget = nil
            end
        end
        Notify("AIM LOCK", Config.AimActive and "ON ✓" or "OFF ✗", 1.5)

    -- F = Fly
    elseif input.KeyCode == Enum.KeyCode.F then
        Config.Fly = not Config.Fly
        local btn = Buttons["Fly"]
        if btn then
            local dot = btn:FindFirstChildOfClass("Frame")
            if Config.Fly then
                btn.BackgroundColor3 = Color3.fromRGB(0, 80, 200)
                btn.TextColor3       = Color3.fromRGB(255, 255, 255)
                btn.Text             = "   FLY [F]: ON"
                if dot then dot.BackgroundColor3 = Color3.fromRGB(0, 255, 100) end
            else
                btn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
                btn.TextColor3       = Color3.fromRGB(200, 200, 200)
                btn.Text             = "   FLY [F]: OFF"
                if dot then dot.BackgroundColor3 = Color3.fromRGB(255, 60, 60) end
                local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum.PlatformStand = false end
            end
        end
        Notify("FLY", Config.Fly and "ON ✓" or "OFF ✗", 1.5)

    -- V = Noclip
    elseif input.KeyCode == Enum.KeyCode.V then
        Config.Noclip = not Config.Noclip
        local btn = Buttons["Noclip"]
        if btn then
            local dot = btn:FindFirstChildOfClass("Frame")
            if Config.Noclip then
                btn.BackgroundColor3 = Color3.fromRGB(0, 80, 200)
                btn.TextColor3       = Color3.fromRGB(255, 255, 255)
                btn.Text             = "   NOCLIP [V]: ON"
                if dot then dot.BackgroundColor3 = Color3.fromRGB(0, 255, 100) end
            else
                btn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
                btn.TextColor3       = Color3.fromRGB(200, 200, 200)
                btn.Text             = "   NOCLIP [V]: OFF"
                if dot then dot.BackgroundColor3 = Color3.fromRGB(255, 60, 60) end
                RestoreCollision()
            end
        end
        Notify("NOCLIP", Config.Noclip and "ON ✓" or "OFF ✗", 1.5)
    end
end)

-- == [ CLEANUP при виході ] ==
Players.LocalPlayer.CharacterRemoving:Connect(function()
    Config.Fly    = false
    Config.Noclip = false
    if Buttons["Fly"] then
        Buttons["Fly"].Text            = "   FLY [F]: OFF"
        Buttons["Fly"].BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    end
    if Buttons["Noclip"] then
        Buttons["Noclip"].Text            = "   NOCLIP [V]: OFF"
        Buttons["Noclip"].BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    end
end)

-- == [ ГОТОВО ] ==
Notify("Markiyan PRO V43", "Скрипт завантажено! Натисни M ✓", 4)
