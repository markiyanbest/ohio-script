-- markiyanbest's script (V64 - ADAPTIVE UI + FLY FIX + FARM FIX)
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

local IsMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled
local IsPC = not IsMobile

pcall(function()
	for _, sg in pairs({game:GetService("CoreGui"), lp:WaitForChild("PlayerGui")}) do
		for _, v in pairs(sg:GetChildren()) do
			if v:IsA("ScreenGui") and (v.Name == "MarkiyanPro" or v.Name:find("Sys_V5") or v.Name:find("Sys_V6")) then
				v:Destroy()
			end
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
		if v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("DepthOfFieldEffect") or v:IsA("ColorCorrectionEffect") then
			pcall(function() v.Enabled = false end)
		end
	end
end

local COORDS = {
	GUN_SHOP = Vector3.new(1131, 25, -1344),
	BANK_ENT = Vector3.new(1106, 8, -336),
	BANK_MONEY = Vector3.new(1110, 8, -325),
	SAFE_ZONE = Vector3.new(-37, -27, 3),
}

local ALL_ITEMS = {
	"4th of July Hat",
	"Acid Gun",
	"Admin AK-47",
	"Admin Nuke",
	"Admin RPG",
	"Airdrop Marker",
	"Airdrop",
	"Airstrike",
	"AK-47",
	"Apple",
	"AR-15",
	"Armored Truck",
	"AS VAL",
	"ATM",
	"AUG",
	"Balloon",
	"Banana",
	"Banana Peel",
	"Bandage",
	"Barrett M107",
	"Baseball Bat",
	"Basketball",
	"Baton",
	"Beach Ball",
	"Beans",
	"Bear Trap",
	"Black Bandana",
	"Bloxaide",
	"Bloxy Cola",
	"Blue Bandana",
	"Blue Candy Cane",
	"Blue Gloves",
	"Brass Knuckles",
	"Burger",
	"C4",
	"Cake",
	"Candy Cane",
	"Cash Register",
	"Chicken",
	"Choco Bunny",
	"Chocolates",
	"Clover Balloon",
	"Clown",
	"Clown Mallet",
	"Coffee",
	"Component Boxes",
	"Cookie",
	"Cotton Candy",
	"Crowbar",
	"Cruiser Keys",
	"Deagle",
	"Diamond Glock",
	"Diamond Taco",
	"Dollar Balloon",
	"Donut",
	"Double Barrel",
	"Dragunov",
	"Drone",
	"Dumbell",
	"Easter Basket",
	"Electronics",
	"Explosives Scrap",
	"Festive Guitar",
	"Fire Extinguisher",
	"Fireaxe",
	"Firework",
	"Firework Cake",
	"Firework Cone",
	"Firework Mortar",
	"Fists",
	"Flamethrower",
	"Flashbang",
	"Flashlight",
	"Frag Grenade",
	"Gems",
	"Glock",
	"Glock 18",
	"Gold AK-47",
	"Gold Deagle",
	"Gold Lucky Block",
	"Golden Clover Balloon",
	"Gravity Gun",
	"Green Firework",
	"Green Lucky Block",
	"Grocery Cart",
	"Guitar",
	"Heart Balloon",
	"Heavy C4",
	"Heavy Vest",
	"Helicopter Keys",
	"Hockey Mask",
	"Hotdog",
	"Hoverboard",
	"July 4th Firework",
	"Katana",
	"Knife",
	"Kunai",
	"Landmines",
	"Large Present",
	"Light Vest",
	"Locker",
	"Lockpick",
	"M1 Garand",
	"M1911",
	"M249 SAW",
	"M4A1",
	"Maraca",
	"Materials",
	"Meat Grinder",
	"Medical Supplies",
	"Medium Vest",
	"Medkit",
	"Megaphone",
	"Military Keycard",
	"Military Key Card",
	"Military Vest",
	"Molotov",
	"Money Balloon",
	"Money Gun",
	"Money Printer",
	"Mossberg",
	"MP7",
	"Mustang Keys",
	"Night Vision Goggles",
	"Nuke Launcher",
	"Orange Lucky Block",
	"Pepper Spray",
	"Pink Firework",
	"Pizza",
	"Police Keycard",
	"Police Key Card",
	"Presents",
	"Purple Lucky Block",
	"Python",
	"Raygun",
	"Red Bandana",
	"Red Gloves",
	"Red Lucky Block",
	"Rifles",
	"Riot Shield",
	"Roman Candle",
	"Rose",
	"RPG",
	"RPK",
	"Saber",
	"Safes",
	"Saiga 12",
	"Sawn Off",
	"Shopping Cart",
	"Sign",
	"Skateboard",
	"Slot Machine",
	"Small Present",
	"Smoke Grenade",
	"Sombrero Hat",
	"SPAS-12",
	"Sparkler",
	"Spectral Scythe",
	"Spiked Baseball Bat",
	"Stagecoach",
	"Stop Sign",
	"Stretcher",
	"Suitcase Nuke",
	"Surgeon Mask",
	"Unusual Money Printer",
	"USP 45",
	"Uzi",
	"Wallet",
	"Weapon Parts",
	"X-Ray Goggles",
}

local ALL_ITEMS_LOOKUP = {}
for _, item in pairs(ALL_ITEMS) do
	ALL_ITEMS_LOOKUP[item:lower()] = item
end

local EXTRA_NAMES = {
	["money printer"] = "Money Printer",
	["money printers"] = "Money Printer",
	["moneyprinter"] = "Money Printer",
	["unusual money printer"] = "Unusual Money Printer",
	["unusualmoneyprinter"] = "Unusual Money Printer",
	["kunai"] = "Kunai",
	["kunais"] = "Kunai",
	["military key card"] = "Military Key Card",
	["military keycard"] = "Military Keycard",
	["military armory keycard"] = "Military Keycard",
	["militarykeycard"] = "Military Keycard",
	["police key card"] = "Police Key Card",
	["police keycard"] = "Police Keycard",
	["police armory keycard"] = "Police Keycard",
	["policekeycard"] = "Police Keycard",
	["clover balloon"] = "Clover Balloon",
	["golden clover balloon"] = "Golden Clover Balloon",
	["money balloon"] = "Money Balloon",
	["heart balloon"] = "Heart Balloon",
	["dollar balloon"] = "Dollar Balloon",
	["gold ak-47"] = "Gold AK-47",
	["gold ak47"] = "Gold AK-47",
	["gold deagle"] = "Gold Deagle",
	["golden deagle"] = "Gold Deagle",
	["green firework"] = "Green Firework",
	["pink firework"] = "Pink Firework",
	["july 4th firework"] = "July 4th Firework",
	["july4th firework"] = "July 4th Firework",
	["diamond glock"] = "Diamond Glock",
	["diamond taco"] = "Diamond Taco",
	["candy cane"] = "Candy Cane",
	["blue candy cane"] = "Blue Candy Cane",
	["mustang keys"] = "Mustang Keys",
	["helicopter keys"] = "Helicopter Keys",
	["cruiser keys"] = "Cruiser Keys",
	["airdrop marker"] = "Airdrop Marker",
	["airdrop"] = "Airdrop",
	["suitcase nuke"] = "Suitcase Nuke",
	["nuke launcher"] = "Nuke Launcher",
	["double barrel"] = "Double Barrel",
	["double barrel shotgun"] = "Double Barrel",
	["sawn off"] = "Sawn Off",
	["sawn-off"] = "Sawn Off",
	["sawnoff"] = "Sawn Off",
	["frag grenade"] = "Frag Grenade",
	["smoke grenade"] = "Smoke Grenade",
	["spiked baseball bat"] = "Spiked Baseball Bat",
	["baseball bat"] = "Baseball Bat",
	["light vest"] = "Light Vest",
	["heavy vest"] = "Heavy Vest",
	["medium vest"] = "Medium Vest",
	["military vest"] = "Military Vest",
	["slot machine"] = "Slot Machine",
	["cash register"] = "Cash Register",
	["grocery cart"] = "Grocery Cart",
	["shopping cart"] = "Shopping Cart",
	["stop sign"] = "Stop Sign",
	["night vision goggles"] = "Night Vision Goggles",
	["xray goggles"] = "X-Ray Goggles",
	["x-ray goggles"] = "X-Ray Goggles",
	["xraygoggles"] = "X-Ray Goggles",
	["spectral scythe"] = "Spectral Scythe",
	["gold lucky block"] = "Gold Lucky Block",
	["green lucky block"] = "Green Lucky Block",
	["orange lucky block"] = "Orange Lucky Block",
	["purple lucky block"] = "Purple Lucky Block",
	["red lucky block"] = "Red Lucky Block",
	["large present"] = "Large Present",
	["small present"] = "Small Present",
	["component boxes"] = "Component Boxes",
	["medical supplies"] = "Medical Supplies",
	["weapon parts"] = "Weapon Parts",
	["explosives scrap"] = "Explosives Scrap",
	["brass knuckles"] = "Brass Knuckles",
	["clown mallet"] = "Clown Mallet",
	["meat grinder"] = "Meat Grinder",
	["money gun"] = "Money Gun",
	["gravity gun"] = "Gravity Gun",
	["heavy c4"] = "Heavy C4",
	["bear trap"] = "Bear Trap",
	["beach ball"] = "Beach Ball",
	["choco bunny"] = "Choco Bunny",
	["cotton candy"] = "Cotton Candy",
	["banana peel"] = "Banana Peel",
	["hockey mask"] = "Hockey Mask",
	["surgeon mask"] = "Surgeon Mask",
	["sombrero hat"] = "Sombrero Hat",
	["4th of july hat"] = "4th of July Hat",
	["bloxy cola"] = "Bloxy Cola",
	["roman candle"] = "Roman Candle",
	["firework cake"] = "Firework Cake",
	["firework cone"] = "Firework Cone",
	["firework mortar"] = "Firework Mortar",
	["easter basket"] = "Easter Basket",
	["festive guitar"] = "Festive Guitar",
	["fire extinguisher"] = "Fire Extinguisher",
	["black bandana"] = "Black Bandana",
	["blue bandana"] = "Blue Bandana",
	["red bandana"] = "Red Bandana",
	["blue gloves"] = "Blue Gloves",
	["red gloves"] = "Red Gloves",
	["saiga 12"] = "Saiga 12",
	["m249 saw"] = "M249 SAW",
	["m1 garand"] = "M1 Garand",
	["usp 45"] = "USP 45",
	["glock 18"] = "Glock 18",
	["ak-47"] = "AK-47",
	["ak47"] = "AK-47",
	["ar-15"] = "AR-15",
	["ar15"] = "AR-15",
	["as val"] = "AS VAL",
	["spas-12"] = "SPAS-12",
	["spas12"] = "SPAS-12",
	["m4a1"] = "M4A1",
	["m1911"] = "M1911",
	["barrett m107"] = "Barrett M107",
	["barrett"] = "Barrett M107",
	["atm"] = "ATM",
	["locker"] = "Locker",
	["wallet"] = "Wallet",
	["safes"] = "Safes",
	["gems"] = "Gems",
	["lockpick"] = "Lockpick",
	["sparkler"] = "Sparkler",
	["raygun"] = "Raygun",
	["hoverboard"] = "Hoverboard",
	["skateboard"] = "Skateboard",
	["stagecoach"] = "Stagecoach",
	["megaphone"] = "Megaphone",
	["maraca"] = "Maraca",
	["materials"] = "Materials",
	["electronics"] = "Electronics",
	["drone"] = "Drone",
	["saber"] = "Saber",
	["rifles"] = "Rifles",
	["presents"] = "Presents",
}
for k, v in pairs(EXTRA_NAMES) do
	if not ALL_ITEMS_LOOKUP[k] then ALL_ITEMS_LOOKUP[k] = v end
end

local PriorityLoot = {}
for _, item in pairs(ALL_ITEMS) do
	PriorityLoot[item:lower()] = true
end
for k, _ in pairs(EXTRA_NAMES) do
	PriorityLoot[k] = true
end

local ItemCategories = {
	{name = "🏆 ПРІОРИТЕТ", color = Color3.fromRGB(180, 100, 0), items = {
		"Money Printer","Unusual Money Printer","Money Balloon","Dollar Balloon",
		"Clover Balloon","Golden Clover Balloon","Heart Balloon",
		"Mustang Keys","Helicopter Keys","Cruiser Keys",
		"Military Keycard","Military Key Card","Police Keycard","Police Key Card",
		"Gold AK-47","Gold Deagle","Diamond Glock",
		"Admin AK-47","Admin RPG","Admin Nuke",
		"Suitcase Nuke","Nuke Launcher","Raygun","Barrett M107",
		"Spectral Scythe","SPAS-12","Kunai",
		"Diamond Taco","Airdrop Marker","Airdrop","X-Ray Goggles","Night Vision Goggles",
		"Lockpick","Candy Cane","Blue Candy Cane","Sparkler",
		"Green Firework","Pink Firework","Gems","Safes",
	}},
	{name = "🔫 ЗБРОЯ", color = Color3.fromRGB(160, 30, 30), items = {
		"Acid Gun","AK-47","AR-15","AS VAL","AUG","Baseball Bat","Baton",
		"Brass Knuckles","C4","Clown Mallet","Crowbar","Deagle","Double Barrel",
		"Dragunov","Fire Extinguisher","Fireaxe","Fists","Flamethrower","Flashbang",
		"Frag Grenade","Glock","Glock 18","Gravity Gun","Heavy C4","Katana","Knife",
		"Landmines","M1 Garand","M1911","M249 SAW","M4A1","Meat Grinder","Molotov",
		"Money Gun","Mossberg","MP7","Pepper Spray","Python","Rifles","Riot Shield",
		"RPG","RPK","Saber","Saiga 12","Sawn Off","Smoke Grenade",
		"Spiked Baseball Bat","USP 45","Uzi",
	}},
	{name = "🛡 БРОНЯ/МЕД", color = Color3.fromRGB(0, 100, 160), items = {
		"Bandage","Heavy Vest","Light Vest","Medium Vest","Medkit",
		"Military Vest","Stretcher","Surgeon Mask",
	}},
	{name = "💰 ГРОШІ/КЛЮЧІ", color = Color3.fromRGB(180, 150, 0), items = {
		"ATM","Cash Register","Slot Machine","Wallet",
	}},
	{name = "🍎 ЇЖА", color = Color3.fromRGB(0, 140, 60), items = {
		"Apple","Banana","Banana Peel","Beans","Bloxaide","Bloxy Cola","Burger",
		"Cake","Chicken","Choco Bunny","Chocolates","Coffee","Cookie",
		"Cotton Candy","Donut","Hotdog","Pizza","Rose",
	}},
	{name = "📦 ЯЩИКИ/ПОДАРУНКИ", color = Color3.fromRGB(100, 60, 0), items = {
		"Airstrike","Armored Truck","Component Boxes","Drone",
		"Easter Basket","Locker","Gold Lucky Block","Green Lucky Block","Orange Lucky Block",
		"Purple Lucky Block","Red Lucky Block","Large Present","Presents","Small Present",
	}},
	{name = "🎈 БАЛОНИ/СВЯТО", color = Color3.fromRGB(180, 0, 120), items = {
		"4th of July Hat","Balloon","Basketball","Beach Ball","Bear Trap",
		"Clown","Firework","Firework Cake","Firework Cone","Firework Mortar",
		"Hockey Mask","July 4th Firework","Roman Candle","Sombrero Hat",
	}},
	{name = "👗 ОДЯГ", color = Color3.fromRGB(80, 0, 180), items = {
		"Black Bandana","Blue Bandana","Blue Gloves","Red Bandana","Red Gloves",
	}},
	{name = "🔧 ІНСТРУМЕНТИ", color = Color3.fromRGB(60, 60, 60), items = {
		"Dumbell","Festive Guitar","Flashlight","Grocery Cart","Guitar",
		"Hoverboard","Maraca","Megaphone","Shopping Cart","Sign","Skateboard",
		"Stagecoach","Stop Sign",
	}},
	{name = "⚙️ МАТЕРІАЛИ", color = Color3.fromRGB(40, 80, 40), items = {
		"Electronics","Explosives Scrap","Materials","Medical Supplies","Weapon Parts",
	}},
}

local SAVE_KEY = "MarkiyanProV64_Settings"
local function SaveSettings(config, itemPicker)
	pcall(function()
		local data = {config = {}, itemPicker = {}}
		for k, v in pairs(config) do
			if type(v) == "boolean" or type(v) == "number" or type(v) == "string" then
				data.config[k] = v
			end
		end
		for n, s in pairs(itemPicker) do data.itemPicker[n] = s end
		if writefile then writefile(SAVE_KEY..".json", HttpService:JSONEncode(data)) end
	end)
end
local function LoadSettings()
	local data = nil
	pcall(function()
		if readfile and isfile then
			if isfile(SAVE_KEY..".json") then
				data = HttpService:JSONDecode(readfile(SAVE_KEY..".json"))
			end
		end
	end)
	return data
end

local Config = {
	Farm=false,Speed=false,Heal=false,AimActive=false,
	FPSBoost=false,AntiSeat=false,AntiAFK=false,Fly=false,
	FlySpeedValue=IsMobile and 35 or 50,WalkSpeedValue=IsMobile and 45 or 65,
	ESP=false,Fullbright=false,InfJump=false,Noclip=false,
	Magnet=false,MagnetTarget=nil,ShadowMagnet=false,
	ShadowTarget=nil,ShadowDepth=15,AutoSafe=false,SafeHealth=35,
	SilentAim=false,AimFOV=200,AimSmooth=0.18,AimPart="Head",
	HighJump=false,JumpPowerValue=80,
	MoneyFarm=false, -- НОВИЙ: авто-фарм грошей (CashBundle)
	SC_Aim=IsMobile,SC_Silent=IsMobile,SC_Fly=IsMobile,
	SC_Noclip=IsMobile,SC_Speed=IsMobile,SC_Farm=IsMobile,
	SC_Shadow=IsMobile,SC_HighJump=IsMobile,SC_Safe=false,
	SC_MoneyFarm=IsMobile, -- НОВИЙ shortcut
	_SafeTP=false,FarmRange=900,
}

local ItemPickerState = {}
for _, item in pairs(ALL_ITEMS) do ItemPickerState[item] = true end
for _, cat in pairs(ItemCategories) do
	for _, item in pairs(cat.items) do
		if ItemPickerState[item] == nil then ItemPickerState[item] = true end
	end
end

local Binds = {
	Fly=Enum.KeyCode.V,AimActive=Enum.KeyCode.G,
	Noclip=Enum.KeyCode.X,SilentAim=Enum.KeyCode.B,
	ToggleUI=Enum.KeyCode.M,
}
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

task.spawn(function()
	while task.wait(15) do SaveSettings(Config, ItemPickerState) end
end)

local function Notify(t, x, d) pcall(function() StarterGui:SetCore("SendNotification",{Title=t,Text=x,Duration=d or 2}) end) end
local function GetChar() return lp.Character end
local function GetHum() local c = GetChar(); return c and c:FindFirstChildOfClass("Humanoid") end
local function GetRoot() local c = GetChar(); return c and c:FindFirstChild("HumanoidRootPart") end
local function IsHumAlive() local h = GetHum(); return h and h.Health > 0 end

local function SafeTeleport(pos)
	if not IsHumAlive() then return false end
	local root = GetRoot(); if not root then return false end
	local char = GetChar()
	local ok = pcall(function() char:PivotTo(CFrame.new(pos + Vector3.new(0, 3, 0))) end)
	if not ok then pcall(function() root.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0)) end) end
	return true
