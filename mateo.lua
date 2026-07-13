-- [[ OMNI GHOST v8.3 - DEBUG & AUTO-FIX ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Створюємо Debug UI
local dbgGui = Instance.new("ScreenGui", LP:WaitForChild("PlayerGui"))
dbgGui.Name = "OmniDebug"
local dbgFrame = Instance.new("Frame", dbgGui)
dbgFrame.Size = UDim2.new(0, 200, 0, 150)
dbgFrame.Position = UDim2.new(0.5, 100, 0, 50)
dbgFrame.BackgroundColor3 = Color3.new(0,0,0)
dbgFrame.BackgroundTransparency = 0.5

local dbgList = Instance.new("UIListLayout", dbgFrame)
local function Log(text, color)
    local l = Instance.new("TextLabel", dbgFrame)
    l.Size = UDim2.new(1, 0, 0, 20)
    l.Text = text
    l.TextColor3 = color or Color3.new(1,1,1)
    l.BackgroundTransparency = 1
    l.TextSize = 12
end

-- Перевірки
local hasDrawing = pcall(function() return Drawing.new("Circle") end)
local hasMouseRel = (type(mousemoverel) == "function")
local playersFound = #Players:GetPlayers() > 1

Log("Drawing API: "..(hasDrawing and "YES" or "NO"), hasDrawing and Color3.new(0,1,0) or Color3.new(1,0,0))
Log("mousemoverel: "..(hasMouseRel and "YES" or "NO"), hasMouseRel and Color3.new(0,1,0) or Color3.new(1,0,0))
Log("Players Found: "..(playersFound and "YES" or "NO"), playersFound and Color3.new(0,1,0) or Color3.new(1,0,0))
Log("Viewport: "..tostring(Camera.ViewportSize))

-- Спроба створити FOV коло через UI (якщо Drawing не працює)
local fovUI = Instance.new("Frame", dbgGui)
fovUI.Name = "FOV_UI"
fovUI.Size = UDim2.new(0, 200, 0, 200)
fovUI.AnchorPoint = Vector2.new(0.5, 0.5)
fovUI.Position = UDim2.new(0.5, 0, 0.5, 0)
fovUI.BackgroundTransparency = 1
fovUI.Visible = true

local uiStroke = Instance.new("UIStroke", fovUI)
uiStroke.Thickness = 2
uiStroke.Color = Color3.new(1,0,0)
Instance.new("UICorner", fovUI).CornerRadius = UDim.new(1, 0)

Log("FOV UI Created", Color3.new(0,1,0))

-- Тест пошуку цілі
local testTarget = nil
RunService.RenderStepped:Connect(function()
    fovUI.Position = UDim2.new(0, Camera.ViewportSize.X/2, 0, Camera.ViewportSize.Y/2)
    
    local closestDist = 1000
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("Head") then
            local head = p.Character.Head
            local sp, onScreen = Camera:WorldToViewportPoint(head.Position)
            if onScreen then
                local dist = (Vector2.new(sp.X, sp.Y) - (Camera.ViewportSize/2)).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    testTarget = p.Name
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        Log("Target: "..(testTarget or "NONE"), testTarget and Color3.new(0,1,0) or Color3.new(1,1,0))
    end
end)
