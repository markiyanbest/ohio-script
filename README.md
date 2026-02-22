-- markiyanbest's script (V42 - THE STABLE BASE) [UPGRADED HYBRID EDITION + ESP + MAGNET + AUTOSAFE + SHIFT LOCK BUG FIX]
local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local RS = game:GetService("RunService")
local Light = game:GetService("Lighting")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local StarterGui = game:GetService("StarterGui")

-- == [ КОРДИНАТИ ] ==
local COORDS = {
    ["GUN_SHOP"]   = Vector3.new(1131, 25, -1344),
    ["BANK_ENT"]   = Vector3.new(1106, 8, -336),
    ["BANK_MONEY"] = Vector3.new(1110, 8, -325),
    ["SAFE_ZONE"]  = Vector3.new(-37, -27, 3)
}

if lp.PlayerGui:FindFirstChild("MarkiyanPro") then lp.PlayerGui.MarkiyanPro:Destroy() end

local Config = {
    Farm = false, Speed = false, Bright = false, Armor = false, Heal = false,
    AimActive = false, LockedTarget = nil, 
    FPSBoost = false, AntiSeat = false,
    Fly = false, FlySpeedValue = 50, WalkSpeedValue = 65,
    ESP = false, NoSpread = false, InfJump = false, Noclip = false,
    Magnet = false, MagnetTarget = nil,
    AutoSafe = false, SafeHealth = 35,
    -- == [ ПОВНИЙ БІЛИЙ СПИСОК (ДОДАНО ВСЮ ЗБРОЮ ТА ПРЕДМЕТИ) ] ==
    Loot = {
        "void", "gem", "shard", "suitcase nuke", "nuke", "nextbot", "ninja star", "stop sign", "printer", "money printer", "steal", "materials", "candy",
        "gold ak", "gold deagle", "gold glock", "gold knife", "flamethrower", "barrett", "m107", "rpg", "launcher", "c4", "molotov", "scrap", "cane", "scar l",
        "m4", "ak", "sniper", "weapon parts", "explosives", "helimail", "helicopter", "mobile dealer", "lockpick", "santa", "blue",
        "key", "card", "cash", "money", "wallet", "electronics", "atm", "safe", "diamond", "gold bar", "limited", "box", "crate", "mustang", "mattery",
        "medkit", "heavy armor", "medium armor", "light armor", "vest", "phone", "bandage", "balloon", "cookies", "air", "drop", "diamond",  "dark", "lucky",
        "m1911", "glock", "glock18", "usp45", "python", "deagle", "uzi", "stagecoach", "mossberg", "sawnoff", "doublebarrel", "saiga12", "ar15", "ak47", "m4a1", "aug", 
        "tommygun", "asval", "rpk", "dragunov", "m249", "mp7", "fnfal", "p90", "scarl", "awp", "m1garand", "barrettm107", "cannonrpg", "acidgun", "raygun", "gravitygun", 
        "minigun", "goldak47", "adminak47", "adminrpg", "taser", "pepperspray", "moneygun", "ninjastars", "shurikens", "tomahawk", "heavyvest", "militaryvest", "helmet", 
        "mask", "backpack", "flashlight", "radio", "moneybag", "atmcards", "coffee", "moneyprinter", "cloverballoon", "moneyballoon", "heartballoon", "luckyblockcrate", "sabercrate"
    },
    -- == [ РОЗШИРЕНИЙ ЧОРНИЙ СПИСОК ] ==
    Blacklist = {
        "trash", "newspaper", "bottle", "leaf", "stick", "shoe", "apple", "soda", "burger", "hotdog", "stop", "ore", "ladder", "fireworks", "press", "paintball", "spawn", "bloxiade", "cola", "spin",
        "requires", "door", "gate", "barrier", "cell", "unlock after", "cash earned", "garage", "ammo", "pickaxe", "sign", "equip", "put", "on", "food", "gloves", "spray", "ignite",
        "brew", "latte", "espresso", "drink", "vending machine", "cola", "bloxy", "bat", "katana", "flashbang", "skateboard", "bike", "off", "turn", "ninja", "workbench", "edit",
        "open", "fill", "drain", "close"
    }
}