end

local function IsTargetAlive(t)
	if not t or not t.Parent then return false end
	local c = t.Character; if not c then return false end
	local h = c:FindFirstChildOfClass("Humanoid")
	return h and h.Health > 0
end

local function IsInsidePlayerCharacter(obj)
	if not obj then return false end
	local current = obj
	while current do
		if current == workspace then return false end
		for _, p in pairs(Players:GetPlayers()) do
			if p.Character and p.Character == current then return true end
		end
		if current:IsA("Model") then
			if current:FindFirstChildOfClass("Humanoid") then return true end
		end
		current = current.Parent
	end
	return false
end

local BLACKLIST_ACTIONS = {
	["open"]=true,["close"]=true,["lock"]=true,["unlock"]=true,
	["enter"]=true,["exit"]=true,["drive"]=true,["ride"]=true,
	["sit"]=true,["get in"]=true,["get out"]=true,["start"]=true,
	["toggle"]=true,["activate"]=true,["push"]=true,["pull"]=true,
	["insert"]=true,["swipe"]=true,["deposit"]=true,["withdraw"]=true,
	["hack"]=true,["crack"]=true,["break"]=true,["smash"]=true,
	["destroy"]=true,["place"]=true,["build"]=true,["craft"]=true,
	["talk"]=true,["speak"]=true,["read"]=true,["press"]=true,
	["manage"]=true,["buy"]=true,["purchase"]=true,["sell"]=true,
	["upgrade"]=true,["repair"]=true,["spawn"]=true,["respawn"]=true,
	["reset"]=true,["turn"]=true,["turn on"]=true,["turn off"]=true,
	["rent"]=true,["claim"]=true,["use"]=true,["interact"]=true,
	["search"]=true,["inspect"]=true,["access"]=true,
}

local BLACKLIST_WORDS = {
	"door","doors","gate","gates","vault","barrier","hatch","entrance",
	"panel","manage","property","apartment","condo","computer","terminal",
	"screen","chair","seat","bench","bed","toilet","sink","shower",
	"npc","shopkeeper","vendor","vehicle","car","truck",
	"rent","house","claim","clan","base","spawn","teleport",
	"atm machine","deposit","withdraw","bank terminal",
	"crafting table","crafting","workbench",
}

local ALLOWED_ACTIONS = {
	["collect"]=true,["grab"]=true,["pick up"]=true,["pickup"]=true,
	["take"]=true,["loot"]=true,["get"]=true,["steal"]=true,
	["pick"]=true,["acquire"]=true,["gather"]=true,["equip"]=true,
	[""]=true,["e"]=true,
}

local function IsItemEnabled(itemName)
	if not itemName then return false end
	if ItemPickerState[itemName] ~= nil then return ItemPickerState[itemName] end
	local exact = ALL_ITEMS_LOOKUP[itemName:lower()]
	if exact and ItemPickerState[exact] ~= nil then return ItemPickerState[exact] end
	local fromExtra = EXTRA_NAMES[itemName:lower()]
	if fromExtra and ItemPickerState[fromExtra] ~= nil then return ItemPickerState[fromExtra] end
	return false
end

local function IsBlacklistedText(text)
	if not text or text == "" then return false end
	local tl = text:lower()
	for _, word in ipairs(BLACKLIST_WORDS) do
		if tl:find(word, 1, true) then return true end
	end
	return false
end

local function FindItemName(parentName, objectText)
	local pLow = (parentName or ""):lower():gsub("^%s+",""):gsub("%s+$","")
	local oLow = (objectText or ""):lower():gsub("^%s+",""):gsub("%s+$","")
	if ALL_ITEMS_LOOKUP[pLow] then return ALL_ITEMS_LOOKUP[pLow] end
	if oLow ~= "" and ALL_ITEMS_LOOKUP[oLow] then return ALL_ITEMS_LOOKUP[oLow] end
	return nil
end

local function IsActionAllowed(actionText)
	local al = (actionText or ""):lower():gsub("^%s+",""):gsub("%s+$","")
	if ALLOWED_ACTIONS[al] then return true end
	if BLACKLIST_ACTIONS[al] then return false end
	for act in pairs(ALLOWED_ACTIONS) do
		if act ~= "" and act ~= "e" and al:find(act, 1, true) then return true end
	end
	return false
end

local function QuickCheckPrompt(prompt)
	if not prompt or not prompt.Parent then return false, nil end
	local en = false
	pcall(function() en = prompt.Enabled end)
	if not en then return false, nil end
	local kbKey = nil
	pcall(function() kbKey = prompt.KeyboardKeyCode end)
	if kbKey == Enum.KeyCode.F then return false, nil end
	local par = prompt.Parent
	if not par then return false, nil end
	local parentName = ""
	pcall(function() parentName = par.Name or "" end)
	local actionText = ""
	pcall(function() actionText = (prompt.ActionText or "") end)
	local objectText = ""
	pcall(function() objectText = (prompt.ObjectText or "") end)
	local aLow = actionText:lower():gsub("^%s+",""):gsub("%s+$","")
	local pLow = parentName:lower():gsub("^%s+",""):gsub("%s+$","")
	if BLACKLIST_ACTIONS[aLow] then return false, nil end
	if IsBlacklistedText(pLow) then return false, nil end
	if IsBlacklistedText(aLow) then return false, nil end
	local parentBlacklisted = false
	pcall(function()
		if par.Parent then
			if par.Parent:FindFirstChildOfClass("Humanoid") then parentBlacklisted = true end
		end
	end)
	if parentBlacklisted then return false, nil end
	if IsInsidePlayerCharacter(par) then return false, nil end
	local matchedItem = FindItemName(parentName, objectText)
	if not matchedItem then return false, nil end
	if not IsItemEnabled(matchedItem) then return false, nil end
	if not IsActionAllowed(aLow) then return false, nil end
	return true, matchedItem
end

local function GetPromptPosition(prompt)
	local pos = nil
	pcall(function()
		local par = prompt.Parent
		if par then
			if par:IsA("BasePart") then pos = par.Position
			elseif par:IsA("Model") then pos = par:GetPivot().Position
			else
				local pp = par:FindFirstChildWhichIsA("BasePart")
				if pp then pos = pp.Position end
			end
		end
	end)
	return pos
end

local function SafeFirePrompt(prompt)
	if not prompt or not prompt.Parent then return false end
	local kbKey = nil
	pcall(function() kbKey = prompt.KeyboardKeyCode end)
	if kbKey == Enum.KeyCode.F then return false end
	if fireproximityprompt then
		local ok = pcall(fireproximityprompt, prompt)
		if ok then return true end
	end
	local holdTime = 0
	pcall(function() holdTime = math.max(prompt.HoldDuration or 0, 0) end)
	if holdTime > 0 then
		pcall(function()
			prompt:InputHoldBegin()
			task.wait(holdTime + 0.1)
			prompt:InputHoldEnd()
		end)
	else
		pcall(function()
			prompt:InputHoldBegin()
			task.wait(0.05)
			prompt:InputHoldEnd()
		end)
	end
	return true
end

-- ============================================================
-- CASH BUNDLE FARM — окрема функція збору грошей з карти
-- Телепортується до кожного CashBundle, стрибає/рухається
-- щоб підібрати (бо просто ТП не завжди зараховує підбір)
-- ============================================================
local moneyFarmRunning = false
local moneyFarmStats = {collected = 0, total = 0}

-- Знаходить всі CashBundle у workspace (пробує кілька шляхів)
local function GetAllCashBundles()
	local bundles = {}
	-- Стандартний шлях
	local entitiesFolder = workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Entities")
	if entitiesFolder then
		local cashBundleFolder = entitiesFolder:FindFirstChild("CashBundle")
		if cashBundleFolder then
			for _, bundle in ipairs(cashBundleFolder:GetChildren()) do
				table.insert(bundles, bundle)
			end
		end
	end
	-- Якщо не знайшло — шукаємо по всьому workspace
	if #bundles == 0 then
		for _, obj in pairs(workspace:GetDescendants()) do
			if obj.Name == "CashBundle" or obj.Name == "Cash" or obj.Name == "MoneyBundle" then
				if obj:IsA("Model") or obj:IsA("BasePart") then
					table.insert(bundles, obj)
				end
			end
		end
	end
	return bundles
