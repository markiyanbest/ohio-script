-- markiyanbest's script (V51.5 - PICKER FIX + MANAGE HOUSE)
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
        Light.GlobalShadows = false; Light.FogEnd = 9e9
        Light.Brightness = 1; Light.ClockTime = 14
    end)
    for _, v in pairs(Light:GetChildren()) do
        if v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("SunRaysEffect")
            or v:IsA("DepthOfFieldEffect") or v:IsA("ColorCorrectionEffect") then
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
        prompt:InputHoldBegin(); task.wait(0.05); prompt:InputHoldEnd()
    end)
    return ok2
end

local COORDS = {
    GUN_SHOP = Vector3.new(1131, 25, -1344),
    BANK_ENT = Vector3.new(1106, 8, -336),
    BANK_MONEY = Vector3.new(1110, 8, -325),
    SAFE_ZONE = Vector3.new(-37, -27, 3),
}

local ALL_ITEMS = {
    "Acid Gun","Admin AK-47","Admin Nuke","Admin RPG","AK-47","AR-15",
    "AS VAL","AUG","Barrett M107","Baseball Bat","Baton","Brass Knuckles",
    "C4","Clown Mallet","Crowbar","Deagle","Double barrel","Dragunov",
    "Fire Extinguisher","Fireaxe","Fists","Flamethrower","Flashbang",
    "Frag grenade","Glock","Glock 18","Gold AK-47","Gold Deagle",
    "Gravity Gun","Heavy C4","Katana","Knife","Landmines","M1 Garand",
    "M1911","M249 SAW","M4A1","Meat Grinder","Molotov","Money Gun",
    "Mossberg","MP7","Pepper Spray","Python","Raygun","Riot Shield",
    "RPG","RPK","Saber","Saiga 12","Sawn off","Smoke grenade",
    "Spectral Scythe","Spiked baseball bat","Suitcase Nuke","USP 45","Uzi",
    "Bandage","Heavy Vest","Light vest","Medium Vest","Medkit",
    "Military Vest","Stretcher","Surgeon Mask","X-Ray Goggles",
    "ATM","Cash Register","Gems","Money printer","Unusual Money Printer",
    "Safes","Slot machine","Wallet",
    "Apple","Banana","Banana Peel","Beans","Bloxaide","Bloxy Cola",
    "Burger","Cake","Candy Cane","Chicken","Choco Bunny","Chocolates",
    "Coffee","Cookie","Cotton Candy","Diamond Taco","Donut","Hotdog",
    "Pizza","Rose",
    "Airdrop Marker","Airstrike","Armored Truck","Component Boxes",
    "Crafting table","Drone","Easter Basket","Gold Lucky Block",
    "Green Lucky Block","Large Present","Locker","Lockpick",
    "Orange Lucky Block","Presents","Purple Lucky Block","Red Lucky Block",
    "Small Present",
    "Dumbell","Festive Guitar","Flashlight","Grocery Cart","Guitar",
    "Hoverboard","Maraca","Megaphone","Shopping Cart","Sign",
    "Skateboard","Stagecoach","Stop Sign",
    "4th of July Hat","Balloon","Basketball","Beach Ball","Bear Trap",
    "Clover Balloon","Clown","Firework","Firework Cake","Firework Cone",
    "Firework Mortar","Green Firework","Heart Balloon","Hockey Mask",
    "July 4th Firework","Pink Firework","Roman Candle","Sombrero Hat",
    "Sparkler",
    "Black Bandana","Blue Bandana","Blue Gloves","Red Bandana","Red Gloves",
    "Blue Candy Cane","Cruiser Keys","Dollar Balloon",
    "Golden Clover Balloon","Helicopter Keys","Kunai",
    "Military Keycard","Mustang Keys","Night Vision Goggles",
    "Nuke Launcher","Police Keycard","SPAS-12",
}

local ALL_ITEMS_LOOKUP = {}
for _, item in pairs(ALL_ITEMS) do
    ALL_ITEMS_LOOKUP[item:lower()] = item
end

local SAVE_KEY = "MarkiyanProV51_Settings"