-- == [ МОБІЛЬНІ КОНТРОЛЕРИ ] ==
local Controls = nil
task.spawn(function()
    if not game:IsLoaded() then game.Loaded:Wait() end
    pcall(function()
        local PlayerModule = require(lp.PlayerScripts:WaitForChild("PlayerModule", 5))
        Controls = PlayerModule:GetControls()
    end)
end)

-- == [ СИСТЕМИ (FPS, HEAL, ARMOR) ] ==
local function ApplyFPS()
    settings().Rendering.QualityLevel = 1
    Light.GlobalShadows = false
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Part") or v:IsA("MeshPart") then v.Material = Enum.Material.SmoothPlastic end
        if v:IsA("Decal") or v:IsA("Texture") then v:Destroy() end
    end
end

task.spawn(function()
    while task.wait(0.5) do
        if not lp.Character or not lp.Character:FindFirstChild("Humanoid") then continue end
        if Config.Heal and lp.Character.Humanoid.Health < 75 then
            local med = lp.Backpack:FindFirstChild("Medkit") or lp.Character:FindFirstChild("Medkit")
            if med then med:Activate() end
        end
        if Config.Armor then
            local arm = lp.Backpack:FindFirstChild("Armor") or lp.Character:FindFirstChild("Armor")
            if arm then arm:Activate() end
        end
    end
end)

-- == [ АВТО-ГРАБІЖ ] ==
local function StartRobbery()
    if not lp.Character then return end
    StarterGui:SetCore("SendNotification", {Title = "BANK ROB"; Text = "Executing..."; Duration = 2})
    lp.Character:PivotTo(CFrame.new(COORDS["BANK_MONEY"]))
    task.wait(0.6)
    for i = 1, 20 do
        if not lp.Character then break end
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("ProximityPrompt") and v.Enabled then
                if (lp.Character.HumanoidRootPart.Position - v.Parent:GetPivot().Position).Magnitude < 15 then
                    fireproximityprompt(v)
                end
            end
        end
        task.wait(0.4)
    end
    lp.Character:PivotTo(CFrame.new(COORDS["SAFE_ZONE"] + Vector3.new(0, 3, 0)))
end

-- == [ AIM ТА MAGNET LOCK ] ==
local function getClosest()
    local target, dist = nil, 800
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= lp and v.Character and v.Character:FindFirstChild("Head") then
            local hum = v.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local pos, vis = Camera:WorldToViewportPoint(v.Character.Head.Position)
                local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                if mag < dist then dist = mag target = v end
            end
        end
    end
    return target
end

RS.RenderStepped:Connect(function()
    if Config.AimActive then
        if not Config.LockedTarget or not Config.LockedTarget.Parent or not Config.LockedTarget.Character or Config.LockedTarget.Character.Humanoid.Health <= 0 then
            Config.LockedTarget = getClosest()
        end
        if Config.LockedTarget and Config.LockedTarget.Character:FindFirstChild("Head") then
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, Config.LockedTarget.Character.Head.Position)
        end
    else
        Config.LockedTarget = nil
    end
end)

-- == [ ESP СИСТЕМА (DISTANCE & HP) ] ==
local function ClearESP(char)
    if char then
        local head = char:FindFirstChild("Head")
        if head and head:FindFirstChild("MarkiyanESP") then
            head.MarkiyanESP:Destroy()
        end
        if char:FindFirstChild("MarkiyanHighlight") then
            char.MarkiyanHighlight:Destroy()
        end
    end
end