end

-- Отримує позицію бандла (моделі або парта)
local function GetBundlePosition(bundle)
	if not bundle or not bundle.Parent then return nil end
	if bundle:IsA("BasePart") then return bundle.Position end
	if bundle:IsA("Model") then
		local primary = bundle.PrimaryPart
		if primary then return primary.Position end
		local firstPart = bundle:FindFirstChildWhichIsA("BasePart")
		if firstPart then return firstPart.Position end
	end
	return nil
end

-- Основна функція підбору одного бандла:
-- телепортується, потім стрибає і трохи рухається щоб підібрати
local function CollectOneCashBundle(bundle)
	if not bundle or not bundle.Parent then return false end
	local pos = GetBundlePosition(bundle)
	if not pos then return false end
	local root = GetRoot()
	if not root then return false end
	-- Телепортуємось прямо на бандл
	local ok = pcall(function()
		local char = GetChar()
		if char then
			char:PivotTo(CFrame.new(pos + Vector3.new(0, 2.5, 0)))
		else
			root.CFrame = CFrame.new(pos + Vector3.new(0, 2.5, 0))
		end
	end)
	if not ok then
		pcall(function() root.CFrame = CFrame.new(pos + Vector3.new(0, 2.5, 0)) end)
	end
	task.wait(0.08)
	-- Перевіряємо чи бандл ще існує після ТП
	if not bundle.Parent then return true end -- вже підібрано
	-- Стрибаємо — це допомагає підібрати через ClickDetector/TouchInterest
	local hum = GetHum()
	if hum then
		pcall(function()
			hum:ChangeState(Enum.HumanoidStateType.Jumping)
		end)
	end
	task.wait(0.08)
	-- Додатково рухаємось на кілька сантиметрів у різні сторони
	-- щоб touch event спрацював якщо потрібен
	if not bundle.Parent then return true end
	local offsets = {
		Vector3.new(0.4, 0, 0),
		Vector3.new(-0.4, 0, 0),
		Vector3.new(0, 0, 0.4),
		Vector3.new(0, 0, -0.4),
		Vector3.new(0, -0.5, 0),
	}
	for _, offset in ipairs(offsets) do
		if not bundle.Parent then break end
		if not IsHumAlive() then break end
		pcall(function()
			root = GetRoot()
			if root then root.CFrame = CFrame.new(pos + offset + Vector3.new(0, 2.5, 0)) end
		end)
		task.wait(0.05)
	end
	-- Якщо є ClickDetector — спрацьовуємо його
	if bundle.Parent then
		pcall(function()
			for _, child in ipairs(bundle:GetDescendants()) do
				if child:IsA("ClickDetector") then
					if fireclickdetector then
						fireclickdetector(child)
					end
				end
			end
		end)
	end
	task.wait(0.05)
	return true
end

-- Головний цикл фарму грошей
task.spawn(function()
	while true do
		task.wait(0.1)
		if not Config.MoneyFarm then
			moneyFarmRunning = false
			task.wait(0.5)
			continue
		end
		if not IsHumAlive() then
			task.wait(1)
			continue
		end
		moneyFarmRunning = true
		local bundles = GetAllCashBundles()
		if #bundles == 0 then
			-- Немає грошей — чекаємо
			task.wait(2)
			continue
		end
		moneyFarmStats.total = #bundles
		-- Сортуємо по відстані щоб збирати найближчі перші
		local root = GetRoot()
		if root then
			table.sort(bundles, function(a, b)
				local posA = GetBundlePosition(a)
				local posB = GetBundlePosition(b)
				if not posA then return false end
				if not posB then return true end
				return (root.Position - posA).Magnitude < (root.Position - posB).Magnitude
			end)
		end
		for _, bundle in ipairs(bundles) do
			if not Config.MoneyFarm then break end
			if not IsHumAlive() then break end
			if not bundle.Parent then continue end -- вже підібрано кимось
			local collected = CollectOneCashBundle(bundle)
			if collected then
				moneyFarmStats.collected = moneyFarmStats.collected + 1
			end
			task.wait(0.05)
		end
		moneyFarmRunning = false
		-- Невелика пауза перед наступним циклом
		task.wait(1.5)
	end
end)

-- ============================================================
-- AIM SYSTEM
-- ============================================================
local aimTarget = nil
local aimLocked = false
local aimLastSwitch = 0
local aimSwitchCD = 0.8
local aimLostFrames = 0
local aimLostMax = 60
local lastPing = 0
local pingTick = 0
local shadowSavedPos = nil
local aimHasLockedOnce = false

local function FindAimPart(char)
	if not char then return nil end
	local name = Config.AimPart or "Head"
	local p = char:FindFirstChild(name)
	if p and p:IsA("BasePart") then return p end
	p = char:FindFirstChild("Head")
	if p and p:IsA("BasePart") then return p end
	p = char:FindFirstChild("HumanoidRootPart")
	if p and p:IsA("BasePart") then return p end
	return nil
end

local function ScreenDist(part)
	if not part then return math.huge end
	local pos, on = Camera:WorldToViewportPoint(part.Position)
	if not on then return math.huge end
	local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
	return (Vector2.new(pos.X, pos.Y) - center).Magnitude
end

local function IsVisible(part)
	if not part then return false end
	local origin = Camera.CFrame.Position
	local direction = part.Position - origin
	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	local excludeList = {}
	for _, p in pairs(Players:GetPlayers()) do
		if p.Character then table.insert(excludeList, p.Character) end
	end
	local myChar = GetChar()
	if myChar then table.insert(excludeList, myChar) end
	rayParams.FilterDescendantsInstances = excludeList
	local result = workspace:Raycast(origin, direction, rayParams)
	if not result then return true end
	local hitDist = (result.Position - origin).Magnitude
	local targetDist = direction.Magnitude
	return hitDist >= targetDist - 2
end

local function FindNewTarget()
	local fov = Config.AimFOV
	local best, bestDist = nil, math.huge
	for _, p in pairs(Players:GetPlayers()) do
		if p == lp then continue end
		local char = p.Character; if not char then continue end
		local h = char:FindFirstChildOfClass("Humanoid")
		if not h or h.Health <= 0 then continue end
		local part = FindAimPart(char); if not part then continue end
		if not IsVisible(part) then continue end
		local sd = ScreenDist(part)
		if sd > fov then continue end
		if sd < bestDist then bestDist = sd; best = p end
	end
	return best
end

local function GetBestAimTarget()
	local now = tick()
	if aimTarget and aimLocked then
		local char = aimTarget.Character
		if char then
			local h = char:FindFirstChildOfClass("Humanoid")
			if h and h.Health > 0 then
				local part = FindAimPart(char)
				if part then
					local sd = ScreenDist(part)
					if sd <= Config.AimFOV * 2.5 then
						aimLostFrames = 0
						return char
					end
					aimLostFrames = aimLostFrames + 1
					if aimLostFrames < aimLostMax then return char end
				end
			end
		end
		aimTarget = nil; aimLocked = false; aimLostFrames = 0
		aimHasLockedOnce = true
		return nil
	end
	if aimHasLockedOnce then return nil end
	if now - aimLastSwitch < aimSwitchCD then return nil end
	local best = FindNewTarget()
	if best then
		aimTarget = best; aimLocked = true; aimLostFrames = 0; aimLastSwitch = now
		aimHasLockedOnce = true
		return best.Character
	end
	return nil
end

local function GetClosestByDist()
	local root = GetRoot(); if not root then return nil end
	local best, bestD = nil, math.huge
	for _, v in pairs(Players:GetPlayers()) do
		if v == lp or not IsTargetAlive(v) then continue end
		local h = v.Character and v.Character:FindFirstChild("HumanoidRootPart")
		if h then
			local d = (h.Position - root.Position).Magnitude
			if d < bestD then bestD = d; best = v end
		end
	end
	return best
end

local Controls = nil
task.spawn(function()
	if not game:IsLoaded() then game.Loaded:Wait() end
	task.wait(1)
	pcall(function()
		Controls = require(lp:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule", 5)):GetControls()
	end)
end)

local MobUp, MobDn = false, false

local isShooting = false
local shootTouches = {}
local silentOrigCF = nil
local silentActive = false
local prevShooting = false

UIS.TouchStarted:Connect(function(inp, gpe)
	if gpe then return end
	shootTouches[inp] = true; isShooting = true
end)
UIS.TouchEnded:Connect(function(inp)
	shootTouches[inp] = nil; isShooting = (next(shootTouches) ~= nil)
end)

local function StartSilentAim()
	if silentActive or not Config.SilentAim then return end
	local tc = GetBestAimTarget(); if not tc then return end
	local head = FindAimPart(tc); if not head then return end
	silentActive = true; silentOrigCF = Camera.CFrame
	local vel = Vector3.zero
	pcall(function() vel = head.AssemblyLinearVelocity end)
	local predPos = head.Position + vel * math.clamp(lastPing, 0.01, 0.08)
	Camera.CFrame = CFrame.new(Camera.CFrame.Position, predPos)
end

local function StopSilentAim()
	if not silentActive then return end
	silentActive = false
	if silentOrigCF then Camera.CFrame = silentOrigCF; silentOrigCF = nil end
end

RS.RenderStepped:Connect(function()
	if not Config.SilentAim then
		if silentActive then StopSilentAim() end; return
	end
	local shooting = IsPC and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or isShooting
	if shooting and not prevShooting then StartSilentAim()
	elseif not shooting and prevShooting then StopSilentAim()
	elseif shooting and silentActive then
		local tc = GetBestAimTarget()
		if tc then
			local head = FindAimPart(tc)
			if head then
				local vel = Vector3.zero
				pcall(function() vel = head.AssemblyLinearVelocity end)
				local predPos = head.Position + vel * math.clamp(lastPing, 0.01, 0.08)
				Camera.CFrame = CFrame.new(Camera.CFrame.Position, predPos)
			end
		end
	end
	prevShooting = shooting
end)

local fpsApplied = false
local function ApplyFPS()
	if fpsApplied then return end; fpsApplied = true
	pcall(function() settings().Rendering.QualityLevel = 1; Light.GlobalShadows = false; Light.FogEnd = 9e9 end)
	for _, v in pairs(Light:GetChildren()) do
		pcall(function()
			if v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("DepthOfFieldEffect") or v:IsA("ColorCorrectionEffect") then v.Enabled = false end
		end)
	end
	task.spawn(function()
		for _, v in pairs(workspace:GetDescendants()) do
			pcall(function()
				if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then v.Enabled = false end
			end)
		end
	end)
end

local sL = {}
local function EnableFB()
	pcall(function()
		sL.B = Light.Brightness; sL.C = Light.ClockTime; sL.F = Light.FogEnd
		sL.A = Light.Ambient; sL.O = Light.OutdoorAmbient; sL.G = Light.GlobalShadows
		Light.Brightness = 2; Light.ClockTime = 14; Light.FogEnd = 100000
		Light.Ambient = Color3.fromRGB(178, 178, 178)
		Light.OutdoorAmbient = Color3.fromRGB(178, 178, 178)
		Light.GlobalShadows = false
	end)
	for _, v in pairs(Light:GetChildren()) do
		pcall(function() if v:IsA("Atmosphere") then v.Density = 0; v.Offset = 0 end end)
	end
end
local function DisableFB()
	pcall(function()
		if sL.B then Light.Brightness = sL.B; Light.ClockTime = sL.C; Light.FogEnd = sL.F; Light.Ambient = sL.A; Light.OutdoorAmbient = sL.O; Light.GlobalShadows = sL.G end
	end)
end

local healCD = 0
task.spawn(function()
	while task.wait(IsMobile and 1.5 or 0.8) do
		if not IsHumAlive() or tick() - healCD < 2 then continue end
		local hum, char = GetHum(), GetChar()
		if not hum or not char then continue end
		if Config.Heal and hum.Health < hum.MaxHealth * 0.75 then
			local found = nil
			local healKW = {"medkit","bandage","firstaid","aid","heal","health"}
			for _, item in pairs(lp.Backpack:GetChildren()) do
				if not item:IsA("Tool") then continue end
				local n = item.Name:lower()
				for _, k in pairs(healKW) do if n:find(k, 1, true) then found = item; break end end
				if found then break end
			end
			if not found then
				for _, item in pairs(char:GetChildren()) do
					if not item:IsA("Tool") then continue end
					local n = item.Name:lower()
					for _, k in pairs(healKW) do if n:find(k, 1, true) then found = item; break end end
					if found then break end
				end
			end
			if found then
				pcall(function()
					if found.Parent == lp.Backpack then hum:EquipTool(found); task.wait(0.25) end
					local t = char:FindFirstChild(found.Name)
					if t then t:Activate() end
				end)
				task.wait(0.7)
				pcall(function() hum:UnequipTools() end)
				healCD = tick()
			end
		end
	end
end)

lp.Idled:Connect(function()
	if Config.AntiAFK then pcall(function() VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new()) end) end
end)
task.spawn(function()
	while task.wait(50) do
		if Config.AntiAFK then pcall(function() VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new()) end) end
	end
end)