local function SaveSettings(config, itemPicker)
    pcall(function()
        local data = {config = {}, itemPicker = {}}
        for k, v in pairs(config) do
            if type(v) == "boolean" or type(v) == "number" or type(v) == "string" then
                data.config[k] = v
            end
        end
        for n, s in pairs(itemPicker) do data.itemPicker[n] = s end
        if writefile then writefile(SAVE_KEY .. ".json", HttpService:JSONEncode(data)) end
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

local Config = {
    Farm = false, Speed = false, Armor = false, Heal = false,
    AimActive = false, FPSBoost = false, AntiSeat = false, AntiAFK = false,
    Fly = false, FlySpeedValue = IsMobile and 35 or 50,
    WalkSpeedValue = IsMobile and 45 or 65,
    ESP = false, ItemESP = false, Fullbright = false, AutoEquip = false,
    InfJump = false, Noclip = false, Magnet = false, MagnetTarget = nil,
    AutoSafe = false, SafeHealth = 35,
    SilentAim = false, AimFOV = 200, AimSmooth = 0.18, AimPart = "Head",
    KillAura = false, KillAuraRange = 15,
    HighJump = false, JumpPowerValue = 50,
}

local ItemPickerState = {}
for _, item in pairs(ALL_ITEMS) do ItemPickerState[item] = true end

local Binds = {
    Fly = Enum.KeyCode.F, AimActive = Enum.KeyCode.G,
    Noclip = Enum.KeyCode.V, SilentAim = Enum.KeyCode.B,
    ToggleUI = Enum.KeyCode.M,
}
local BindNames = {Fly="FLY",AimActive="AIM",Noclip="NOCLIP",SilentAim="SILENT",ToggleUI="UI"}
local waitingForBind = nil

local savedData = LoadSettings()
if savedData then
    if savedData.config then
        for k, v in pairs(savedData.config) do
            if Config[k] ~= nil and type(Config[k]) == type(v) then Config[k] = v end
        end
    end
    if savedData.itemPicker then
        for n, s in pairs(savedData.itemPicker) do
            if ItemPickerState[n] ~= nil then ItemPickerState[n] = s end
        end
    end
end

task.spawn(function() while task.wait(15) do SaveSettings(Config, ItemPickerState) end end)

-- ============================================================
-- BLACKLIST V51.5
-- ============================================================
local HARDBLOCK_NAMES = {
    ["door"]=true,["doors"]=true,["gate"]=true,["gates"]=true,
    ["vault"]=true,["vault door"]=true,["barrier"]=true,["hatch"]=true,
    ["entrance"]=true,["secure door"]=true,["locked door"]=true,
    ["metal door"]=true,["iron door"]=true,["steel door"]=true,
    ["wooden door"]=true,["front door"]=true,["back door"]=true,
    ["cell door"]=true,["prison door"]=true,["jail door"]=true,
    ["garage door"]=true,["security door"]=true,["access door"]=true,
    ["panel"]=true,["access panel"]=true,
    -- V51.5 додано:
    ["manage house"]=true,["house"]=true,["manage"]=true,
    ["property"]=true,["apartment"]=true,["condo"]=true,
}

local DOOR_ACTION_BLOCKS = {
    "requires lockpick","requires keycard","requires key card",
    "requires key","requires level","requires police","requires military","rent"
    "need lockpick","need keycard","need key card","need key",
    "use lockpick","use keycard","use key card",
    "insert keycard","insert key card","insert key","insert card",
    "swipe card","swipe keycard","swipe key card",
    "unlock with","open with","locked",
    "unlock door","open door","close door","lock door",
    -- V51.5 додано:
    "manage house","manage property","open house","close house",
    "open gate","close gate","open entrance",
    "open","close",
}

local DOOR_ANCESTOR_KW = {"door","gate","vault","hatch","barrier","lock","fence","house","manage"}

local BLACKLIST_EXACT = {
    ["door"]=true,["doors"]=true,["gate"]=true,["gates"]=true,
    ["fence"]=true,["fences"]=true,["barrier"]=true,["barriers"]=true,
    ["wall"]=true,["locked"]=true,["hinge"]=true,
    ["spawn"]=true,["edit"]=true,["open"]=true,["close"]=true,
    ["press"]=true,["turn"]=true,["interact"]=true,["interaction"]=true,
    ["enter"]=true,["exit"]=true,["sit"]=true,["stand"]=true,
    ["chair"]=true,["bench"]=true,["desk"]=true,
    ["bed"]=true,["couch"]=true,["sofa"]=true,
    ["toilet"]=true,["sink"]=true,["shower"]=true,
    ["ladder"]=true,["stairs"]=true,["elevator"]=true,["lift"]=true,
    ["window"]=true,["curtain"]=true,["lamp"]=true,
    ["switch"]=true,["lever"]=true,["button"]=true,
    ["shelf"]=true,["cabinet"]=true,
    ["mirror"]=true,["picture"]=true,["painting"]=true,
    ["tv"]=true,["television"]=true,["monitor"]=true,
    ["computer"]=true,["laptop"]=true,
    ["phone"]=true,["telephone"]=true,
    ["clock"]=true,["alarm"]=true,
    ["trash"]=true,["garbage"]=true,["bin"]=true,["dumpster"]=true,
    ["mailbox"]=true,["flag"]=true,["pole"]=true,
    ["tree"]=true,["bush"]=true,["plant"]=true,
    ["rock"]=true,["stone"]=true,["hydrant"]=true,
    ["vending"]=true,["vending machine"]=true,["workbench"]=true,
    ["purchase"]=true,["buy"]=true,["sell"]=true,
    ["shop"]=true,["store"]=true,["market"]=true,["mall"]=true,
    ["premium"]=true,["vip"]=true,["robux"]=true,["gamepass"]=true,
    ["ammo"]=true,["ammo box"]=true,["ammobox"]=true,
    ["ammo crate"]=true,["ammocrate"]=true,
    ["ammunition"]=true,["ammunition box"]=true,
    ["magazine"]=true,["bullets"]=true,["rounds"]=true,
    ["unlock"]=true,["unlocks"]=true,
    ["locked until"]=true,["unlock after"]=true,
    ["cash earned"]=true,["need cash"]=true,["need money"]=true,["earned"]=true,
    ["npc"]=true,["guard"]=true,["cop"]=true,
    ["officer"]=true,["soldier"]=true,
    ["civilian"]=true,["citizen"]=true,
    ["shopkeeper"]=true,["vendor"]=true,["boss"]=true,["enemy"]=true,
    ["garage"]=true,["parking"]=true,["gas station"]=true,["fuel"]=true,
    ["drive"]=true,["ride"]=true,["steer"]=true,["wheel"]=true,
    ["seat"]=true,["passenger"]=true,["start engine"]=true,
    ["paintball"]=true,["paintball gun"]=true,
    ["minigame"]=true,["mini game"]=true,
    ["pickaxe"]=true,["pick axe"]=true,["mining"]=true,["ore"]=true,
    ["respawn"]=true,["reset"]=true,["settings"]=true,["options"]=true,
    ["menu"]=true,["gui"]=true,["tutorial"]=true,["help"]=true,
    ["info"]=true,["information"]=true,["rules"]=true,["rule"]=true,
    ["team"]=true,["teams"]=true,["job"]=true,["jobs"]=true,
    ["quest"]=true,["quests"]=true,["mission"]=true,["missions"]=true,
    ["objective"]=true,["radio"]=true,["siren"]=true,["horn"]=true,
    ["trunk"]=true,["hood"]=true,["engine"]=true,["tire"]=true,
    ["repair"]=true,["fix"]=true,["spray"]=true,["paint"]=true,
    ["color"]=true,["colour"]=true,["customize"]=true,["custom"]=true,
    ["upgrade"]=true,["level"]=true,["rank"]=true,
    ["xp"]=true,["exp"]=true,["experience"]=true,
    ["skill"]=true,["perk"]=true,["inventory"]=true,["backpack"]=true,
    ["equip"]=true,["unequip"]=true,["drop"]=true,
    ["destroy"]=true,["delete"]=true,["remove"]=true,
    ["place"]=true,["build"]=true,["blueprint"]=true,["recipe"]=true,
    -- V51.5 додано:
    ["manage"]=true,["manage house"]=true,["house"]=true,
    ["property"]=true,["apartment"]=true,["condo"]=true,
    ["rent"]=true,["lease"]=true,["mortgage"]=true,
}

local BLACKLIST_PATTERNS = {
    "ammo%s*box","ammo%s*crate","ammunition%s*box",
    "unlock%s*after","cash%s*earned","unlocks%s*at","locked%s*until",
    "need%s*%d","need%s*cash","need%s*money",
    "purchase%s*for","buy%s*for","buy%s*to",
    "premium%s*only","vip%s*only","members%s*only","robux",
    "%d+%.?%d*m%s*cash","%d+%.?%d*k%s*cash","%d+%.?%d*m%s*earned",
    "after%s*%d","after%s*earning","earn%s*%d",
    "paintball","pick%s*axe","small%s*extinguisher",
    "open%s*door","close%s*door","open%s*gate","close%s*gate",
    "enter%s*vehicle","exit%s*vehicle","drive%s*car",
    "get%s*in","get%s*out","start%s*engine",
    "lock%s*door","unlock%s*door","sit%s*down","stand%s*up",
    "requires%s+%a","need%s+lockpick","need%s+keycard",
    "need%s+key%s*card","use%s+lockpick","use%s+keycard",
    "insert%s+key","insert%s+card","swipe%s+card",
    "swipe%s+keycard","unlock%s+with","open%s+with",
    -- V51.5:
    "manage%s+house","manage%s+property","open%s+house",
}

local WHITELIST_FORCE = {}
for _, item in pairs(ALL_ITEMS) do WHITELIST_FORCE[item:lower()] = true end

local PriorityLoot = {
    ["money printer"]=true,["unusual money printer"]=true,
    ["keycard"]=true,["police keycard"]=true,["military keycard"]=true,
    ["lockpick"]=true,["gold ak-47"]=true,["gold deagle"]=true,
    ["admin ak-47"]=true,["admin rpg"]=true,["admin nuke"]=true,
    ["suitcase nuke"]=true,["raygun"]=true,["barrett m107"]=true,
    ["spectral scythe"]=true,["diamond taco"]=true,["airdrop marker"]=true,
    ["nuke launcher"]=true,["spas-12"]=true,["kunai"]=true,
    ["mustang keys"]=true,["helicopter keys"]=true,["cruiser keys"]=true,
    ["night vision goggles"]=true,["x-ray goggles"]=true,
}

-- ============================================================
-- UTILITIES
-- ============================================================
local function Notify(t, x, d) pcall(function() StarterGui:SetCore("SendNotification",{Title=t,Text=x,Duration=d or 2}) end) end
local function GetChar() return lp.Character end
local function GetHum() local c=GetChar(); return c and c:FindFirstChildOfClass("Humanoid") end
local function GetRoot() local c=GetChar(); return c and c:FindFirstChild("HumanoidRootPart") end
local function IsHumAlive() local h=GetHum(); return h and h.Health>0 end

local function SafeTeleport(pos)
    if not IsHumAlive() then return false end
    local root=GetRoot(); if not root then return false end
    local char=GetChar()
    local ok=pcall(function() char:PivotTo(CFrame.new(pos+Vector3.new(0,3,0))) end)
    if not ok then pcall(function() root.CFrame=CFrame.new(pos+Vector3.new(0,3,0)) end) end
    return true
end

local function IsTargetAlive(t)
    if not t or not t.Parent then return false end
    local c=t.Character; if not c then return false end
    local h=c:FindFirstChildOfClass("Humanoid"); return h and h.Health>0
end

-- ============================================================
-- [FIX V51.5] ITEM PICKER — строга перевірка
-- Тепер якщо предмет ВИМКНЕНИЙ (✗) — він 100% НЕ підбирається
-- ============================================================
local function IsWhitelisted(text)
    if WHITELIST_FORCE[text] then return true end
    for itemLow, _ in pairs(WHITELIST_FORCE) do
        if #itemLow >= 4 and text:find(itemLow, 1, true) then return true end
    end
    return false
end

local function IsBlocked(text)
    if IsWhitelisted(text) then return false end
    for word in text:gmatch("%S+") do
        if BLACKLIST_EXACT[word] then return true end
    end
    if BLACKLIST_EXACT[text] then return true end
    for kw in pairs(BLACKLIST_EXACT) do
        if #kw >= 3 and text:find(kw, 1, true) then return true end
    end
    for _, pattern in pairs(BLACKLIST_PATTERNS) do
        if text:find(pattern) then return true end
    end
    return false
end

-- [FIX V51.5] Строга перевірка Item Picker
-- Повертає: matchedItem (string або nil), enabled (bool)
local function CheckItemPicker(parentName)
    local pLow = parentName:lower()

    -- 1. Точний збіг
    if ALL_ITEMS_LOOKUP[pLow] then
        local origName = ALL_ITEMS_LOOKUP[pLow]
        return origName, (ItemPickerState[origName] == true)
    end

    -- 2. Частковий збіг — знайти НАЙДОВШИЙ збіг
    local bestMatch = nil
    local bestLen = 0
    for itemLow, itemOriginal in pairs(ALL_ITEMS_LOOKUP) do
        if #itemLow >= 3 then
            if pLow:find(itemLow, 1, true) then
                if #itemLow > bestLen then
                    bestLen = #itemLow
                    bestMatch = itemOriginal
                end
            end
        end
    end

    if bestMatch then
        return bestMatch, (ItemPickerState[bestMatch] == true)
    end

    return nil, true -- невідомий предмет = дозволити
end

local function IsValidLootPrompt(prompt)
    if not prompt or not prompt.Parent then return false end
    if not prompt.Enabled then return false end

    local par = prompt.Parent
    local parentName = par.Name or ""
    local pLow = parentName:lower()
    local actionText = (prompt.ActionText or ""):lower()
    local objectText = (prompt.ObjectText or ""):lower()
    local fullText = pLow .. " " .. actionText .. " " .. objectText

    -- КРОК 0: Хардблок назв
    if HARDBLOCK_NAMES[pLow] then return false end

    -- Батько містить door/gate/vault/house/manage
    if not ALL_ITEMS_LOOKUP[pLow] then
        for _, dk in pairs(DOOR_ANCESTOR_KW) do
            if pLow:find(dk, 1, true) then return false end
        end
    end

    -- КРОК 1: ActionText/ObjectText дверні фрази
    for _, phrase in pairs(DOOR_ACTION_BLOCKS) do
        if actionText:find(phrase, 1, true) then return false end
        if objectText:find(phrase, 1, true) then return false end
        if fullText:find(phrase, 1, true) then
            if ALL_ITEMS_LOOKUP[pLow] then break end
            return false
        end
    end

    -- КРОК 2: Предки
    if not ALL_ITEMS_LOOKUP[pLow] then
        local ancestor = par.Parent
        for i = 1, 4 do
            if not ancestor then break end
            local aName = (ancestor.Name or ""):lower()
            for _, dk in pairs(DOOR_ANCESTOR_KW) do
                if aName:find(dk, 1, true) then return false end
            end
            ancestor = ancestor.Parent
        end
        for _, child in pairs(par:GetChildren()) do
            local cn = (child.Name or ""):lower()
            local cc = (child.ClassName or ""):lower()
            if cn:find("hinge") or cn:find("door") or cc:find("hinge") then return false end
        end
        if par.Parent then
            for _, sibling in pairs(par.Parent:GetChildren()) do
                local sn = (sibling.Name or ""):lower()
                if sn:find("door") or sn:find("gate") or sn:find("hinge") then return false end
            end
        end
    end

    -- [FIX V51.5] КРОК 3: Item Picker — СТРОГА перевірка
    -- Перевіряємо і по імені батька, і по fullText
    local matchedItem, isEnabled = CheckItemPicker(parentName)
    if matchedItem and not isEnabled then
        return false -- предмет ВИМКНЕНИЙ в picker
    end

    -- Також перевірити fullText на збіг з вимкненими предметами
    if not matchedItem then
        for itemLow, itemOriginal in pairs(ALL_ITEMS_LOOKUP) do
            if #itemLow >= 4 and fullText:find(itemLow, 1, true) then
                if ItemPickerState[itemOriginal] == false then
                    return false -- знайшли вимкнений предмет в тексті
                end
                matchedItem = itemOriginal
                isEnabled = true
                break
            end
        end
    end

    -- КРОК 4: Точний збіг ALL_ITEMS
    if ALL_ITEMS_LOOKUP[pLow] then return true end

    -- КРОК 5: Погані дії
    local badActions = {
        "open","close","lock","unlock","enter","exit",
        "drive","ride","sit","get in","get out","start",
        "interact","use","toggle","activate","turn",
        "buy","purchase","sell","upgrade","repair",
        "spawn","respawn","reset","equip","unequip",
        "manage",
    }
    for _, ba in pairs(badActions) do
        if actionText:find(ba, 1, true) then
            if not IsWhitelisted(fullText) then return false end
        end
    end

    -- КРОК 6: Загальний blacklist
    if IsBlocked(fullText) then return false end

    -- КРОК 7: Частковий збіг ALL_ITEMS
    for itemLow, itemOriginal in pairs(ALL_ITEMS_LOOKUP) do
        if #itemLow >= 3 then
            if pLow:find(itemLow, 1, true) or fullText:find(itemLow, 1, true) then
                -- Ще раз перевірити picker!
                if ItemPickerState[itemOriginal] == false then
                    return false
                end
                return true
            end
        end
    end

    return false
end

local function IsPriority(pLow, fullText)
    if PriorityLoot[pLow] then return true end
    for kw in pairs(PriorityLoot) do
        if fullText:find(kw, 1, true) then return true end
    end
    return false
end

-- ============================================================
-- AIM
-- ============================================================
local aimRayParams = RaycastParams.new()
aimRayParams.FilterType = Enum.RaycastFilterType.Exclude

local function FindAimPart(char)
    if not char then return nil end
    return char:FindFirstChild(Config.AimPart or "Head")
        or char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
end

local function IsVisible(char)
    if not char then return false end
    local myChar=lp.Character; if not myChar then return false end
    local part=FindAimPart(char); if not part then return false end
    local origin=Camera.CFrame.Position; local target=part.Position
    local dir=target-origin; local dist=dir.Magnitude
    if dist<1 then return true end
    aimRayParams.FilterDescendantsInstances={myChar}
    local result=workspace:Raycast(origin,dir.Unit*(dist-0.5),aimRayParams)
    if not result then return true end
    if result.Instance:IsDescendantOf(char) then return true end
    if result.Instance.Transparency>=0.8 then return true end
    return false
end

local function ScreenDist(part)
    if not part then return math.huge end
    local pos,on=Camera:WorldToViewportPoint(part.Position)
    if not on then return math.huge end
    local center=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)
    return (Vector2.new(pos.X,pos.Y)-center).Magnitude