RS.RenderStepped:Connect(function()
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= lp and v.Character then
            local char = v.Character
            local hum = char:FindFirstChild("Humanoid")
            local head = char:FindFirstChild("Head")
            
            if Config.ESP and hum and head and hum.Health > 0 then
                local espGui = head:FindFirstChild("MarkiyanESP")
                if not espGui then
                    espGui = Instance.new("BillboardGui")
                    espGui.Name = "MarkiyanESP"
                    espGui.Size = UDim2.new(0, 200, 0, 50)
                    espGui.StudsOffset = Vector3.new(0, 3, 0)
                    espGui.AlwaysOnTop = true
                    
                    local textLabel = Instance.new("TextLabel")
                    textLabel.Parent = espGui
                    textLabel.Size = UDim2.new(1, 0, 1, 0)
                    textLabel.BackgroundTransparency = 1
                    textLabel.TextStrokeTransparency = 0.2
                    textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
                    textLabel.Font = Enum.Font.SourceSansBold
                    textLabel.TextSize = 14
                    
                    espGui.Parent = head
                    
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "MarkiyanHighlight"
                    highlight.FillColor = Color3.new(1, 0, 0)
                    highlight.OutlineColor = Color3.new(1, 1, 1)
                    highlight.FillTransparency = 0.6
                    highlight.OutlineTransparency = 0
                    highlight.Parent = char
                end
                
                local textLabel = espGui:FindFirstChildWhichIsA("TextLabel")
                if textLabel then
                    local root = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
                    local dist = root and math.floor((root.Position - head.Position).Magnitude) or 0
                    local hp = math.floor(hum.Health)
                    local maxHp = math.floor(hum.MaxHealth)
                    
                    textLabel.Text = string.format("%s\nHP: %d/%d | Dist: %dm", v.Name, hp, maxHp, dist)
                    
                    if hp / maxHp >= 0.6 then
                        textLabel.TextColor3 = Color3.new(0, 1, 0)
                    elseif hp / maxHp >= 0.3 then
                        textLabel.TextColor3 = Color3.new(1, 1, 0)
                    else
                        textLabel.TextColor3 = Color3.new(1, 0, 0)
                    end
                end
            else
                ClearESP(char)
            end
        end
    end
end)

-- == [ AUTO FARM ] ==
task.spawn(function()
    while task.wait(0.5) do
        if Config.Farm and lp.Character then
            pcall(function()
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("ProximityPrompt") and v.Enabled then
                        local text = (v.Parent.Name .. v.ActionText .. v.ObjectText):lower()
                        local ok = false
                        for _, l in pairs(Config.Loot) do if text:find(l) then ok = true break end end
                        for _, b in pairs(Config.Blacklist) do if text:find(b) then ok = false break end end
                        
                        if ok then
                            lp.Character:PivotTo(v.Parent:GetPivot() * CFrame.new(0, 3, 0))
                            task.wait(0.25)
                            fireproximityprompt(v)
                            task.wait(0.2)
                        end
                    end
                end
            end)
        end
    end
end)