local robRunning = false
local function StartRobbery()
	if robRunning then robRunning = false; Notify("ROB","Stopping...",2); return end
	robRunning = true
	task.spawn(function()
		for cycle = 1, 10 do
			if not robRunning then break end
			Notify("ROB","Цикл "..cycle.."/10",2)
			for w = 1, 10 do if IsHumAlive() then break end; task.wait(1) end
			if not IsHumAlive() then task.wait(3); continue end
			SafeTeleport(COORDS.BANK_MONEY); task.wait(1.5)
			local collected = 0; local startTime = tick()
			while tick() - startTime < 10 do
				if not robRunning or not IsHumAlive() then break end
				local root = GetRoot(); if not root then break end
				local foundAny = false
				for _, v in pairs(workspace:GetDescendants()) do
					if not robRunning or not IsHumAlive() then break end
					if not v:IsA("ProximityPrompt") or not v.Enabled then continue end
					local par = v.Parent; if not par then continue end
					local at = (v.ActionText or ""):lower()
					local pn = (par.Name or ""):lower()
					local ft = pn.." "..at
					local ok = false
					if ft:find("steal", 1, true) or ft:find("rob", 1, true) then ok = true end
					if ft:find("grab", 1, true) and ft:find("money", 1, true) then ok = true end
					if ft:find("collect", 1, true) and ft:find("money", 1, true) then ok = true end
					if pn:find("money", 1, true) and not pn:find("money gun", 1, true) and not pn:find("money printer", 1, true) then ok = true end
					if pn:find("cash", 1, true) and not pn:find("cash register", 1, true) then ok = true end
					if not ok then continue end
					local pos = Vector3.zero
					pcall(function() pos = par:GetPivot().Position end)
					if pos.Magnitude < 1 then continue end
					if (root.Position - pos).Magnitude < 30 then
						pcall(function() root.CFrame = CFrame.new(pos + Vector3.new(0, 1, 0)) end)
						task.wait(0.1); SafeFirePrompt(v); collected = collected + 1; foundAny = true; task.wait(0.15)
					end
				end
				if not foundAny then task.wait(0.5) end; task.wait(0.1)
			end
			if IsHumAlive() then SafeTeleport(COORDS.SAFE_ZONE); Notify("ROB","Цикл "..cycle.." done ("..collected..")",2) end
			if cycle < 10 and robRunning then for w = 1, 10 do if not robRunning then break end; task.wait(1) end end
		end
		robRunning = false; Notify("ROB","Завершено!",4)
	end)
end

local ESPCache = {}
local function ClearESP(c)
	if not c then return end
	pcall(function()
		local h = c:FindFirstChild("Head")
		if h then local g = h:FindFirstChild("MrkESP"); if g then g:Destroy() end end
		local hl = c:FindFirstChild("MrkHL"); if hl then hl:Destroy() end
	end)
end
local function ClearAllESP()
	for _, v in pairs(Players:GetPlayers()) do if v ~= lp then ClearESP(v.Character) end end
	ESPCache = {}
end

task.spawn(function()
	while task.wait(IsMobile and 0.2 or 0.08) do
		if not Config.ESP then continue end
		local myR = GetRoot()
		for _, v in pairs(Players:GetPlayers()) do
			if v == lp then continue end
			local char = v.Character
			local head = char and char:FindFirstChild("Head")
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			if not char or not head or not hum or hum.Health <= 0 then
				if ESPCache[v] then ClearESP(char); ESPCache[v] = nil end; continue
			end
			local cache = ESPCache[v]
			if not cache or not cache.gui or not cache.gui.Parent then
				if cache then ClearESP(char) end
				local gui = Instance.new("BillboardGui"); gui.Name = "MrkESP"
				gui.Size = UDim2.new(0, IsMobile and 150 or 185, 0, IsMobile and 42 or 50)
				gui.StudsOffset = Vector3.new(0, 3.2, 0); gui.AlwaysOnTop = true
				gui.MaxDistance = IsMobile and 250 or 450; gui.Parent = head
				local bg = Instance.new("Frame", gui); bg.Size = UDim2.new(1, 0, 1, 0)
				bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0); bg.BackgroundTransparency = 0.45; bg.BorderSizePixel = 0
				Instance.new("UICorner", bg)
				local lbl = Instance.new("TextLabel", bg); lbl.Name = "L"; lbl.Size = UDim2.new(1, 0, 1, 0)
				lbl.BackgroundTransparency = 1; lbl.Font = Enum.Font.GothamBold
				lbl.TextSize = IsMobile and 10 or 12; lbl.TextWrapped = true; lbl.TextStrokeTransparency = 0.3
				pcall(function()
					local hl = Instance.new("Highlight"); hl.Name = "MrkHL"; hl.FillColor = Color3.new(1, 0, 0)
					hl.OutlineColor = Color3.new(1, 1, 1); hl.FillTransparency = 0.65
					hl.OutlineTransparency = 0; hl.Adornee = char; hl.Parent = char
				end)
				ESPCache[v] = {gui = gui, lbl = lbl}; cache = ESPCache[v]
			end
			local dist = myR and math.floor((myR.Position - head.Position).Magnitude) or 0
			local hp = math.floor(hum.Health); local mH = math.max(math.floor(hum.MaxHealth), 1)
			local r = hp / mH
			cache.lbl.Text = string.format("[%s]\nHP:%d/%d | %dm", v.Name, hp, mH, dist)
			cache.lbl.TextColor3 = r >= 0.6 and Color3.fromRGB(0, 255, 100) or r >= 0.3 and Color3.fromRGB(255, 220, 0) or Color3.fromRGB(255, 60, 60)
		end
	end
end)

Players.PlayerRemoving:Connect(function(p) if ESPCache[p] then ClearESP(p.Character); ESPCache[p] = nil end end)
for _, p in pairs(Players:GetPlayers()) do
	if p ~= lp then p.CharacterRemoving:Connect(function(c) if ESPCache[p] then ClearESP(c); ESPCache[p] = nil end end) end
end
Players.PlayerAdded:Connect(function(p) p.CharacterRemoving:Connect(function(c) if ESPCache[p] then ClearESP(c); ESPCache[p] = nil end end) end)

local function RestoreCollision()
	local c = GetChar(); if not c then return end
	for _, v in pairs(c:GetDescendants()) do
		if v:IsA("BasePart") then pcall(function() v.CanCollide = true end) end
	end
	local root = GetRoot()
	if root then task.wait(0.05); pcall(function() root.CFrame = root.CFrame + Vector3.new(0, 2, 0); root.AssemblyLinearVelocity = Vector3.zero end) end
end

local farmRunning = false
local farmStats = {collected = 0, skipped = 0, lastItem = ""}

task.spawn(function()
	local failedPrompts = {}
	local FAIL_TIMEOUT = 4
	while true do
		task.wait(0.05)
		if not Config.Farm then
			farmRunning = false
			failedPrompts = {}
			task.wait(0.5)
			continue
		end
		if not IsHumAlive() then task.wait(1); continue end
		farmRunning = true
		local root = GetRoot()
		if not root then task.wait(0.5); continue end
		local priorityList = {}
		local normalList = {}
		local now = tick()
		for k, t in pairs(failedPrompts) do
			if now - t > FAIL_TIMEOUT then failedPrompts[k] = nil end
		end
		for _, v in pairs(workspace:GetDescendants()) do
			if not v:IsA("ProximityPrompt") then continue end
			local uid = tostring(v)
			if failedPrompts[uid] then continue end
			local ok, matchedItem = QuickCheckPrompt(v)
			if not ok or not matchedItem then continue end
			local pos = GetPromptPosition(v)
			if not pos then continue end
			local dist = (root.Position - pos).Magnitude
			if dist > (Config.FarmRange or 900) then continue end
			local entry = {prompt = v, name = matchedItem, pos = pos, dist = dist, uid = uid}
			if PriorityLoot[matchedItem:lower()] then
				table.insert(priorityList, entry)
			else
				table.insert(normalList, entry)
			end
		end
		table.sort(priorityList, function(a, b) return a.dist < b.dist end)
		table.sort(normalList, function(a, b) return a.dist < b.dist end)
		local allEntries = {}
		for _, e in ipairs(priorityList) do table.insert(allEntries, e) end
		for _, e in ipairs(normalList) do table.insert(allEntries, e) end
		if #allEntries == 0 then task.wait(0.5); continue end
		for _, entry in ipairs(allEntries) do
			if not Config.Farm or not IsHumAlive() then break end
			local prompt = entry.prompt
			if not prompt or not prompt.Parent then continue end
			local stillOk, _ = QuickCheckPrompt(prompt)
			if not stillOk then continue end
			local myRoot = GetRoot()
			if not myRoot then break end
			local pos = entry.pos
			local dist = (myRoot.Position - pos).Magnitude
			if dist > 12 then
				SafeTeleport(pos)
				task.wait(0.15)
			else
				pcall(function() myRoot.CFrame = CFrame.new(pos + Vector3.new(0, 1, 0)) end)
				task.wait(0.05)
			end
			if not Config.Farm or not IsHumAlive() then break end
			if not prompt or not prompt.Parent then continue end
			local okAfterMove, _ = QuickCheckPrompt(prompt)
			if not okAfterMove then failedPrompts[entry.uid] = tick(); continue end
			local holdTime = 0
			pcall(function() holdTime = prompt.HoldDuration or 0 end)
			if holdTime > 3 then
				failedPrompts[entry.uid] = tick()
				farmStats.skipped = farmStats.skipped + 1
				continue
			end
			local collected = false
			local attemptDone = false
			task.spawn(function()
				local fireOk = SafeFirePrompt(prompt)
				if fireOk then
					collected = true
					farmStats.collected = farmStats.collected + 1
					farmStats.lastItem = entry.name
				else
					failedPrompts[entry.uid] = tick()
					farmStats.skipped = farmStats.skipped + 1
				end
				attemptDone = true
			end)
			local maxWait = math.max(holdTime + 0.5, 0.3)
			local waited = 0
			local step = 0.05
			while not attemptDone and waited < maxWait do
				task.wait(step)
				waited = waited + step
				if not Config.Farm or not IsHumAlive() then break end
			end
			if not attemptDone then
				failedPrompts[entry.uid] = tick()
				farmStats.skipped = farmStats.skipped + 1
			end
			task.wait(0.05)
		end
		farmRunning = false
		task.wait(0.1)
	end
end)

RS.RenderStepped:Connect(function(dt)
	local now = tick()
	if now - pingTick > 3 then pingTick = now; pcall(function() lastPing = lp:GetNetworkPing() end) end
	if Config.Fly and IsHumAlive() then
		local root, hum = GetRoot(), GetHum()
		if root and hum then
			hum.PlatformStand = false
			local mx, mz = 0, 0
			if IsMobile and Controls then local mv = Controls:GetMoveVector(); mx = mv.X; mz = mv.Z
			elseif IsPC then
				if UIS:IsKeyDown(Enum.KeyCode.W) then mz = -1 end
				if UIS:IsKeyDown(Enum.KeyCode.S) then mz = 1 end
				if UIS:IsKeyDown(Enum.KeyCode.A) then mx = -1 end
				if UIS:IsKeyDown(Enum.KeyCode.D) then mx = 1 end
			end
			local cf = Camera.CFrame
			local dir = cf.LookVector * -mz + cf.RightVector * mx
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

pcall(function() RS:UnbindFromRenderStep("MrkAim") end)
RS:BindToRenderStep("MrkAim", 2000, function()
	if Config.AimActive then
		local target = GetBestAimTarget()
		local part = target and FindAimPart(target)
		if part then
			local predTime = math.clamp(lastPing, 0.01, 0.12)
			local vel = Vector3.zero
			pcall(function() vel = part.AssemblyLinearVelocity end)
			local horizVel = Vector3.new(vel.X, 0, vel.Z)
			local predPos = part.Position + horizVel * predTime
			local smooth = Config.AimSmooth
			local sd = ScreenDist(part)
			if sd < 30 then smooth = smooth * 0.25
			elseif sd < 80 then smooth = smooth * 0.5 end
			Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, predPos), smooth)
		end
	else
		aimTarget = nil; aimLocked = false; aimLostFrames = 0; aimHasLockedOnce = false
	end
end)

RS.Heartbeat:Connect(function(dt)
	local hum, root = GetHum(), GetRoot()
	if not hum or not root then return end
	if Config.AntiSeat and hum.SeatPart then pcall(function() hum.Sit = false end) end
	if Config.Speed and not Config.Fly and IsHumAlive() then
		if hum.WalkSpeed ~= Config.WalkSpeedValue then hum.WalkSpeed = Config.WalkSpeedValue end
	elseif not Config.Fly and not Config.Speed then
		if hum.WalkSpeed ~= 16 then hum.WalkSpeed = 16 end
	end
	if not Config.Fly and hum.PlatformStand then pcall(function() hum.PlatformStand = false end) end
	if Config.HighJump and IsHumAlive() then
		pcall(function() hum.UseJumpPower = true; if hum.JumpPower ~= Config.JumpPowerValue then hum.JumpPower = Config.JumpPowerValue end end)
	elseif not Config.HighJump and IsHumAlive() then
		pcall(function() hum.UseJumpPower = true; if hum.JumpPower ~= 50 then hum.JumpPower = 50 end end)
	end
	if Config.Noclip or Config.ShadowMagnet then
		local c = GetChar()
		if c then for _, v in pairs(c:GetDescendants()) do if v:IsA("BasePart") then pcall(function() v.CanCollide = false end) end end end
	end
	if Config.ShadowMagnet then
		if not shadowSavedPos then shadowSavedPos = root.Position end
		if not IsTargetAlive(Config.ShadowTarget) then Config.ShadowTarget = GetClosestByDist() end
		if Config.ShadowTarget and IsTargetAlive(Config.ShadowTarget) then
			local tChar = Config.ShadowTarget.Character
			local tR = tChar and tChar:FindFirstChild("HumanoidRootPart")
			if tR then
				local depth = Config.ShadowDepth or 15
				local targetPos = tR.Position - Vector3.new(0, depth, 0)
				local lookDir = tR.CFrame.LookVector
				local flatLook = Vector3.new(lookDir.X, 0, lookDir.Z)
				if flatLook.Magnitude < 0.1 then flatLook = Vector3.new(1, 0, 0) end
				flatLook = flatLook.Unit
				local lyingCF = CFrame.new(targetPos, targetPos + flatLook) * CFrame.Angles(math.rad(90), 0, 0)
				pcall(function()
					root.CFrame = lyingCF
					root.AssemblyLinearVelocity = tR.AssemblyLinearVelocity
					root.AssemblyAngularVelocity = Vector3.zero
				end)
			end
		end
	else
		if shadowSavedPos then
			pcall(function()
				if IsHumAlive() then
					local char = GetChar()
					if char then for _, v in pairs(char:GetDescendants()) do if v:IsA("BasePart") then pcall(function() v.CanCollide = true end) end end end
					root.CFrame = CFrame.new(shadowSavedPos + Vector3.new(0, 3, 0))
					root.AssemblyLinearVelocity = Vector3.zero; root.AssemblyAngularVelocity = Vector3.zero
				end
			end)
			shadowSavedPos = nil; Config.ShadowTarget = nil
		end
	end
	if Config.Magnet and not Config.ShadowMagnet then
		if not IsTargetAlive(Config.MagnetTarget) then Config.MagnetTarget = GetClosestByDist() end
		if Config.MagnetTarget then
			local tH = Config.MagnetTarget.Character and Config.MagnetTarget.Character:FindFirstChild("HumanoidRootPart")
			if tH then pcall(function() root.CFrame = root.CFrame:Lerp(tH.CFrame * CFrame.new(0, 0, 3), IsMobile and 0.15 or 0.22); root.AssemblyLinearVelocity = tH.AssemblyLinearVelocity end) end
		end
	elseif not Config.ShadowMagnet then Config.MagnetTarget = nil end
	if Config.AutoSafe and not Config.Farm and IsHumAlive() and hum.Health <= Config.SafeHealth then
		if (root.Position - COORDS.SAFE_ZONE).Magnitude > 20 then SafeTeleport(COORDS.SAFE_ZONE) end
	end
end)