end

local aimTarget,aimLocked,aimLastSwitch,aimSwitchCD = nil,false,0,0.35
local aimLostFrames,lastPing,pingTick = 0,0,0

local function FindNewAimTarget()
    local fov=Config.AimFOV; local best,bestDist=nil,math.huge
    for _,p in pairs(Players:GetPlayers()) do
        if p==lp then continue end
        local char=p.Character; if not char then continue end
        local h=char:FindFirstChildOfClass("Humanoid")
        if not h or h.Health<=0 then continue end
        local part=FindAimPart(char); if not part then continue end
        local sd=ScreenDist(part); if sd>fov then continue end
        if not IsVisible(char) then continue end
        if sd<bestDist then bestDist=sd;best=p end
    end
    return best
end

local function GetBestAimTarget()
    local now=tick(); local fov=Config.AimFOV
    if aimTarget and aimLocked then
        local char=aimTarget.Character
        if char then
            local h=char:FindFirstChildOfClass("Humanoid")
            if h and h.Health>0 then
                local part=FindAimPart(char)
                if part then
                    if ScreenDist(part)<=fov*1.8 and IsVisible(char) then aimLostFrames=0;return char end
                    aimLostFrames+=1; if aimLostFrames<12 then return char end
                end
            end
        end
        aimTarget=nil;aimLocked=false;aimLostFrames=0
    end
    if now-aimLastSwitch<aimSwitchCD then return nil end
    local best=FindNewAimTarget()
    if best then aimTarget=best;aimLocked=true;aimLostFrames=0;aimLastSwitch=now;return best.Character end
    return nil
end

local function GetClosestByDist()
    local root=GetRoot(); if not root then return nil end
    local best,bestD=nil,math.huge
    for _,v in pairs(Players:GetPlayers()) do
        if v==lp or not IsTargetAlive(v) then continue end
        local h=v.Character and v.Character:FindFirstChild("HumanoidRootPart")
        if h then local d=(h.Position-root.Position).Magnitude; if d<bestD then bestD=d;best=v end end
    end
    return best
end

local Controls = nil
task.spawn(function()
    if not game:IsLoaded() then game.Loaded:Wait() end; task.wait(1)
    pcall(function() Controls=require(lp:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule",5)):GetControls() end)
end)
local MobUp,MobDn = false,false

local lastSilentT,isTouching = 0,false
UIS.TouchStarted:Connect(function() isTouching=true end)
UIS.TouchEnded:Connect(function() isTouching=false end)

local function DoSilentAim()
    if not Config.SilentAim then return end
    local now=tick(); if now-lastSilentT<(IsMobile and 0.05 or 0.016) then return end; lastSilentT=now
    local shooting=IsPC and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or isTouching
    if not shooting then return end
    local tc=GetBestAimTarget(); if not tc then return end
    local head=FindAimPart(tc); if not head then return end
    Camera.CFrame=Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position,head.Position),IsMobile and 0.35 or 0.45)
end

-- KILL AURA
task.spawn(function()
    while task.wait(IsMobile and 0.3 or 0.15) do
        if not Config.KillAura or not IsHumAlive() then continue end
        local root,char=GetRoot(),GetChar(); if not root or not char then continue end
        local tool=char:FindFirstChildOfClass("Tool"); if not tool then continue end
        for _,p in pairs(Players:GetPlayers()) do
            if p==lp or not IsTargetAlive(p) then continue end
            local tR=p.Character and p.Character:FindFirstChild("HumanoidRootPart")
            if not tR or (tR.Position-root.Position).Magnitude>(Config.KillAuraRange or 15) then continue end
            pcall(function() root.CFrame=CFrame.new(root.Position,tR.Position) end)
            pcall(function() tool:Activate() end)
            pcall(function() for _,v in pairs(tool:GetDescendants()) do if v:IsA("RemoteEvent") then v:FireServer(p.Character,tR.Position) end end end)
        end
    end
end)

-- FPS/FULLBRIGHT
local fpsApplied=false
local function ApplyFPS()
    if fpsApplied then return end; fpsApplied=true
    pcall(function() settings().Rendering.QualityLevel=1;Light.GlobalShadows=false;Light.FogEnd=9e9 end)
    for _,v in pairs(Light:GetChildren()) do pcall(function() if v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("DepthOfFieldEffect") or v:IsA("ColorCorrectionEffect") then v.Enabled=false end end) end
    task.spawn(function() for _,v in pairs(workspace:GetDescendants()) do pcall(function() if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then v.Enabled=false end end) end end)
end

local sL={}
local function EnableFB()
    pcall(function() sL.B=Light.Brightness;sL.C=Light.ClockTime;sL.F=Light.FogEnd;sL.A=Light.Ambient;sL.O=Light.OutdoorAmbient;sL.G=Light.GlobalShadows
        Light.Brightness=2;Light.ClockTime=14;Light.FogEnd=100000;Light.Ambient=Color3.fromRGB(178,178,178);Light.OutdoorAmbient=Color3.fromRGB(178,178,178);Light.GlobalShadows=false end)
    for _,v in pairs(Light:GetChildren()) do pcall(function() if v:IsA("Atmosphere") then v.Density=0;v.Offset=0 end end) end
end
local function DisableFB()
    pcall(function() if sL.B then Light.Brightness=sL.B;Light.ClockTime=sL.C;Light.FogEnd=sL.F;Light.Ambient=sL.A;Light.OutdoorAmbient=sL.O;Light.GlobalShadows=sL.G end end)
end

-- AUTO EQUIP
local wKW={"ak","ar","m4","m1","glock","deagle","uzi","rpg","rpk","mp7","aug","dragunov","barrett","mossberg","python","raygun","saiga","shotgun","rifle","pistol","smg","lmg","gun","tommy","spas","sawn","sniper","usp","flamethrower","scar","awp","p90","famas","mac","stagecoach","revolver","minigun","acid","money gun","gravity","crossbow","taser","katana","machete","bat","knife","crowbar","saber","fireaxe","kunai","scythe"}
task.spawn(function()
    while task.wait(1.5) do
        if not Config.AutoEquip or not IsHumAlive() then continue end
        local root,hum,char=GetRoot(),GetHum(),GetChar(); if not root or not hum or not char then continue end
        local near=false
        for _,p in pairs(Players:GetPlayers()) do if p==lp or not IsTargetAlive(p) then continue end
            local h=p.Character:FindFirstChild("HumanoidRootPart"); if h and (h.Position-root.Position).Magnitude<50 then near=true;break end end
        if not near then continue end
        local eq=char:FindFirstChildOfClass("Tool")
        if eq then local en=eq.Name:lower(); local w=false; for _,k in pairs(wKW) do if en:find(k,1,true) then w=true;break end end; if w then continue end end
        local best=nil
        for _,item in pairs(lp.Backpack:GetChildren()) do if not item:IsA("Tool") then continue end; local n=item.Name:lower(); for _,k in pairs(wKW) do if n:find(k,1,true) then best=item;break end end; if best then break end end
        if best then pcall(function() hum:EquipTool(best) end) end
    end
end)