-- == [ NOCLIP ФІЗИКА ] ==
local function RestoreCollision()
    if lp.Character then
        for _, v in pairs(lp.Character:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = true
            end
        end
    end
end

RS.Stepped:Connect(function()
    if Config.Noclip and lp.Character then
        for _, v in pairs(lp.Character:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end
end)

-- == [ HEARTBEAT: FLY, SPEED, MAGNET, AUTOSAFE ] ==
RS.Heartbeat:Connect(function()
    if lp.Character and lp.Character:FindFirstChild("Humanoid") and lp.Character:FindFirstChild("HumanoidRootPart") then
        local hum = lp.Character.Humanoid
        local root = lp.Character.HumanoidRootPart
        
        if Config.AntiSeat then hum.Sit = false end
        
        if Config.Speed and not Config.Fly then 
            hum.WalkSpeed = Config.WalkSpeedValue 
        else 
            if not Config.Fly then hum.WalkSpeed = 16 end 
        end
        
        if Config.Fly then
            hum.PlatformStand = true
            local camLook = Camera.CFrame.LookVector
            local camRight = Camera.CFrame.RightVector
            
            local moveX, moveZ = 0, 0
            if Controls then
                local mv = Controls:GetMoveVector()
                moveX, moveZ = mv.X, mv.Z
            end
            
            if not UIS.TouchEnabled then
                if UIS:IsKeyDown(Enum.KeyCode.W) then moveZ = -1 end
                if UIS:IsKeyDown(Enum.KeyCode.S) then moveZ = 1 end
                if UIS:IsKeyDown(Enum.KeyCode.A) then moveX = -1 end
                if UIS:IsKeyDown(Enum.KeyCode.D) then moveX = 1 end
            end
            
            local dir = (camLook * -moveZ) + (camRight * moveX)
            if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
            if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0, 1, 0) end
            
            root.AssemblyLinearVelocity = dir * Config.FlySpeedValue
            root.AssemblyAngularVelocity = Vector3.zero
        else
            hum.PlatformStand = false
        end

        if Config.Magnet then
            local IsAlive = Config.MagnetTarget and Config.MagnetTarget.Parent and Config.MagnetTarget.Character and Config.MagnetTarget.Character:FindFirstChild("Humanoid") and Config.MagnetTarget.Character.Humanoid.Health > 0
            if not IsAlive then
                Config.MagnetTarget = getClosest()
            end
            
            if Config.MagnetTarget and Config.MagnetTarget.Character and Config.MagnetTarget.Character:FindFirstChild("HumanoidRootPart") then
                local tHRP = Config.MagnetTarget.Character.HumanoidRootPart
                root.CFrame = tHRP.CFrame * CFrame.new(0, 0, 3) 
                root.AssemblyLinearVelocity = tHRP.AssemblyLinearVelocity
            end
        else
            Config.MagnetTarget = nil
        end

        if Config.AutoSafe then
            if hum.Health > 0 and hum.Health <= Config.SafeHealth then
                local distToSafe = (root.Position - COORDS["SAFE_ZONE"]).Magnitude
                if distToSafe > 20 then
                    lp.Character:PivotTo(CFrame.new(COORDS["SAFE_ZONE"] + Vector3.new(0, 3, 0)))
                end
            end
        end
    end
end)

-- == [ INFINITE JUMP (МОБІЛЬНА ТА ПК ПІДТРИМКА) ] ==
UIS.JumpRequest:Connect(function()
    if Config.InfJump and lp.Character and lp.Character:FindFirstChild("Humanoid") then
        lp.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- == [ GUI ТА ФІКСОВАНА СИСТЕМА ПЕРЕТЯГУВАННЯ ] ==
local SG = Instance.new("ScreenGui", lp.PlayerGui); SG.Name = "MarkiyanPro"; SG.ResetOnSpawn = false
local IsMobile = UIS.TouchEnabled

local MainWidth = IsMobile and 220 or 350
local MainHeight = IsMobile and 350 or 500

local Main = Instance.new("Frame", SG); 
Main.Size = UDim2.new(0, MainWidth, 0, MainHeight)
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.Position = UDim2.new(0.5, 0, 0.5, 0)
Main.BackgroundColor3 = Color3.fromRGB(12, 12, 12); Main.Visible = false
Instance.new("UICorner", Main)

local Header = Instance.new("TextLabel", Main); Header.Size = UDim2.new(1, 0, 0, 30); Header.Text = "Markiyan PRO V42 Hybrid"; Header.BackgroundColor3 = Color3.fromRGB(20, 20, 20); Header.TextColor3 = Color3.new(1, 0.8, 0); Header.Font = Enum.Font.SourceSansBold; Instance.new("UICorner", Header)

-- ГЛОБАЛЬНА ФУНКЦІЯ ПЕРЕТЯГУВАННЯ (ЗАХИСТ ВІД SHIFT LOCK)
local function MakeDraggable(guiObject, dragTarget)
    local dragging = false
    local dragStart = nil
    local startPos = nil

    guiObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = dragTarget.Position
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            dragTarget.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

MakeDraggable(Header, Main)

local Scroll = Instance.new("ScrollingFrame", Main); Scroll.Size = UDim2.new(1, -10, 1, -40); Scroll.Position = UDim2.new(0, 5, 0, 35); Scroll.BackgroundTransparency = 1; Scroll.ScrollBarThickness = IsMobile and 0 or 4; 
local Layout = Instance.new("UIListLayout", Scroll)
Layout.Padding = UDim.new(0, 6)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Scroll.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 20)
end)
task.spawn(function() task.wait(0.2); Scroll.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 20) end)