UIS.JumpRequest:Connect(function()
	if not Config.InfJump then return end
	local h = GetHum(); if not h then return end
	pcall(function() h:ChangeState(Enum.HumanoidStateType.Jumping) end)
end)

local UpdFuncs = {}

lp.CharacterRemoving:Connect(function(char)
	shadowSavedPos = nil; aimTarget = nil; aimLocked = false; aimLostFrames = 0; aimHasLockedOnce = false
	silentActive = false; silentOrigCF = nil
	pcall(function() for _, v in pairs(char:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = true end end end)
end)

lp.CharacterAdded:Connect(function(char)
	shadowSavedPos = nil; aimTarget = nil; aimLocked = false; aimLostFrames = 0; aimHasLockedOnce = false
	silentActive = false; silentOrigCF = nil
	task.wait(1)
	local h = char:FindFirstChildOfClass("Humanoid")
	if h then pcall(function() h.PlatformStand = false; h.UseJumpPower = true; h.WalkSpeed = Config.Speed and Config.WalkSpeedValue or 16; h.JumpPower = Config.HighJump and Config.JumpPowerValue or 50 end) end
	task.wait(0.1)
	for k, fn in pairs(UpdFuncs) do pcall(function() fn(Config[k]) end) end
	if UpdateFlyBtns_ then UpdateFlyBtns_() end
end)

-- ============================================================
-- GUI
-- ============================================================
local SG = Instance.new("ScreenGui")
SG.Name = "MarkiyanPro"; SG.ResetOnSpawn = false
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; SG.IgnoreGuiInset = true
pcall(function() SG.Parent = game:GetService("CoreGui") end)
if not SG.Parent or not SG.Parent.Name then SG.Parent = lp:WaitForChild("PlayerGui") end

local screenSize = SG.AbsoluteSize
local isSmallScreen = IsMobile and (screenSize.Y < 700 or screenSize.X < 400)

local MW, MH
if isSmallScreen then MW = 240; MH = 400
elseif IsMobile then MW = 300; MH = 560
else MW = 420; MH = 660 end

local Main = Instance.new("Frame", SG)
Main.Size = UDim2.new(0, MW, 0, MH); Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.Position = UDim2.new(0.5, 0, 0.5, 0); Main.BackgroundColor3 = Color3.fromRGB(8, 8, 14)
Main.BorderSizePixel = 0; Main.Visible = false
Instance.new("UICorner", Main)
local mainStroke = Instance.new("UIStroke", Main); mainStroke.Color = Color3.fromRGB(0, 120, 255); mainStroke.Thickness = 1.5

local headerTextSize = isSmallScreen and 11 or (IsMobile and 13 or 15)
local tabTextSize = isSmallScreen and 8 or (IsMobile and 9 or 11)
local btnTextSize = isSmallScreen and 10 or (IsMobile and 12 or 13)
local categoryTextSize = isSmallScreen and 9 or (IsMobile and 10 or 11)
local sliderTextSize = isSmallScreen and 10 or 12
local itemTextSize = isSmallScreen and 9 or (IsMobile and 10 or 11)

local headerH = isSmallScreen and 36 or 44
local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, headerH); Header.BackgroundColor3 = Color3.fromRGB(10, 10, 20); Header.BorderSizePixel = 0
Instance.new("UICorner", Header)
local hGrad = Instance.new("UIGradient", Header)
hGrad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 50, 180)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 130, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 50, 180))})

local HL = Instance.new("TextLabel", Header)
HL.Size = UDim2.new(1, -55, 1, 0); HL.Position = UDim2.new(0, 10, 0, 0)
HL.BackgroundTransparency = 1; HL.TextColor3 = Color3.new(1, 1, 1)
HL.Font = Enum.Font.GothamBlack; HL.TextSize = headerTextSize
HL.TextXAlignment = Enum.TextXAlignment.Left
HL.Text = "⚡MarkiyanPro V64"..(IsMobile and " [📱]" or "")

local closeSize = isSmallScreen and 24 or 30
local CB = Instance.new("TextButton", Header)
CB.Size = UDim2.new(0, closeSize, 0, closeSize); CB.Position = UDim2.new(1, -(closeSize + 6), 0, (headerH - closeSize) / 2)
CB.BackgroundColor3 = Color3.fromRGB(180, 30, 30); CB.Text = "✕"
CB.TextColor3 = Color3.new(1, 1, 1); CB.Font = Enum.Font.GothamBold
CB.TextSize = isSmallScreen and 12 or 14; CB.BorderSizePixel = 0; CB.ZIndex = 5
Instance.new("UICorner", CB).CornerRadius = UDim.new(0, 6)
CB.MouseButton1Click:Connect(function() Main.Visible = false end)

local tabBarH = isSmallScreen and 24 or 30
local TabBar = Instance.new("Frame", Main)
TabBar.Size = UDim2.new(1, -8, 0, tabBarH); TabBar.Position = UDim2.new(0, 4, 0, headerH + 4)
TabBar.BackgroundColor3 = Color3.fromRGB(12, 12, 20); TabBar.BorderSizePixel = 0
Instance.new("UICorner", TabBar)
local TL = Instance.new("UIListLayout", TabBar); TL.FillDirection = Enum.FillDirection.Horizontal
TL.HorizontalAlignment = Enum.HorizontalAlignment.Center; TL.VerticalAlignment = Enum.VerticalAlignment.Center; TL.Padding = UDim.new(0, 2)

local scrollTop = headerH + tabBarH + 12
local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1, -8, 1, -(scrollTop + 4)); Scroll.Position = UDim2.new(0, 4, 0, scrollTop)
Scroll.BackgroundTransparency = 1; Scroll.BorderSizePixel = 0; Scroll.ClipsDescendants = true
Scroll.ScrollBarThickness = IsMobile and 7 or 3; Scroll.ScrollBarImageColor3 = Color3.fromRGB(0, 120, 255)
Scroll.ScrollingDirection = Enum.ScrollingDirection.Y; Scroll.ElasticBehavior = Enum.ElasticBehavior.Always
Scroll.TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
Scroll.BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"

local LL = Instance.new("UIListLayout", Scroll); LL.Padding = UDim.new(0, isSmallScreen and 3 or 4); LL.HorizontalAlignment = Enum.HorizontalAlignment.Center
local scrollPad = Instance.new("UIPadding", Scroll); scrollPad.PaddingTop = UDim.new(0, 4); scrollPad.PaddingBottom = UDim.new(0, 4)
LL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Scroll.CanvasSize = UDim2.new(0, 0, 0, LL.AbsoluteContentSize.Y + 20) end)

local fovC = Instance.new("Frame", SG)
fovC.Size = UDim2.new(0, Config.AimFOV * 2, 0, Config.AimFOV * 2)
fovC.Position = UDim2.new(0.5, -Config.AimFOV, 0.5, -Config.AimFOV)
fovC.BackgroundTransparency = 1; fovC.BorderSizePixel = 0; fovC.Visible = false; fovC.ZIndex = 10
Instance.new("UICorner", fovC).CornerRadius = UDim.new(1, 0)
local fS = Instance.new("UIStroke", fovC); fS.Color = Color3.fromRGB(0, 120, 255); fS.Thickness = 1.5; fS.Transparency = 0.3

local tI = Instance.new("TextLabel", SG)
tI.Size = UDim2.new(0, isSmallScreen and 180 or 220, 0, isSmallScreen and 20 or 24)
tI.Position = UDim2.new(0.5, isSmallScreen and -90 or -110, 0.5, -(Config.AimFOV + (isSmallScreen and 28 or 34)))
tI.BackgroundColor3 = Color3.fromRGB(10, 10, 16); tI.BackgroundTransparency = 0.25
tI.BorderSizePixel = 0; tI.TextColor3 = Color3.fromRGB(0, 200, 100)
tI.Font = Enum.Font.GothamBold; tI.TextSize = isSmallScreen and 9 or 11; tI.Text = ""; tI.Visible = false; tI.ZIndex = 12
Instance.new("UICorner", tI); Instance.new("UIStroke", tI).Color = Color3.fromRGB(40, 40, 58)

-- Статус лейбл для фарму грошей (показується на екрані)
local moneyFarmStatusLabel = Instance.new("TextLabel", SG)
moneyFarmStatusLabel.Size = UDim2.new(0, isSmallScreen and 220 or 280, 0, isSmallScreen and 22 or 26)
moneyFarmStatusLabel.Position = UDim2.new(0.5, isSmallScreen and -110 or -140, 0, isSmallScreen and 40 or 50)
moneyFarmStatusLabel.BackgroundColor3 = Color3.fromRGB(10, 40, 10)
moneyFarmStatusLabel.BackgroundTransparency = 0.2
moneyFarmStatusLabel.BorderSizePixel = 0
moneyFarmStatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
moneyFarmStatusLabel.Font = Enum.Font.GothamBold
moneyFarmStatusLabel.TextSize = isSmallScreen and 9 or 11
moneyFarmStatusLabel.Text = ""
moneyFarmStatusLabel.Visible = false
moneyFarmStatusLabel.ZIndex = 15
Instance.new("UICorner", moneyFarmStatusLabel)
Instance.new("UIStroke", moneyFarmStatusLabel).Color = Color3.fromRGB(0, 150, 0)

-- Оновлення статус-лейблу фарму грошей
task.spawn(function()
	while task.wait(0.5) do
		if Config.MoneyFarm then
			local bundles = GetAllCashBundles()
			moneyFarmStatusLabel.Visible = true
			moneyFarmStatusLabel.Text = string.format(
				"💰 MONEY FARM | Зібрано: %d | Бандлів: %d",
				moneyFarmStats.collected,
				#bundles
			)
		else
			moneyFarmStatusLabel.Visible = false
		end
	end
end)

local function UpdateFOV()
	local r = Config.AimFOV
	fovC.Size = UDim2.new(0, r * 2, 0, r * 2); fovC.Position = UDim2.new(0.5, -r, 0.5, -r)
	tI.Position = UDim2.new(0.5, isSmallScreen and -90 or -110, 0.5, -(r + (isSmallScreen and 28 or 34)))
end

local fUT = 0
RS.RenderStepped:Connect(function()
	local now = tick(); if now - fUT < 0.05 then return end; fUT = now
	fovC.Visible = Config.AimActive or Config.SilentAim; tI.Visible = false
	if Config.AimActive then
		local tc = aimTarget and aimTarget.Character; local p = tc and FindAimPart(tc)
		if p and aimLocked then
			local plr = Players:GetPlayerFromCharacter(tc)
			local dist = math.floor((Camera.CFrame.Position - p.Position).Magnitude)
			tI.Text = "🔒 "..(plr and plr.Name or "?").." ["..dist.."m]"
			tI.TextColor3 = Color3.fromRGB(0, 230, 120); tI.Visible = true; fS.Color = Color3.fromRGB(0, 200, 100)
		else
			tI.Text = "No target (toggle to re-lock)"; tI.Visible = true; fS.Color = Color3.fromRGB(100, 100, 180)
		end
	elseif Config.SilentAim then
		local tc = aimTarget and aimTarget.Character; local p = tc and FindAimPart(tc)
		if p then
			local plr = Players:GetPlayerFromCharacter(tc)
			local dist = math.floor((Camera.CFrame.Position - p.Position).Magnitude)
			tI.Text = "🔇 "..(plr and plr.Name or "?").." ["..dist.."m]"
			tI.TextColor3 = Color3.fromRGB(255, 200, 50); tI.Visible = true; fS.Color = Color3.fromRGB(255, 200, 50)
		else tI.Text = "No target"; tI.Visible = true; fS.Color = Color3.fromRGB(100, 100, 180) end
	end
end)

local flyBtnSize = isSmallScreen and 48 or 60
local flyH = Instance.new("Frame", SG)
flyH.Size = UDim2.new(0, flyBtnSize * 2 + 16, 0, flyBtnSize)
flyH.Position = UDim2.new(0, 10, 1, -(flyBtnSize + 120))
flyH.BackgroundTransparency = 1; flyH.Visible = false; flyH.ZIndex = 50

local function MkFB(l, x, cb)
	local b = Instance.new("TextButton", flyH); b.Size = UDim2.new(0, flyBtnSize, 0, flyBtnSize); b.Position = UDim2.new(0, x, 0, 0)
	b.BackgroundColor3 = Color3.fromRGB(12, 12, 18); b.Text = l; b.TextColor3 = Color3.new(1, 1, 1)
	b.Font = Enum.Font.GothamBlack; b.TextSize = isSmallScreen and 22 or 28; b.BorderSizePixel = 0; b.ZIndex = 51; b.AutoButtonColor = false
	Instance.new("UICorner", b); Instance.new("UIStroke", b).Color = Color3.fromRGB(40, 40, 58)
	b.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then cb(true); b.BackgroundColor3 = Color3.fromRGB(32, 32, 52) end end)
	b.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then cb(false); b.BackgroundColor3 = Color3.fromRGB(12, 12, 18) end end)