-- AUTO HEAL/ARMOR
local healCD=0
task.spawn(function()
    while task.wait(IsMobile and 1.5 or 0.8) do
        if not IsHumAlive() or tick()-healCD<2 then continue end
        local hum,char=GetHum(),GetChar(); if not hum or not char then continue end
        local function TU(kws)
            local found=nil
            for _,item in pairs(lp.Backpack:GetChildren()) do if not item:IsA("Tool") then continue end; local n=item.Name:lower(); for _,k in pairs(kws) do if n:find(k,1,true) then found=item;break end end; if found then break end end
            if not found then for _,item in pairs(char:GetChildren()) do if not item:IsA("Tool") then continue end; local n=item.Name:lower(); for _,k in pairs(kws) do if n:find(k,1,true) then found=item;break end end; if found then break end end end
            if not found then return end
            pcall(function() if found.Parent==lp.Backpack then hum:EquipTool(found);task.wait(0.25) end; local t=char:FindFirstChild(found.Name); if t then t:Activate() end end)
            task.wait(0.7); pcall(function() hum:UnequipTools() end); healCD=tick()
        end
        if Config.Heal and hum.Health<hum.MaxHealth*0.75 then TU({"medkit","bandage","firstaid","aid","heal","health"}) end
        if Config.Armor then TU({"armor","vest","helmet","shield","kevlar"}) end
    end
end)

lp.Idled:Connect(function() if Config.AntiAFK then pcall(function() VirtualUser:CaptureController();VirtualUser:ClickButton2(Vector2.new()) end) end end)
task.spawn(function() while task.wait(50) do if Config.AntiAFK then pcall(function() VirtualUser:CaptureController();VirtualUser:ClickButton2(Vector2.new()) end) end end end)

local function StartRobbery()
    Notify("ROB","Start...",2); if not SafeTeleport(COORDS.BANK_MONEY) then return end; task.wait(0.8)
    for i=1,20 do if not IsHumAlive() then break end
        pcall(function() local r=GetRoot(); if not r then return end; for _,v in pairs(workspace:GetDescendants()) do if v:IsA("ProximityPrompt") and v.Enabled then local pp=v.Parent; if pp and (r.Position-pp:GetPivot().Position).Magnitude<15 then SafeFirePrompt(v) end end end end); task.wait(0.5)
    end; SafeTeleport(COORDS.SAFE_ZONE); Notify("ROB","Done ✓",3)
end

-- ESP
local ESPCache={}
local function ClearESP(c) if not c then return end; pcall(function() local h=c:FindFirstChild("Head"); if h then local g=h:FindFirstChild("MrkESP"); if g then g:Destroy() end end; local hl=c:FindFirstChild("MrkHL"); if hl then hl:Destroy() end end) end
local function ClearAllESP() for _,v in pairs(Players:GetPlayers()) do if v~=lp then ClearESP(v.Character) end end; ESPCache={} end

task.spawn(function()
    while task.wait(IsMobile and 0.2 or 0.08) do
        if not Config.ESP then continue end; local myR=GetRoot()
        for _,v in pairs(Players:GetPlayers()) do
            if v==lp then continue end; local char=v.Character; local head=char and char:FindFirstChild("Head"); local hum=char and char:FindFirstChildOfClass("Humanoid")
            if not char or not head or not hum or hum.Health<=0 then if ESPCache[v] then ClearESP(char);ESPCache[v]=nil end; continue end
            local cache=ESPCache[v]
            if not cache or not cache.gui or not cache.gui.Parent then
                if cache then ClearESP(char) end
                local gui=Instance.new("BillboardGui"); gui.Name="MrkESP"; gui.Size=UDim2.new(0,IsMobile and 150 or 185,0,IsMobile and 42 or 50); gui.StudsOffset=Vector3.new(0,3.2,0); gui.AlwaysOnTop=true; gui.MaxDistance=IsMobile and 250 or 450; gui.Parent=head
                local bg=Instance.new("Frame",gui); bg.Size=UDim2.new(1,0,1,0); bg.BackgroundColor3=Color3.fromRGB(0,0,0); bg.BackgroundTransparency=0.45; bg.BorderSizePixel=0; Instance.new("UICorner",bg)
                local lbl=Instance.new("TextLabel",bg); lbl.Name="L"; lbl.Size=UDim2.new(1,0,1,0); lbl.BackgroundTransparency=1; lbl.Font=Enum.Font.GothamBold; lbl.TextSize=IsMobile and 10 or 12; lbl.TextWrapped=true; lbl.TextStrokeTransparency=0.3
                if IsPC then pcall(function() local hl=Instance.new("Highlight"); hl.Name="MrkHL"; hl.FillColor=Color3.new(1,0,0); hl.OutlineColor=Color3.new(1,1,1); hl.FillTransparency=0.65; hl.OutlineTransparency=0; hl.Adornee=char; hl.Parent=char end) end
                ESPCache[v]={gui=gui,lbl=lbl}; cache=ESPCache[v]
            end
            local dist=myR and math.floor((myR.Position-head.Position).Magnitude) or 0; local hp=math.floor(hum.Health); local mH=math.max(math.floor(hum.MaxHealth),1); local r=hp/mH
            cache.lbl.Text=string.format("[%s]\nHP:%d/%d | %dm",v.Name,hp,mH,dist)
            cache.lbl.TextColor3=r>=0.6 and Color3.fromRGB(0,255,100) or r>=0.3 and Color3.fromRGB(255,220,0) or Color3.fromRGB(255,60,60)
        end
    end
end)
Players.PlayerRemoving:Connect(function(p) if ESPCache[p] then ClearESP(p.Character);ESPCache[p]=nil end end)
for _,p in pairs(Players:GetPlayers()) do if p~=lp then p.CharacterRemoving:Connect(function(c) if ESPCache[p] then ClearESP(c);ESPCache[p]=nil end end) end end
Players.PlayerAdded:Connect(function(p) p.CharacterRemoving:Connect(function(c) if ESPCache[p] then ClearESP(c);ESPCache[p]=nil end end) end)

-- ITEM ESP
local ItemESPCache={}
local function ClearAllItemESP() for o,g in pairs(ItemESPCache) do pcall(function() g:Destroy() end) end; ItemESPCache={} end
task.spawn(function()
    while task.wait(IsMobile and 2 or 1) do
        if not Config.ItemESP then if next(ItemESPCache) then ClearAllItemESP() end; continue end
        local myR=GetRoot(); if not myR then continue end
        for o,g in pairs(ItemESPCache) do if not o or not o.Parent then pcall(function() g:Destroy() end);ItemESPCache[o]=nil end end
        for _,v in pairs(workspace:GetDescendants()) do
            if not v:IsA("ProximityPrompt") or not v.Enabled then continue end; local par=v.Parent; if not par then continue end
            if not IsValidLootPrompt(v) then continue end
            local pn=par.Name or ""; local pLow=pn:lower(); local ft=(pLow.." "..(v.ActionText or "").." "..(v.ObjectText or "")):lower()
            local pos=Vector3.zero; pcall(function() pos=par:GetPivot().Position end); if pos.Magnitude<1 then continue end
            local dist=(myR.Position-pos).Magnitude; if dist>(IsMobile and 200 or 400) then continue end
            if not ItemESPCache[par] then
                local gui=Instance.new("BillboardGui"); gui.Name="MrkItemESP"; gui.Size=UDim2.new(0,IsMobile and 120 or 150,0,28); gui.StudsOffset=Vector3.new(0,2,0); gui.AlwaysOnTop=true; gui.MaxDistance=IsMobile and 200 or 400
                local bg=Instance.new("Frame",gui); bg.Size=UDim2.new(1,0,1,0); bg.BackgroundColor3=Color3.fromRGB(0,0,0); bg.BackgroundTransparency=0.35; bg.BorderSizePixel=0; Instance.new("UICorner",bg)
                local lbl=Instance.new("TextLabel",bg); lbl.Name="L"; lbl.Size=UDim2.new(1,0,1,0); lbl.BackgroundTransparency=1; lbl.Font=Enum.Font.GothamBold; lbl.TextSize=IsMobile and 9 or 11; lbl.TextWrapped=true; lbl.TextStrokeTransparency=0.3
                pcall(function() gui.Parent=par end); if not gui.Parent then gui:Destroy();continue end; ItemESPCache[par]=gui
            end
            local gui=ItemESPCache[par]; local bg=gui:FindFirstChild("Frame"); local lbl=bg and bg:FindFirstChild("L")
            if lbl then local d=math.floor(dist); local isPrio=IsPriority(pLow,ft); lbl.Text=(isPrio and "⭐ " or "📦 ")..pn.." ["..d.."m]"; lbl.TextColor3=isPrio and Color3.fromRGB(255,215,0) or Color3.fromRGB(0,200,255) end
        end
    end
end)

local function RestoreCollision() local c=GetChar(); if not c then return end; for _,v in pairs(c:GetDescendants()) do if v:IsA("BasePart") then pcall(function() v.CanCollide=true end) end end end

-- AUTO FARM
local farmRunning=false
local function CollectPrompt(v)
    if not v or not v.Parent or not v.Enabled or not IsHumAlive() then return end
    local pos=nil; pcall(function() pos=v.Parent:GetPivot().Position end); if not pos or pos.Magnitude<1 then return end
    SafeTeleport(pos); task.wait(IsMobile and 0.4 or 0.25); SafeFirePrompt(v); task.wait(IsMobile and 0.3 or 0.2)