local Buttons = {}

local function AddT(name, key, func)
    local b = Instance.new("TextButton", Scroll); b.Size = UDim2.new(0.95, 0, 0, 30); b.BackgroundColor3 = Color3.fromRGB(30, 30, 30); b.TextColor3 = Color3.new(1, 1, 1); b.Font = Enum.Font.SourceSansBold; Instance.new("UICorner", b)
    b.Text = name .. ": OFF"
    Buttons[key] = b
    
    b.MouseButton1Click:Connect(function() 
        Config[key] = not Config[key]
        b.Text = name .. (Config[key] and ": ON" or ": OFF")
        b.BackgroundColor3 = Config[key] and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(30, 30, 30) 
        if key == "AimActive" and not Config[key] then Config.LockedTarget = nil end
        if key == "Noclip" and not Config[key] then RestoreCollision() end
        if key == "Magnet" and not Config[key] then Config.MagnetTarget = nil end
        if key == "ESP" and not Config[key] then
            for _, v in pairs(Players:GetPlayers()) do
                if v ~= lp then ClearESP(v.Character) end
            end
        end
        if func and Config[key] then func() end 
    end)
end

-- СИСТЕМА ПОВЗУНКІВ (ЗАХИСТ ВІД SHIFT LOCK)
local function CreateSlider(Text, Min, Max, Default, ConfigKey) 
    local Container = Instance.new("Frame", Scroll); Container.Size = UDim2.new(0.95, 0, 0, 50); Container.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Instance.new("UICorner", Container)

    local Label = Instance.new("TextLabel", Container); Label.Size = UDim2.new(1, 0, 0, 20); Label.Text = Text .. ": " .. Default; 
    Label.TextColor3 = Color3.new(1,1,1); Label.BackgroundTransparency = 1; Label.Font = Enum.Font.SourceSansBold; Label.TextSize = 14 

    local SliderBG = Instance.new("Frame", Container); SliderBG.Size = UDim2.new(0.9, 0, 0, 10); SliderBG.Position = UDim2.new(0.05, 0, 0, 28); 
    SliderBG.BackgroundColor3 = Color3.fromRGB(50, 50, 55); Instance.new("UICorner", SliderBG) 

    local Fill = Instance.new("Frame", SliderBG); Fill.Size = UDim2.new((Default - Min) / (Max - Min), 0, 1, 0); Fill.BackgroundColor3 = Color3.fromRGB(0, 120, 255); Instance.new("UICorner", Fill) 
    
    local dragging = false 
    
    local function Update(input) 
        local pos = math.clamp((input.Position.X - SliderBG.AbsolutePosition.X) / SliderBG.AbsoluteSize.X, 0, 1) 
        Fill.Size = UDim2.new(pos, 0, 1, 0); 
        local value = math.floor(Min + (pos * (Max - Min)))
        Label.Text = Text .. ": " .. value
        Config[ConfigKey] = value
    end 
    
    SliderBG.InputBegan:Connect(function(input) 
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
            dragging = true
            Update(input) 
        end 
    end) 
    
    UIS.InputChanged:Connect(function(input) 
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then 
            Update(input) 
        end 
    end) 
    
    UIS.InputEnded:Connect(function(input) 
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
            dragging = false 
        end 
    end) 
end 

local RobBtn = Instance.new("TextButton", Scroll); RobBtn.Size = UDim2.new(0.95, 0, 0, 35); RobBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0); RobBtn.TextColor3 = Color3.new(1, 1, 1); RobBtn.Font = Enum.Font.SourceSansBold; Instance.new("UICorner", RobBtn); RobBtn.Text = "AUTO ROB BANK"
RobBtn.MouseButton1Click:Connect(function() task.spawn(StartRobbery) end)