end
MkFB("▲", 0, function(v) MobUp = v end); MkFB("▼", flyBtnSize + 12, function(v) MobDn = v end)
local function UpdateFlyBtns() flyH.Visible = Config.Fly and IsMobile end
UpdateFlyBtns_ = UpdateFlyBtns

local scBtnSize = isSmallScreen and 40 or 52
local scBtnW = isSmallScreen and 44 or 56
local scHolder = Instance.new("Frame", SG); scHolder.Size = UDim2.new(0, scBtnW, 0, 580)
scHolder.Position = UDim2.new(1, -(scBtnW + 6), 0.10, 0); scHolder.BackgroundTransparency = 1; scHolder.BorderSizePixel = 0; scHolder.ZIndex = 90
local scLayout = Instance.new("UIListLayout", scHolder); scLayout.Padding = UDim.new(0, isSmallScreen and 3 or 5); scLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local ShortcutBtns = {}
local ShortcutDefs = {
	{key = "AimActive", label = "AIM", scKey = "SC_Aim", color = Color3.fromRGB(220, 50, 50)},
	{key = "SilentAim", label = "SIL", scKey = "SC_Silent", color = Color3.fromRGB(200, 150, 0)},
	{key = "Fly", label = "FLY", scKey = "SC_Fly", color = Color3.fromRGB(0, 100, 220)},
	{key = "Noclip", label = "NC", scKey = "SC_Noclip", color = Color3.fromRGB(0, 160, 100)},
	{key = "Speed", label = "SPD", scKey = "SC_Speed", color = Color3.fromRGB(100, 180, 0)},
	{key = "Farm", label = "FRM", scKey = "SC_Farm", color = Color3.fromRGB(200, 120, 0)},
	{key = "ShadowMagnet", label = "SHD", scKey = "SC_Shadow", color = Color3.fromRGB(80, 0, 160)},
	{key = "HighJump", label = "HJP", scKey = "SC_HighJump", color = Color3.fromRGB(0, 180, 180)},
	{key = "_SafeTP", label = "SAFE", scKey = "SC_Safe", color = Color3.fromRGB(0, 120, 60)},
	-- НОВИЙ: кнопка фарму грошей
	{key = "MoneyFarm", label = "💰", scKey = "SC_MoneyFarm", color = Color3.fromRGB(180, 140, 0)},
}

for _, def in ipairs(ShortcutDefs) do
	local btn = Instance.new("TextButton", scHolder); btn.Size = UDim2.new(0, scBtnSize, 0, isSmallScreen and 34 or 42)
	btn.BackgroundColor3 = Color3.fromRGB(20, 20, 30); btn.TextColor3 = Color3.fromRGB(180, 180, 190)
	btn.Font = Enum.Font.GothamBlack; btn.TextSize = isSmallScreen and 9 or (IsMobile and 11 or 10); btn.Text = def.label
	btn.BorderSizePixel = 0; btn.AutoButtonColor = false; btn.ZIndex = 91; btn.Visible = Config[def.scKey] or false
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
	local stroke = Instance.new("UIStroke", btn); stroke.Color = Color3.fromRGB(40, 40, 58); stroke.Thickness = 1
	local function UpdateSC()
		local on = (def.key ~= "_SafeTP") and Config[def.key]
		if on then btn.BackgroundColor3 = def.color; btn.TextColor3 = Color3.new(1, 1, 1); stroke.Color = Color3.new(1, 1, 1)
		else btn.BackgroundColor3 = Color3.fromRGB(20, 20, 30); btn.TextColor3 = Color3.fromRGB(150, 150, 160); stroke.Color = Color3.fromRGB(40, 40, 58) end
		btn.Visible = Config[def.scKey] or false
	end
	if def.key == "_SafeTP" then
		btn.MouseButton1Click:Connect(function() if SafeTeleport(COORDS.SAFE_ZONE) then Notify("TP", "➜ Safe Zone", 2) end end)
	else
		btn.MouseButton1Click:Connect(function()
			Config[def.key] = not Config[def.key]; UpdateSC()
			if def.key == "Fly" then UpdateFlyBtns() end
			if def.key == "AimActive" then aimTarget = nil; aimLocked = false; aimLostFrames = 0; aimHasLockedOnce = not Config.AimActive end
			if def.key == "Noclip" and not Config.Noclip then RestoreCollision() end
			if def.key == "ShadowMagnet" then if Config.ShadowMagnet then shadowSavedPos = nil else Config.ShadowTarget = nil end end
			if def.key == "ESP" and not Config.ESP then ClearAllESP() end
			if def.key == "Speed" and not Config.Speed then local h = GetHum(); if h then h.WalkSpeed = 16 end end
			if def.key == "HighJump" then local h = GetHum(); if h then h.UseJumpPower = true; h.JumpPower = Config.HighJump and Config.JumpPowerValue or 50 end end
			if def.key == "SilentAim" and not Config.SilentAim then StopSilentAim() end
			if def.key == "MoneyFarm" then
				moneyFarmStats.collected = 0
				Notify("💰 MONEY FARM", Config.MoneyFarm and "ON — Збираємо гроші!" or "OFF", 2)
			end
			if UpdFuncs[def.key] then UpdFuncs[def.key](Config[def.key]) end
			SaveSettings(Config, ItemPickerState)
		end)
	end
	ShortcutBtns[def.key] = {btn = btn, update = UpdateSC, def = def}; UpdateSC()
end

local function UpdateAllShortcuts() for _, sc in pairs(ShortcutBtns) do sc.update() end end

local Sections, TabButtons, ActiveTab = {}, {}, nil
local tabNames = {"Combat", "Move", "Misc", "Items", "Binds"}
local tabW = isSmallScreen and 38 or (IsMobile and 48 or 64)
local tabBtnH = isSmallScreen and 20 or 24

for _, n in pairs(tabNames) do
	Sections[n] = {}
	local b = Instance.new("TextButton", TabBar); b.Size = UDim2.new(0, tabW, 0, tabBtnH)
	b.BackgroundColor3 = Color3.fromRGB(18, 18, 30); b.TextColor3 = Color3.fromRGB(150, 150, 170)
	b.Font = Enum.Font.GothamBold; b.TextSize = tabTextSize; b.Text = n
	b.BorderSizePixel = 0; b.AutoButtonColor = false; Instance.new("UICorner", b); TabButtons[n] = b
end

do
	local d, s, p = false, nil, nil
	Header.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then d = true; s = i.Position; p = Main.Position end end)
	Header.InputChanged:Connect(function(i) if not d then return end; if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then local dl = i.Position - s; Main.Position = UDim2.new(p.X.Scale, p.X.Offset + dl.X, p.Y.Scale, p.Y.Offset + dl.Y) end end)
	Header.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then d = false end end)
	UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then d = false end end)
end

local BtnH = isSmallScreen and 34 or (IsMobile and 42 or 34)

local function MakeFrame(tab)
	local f = Instance.new("Frame", Scroll); f.Size = UDim2.new(0.97, 0, 0, BtnH)
	f.BackgroundTransparency = 1; f.BorderSizePixel = 0; f.Visible = false
	table.insert(Sections[tab], f); return f
end

local function AddCategory(tab, text)
	local catH = isSmallScreen and 18 or 22
	local f = Instance.new("Frame", Scroll); f.Size = UDim2.new(0.97, 0, 0, catH)
	f.BackgroundColor3 = Color3.fromRGB(0, 55, 155); f.BorderSizePixel = 0; f.Visible = false
	Instance.new("UICorner", f)
	local l = Instance.new("TextLabel", f); l.Size = UDim2.new(1, 0, 1, 0); l.BackgroundTransparency = 1
	l.TextColor3 = Color3.new(1, 1, 1); l.Font = Enum.Font.GothamBold; l.TextSize = categoryTextSize
	l.Text = "── "..text.." ──"
	table.insert(Sections[tab], f)
end

local function AddToggle(tab, name, key, cbOn, cbOff)
	local f = MakeFrame(tab)
	local btn = Instance.new("TextButton", f); btn.Size = UDim2.new(1, 0, 1, 0)
	btn.BackgroundColor3 = Color3.fromRGB(20, 20, 30); btn.TextColor3 = Color3.fromRGB(190, 190, 200)
	btn.Font = Enum.Font.GothamBold; btn.TextSize = btnTextSize
	btn.BorderSizePixel = 0; btn.AutoButtonColor = false; btn.TextXAlignment = Enum.TextXAlignment.Left
	btn.Text = "      "..name..": OFF"; Instance.new("UICorner", btn)
	local dotSize = isSmallScreen and 7 or 9
	local dot = Instance.new("Frame", btn); dot.Size = UDim2.new(0, dotSize, 0, dotSize); dot.AnchorPoint = Vector2.new(0, 0.5)
	dot.Position = UDim2.new(0, isSmallScreen and 6 or 10, 0.5, 0); dot.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	dot.BorderSizePixel = 0; dot.ZIndex = btn.ZIndex + 1; Instance.new("UICorner", dot)
	local function Upd(s)
		if s then btn.BackgroundColor3 = Color3.fromRGB(0, 70, 190); btn.TextColor3 = Color3.new(1, 1, 1); dot.BackgroundColor3 = Color3.fromRGB(0, 220, 80); btn.Text = "      "..name..": ON"
		else btn.BackgroundColor3 = Color3.fromRGB(20, 20, 30); btn.TextColor3 = Color3.fromRGB(190, 190, 200); dot.BackgroundColor3 = Color3.fromRGB(200, 50, 50); btn.Text = "      "..name..": OFF" end
		if ShortcutBtns[key] then ShortcutBtns[key].update() end
	end
	UpdFuncs[key] = Upd; if Config[key] then Upd(true) end
	btn.MouseButton1Click:Connect(function()
		Config[key] = not Config[key]; Upd(Config[key])
		if Config[key] then if cbOn then task.spawn(cbOn) end else if cbOff then task.spawn(cbOff) end end
		if key == "Fly" then UpdateFlyBtns() end
		if key == "AimActive" then aimTarget = nil; aimLocked = false; aimLostFrames = 0; aimHasLockedOnce = not Config.AimActive end
		if key == "ESP" and not Config[key] then ClearAllESP() end
		if key == "ShadowMagnet" then if Config.ShadowMagnet then shadowSavedPos = nil else Config.ShadowTarget = nil end end
		if key == "Noclip" and not Config.Noclip then RestoreCollision() end
		if key == "SilentAim" and not Config.SilentAim then StopSilentAim() end
		if key == "MoneyFarm" then
			moneyFarmStats.collected = 0
			Notify("💰 MONEY FARM", Config.MoneyFarm and "ON — Збираємо гроші!" or "OFF", 2)
		end
		SaveSettings(Config, ItemPickerState); Notify(name, Config[key] and "ON ✓" or "OFF ✗", 1.5)
	end)
	return Upd
end

local function AddSlider(tab, label, minV, maxV, def, cKey, cb)
	local sliderH = isSmallScreen and 46 or (IsMobile and 56 or 54)
	local f = Instance.new("Frame", Scroll); f.Size = UDim2.new(0.97, 0, 0, sliderH)
	f.BackgroundColor3 = Color3.fromRGB(16, 16, 24); f.BorderSizePixel = 0; f.Visible = false
	Instance.new("UICorner", f); table.insert(Sections[tab], f)
	local cv = Config[cKey] or def
	local lbl = Instance.new("TextLabel", f); lbl.Size = UDim2.new(1, -8, 0, isSmallScreen and 18 or 22); lbl.Position = UDim2.new(0, 4, 0, 2)
	lbl.BackgroundTransparency = 1; lbl.TextColor3 = Color3.fromRGB(200, 200, 210)
	lbl.Font = Enum.Font.GothamBold; lbl.TextSize = sliderTextSize; lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Text = label..": "..cv
	local trackH = isSmallScreen and 12 or (IsMobile and 14 or 10)
	local trackY = isSmallScreen and 28 or (IsMobile and 36 or 36)
	local tr = Instance.new("Frame", f); tr.Size = UDim2.new(0.92, 0, 0, trackH)
	tr.Position = UDim2.new(0.04, 0, 0, trackY)
	tr.BackgroundColor3 = Color3.fromRGB(35, 35, 50); tr.BorderSizePixel = 0; Instance.new("UICorner", tr)
	local iR = math.clamp((cv - minV) / (maxV - minV), 0, 1)
	local fl = Instance.new("Frame", tr); fl.Size = UDim2.new(iR, 0, 1, 0)
	fl.BackgroundColor3 = Color3.fromRGB(0, 100, 255); fl.BorderSizePixel = 0; Instance.new("UICorner", fl)
	local kS = isSmallScreen and 18 or (IsMobile and 22 or 14)
	local kn = Instance.new("Frame", tr); kn.Size = UDim2.new(0, kS, 0, kS)
	kn.Position = UDim2.new(iR, -kS / 2, 0.5, -kS / 2); kn.BackgroundColor3 = Color3.new(1, 1, 1); kn.BorderSizePixel = 0
	Instance.new("UICorner", kn)
	local dg = false
	local function US(inp)
		local rel = math.clamp((inp.Position.X - tr.AbsolutePosition.X) / tr.AbsoluteSize.X, 0, 1)
		local val = math.floor(minV + rel * (maxV - minV))
		fl.Size = UDim2.new(rel, 0, 1, 0); kn.Position = UDim2.new(rel, -kS / 2, 0.5, -kS / 2)
		lbl.Text = label..": "..val; Config[cKey] = val; if cb then cb(val) end
	end
	tr.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dg = true; US(i) end end)
	UIS.InputChanged:Connect(function(i) if not dg then return end; if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then US(i) end end)
	UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dg = false; SaveSettings(Config, ItemPickerState) end end)