end
local function GetPP(v) local p=Vector3.zero; pcall(function() p=v.Parent:GetPivot().Position end); return p end

task.spawn(function()
    while task.wait(IsMobile and 1 or 0.5) do
        if not Config.Farm or farmRunning then continue end
        if not IsHumAlive() then task.wait(2);continue end
        farmRunning=true
        pcall(function()
            local prompts={}; for _,v in pairs(workspace:GetDescendants()) do if v:IsA("ProximityPrompt") and v.Enabled then table.insert(prompts,v) end end
            local pL,nL={},{}; local myR=GetRoot()
            for _,v in pairs(prompts) do
                if not v or not v.Parent or not v.Enabled then continue end
                if not IsValidLootPrompt(v) then continue end
                local pn=v.Parent.Name or ""; local pLow=pn:lower(); local ft=(pLow.." "..(v.ActionText or "").." "..(v.ObjectText or "")):lower()
                if IsPriority(pLow,ft) then table.insert(pL,v) else table.insert(nL,v) end
            end
            if myR then local mp=myR.Position
                table.sort(pL,function(a,b) return (GetPP(a)-mp).Magnitude<(GetPP(b)-mp).Magnitude end)
                table.sort(nL,function(a,b) return (GetPP(a)-mp).Magnitude<(GetPP(b)-mp).Magnitude end)
            end
            for _,v in pairs(pL) do if not Config.Farm or not IsHumAlive() then break end; CollectPrompt(v) end
            for _,v in pairs(nL) do if not Config.Farm or not IsHumAlive() then break end; CollectPrompt(v) end
        end)
        farmRunning=false
    end
end)

-- RENDER/HEARTBEAT
RS.RenderStepped:Connect(function(dt)
    local now=tick(); if now-pingTick>3 then pingTick=now;pcall(function() lastPing=lp:GetNetworkPing() end) end
    if Config.SilentAim then DoSilentAim() end
    if Config.AimActive then
        local t=GetBestAimTarget(); local p=t and FindAimPart(t)
        if p then local pT=math.clamp(lastPing,0.01,0.2); local vel=p.AssemblyLinearVelocity; local dist=(Camera.CFrame.Position-p.Position).Magnitude; local pM=math.clamp(dist/100,0.3,1.5); local pred=p.Position+vel*pT*pM; local sm=Config.AimSmooth; local sd=ScreenDist(p); if sd<30 then sm*=0.3 elseif sd<80 then sm*=0.6 end; Camera.CFrame=Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position,pred),sm) end
    else aimTarget=nil;aimLocked=false;aimLostFrames=0 end
    if Config.Fly and IsHumAlive() then
        local root,hum=GetRoot(),GetHum()
        if root and hum then local mx,mz=0,0
            if IsMobile and Controls then local mv=Controls:GetMoveVector();mx=mv.X;mz=mv.Z
            elseif IsPC then if UIS:IsKeyDown(Enum.KeyCode.W) then mz=-1 end; if UIS:IsKeyDown(Enum.KeyCode.S) then mz=1 end; if UIS:IsKeyDown(Enum.KeyCode.A) then mx=-1 end; if UIS:IsKeyDown(Enum.KeyCode.D) then mx=1 end end
            local cf=Camera.CFrame; local dir=cf.LookVector*-mz+cf.RightVector*mx; local upD=0
            if UIS:IsKeyDown(Enum.KeyCode.Space) or MobUp then upD=1 end; if UIS:IsKeyDown(Enum.KeyCode.LeftControl) or MobDn then upD=-1 end
            dir=dir+Vector3.new(0,upD,0); if dir.Magnitude>1 then dir=dir.Unit end
            root.CFrame=root.CFrame+dir*Config.FlySpeedValue*dt; root.AssemblyLinearVelocity=Vector3.zero; root.AssemblyAngularVelocity=Vector3.zero
        end
    end
end)

RS.Heartbeat:Connect(function()
    local hum,root=GetHum(),GetRoot(); if not hum or not root then return end
    if Config.AntiSeat and hum.SeatPart then pcall(function() hum.Sit=false end) end
    if Config.Speed and not Config.Fly and IsHumAlive() then if hum.WalkSpeed~=Config.WalkSpeedValue then hum.WalkSpeed=Config.WalkSpeedValue end
    elseif not Config.Fly and not Config.Speed then if hum.WalkSpeed~=16 then hum.WalkSpeed=16 end end
    if not Config.Fly and hum.PlatformStand then pcall(function() hum.PlatformStand=false end) end
    if Config.HighJump and IsHumAlive() then if hum.JumpPower~=Config.JumpPowerValue then hum.JumpPower=Config.JumpPowerValue end
    elseif not Config.HighJump and IsHumAlive() then if hum.JumpPower~=50 then hum.JumpPower=50 end end
    if Config.Noclip then local c=GetChar(); if c then for _,v in pairs(c:GetDescendants()) do if v:IsA("BasePart") then pcall(function() v.CanCollide=false end) end end end end
    if Config.Magnet then
        if not IsTargetAlive(Config.MagnetTarget) then Config.MagnetTarget=GetClosestByDist() end
        if Config.MagnetTarget then local tH=Config.MagnetTarget.Character and Config.MagnetTarget.Character:FindFirstChild("HumanoidRootPart")
            if tH then pcall(function() root.CFrame=root.CFrame:Lerp(tH.CFrame*CFrame.new(0,0,3),IsMobile and 0.15 or 0.22); root.AssemblyLinearVelocity=tH.AssemblyLinearVelocity end) end end
    else Config.MagnetTarget=nil end
    if Config.AutoSafe and not Config.Farm and IsHumAlive() and hum.Health<=Config.SafeHealth then if (root.Position-COORDS.SAFE_ZONE).Magnitude>20 then SafeTeleport(COORDS.SAFE_ZONE) end end
end)

UIS.JumpRequest:Connect(function() if not Config.InfJump then return end; local h=GetHum(); if h and h:GetState()~=Enum.HumanoidStateType.Jumping then pcall(function() h:ChangeState(Enum.HumanoidStateType.Jumping) end) end end)

lp.CharacterRemoving:Connect(function(char)
    if Config.Noclip then pcall(function() for _,v in pairs(char:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide=true end end end) end
    Config.Fly=false;Config.Noclip=false;aimTarget=nil;aimLocked=false;aimLostFrames=0
end)
lp.CharacterAdded:Connect(function(char)
    Config.Fly=false;Config.Noclip=false;Config.Magnet=false;aimTarget=nil;aimLocked=false;aimLostFrames=0
    pcall(function() if UpdFuncs then if UpdFuncs.Fly then UpdFuncs.Fly(false) end; if UpdFuncs.Noclip then UpdFuncs.Noclip(false) end; if UpdFuncs.Magnet then UpdFuncs.Magnet(false) end end end)
    task.wait(1); local h=char:FindFirstChildOfClass("Humanoid")
    if h then pcall(function() h.PlatformStand=false; h.WalkSpeed=Config.Speed and Config.WalkSpeedValue or 16; h.JumpPower=Config.HighJump and Config.JumpPowerValue or 50 end) end
end)

-- ============================================================
-- GUI
-- ============================================================
local SG=Instance.new("ScreenGui"); SG.Name="MarkiyanPro"; SG.ResetOnSpawn=false; SG.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
pcall(function() SG.Parent=game:GetService("CoreGui") end)
if not SG.Parent or not SG.Parent.Name then SG.Parent=lp:WaitForChild("PlayerGui") end

local MW=IsMobile and 280 or 420; local MH=IsMobile and 520 or 660
local Main=Instance.new("Frame",SG); Main.Size=UDim2.new(0,MW,0,MH); Main.AnchorPoint=Vector2.new(0.5,0.5); Main.Position=UDim2.new(0.5,0,0.5,0); Main.BackgroundColor3=Color3.fromRGB(8,8,14); Main.BorderSizePixel=0; Main.Visible=false; Instance.new("UICorner",Main); Instance.new("UIStroke",Main).Color=Color3.fromRGB(0,120,255)

local Header=Instance.new("Frame",Main); Header.Size=UDim2.new(1,0,0,40); Header.BackgroundColor3=Color3.fromRGB(10,10,20); Header.BorderSizePixel=0; Instance.new("UICorner",Header)
Instance.new("UIGradient",Header).Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(0,50,180)),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(0,130,255)),ColorSequenceKeypoint.new(1,Color3.fromRGB(0,50,180))})
local HL=Instance.new("TextLabel",Header); HL.Size=UDim2.new(1,-50,1,0); HL.Position=UDim2.new(0,8,0,0); HL.BackgroundTransparency=1; HL.TextColor3=Color3.fromRGB(255,255,255); HL.Font=Enum.Font.GothamBlack; HL.TextSize=IsMobile and 12 or 14; HL.TextXAlignment=Enum.TextXAlignment.Left; HL.Text="⚡ V51.5"..(IsMobile and " [M]" or "")
local CB=Instance.new("TextButton",Header); CB.Size=UDim2.new(0,26,0,26); CB.Position=UDim2.new(1,-34,0,7); CB.BackgroundColor3=Color3.fromRGB(180,30,30); CB.Text="✕"; CB.TextColor3=Color3.fromRGB(255,255,255); CB.Font=Enum.Font.GothamBold; CB.TextSize=12; CB.BorderSizePixel=0; CB.ZIndex=5; Instance.new("UICorner",CB).CornerRadius=UDim.new(0,6); CB.MouseButton1Click:Connect(function() Main.Visible=false end)