AddT("AIM LOCK (G)", "AimActive")
AddT("PLAYER ESP", "ESP")
AddT("MAGNET", "Magnet")
AddT("AUTO SAFE (LOW HP)", "AutoSafe")
AddT("AUTO FARM", "Farm")
AddT("FLY (F)", "Fly")
CreateSlider("FLY SPEED", 10, 250, Config.FlySpeedValue, "FlySpeedValue")
AddT("NOCLIP (V)", "Noclip")
AddT("SPEED HACK", "Speed")
CreateSlider("WALK SPEED", 16, 150, Config.WalkSpeedValue, "WalkSpeedValue")
AddT("AUTO HEAL", "Heal")
AddT("AUTO ARMOR", "Armor")
AddT("ANTI-SEAT", "AntiSeat")
AddT("FPS BOOST", "FPSBoost", ApplyFPS)
AddT("INF JUMP", "InfJump")

local function AddTP(name, vec)
    local b = Instance.new("TextButton", Scroll); b.Size = UDim2.new(0.95, 0, 0, 30); b.BackgroundColor3 = Color3.fromRGB(45, 45, 45); b.TextColor3 = Color3.fromRGB(255, 215, 0); b.Font = Enum.Font.SourceSansBold; Instance.new("UICorner", b); b.Text = "TP: " .. name
    b.MouseButton1Click:Connect(function() lp.Character:PivotTo(CFrame.new(vec + Vector3.new(0, 3, 0))) end)
end
AddTP("GUN SHOP", COORDS["GUN_SHOP"]); AddTP("BANK", COORDS["BANK_ENT"]); AddTP("SAFE ZONE", COORDS["SAFE_ZONE"])

-- КЛАВІШІ БІНДІВ (G, F, V, Space)
UIS.InputBegan:Connect(function(i, c)
    if not c then
        if i.KeyCode == Enum.KeyCode.G then 
            Config.AimActive = not Config.AimActive
            Buttons["AimActive"].Text = "AIM LOCK (G)" .. (Config.AimActive and ": ON" or ": OFF")
            Buttons["AimActive"].BackgroundColor3 = Config.AimActive and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(30, 30, 30)
            if not Config.AimActive then Config.LockedTarget = nil end
        elseif i.KeyCode == Enum.KeyCode.F then 
            Config.Fly = not Config.Fly
            Buttons["Fly"].Text = "FLY (F)" .. (Config.Fly and ": ON" or ": OFF")
            Buttons["Fly"].BackgroundColor3 = Config.Fly and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(30, 30, 30)
        elseif i.KeyCode == Enum.KeyCode.V then 
            Config.Noclip = not Config.Noclip
            Buttons["Noclip"].Text = "NOCLIP (V)" .. (Config.Noclip and ": ON" or ": OFF")
            Buttons["Noclip"].BackgroundColor3 = Config.Noclip and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(30, 30, 30)
            if not Config.Noclip then RestoreCollision() end
        end
    end
end)

-- == [ DRAGGABLE M BUTTON ТА ОБРОБКА КЛІКІВ ] ==
local MButtonSize = IsMobile and 45 or 40
local M = Instance.new("TextButton", SG); 
M.Size = UDim2.new(0, MButtonSize, 0, MButtonSize); 
M.Position = UDim2.new(0, 10, 0.3, 0); 
M.Text = "M"; 
M.Font = Enum.Font.SourceSansBold;
M.TextSize = IsMobile and 24 or 20;
M.BackgroundColor3 = Color3.fromRGB(20, 20, 20); 
M.TextColor3 = Color3.new(1, 1, 1); 
Instance.new("UICorner", M)

local draggingM = false
local dragStartM = nil
local startPosM = nil
local clickStartTick = 0

M.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingM = true
        dragStartM = input.Position
        startPosM = M.Position
        clickStartTick = tick()
    end
end)

UIS.InputChanged:Connect(function(input)
    if draggingM and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStartM
        M.Position = UDim2.new(startPosM.X.Scale, startPosM.X.Offset + delta.X, startPosM.Y.Scale, startPosM.Y.Offset + delta.Y)
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if draggingM then
            draggingM = false
            local delta = (input.Position - dragStartM).Magnitude
            if tick() - clickStartTick < 0.3 and delta < 10 then
                Main.Visible = not Main.Visible 
            end
        end
    end
end)