end

local function AddAction(tab, name, color, cb)
	local f = MakeFrame(tab)
	local btn = Instance.new("TextButton", f); btn.Size = UDim2.new(1, 0, 1, 0); btn.BackgroundColor3 = color
	btn.TextColor3 = Color3.new(1, 1, 1); btn.Font = Enum.Font.GothamBold; btn.TextSize = btnTextSize
	btn.BorderSizePixel = 0; btn.AutoButtonColor = false; btn.Text = name; Instance.new("UICorner", btn)
	btn.MouseButton1Click:Connect(function() task.spawn(cb) end)
end

local function AddTP(tab, name, vec)
	local f = MakeFrame(tab)
	local btn = Instance.new("TextButton", f); btn.Size = UDim2.new(1, 0, 1, 0)
	btn.BackgroundColor3 = Color3.fromRGB(18, 18, 32); btn.TextColor3 = Color3.fromRGB(255, 215, 0)
	btn.Font = Enum.Font.GothamBold; btn.TextSize = isSmallScreen and 10 or (IsMobile and 12 or 12)
	btn.BorderSizePixel = 0; btn.AutoButtonColor = false; btn.Text = "📍 "..name; Instance.new("UICorner", btn)
	btn.MouseButton1Click:Connect(function() if SafeTeleport(vec) then Notify("TP", "➜ "..name, 2) end end)
end

AddCategory("Combat", "AIMING")
AddToggle("Combat", "AIM LOCK", "AimActive",
	function() aimTarget = nil; aimLocked = false; aimLostFrames = 0; aimLastSwitch = 0; aimHasLockedOnce = false end,
	function() aimTarget = nil; aimLocked = false; aimLostFrames = 0; aimHasLockedOnce = false end)
AddToggle("Combat", "SILENT AIM", "SilentAim", nil, function() StopSilentAim() end)
AddToggle("Combat", "ESP", "ESP", nil, function() ClearAllESP() end)
AddCategory("Combat", "MAGNET")
AddToggle("Combat", "MAGNET", "Magnet", nil, function() Config.MagnetTarget = nil end)
AddToggle("Combat", "👻 SHADOW MAGNET", "ShadowMagnet", function() shadowSavedPos = nil end, function() Config.ShadowTarget = nil end)
AddSlider("Combat", "Shadow Depth", 5, 40, Config.ShadowDepth, "ShadowDepth")
AddCategory("Combat", "AIM CONFIG")
AddSlider("Combat", "FOV", 50, 500, Config.AimFOV, "AimFOV", function(v) Config.AimFOV = v; UpdateFOV() end)
AddSlider("Combat", "Smooth(x100)", 5, 100, math.floor(Config.AimSmooth * 100), "AimSmooth", function(v) Config.AimSmooth = v / 100 end)

AddCategory("Move", "MOVEMENT")
AddToggle("Move", "FLY", "Fly", function() UpdateFlyBtns() end, function() UpdateFlyBtns(); local h = GetHum(); if h then h.PlatformStand = false; h.WalkSpeed = 16 end end)
AddSlider("Move", "FLY SPEED", 10, IsPC and 250 or 150, Config.FlySpeedValue, "FlySpeedValue")
AddToggle("Move", "SPEED", "Speed", nil, function() local h = GetHum(); if h then h.WalkSpeed = 16 end end)
AddSlider("Move", "WALK SPEED", 16, IsPC and 150 or 100, Config.WalkSpeedValue, "WalkSpeedValue")
AddToggle("Move", "NOCLIP", "Noclip", nil, function() RestoreCollision() end)
AddToggle("Move", "INF JUMP", "InfJump")
AddToggle("Move", "HIGH JUMP", "HighJump",
	function() local h = GetHum(); if h then h.UseJumpPower = true; h.JumpPower = Config.JumpPowerValue end end,
	function() local h = GetHum(); if h then h.UseJumpPower = true; h.JumpPower = 50 end end)
AddSlider("Move", "JUMP POWER", 50, 300, Config.JumpPowerValue, "JumpPowerValue", function(v) if Config.HighJump then local h = GetHum(); if h then h.UseJumpPower = true; h.JumpPower = v end end end)
AddCategory("Move", "TELEPORTS")
AddTP("Move", "GUN SHOP", COORDS.GUN_SHOP)
AddTP("Move", "BANK", COORDS.BANK_ENT)
AddTP("Move", "SAFE ZONE", COORDS.SAFE_ZONE)

AddCategory("Misc", "SURVIVAL")
AddToggle("Misc", "AUTO SAFE", "AutoSafe")
AddToggle("Misc", "AUTO HEAL", "Heal")
AddCategory("Misc", "FARM & VISUALS")
AddToggle("Misc", "AUTO FARM", "Farm")
AddSlider("Misc", "FARM RANGE", 50, 2000, Config.FarmRange or 900, "FarmRange")
-- НОВИЙ ТОГЛ: фарм грошей
AddCategory("Misc", "💰 MONEY FARM")
AddToggle("Misc", "💰 AUTO MONEY FARM", "MoneyFarm",
	function()
		moneyFarmStats.collected = 0
		Notify("💰 MONEY FARM", "ON — Збираємо CashBundle!", 3)
	end,
	function()
		Notify("💰 MONEY FARM", "OFF", 2)
	end
)
-- Кнопка одноразового збору всіх грошей
AddAction("Misc", "💰 COLLECT ALL MONEY NOW", Color3.fromRGB(140, 110, 0), function()
	if not IsHumAlive() then Notify("💰", "Ти мертвий!", 2); return end
	Notify("💰 COLLECT", "Збираємо всі гроші...", 3)
	local bundles = GetAllCashBundles()
	local count = 0
	for _, bundle in ipairs(bundles) do
		if not IsHumAlive() then break end
		if not bundle.Parent then continue end
		CollectOneCashBundle(bundle)
		count = count + 1
		task.wait(0.05)
	end
	Notify("💰 COLLECT", "Зібрано "..count.." бандлів!", 3)
end)
AddToggle("Misc", "FULLBRIGHT", "Fullbright", function() EnableFB() end, function() DisableFB() end)
AddToggle("Misc", "FPS BOOST", "FPSBoost", function() ApplyFPS() end)
AddCategory("Misc", "UTILITIES")
AddToggle("Misc", "ANTI-SEAT", "AntiSeat")
AddToggle("Misc", "ANTI-AFK", "AntiAFK")
AddCategory("Misc", "ACTIONS")
AddAction("Misc", "🏦 ROB BANK (10x)", Color3.fromRGB(150, 20, 20), StartRobbery)

local iTotalLabel = Instance.new("Frame", Scroll)
iTotalLabel.Size = UDim2.new(0.97, 0, 0, isSmallScreen and 22 or 28)
iTotalLabel.BackgroundColor3 = Color3.fromRGB(0, 60, 130); iTotalLabel.BorderSizePixel = 0; iTotalLabel.Visible = false
Instance.new("UICorner", iTotalLabel); table.insert(Sections["Items"], iTotalLabel)
local iTL = Instance.new("TextLabel", iTotalLabel); iTL.Size = UDim2.new(1, 0, 1, 0); iTL.BackgroundTransparency = 1
iTL.TextColor3 = Color3.new(1, 1, 1); iTL.Font = Enum.Font.GothamBold; iTL.TextSize = isSmallScreen and 8 or (IsMobile and 10 or 11)
iTL.Text = "📦 ITEM PICKER — "..#ALL_ITEMS.." предметів | ⭐=пріоритет"

local farmStatsLabel = Instance.new("Frame", Scroll)
farmStatsLabel.Size = UDim2.new(0.97, 0, 0, isSmallScreen and 20 or 24)
farmStatsLabel.BackgroundColor3 = Color3.fromRGB(30, 60, 0); farmStatsLabel.BorderSizePixel = 0; farmStatsLabel.Visible = false
Instance.new("UICorner", farmStatsLabel); table.insert(Sections["Items"], farmStatsLabel)
local fSL = Instance.new("TextLabel", farmStatsLabel); fSL.Size = UDim2.new(1, 0, 1, 0); fSL.BackgroundTransparency = 1
fSL.TextColor3 = Color3.fromRGB(150, 255, 150); fSL.Font = Enum.Font.Gotham; fSL.TextSize = isSmallScreen and 8 or 10

task.spawn(function()
	while task.wait(2) do
		if ActiveTab == "Items" then
			fSL.Text = string.format("📊 Зібрано: %d | Пропущено: %d | Останній: %s", farmStats.collected, farmStats.skipped, farmStats.lastItem)
		end
	end
end)

local searchH = isSmallScreen and 34 or (IsMobile and 42 or 36)
local searchBtnH = isSmallScreen and 24 or (IsMobile and 30 or 26)
local sFr = Instance.new("Frame", Scroll); sFr.Size = UDim2.new(0.97, 0, 0, searchH)
sFr.BackgroundColor3 = Color3.fromRGB(16, 16, 26); sFr.BorderSizePixel = 0; sFr.Visible = false
Instance.new("UICorner", sFr); table.insert(Sections["Items"], sFr)
local sB = Instance.new("TextBox", sFr); sB.Size = UDim2.new(0.55, -4, 0, searchBtnH)
sB.Position = UDim2.new(0, 6, 0.5, -searchBtnH / 2); sB.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
sB.TextColor3 = Color3.new(1, 1, 1); sB.PlaceholderText = "🔍 пошук..."
sB.PlaceholderColor3 = Color3.fromRGB(100, 100, 130); sB.Font = Enum.Font.Gotham; sB.TextSize = isSmallScreen and 10 or 12
sB.ClearTextOnFocus = false; sB.BorderSizePixel = 0; Instance.new("UICorner", sB)
local eA = Instance.new("TextButton", sFr); eA.Size = UDim2.new(0.21, 0, 0, searchBtnH)
eA.Position = UDim2.new(0.57, 2, 0.5, -searchBtnH / 2); eA.BackgroundColor3 = Color3.fromRGB(0, 120, 50)
eA.TextColor3 = Color3.new(1, 1, 1); eA.Font = Enum.Font.GothamBold; eA.TextSize = isSmallScreen and 8 or 10; eA.Text = "ВСІ✓"; eA.BorderSizePixel = 0
Instance.new("UICorner", eA)
local dAB = Instance.new("TextButton", sFr); dAB.Size = UDim2.new(0.21, 0, 0, searchBtnH)
dAB.Position = UDim2.new(0.79, 2, 0.5, -searchBtnH / 2); dAB.BackgroundColor3 = Color3.fromRGB(150, 30, 30)
dAB.TextColor3 = Color3.new(1, 1, 1); dAB.Font = Enum.Font.GothamBold; dAB.TextSize = isSmallScreen and 8 or 10; dAB.Text = "ВСІ✗"; dAB.BorderSizePixel = 0
Instance.new("UICorner", dAB)

local itemBtns = {}
local itemH = isSmallScreen and 26 or (IsMobile and 32 or 28)
local catH_menu = isSmallScreen and 26 or (IsMobile and 32 or 28)
local catBtnH = isSmallScreen and 18 or (IsMobile and 22 or 20)

local categorizedItemsSet = {}
for _, cat in ipairs(ItemCategories) do
	for _, item in ipairs(cat.items) do
		categorizedItemsSet[item] = true
	end
end
local otherItems = {}
for _, item in ipairs(ALL_ITEMS) do
	if not categorizedItemsSet[item] then
		table.insert(otherItems, item)
	end
end
if #otherItems > 0 then
	table.insert(ItemCategories, {name = "📋 ІНШЕ", color = Color3.fromRGB(50, 50, 80), items = otherItems})
end

for _, cat in ipairs(ItemCategories) do
	local catF = Instance.new("Frame", Scroll); catF.Size = UDim2.new(0.97, 0, 0, catH_menu)
	catF.BackgroundColor3 = cat.color; catF.BorderSizePixel = 0; catF.Visible = false
	Instance.new("UICorner", catF); table.insert(Sections["Items"], catF)
	local catLbl = Instance.new("TextLabel", catF); catLbl.Size = UDim2.new(0.75, 0, 1, 0); catLbl.Position = UDim2.new(0, 8, 0, 0)
	catLbl.BackgroundTransparency = 1; catLbl.TextColor3 = Color3.new(1, 1, 1)
	catLbl.Font = Enum.Font.GothamBold; catLbl.TextSize = isSmallScreen and 8 or (IsMobile and 10 or 11); catLbl.TextXAlignment = Enum.TextXAlignment.Left
	catLbl.Text = cat.name.." ("..#cat.items..")"
	local catOn = Instance.new("TextButton", catF); catOn.Size = UDim2.new(0.11, 0, 0, catBtnH)
	catOn.Position = UDim2.new(0.76, 0, 0.5, -catBtnH / 2); catOn.BackgroundColor3 = Color3.fromRGB(0, 100, 40)
	catOn.TextColor3 = Color3.new(1, 1, 1); catOn.Font = Enum.Font.GothamBold; catOn.TextSize = isSmallScreen and 8 or 9; catOn.Text = "✓"; catOn.BorderSizePixel = 0
	Instance.new("UICorner", catOn)
	local catOff = Instance.new("TextButton", catF); catOff.Size = UDim2.new(0.11, 0, 0, catBtnH)
	catOff.Position = UDim2.new(0.88, 0, 0.5, -catBtnH / 2); catOff.BackgroundColor3 = Color3.fromRGB(120, 20, 20)
	catOff.TextColor3 = Color3.new(1, 1, 1); catOff.Font = Enum.Font.GothamBold; catOff.TextSize = isSmallScreen and 8 or 9; catOff.Text = "✗"; catOff.BorderSizePixel = 0
	Instance.new("UICorner", catOff)
	local catItemBtns = {}
	for _, iN in ipairs(cat.items) do
		if ItemPickerState[iN] == nil then ItemPickerState[iN] = true end
		local f = Instance.new("Frame", Scroll); f.Size = UDim2.new(0.97, 0, 0, itemH)
		f.BackgroundTransparency = 1; f.BorderSizePixel = 0; f.Visible = false
		table.insert(Sections["Items"], f)
		local b = Instance.new("TextButton", f); b.Size = UDim2.new(1, 0, 1, 0)
		b.Font = Enum.Font.GothamBold; b.TextSize = itemTextSize
		b.BorderSizePixel = 0; b.AutoButtonColor = false; b.TextXAlignment = Enum.TextXAlignment.Left
		Instance.new("UICorner", b)
		local isPrio = PriorityLoot[iN:lower()]
		local function U()
			if ItemPickerState[iN] then
				b.BackgroundColor3 = isPrio and Color3.fromRGB(0, 80, 0) or Color3.fromRGB(10, 50, 25)
				b.TextColor3 = isPrio and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(100, 255, 130)
				b.Text = (isPrio and " ⭐ " or " ✓ ")..iN
			else
				b.BackgroundColor3 = Color3.fromRGB(50, 15, 15); b.TextColor3 = Color3.fromRGB(255, 120, 120)
				b.Text = " ✗ "..iN
			end
		end; U()
		b.MouseButton1Click:Connect(function() ItemPickerState[iN] = not ItemPickerState[iN]; U(); SaveSettings(Config, ItemPickerState) end)
		local entry = {frame = f, itemName = iN, update = U}
		table.insert(itemBtns, entry); table.insert(catItemBtns, entry)
	end
	catOn.MouseButton1Click:Connect(function()
		for _, e in pairs(catItemBtns) do ItemPickerState[e.itemName] = true; e.update() end
		SaveSettings(Config, ItemPickerState)
	end)
	catOff.MouseButton1Click:Connect(function()
		for _, e in pairs(catItemBtns) do ItemPickerState[e.itemName] = false; e.update() end
		SaveSettings(Config, ItemPickerState)
	end)