local TabBar=Instance.new("Frame",Main); TabBar.Size=UDim2.new(1,-8,0,28); TabBar.Position=UDim2.new(0,4,0,44); TabBar.BackgroundColor3=Color3.fromRGB(12,12,20); TabBar.BorderSizePixel=0; Instance.new("UICorner",TabBar)
local TL=Instance.new("UIListLayout",TabBar); TL.FillDirection=Enum.FillDirection.Horizontal; TL.HorizontalAlignment=Enum.HorizontalAlignment.Center; TL.VerticalAlignment=Enum.VerticalAlignment.Center; TL.Padding=UDim.new(0,3)

local Scroll=Instance.new("ScrollingFrame",Main); Scroll.Size=UDim2.new(1,-8,1,-80); Scroll.Position=UDim2.new(0,4,0,76); Scroll.BackgroundTransparency=1; Scroll.ScrollBarThickness=IsPC and 3 or 0; Scroll.ScrollBarImageColor3=Color3.fromRGB(0,120,255); Scroll.BorderSizePixel=0; Scroll.ClipsDescendants=true
local LL=Instance.new("UIListLayout",Scroll); LL.Padding=UDim.new(0,4); LL.HorizontalAlignment=Enum.HorizontalAlignment.Center; Instance.new("UIPadding",Scroll).PaddingTop=UDim.new(0,4)
LL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Scroll.CanvasSize=UDim2.new(0,0,0,LL.AbsoluteContentSize.Y+10) end)

-- FOV
local fovC=Instance.new("Frame",SG); fovC.Size=UDim2.new(0,Config.AimFOV*2,0,Config.AimFOV*2); fovC.Position=UDim2.new(0.5,-Config.AimFOV,0.5,-Config.AimFOV); fovC.BackgroundTransparency=1; fovC.BorderSizePixel=0; fovC.Visible=false; fovC.ZIndex=10; Instance.new("UICorner",fovC).CornerRadius=UDim.new(1,0); local fS=Instance.new("UIStroke",fovC); fS.Color=Color3.fromRGB(0,120,255); fS.Thickness=1.5; fS.Transparency=0.3
local tI=Instance.new("TextLabel",SG); tI.Size=UDim2.new(0,200,0,22); tI.Position=UDim2.new(0.5,-100,0.5,-(Config.AimFOV+32)); tI.BackgroundColor3=Color3.fromRGB(10,10,16); tI.BackgroundTransparency=0.25; tI.BorderSizePixel=0; tI.TextColor3=Color3.fromRGB(0,200,100); tI.Font=Enum.Font.GothamBold; tI.TextSize=11; tI.Text=""; tI.Visible=false; tI.ZIndex=12; Instance.new("UICorner",tI); Instance.new("UIStroke",tI).Color=Color3.fromRGB(40,40,58)
local function UpdateFOV() local r=Config.AimFOV; fovC.Size=UDim2.new(0,r*2,0,r*2); fovC.Position=UDim2.new(0.5,-r,0.5,-r); tI.Position=UDim2.new(0.5,-100,0.5,-(r+32)) end
local fUT=0
RS.RenderStepped:Connect(function() local now=tick(); if now-fUT<0.05 then return end; fUT=now; fovC.Visible=Config.AimActive or Config.SilentAim; tI.Visible=false
    if Config.AimActive then local tc=aimTarget and aimTarget.Character; local p=tc and FindAimPart(tc); if p and aimLocked then local plr=Players:GetPlayerFromCharacter(tc); tI.Text="🔒 "..(plr and plr.Name or "?"); tI.TextColor3=Color3.fromRGB(0,230,120); tI.Visible=true; fS.Color=Color3.fromRGB(0,200,100) else tI.Text="—"; tI.Visible=true; fS.Color=Color3.fromRGB(100,100,180) end
    elseif Config.SilentAim then local tc=aimTarget and aimTarget.Character; local p=tc and FindAimPart(tc); if p then local plr=Players:GetPlayerFromCharacter(tc); tI.Text="🔇 "..(plr and plr.Name or "?"); tI.TextColor3=Color3.fromRGB(255,200,50); tI.Visible=true; fS.Color=Color3.fromRGB(255,200,50) else tI.Text="—"; tI.Visible=true; fS.Color=Color3.fromRGB(100,100,180) end end
end)

-- FLY BTNS
local flyH=Instance.new("Frame",SG); flyH.Size=UDim2.new(0,134,0,60); flyH.Position=UDim2.new(1,-148,1,-76); flyH.BackgroundTransparency=1; flyH.Visible=false; flyH.ZIndex=50
local function MkFB(l,x,cb) local b=Instance.new("TextButton",flyH); b.Size=UDim2.new(0,60,0,56); b.Position=UDim2.new(0,x,0,0); b.BackgroundColor3=Color3.fromRGB(12,12,18); b.Text=l; b.TextColor3=Color3.fromRGB(255,255,255); b.Font=Enum.Font.GothamBlack; b.TextSize=26; b.BorderSizePixel=0; b.ZIndex=51; b.AutoButtonColor=false; Instance.new("UICorner",b); Instance.new("UIStroke",b).Color=Color3.fromRGB(40,40,58)
    b.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then cb(true);b.BackgroundColor3=Color3.fromRGB(32,32,48) end end)
    b.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then cb(false);b.BackgroundColor3=Color3.fromRGB(12,12,18) end end) end
MkFB("▲",0,function(v) MobUp=v end); MkFB("▼",70,function(v) MobDn=v end)
local function UpdateFlyBtns() flyH.Visible=Config.Fly and IsMobile end

-- TABS
local Sections,TabButtons,ActiveTab={},{},nil; local tabNames={"Combat","Move","Misc","Items","Binds"}; local tabW=IsMobile and 46 or 64
for _,n in pairs(tabNames) do Sections[n]={}; local b=Instance.new("TextButton",TabBar); b.Size=UDim2.new(0,tabW,0,22); b.BackgroundColor3=Color3.fromRGB(18,18,30); b.TextColor3=Color3.fromRGB(150,150,170); b.Font=Enum.Font.GothamBold; b.TextSize=IsMobile and 9 or 11; b.Text=n; b.BorderSizePixel=0; b.AutoButtonColor=false; Instance.new("UICorner",b); TabButtons[n]=b end

do local d,s,p=false,nil,nil; Header.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then d=true;s=i.Position;p=Main.Position end end)
    Header.InputChanged:Connect(function(i) if not d then return end; if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then local dl=i.Position-s; Main.Position=UDim2.new(p.X.Scale,p.X.Offset+dl.X,p.Y.Scale,p.Y.Offset+dl.Y) end end)
    Header.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then d=false end end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then d=false end end) end

local BtnH=IsMobile and 36 or 32; local UpdFuncs,Buttons={},{}
local function MakeFrame(tab) local f=Instance.new("Frame",Scroll); f.Size=UDim2.new(0.97,0,0,BtnH); f.BackgroundTransparency=1; f.BorderSizePixel=0; f.Visible=false; table.insert(Sections[tab],f); return f end
local function AddCategory(tab,text) local f=Instance.new("Frame",Scroll); f.Size=UDim2.new(0.97,0,0,20); f.BackgroundColor3=Color3.fromRGB(0,55,155); f.BorderSizePixel=0; f.Visible=false; Instance.new("UICorner",f); local l=Instance.new("TextLabel",f); l.Size=UDim2.new(1,0,1,0); l.BackgroundTransparency=1; l.TextColor3=Color3.fromRGB(255,255,255); l.Font=Enum.Font.GothamBold; l.TextSize=11; l.Text="── "..text.." ──"; table.insert(Sections[tab],f) end

local function AddToggle(tab,name,key,cbOn,cbOff)
    local f=MakeFrame(tab); local btn=Instance.new("TextButton",f); btn.Size=UDim2.new(1,0,1,0); btn.BackgroundColor3=Color3.fromRGB(20,20,30); btn.TextColor3=Color3.fromRGB(190,190,200); btn.Font=Enum.Font.GothamBold; btn.TextSize=IsMobile and 11 or 13; btn.BorderSizePixel=0; btn.AutoButtonColor=false; btn.TextXAlignment=Enum.TextXAlignment.Left; btn.Text="       "..name..": OFF"; Instance.new("UICorner",btn)
    local dot=Instance.new("Frame",btn); dot.Size=UDim2.new(0,8,0,8); dot.AnchorPoint=Vector2.new(0,0.5); dot.Position=UDim2.new(0,10,0.5,0); dot.BackgroundColor3=Color3.fromRGB(200,50,50); dot.BorderSizePixel=0; dot.ZIndex=btn.ZIndex+1; Instance.new("UICorner",dot)
    local function Upd(s) if s then btn.BackgroundColor3=Color3.fromRGB(0,70,190);btn.TextColor3=Color3.fromRGB(255,255,255);dot.BackgroundColor3=Color3.fromRGB(0,220,80);btn.Text="       "..name..": ON" else btn.BackgroundColor3=Color3.fromRGB(20,20,30);btn.TextColor3=Color3.fromRGB(190,190,200);dot.BackgroundColor3=Color3.fromRGB(200,50,50);btn.Text="       "..name..": OFF" end end
    UpdFuncs[key]=Upd; if Config[key] then Upd(true) end
    btn.MouseButton1Click:Connect(function() Config[key]=not Config[key]; Upd(Config[key]); if Config[key] then if cbOn then task.spawn(cbOn) end else if cbOff then task.spawn(cbOff) end end
        if key=="Fly" then UpdateFlyBtns() end; if key=="AimActive" and not Config[key] then aimTarget=nil;aimLocked=false;aimLostFrames=0 end; if key=="ESP" and not Config[key] then ClearAllESP() end; if key=="ItemESP" and not Config[key] then ClearAllItemESP() end
        SaveSettings(Config,ItemPickerState); Notify(name,Config[key] and "ON ✓" or "OFF ✗",1.5) end); return Upd
end

