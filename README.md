-- markiyanbest's script (V42 - THE STABLE BASE)
local lp = game:GetService("Players").LocalPlayer
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
    Fly = false, FlySpeed = 2.5, SpeedMult = 1.2,
    ESP = false, NoSpread = false, InfJump = false,
    -- == [ ПОВНИЙ БІЛИЙ СПИСОК ] ==
    Loot = {
        "void", "gem", "shard", "suitcase nuke", "nuke", "nextbot", "ninja star", "stop sign", "printer", "money printer", "steal", "materials", "candy",
        "gold ak", "gold deagle", "gold glock", "gold knife", "flamethrower", "barrett", "m107", "rpg", "launcher", "c4", "molotov", "scrap", "cane", "scar L",
        "m4", "ak", "sniper", "weapon parts", "explosives", "helimail", "helicopter", "skateboard", "mobile dealer", "lockpick", "santa", "blue",
        "key", "card", "cash", "money", "wallet", "electronics", "atm", "safe", "diamond", "gold bar", "limited", "box", "crate", "mustang", "mattery",
        "medkit", "heavy armor", "medium armor", "light armor", "vest", "phone", "bandage", "balloon", "cookies", "air", "drop", "diamond",  "dark", "lucky",
    },
    -- == [ РОЗШИРЕНИЙ ЧОРНИЙ СПИСОК ] ==
    Blacklist = {
        "trash", "newspaper", "bottle", "bandage", "leaf", "stick", "shoe", "apple", "soda", "burger", "hotdog", "mask", "stop", "ore", "ladder", "fireworks", "press", "taser", "paintball",
        "requires", "door", "gate", "barrier", "cell", "unlock after", "cash earned", "garage", "ammo", "pickaxe", "sign", "equip", "put", "on", "food", "gloves", "spray", "ignite",
        "brew", "coffee", "latte", "espresso", "drink", "vending machine", "cola", "bloxy", "bat", "katana", "flashbang", "skateboard", "bike", "off", "turn", "molotov", "ninja",
    }
}

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

-- == [ AIM LOCK ] ==
local function getClosest()
    local target, dist = nil, 800
    for _, v in pairs(game:GetService("Players"):GetPlayers()) do
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

-- == [ ФІЗИКА ] ==
RS.Heartbeat:Connect(function()
    if lp.Character and lp.Character:FindFirstChild("Humanoid") then
        local hum = lp.Character.Humanoid
        local root = lp.Character.HumanoidRootPart
        if Config.AntiSeat then hum.Sit = false end
        if Config.Speed and not Config.Fly then hum.WalkSpeed = 65 else if not Config.Fly then hum.WalkSpeed = 16 end end
        if Config.Fly and root then
            local d = Vector3.new(0,0,0)
            if UIS:IsKeyDown(Enum.KeyCode.W) then d = d + Camera.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then d = d - Camera.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then d = d - Camera.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then d = d + Camera.CFrame.RightVector end
            root.Velocity = Vector3.new(0, 0.1, 0)
            if d.Magnitude > 0 then root.CFrame = root.CFrame + (d.Unit * Config.FlySpeed) end
        end
    end
end)

-- == [ GUI ] ==
local SG = Instance.new("ScreenGui", lp.PlayerGui); SG.Name = "MarkiyanPro"; SG.ResetOnSpawn = false
local Main = Instance.new("Frame", SG); Main.Size = UDim2.new(0, 165, 0, 320); Main.Position = UDim2.new(0, 10, 0.4, 0); Main.BackgroundColor3 = Color3.fromRGB(12, 12, 12); Instance.new("UICorner", Main)
local Header = Instance.new("TextLabel", Main); Header.Size = UDim2.new(1, 0, 0, 30); Header.Text = "Markiyan PRO V42"; Header.BackgroundColor3 = Color3.fromRGB(20, 20, 20); Header.TextColor3 = Color3.new(1, 0.8, 0); Header.Font = Enum.Font.SourceSansBold; Instance.new("UICorner", Header)
local Scroll = Instance.new("ScrollingFrame", Main); Scroll.Size = UDim2.new(1, -10, 1, -40); Scroll.Position = UDim2.new(0, 5, 0, 35); Scroll.BackgroundTransparency = 1; Scroll.CanvasSize = UDim2.new(0, 0, 0, 950); Scroll.ScrollBarThickness = 2; Instance.new("UIListLayout", Scroll).Padding = UDim.new(0, 5)

local function AddT(name, key, func)
    local b = Instance.new("TextButton", Scroll); b.Size = UDim2.new(1, -10, 0, 30); b.BackgroundColor3 = Color3.fromRGB(30, 30, 30); b.TextColor3 = Color3.new(1, 1, 1); b.Font = Enum.Font.SourceSansBold; Instance.new("UICorner", b)
    RS.Heartbeat:Connect(function() 
        b.Text = name .. (Config[key] and ": ON" or ": OFF")
        b.BackgroundColor3 = Config[key] and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(30, 30, 30) 
    end)
    b.MouseButton1Click:Connect(function() 
        Config[key] = not Config[key]
        if key == "AimActive" and not Config[key] then Config.LockedTarget = nil end
        if func and Config[key] then func() end 
    end)
end

local RobBtn = Instance.new("TextButton", Scroll); RobBtn.Size = UDim2.new(1, -10, 0, 35); RobBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0); RobBtn.TextColor3 = Color3.new(1, 1, 1); RobBtn.Font = Enum.Font.SourceSansBold; Instance.new("UICorner", RobBtn); RobBtn.Text = "AUTO ROB BANK"
RobBtn.MouseButton1Click:Connect(function() task.spawn(StartRobbery) end)

AddT("AIM LOCK (G)", "AimActive")
AddT("AUTO FARM", "Farm")
AddT("FLY (F)", "Fly")
AddT("SPEED HACK", "Speed")
AddT("AUTO HEAL", "Heal")
AddT("AUTO ARMOR", "Armor")
AddT("ANTI-SEAT", "AntiSeat")
AddT("FPS BOOST", "FPSBoost", ApplyFPS)
AddT("INF JUMP", "InfJump")

local function AddTP(name, vec)
    local b = Instance.new("TextButton", Scroll); b.Size = UDim2.new(1, -10, 0, 30); b.BackgroundColor3 = Color3.fromRGB(45, 45, 45); b.TextColor3 = Color3.fromRGB(255, 215, 0); b.Font = Enum.Font.SourceSansBold; Instance.new("UICorner", b); b.Text = "TP: " .. name
    b.MouseButton1Click:Connect(function() lp.Character:PivotTo(CFrame.new(vec + Vector3.new(0, 3, 0))) end)
end
AddTP("GUN SHOP", COORDS["GUN_SHOP"]); AddTP("BANK", COORDS["BANK_ENT"]); AddTP("SAFE ZONE", COORDS["SAFE_ZONE"])

UIS.InputBegan:Connect(function(i, c)
    if not c then
        if i.KeyCode == Enum.KeyCode.G then Config.AimActive = not Config.AimActive
        elseif i.KeyCode == Enum.KeyCode.F then Config.Fly = not Config.Fly
        elseif i.KeyCode == Enum.KeyCode.Space and Config.InfJump then lp.Character.Humanoid:ChangeState("Jumping") end
    end
end)

local M = Instance.new("TextButton", SG); M.Size = UDim2.new(0, 35, 0, 35); M.Position = UDim2.new(0, 10, 0.1, 0); M.Text = "M"; M.BackgroundColor3 = Color3.fromRGB(20, 20, 20); M.TextColor3 = Color3.new(1, 1, 1); Instance.new("UICorner", M)
M.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)