end

local function FilterItems(q)
	local ql = q:lower()
	for _, e in pairs(itemBtns) do
		e.frame.Visible = (ActiveTab == "Items") and (ql == "" or e.itemName:lower():find(ql, 1, true) ~= nil)
	end
	task.wait(); Scroll.CanvasSize = UDim2.new(0, 0, 0, LL.AbsoluteContentSize.Y + 20)
end
sB:GetPropertyChangedSignal("Text"):Connect(function() if ActiveTab == "Items" then FilterItems(sB.Text) end end)
eA.MouseButton1Click:Connect(function()
	local q = sB.Text:lower()
	for _, e in pairs(itemBtns) do
		if q == "" or e.itemName:lower():find(q, 1, true) then ItemPickerState[e.itemName] = true; e.update() end
	end
	SaveSettings(Config, ItemPickerState)
end)
dAB.MouseButton1Click:Connect(function()
	local q = sB.Text:lower()
	for _, e in pairs(itemBtns) do
		if q == "" or e.itemName:lower():find(q, 1, true) then ItemPickerState[e.itemName] = false; e.update() end
	end
	SaveSettings(Config, ItemPickerState)
end)

AddCategory("Binds", "KEYBINDS (PC)")
local bA = {{key = "Fly", name = "FLY"}, {key = "AimActive", name = "AIM"}, {key = "Noclip", name = "NOCLIP"}, {key = "SilentAim", name = "SILENT"}, {key = "ToggleUI", name = "UI"}}
local BBtns = {}
local function AddBR(tab, aK, aN)
	local bindH = isSmallScreen and 36 or (IsMobile and 44 or 38)
	local bindBtnH = isSmallScreen and 24 or (IsMobile and 30 or 26)
	local f = Instance.new("Frame", Scroll); f.Size = UDim2.new(0.97, 0, 0, bindH)
	f.BackgroundColor3 = Color3.fromRGB(16, 16, 26); f.BorderSizePixel = 0; f.Visible = false
	Instance.new("UICorner", f); table.insert(Sections[tab], f)
	local nl = Instance.new("TextLabel", f); nl.Size = UDim2.new(0.52, 0, 1, 0); nl.Position = UDim2.new(0, 10, 0, 0)
	nl.BackgroundTransparency = 1; nl.TextColor3 = Color3.fromRGB(200, 200, 210)
	nl.Font = Enum.Font.GothamBold; nl.TextSize = btnTextSize; nl.TextXAlignment = Enum.TextXAlignment.Left; nl.Text = aN
	local bb = Instance.new("TextButton", f); bb.Size = UDim2.new(0.42, 0, 0, bindBtnH)
	bb.Position = UDim2.new(0.55, 0, 0.5, -bindBtnH / 2); bb.BackgroundColor3 = Color3.fromRGB(22, 22, 38)
	bb.TextColor3 = Color3.fromRGB(170, 200, 255); bb.Font = Enum.Font.GothamBold; bb.TextSize = isSmallScreen and 9 or 11
	bb.BorderSizePixel = 0; bb.AutoButtonColor = false
	bb.Text = Binds[aK] and tostring(Binds[aK]):gsub("Enum%.KeyCode%.","") or "?"
	Instance.new("UICorner", bb); Instance.new("UIStroke", bb).Color = Color3.fromRGB(0, 100, 200)
	BBtns[aK] = bb
	bb.MouseButton1Click:Connect(function()
		if waitingForBind then return end
		waitingForBind = aK; bb.Text = "[...]"; bb.TextColor3 = Color3.fromRGB(255, 220, 50)
	end)
end
for _, e in pairs(bA) do AddBR("Binds", e.key, e.name) end

AddCategory("Binds", "SCREEN SHORTCUTS 📱")
local scInfo = Instance.new("Frame", Scroll); scInfo.Size = UDim2.new(0.97, 0, 0, isSmallScreen and 24 or (IsMobile and 30 or 24))
scInfo.BackgroundColor3 = Color3.fromRGB(12, 12, 22); scInfo.BorderSizePixel = 0; scInfo.Visible = false
Instance.new("UICorner", scInfo); table.insert(Sections["Binds"], scInfo)
local scInfoL = Instance.new("TextLabel", scInfo); scInfoL.Size = UDim2.new(1, 0, 1, 0); scInfoL.BackgroundTransparency = 1
scInfoL.TextColor3 = Color3.fromRGB(120, 160, 255); scInfoL.Font = Enum.Font.Gotham; scInfoL.TextSize = isSmallScreen and 8 or 10; scInfoL.TextWrapped = true
scInfoL.Text = "Show/hide screen buttons"

local scToggleH = isSmallScreen and 30 or (IsMobile and 38 or 34)
for _, def in ipairs(ShortcutDefs) do
	local f = Instance.new("Frame", Scroll); f.Size = UDim2.new(0.97, 0, 0, scToggleH)
	f.BackgroundTransparency = 1; f.BorderSizePixel = 0; f.Visible = false; table.insert(Sections["Binds"], f)
	local btn = Instance.new("TextButton", f); btn.Size = UDim2.new(1, 0, 1, 0); btn.Font = Enum.Font.GothamBold
	btn.TextSize = isSmallScreen and 9 or (IsMobile and 11 or 12); btn.BorderSizePixel = 0; btn.AutoButtonColor = false
	btn.TextXAlignment = Enum.TextXAlignment.Left; Instance.new("UICorner", btn)
	local function U()
		if Config[def.scKey] then btn.BackgroundColor3 = Color3.fromRGB(0, 60, 40); btn.TextColor3 = Color3.fromRGB(100, 255, 130); btn.Text = " 📱 "..def.label..": VISIBLE"
		else btn.BackgroundColor3 = Color3.fromRGB(40, 15, 15); btn.TextColor3 = Color3.fromRGB(255, 130, 130); btn.Text = " 📱 "..def.label..": HIDDEN" end
		if ShortcutBtns[def.key] then ShortcutBtns[def.key].update() end
	end; U()
	btn.MouseButton1Click:Connect(function() Config[def.scKey] = not Config[def.scKey]; U(); SaveSettings(Config, ItemPickerState) end)
end

local function ShowTab(n)
	ActiveTab = n
	for nn, frames in pairs(Sections) do
		for _, f in pairs(frames) do
			pcall(function() f.Visible = (nn == n) end)
		end
	end
	if n == "Items" then FilterItems(sB.Text) end
	for nn, b in pairs(TabButtons) do
		if nn == n then b.BackgroundColor3 = Color3.fromRGB(0, 100, 220); b.TextColor3 = Color3.new(1, 1, 1)
		else b.BackgroundColor3 = Color3.fromRGB(18, 18, 30); b.TextColor3 = Color3.fromRGB(150, 150, 170) end
	end
	task.wait(); Scroll.CanvasPosition = Vector2.zero; Scroll.CanvasSize = UDim2.new(0, 0, 0, LL.AbsoluteContentSize.Y + 20)
end
for n, b in pairs(TabButtons) do b.MouseButton1Click:Connect(function() ShowTab(n) end) end

UIS.InputBegan:Connect(function(inp, gpe)
	if waitingForBind then
		if inp.UserInputType == Enum.UserInputType.Keyboard then
			if inp.KeyCode == Enum.KeyCode.F then
				if BBtns[waitingForBind] then BBtns[waitingForBind].Text = "⚠ Not F!"; BBtns[waitingForBind].TextColor3 = Color3.fromRGB(255, 80, 80) end
				task.delay(1, function()
					if BBtns[waitingForBind] then
						local a = waitingForBind
						BBtns[a].Text = Binds[a] and tostring(Binds[a]):gsub("Enum%.KeyCode%.","") or "?"
						BBtns[a].TextColor3 = Color3.fromRGB(170, 200, 255)
					end
					waitingForBind = nil
				end)
				return
			end
			local a = waitingForBind; Binds[a] = inp.KeyCode
			if BBtns[a] then BBtns[a].Text = tostring(inp.KeyCode):gsub("Enum%.KeyCode%.",""); BBtns[a].TextColor3 = Color3.fromRGB(170, 200, 255) end
			waitingForBind = nil; SaveSettings(Config, ItemPickerState)
		end; return
	end
	if gpe then return end
	if inp.KeyCode == Enum.KeyCode.F then return end
	for a, k in pairs(Binds) do
		if inp.KeyCode ~= k then continue end
		if a == "ToggleUI" then Main.Visible = not Main.Visible
		elseif a == "Fly" then
			Config.Fly = not Config.Fly; if UpdFuncs.Fly then UpdFuncs.Fly(Config.Fly) end
			UpdateFlyBtns(); UpdateAllShortcuts()
			if not Config.Fly then local h = GetHum(); if h then h.PlatformStand = false; h.WalkSpeed = 16 end end
		elseif a == "AimActive" then
			Config.AimActive = not Config.AimActive; if UpdFuncs.AimActive then UpdFuncs.AimActive(Config.AimActive) end
			UpdateAllShortcuts(); aimTarget = nil; aimLocked = false; aimLostFrames = 0; aimHasLockedOnce = not Config.AimActive
		elseif a == "Noclip" then
			Config.Noclip = not Config.Noclip; if UpdFuncs.Noclip then UpdFuncs.Noclip(Config.Noclip) end
			UpdateAllShortcuts(); if not Config.Noclip then RestoreCollision() end
		elseif a == "SilentAim" then
			Config.SilentAim = not Config.SilentAim; if UpdFuncs.SilentAim then UpdFuncs.SilentAim(Config.SilentAim) end
			UpdateAllShortcuts(); if not Config.SilentAim then StopSilentAim() end
		end
	end
end)

local MS = isSmallScreen and 44 or (IsMobile and 56 or 44)
local MB = Instance.new("TextButton", SG); MB.Size = UDim2.new(0, MS, 0, MS); MB.Position = UDim2.new(0, 10, 0.25, 0)
MB.Text = "M"; MB.Font = Enum.Font.GothamBlack; MB.TextSize = isSmallScreen and 18 or (IsMobile and 24 or 20)
MB.BackgroundColor3 = Color3.fromRGB(0, 80, 200); MB.TextColor3 = Color3.new(1, 1, 1)
MB.BorderSizePixel = 0; MB.AutoButtonColor = false; MB.ZIndex = 100
Instance.new("UICorner", MB); Instance.new("UIStroke", MB).Color = Color3.new(1, 1, 1)
task.spawn(function()
	while true do
		TweenService:Create(MB, TweenInfo.new(1.6), {BackgroundColor3 = Color3.fromRGB(0, 40, 160)}):Play(); task.wait(1.6)
		TweenService:Create(MB, TweenInfo.new(1.6), {BackgroundColor3 = Color3.fromRGB(0, 110, 255)}):Play(); task.wait(1.6)
	end
end)
do
	local d, s, p, t, m = false, nil, nil, 0, false
	MB.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then d = true; s = i.Position; p = MB.Position; t = tick(); m = false end end)
	MB.InputChanged:Connect(function(i) if not d then return end; if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then local dl = i.Position - s; if dl.Magnitude > 8 then m = true end; MB.Position = UDim2.new(p.X.Scale, p.X.Offset + dl.X, p.Y.Scale, p.Y.Offset + dl.Y) end end)
	MB.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then if d and not m and tick() - t < 0.3 then Main.Visible = not Main.Visible end; d = false end end)
	UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then d = false end end)
end

ShowTab("Combat")
if Config.Fullbright then task.spawn(EnableFB) end
if Config.FPSBoost then task.spawn(ApplyFPS) end
if Config.HighJump then local h = GetHum(); if h then h.UseJumpPower = true; h.JumpPower = Config.JumpPowerValue end end
if Config.Speed then local h = GetHum(); if h then h.WalkSpeed = Config.WalkSpeedValue end end
UpdateAllShortcuts(); UpdateFlyBtns()

Notify("⚡ V64", "✓ + 💰 Money Farm додано | M=меню", 5)