local function AddSlider(tab,label,minV,maxV,def,cKey,cb)
    local f=Instance.new("Frame",Scroll); f.Size=UDim2.new(0.97,0,0,IsMobile and 50 or 52); f.BackgroundColor3=Color3.fromRGB(16,16,24); f.BorderSizePixel=0; f.Visible=false; Instance.new("UICorner",f); table.insert(Sections[tab],f)
    local cv=Config[cKey] or def; local lbl=Instance.new("TextLabel",f); lbl.Size=UDim2.new(1,-8,0,20); lbl.Position=UDim2.new(0,4,0,2); lbl.BackgroundTransparency=1; lbl.TextColor3=Color3.fromRGB(200,200,210); lbl.Font=Enum.Font.GothamBold; lbl.TextSize=IsMobile and 11 or 12; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.Text=label..": "..cv
    local tr=Instance.new("Frame",f); tr.Size=UDim2.new(0.92,0,0,IsMobile and 9 or 8); tr.Position=UDim2.new(0.04,0,0,IsMobile and 32 or 34); tr.BackgroundColor3=Color3.fromRGB(35,35,50); tr.BorderSizePixel=0; Instance.new("UICorner",tr)
    local iR=math.clamp((cv-minV)/(maxV-minV),0,1); local fl=Instance.new("Frame",tr); fl.Size=UDim2.new(iR,0,1,0); fl.BackgroundColor3=Color3.fromRGB(0,100,255); fl.BorderSizePixel=0; Instance.new("UICorner",fl)
    local kS=IsMobile and 16 or 13; local kn=Instance.new("Frame",tr); kn.Size=UDim2.new(0,kS,0,kS); kn.Position=UDim2.new(iR,-kS/2,0.5,-kS/2); kn.BackgroundColor3=Color3.fromRGB(255,255,255); kn.BorderSizePixel=0; Instance.new("UICorner",kn)
    local dg=false; local function US(inp) local rel=math.clamp((inp.Position.X-tr.AbsolutePosition.X)/tr.AbsoluteSize.X,0,1); local val=math.floor(minV+rel*(maxV-minV)); fl.Size=UDim2.new(rel,0,1,0); kn.Position=UDim2.new(rel,-kS/2,0.5,-kS/2); lbl.Text=label..": "..val; Config[cKey]=val; if cb then cb(val) end end
    tr.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dg=true;US(i) end end)
    UIS.InputChanged:Connect(function(i) if not dg then return end; if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then US(i) end end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dg=false;SaveSettings(Config,ItemPickerState) end end)
end

local function AddAction(tab,name,color,cb) local f=MakeFrame(tab); local btn=Instance.new("TextButton",f); btn.Size=UDim2.new(1,0,1,0); btn.BackgroundColor3=color; btn.TextColor3=Color3.fromRGB(255,255,255); btn.Font=Enum.Font.GothamBold; btn.TextSize=IsMobile and 11 or 13; btn.BorderSizePixel=0; btn.AutoButtonColor=false; btn.Text=name; Instance.new("UICorner",btn); btn.MouseButton1Click:Connect(function() task.spawn(cb) end) end
local function AddTP(tab,name,vec) local f=MakeFrame(tab); local btn=Instance.new("TextButton",f); btn.Size=UDim2.new(1,0,1,0); btn.BackgroundColor3=Color3.fromRGB(18,18,32); btn.TextColor3=Color3.fromRGB(255,215,0); btn.Font=Enum.Font.GothamBold; btn.TextSize=IsMobile and 11 or 12; btn.BorderSizePixel=0; btn.AutoButtonColor=false; btn.Text="📍 "..name; Instance.new("UICorner",btn); btn.MouseButton1Click:Connect(function() if SafeTeleport(vec) then Notify("TP","➜ "..name,2) end end) end

AddCategory("Combat","COMBAT")
AddToggle("Combat","AIM LOCK","AimActive",function() aimTarget=nil;aimLocked=false;aimLostFrames=0;aimLastSwitch=0 end,function() aimTarget=nil;aimLocked=false;aimLostFrames=0 end)
AddToggle("Combat","SILENT AIM","SilentAim"); AddToggle("Combat","KILL AURA","KillAura"); AddSlider("Combat","Aura Range",5,30,Config.KillAuraRange,"KillAuraRange")
AddToggle("Combat","ESP","ESP",nil,function() ClearAllESP() end); AddToggle("Combat","ITEM ESP","ItemESP",nil,function() ClearAllItemESP() end)
AddToggle("Combat","MAGNET","Magnet",nil,function() Config.MagnetTarget=nil end); AddToggle("Combat","AUTO EQUIP","AutoEquip")
AddCategory("Combat","AIM CONFIG"); AddSlider("Combat","FOV",50,500,Config.AimFOV,"AimFOV",function(v) Config.AimFOV=v;UpdateFOV() end)
AddSlider("Combat","Smooth(x100)",5,100,math.floor(Config.AimSmooth*100),"AimSmooth",function(v) Config.AimSmooth=v/100 end)

AddCategory("Move","MOVEMENT")
AddToggle("Move","FLY","Fly",function() UpdateFlyBtns() end,function() UpdateFlyBtns();local h=GetHum();if h then h.PlatformStand=false;h.WalkSpeed=16 end end)
AddSlider("Move","FLY SPEED",10,IsPC and 250 or 150,Config.FlySpeedValue,"FlySpeedValue")
AddToggle("Move","SPEED","Speed",nil,function() local h=GetHum();if h then h.WalkSpeed=16 end end)
AddSlider("Move","WALK SPEED",16,IsPC and 150 or 100,Config.WalkSpeedValue,"WalkSpeedValue")
AddToggle("Move","NOCLIP","Noclip",nil,function() RestoreCollision() end); AddToggle("Move","INF JUMP","InfJump")
AddToggle("Move","HIGH JUMP","HighJump",function() local h=GetHum();if h then h.JumpPower=Config.JumpPowerValue end end,function() local h=GetHum();if h then h.JumpPower=50 end end)
AddSlider("Move","JUMP",50,300,Config.JumpPowerValue,"JumpPowerValue",function(v) if Config.HighJump then local h=GetHum();if h then h.JumpPower=v end end end)
AddCategory("Move","TELEPORTS"); AddTP("Move","GUN SHOP",COORDS.GUN_SHOP); AddTP("Move","BANK",COORDS.BANK_ENT); AddTP("Move","SAFE ZONE",COORDS.SAFE_ZONE)

AddCategory("Misc","SURVIVAL"); AddToggle("Misc","AUTO SAFE","AutoSafe"); AddToggle("Misc","AUTO HEAL","Heal"); AddToggle("Misc","AUTO ARMOR","Armor")
AddCategory("Misc","FARM & VISUALS"); AddToggle("Misc","AUTO FARM","Farm")
AddToggle("Misc","FULLBRIGHT","Fullbright",function() EnableFB() end,function() DisableFB() end)
AddToggle("Misc","FPS BOOST","FPSBoost",function() ApplyFPS() end)
AddCategory("Misc","UTILITIES"); AddToggle("Misc","ANTI-SEAT","AntiSeat"); AddToggle("Misc","ANTI-AFK","AntiAFK")
AddCategory("Misc","ACTIONS"); AddAction("Misc","🏦 ROB BANK",Color3.fromRGB(150,20,20),StartRobbery)

-- ITEMS TAB
AddCategory("Items","ITEM PICKER (162)")
local iIF=Instance.new("Frame",Scroll); iIF.Size=UDim2.new(0.97,0,0,IsMobile and 36 or 28); iIF.BackgroundColor3=Color3.fromRGB(12,12,22); iIF.BorderSizePixel=0; iIF.Visible=false; Instance.new("UICorner",iIF); table.insert(Sections["Items"],iIF)
local iIL=Instance.new("TextLabel",iIF); iIL.Size=UDim2.new(1,0,1,0); iIL.BackgroundTransparency=1; iIL.TextColor3=Color3.fromRGB(120,160,255); iIL.Font=Enum.Font.Gotham; iIL.TextSize=IsMobile and 9 or 10; iIL.TextWrapped=true; iIL.Text="🔍 ✓=збирає ✗=ігнорує"

local sF=Instance.new("Frame",Scroll); sF.Size=UDim2.new(0.97,0,0,IsMobile and 38 or 34); sF.BackgroundColor3=Color3.fromRGB(16,16,26); sF.BorderSizePixel=0; sF.Visible=false; Instance.new("UICorner",sF); table.insert(Sections["Items"],sF)
local sB=Instance.new("TextBox",sF); sB.Size=UDim2.new(0.60,-4,0,IsMobile and 28 or 24); sB.Position=UDim2.new(0,6,0.5,IsMobile and -14 or -12); sB.BackgroundColor3=Color3.fromRGB(25,25,40); sB.TextColor3=Color3.fromRGB(255,255,255); sB.PlaceholderText="🔍 search..."; sB.PlaceholderColor3=Color3.fromRGB(100,100,130); sB.Font=Enum.Font.Gotham; sB.TextSize=IsMobile and 11 or 12; sB.ClearTextOnFocus=false; sB.BorderSizePixel=0; Instance.new("UICorner",sB)
local eA=Instance.new("TextButton",sF); eA.Size=UDim2.new(0.17,0,0,IsMobile and 28 or 24); eA.Position=UDim2.new(0.62,2,0.5,IsMobile and -14 or -12); eA.BackgroundColor3=Color3.fromRGB(0,120,50); eA.TextColor3=Color3.fromRGB(255,255,255); eA.Font=Enum.Font.GothamBold; eA.TextSize=IsMobile and 9 or 10; eA.Text="ALL✓"; eA.BorderSizePixel=0; Instance.new("UICorner",eA)
local dAB=Instance.new("TextButton",sF); dAB.Size=UDim2.new(0.17,0,0,IsMobile and 28 or 24); dAB.Position=UDim2.new(0.81,2,0.5,IsMobile and -14 or -12); dAB.BackgroundColor3=Color3.fromRGB(150,30,30); dAB.TextColor3=Color3.fromRGB(255,255,255); dAB.Font=Enum.Font.GothamBold; dAB.TextSize=IsMobile and 9 or 10; dAB.Text="ALL✗"; dAB.BorderSizePixel=0; Instance.new("UICorner",dAB)

local itemBtns={}
for _,iN in ipairs(ALL_ITEMS) do
    local f=Instance.new("Frame",Scroll); f.Size=UDim2.new(0.97,0,0,IsMobile and 30 or 28); f.BackgroundTransparency=1; f.BorderSizePixel=0; f.Visible=false; table.insert(Sections["Items"],f)
    local b=Instance.new("TextButton",f); b.Size=UDim2.new(1,0,1,0); b.Font=Enum.Font.GothamBold; b.TextSize=IsMobile and 10 or 11; b.BorderSizePixel=0; b.AutoButtonColor=false; b.TextXAlignment=Enum.TextXAlignment.Left; Instance.new("UICorner",b)
    local function U() if ItemPickerState[iN] then b.BackgroundColor3=Color3.fromRGB(10,60,30);b.TextColor3=Color3.fromRGB(100,255,130);b.Text="  ✓ "..iN else b.BackgroundColor3=Color3.fromRGB(50,15,15);b.TextColor3=Color3.fromRGB(255,120,120);b.Text="  ✗ "..iN end end; U()
    b.MouseButton1Click:Connect(function() ItemPickerState[iN]=not ItemPickerState[iN]; U(); SaveSettings(Config,ItemPickerState) end)
    table.insert(itemBtns,{frame=f,itemName=iN,update=U})
end

local function FilterItems(q) local ql=q:lower(); for _,e in pairs(itemBtns) do e.frame.Visible=(ActiveTab=="Items") and (ql=="" or e.itemName:lower():find(ql,1,true)~=nil) end; task.wait(); Scroll.CanvasSize=UDim2.new(0,0,0,LL.AbsoluteContentSize.Y+10) end
sB:GetPropertyChangedSignal("Text"):Connect(function() if ActiveTab=="Items" then FilterItems(sB.Text) end end)
eA.MouseButton1Click:Connect(function() local q=sB.Text:lower(); for _,e in pairs(itemBtns) do if q=="" or e.itemName:lower():find(q,1,true) then ItemPickerState[e.itemName]=true;e.update() end end; SaveSettings(Config,ItemPickerState) end)
dAB.MouseButton1Click:Connect(function() local q=sB.Text:lower(); for _,e in pairs(itemBtns) do if q=="" or e.itemName:lower():find(q,1,true) then ItemPickerState[e.itemName]=false;e.update() end end; SaveSettings(Config,ItemPickerState) end)

-- BINDS
local bA={{key="Fly",name="FLY"},{key="AimActive",name="AIM"},{key="Noclip",name="NOCLIP"},{key="SilentAim",name="SILENT"},{key="ToggleUI",name="UI"}}
local bIF=Instance.new("Frame",Scroll); bIF.Size=UDim2.new(0.97,0,0,IsMobile and 36 or 26); bIF.BackgroundColor3=Color3.fromRGB(12,12,22); bIF.BorderSizePixel=0; bIF.Visible=false; Instance.new("UICorner",bIF); table.insert(Sections["Binds"],bIF)
local bIL=Instance.new("TextLabel",bIF); bIL.Size=UDim2.new(1,0,1,0); bIL.BackgroundTransparency=1; bIL.TextColor3=Color3.fromRGB(120,160,255); bIL.Font=Enum.Font.Gotham; bIL.TextSize=IsMobile and 10 or 11; bIL.TextWrapped=true; bIL.Text="Кнопка → клавіша"
AddCategory("Binds","BINDS")
local BBtns={}
local function AddBR(tab,aK,aN) local f=Instance.new("Frame",Scroll); f.Size=UDim2.new(0.97,0,0,IsMobile and 40 or 36); f.BackgroundColor3=Color3.fromRGB(16,16,26); f.BorderSizePixel=0; f.Visible=false; Instance.new("UICorner",f); table.insert(Sections[tab],f)
    local nl=Instance.new("TextLabel",f); nl.Size=UDim2.new(0.52,0,1,0); nl.Position=UDim2.new(0,10,0,0); nl.BackgroundTransparency=1; nl.TextColor3=Color3.fromRGB(200,200,210); nl.Font=Enum.Font.GothamBold; nl.TextSize=IsMobile and 11 or 13; nl.TextXAlignment=Enum.TextXAlignment.Left; nl.Text=aN
    local bb=Instance.new("TextButton",f); bb.Size=UDim2.new(0.4,0,0,IsMobile and 28 or 24); bb.Position=UDim2.new(0.56,0,0.5,IsMobile and -14 or -12); bb.BackgroundColor3=Color3.fromRGB(22,22,38); bb.TextColor3=Color3.fromRGB(170,200,255); bb.Font=Enum.Font.GothamBold; bb.TextSize=IsMobile and 10 or 11; bb.BorderSizePixel=0; bb.AutoButtonColor=false; bb.Text=Binds[aK] and tostring(Binds[aK]):gsub("Enum%.KeyCode%.","") or "?"; Instance.new("UICorner",bb); Instance.new("UIStroke",bb).Color=Color3.fromRGB(0,100,200); BBtns[aK]=bb
    bb.MouseButton1Click:Connect(function() if waitingForBind then return end; waitingForBind=aK; bb.Text="[...]"; bb.TextColor3=Color3.fromRGB(255,220,50) end) end
for _,e in pairs(bA) do AddBR("Binds",e.key,e.name) end

local function ShowTab(n) ActiveTab=n; for nn,frames in pairs(Sections) do for _,f in pairs(frames) do pcall(function() f.Visible=(nn==n) end) end end; if n=="Items" then FilterItems(sB.Text) end
    for nn,b in pairs(TabButtons) do if nn==n then b.BackgroundColor3=Color3.fromRGB(0,100,220);b.TextColor3=Color3.fromRGB(255,255,255) else b.BackgroundColor3=Color3.fromRGB(18,18,30);b.TextColor3=Color3.fromRGB(150,150,170) end end
    task.wait(); Scroll.CanvasPosition=Vector2.zero; Scroll.CanvasSize=UDim2.new(0,0,0,LL.AbsoluteContentSize.Y+10) end
for n,b in pairs(TabButtons) do b.MouseButton1Click:Connect(function() ShowTab(n) end) end

UIS.InputBegan:Connect(function(inp,gpe)
    if waitingForBind then if inp.UserInputType==Enum.UserInputType.Keyboard then local a=waitingForBind; Binds[a]=inp.KeyCode; if BBtns[a] then BBtns[a].Text=tostring(inp.KeyCode):gsub("Enum%.KeyCode%.",""); BBtns[a].TextColor3=Color3.fromRGB(170,200,255) end; waitingForBind=nil; SaveSettings(Config,ItemPickerState) end; return end
    if gpe then return end
    for a,k in pairs(Binds) do if inp.KeyCode~=k then continue end
        if a=="ToggleUI" then Main.Visible=not Main.Visible
        elseif a=="Fly" then Config.Fly=not Config.Fly;if UpdFuncs.Fly then UpdFuncs.Fly(Config.Fly) end;UpdateFlyBtns();if not Config.Fly then local h=GetHum();if h then h.PlatformStand=false;h.WalkSpeed=16 end end
        elseif a=="AimActive" then Config.AimActive=not Config.AimActive;if UpdFuncs.AimActive then UpdFuncs.AimActive(Config.AimActive) end;aimTarget=nil;aimLocked=false;aimLostFrames=0
        elseif a=="Noclip" then Config.Noclip=not Config.Noclip;if UpdFuncs.Noclip then UpdFuncs.Noclip(Config.Noclip) end;if not Config.Noclip then RestoreCollision() end
        elseif a=="SilentAim" then Config.SilentAim=not Config.SilentAim;if UpdFuncs.SilentAim then UpdFuncs.SilentAim(Config.SilentAim) end end
    end
end)

local MS=IsMobile and 52 or 42; local MB=Instance.new("TextButton",SG); MB.Size=UDim2.new(0,MS,0,MS); MB.Position=UDim2.new(0,10,0.28,0); MB.Text="M"; MB.Font=Enum.Font.GothamBlack; MB.TextSize=IsMobile and 22 or 18; MB.BackgroundColor3=Color3.fromRGB(0,80,200); MB.TextColor3=Color3.fromRGB(255,255,255); MB.BorderSizePixel=0; MB.AutoButtonColor=false; MB.ZIndex=100; Instance.new("UICorner",MB); Instance.new("UIStroke",MB).Color=Color3.fromRGB(255,255,255)
task.spawn(function() while true do TweenService:Create(MB,TweenInfo.new(1.6),{BackgroundColor3=Color3.fromRGB(0,40,160)}):Play(); task.wait(1.6); TweenService:Create(MB,TweenInfo.new(1.6),{BackgroundColor3=Color3.fromRGB(0,110,255)}):Play(); task.wait(1.6) end end)
do local d,s,p,t,m=false,nil,nil,0,false
    MB.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then d=true;s=i.Position;p=MB.Position;t=tick();m=false end end)
    MB.InputChanged:Connect(function(i) if not d then return end; if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then local dl=i.Position-s; if dl.Magnitude>6 then m=true end; MB.Position=UDim2.new(p.X.Scale,p.X.Offset+dl.X,p.Y.Scale,p.Y.Offset+dl.Y) end end)
    MB.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then if d and not m and tick()-t<0.28 then Main.Visible=not Main.Visible end; d=false end end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then d=false end end) end

ShowTab("Combat")
if Config.Fullbright then task.spawn(EnableFB) end
if Config.FPSBoost then task.spawn(ApplyFPS) end
if Config.HighJump then local h=GetHum();if h then h.JumpPower=Config.JumpPowerValue end end
Notify("⚡ V51.5",IsMobile and "📱 PickerFix+DoorFix ✓" or "M=меню | PickerFix ✓",5)