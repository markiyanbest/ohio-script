-- Language: Luau | Target: Roblox Ohio (PlaceId: 7239319209) | Runtime: Client Executor (PC & Mobile)
-- markiyanbest's script (V80 - Smart Auto Bank Robbery, Vault Gems/Safes/CashBundles, Full Mutex Sync, Drawer UI)

if getgenv().MarkiyanCleanup then
    pcall(getgenv().MarkiyanCleanup)
end

local ActiveConnections = {}
local ScriptAlive = true

local function TrackConn(conn)
    if conn then
        table.insert(ActiveConnections, conn)
    end
    return conn
end

local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local RS = game:GetService("RunService")
local Light = game:GetService("Lighting")
local UIS = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local Camera = workspace.CurrentCamera or workspace:FindFirstChildOfClass("Camera")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

local IsMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled
local IsPC = not IsMobile

pcall(function()
    for _, sg in pairs({game:GetService("CoreGui"), lp:WaitForChild("PlayerGui")}) do
        for _, v in pairs(sg:GetChildren()) do
            if v:IsA("ScreenGui") and (v.Name == "MarkiyanPro" or v.Name:find("Sys_V")) then
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

-- ============================================================
-- 2026 OHIO ITEM REGISTRY & CATEGORIES
-- ============================================================
local ItemCategories = {
    {name="🏆 ПРІОРИТЕТ / ЛІМІТКИ 2026", color=Color3.fromRGB(205,115,0), items={
        "Money Printer","Unusual Money Printer","Gold Money Printer",
        "Money Balloon","Dollar Balloon","Clover Balloon","Golden Clover Balloon","Heart Balloon",
        "Bat Balloon","Ghost Balloon","Bunny Balloon","Skull Balloon","Snowflake Balloon",
        "Pumpkin Balloon","Cupid Balloon","Easter Balloon","Star Balloon","Party Balloon",
        "Pot of Gold Balloon","Black Balloon","Golden Balloon","Patriotic Balloon",
        "Void Rose","Gold Rose",
        "Void Scythe","Spectral Scythe","Spirit Kunai","Kunai",
        "Blue Candy Cane","Candy Cane","Festive Guitar",
        "Void Katana","Gold Katana","Diamond Katana","Karambit","Butterfly Knife","Golden Knife",
        "Dark Matter Gem","Void Gem","Diamond","Sapphire","Emerald","Ruby","Amethyst",
        "Diamond ore","Gold ore","Golden Crown","Golden Cup","Diamond Ring","Rollie",
        "Pearl necklace","Purple seashell","Gold Bar","Money Bag","Cash Bag","Diamond Taco",
        "Helicopter Keys","Mustang Keys","Cruiser Keys",
        "Red Keycard","Military Keycard","Police Keycard","Scythe Key",
        "Admin AK-47","Admin RPG","Admin Nuke",
        "Gold AK-47","Gold Deagle","Diamond Glock","Pulse Rifle","Raygun",
        "Suitcase Nuke","Nuke Launcher","NextBot Grenade","Infinite NextBot",
        "Sparkler","Pink Firework","Green Firework","July 4th Firework",
        "Purple Lucky Block","Blue Lucky Block","Red Lucky Block","Orange Lucky Block",
        "Green Lucky Block","Gold Lucky Block","Festive Lucky Block","Void Lucky Block",
        "Rainbow Lucky Block","Galaxy Lucky Block","Flying Santa's Box","Santa Sleigh",
        "Large Present","Small Present","Presents","Easter Basket","Lantern","Egg","Umbrella",
    }},
    {name="🔫 ЗБРОЯ ТА ВИБУХІВКА", color=Color3.fromRGB(165,35,45), items={
        "AK-47","AR-15","AS VAL","AUG","M4A1","SCAR-L","M1 Garand",
        "Barrett M107","Dragunov","AWP",
        "MP7","P90","Tommy Gun","Mac-10","Uzi","M249 SAW","RPK",
        "Double Barrel","Mossberg","Saiga 12","Sawn Off","Stagecoach","SPAS-12",
        "Deagle","Glock","Glock 18","M1911","Python","USP 45",
        "Acid Gun","Gravity Gun","Money Gun","Flamethrower","Railgun","Taser Gun","Pepper Spray",
        "Snowball Launcher","Pumpkin Launcher",
        "RPG","Heavy C4","C4","Frag Grenade","Smoke Grenade","Flashbang","Molotov",
        "Landmines","Bear Trap","Airstrike","Airdrop Marker","Airdrop",
    }},
    {name="🗡 ХОЛОДНА ЗБРОЯ", color=Color3.fromRGB(130,45,90), items={
        "Katana","Saber","Spiked Baseball Bat","Baseball Bat","Fireaxe","Crowbar",
        "Knife","Baton","Brass Knuckles","Blue Gloves","Red Gloves","Clown Mallet",
        "Tomahawk","Ninja Star","Stop Sign","Sign","Guitar","Maraca","Fists",
    }},
    {name="💎 КАБЛУЧКИ, РУДИ ТА СКАРБИ", color=Color3.fromRGB(0,135,155), items={
        "Ruby Ring","Sapphire Ring","Topaz Ring","Amethyst Ring","Emerald Ring","Watch",
        "Sapphire ore","Amethyst ore","Ruby ore","Topaz ore","Emerald ore",
        "Blue seashell","Basic seashell","Gems",
    }},
    {name="🛡 БРОНЯ, МАСКИ ТА ОКУЛЯРИ", color=Color3.fromRGB(20,105,170), items={
        "Military Vest","Heavy Vest","Medium Vest","Light Vest",
        "Night Vision Goggles","X-Ray Goggles","America Hat","4th of July Hat","Sombrero Hat",
        "Hockey Mask","Surgeon Mask","Black Bandana","Blue Bandana","Red Bandana",
        "Medkit","Bandage","Riot Shield","Stretcher",
    }},
    {name="📦 СЕЙФИ, КАСИ ТА КОМПОНЕНТИ", color=Color3.fromRGB(120,75,20), items={
        "Gold Safe","Large Safe","Medium Safe","Small Safe","Safes",
        "ATM","Cash Register","Slot Machine","Locker","Armored Truck","Wallet",
        "Component Boxes","Weapon Parts","Medical Supplies","Explosives","Explosives Scrap",
        "Electronics","Materials","Scrap","Cheap Metal","Refined Metal","Gunpowder",
        "Cloth","Chemicals","Circuit Boards","Plastic",
    }},
    {name="🍎 ЇЖА, ФЕЄРВЕРКИ ТА ПРОПИ", color=Color3.fromRGB(20,140,70), items={
        "Balloon","Rose","Choco Bunny","Chocolates","Apple","Banana","Banana Peel","Beans",
        "Bloxaide","Bloxy Cola","Burger","Cake","Chicken","Coffee","Cookie","Cotton Candy",
        "Donut","Hotdog","Pizza","Popcorn","Taco",
        "Firework","Firework Cake","Firework Cone","Firework Mortar","Roman Candle",
        "Lockpick","Flashlight","Fire Extinguisher","Megaphone","Drone","Hoverboard","Skateboard",
        "Basketball","Beach Ball","Clown","Dumbell","Grocery Cart","Shopping Cart","Meat Grinder",
    }},
}

local ALL_ITEMS = {}
local ALL_ITEMS_LOOKUP = {}
do
    local seen = {}
    for _, cat in ipairs(ItemCategories) do
        for _, item in ipairs(cat.items) do
            if not seen[item] then
                seen[item] = true
                table.insert(ALL_ITEMS, item)
                ALL_ITEMS_LOOKUP[item:lower()] = item
            end
        end
    end
end

local EXTRA_NAMES = {}
do
    local EN = {
        ["money balloon"]="Money Balloon",["dollar balloon"]="Dollar Balloon",["dollarballoon"]="Dollar Balloon",
        ["clover balloon"]="Clover Balloon",["golden clover balloon"]="Golden Clover Balloon",
        ["gold clover balloon"]="Golden Clover Balloon",["heart balloon"]="Heart Balloon",
        ["bat balloon"]="Bat Balloon",["batballoon"]="Bat Balloon",
        ["ghost balloon"]="Ghost Balloon",["ghostballoon"]="Ghost Balloon",
        ["bunny balloon"]="Bunny Balloon",["bunnyballoon"]="Bunny Balloon",
        ["skull balloon"]="Skull Balloon",["skullballoon"]="Skull Balloon",
        ["snowflake balloon"]="Snowflake Balloon",["snowflakeballoon"]="Snowflake Balloon",
        ["pumpkin balloon"]="Pumpkin Balloon",["cupid balloon"]="Cupid Balloon",
        ["easter balloon"]="Easter Balloon",["star balloon"]="Star Balloon",
        ["party balloon"]="Party Balloon",["pot of gold balloon"]="Pot of Gold Balloon",
        ["black balloon"]="Black Balloon",["golden balloon"]="Golden Balloon",["patriotic balloon"]="Patriotic Balloon",
        ["balloon"]="Balloon",["void rose"]="Void Rose",["black rose"]="Void Rose",["voidrose"]="Void Rose",
        ["gold rose"]="Gold Rose",["golden rose"]="Gold Rose",["goldrose"]="Gold Rose",["rose"]="Rose",
        ["purple lucky block"]="Purple Lucky Block",["blue lucky block"]="Blue Lucky Block",
        ["red lucky block"]="Red Lucky Block",["orange lucky block"]="Orange Lucky Block",
        ["green lucky block"]="Green Lucky Block",["gold lucky block"]="Gold Lucky Block",
        ["golden lucky block"]="Gold Lucky Block",["festive lucky block"]="Festive Lucky Block",
        ["void lucky block"]="Void Lucky Block",["rainbow lucky block"]="Rainbow Lucky Block",
        ["galaxy lucky block"]="Galaxy Lucky Block",
        ["large present"]="Large Present",["small present"]="Small Present",
        ["presents"]="Presents",["present"]="Presents",
        ["flying santa's box"]="Flying Santa's Box",["santa sleigh"]="Santa Sleigh",
        ["easter basket"]="Easter Basket",["choco bunny"]="Choco Bunny",["chocolates"]="Chocolates",
        ["lantern"]="Lantern",["egg"]="Egg",["umbrella"]="Umbrella",
        ["sparkler"]="Sparkler",["pink firework"]="Pink Firework",["green firework"]="Green Firework",
        ["july 4th firework"]="July 4th Firework",["july4th firework"]="July 4th Firework",["4th of july firework"]="July 4th Firework",
        ["firework"]="Firework",["firework cake"]="Firework Cake",["firework cone"]="Firework Cone",
        ["firework mortar"]="Firework Mortar",["roman candle"]="Roman Candle",
        ["void scythe"]="Void Scythe",["scythe (void)"]="Void Scythe",["scythe void"]="Void Scythe",
        ["spectral scythe"]="Spectral Scythe",
        ["spirit kunai"]="Spirit Kunai",["spiritual kunai"]="Spirit Kunai",
        ["regular kunai"]="Kunai",["kunai"]="Kunai",["kunais"]="Kunai",
        ["blue candy cane"]="Blue Candy Cane",["blue candy"]="Blue Candy Cane",["candy cane"]="Candy Cane",
        ["festive guitar"]="Festive Guitar",
        ["spiked baseball bat"]="Spiked Baseball Bat",["spiked bat"]="Spiked Baseball Bat",["baseball bat"]="Baseball Bat",
        ["void katana"]="Void Katana",["gold katana"]="Gold Katana",["diamond katana"]="Diamond Katana",
        ["butterfly knife"]="Butterfly Knife",["karambit"]="Karambit",["golden knife"]="Golden Knife",
        ["tomahawk"]="Tomahawk",["ninja star"]="Ninja Star",
        ["ak-47"]="AK-47",["ak47"]="AK-47",
        ["gold ak-47"]="Gold AK-47",["gold ak47"]="Gold AK-47",["golden ak-47"]="Gold AK-47",
        ["admin ak-47"]="Admin AK-47",["admin rpg"]="Admin RPG",["admin nuke"]="Admin Nuke",
        ["suitcase nuke"]="Suitcase Nuke",["nuke launcher"]="Nuke Launcher",
        ["nextbot grenade"]="NextBot Grenade",["infinite nextbot"]="Infinite NextBot",
        ["gold deagle"]="Gold Deagle",["golden deagle"]="Gold Deagle",["deagle"]="Deagle",
        ["diamond glock"]="Diamond Glock",["glock 18"]="Glock 18",["glock"]="Glock",
        ["as val"]="AS VAL",["as-val"]="AS VAL",["asval"]="AS VAL",
        ["scar-l"]="SCAR-L",["scarl"]="SCAR-L",["awp"]="AWP",
        ["m4a1"]="M4A1",["ar-15"]="AR-15",["ar15"]="AR-15",
        ["barrett m107"]="Barrett M107",["barrett"]="Barrett M107",
        ["m249 saw"]="M249 SAW",["m249"]="M249 SAW",["m1 garand"]="M1 Garand",
        ["spas-12"]="SPAS-12",["spas12"]="SPAS-12",["saiga 12"]="Saiga 12",
        ["sawn off"]="Sawn Off",["sawn-off"]="Sawn Off",["sawnoff"]="Sawn Off",
        ["double barrel"]="Double Barrel",["double barrel shotgun"]="Double Barrel",
        ["tommy gun"]="Tommy Gun",["thompson"]="Tommy Gun",["mac-10"]="Mac-10",["mac10"]="Mac-10",
        ["p90"]="P90",["pulse rifle"]="Pulse Rifle",["raygun"]="Raygun",["reygan"]="Raygun",
        ["railgun"]="Railgun",["taser"]="Taser Gun",["taser gun"]="Taser Gun",
        ["snowball launcher"]="Snowball Launcher",["pumpkin launcher"]="Pumpkin Launcher",
        ["heavy c4"]="Heavy C4",["c4"]="C4",["frag grenade"]="Frag Grenade",["smoke grenade"]="Smoke Grenade",
        ["airdrop marker"]="Airdrop Marker",["airdrop"]="Airdrop",
        ["dark matter gem"]="Dark Matter Gem",["darkmattergem"]="Dark Matter Gem",["dark matter"]="Dark Matter Gem",
        ["void gem"]="Void Gem",["voidgem"]="Void Gem",["diamond"]="Diamond",["sapphire"]="Sapphire",
        ["emerald"]="Emerald",["ruby"]="Ruby",["amethyst"]="Amethyst",
        ["diamond ring"]="Diamond Ring",["diamondring"]="Diamond Ring",
        ["emerald ring"]="Emerald Ring",["ruby ring"]="Ruby Ring",["sapphire ring"]="Sapphire Ring",
        ["topaz ring"]="Topaz Ring",["amethyst ring"]="Amethyst Ring",
        ["rollie"]="Rollie",["gold watch"]="Rollie",["watch"]="Watch",
        ["golden crown"]="Golden Crown",["goldencrown"]="Golden Crown",
        ["golden cup"]="Golden Cup",["goldencup"]="Golden Cup",
        ["pearl necklace"]="Pearl necklace",["purple seashell"]="Purple seashell",
        ["blue seashell"]="Blue seashell",["basic seashell"]="Basic seashell",
        ["diamond ore"]="Diamond ore",["gold ore"]="Gold ore",["sapphire ore"]="Sapphire ore",
        ["amethyst ore"]="Amethyst ore",["ruby ore"]="Ruby ore",["topaz ore"]="Topaz ore",["emerald ore"]="Emerald ore",
        ["gold bar"]="Gold Bar",["gold bullion"]="Gold Bar",["money bag"]="Money Bag",["cash bag"]="Cash Bag",
        ["diamond taco"]="Diamond Taco",
        ["money printer"]="Money Printer",["money printers"]="Money Printer",["moneyprinter"]="Money Printer",["printer"]="Money Printer",
        ["unusual money printer"]="Unusual Money Printer",["unusualmoneyprinter"]="Unusual Money Printer",["unusual printer"]="Unusual Money Printer",
        ["gold money printer"]="Gold Money Printer",["golden money printer"]="Gold Money Printer",
        ["helicopter keys"]="Helicopter Keys",["heli keys"]="Helicopter Keys",
        ["mustang keys"]="Mustang Keys",["cruiser keys"]="Cruiser Keys",
        ["red keycard"]="Red Keycard",["military keycard"]="Military Keycard",["military key card"]="Military Keycard",
        ["military armory keycard"]="Military Keycard",["militarykeycard"]="Military Keycard",
        ["police keycard"]="Police Keycard",["police key card"]="Police Keycard",
        ["police armory keycard"]="Police Keycard",["policekeycard"]="Police Keycard",
        ["scythe key"]="Scythe Key",
        ["gold safe"]="Gold Safe",["goldsafe"]="Gold Safe",
        ["large safe"]="Large Safe",["largesafe"]="Large Safe",
        ["medium safe"]="Medium Safe",["mediumsafe"]="Medium Safe",
        ["small safe"]="Small Safe",["smallsafe"]="Small Safe",
        ["safes"]="Safes",["safe"]="Safes",
        ["slot machine"]="Slot Machine",["cash register"]="Cash Register",["cashregister"]="Cash Register",
        ["atm"]="ATM",["atmmachine"]="ATM",
        ["light vest"]="Light Vest",["medium vest"]="Medium Vest",["heavy vest"]="Heavy Vest",["military vest"]="Military Vest",
        ["america hat"]="America Hat",["4th of july hat"]="4th of July Hat",
        ["night vision goggles"]="Night Vision Goggles",["x-ray goggles"]="X-Ray Goggles",["xray goggles"]="X-Ray Goggles",
        ["stakeboard"]="Skateboard",["skateboard"]="Skateboard",
    }
    for k, v in pairs(EN) do
        EXTRA_NAMES[k] = v
        if not ALL_ITEMS_LOOKUP[k] then ALL_ITEMS_LOOKUP[k] = v end
    end
end

local PriorityLoot = {}
for _, item in ipairs(ItemCategories[1].items) do PriorityLoot[item:lower()] = true end
for k, v in pairs(EXTRA_NAMES) do
    if PriorityLoot[v:lower()] then PriorityLoot[k] = true end
end

local PRIORITY_KEYWORDS = {
    "printer", "balloon", "keycard", "key card", "nuke", "lucky block",
    "dark matter", "void", "diamond", "golden", "gold ", "admin",
    "scythe", "kunai", "gem", "airdrop", "present", "keys", "raygun",
    "pulse rifle", "rollie", "nextbot", "santa", "sparkler", "crown"
}

local CONTAINER_ITEMS = {
    ["Safes"]=true, ["Gold Safe"]=true, ["Large Safe"]=true, ["Medium Safe"]=true, ["Small Safe"]=true,
    ["Locker"]=true, ["Airdrop"]=true, ["Flying Santa's Box"]=true,
    ["Large Present"]=true, ["Small Present"]=true, ["Presents"]=true, ["Easter Basket"]=true,
    ["Component Boxes"]=true, ["ATM"]=true, ["Cash Register"]=true, ["Slot Machine"]=true,
    ["Gold Lucky Block"]=true, ["Green Lucky Block"]=true, ["Orange Lucky Block"]=true,
    ["Purple Lucky Block"]=true, ["Red Lucky Block"]=true, ["Blue Lucky Block"]=true,
    ["Festive Lucky Block"]=true, ["Void Lucky Block"]=true, ["Rainbow Lucky Block"]=true, ["Galaxy Lucky Block"]=true,
}

local GENERIC_PART_NAMES = {
    ["handle"]=true, ["part"]=true, ["main"]=true, ["meshpart"]=true,
    ["base"]=true, ["body"]=true, ["attachment"]=true, ["prompt"]=true,
    ["proximityprompt"]=true, ["hitbox"]=true, ["root"]=true, ["primary"]=true,
    ["itempickup"]=true, ["pickup"]=true, ["model"]=true, ["union"]=true,
    ["screen"]=true, ["frame"]=true, ["door"]=true,
}

local ColorThemes = {
    {name="🔵 Кібер Синій", primary=Color3.fromRGB(35,115,245), secondary=Color3.fromRGB(22,60,145), accent=Color3.fromRGB(70,185,255), header1=Color3.fromRGB(18,42,110), header2=Color3.fromRGB(35,115,245)},
    {name="🔴 Кримсон", primary=Color3.fromRGB(210,40,55), secondary=Color3.fromRGB(125,22,32), accent=Color3.fromRGB(255,90,105), header1=Color3.fromRGB(105,15,25), header2=Color3.fromRGB(210,40,55)},
    {name="🟢 Смарагд", primary=Color3.fromRGB(15,165,95), secondary=Color3.fromRGB(10,95,55), accent=Color3.fromRGB(50,235,135), header1=Color3.fromRGB(10,75,42), header2=Color3.fromRGB(15,165,95)},
    {name="🟣 Неон Фіолет", primary=Color3.fromRGB(130,45,225), secondary=Color3.fromRGB(75,25,135), accent=Color3.fromRGB(190,110,255), header1=Color3.fromRGB(55,15,105), header2=Color3.fromRGB(130,45,225)},
    {name="🟠 Голд Амбер", primary=Color3.fromRGB(225,115,15), secondary=Color3.fromRGB(135,65,10), accent=Color3.fromRGB(255,175,50), header1=Color3.fromRGB(110,50,5), header2=Color3.fromRGB(225,115,15)},
    {name="🩷 Сакура", primary=Color3.fromRGB(215,45,145), secondary=Color3.fromRGB(130,20,85), accent=Color3.fromRGB(255,110,195), header1=Color3.fromRGB(100,15,65), header2=Color3.fromRGB(215,45,145)},
    {name="⚫ Онікс", primary=Color3.fromRGB(75,80,95), secondary=Color3.fromRGB(40,42,52), accent=Color3.fromRGB(150,160,185), header1=Color3.fromRGB(24,26,34), header2=Color3.fromRGB(65,70,85)},
    {name="🩵 Аквамарин", primary=Color3.fromRGB(15,170,185), secondary=Color3.fromRGB(10,95,105), accent=Color3.fromRGB(65,235,250), header1=Color3.fromRGB(8,75,85), header2=Color3.fromRGB(15,170,185)},
}
local currentThemeIndex = 1

local Config = {
    Farm=false, AutoSnipe=false, SmartUnknownSnipe=true, InstantPrompt=true,
    ATMFarm=false, ATMIncludeRegisters=true, ATMIncludeSafes=true, ATMCollectCash=true, ATMAttackDelay=12,
    AutoBank=false, BankBreakSafes=true, BankReturnSafeZone=true, BankCheckInterval=4,
    Speed=false, AimActive=false,
    FPSBoost=false, AntiSeat=false, AntiAFK=false, AntiRagdoll=true, Fly=false,
    FlySpeedValue=IsMobile and 35 or 50, WalkSpeedValue=IsMobile and 45 or 65,
    ESP=false, LootESP=false, Fullbright=false, InfJump=false, Noclip=false,
    Magnet=false, MagnetTarget=nil, ShadowMagnet=false,
    ShadowTarget=nil, ShadowDepth=15, AutoSafe=false, SafeHealth=35,
    SilentAim=false, AimFOV=200, AimPart="Head",
    AimPrediction=135, AimSmooth=0, AimWallCheck=true,
    HighJump=false, JumpPowerValue=80,
    MoneyFarm=false, MoneyMinSum=0,
    SC_Aim=IsMobile, SC_Silent=IsMobile, SC_Fly=IsMobile,
    SC_Noclip=IsMobile, SC_Speed=IsMobile, SC_Farm=IsMobile,
    SC_ATM=IsMobile, SC_Bank=IsMobile, SC_Snipe=false,
    SC_Shadow=IsMobile, SC_HighJump=IsMobile, SC_Safe=false,
    SC_MoneyFarm=IsMobile,
    _SafeTP=false, FarmRange=900,
    FarmDelay=18, FarmMaxHold=20, FarmBatchSize=5,
    ThemeIndex=1, ShadowJumpDelay=20,
}

local ItemPickerState = {}
local SnipePickerState = {}
for _, item in pairs(ALL_ITEMS) do
    ItemPickerState[item] = true
    SnipePickerState[item] = PriorityLoot[item:lower()] and true or false
end

local Binds = {
    Fly=Enum.KeyCode.V, AimActive=Enum.KeyCode.G,
    Noclip=Enum.KeyCode.X, SilentAim=Enum.KeyCode.B,
    ToggleUI=Enum.KeyCode.M, ATMFarm=Enum.KeyCode.Unknown,
    AutoBank=Enum.KeyCode.Unknown,
    Farm=Enum.KeyCode.Unknown, AutoSnipe=Enum.KeyCode.Unknown,
    Speed=Enum.KeyCode.Unknown, HighJump=Enum.KeyCode.Unknown,
    ShadowMagnet=Enum.KeyCode.Unknown, Magnet=Enum.KeyCode.Unknown,
    MoneyFarm=Enum.KeyCode.Unknown, ESP=Enum.KeyCode.Unknown,
    LootESP=Enum.KeyCode.Unknown,
}
local waitingForBind = nil
local waitingBindBtn = nil
local UpdateFlyBtns_ = nil
local loadedDataStatus = false

local SAVE_KEY = "MarkiyanPro_Ohio_Save_V80"
local function SaveSettings()
    pcall(function()
        local data = {config={}, itemPicker={}, snipePicker={}, binds={}}
        for k, v in pairs(Config) do
            if type(v)=="boolean" or type(v)=="number" or type(v)=="string" then data.config[k] = v end
        end
        for n, s in pairs(ItemPickerState) do data.itemPicker[n] = s end
        for n, s in pairs(SnipePickerState) do data.snipePicker[n] = s end
        for k, b in pairs(Binds) do
            if b and b ~= Enum.KeyCode.Unknown then
                data.binds[k] = tostring(b):gsub("Enum%.KeyCode%.", "")
            end
        end
        if writefile then writefile(SAVE_KEY..".json", HttpService:JSONEncode(data)) end
    end)
end

local function LoadSettings()
    local data = nil
    pcall(function()
        if readfile and isfile then
            for _, fn in ipairs({SAVE_KEY..".json", "MarkiyanPro_Ohio_Save_V79.json", "MarkiyanPro_Ohio_Save_V78.json", "MarkiyanPro_Ohio_Save.json"}) do
                if isfile(fn) then
                    data = HttpService:JSONDecode(readfile(fn))
                    break
                end
            end
        end
    end)
    return data
end

do
    local savedData = LoadSettings()
    if savedData then
        loadedDataStatus = true
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
        if savedData.snipePicker then
            for n, s in pairs(savedData.snipePicker) do
                if SnipePickerState[n] ~= nil then SnipePickerState[n] = s end
            end
        end
        if savedData.binds then
            for k, bName in pairs(savedData.binds) do
                if Enum.KeyCode[bName] then Binds[k] = Enum.KeyCode[bName] end
            end
        end
    end
end
currentThemeIndex = math.clamp(Config.ThemeIndex or 1, 1, #ColorThemes)

task.spawn(function()
    while ScriptAlive and task.wait(15) do
        if not ScriptAlive then break end
        SaveSettings()
    end
end)

local function Notify(t, x, d)
    pcall(function() StarterGui:SetCore("SendNotification",{Title=t,Text=x,Duration=d or 2}) end)
end
local function GetChar() return lp.Character end
local function GetHum() local c=GetChar(); return c and c:FindFirstChildOfClass("Humanoid") end
local function GetRoot() local c=GetChar(); return c and c:FindFirstChild("HumanoidRootPart") end
local function IsHumAlive() local h=GetHum(); return h and h.Health > 0 end

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
    local h=c:FindFirstChildOfClass("Humanoid")
    return h and h.Health > 0
end

local function IsPlayerInvincible(player)
    if not player or not player.Character then return true end
    local char=player.Character
    local hum=char:FindFirstChildOfClass("Humanoid")
    if not hum then return true end
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("ForceField") then return true end
    end
    return false
end

local function HasForceField()
    local char = GetChar()
    if not char then return false end
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("ForceField") then return true end
    end
    return false
end

local function RemoveShieldByMoving()
    if not HasForceField() then return true end
    local root = GetRoot()
    local hum = GetHum()
    if not root or not hum then return false end
    local startPos = root.Position
    local moveDirections = {
        Vector3.new(5,0,0), Vector3.new(-5,0,0),
        Vector3.new(0,0,5), Vector3.new(0,0,-5),
        Vector3.new(3,0,3), Vector3.new(-3,0,-3),
    }
    for _, dir in ipairs(moveDirections) do
        if not HasForceField() then break end
        if not IsHumAlive() then return false end
        pcall(function() root.CFrame = CFrame.new(startPos + dir) end)
        task.wait(0.15)
    end
    if IsHumAlive() then pcall(function() root.CFrame = CFrame.new(startPos) end) end
    local waitTime = 0
    while HasForceField() and waitTime < 5 do
        if not IsHumAlive() then return false end
        pcall(function() local h2=GetHum(); if h2 then h2:Move(Vector3.new(1,0,0)) end end)
        task.wait(0.2); waitTime=waitTime+0.2
        pcall(function() local h2=GetHum(); if h2 then h2:Move(Vector3.new(-1,0,-1)) end end)
        task.wait(0.2); waitTime=waitTime+0.2
    end
    pcall(function() local h2=GetHum(); if h2 then h2:Move(Vector3.new(0,0,0)) end end)
    return not HasForceField()
end

-- ============================================================
-- SERVER HOP / REJOIN / SMALL SERVER / BIG SERVER
-- ============================================================
local function GetPlaceId() return game.PlaceId end
local function GetJobId() return game.JobId end

local function DoRejoin()
    Notify("🔄 REJOIN", "Перезаходимо на сервер...", 3)
    task.wait(1)
    pcall(function() TeleportService:TeleportToPlaceInstance(GetPlaceId(), GetJobId(), lp) end)
end

local function FetchServers(placeId, currentJobId, maxPages, sortOrder)
    local allServers = {}
    local cursor = ""
    for page = 1, maxPages do
        local url = string.format(
            "https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=%s&limit=100%s",
            placeId, sortOrder or "Asc",
            cursor ~= "" and ("&cursor="..cursor) or ""
        )
        local ok, result = pcall(function() return HttpService:JSONDecode(game:HttpGet(url)) end)
        if not ok or not result or not result.data then break end
        for _, server in ipairs(result.data) do
            if server.id ~= currentJobId and server.playing and server.maxPlayers then
                if server.playing < server.maxPlayers and server.playing > 0 then
                    table.insert(allServers, server)
                end
            end
        end
        if result.nextPageCursor and result.nextPageCursor ~= "" then
            cursor = result.nextPageCursor
        else break end
    end
    return allServers
end

local function DoServerHop()
    Notify("🔀 SERVER HOP", "Шукаємо рандомний сервер...", 3)
    task.wait(0.5)
    local placeId = GetPlaceId()
    local currentJobId = GetJobId()
    local allServers = {}
    local sortOrders = {"Asc","Desc"}
    local chosenSort = sortOrders[math.random(1,2)]
    local pagesToFetch = math.random(1,5)
    local skipPages = math.random(0,3)
    local pagesSkipped = 0
    local cursor = ""
    for page = 1, pagesToFetch + skipPages do
        local url = string.format(
            "https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=%s&limit=100%s",
            placeId, chosenSort,
            cursor ~= "" and ("&cursor="..cursor) or ""
        )
        local ok, result = pcall(function() return HttpService:JSONDecode(game:HttpGet(url)) end)
        if not ok or not result or not result.data then break end
        if pagesSkipped < skipPages then
            pagesSkipped = pagesSkipped + 1
        else
            for _, server in ipairs(result.data) do
                if server.id ~= currentJobId and server.playing and server.maxPlayers then
                    if server.playing < server.maxPlayers and server.playing > 0 then
                        table.insert(allServers, server)
                    end
                end
            end
        end
        if result.nextPageCursor and result.nextPageCursor ~= "" then
            cursor = result.nextPageCursor
        else break end
    end
    if #allServers > 0 then
        local randomIndex = math.random(1, #allServers)
        local chosenServer = allServers[randomIndex]
        Notify("🔀 SERVER HOP", string.format("Рандомний #%d з %d! Гравців: %d/%d", randomIndex, #allServers, chosenServer.playing, chosenServer.maxPlayers), 3)
        task.wait(1)
        pcall(function() TeleportService:TeleportToPlaceInstance(placeId, chosenServer.id, lp) end)
    else
        Notify("🔀 SERVER HOP", "Телепорт на випадковий...", 3)
        task.wait(1)
        pcall(function() TeleportService:Teleport(placeId, lp) end)
    end
end

local function DoJoinSmallServer()
    Notify("🔍 SMALL SERVER", "Шукаємо найменший сервер...", 3)
    task.wait(0.5)
    local placeId = GetPlaceId()
    local currentJobId = GetJobId()
    local allServers = FetchServers(placeId, currentJobId, 15, "Asc")
    table.sort(allServers, function(a, b) return a.playing < b.playing end)
    if #allServers > 0 then
        local bestServer = allServers[1]
        Notify("🔍 SMALL SERVER", string.format("Знайдено! Гравців: %d/%d (з %d)", bestServer.playing, bestServer.maxPlayers, #allServers), 4)
        task.wait(1.5)
        pcall(function() TeleportService:TeleportToPlaceInstance(placeId, bestServer.id, lp) end)
    else
        Notify("🔍 SMALL SERVER", "Не знайдено, звичайний hop...", 3)
        task.wait(1)
        pcall(function() TeleportService:Teleport(placeId, lp) end)
    end
end

local function DoJoinBigServer()
    Notify("👥 BIG SERVER", "Шукаємо найбільший сервер...", 3)
    task.wait(0.5)
    local placeId = GetPlaceId()
    local currentJobId = GetJobId()
    local allServers = FetchServers(placeId, currentJobId, 10, "Desc")
    table.sort(allServers, function(a, b) return a.playing > b.playing end)
    if #allServers > 0 then
        local topCount = math.min(5, #allServers)
        local chosenIndex = math.random(1, topCount)
        local bestServer = allServers[chosenIndex]
        Notify("👥 BIG SERVER", string.format("Знайдено! Гравців: %d/%d (#%d з top-%d)", bestServer.playing, bestServer.maxPlayers, chosenIndex, topCount), 4)
        task.wait(1.5)
        pcall(function() TeleportService:TeleportToPlaceInstance(placeId, bestServer.id, lp) end)
    else
        Notify("👥 BIG SERVER", "Не знайдено, звичайний hop...", 3)
        task.wait(1)
        pcall(function() TeleportService:Teleport(placeId, lp) end)
    end
end

-- ============================================================
-- SMART ITEM & CONTAINER MATCHING ENGINE (ANTI-BUY STAND GUARD)
-- ============================================================
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

local HARD_BLOCKED_PAID_ACTIONS = {
    ["buy"]=true, ["purchase"]=true, ["rent"]=true, ["sell"]=true,
    ["deposit"]=true, ["withdraw"]=true, ["upgrade"]=true, ["repair"]=true,
}

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

local CONTAINER_ALLOWED_ACTIONS = {
    ["open"]=true,["search"]=true,["crack"]=true,["break"]=true,
    ["hack"]=true,["loot"]=true,["rob"]=true,["steal"]=true,
    ["collect"]=true,["grab"]=true,["take"]=true,["pick up"]=true,
    ["pickup"]=true,[""]=true,["e"]=true,
}

local BLACKLIST_WORDS = {
    "door","doors","gate","gates","vault door","barrier","hatch","entrance",
    "panel","manage","property","apartment","condo","computer","terminal",
    "screen","chair","seat","bench","bed","toilet","sink","shower",
    "npc","shopkeeper","vendor","vehicle","car","truck",
    "rent","house","claim","clan","base","spawn","teleport",
    "deposit","withdraw","bank terminal",
    "crafting table","crafting","workbench","display","stand",
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
    if Config.SmartUnknownSnipe and PriorityLoot[itemName:lower()] then return true end
    return false
end

local function IsSnipeItemEnabled(itemName)
    if not itemName then return false end
    if SnipePickerState[itemName] ~= nil then return SnipePickerState[itemName] end
    local exact = ALL_ITEMS_LOOKUP[itemName:lower()]
    if exact and SnipePickerState[exact] ~= nil then return SnipePickerState[exact] end
    local fromExtra = EXTRA_NAMES[itemName:lower()]
    if fromExtra and SnipePickerState[fromExtra] ~= nil then return SnipePickerState[fromExtra] end
    if Config.SmartUnknownSnipe and PriorityLoot[itemName:lower()] then return true end
    return false
end

local function IsBlacklistedText(text)
    if not text or text == "" then return false end
    local tl = text:lower()
    for _, word in ipairs(BLACKLIST_WORDS) do if tl:find(word,1,true) then return true end end
    return false
end

local function TryMatchSingleCandidate(rawText)
    if not rawText or rawText == "" then return nil end
    local clean = rawText:match("^%s*(.-)%s*$") or ""
    local low = clean:lower()
    if low == "" or GENERIC_PART_NAMES[low] then return nil end

    if ALL_ITEMS_LOOKUP[low] then return ALL_ITEMS_LOOKUP[low] end
    if EXTRA_NAMES[low] then return EXTRA_NAMES[low] end

    for k, canonical in pairs(ALL_ITEMS_LOOKUP) do
        if #k > 3 and low:find(k, 1, true) then
            return canonical
        end
    end

    if Config.SmartUnknownSnipe then
        for _, kw in ipairs(PRIORITY_KEYWORDS) do
            if low:find(kw, 1, true) then
                ALL_ITEMS_LOOKUP[low] = clean
                PriorityLoot[low] = true
                if ItemPickerState[clean] == nil then ItemPickerState[clean] = true end
                if SnipePickerState[clean] == nil then SnipePickerState[clean] = true end
                return clean
            end
        end
    end
    return nil
end

local function ResolvePromptItemName(prompt)
    local candidates = {}
    pcall(function()
        if prompt.ObjectText and prompt.ObjectText ~= "" then
            table.insert(candidates, prompt.ObjectText)
        end
        local par = prompt.Parent
        if par then
            for _, attrName in ipairs({"ItemName", "ToolName", "Name", "Item", "Type"}) do
                local attrVal = par:GetAttribute(attrName)
                if type(attrVal) == "string" and attrVal ~= "" then
                    table.insert(candidates, attrVal)
                end
            end
            table.insert(candidates, par.Name)
            local grandPar = par.Parent
            if grandPar and grandPar ~= workspace then
                for _, attrName in ipairs({"ItemName", "ToolName", "Name", "Item", "Type"}) do
                    local attrVal = grandPar:GetAttribute(attrName)
                    if type(attrVal) == "string" and attrVal ~= "" then
                        table.insert(candidates, attrVal)
                    end
                end
                table.insert(candidates, grandPar.Name)
            end
        end
    end)

    for _, cand in ipairs(candidates) do
        local matched = TryMatchSingleCandidate(cand)
        if matched then return matched end
    end
    return nil
end

local function IsActionAllowed(actionText, matchedItem)
    local al = (actionText or ""):lower():match("^%s*(.-)%s*$") or ""
    if HARD_BLOCKED_PAID_ACTIONS[al] or al:find("buy", 1, true) or al:find("purchase", 1, true) or al:find("%$") then
        return false
    end
    if matchedItem and CONTAINER_ITEMS[matchedItem] then
        if CONTAINER_ALLOWED_ACTIONS[al] then return true end
        for act in pairs(CONTAINER_ALLOWED_ACTIONS) do
            if act ~= "" and act ~= "e" and al:find(act, 1, true) then return true end
        end
    end
    if ALLOWED_ACTIONS[al] then return true end
    if BLACKLIST_ACTIONS[al] then return false end
    for act in pairs(ALLOWED_ACTIONS) do
        if act ~= "" and act ~= "e" and al:find(act,1,true) then return true end
    end
    return false
end

local function QuickCheckPrompt(prompt, forSnipe)
    if not prompt or not prompt.Parent then return false, nil end
    local kbKey = nil; pcall(function() kbKey = prompt.KeyboardKeyCode end)
    if kbKey == Enum.KeyCode.F then return false, nil end
    local par = prompt.Parent; if not par then return false, nil end

    local parentName = ""; pcall(function() parentName = par.Name or "" end)
    local actionText = ""; pcall(function() actionText = (prompt.ActionText or "") end)
    local objectText = ""; pcall(function() objectText = (prompt.ObjectText or "") end)

    local aLow = actionText:lower():match("^%s*(.-)%s*$") or ""
    local pLow = parentName:lower():match("^%s*(.-)%s*$") or ""
    local oLow = objectText:lower():match("^%s*(.-)%s*$") or ""

    if HARD_BLOCKED_PAID_ACTIONS[aLow] or aLow:find("buy", 1, true) or aLow:find("%$") or oLow:find("buy ", 1, true) then
        return false, nil
    end
    if IsBlacklistedText(pLow) or IsBlacklistedText(aLow) then return false, nil end

    local parentBlacklisted = false
    pcall(function()
        if par.Parent and par.Parent:FindFirstChildOfClass("Humanoid") then
            parentBlacklisted = true
        end
    end)
    if parentBlacklisted or IsInsidePlayerCharacter(par) then return false, nil end

    local matchedItem = ResolvePromptItemName(prompt)
    if not matchedItem then return false, nil end

    if forSnipe then
        if not IsSnipeItemEnabled(matchedItem) then return false, nil end
    else
        if not IsItemEnabled(matchedItem) then return false, nil end
    end

    if not IsActionAllowed(aLow, matchedItem) then return false, nil end

    return true, matchedItem
end

local function GetPromptPosition(prompt)
    local pos = nil
    pcall(function()
        local par = prompt.Parent
        if not par then return end
        if par:IsA("BasePart") then
            pos = par.Position
        elseif par:IsA("Attachment") then
            pos = par.WorldPosition
        elseif par:IsA("Model") then
            pos = par:GetPivot().Position
        else
            local model = par:FindFirstAncestorOfClass("Model")
            if model and model ~= workspace then
                pos = model:GetPivot().Position
            else
                local pp = par:FindFirstChildWhichIsA("BasePart", true)
                if pp then pos = pp.Position end
            end
        end
    end)
    return pos
end

local function SafeFirePrompt(prompt, attempts)
    if not prompt or not prompt.Parent then return false end
    local kbKey = nil; pcall(function() kbKey = prompt.KeyboardKeyCode end)
    if kbKey == Enum.KeyCode.F then return false end
    attempts = attempts or 3
    pcall(function()
        if Config.InstantPrompt then prompt.HoldDuration = 0 end
        prompt.RequiresLineOfSight = false
        if prompt.MaxActivationDistance < 18 then prompt.MaxActivationDistance = 18 end
    end)
    local holdTime = 0; pcall(function() holdTime = math.max(prompt.HoldDuration or 0, 0) end)
    if fireproximityprompt then
        for i = 1, attempts do
            if not prompt or not prompt.Parent then break end
            pcall(fireproximityprompt, prompt)
            if holdTime > 0 then task.wait(holdTime + 0.05) else task.wait(0.05) end
        end
        return true
    end
    if holdTime > 0 then
        pcall(function() prompt:InputHoldBegin(); task.wait(holdTime + 0.12); prompt:InputHoldEnd() end)
    else
        for i = 1, attempts do
            if not prompt or not prompt.Parent then break end
            pcall(function() prompt:InputHoldBegin(); task.wait(0.06); prompt:InputHoldEnd() end)
            task.wait(0.04)
        end
    end
    return true
end

-- ============================================================
-- AUTO FARM & INSTA-SNIPE + EXACT WORKSPACE.GAME CACHES
-- ============================================================
local farmRunning = false
local farmStats = {collected=0, skipped=0, lastItem=""}
local cachedPrompts = {}
local cachedBundles = {}
local cachedBreakables = {}
local snipeInProgress = false
local bankRobInProgress = false

local SAFE_FOLDER_NAMES = {
    ["LargeSafe"]=true, ["MediumSafe"]=true, ["SmallSafe"]=true, ["GoldSafe"]=true, ["Safes"]=true,
}

local function IsCashBundleObj(obj)
    if not obj then return false end
    if not (obj:IsA("Model") or obj:IsA("BasePart")) then return false end
    local n = obj.Name
    if n == "CashBundle" or n == "Cash" or n == "MoneyBundle" then return true end
    if obj.Parent and obj.Parent.Name == "CashBundle" then return true end
    return false
end

local function IsBreakableATMOrSafe(obj)
    if not obj or not obj:IsA("Model") then return false end
    local nl = obj.Name:lower()
    local parName = obj.Parent and obj.Parent.Name or ""
    if parName == "ATM" or nl == "atm" or nl == "atmmachine" or (nl:find("atm", 1, true) and not nl:find("combat")) then
        return true
    end
    if parName == "CashRegister" or nl == "cashregister" or nl == "cash register" or nl:find("register", 1, true) then
        return true
    end
    if SAFE_FOLDER_NAMES[parName] or nl:find("safe", 1, true) then
        return true
    end
    return false
end

local function ScanWorkspaceContainers()
    local gameFolder = workspace:FindFirstChild("Game")
    if gameFolder then
        local entities = gameFolder:FindFirstChild("Entities")
        if entities then
            local itemPickup = entities:FindFirstChild("ItemPickup")
            if itemPickup then
                for _, d in ipairs(itemPickup:GetDescendants()) do
                    if d:IsA("ProximityPrompt") then
                        cachedPrompts[d] = true
                        if Config.InstantPrompt then pcall(function() d.HoldDuration = 0; d.RequiresLineOfSight = false end) end
                    end
                end
            end
            local cashFolder = entities:FindFirstChild("CashBundle")
            if cashFolder then
                for _, b in ipairs(cashFolder:GetChildren()) do
                    cachedBundles[b] = true
                end
            end
            for safeFolderName, _ in pairs(SAFE_FOLDER_NAMES) do
                local sf = entities:FindFirstChild(safeFolderName)
                if sf then
                    for _, s in ipairs(sf:GetChildren()) do
                        if s:IsA("Model") then cachedBreakables[s] = true end
                    end
                end
            end
        end
        local props = gameFolder:FindFirstChild("Props")
        if props then
            for _, fName in ipairs({"ATM", "ATMs", "CashRegister", "CashRegisters"}) do
                local pf = props:FindFirstChild(fName)
                if pf then
                    for _, m in ipairs(pf:GetChildren()) do
                        if m:IsA("Model") then cachedBreakables[m] = true end
                    end
                end
            end
        end
    end
end

task.spawn(function()
    ScanWorkspaceContainers()
    local count = 0
    for _, v in ipairs(workspace:GetDescendants()) do
        if not ScriptAlive then break end
        if v:IsA("ProximityPrompt") then
            cachedPrompts[v] = true
            if Config.InstantPrompt then pcall(function() v.HoldDuration = 0; v.RequiresLineOfSight = false end) end
        elseif IsCashBundleObj(v) then
            cachedBundles[v] = true
        elseif IsBreakableATMOrSafe(v) then
            cachedBreakables[v] = true
        end
        count = count + 1
        if count % 1000 == 0 then task.wait() end
    end
end)

TrackConn(workspace.DescendantAdded:Connect(function(v)
    if IsCashBundleObj(v) then
        cachedBundles[v] = true
    elseif IsBreakableATMOrSafe(v) then
        cachedBreakables[v] = true
    end
    if not v:IsA("ProximityPrompt") then return end
    cachedPrompts[v] = true
    if Config.InstantPrompt then pcall(function() v.HoldDuration = 0; v.RequiresLineOfSight = false end) end

    if not Config.AutoSnipe then return end
    if snipeInProgress then return end

    task.spawn(function()
        task.wait(0.08)
        if not ScriptAlive or not Config.AutoSnipe then return end
        if snipeInProgress then return end
        if not v or not v.Parent then return end

        local ok, matchedItem = QuickCheckPrompt(v, true)
        if not ok or not matchedItem then return end

        local initialPos = GetPromptPosition(v)
        if not initialPos then return end
        if not IsHumAlive() then return end
        if HasForceField() then return end

        local root = GetRoot()
        if not root then return end

        local savedPos = Vector3.new(root.Position.X, root.Position.Y, root.Position.Z)
        snipeInProgress = true

        local looted = false
        local timeout = tick() + 10

        while ScriptAlive and tick() < timeout do
            if not IsHumAlive() then break end
            if not v or not v.Parent or not v:IsDescendantOf(workspace) then
                looted = true
                break
            end

            local currentPos = GetPromptPosition(v)
            if currentPos then
                pcall(function()
                    local char = GetChar()
                    if char then
                        char:PivotTo(CFrame.new(currentPos + Vector3.new(0, 2.5, 0)))
                    else
                        root = GetRoot()
                        if root then root.CFrame = CFrame.new(currentPos + Vector3.new(0, 2.5, 0)) end
                    end
                end)
                task.wait(0.04)
            end

            if v and v.Parent then
                SafeFirePrompt(v, 3)
            end

            task.wait(0.05)
            if not v or not v.Parent or not v:IsDescendantOf(workspace) then
                looted = true
                break
            end
        end

        task.wait(0.08)
        if IsHumAlive() then
            pcall(function()
                local char = GetChar()
                if char then
                    char:PivotTo(CFrame.new(savedPos + Vector3.new(0, 3, 0)))
                else
                    local r = GetRoot()
                    if r then r.CFrame = CFrame.new(savedPos + Vector3.new(0, 3, 0)) end
                end
            end)
        end

        if looted then
            farmStats.collected = farmStats.collected + 1
            farmStats.lastItem = matchedItem
            Notify("🎯 SNIPED!", matchedItem, 2.5)
        end

        snipeInProgress = false
    end)
end))

TrackConn(workspace.DescendantRemoving:Connect(function(v)
    if cachedPrompts[v] then cachedPrompts[v] = nil end
    if cachedBundles[v] then cachedBundles[v] = nil end
    if cachedBreakables[v] then cachedBreakables[v] = nil end
end))

task.spawn(function()
    local failedPrompts = {}
    local FAIL_TIMEOUT = 8
    while ScriptAlive do
        task.wait(0.15)
        if not ScriptAlive then break end
        if not Config.Farm then farmRunning=false; failedPrompts={}; task.wait(0.5); continue end
        if snipeInProgress or bankRobInProgress then task.wait(0.15); continue end
        if not IsHumAlive() then task.wait(1); continue end
        if HasForceField() then RemoveShieldByMoving(); if HasForceField() then task.wait(1); continue end end
        farmRunning = true
        local root = GetRoot(); if not root then task.wait(0.5); continue end
        local priorityList, normalList = {}, {}
        local now = tick()
        for k, t in pairs(failedPrompts) do if now-t > FAIL_TIMEOUT then failedPrompts[k] = nil end end

        local maxBatch = Config.FarmBatchSize or 5
        local batchCount = 0

        for v, _ in pairs(cachedPrompts) do
            if not v or not v.Parent then cachedPrompts[v] = nil; continue end
            local uid = tostring(v); if failedPrompts[uid] then continue end
            local ok, matchedItem = QuickCheckPrompt(v, false); if not ok or not matchedItem then continue end
            local pos = GetPromptPosition(v); if not pos then continue end
            local dist = (root.Position-pos).Magnitude; if dist > (Config.FarmRange or 900) then continue end

            local isEn = false; pcall(function() isEn = v.Enabled end)
            if not isEn then continue end

            local entry = {prompt=v, name=matchedItem, pos=pos, dist=dist, uid=uid}
            if SnipePickerState[matchedItem] or PriorityLoot[matchedItem:lower()] then
                table.insert(priorityList, entry)
            else
                table.insert(normalList, entry)
            end
            batchCount = batchCount + 1
            if batchCount >= maxBatch * 3 then break end
        end

        table.sort(priorityList, function(a,b) return a.dist < b.dist end)
        table.sort(normalList, function(a,b) return a.dist < b.dist end)

        local allEntries = {}
        for _, e in ipairs(priorityList) do table.insert(allEntries, e) end
        for _, e in ipairs(normalList) do table.insert(allEntries, e) end
        if #allEntries == 0 then task.wait(0.8); continue end

        local processed = 0
        for _, entry in ipairs(allEntries) do
            if processed >= maxBatch then break end
            if not ScriptAlive or not Config.Farm or not IsHumAlive() then break end
            if snipeInProgress or bankRobInProgress then break end
            if HasForceField() then RemoveShieldByMoving(); if HasForceField() then break end end
            local prompt = entry.prompt; if not prompt or not prompt.Parent then continue end
            local myRoot = GetRoot(); if not myRoot then break end
            local pos = entry.pos
            local dist = (myRoot.Position-pos).Magnitude

            if dist > 12 then
                SafeTeleport(pos); task.wait(0.32)
            else
                pcall(function() myRoot.CFrame = CFrame.new(pos+Vector3.new(0,1,0)) end)
                task.wait(0.12)
            end
            if not Config.Farm or not IsHumAlive() or snipeInProgress or bankRobInProgress then break end
            if not prompt or not prompt.Parent then continue end

            local okAfterMove, _ = QuickCheckPrompt(prompt, false)
            local isEnNow = false; pcall(function() isEnNow = prompt.Enabled end)
            if not okAfterMove or not isEnNow then failedPrompts[entry.uid] = tick(); continue end

            if Config.InstantPrompt then pcall(function() prompt.HoldDuration = 0; prompt.RequiresLineOfSight = false end) end
            local holdTime = 0; pcall(function() holdTime = prompt.HoldDuration or 0 end)
            local maxHold = (Config.FarmMaxHold or 20) / 10
            if holdTime > maxHold then failedPrompts[entry.uid] = tick(); farmStats.skipped = farmStats.skipped+1; continue end

            local attempts = holdTime > 0 and 1 or 3
            local attemptDone = false
            task.spawn(function()
                local fireOk = SafeFirePrompt(prompt, attempts)
                if fireOk then
                    farmStats.collected = farmStats.collected + 1
                    farmStats.lastItem = entry.name
                else
                    failedPrompts[entry.uid] = tick()
                    farmStats.skipped = farmStats.skipped + 1
                end
                attemptDone = true
            end)

            local maxWait = math.max(holdTime * attempts + 1.0, 0.5)
            local waited = 0
            while not attemptDone and waited < maxWait do
                task.wait(0.05); waited = waited + 0.05
                if not Config.Farm or not IsHumAlive() or snipeInProgress or bankRobInProgress then break end
            end
            if not attemptDone then failedPrompts[entry.uid] = tick(); farmStats.skipped = farmStats.skipped+1 end
            processed = processed + 1
            task.wait((Config.FarmDelay or 18)/100)
            task.wait(0.05)
        end
        farmRunning = false
        task.wait(0.2)
    end
end)

-- ============================================================
-- CASH BUNDLE FARM
-- ============================================================
local moneyFarmRunning = false
local moneyFarmStats = {collected=0, total=0, skippedSmall=0}
local moneyFarmSavedPos = nil

local function GetAllCashBundles()
    local bundles = {}
    local entitiesFolder = workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Entities")
    if entitiesFolder then
        local cashBundleFolder = entitiesFolder:FindFirstChild("CashBundle")
        if cashBundleFolder then
            for _, bundle in ipairs(cashBundleFolder:GetChildren()) do
                table.insert(bundles, bundle)
            end
            return bundles
        end
    end
    for obj, _ in pairs(cachedBundles) do
        if obj and obj.Parent then
            table.insert(bundles, obj)
        else
            cachedBundles[obj] = nil
        end
    end
    return bundles
end

local function GetBundlePosition(bundle)
    if not bundle or not bundle.Parent then return nil end
    if bundle:IsA("BasePart") then return bundle.Position end
    if bundle:IsA("Model") then
        local primary = bundle.PrimaryPart; if primary then return primary.Position end
        local firstPart = bundle:FindFirstChildWhichIsA("BasePart", true); if firstPart then return firstPart.Position end
    end
    return nil
end

local function GetBundleValue(bundle)
    if not bundle or not bundle.Parent then return 0 end

    local foundAttr = nil
    pcall(function()
        for k, v in pairs(bundle:GetAttributes()) do
            if type(v) == "number" and v > 0 then
                foundAttr = v
                break
            end
            if type(v) == "string" then
                local n = tonumber((v):match("%d+"))
                if n and n > 0 then foundAttr = n; break end
            end
        end
    end)
    if foundAttr then return foundAttr end

    for _, child in ipairs(bundle:GetChildren()) do
        if child:IsA("IntValue") or child:IsA("NumberValue") then
            if child.Value and child.Value > 0 then return child.Value end
        end
        if child:IsA("StringValue") then
            local strNum = tonumber((child.Value or ""):match("%d+"))
            if strNum and strNum > 0 then return strNum end
        end
    end

    for _, child in ipairs(bundle:GetDescendants()) do
        if child:IsA("TextLabel") then
            local numStr = (child.Text or ""):gsub("[^%d]","")
            if numStr ~= "" then local num = tonumber(numStr); if num and num > 0 then return num end end
        end
    end

    local nameNum = bundle.Name:gsub("[^%d]","")
    if nameNum ~= "" then local num = tonumber(nameNum); if num and num > 0 then return num end end
    return 0
end

local function TriggerBundleInteractions(bundle, root)
    if not bundle or not bundle.Parent or not root then return end
    pcall(function()
        if bundle:IsA("ClickDetector") and fireclickdetector then
            fireclickdetector(bundle)
        end
        local directCD = bundle:FindFirstChildOfClass("ClickDetector")
        if directCD and fireclickdetector then
            fireclickdetector(directCD)
        end
        for _, child in ipairs(bundle:GetDescendants()) do
            if child:IsA("ClickDetector") and fireclickdetector then
                fireclickdetector(child)
            elseif child:IsA("ProximityPrompt") then
                SafeFirePrompt(child, 1)
            elseif child:IsA("BasePart") and firetouchinterest then
                firetouchinterest(root, child, 0)
                firetouchinterest(root, child, 1)
            end
        end
        if bundle:IsA("BasePart") and firetouchinterest then
            firetouchinterest(root, bundle, 0)
            firetouchinterest(root, bundle, 1)
        end
    end)
end

local function CollectOneCashBundle(bundle)
    if not bundle or not bundle.Parent then return false end
    local pos = GetBundlePosition(bundle); if not pos then return false end
    local root = GetRoot(); if not root then return false end
    if Config.MoneyMinSum > 0 then
        local val = GetBundleValue(bundle)
        if val > 0 and val < Config.MoneyMinSum then moneyFarmStats.skippedSmall = moneyFarmStats.skippedSmall+1; return false end
    end
    local ok = pcall(function()
        local char = GetChar()
        if char then char:PivotTo(CFrame.new(pos+Vector3.new(0,2.5,0)))
        else root.CFrame = CFrame.new(pos+Vector3.new(0,2.5,0)) end
    end)
    if not ok then pcall(function() root.CFrame = CFrame.new(pos+Vector3.new(0,2.5,0)) end) end
    TriggerBundleInteractions(bundle, root)
    task.wait(0.08)
    if not bundle.Parent then return true end
    local hum = GetHum(); if hum then pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end) end
    task.wait(0.06)
    if not bundle.Parent then return true end
    local offsets = {Vector3.new(0.4,0,0),Vector3.new(-0.4,0,0),Vector3.new(0,0,0.4),Vector3.new(0,0,-0.4),Vector3.new(0,-0.5,0)}
    for _, offset in ipairs(offsets) do
        if not bundle.Parent then break end
        if not IsHumAlive() or snipeInProgress then break end
        pcall(function() root = GetRoot(); if root then root.CFrame = CFrame.new(pos+offset+Vector3.new(0,2.5,0)) end end)
        TriggerBundleInteractions(bundle, root)
        task.wait(0.04)
    end
    return true
end

task.spawn(function()
    while ScriptAlive do
        task.wait(0.15)
        if not ScriptAlive then break end
        if not Config.MoneyFarm then moneyFarmRunning=false; moneyFarmSavedPos=nil; task.wait(0.5); continue end
        if snipeInProgress or bankRobInProgress then task.wait(0.2); continue end
        if not IsHumAlive() then task.wait(1); continue end
        if HasForceField() then RemoveShieldByMoving(); if HasForceField() then task.wait(1); continue end end
        moneyFarmRunning = true
        local bundles = GetAllCashBundles()
        if #bundles == 0 then moneyFarmSavedPos=nil; task.wait(2); continue end
        moneyFarmStats.total = #bundles
        local root = GetRoot(); if not root then task.wait(0.5); continue end
        if not moneyFarmSavedPos then moneyFarmSavedPos = root.Position end
        table.sort(bundles, function(a,b)
            local posA = GetBundlePosition(a); local posB = GetBundlePosition(b)
            if not posA then return false end; if not posB then return true end
            return (root.Position-posA).Magnitude < (root.Position-posB).Magnitude
        end)
        local collectedAny = false
        for _, bundle in ipairs(bundles) do
            if not ScriptAlive or not Config.MoneyFarm then break end
            if snipeInProgress or bankRobInProgress or not IsHumAlive() then break end
            if not bundle.Parent then continue end
            if CollectOneCashBundle(bundle) then moneyFarmStats.collected = moneyFarmStats.collected+1; collectedAny = true end
            task.wait(0.08)
        end
        if collectedAny and moneyFarmSavedPos and IsHumAlive() and not snipeInProgress and not bankRobInProgress then
            SafeTeleport(moneyFarmSavedPos); task.wait(0.2)
        end
        moneyFarmSavedPos = nil; moneyFarmRunning = false; task.wait(1.5)
    end
end)

-- ============================================================
-- 🏧 AUTO ATM, REGISTER & SAFE FARM (v.Screen Check + Snipe Pause)
-- ============================================================
local atmStats = {broken=0, cashCollected=0}
local atmCooldowns = {}

local function GetBreakablePosition(obj)
    if not obj or not obj.Parent then return nil end
    local pos = nil
    pcall(function()
        local screen = obj:FindFirstChild("Screen", true)
        if screen and screen:IsA("BasePart") then
            pos = screen.Position
        elseif obj:IsA("Model") then
            pos = (obj.PrimaryPart and obj.PrimaryPart.Position) or obj:GetPivot().Position
        elseif obj:IsA("BasePart") then
            pos = obj.Position
        end
    end)
    return pos
end

local function IsBreakableIntact(obj, ignoreFilter)
    if not obj or not obj.Parent then return false end
    local nl = obj.Name:lower()
    local parName = obj.Parent and obj.Parent.Name or ""

    local isReg = (parName == "CashRegister") or nl:find("register", 1, true) ~= nil
    local isSafe = SAFE_FOLDER_NAMES[parName] or nl:find("safe", 1, true) ~= nil

    if not ignoreFilter then
        if isReg and not Config.ATMIncludeRegisters then return false end
        if isSafe and not Config.ATMIncludeSafes then return false end
    end

    if atmCooldowns[obj] and (tick() - atmCooldowns[obj] < 38) then
        return false
    end

    local screen = obj:FindFirstChild("Screen")
    if screen and screen:IsA("BasePart") then
        if screen.Transparency >= 0.9 then return false end
        local sColor = screen.Color
        if sColor.R < 0.08 and sColor.G < 0.08 and sColor.B < 0.08 then
            return false
        end
    end

    local broken = false
    pcall(function()
        for k, v in pairs(obj:GetAttributes()) do
            local kl = k:lower()
            if (kl == "health" or kl == "hp") and type(v) == "number" and v <= 0 then
                broken = true
            elseif (kl == "broken" or kl == "destroyed" or kl == "disabled" or kl == "robbed" or kl == "open") and v == true then
                broken = true
            end
        end
    end)
    if broken then return false end

    for _, child in ipairs(obj:GetDescendants()) do
        local cn = child.Name:lower()
        if (child:IsA("IntValue") or child:IsA("NumberValue")) and (cn == "health" or cn == "hp") then
            if child.Value <= 0 then return false end
        elseif child:IsA("BoolValue") and (cn == "broken" or cn == "destroyed" or cn == "robbed" or cn == "open") then
            if child.Value == true then return false end
        end
    end

    local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart", true)
    if not part or part.Transparency >= 0.95 then return false end
    return true
end

local function EquipBestBreakerTool()
    local char = GetChar()
    local hum = GetHum()
    if not char or not hum then return nil end

    local currentTool = char:FindFirstChildOfClass("Tool")
    if currentTool then return currentTool end

    local bp = lp:FindFirstChildOfClass("Backpack")
    if not bp then return nil end

    local preferred = {
        "void scythe", "spectral scythe", "spirit kunai", "kunai", "fists", "fist",
        "crowbar", "fireaxe", "spiked baseball bat", "baseball bat", "katana",
        "saber", "tomahawk", "knife", "baton", "brass knuckles", "clown mallet"
    }
    for _, pref in ipairs(preferred) do
        for _, t in ipairs(bp:GetChildren()) do
            if t:IsA("Tool") and t.Name:lower():find(pref, 1, true) then
                pcall(function() hum:EquipTool(t) end)
                return t
            end
        end
    end

    local anyTool = bp:FindFirstChildOfClass("Tool")
    if anyTool then
        pcall(function() hum:EquipTool(anyTool) end)
        return anyTool
    end
    return nil
end

local function PerformBreakAttack(targetObj)
    local char = GetChar()
    local root = GetRoot()
    if not char or not root then return end

    local tool = EquipBestBreakerTool()
    if tool then
        pcall(function() tool:Activate() end)
    end

    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton1(Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2))
    end)

    for _, desc in ipairs(targetObj:GetDescendants()) do
        if desc:IsA("ProximityPrompt") and desc.Enabled then
            SafeFirePrompt(desc, 1)
        elseif desc:IsA("ClickDetector") and fireclickdetector then
            pcall(fireclickdetector, desc)
        end
    end
end

local function WaitIfSnipeActive()
    if not snipeInProgress then return false end
    while ScriptAlive and snipeInProgress do
        task.wait(0.08)
    end
    task.wait(0.12)
    return true
end

task.spawn(function()
    while ScriptAlive do
        task.wait(0.2)
        if not ScriptAlive then break end
        if not Config.ATMFarm then task.wait(0.4); continue end

        if snipeInProgress or bankRobInProgress then
            task.wait(0.2)
            continue
        end

        if not IsHumAlive() then task.wait(1); continue end
        if HasForceField() then RemoveShieldByMoving(); if HasForceField() then task.wait(1); continue end end

        local root = GetRoot()
        if not root then task.wait(0.5); continue end

        ScanWorkspaceContainers()

        local validTargets = {}
        for obj, _ in pairs(cachedBreakables) do
            if not obj or not obj.Parent then
                cachedBreakables[obj] = nil
            elseif IsBreakableIntact(obj, false) then
                local pos = GetBreakablePosition(obj)
                if pos then
                    table.insert(validTargets, {model=obj, pos=pos, dist=(root.Position - pos).Magnitude})
                end
            end
        end

        if #validTargets == 0 then
            for k, t in pairs(atmCooldowns) do
                if tick() - t > 20 then atmCooldowns[k] = nil end
            end
            task.wait(1.2)
            continue
        end

        table.sort(validTargets, function(a, b) return a.dist < b.dist end)
        local targetEntry = validTargets[1]
        local atm = targetEntry.model
        local atmPos = targetEntry.pos

        SafeTeleport(atmPos + Vector3.new(0, 0, 2.5))
        task.wait(0.2)

        local attackStart = tick()
        local maxBreakTime = 6.5

        while ScriptAlive and Config.ATMFarm and (tick() - attackStart < maxBreakTime) do
            if not IsHumAlive() or bankRobInProgress then break end

            if snipeInProgress then
                local pausedElapsed = tick() - attackStart
                WaitIfSnipeActive()
                if not Config.ATMFarm or not IsHumAlive() or bankRobInProgress then break end
                atmPos = GetBreakablePosition(atm) or atmPos
                SafeTeleport(atmPos + Vector3.new(0, 0, 2.5))
                task.wait(0.15)
                attackStart = tick() - pausedElapsed
            end

            if not IsBreakableIntact(atm, false) then
                break
            end

            atmPos = GetBreakablePosition(atm) or atmPos
            local myRoot = GetRoot()
            if myRoot then
                pcall(function()
                    local standPos = atmPos + Vector3.new(0, 1.5, 2.2)
                    myRoot.CFrame = CFrame.new(standPos, atmPos)
                    if Camera then
                        Camera.CFrame = CFrame.new(Camera.CFrame.Position, atmPos)
                    end
                end)
            end

            PerformBreakAttack(atm)
            task.wait(math.clamp((Config.ATMAttackDelay or 12) / 100, 0.05, 0.5))
        end

        atmCooldowns[atm] = tick()
        atmStats.broken = atmStats.broken + 1

        if Config.ATMCollectCash and Config.ATMFarm and IsHumAlive() and not bankRobInProgress then
            task.wait(0.22)
            for pass = 1, 2 do
                if not Config.ATMFarm or not IsHumAlive() or bankRobInProgress then break end
                if snipeInProgress then WaitIfSnipeActive() end
                local bundles = GetAllCashBundles()
                for _, b in ipairs(bundles) do
                    if not Config.ATMFarm or not IsHumAlive() or bankRobInProgress then break end
                    if snipeInProgress then WaitIfSnipeActive() end
                    local bPos = GetBundlePosition(b)
                    if bPos and (bPos - atmPos).Magnitude <= 35 then
                        if CollectOneCashBundle(b) then
                            atmStats.cashCollected = atmStats.cashCollected + 1
                            moneyFarmStats.collected = moneyFarmStats.collected + 1
                        end
                    end
                end
                task.wait(0.1)
            end
        end
    end
end)

-- ============================================================
-- 🏦 SMART BANK ROBBERY V80 (GEMS + CASH + GOLD SAFES + COOLDOWN CHECK)
-- ============================================================
local VAULT_RADIUS = 48
local bankStats = {robberies=0, itemsLooted=0}

local function IsPromptInsideBankVault(prompt)
    if not prompt or not prompt.Parent then return false, nil, nil end
    local isEn = false
    pcall(function() isEn = prompt.Enabled end)
    if not isEn then return false, nil, nil end

    local pos = GetPromptPosition(prompt)
    if not pos or (pos - COORDS.BANK_MONEY).Magnitude > VAULT_RADIUS then
        return false, nil, nil
    end

    local par = prompt.Parent
    local at = (prompt.ActionText or ""):lower():match("^%s*(.-)%s*$") or ""
    local ob = (prompt.ObjectText or ""):lower()
    local pn = (par.Name or ""):lower()
    local gpn = (par.Parent and par.Parent.Name or ""):lower()

    if HARD_BLOCKED_PAID_ACTIONS[at] or at:find("buy", 1, true) or at:find("%$") then
        return false, nil, nil
    end
    if IsBlacklistedText(pn) or IsBlacklistedText(at) then
        return false, nil, nil
    end

    -- 1. Перевіряємо через основний реєстр предметів (Dark Matter Gem, Void Gem, Diamond, Golden Crown, Rollie тощо)
    local matchedItem = ResolvePromptItemName(prompt)
    if matchedItem then
        return true, pos, matchedItem
    end

    -- 2. Перевіряємо специфічні стопки грошей та об'єкти банківського сховища
    local ft = pn .. " " .. gpn .. " " .. ob .. " " .. at
    if ft:find("steal", 1, true) or ft:find("rob", 1, true) or ft:find("vault", 1, true)
        or ft:find("money", 1, true) or ft:find("cash", 1, true) or ft:find("gold", 1, true)
        or ft:find("gem", 1, true) or ft:find("diamond", 1, true) or ft:find("ring", 1, true)
        or ft:find("crown", 1, true) or ft:find("watch", 1, true) or ft:find("rollie", 1, true)
        or ft:find("bullion", 1, true) or ft:find("loot", 1, true) then
        if not ft:find("money gun", 1, true) and not ft:find("money printer", 1, true) then
            return true, pos, (prompt.ObjectText ~= "" and prompt.ObjectText or par.Name)
        end
    end

    return false, nil, nil
end

local function GetBankVaultTargets()
    local promptsList = {}
    local safesList = {}
    local bundlesList = {}

    for v, _ in pairs(cachedPrompts) do
        if not v or not v.Parent then
            cachedPrompts[v] = nil
        else
            local ok, pos, label = IsPromptInsideBankVault(v)
            if ok and pos then
                table.insert(promptsList, {prompt=v, pos=pos, name=label or "Bank Loot"})
            end
        end
    end

    if Config.BankBreakSafes then
        for obj, _ in pairs(cachedBreakables) do
            if not obj or not obj.Parent then
                cachedBreakables[obj] = nil
            else
                local nl = obj.Name:lower()
                local parName = obj.Parent and obj.Parent.Name or ""
                local isSafe = SAFE_FOLDER_NAMES[parName] or nl:find("safe", 1, true) ~= nil
                if isSafe and IsBreakableIntact(obj, true) then
                    local pos = GetBreakablePosition(obj)
                    if pos and (pos - COORDS.BANK_MONEY).Magnitude <= VAULT_RADIUS then
                        table.insert(safesList, {model=obj, pos=pos})
                    end
                end
            end
        end
    end

    for _, b in ipairs(GetAllCashBundles()) do
        local bPos = GetBundlePosition(b)
        if bPos and (bPos - COORDS.BANK_MONEY).Magnitude <= VAULT_RADIUS then
            table.insert(bundlesList, {bundle=b, pos=bPos})
        end
    end

    return promptsList, safesList, bundlesList
end

local function ExecuteSmartBankSweep(manualTrigger)
    if bankRobInProgress then
        if manualTrigger then
            bankRobInProgress = false
            Notify("🏦 BANK", "Пограбування зупинено", 2)
        end
        return false
    end

    if not IsHumAlive() then
        if manualTrigger then Notify("🏦 BANK", "Ти мертвий!", 2) end
        return false
    end

    ScanWorkspaceContainers()
    local promptsList, safesList, bundlesList = GetBankVaultTargets()

    -- Якщо користувач натиснув кнопку вручну, а ми далеко від банку (стрімінг-радіус Roblox міг ще не підвантажити об'єкти)
    local root = GetRoot()
    local savedOrigin = root and root.Position or COORDS.SAFE_ZONE

    if #promptsList == 0 and #safesList == 0 and #bundlesList == 0 then
        if not manualTrigger and root and (root.Position - COORDS.BANK_MONEY).Magnitude < 180 then
            -- Ми поруч, і банк точно порожній (на кулдауні)
            return false
        end
    end

    if snipeInProgress then WaitIfSnipeActive() end
    if HasForceField() then RemoveShieldByMoving() end

    bankRobInProgress = true
    local totalLootedThisRun = 0

    -- Крок 1: Телепорт у сховище для підвантаження всіх об'єктів та швидкої перевірки
    SafeTeleport(COORDS.BANK_MONEY)
    task.wait(0.35)
    ScanWorkspaceContainers()
    promptsList, safesList, bundlesList = GetBankVaultTargets()

    if #promptsList == 0 and #safesList == 0 and #bundlesList == 0 then
        if manualTrigger then
            Notify("🏦 BANK COOLDOWN", "Сховище порожнє (на кулдауні)!", 3)
        end
        if Config.BankReturnSafeZone then
            SafeTeleport(COORDS.SAFE_ZONE)
        elseif savedOrigin then
            SafeTeleport(savedOrigin)
        end
        bankRobInProgress = false
        return false
    end

    Notify("🏦 BANK RAID", string.format("Знайдено: %d лут | %d сейфів | %d кеш", #promptsList, #safesList, #bundlesList), 2.5)

    -- Крок 2: Збираємо всі промпти у сховищі (Dark Matter Gem, Void Gem, Diamond, Стопки грошей)
    for pass = 1, 2 do
        if not ScriptAlive or not bankRobInProgress or not IsHumAlive() then break end
        promptsList, safesList, bundlesList = GetBankVaultTargets()

        for _, entry in ipairs(promptsList) do
            if not ScriptAlive or not bankRobInProgress or not IsHumAlive() then break end
            if snipeInProgress then
                WaitIfSnipeActive()
                SafeTeleport(COORDS.BANK_MONEY)
                task.wait(0.15)
            end
            local pr = entry.prompt
            if pr and pr.Parent and pr.Enabled then
                local pos = GetPromptPosition(pr) or entry.pos
                local myRoot = GetRoot()
                if myRoot and pos then
                    pcall(function() myRoot.CFrame = CFrame.new(pos + Vector3.new(0, 2.2, 0)) end)
                    task.wait(0.08)
                    if SafeFirePrompt(pr, 3) then
                        totalLootedThisRun = totalLootedThisRun + 1
                        bankStats.itemsLooted = bankStats.itemsLooted + 1
                    end
                    task.wait(0.08)
                end
            end
        end

        -- Крок 3: Ламаємо Золоті та Великі сейфи всередині сховища
        if Config.BankBreakSafes and #safesList > 0 then
            for _, sEntry in ipairs(safesList) do
                if not ScriptAlive or not bankRobInProgress or not IsHumAlive() then break end
                local safeModel = sEntry.model
                if safeModel and safeModel.Parent and IsBreakableIntact(safeModel, true) then
                    local sPos = GetBreakablePosition(safeModel) or sEntry.pos
                    SafeTeleport(sPos + Vector3.new(0, 0, 2.2))
                    task.wait(0.15)
                    local bStart = tick()
                    while ScriptAlive and bankRobInProgress and (tick() - bStart < 6.0) do
                        if not IsHumAlive() then break end
                        if snipeInProgress then
                            local elapsed = tick() - bStart
                            WaitIfSnipeActive()
                            sPos = GetBreakablePosition(safeModel) or sPos
                            SafeTeleport(sPos + Vector3.new(0, 0, 2.2))
                            task.wait(0.12)
                            bStart = tick() - elapsed
                        end
                        if not IsBreakableIntact(safeModel, true) then break end
                        local myRoot = GetRoot()
                        if myRoot then
                            pcall(function()
                                myRoot.CFrame = CFrame.new(sPos + Vector3.new(0, 1.5, 2.0), sPos)
                                if Camera then Camera.CFrame = CFrame.new(Camera.CFrame.Position, sPos) end
                            end)
                        end
                        PerformBreakAttack(safeModel)
                        task.wait(0.1)
                    end
                    atmCooldowns[safeModel] = tick()
                    atmStats.broken = atmStats.broken + 1
                    totalLootedThisRun = totalLootedThisRun + 1
                end
            end
        end

        -- Крок 4: Збираємо всі пачки CashBundle, що лежать або випали в сховищі
        _, _, bundlesList = GetBankVaultTargets()
        for _, bEntry in ipairs(bundlesList) do
            if not ScriptAlive or not bankRobInProgress or not IsHumAlive() then break end
            if snipeInProgress then WaitIfSnipeActive() end
            if bEntry.bundle and bEntry.bundle.Parent then
                if CollectOneCashBundle(bEntry.bundle) then
                    totalLootedThisRun = totalLootedThisRun + 1
                    moneyFarmStats.collected = moneyFarmStats.collected + 1
                end
            end
        end
        task.wait(0.15)
    end

    -- Крок 5: Відхід у Safe Zone або повернення на попередню точку
    if IsHumAlive() and not snipeInProgress then
        if Config.BankReturnSafeZone then
            SafeTeleport(COORDS.SAFE_ZONE)
        elseif savedOrigin then
            SafeTeleport(savedOrigin)
        end
    end

    if totalLootedThisRun > 0 then
        bankStats.robberies = bankStats.robberies + 1
        Notify("🏦 BANK CLEARED!", string.format("Забрано об'єктів у сховищі: %d", totalLootedThisRun), 3)
    end

    bankRobInProgress = false
    return totalLootedThisRun > 0
end

local function StartRobbery()
    task.spawn(function()
        ExecuteSmartBankSweep(true)
    end)
end

-- Фоновий цикл AutoBank (перевіряє сховище і грабує тільки коли банк активний)
task.spawn(function()
    local lastRemoteProbe = 0
    while ScriptAlive do
        task.wait(0.5)
        if not ScriptAlive then break end
        if not Config.AutoBank then task.wait(0.8); continue end
        if snipeInProgress or bankRobInProgress then task.wait(0.3); continue end
        if not IsHumAlive() then task.wait(1); continue end

        ScanWorkspaceContainers()
        local promptsList, safesList, bundlesList = GetBankVaultTargets()
        local hasTargets = (#promptsList > 0) or (#safesList > 0) or (#bundlesList > 0)

        -- Якщо ми далеко від банку і кеш порожній через StreamingEnabled, раз на N секунд перевіряємо сховище
        local probeInterval = math.max((Config.BankCheckInterval or 4) * 5, 12)
        if hasTargets or (tick() - lastRemoteProbe >= probeInterval) then
            lastRemoteProbe = tick()
            ExecuteSmartBankSweep(false)
        end
        task.wait(math.max(Config.BankCheckInterval or 4, 2))
    end
end)

-- ============================================================
-- AIM SYSTEM
-- ============================================================
local aimTarget = nil
local aimLocked = false
local aimLastSwitch = 0
local aimSwitchCD = 0.5
local aimLostFrames = 0
local aimLostMax = 45
local lastPing = 0
local pingTick = 0
local shadowSavedPos = nil

local function FindAimPart(char)
    if not char then return nil end
    local name = Config.AimPart or "Head"
    local p = char:FindFirstChild(name)
    if p and p:IsA("BasePart") then return p end
    p = char:FindFirstChild("Head"); if p and p:IsA("BasePart") then return p end
    p = char:FindFirstChild("HumanoidRootPart"); if p and p:IsA("BasePart") then return p end
    return nil
end

local function ScreenDist(part)
    if not part or not Camera then return math.huge end
    local pos, on = Camera:WorldToViewportPoint(part.Position)
    if not on then return math.huge end
    return (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
end

local function WallCheck(targetPosition)
    if not Config.AimWallCheck or not Camera then return true end
    local origin = Camera.CFrame.Position
    local direction = targetPosition - origin
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    local excludeList = {}
    for _, p in pairs(Players:GetPlayers()) do if p.Character then table.insert(excludeList, p.Character) end end
    local myChar = GetChar(); if myChar then table.insert(excludeList, myChar) end
    table.insert(excludeList, Camera)
    rayParams.FilterDescendantsInstances = excludeList
    rayParams.IgnoreWater = true
    local result = workspace:Raycast(origin, direction, rayParams)
    if result then
        local hitChar = result.Instance:FindFirstAncestorOfClass("Model")
        if hitChar and hitChar:FindFirstChildOfClass("Humanoid") then return true end
        return false
    end
    return true
end

local function FindNewTarget()
    if not Camera then return nil end
    local fov = Config.AimFOV or 200
    local best, bestDist = nil, math.huge
    local mousePos = IsPC and UIS:GetMouseLocation() or nil
    for _, p in pairs(Players:GetPlayers()) do
        if p == lp then continue end
        local char = p.Character; if not char then continue end
        local h = char:FindFirstChildOfClass("Humanoid"); if not h or h.Health <= 0 then continue end
        if IsPlayerInvincible(p) then continue end
        local part = FindAimPart(char); if not part then continue end
        local screenPoint, onScreen = Camera:WorldToViewportPoint(part.Position); if not onScreen then continue end
        if not WallCheck(part.Position) then continue end
        local distFromAim
        if IsPC and mousePos then
            distFromAim = (Vector2.new(screenPoint.X,screenPoint.Y)-mousePos).Magnitude
        else
            distFromAim = ScreenDist(part)
        end
        if distFromAim > fov then continue end
        if distFromAim < bestDist then bestDist = distFromAim; best = p end
    end
    return best
end

local function IsCurrentTargetValid()
    if not aimTarget or not aimTarget.Parent then return false end
    local char = aimTarget.Character; if not char then return false end
    local h = char:FindFirstChildOfClass("Humanoid"); if not h or h.Health <= 0 then return false end
    if IsPlayerInvincible(aimTarget) then return false end
    local part = FindAimPart(char); if not part then return false end
    if not WallCheck(part.Position) then return false end
    return true
end

local function GetBestAimTarget()
    if not Config.AimActive and not Config.SilentAim then
        aimTarget=nil; aimLocked=false; aimLostFrames=0; return nil
    end
    if aimTarget and aimLocked then
        if IsCurrentTargetValid() then
            local char = aimTarget.Character
            local part = FindAimPart(char)
            if part then
                local sd = ScreenDist(part)
                if sd <= (Config.AimFOV or 200) * 3 then aimLostFrames=0; return char end
                aimLostFrames = aimLostFrames + 1
                if aimLostFrames < aimLostMax then return char end
            end
        end
        aimTarget=nil; aimLocked=false; aimLostFrames=0
    end
    local now = tick()
    if now - aimLastSwitch < aimSwitchCD then return nil end
    local best = FindNewTarget()
    if best then aimTarget=best; aimLocked=true; aimLostFrames=0; aimLastSwitch=now; return best.Character end
    return nil
end

local function GetClosestByDist()
    local root = GetRoot(); if not root then return nil end
    local best, bestD = nil, math.huge
    for _, v in pairs(Players:GetPlayers()) do
        if v == lp then continue end
        if not IsTargetAlive(v) then continue end
        if IsPlayerInvincible(v) then continue end
        local h = v.Character and v.Character:FindFirstChild("HumanoidRootPart")
        if h then local d = (h.Position-root.Position).Magnitude; if d < bestD then bestD=d; best=v end end
    end
    return best
end

local Controls = nil
task.spawn(function()
    if not game:IsLoaded() then game.Loaded:Wait() end; task.wait(1)
    pcall(function() Controls = require(lp:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule",5)):GetControls() end)
end)

local MobUp, MobDn = false, false

-- ============================================================
-- SILENT AIM
-- ============================================================
local isShooting = false
local shootTouches = {}
local silentOrigCF = nil
local silentActive = false
local prevShooting = false
local silentSnapTime = 0
local useRaycastSilentHook = false

pcall(function()
    if hookmetamethod and getnamecallmethod then
        getgenv().MrkSilentCallback = function(self, method, args)
            if not ScriptAlive or not Config.SilentAim then return nil end
            if self ~= workspace then return nil end
            if method == "Raycast" and typeof(args[1]) == "Vector3" and typeof(args[2]) == "Vector3" then
                local tc = GetBestAimTarget()
                local part = tc and FindAimPart(tc)
                if part then
                    local vel = Vector3.zero
                    local rp = tc:FindFirstChild("HumanoidRootPart")
                    if rp then vel = rp.AssemblyLinearVelocity end
                    local predicted = part.Position + (vel * (Config.AimPrediction or 135) / 1000)
                    local origin = args[1]
                    local origMag = args[2].Magnitude
                    args[2] = (predicted - origin).Unit * math.max(origMag, (predicted - origin).Magnitude + 15)
                    return args
                end
            elseif (method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRay" or method == "FindPartOnRayWithWhitelist") and typeof(args[1]) == "Ray" then
                local tc = GetBestAimTarget()
                local part = tc and FindAimPart(tc)
                if part then
                    local vel = Vector3.zero
                    local rp = tc:FindFirstChild("HumanoidRootPart")
                    if rp then vel = rp.AssemblyLinearVelocity end
                    local predicted = part.Position + (vel * (Config.AimPrediction or 135) / 1000)
                    local origin = args[1].Origin
                    local origMag = args[1].Direction.Magnitude
                    args[1] = Ray.new(origin, (predicted - origin).Unit * math.max(origMag, (predicted - origin).Magnitude + 15))
                    return args
                end
            end
            return nil
        end

        if not getgenv().MrkSilentHookInstalled then
            getgenv().MrkSilentHookInstalled = true
            local oldNamecall
            oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
                local method = getnamecallmethod()
                local cb = getgenv().MrkSilentCallback
                if cb and (not checkcaller or not checkcaller()) then
                    if method == "Raycast" or method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRay" or method == "FindPartOnRayWithWhitelist" then
                        local modified = cb(self, method, {...})
                        if modified then
                            return oldNamecall(self, unpack(modified))
                        end
                    end
                end
                return oldNamecall(self, ...)
            end))
        end
        useRaycastSilentHook = true
    end
end)

TrackConn(UIS.TouchStarted:Connect(function(inp, gpe) if gpe then return end; shootTouches[inp]=true; isShooting=true end))
TrackConn(UIS.TouchEnded:Connect(function(inp) shootTouches[inp]=nil; isShooting=(next(shootTouches)~=nil) end))

local function DoSilentSnap()
    if not Config.SilentAim or useRaycastSilentHook or not Camera then return end
    local tc = GetBestAimTarget(); if not tc then return end
    local head = FindAimPart(tc); if not head then return end
    silentOrigCF = Camera.CFrame; silentActive = true; silentSnapTime = tick()
    local vel = Vector3.zero
    pcall(function() local rp=tc:FindFirstChild("HumanoidRootPart"); if rp then vel=rp.AssemblyLinearVelocity end end)
    Camera.CFrame = CFrame.new(Camera.CFrame.Position, head.Position + (vel * Config.AimPrediction / 1000))
end

local function RestoreSilentAim()
    if not silentActive then return end
    silentActive = false
    if silentOrigCF and Camera then Camera.CFrame = silentOrigCF; silentOrigCF = nil end
end

TrackConn(RS.RenderStepped:Connect(function()
    if workspace.CurrentCamera then Camera = workspace.CurrentCamera end
    if not Config.SilentAim then if silentActive then RestoreSilentAim() end; prevShooting=false; return end
    if useRaycastSilentHook then
        GetBestAimTarget()
        return
    end
    local shooting = IsPC and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or isShooting
    if shooting and not prevShooting then DoSilentSnap()
    elseif not shooting and prevShooting then RestoreSilentAim()
    elseif shooting and silentActive then
        local tc = GetBestAimTarget()
        if tc then
            local head = FindAimPart(tc)
            if head then
                local vel = Vector3.zero
                pcall(function() local rp=tc:FindFirstChild("HumanoidRootPart"); if rp then vel=rp.AssemblyLinearVelocity end end)
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, head.Position + (vel * Config.AimPrediction / 1000))
            end
        else RestoreSilentAim() end
    elseif not shooting and silentActive then RestoreSilentAim() end
    if silentActive and (tick() - silentSnapTime) > 0.5 then RestoreSilentAim() end
    prevShooting = shooting
end))

-- ============================================================
-- FPS / FULLBRIGHT / ANTI-AFK / AUTO SAFE
-- ============================================================
local fpsApplied = false
local function ApplyFPS()
    if fpsApplied then return end; fpsApplied = true
    pcall(function() settings().Rendering.QualityLevel=1; Light.GlobalShadows=false; Light.FogEnd=9e9 end)
    for _, v in pairs(Light:GetChildren()) do
        pcall(function()
            if v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("DepthOfFieldEffect") or v:IsA("ColorCorrectionEffect") then v.Enabled=false end
        end)
    end
    task.spawn(function()
        for _, v in pairs(workspace:GetDescendants()) do
            if not ScriptAlive then break end
            pcall(function()
                if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then v.Enabled=false end
            end)
        end
    end)
end

local sL = {}
local function EnableFB()
    pcall(function()
        sL.B=Light.Brightness; sL.C=Light.ClockTime; sL.F=Light.FogEnd
        sL.A=Light.Ambient; sL.O=Light.OutdoorAmbient; sL.G=Light.GlobalShadows
        Light.Brightness=2; Light.ClockTime=14; Light.FogEnd=100000
        Light.Ambient=Color3.fromRGB(178,178,178); Light.OutdoorAmbient=Color3.fromRGB(178,178,178); Light.GlobalShadows=false
    end)
    for _, v in pairs(Light:GetChildren()) do
        pcall(function() if v:IsA("Atmosphere") then v.Density=0; v.Offset=0 end end)
    end
end
local function DisableFB()
    pcall(function()
        if sL.B then Light.Brightness=sL.B; Light.ClockTime=sL.C; Light.FogEnd=sL.F; Light.Ambient=sL.A; Light.OutdoorAmbient=sL.O; Light.GlobalShadows=sL.G end
    end)
end

TrackConn(lp.Idled:Connect(function()
    if Config.AntiAFK then pcall(function() VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new()) end) end
end))
task.spawn(function() while ScriptAlive and task.wait(50) do if Config.AntiAFK then pcall(function() VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new()) end) end end end)

do
    local autoSafeCD = 0
    task.spawn(function()
        while ScriptAlive and task.wait(0.3) do
            if not Config.AutoSafe then continue end
            if not IsHumAlive() then continue end
            if tick() - autoSafeCD < 3 then continue end
            local hum = GetHum(); local root = GetRoot()
            if not hum or not root then continue end
            if hum.Health <= Config.SafeHealth then
                if (root.Position - COORDS.SAFE_ZONE).Magnitude > 20 then
                    SafeTeleport(COORDS.SAFE_ZONE); autoSafeCD = tick()
                    Notify("🛡 AUTO SAFE", "TP до Safe Zone! HP: "..math.floor(hum.Health), 3)
                end
            end
        end
    end)
end

-- ============================================================
-- PLAYER ESP & PRIORITY LOOT ESP
-- ============================================================
local ESPCache = {}
local LootESPCache = {}

local function ClearESP(c)
    if not c then return end
    pcall(function()
        local h = c:FindFirstChild("Head"); if h then local g=h:FindFirstChild("MrkESP"); if g then g:Destroy() end end
        local hl = c:FindFirstChild("MrkHL"); if hl then hl:Destroy() end
    end)
end
local function ClearAllESP()
    for _, v in pairs(Players:GetPlayers()) do if v ~= lp then ClearESP(v.Character) end end
    ESPCache = {}
end

local function ClearAllLootESP()
    for prompt, data in pairs(LootESPCache) do
        pcall(function() if data.gui then data.gui:Destroy() end end)
    end
    LootESPCache = {}
end

local function ResolveLootAdornee(prompt)
    local par = prompt and prompt.Parent
    if not par then return nil end
    if par:IsA("BasePart") or par:IsA("Attachment") then
        return par
    elseif par:IsA("Model") then
        return par.PrimaryPart or par:FindFirstChildWhichIsA("BasePart", true)
    end
    local ancestorPart = par:FindFirstAncestorWhichIsA("BasePart")
    if ancestorPart then return ancestorPart end
    return par:FindFirstChildWhichIsA("BasePart", true)
end

task.spawn(function()
    while ScriptAlive and task.wait(IsMobile and 0.2 or 0.08) do
        if Config.ESP then
            local myR = GetRoot()
            for _, v in pairs(Players:GetPlayers()) do
                if v == lp then continue end
                local char = v.Character
                local head = char and char:FindFirstChild("Head")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if not char or not head or not hum or hum.Health <= 0 then
                    if ESPCache[v] then ClearESP(char); ESPCache[v]=nil end; continue
                end
                local cache = ESPCache[v]
                if not cache or not cache.gui or not cache.gui.Parent then
                    if cache then ClearESP(char) end
                    local gui = Instance.new("BillboardGui"); gui.Name="MrkESP"
                    gui.Size = UDim2.new(0,IsMobile and 150 or 185,0,IsMobile and 42 or 50)
                    gui.StudsOffset = Vector3.new(0,3.2,0); gui.AlwaysOnTop=true
                    gui.MaxDistance = IsMobile and 250 or 450; gui.Parent=head
                    local bg = Instance.new("Frame",gui); bg.Size=UDim2.new(1,0,1,0)
                    bg.BackgroundColor3=Color3.fromRGB(0,0,0); bg.BackgroundTransparency=0.45; bg.BorderSizePixel=0
                    Instance.new("UICorner",bg)
                    local lbl = Instance.new("TextLabel",bg); lbl.Name="L"; lbl.Size=UDim2.new(1,0,1,0)
                    lbl.BackgroundTransparency=1; lbl.Font=Enum.Font.GothamBold
                    lbl.TextSize = IsMobile and 10 or 12; lbl.TextWrapped=true; lbl.TextStrokeTransparency=0.3
                    pcall(function()
                        local hl = Instance.new("Highlight"); hl.Name="MrkHL"; hl.FillColor=Color3.new(1,0,0)
                        hl.OutlineColor=Color3.new(1,1,1); hl.FillTransparency=0.65; hl.OutlineTransparency=0; hl.Adornee=char; hl.Parent=char
                    end)
                    ESPCache[v] = {gui=gui, lbl=lbl}; cache=ESPCache[v]
                end
                local dist = myR and math.floor((myR.Position-head.Position).Magnitude) or 0
                local hp = math.floor(hum.Health); local mH=math.max(math.floor(hum.MaxHealth),1); local r=hp/mH
                cache.lbl.Text = string.format("[%s]\nHP:%d/%d | %dm",v.Name,hp,mH,dist)
                cache.lbl.TextColor3 = r>=0.6 and Color3.fromRGB(0,255,100) or r>=0.3 and Color3.fromRGB(255,220,0) or Color3.fromRGB(255,60,60)
            end
        end
    end
end)

task.spawn(function()
    while ScriptAlive and task.wait(0.6) do
        if not Config.LootESP then
            if next(LootESPCache) ~= nil then ClearAllLootESP() end
            continue
        end
        local myR = GetRoot()
        for prompt, _ in pairs(cachedPrompts) do
            if not prompt or not prompt.Parent then
                if LootESPCache[prompt] then pcall(function() LootESPCache[prompt].gui:Destroy() end); LootESPCache[prompt]=nil end
                continue
            end
            local ok, matched = QuickCheckPrompt(prompt, true)
            if ok and matched then
                local pos = GetPromptPosition(prompt)
                local adornee = ResolveLootAdornee(prompt)
                if adornee and pos then
                    local entry = LootESPCache[prompt]
                    if not entry or not entry.gui or not entry.gui.Parent then
                        local gui = Instance.new("BillboardGui")
                        gui.Name = "MrkLootESP"
                        gui.Size = UDim2.new(0, 150, 0, 28)
                        gui.StudsOffset = Vector3.new(0, 2.2, 0)
                        gui.AlwaysOnTop = true
                        gui.Adornee = adornee
                        gui.Parent = adornee
                        local lbl = Instance.new("TextLabel", gui)
                        lbl.Size = UDim2.new(1, 0, 1, 0)
                        lbl.BackgroundTransparency = 0.35
                        lbl.BackgroundColor3 = Color3.fromRGB(20, 15, 0)
                        lbl.TextColor3 = Color3.fromRGB(255, 215, 0)
                        lbl.Font = Enum.Font.GothamBold
                        lbl.TextSize = IsMobile and 10 or 11
                        Instance.new("UICorner", lbl)
                        LootESPCache[prompt] = {gui = gui, lbl = lbl, name = matched}
                        entry = LootESPCache[prompt]
                    end
                    local d = myR and math.floor((myR.Position - pos).Magnitude) or 0
                    entry.lbl.Text = string.format("🎯 %s [%dm]", entry.name, d)
                end
            elseif LootESPCache[prompt] then
                pcall(function() LootESPCache[prompt].gui:Destroy() end)
                LootESPCache[prompt] = nil
            end
        end
    end
end)

TrackConn(Players.PlayerRemoving:Connect(function(p) if ESPCache[p] then ClearESP(p.Character); ESPCache[p]=nil end end))
for _, p in pairs(Players:GetPlayers()) do
    if p ~= lp then TrackConn(p.CharacterRemoving:Connect(function(c) if ESPCache[p] then ClearESP(c); ESPCache[p]=nil end end)) end
end
TrackConn(Players.PlayerAdded:Connect(function(p)
    TrackConn(p.CharacterRemoving:Connect(function(c) if ESPCache[p] then ClearESP(c); ESPCache[p]=nil end end))
end))

local function RestoreCollision()
    local c = GetChar(); if not c then return end
    for _, v in pairs(c:GetDescendants()) do
        if v:IsA("BasePart") then pcall(function() v.CanCollide=true; v.AssemblyLinearVelocity=Vector3.zero; v.AssemblyAngularVelocity=Vector3.zero end) end
    end
    local root = GetRoot()
    if root then
        task.wait(0.05)
        pcall(function() root.CFrame=root.CFrame+Vector3.new(0,2,0); root.AssemblyLinearVelocity=Vector3.zero end)
    end
end

-- ============================================================
-- SHADOW MAGNET + MAIN LOOPS + ANTI-RAGDOLL
-- ============================================================
local shadowState = {targetHighY=nil, highYStartTime=nil, HIGH_Y_DELAY=2.0, lastTargetY=nil}

TrackConn(RS.RenderStepped:Connect(function(dt)
    local now = tick()
    if now-pingTick > 3 then pingTick=now; pcall(function() lastPing=lp:GetNetworkPing() end) end
    if Config.Fly and IsHumAlive() and Camera then
        local root, hum = GetRoot(), GetHum()
        if root and hum then
            hum.PlatformStand = false
            local mx, mz = 0, 0
            if IsMobile and Controls then
                local mv = Controls:GetMoveVector(); mx=mv.X; mz=mv.Z
            elseif IsPC then
                if UIS:IsKeyDown(Enum.KeyCode.W) then mz=-1 end
                if UIS:IsKeyDown(Enum.KeyCode.S) then mz=1 end
                if UIS:IsKeyDown(Enum.KeyCode.A) then mx=-1 end
                if UIS:IsKeyDown(Enum.KeyCode.D) then mx=1 end
            end
            local cf = Camera.CFrame
            local dir = cf.LookVector * -mz + cf.RightVector * mx
            local upD = 0
            if UIS:IsKeyDown(Enum.KeyCode.Space) or MobUp then upD=1 end
            if UIS:IsKeyDown(Enum.KeyCode.LeftControl) or MobDn then upD=-1 end
            dir = dir + Vector3.new(0,upD,0)
            if dir.Magnitude > 1 then dir = dir.Unit end
            root.CFrame = root.CFrame + dir * Config.FlySpeedValue * dt
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
        end
    end
end))

pcall(function() RS:UnbindFromRenderStep("MrkAim") end)
RS:BindToRenderStep("MrkAim", 2000, function()
    if Config.AimActive and Camera then
        local target = GetBestAimTarget()
        local part = target and FindAimPart(target)
        if part then
            local vel = Vector3.zero
            pcall(function() local rp=target:FindFirstChild("HumanoidRootPart"); if rp then vel=rp.AssemblyLinearVelocity end end)
            local predictedPosition = part.Position + (vel * Config.AimPrediction / 1000)
            if Config.AimSmooth > 0 then
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, predictedPosition), Config.AimSmooth/100)
            else
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, predictedPosition)
            end
        end
    elseif not Config.SilentAim then
        aimTarget=nil; aimLocked=false; aimLostFrames=0
    end
end)

TrackConn(RS.Stepped:Connect(function()
    if Config.Noclip or Config.ShadowMagnet then
        local c = GetChar()
        if c then
            for _, v in pairs(c:GetDescendants()) do
                if v:IsA("BasePart") then
                    pcall(function() v.CanCollide = false end)
                end
            end
        end
    end
end))

pcall(function() RS:UnbindFromRenderStep("MrkSpeedHJ") end)
RS:BindToRenderStep("MrkSpeedHJ", 1, function()
    local hum = GetHum()
    if not hum or hum.Health <= 0 then return end

    if Config.Speed and not Config.Fly then
        hum.WalkSpeed = Config.WalkSpeedValue
    end

    if Config.HighJump then
        pcall(function()
            hum.UseJumpPower = true
            hum.JumpPower = Config.JumpPowerValue
            hum.JumpHeight = Config.JumpPowerValue * 0.4
        end)
    end
end)

TrackConn(RS.Heartbeat:Connect(function(dt)
    local hum, root = GetHum(), GetRoot()
    if not hum or not root then return end
    if Config.HighJump and hum.JumpPower ~= Config.JumpPowerValue then
        pcall(function() hum.UseJumpPower = true; hum.JumpPower = Config.JumpPowerValue end)
    end
    if Config.AntiSeat and hum.SeatPart then pcall(function() hum.Sit=false end) end
    if not Config.Fly and hum.PlatformStand then pcall(function() hum.PlatformStand=false end) end

    if Config.AntiRagdoll then
        pcall(function()
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            local st = hum:GetState()
            if st == Enum.HumanoidStateType.Ragdoll or st == Enum.HumanoidStateType.FallingDown then
                hum:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
        end)
    end

    if Config.ShadowMagnet then
        if not shadowSavedPos then shadowSavedPos=root.Position end
        if not IsTargetAlive(Config.ShadowTarget) or IsPlayerInvincible(Config.ShadowTarget) then
            Config.ShadowTarget=GetClosestByDist()
            shadowState.targetHighY=nil; shadowState.highYStartTime=nil; shadowState.lastTargetY=nil
        end
        if Config.ShadowTarget and IsTargetAlive(Config.ShadowTarget) and not IsPlayerInvincible(Config.ShadowTarget) then
            local tChar = Config.ShadowTarget.Character
            local tR = tChar and tChar:FindFirstChild("HumanoidRootPart")
            if tR then
                local depth = Config.ShadowDepth or 15
                local tPos = tR.Position; local tY = tPos.Y; local now = tick()
                local prevY = shadowState.lastTargetY or tY
                local deltaY = tY - prevY
                local isJumping = math.abs(deltaY) > 0.5 and deltaY > 0
                if isJumping then
                    if not shadowState.highYStartTime then shadowState.highYStartTime=now; shadowState.targetHighY=tY
                    else if tY > shadowState.targetHighY then shadowState.targetHighY=tY end end
                else
                    if shadowState.highYStartTime and (now-shadowState.highYStartTime >= shadowState.HIGH_Y_DELAY) then
                        shadowState.highYStartTime=nil; shadowState.targetHighY=nil
                    end
                end
                shadowState.lastTargetY = tY
                local targetShadowY = (shadowState.highYStartTime and now-shadowState.highYStartTime < shadowState.HIGH_Y_DELAY) and root.Position.Y or (tY - depth)
                local lookDir = tR.CFrame.LookVector
                local flatLook = Vector3.new(lookDir.X,0,lookDir.Z)
                if flatLook.Magnitude < 0.1 then flatLook=Vector3.new(1,0,0) end
                flatLook = flatLook.Unit
                local newY = root.Position.Y + (targetShadowY-root.Position.Y) * math.min(6*dt,1)
                local finalPos = Vector3.new(tPos.X,newY,tPos.Z)
                local lyingCF = CFrame.new(finalPos, finalPos+flatLook) * CFrame.Angles(math.rad(90),0,0)
                pcall(function()
                    root.CFrame = lyingCF
                    local tVel = tR.AssemblyLinearVelocity
                    root.AssemblyLinearVelocity = Vector3.new(tVel.X,0,tVel.Z)
                    root.AssemblyAngularVelocity = Vector3.zero
                end)
            end
        end
    else
        if shadowSavedPos then
            pcall(function()
                if IsHumAlive() then
                    RestoreCollision()
                    root.CFrame = CFrame.new(shadowSavedPos+Vector3.new(0,3,0))
                end
            end)
            shadowSavedPos=nil; Config.ShadowTarget=nil
            shadowState.targetHighY=nil; shadowState.highYStartTime=nil; shadowState.lastTargetY=nil
        end
    end

    if Config.Magnet and not Config.ShadowMagnet then
        if not IsTargetAlive(Config.MagnetTarget) or IsPlayerInvincible(Config.MagnetTarget) then
            Config.MagnetTarget = GetClosestByDist()
        end
        if Config.MagnetTarget and not IsPlayerInvincible(Config.MagnetTarget) then
            local tH = Config.MagnetTarget.Character and Config.MagnetTarget.Character:FindFirstChild("HumanoidRootPart")
            if tH then
                pcall(function()
                    root.CFrame = root.CFrame:Lerp(tH.CFrame * CFrame.new(0,0,3), IsMobile and 0.15 or 0.22)
                    root.AssemblyLinearVelocity = tH.AssemblyLinearVelocity
                end)
            end
        end
    elseif not Config.ShadowMagnet then
        Config.MagnetTarget = nil
    end
end))

local highJumpConnection = nil
local function SetupHighJumpDetector()
    if highJumpConnection then highJumpConnection:Disconnect(); highJumpConnection = nil end
    local hum = GetHum()
    if not hum then return end
    highJumpConnection = TrackConn(hum.StateChanged:Connect(function(oldState, newState)
        if newState == Enum.HumanoidStateType.Jumping and Config.HighJump then
            task.defer(function()
                if not Config.HighJump then return end
                local root = GetRoot()
                if root then
                    local vel = root.AssemblyLinearVelocity
                    root.AssemblyLinearVelocity = Vector3.new(vel.X, Config.JumpPowerValue, vel.Z)
                end
            end)
        end
    end))
end
task.spawn(SetupHighJumpDetector)

TrackConn(UIS.JumpRequest:Connect(function()
    local h = GetHum()
    if not h then return end
    if Config.HighJump then
        pcall(function() h.UseJumpPower = true; h.JumpPower = Config.JumpPowerValue end)
        task.delay(0.03, function()
            if not Config.HighJump then return end
            local root = GetRoot()
            if root then
                local vel = root.AssemblyLinearVelocity
                if vel.Y > 0 then root.AssemblyLinearVelocity = Vector3.new(vel.X, Config.JumpPowerValue, vel.Z) end
            end
        end)
    end
    if Config.InfJump then
        pcall(function() h:ChangeState(Enum.HumanoidStateType.Jumping) end)
    end
end))

local UpdFuncs = {}

TrackConn(lp.CharacterRemoving:Connect(function(char)
    shadowSavedPos=nil; aimTarget=nil; aimLocked=false; aimLostFrames=0
    silentActive=false; silentOrigCF=nil
    shadowState.targetHighY=nil; shadowState.highYStartTime=nil; shadowState.lastTargetY=nil
    moneyFarmSavedPos=nil; snipeInProgress=false; bankRobInProgress=false
    pcall(function() for _, v in pairs(char:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide=true end end end)
end))

TrackConn(lp.CharacterAdded:Connect(function(char)
    shadowSavedPos=nil; aimTarget=nil; aimLocked=false; aimLostFrames=0
    silentActive=false; silentOrigCF=nil
    shadowState.targetHighY=nil; shadowState.highYStartTime=nil; shadowState.lastTargetY=nil
    moneyFarmSavedPos=nil; snipeInProgress=false; bankRobInProgress=false
    cachedPrompts = {}; cachedBundles = {}; cachedBreakables = {}
    task.spawn(function() task.wait(1.5); SetupHighJumpDetector() end)
    task.wait(1.2)
    if workspace.CurrentCamera then Camera = workspace.CurrentCamera end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        if Config.Speed then pcall(function() hum.WalkSpeed = Config.WalkSpeedValue end) end
        if Config.HighJump then pcall(function() hum.UseJumpPower = true; hum.JumpPower = Config.JumpPowerValue end) end
    end
    for k, fn in pairs(UpdFuncs) do pcall(function() fn(Config[k]) end) end
    if UpdateFlyBtns_ then UpdateFlyBtns_() end
    task.spawn(function()
        ScanWorkspaceContainers()
        local count = 0
        for _, v in ipairs(workspace:GetDescendants()) do
            if not ScriptAlive then break end
            if v:IsA("ProximityPrompt") then
                cachedPrompts[v] = true
                if Config.InstantPrompt then pcall(function() v.HoldDuration = 0; v.RequiresLineOfSight = false end) end
            elseif IsCashBundleObj(v) then
                cachedBundles[v] = true
            elseif IsBreakableATMOrSafe(v) then
                cachedBreakables[v] = true
            end
            count = count + 1
            if count % 500 == 0 then task.wait() end
        end
    end)
end))

-- ============================================================
-- V80 GUI WITH RIGHT-CLICK & ⚙ SETTINGS DRAWERS
-- ============================================================
local safeScreenSize = Camera and Camera.ViewportSize or Vector2.new(1000,1000)
local isSmallScreen = IsMobile and (safeScreenSize.Y < 700 or safeScreenSize.X < 400)

local MW, MH
if isSmallScreen then MW=275; MH=420 elseif IsMobile then MW=335; MH=560 else MW=455; MH=660 end

local SG = Instance.new("ScreenGui")
SG.Name = "MarkiyanPro"
SG.ResetOnSpawn = false
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SG.IgnoreGuiInset = true

local coreGuiSuccess = pcall(function() SG.Parent = game:GetService("CoreGui") end)
if not coreGuiSuccess or not SG.Parent then
    SG.Parent = lp:WaitForChild("PlayerGui")
end

local Main = Instance.new("Frame",SG)
Main.Size = UDim2.new(0,MW,0,MH); Main.AnchorPoint=Vector2.new(0.5,0.5)
Main.Position = UDim2.new(0.5,0,0.5,0); Main.BackgroundColor3=Color3.fromRGB(11,12,18)
Main.BorderSizePixel = 0; Main.Visible=false
Instance.new("UICorner",Main).CornerRadius = UDim.new(0,12)
local mainStroke = Instance.new("UIStroke",Main)
mainStroke.Color = ColorThemes[currentThemeIndex].primary; mainStroke.Thickness=1.8

local headerTextSize = isSmallScreen and 11 or (IsMobile and 13 or 15)
local tabTextSize = isSmallScreen and 8 or (IsMobile and 9 or 11)
local btnTextSize = isSmallScreen and 10 or (IsMobile and 12 or 13)
local categoryTextSize = isSmallScreen and 9 or (IsMobile and 10 or 11)
local sliderTextSize = isSmallScreen and 9 or 11
local itemTextSize = isSmallScreen and 9 or (IsMobile and 10 or 11)
local headerH = isSmallScreen and 38 or 46

local Header, hGrad, HL
do
    Header = Instance.new("Frame",Main)
    Header.Size = UDim2.new(1,0,0,headerH); Header.BackgroundColor3=Color3.fromRGB(16,18,28); Header.BorderSizePixel=0
    Instance.new("UICorner",Header).CornerRadius = UDim.new(0,12)
    hGrad = Instance.new("UIGradient",Header)
    hGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,ColorThemes[currentThemeIndex].header1),
        ColorSequenceKeypoint.new(0.5,ColorThemes[currentThemeIndex].header2),
        ColorSequenceKeypoint.new(1,ColorThemes[currentThemeIndex].header1)
    })
    HL = Instance.new("TextLabel",Header)
    HL.Size = UDim2.new(1,-70,1,0); HL.Position=UDim2.new(0,12,0,0)
    HL.BackgroundTransparency = 1; HL.TextColor3=Color3.new(1,1,1)
    HL.Font = Enum.Font.GothamBlack; HL.TextSize=headerTextSize; HL.TextXAlignment=Enum.TextXAlignment.Left
    HL.Text = "⚡ MarkiyanPro V80"

    local subHint = Instance.new("TextLabel",Header)
    subHint.Size = UDim2.new(0,120,0,14); subHint.Position = UDim2.new(1,-162,0.5,-7)
    subHint.BackgroundTransparency = 1; subHint.TextColor3 = Color3.fromRGB(220,235,255)
    subHint.Font = Enum.Font.GothamBold; subHint.TextSize = isSmallScreen and 7 or 9
    subHint.TextXAlignment = Enum.TextXAlignment.Right
    subHint.Text = IsMobile and "⚙ = Настройки" or "ПКМ / ⚙ = Настройки"

    local closeSize = isSmallScreen and 22 or 26
    local CB = Instance.new("TextButton",Header)
    CB.Size = UDim2.new(0,closeSize,0,closeSize)
    CB.Position = UDim2.new(1,-(closeSize+8),0.5,-closeSize/2)
    CB.BackgroundColor3 = Color3.fromRGB(200,35,45); CB.Text="✕"; CB.TextColor3=Color3.new(1,1,1)
    CB.Font = Enum.Font.GothamBold; CB.TextSize=isSmallScreen and 10 or 12; CB.BorderSizePixel=0; CB.ZIndex=5
    Instance.new("UICorner",CB).CornerRadius = UDim.new(0,7)
    CB.MouseButton1Click:Connect(function() Main.Visible=false end)
end

local tabBarH = isSmallScreen and 28 or 32
local TabBar = Instance.new("Frame",Main)
TabBar.Size = UDim2.new(1,-12,0,tabBarH); TabBar.Position=UDim2.new(0,6,0,headerH+4)
TabBar.BackgroundColor3 = Color3.fromRGB(16,18,26); TabBar.BorderSizePixel=0
Instance.new("UICorner",TabBar).CornerRadius = UDim.new(0,8)
local TL = Instance.new("UIListLayout",TabBar)
TL.FillDirection = Enum.FillDirection.Horizontal; TL.HorizontalAlignment=Enum.HorizontalAlignment.Center
TL.VerticalAlignment = Enum.VerticalAlignment.Center; TL.Padding=UDim.new(0,4)

local scrollTop = headerH + tabBarH + 10
local Scroll = Instance.new("ScrollingFrame",Main)
Scroll.Size = UDim2.new(1,-10,1,-(scrollTop+6)); Scroll.Position=UDim2.new(0,5,0,scrollTop)
Scroll.BackgroundTransparency = 1; Scroll.BorderSizePixel=0; Scroll.ClipsDescendants=true
Scroll.ScrollBarThickness = IsMobile and 6 or 3; Scroll.ScrollBarImageColor3=ColorThemes[currentThemeIndex].primary
Scroll.ScrollingDirection = Enum.ScrollingDirection.Y; Scroll.ElasticBehavior=Enum.ElasticBehavior.Always

local LL = Instance.new("UIListLayout",Scroll)
LL.Padding = UDim.new(0,isSmallScreen and 4 or 5); LL.HorizontalAlignment=Enum.HorizontalAlignment.Center
LL.SortOrder = Enum.SortOrder.LayoutOrder
Instance.new("UIPadding",Scroll).PaddingTop = UDim.new(0,4)

local layoutCounter = 0
local function NextOrder()
    layoutCounter = layoutCounter + 1
    return layoutCounter
end

local function RefreshCanvas()
    local listHeight = LL and LL.AbsoluteContentSize.Y or 0
    Scroll.CanvasSize = UDim2.new(0,0,0,listHeight+24)
end
TrackConn(LL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(RefreshCanvas))

local fovC, fS, tI
do
    local currentFOV = Config.AimFOV or 200
    fovC = Instance.new("Frame",SG)
    fovC.Size = UDim2.new(0,currentFOV*2,0,currentFOV*2)
    fovC.Position = UDim2.new(0.5,-currentFOV,0.5,-currentFOV)
    fovC.BackgroundTransparency = 1; fovC.BorderSizePixel=0; fovC.Visible=false; fovC.ZIndex=10
    Instance.new("UICorner",fovC).CornerRadius = UDim.new(1,0)
    fS = Instance.new("UIStroke",fovC); fS.Color=ColorThemes[currentThemeIndex].primary; fS.Thickness=1.5; fS.Transparency=0.3
    tI = Instance.new("TextLabel",SG)
    tI.Size = UDim2.new(0,isSmallScreen and 180 or 220,0,isSmallScreen and 20 or 24)
    tI.Position = UDim2.new(0.5,isSmallScreen and -90 or -110,0.5,-(currentFOV+(isSmallScreen and 28 or 34)))
    tI.BackgroundColor3 = Color3.fromRGB(10,10,16); tI.BackgroundTransparency=0.25; tI.BorderSizePixel=0
    tI.TextColor3 = Color3.fromRGB(0,200,100); tI.Font=Enum.Font.GothamBold; tI.TextSize=isSmallScreen and 9 or 11
    tI.Text = ""; tI.Visible=false; tI.ZIndex=12
    Instance.new("UICorner",tI); Instance.new("UIStroke",tI).Color=Color3.fromRGB(40,40,58)
end

local statusHudLabel
do
    statusHudLabel = Instance.new("TextLabel",SG)
    statusHudLabel.Size = UDim2.new(0,isSmallScreen and 260 or 370,0,isSmallScreen and 24 or 28)
    statusHudLabel.Position = UDim2.new(0.5,isSmallScreen and -130 or -185,1,-(isSmallScreen and 95 or 105))
    statusHudLabel.BackgroundColor3 = Color3.fromRGB(12,18,28); statusHudLabel.BackgroundTransparency=0.18
    statusHudLabel.BorderSizePixel = 0; statusHudLabel.TextColor3=Color3.fromRGB(120,255,160)
    statusHudLabel.Font = Enum.Font.GothamBold; statusHudLabel.TextSize=isSmallScreen and 9 or 11
    statusHudLabel.Text = ""; statusHudLabel.Visible=false; statusHudLabel.ZIndex=15
    Instance.new("UICorner",statusHudLabel).CornerRadius = UDim.new(0,8)
    Instance.new("UIStroke",statusHudLabel).Color = ColorThemes[currentThemeIndex].primary
    task.spawn(function()
        while ScriptAlive and task.wait(0.4) do
            if Config.ATMFarm or Config.MoneyFarm or Config.AutoBank or bankRobInProgress then
                statusHudLabel.Visible = true
                local stateTxt = snipeInProgress and "⏸ SNIPE" or (bankRobInProgress and "🏦 BANK RAID" or "▶ ACTIVE")
                statusHudLabel.Text = string.format("🏦 Bank: %d | 🏧 ATM: %d | 💰 Cash: %d | 🎯 Snipe: %d [%s]",
                    bankStats.robberies, atmStats.broken, moneyFarmStats.collected, farmStats.collected, stateTxt)
            else
                statusHudLabel.Visible = false
            end
        end
    end)
end

local function UpdateFOV()
    local r = Config.AimFOV or 200
    fovC.Size = UDim2.new(0,r*2,0,r*2); fovC.Position=UDim2.new(0.5,-r,0.5,-r)
    tI.Position = UDim2.new(0.5,isSmallScreen and -90 or -110,0.5,-(r+(isSmallScreen and 28 or 34)))
end

do
    local fUT = 0
    TrackConn(RS.RenderStepped:Connect(function()
        local now = tick(); if now-fUT < 0.05 then return end; fUT=now
        fovC.Visible = Config.AimActive or Config.SilentAim; tI.Visible=false
        if Config.AimActive then
            local tc = aimTarget and aimTarget.Character
            local p = tc and FindAimPart(tc)
            if p and aimLocked and Camera then
                local plr = Players:GetPlayerFromCharacter(tc)
                local dist = math.floor((Camera.CFrame.Position-p.Position).Magnitude)
                tI.Text = "🔒 "..(plr and plr.Name or "?").." ["..dist.."m]"
                tI.TextColor3 = Color3.fromRGB(0,230,120); tI.Visible=true; fS.Color=Color3.fromRGB(0,200,100)
            else
                tI.Text = "🔍 Scanning..."; tI.TextColor3=Color3.fromRGB(180,180,100); tI.Visible=true; fS.Color=Color3.fromRGB(100,100,180)
            end
        elseif Config.SilentAim then
            local tc = aimTarget and aimTarget.Character
            local p = tc and FindAimPart(tc)
            if p and Camera then
                local plr = Players:GetPlayerFromCharacter(tc)
                local dist = math.floor((Camera.CFrame.Position-p.Position).Magnitude)
                tI.Text = "🔇 "..(plr and plr.Name or "?").." ["..dist.."m]"
                tI.TextColor3 = Color3.fromRGB(255,200,50); tI.Visible=true; fS.Color=Color3.fromRGB(255,200,50)
            else
                tI.Text = "No target"; tI.Visible=true; fS.Color=Color3.fromRGB(100,100,180)
            end
        end
    end))
end

local flyH
do
    local flyBtnSize = isSmallScreen and 48 or 60
    flyH = Instance.new("Frame",SG)
    flyH.Size = UDim2.new(0,flyBtnSize*2+16,0,flyBtnSize)
    flyH.Position = UDim2.new(0,10,1,-(flyBtnSize+120))
    flyH.BackgroundTransparency = 1; flyH.Visible=false; flyH.ZIndex=50
    local function MkFB(l, x, cb)
        local b = Instance.new("TextButton",flyH)
        b.Size = UDim2.new(0,flyBtnSize,0,flyBtnSize); b.Position=UDim2.new(0,x,0,0)
        b.BackgroundColor3 = Color3.fromRGB(14,16,24); b.Text=l; b.TextColor3=Color3.new(1,1,1)
        b.Font = Enum.Font.GothamBlack; b.TextSize=isSmallScreen and 22 or 28; b.BorderSizePixel=0; b.ZIndex=51; b.AutoButtonColor=false
        Instance.new("UICorner",b).CornerRadius = UDim.new(0,10)
        Instance.new("UIStroke",b).Color=Color3.fromRGB(45,50,70)
        b.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then cb(true); b.BackgroundColor3=Color3.fromRGB(35,45,75) end end)
        b.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then cb(false); b.BackgroundColor3=Color3.fromRGB(14,16,24) end end)
    end
    MkFB("▲",0,function(v) MobUp=v end); MkFB("▼",flyBtnSize+12,function(v) MobDn=v end)
end
UpdateFlyBtns_ = function() flyH.Visible = Config.Fly and IsMobile end

local ShortcutBtns = {}
local ShortcutDefs = {
    {key="AimActive", label="AIM", scKey="SC_Aim", color=Color3.fromRGB(220,50,50)},
    {key="SilentAim", label="SIL", scKey="SC_Silent", color=Color3.fromRGB(200,150,0)},
    {key="Fly", label="FLY", scKey="SC_Fly", color=Color3.fromRGB(0,110,230)},
    {key="Noclip", label="NC", scKey="SC_Noclip", color=Color3.fromRGB(0,165,105)},
    {key="Speed", label="SPD", scKey="SC_Speed", color=Color3.fromRGB(100,180,0)},
    {key="Farm", label="FRM", scKey="SC_Farm", color=Color3.fromRGB(200,120,0)},
    {key="ATMFarm", label="ATM", scKey="SC_ATM", color=Color3.fromRGB(0,160,130)},
    {key="AutoBank", label="🏦", scKey="SC_Bank", color=Color3.fromRGB(185,35,45)},
    {key="AutoSnipe", label="🎯", scKey="SC_Snipe", color=Color3.fromRGB(220,90,0)},
    {key="ShadowMagnet", label="SHD", scKey="SC_Shadow", color=Color3.fromRGB(110,30,190)},
    {key="HighJump", label="HJP", scKey="SC_HighJump", color=Color3.fromRGB(0,180,180)},
    {key="_SafeTP", label="SAFE", scKey="SC_Safe", color=Color3.fromRGB(0,130,65)},
    {key="MoneyFarm", label="💰", scKey="SC_MoneyFarm", color=Color3.fromRGB(185,145,0)},
}

local function ApplyFeatureSideEffects(key)
    if key=="Fly" then
        if UpdateFlyBtns_ then UpdateFlyBtns_() end
        if not Config.Fly then local h = GetHum(); if h then h.PlatformStand=false; h.WalkSpeed=16 end end
    elseif key=="AimActive" then
        aimTarget=nil; aimLocked=false; aimLostFrames=0
    elseif key=="Noclip" and not Config.Noclip then
        RestoreCollision()
    elseif key=="ShadowMagnet" then
        if Config.ShadowMagnet then shadowSavedPos=nil; shadowState.targetHighY=nil; shadowState.highYStartTime=nil; shadowState.lastTargetY=nil
        else Config.ShadowTarget=nil end
    elseif key=="ESP" and not Config.ESP then
        ClearAllESP()
    elseif key=="LootESP" and not Config.LootESP then
        ClearAllLootESP()
    elseif key=="Speed" then
        local h = GetHum(); if h then h.WalkSpeed = Config.Speed and Config.WalkSpeedValue or 16 end
    elseif key=="HighJump" then
        local h = GetHum(); if h then h.UseJumpPower=true; h.JumpPower=Config.HighJump and Config.JumpPowerValue or 50 end
    elseif key=="SilentAim" and not Config.SilentAim then
        RestoreSilentAim()
    elseif key=="Fullbright" then
        if Config.Fullbright then EnableFB() else DisableFB() end
    elseif key=="FPSBoost" and Config.FPSBoost then
        ApplyFPS()
    elseif key=="MoneyFarm" then
        moneyFarmStats.collected=0; moneyFarmStats.skippedSmall=0; moneyFarmSavedPos=nil
    elseif key=="AutoBank" and not Config.AutoBank then
        bankRobInProgress = false
    end
end

do
    local scBtnSize = isSmallScreen and 40 or 50
    local scBtnW = isSmallScreen and 44 or 54
    local scHolder = Instance.new("Frame",SG)
    scHolder.Size = UDim2.new(0,scBtnW,0,660); scHolder.Position=UDim2.new(1,-(scBtnW+6),0.08,0)
    scHolder.BackgroundTransparency = 1; scHolder.BorderSizePixel=0; scHolder.ZIndex=90
    local scLayout = Instance.new("UIListLayout",scHolder)
    scLayout.Padding = UDim.new(0,isSmallScreen and 3 or 4); scLayout.HorizontalAlignment=Enum.HorizontalAlignment.Center

    for _, def in ipairs(ShortcutDefs) do
        local btn = Instance.new("TextButton",scHolder)
        btn.Size = UDim2.new(0,scBtnSize,0,isSmallScreen and 30 or 36)
        btn.BackgroundColor3 = Color3.fromRGB(16,18,26); btn.TextColor3=Color3.fromRGB(185,190,205)
        btn.Font = Enum.Font.GothamBlack; btn.TextSize=isSmallScreen and 9 or 10
        btn.Text = def.label; btn.BorderSizePixel=0; btn.AutoButtonColor=false; btn.ZIndex=91; btn.Visible=Config[def.scKey] or false
        Instance.new("UICorner",btn).CornerRadius = UDim.new(0,8)
        local stroke = Instance.new("UIStroke",btn); stroke.Color=Color3.fromRGB(42,46,66); stroke.Thickness=1.2
        local function UpdateSC()
            local on = (def.key ~= "_SafeTP") and Config[def.key]
            if on then btn.BackgroundColor3=def.color; btn.TextColor3=Color3.new(1,1,1); stroke.Color=Color3.new(1,1,1)
            else btn.BackgroundColor3=Color3.fromRGB(16,18,26); btn.TextColor3=Color3.fromRGB(155,160,175); stroke.Color=Color3.fromRGB(42,46,66) end
            btn.Visible = Config[def.scKey] or false
        end
        if def.key == "_SafeTP" then
            btn.MouseButton1Click:Connect(function() if SafeTeleport(COORDS.SAFE_ZONE) then Notify("TP","➜ Safe Zone",2) end end)
        else
            btn.MouseButton1Click:Connect(function()
                Config[def.key] = not Config[def.key]; UpdateSC()
                ApplyFeatureSideEffects(def.key)
                if UpdFuncs[def.key] then UpdFuncs[def.key](Config[def.key]) end
                SaveSettings()
            end)
        end
        ShortcutBtns[def.key] = {btn=btn, update=UpdateSC, def=def}; UpdateSC()
    end
end

local function UpdateAllShortcuts() for _, sc in pairs(ShortcutBtns) do sc.update() end end

local themeRefs = {toggleBtns={}, sliderFills={}, catFrames={}, drawerFrames={}}
local MB
local Sections = {}; local TabButtons = {}; local ActiveTab = nil
local BindBtnRegistry = {}

local function ApplyThemeToAll()
    local theme = ColorThemes[currentThemeIndex]
    pcall(function() mainStroke.Color=theme.primary end)
    pcall(function() hGrad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,theme.header1),ColorSequenceKeypoint.new(0.5,theme.header2),ColorSequenceKeypoint.new(1,theme.header1)}) end)
    pcall(function() Scroll.ScrollBarImageColor3=theme.primary end)
    pcall(function() fS.Color=theme.primary end)
    if ActiveTab then
        for n, b in pairs(TabButtons) do
            if n == ActiveTab then b.BackgroundColor3=theme.primary; b.TextColor3=Color3.new(1,1,1)
            else b.BackgroundColor3=Color3.fromRGB(22,24,36); b.TextColor3=Color3.fromRGB(155,160,180) end
        end
    end
    for _, ref in pairs(themeRefs.toggleBtns) do pcall(function() if ref.getState and ref.getState() then ref.btn.BackgroundColor3=theme.secondary end end) end
    for _, fill in pairs(themeRefs.sliderFills) do pcall(function() fill.BackgroundColor3=theme.primary end) end
    for _, cf in pairs(themeRefs.catFrames) do pcall(function() cf.BackgroundColor3=theme.secondary end) end
    for _, ds in pairs(themeRefs.drawerFrames) do pcall(function() ds.Color=theme.primary end) end
    pcall(function() if MB then MB.BackgroundColor3=theme.primary end end)
end

local tabNames = {"Combat","Move","Farm","Misc","Items","Theme"}
local tabW = isSmallScreen and 41 or (IsMobile and 50 or 68)
local tabBtnH = isSmallScreen and 22 or 26

for _, n in ipairs(tabNames) do
    Sections[n] = {}
    local b = Instance.new("TextButton",TabBar)
    b.Size = UDim2.new(0,tabW,0,tabBtnH); b.BackgroundColor3=Color3.fromRGB(22,24,36); b.TextColor3=Color3.fromRGB(155,160,180)
    b.Font = Enum.Font.GothamBold; b.TextSize=tabTextSize; b.Text=n; b.BorderSizePixel=0; b.AutoButtonColor=false
    Instance.new("UICorner",b).CornerRadius = UDim.new(0,6); TabButtons[n]=b
end

do
    local d, s, p = false, nil, nil
    Header.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then d=true; s=i.Position; p=Main.Position end end)
    Header.InputChanged:Connect(function(i) if not d then return end; if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then local dl=i.Position-s; Main.Position=UDim2.new(p.X.Scale,p.X.Offset+dl.X,p.Y.Scale,p.Y.Offset+dl.Y) end end)
    Header.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then d=false end end)
    TrackConn(UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then d=false end end))
end

local BtnH = isSmallScreen and 36 or (IsMobile and 42 or 36)

local function RegisterSectionItem(tab, instance, isDrawer)
    table.insert(Sections[tab], {frame=instance, isDrawer=isDrawer or false, open=false})
end

local function AddCategory(tab, text)
    local catH = isSmallScreen and 20 or 24
    local f = Instance.new("Frame",Scroll); f.Size=UDim2.new(0.97,0,0,catH); f.LayoutOrder=NextOrder()
    f.BackgroundColor3 = ColorThemes[currentThemeIndex].secondary; f.BorderSizePixel=0; f.Visible=false
    Instance.new("UICorner",f).CornerRadius = UDim.new(0,6)
    local l = Instance.new("TextLabel",f); l.Size=UDim2.new(1,0,1,0); l.BackgroundTransparency=1
    l.TextColor3 = Color3.new(1,1,1); l.Font=Enum.Font.GothamBold; l.TextSize=categoryTextSize; l.Text="✦ "..text.." ✦"
    RegisterSectionItem(tab, f, false)
    table.insert(themeRefs.catFrames,f)
end

local function AddDrawerSlider(drawer, label, minV, maxV, def, cKey, cb)
    local sliderH = isSmallScreen and 42 or 46
    local f = Instance.new("Frame",drawer); f.Size=UDim2.new(1,0,0,sliderH)
    f.BackgroundColor3 = Color3.fromRGB(20,22,34); f.BorderSizePixel=0
    Instance.new("UICorner",f).CornerRadius = UDim.new(0,6)
    local cv = Config[cKey] or def
    local lbl = Instance.new("TextLabel",f); lbl.Size=UDim2.new(1,-10,0,18); lbl.Position=UDim2.new(0,6,0,2)
    lbl.BackgroundTransparency = 1; lbl.TextColor3=Color3.fromRGB(210,215,230); lbl.Font=Enum.Font.GothamBold; lbl.TextSize=sliderTextSize
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Text=label..": "..cv
    local trackH = 10
    local trackY = isSmallScreen and 24 or 26
    local tr = Instance.new("Frame",f); tr.Size=UDim2.new(0.92,0,0,trackH); tr.Position=UDim2.new(0.04,0,0,trackY)
    tr.BackgroundColor3 = Color3.fromRGB(38,42,60); tr.BorderSizePixel=0; Instance.new("UICorner",tr)
    local iR = math.clamp((cv-minV)/(maxV-minV),0,1)
    local fl = Instance.new("Frame",tr); fl.Size=UDim2.new(iR,0,1,0)
    fl.BackgroundColor3 = ColorThemes[currentThemeIndex].primary; fl.BorderSizePixel=0; Instance.new("UICorner",tr); Instance.new("UICorner",fl)
    table.insert(themeRefs.sliderFills,fl)
    local kS = 16
    local kn = Instance.new("Frame",tr); kn.Size=UDim2.new(0,kS,0,kS); kn.Position=UDim2.new(iR,-kS/2,0.5,-kS/2)
    kn.BackgroundColor3 = Color3.new(1,1,1); kn.BorderSizePixel=0; Instance.new("UICorner",kn).CornerRadius = UDim.new(1,0)
    local dg = false
    local function US(inp)
        local tW = tr.AbsoluteSize.X; if tW == 0 then tW=1 end
        local rel = math.clamp((inp.Position.X-tr.AbsolutePosition.X)/tW,0,1)
        local val = math.floor(minV+rel*(maxV-minV))
        fl.Size = UDim2.new(rel,0,1,0); kn.Position=UDim2.new(rel,-kS/2,0.5,-kS/2)
        lbl.Text = label..": "..val; Config[cKey]=val; if cb then cb(val) end
        shadowState.HIGH_Y_DELAY = (Config.ShadowJumpDelay or 20) / 10
    end
    tr.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dg=true; US(i) end end)
    TrackConn(UIS.InputChanged:Connect(function(i) if not dg then return end; if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then US(i) end end))
    TrackConn(UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dg=false; SaveSettings() end end))
end

local function AddDrawerSubToggle(drawer, label, cKey, cb)
    local b = Instance.new("TextButton",drawer)
    b.Size = UDim2.new(1,0,0,isSmallScreen and 28 or 30)
    b.Font = Enum.Font.GothamBold; b.TextSize = isSmallScreen and 9 or 11; b.BorderSizePixel = 0; b.AutoButtonColor = false
    Instance.new("UICorner",b).CornerRadius = UDim.new(0,6)
    local function Upd()
        if Config[cKey] then
            b.BackgroundColor3 = Color3.fromRGB(18,75,45)
            b.TextColor3 = Color3.fromRGB(130,255,165)
            b.Text = "  ✓ " .. label .. ": ON"
        else
            b.BackgroundColor3 = Color3.fromRGB(35,22,28)
            b.TextColor3 = Color3.fromRGB(235,130,130)
            b.Text = "  ✗ " .. label .. ": OFF"
        end
    end
    Upd()
    b.MouseButton1Click:Connect(function()
        Config[cKey] = not Config[cKey]
        Upd()
        if cb then cb(Config[cKey]) end
        SaveSettings()
    end)
end

local function AddFeature(tab, name, key, opts)
    opts = opts or {}
    local f = Instance.new("Frame",Scroll); f.Size=UDim2.new(0.97,0,0,BtnH); f.LayoutOrder=NextOrder()
    f.BackgroundTransparency = 1; f.BorderSizePixel=0; f.Visible=false
    RegisterSectionItem(tab, f, false)

    local btn = Instance.new("TextButton",f)
    btn.Size = UDim2.new(1,-(BtnH+4),1,0)
    btn.BackgroundColor3 = Color3.fromRGB(20,22,34); btn.TextColor3=Color3.fromRGB(200,205,220)
    btn.Font = Enum.Font.GothamBold; btn.TextSize=btnTextSize; btn.BorderSizePixel=0; btn.AutoButtonColor=false
    btn.TextXAlignment = Enum.TextXAlignment.Left; btn.Text="   "..name; Instance.new("UICorner",btn).CornerRadius = UDim.new(0,8)
    local btnStroke = Instance.new("UIStroke",btn); btnStroke.Color = Color3.fromRGB(38,42,62); btnStroke.Thickness = 1

    local dotSize = isSmallScreen and 8 or 10
    local dot = Instance.new("Frame",btn); dot.Size=UDim2.new(0,dotSize,0,dotSize); dot.AnchorPoint=Vector2.new(1,0.5)
    dot.Position = UDim2.new(1,-10,0.5,0); dot.BackgroundColor3=Color3.fromRGB(210,55,65)
    dot.BorderSizePixel = 0; dot.ZIndex=btn.ZIndex+1; Instance.new("UICorner",dot).CornerRadius = UDim.new(1,0)

    local gearBtn = Instance.new("TextButton",f)
    gearBtn.Size = UDim2.new(0,BtnH,1,0); gearBtn.Position = UDim2.new(1,-BtnH,0,0)
    gearBtn.BackgroundColor3 = Color3.fromRGB(24,27,42); gearBtn.TextColor3 = Color3.fromRGB(170,185,225)
    gearBtn.Font = Enum.Font.GothamBlack; gearBtn.TextSize = isSmallScreen and 13 or 15
    gearBtn.Text = "⚙"; gearBtn.BorderSizePixel = 0; gearBtn.AutoButtonColor = false
    Instance.new("UICorner",gearBtn).CornerRadius = UDim.new(0,8)
    local gearStroke = Instance.new("UIStroke",gearBtn); gearStroke.Color = Color3.fromRGB(42,48,72); gearStroke.Thickness = 1

    local drawer = Instance.new("Frame",Scroll)
    drawer.Size = UDim2.new(0.95,0,0,0)
    drawer.AutomaticSize = Enum.AutomaticSize.Y
    drawer.LayoutOrder = NextOrder()
    drawer.BackgroundColor3 = Color3.fromRGB(15,17,26)
    drawer.BorderSizePixel = 0; drawer.Visible = false
    Instance.new("UICorner",drawer).CornerRadius = UDim.new(0,8)
    local dStroke = Instance.new("UIStroke",drawer); dStroke.Color = ColorThemes[currentThemeIndex].primary; dStroke.Thickness = 1.2
    table.insert(themeRefs.drawerFrames, dStroke)

    local dPad = Instance.new("UIPadding",drawer)
    dPad.PaddingTop = UDim.new(0,6); dPad.PaddingBottom = UDim.new(0,6)
    dPad.PaddingLeft = UDim.new(0,8); dPad.PaddingRight = UDim.new(0,8)

    local dLayout = Instance.new("UIListLayout",drawer)
    dLayout.Padding = UDim.new(0,5); dLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local drawerRecord = {frame=drawer, isDrawer=true, open=false}
    table.insert(Sections[tab], drawerRecord)

    local topRow = Instance.new("Frame",drawer)
    topRow.Size = UDim2.new(1,0,0,isSmallScreen and 26 or 28); topRow.BackgroundTransparency = 1

    local bindBtn = Instance.new("TextButton",topRow)
    bindBtn.Size = opts.scKey and UDim2.new(0.49,0,1,0) or UDim2.new(1,0,1,0)
    bindBtn.BackgroundColor3 = Color3.fromRGB(24,28,44); bindBtn.TextColor3 = Color3.fromRGB(165,205,255)
    bindBtn.Font = Enum.Font.GothamBold; bindBtn.TextSize = isSmallScreen and 9 or 10; bindBtn.BorderSizePixel = 0
    Instance.new("UICorner",bindBtn).CornerRadius = UDim.new(0,6)

    local function UpdateBindText()
        local b = Binds[key]
        local bStr = (b and b ~= Enum.KeyCode.Unknown) and tostring(b):gsub("Enum%.KeyCode%.", "") or "NONE"
        bindBtn.Text = "⌨ Бінд: [" .. bStr .. "]"
        bindBtn.TextColor3 = Color3.fromRGB(165,205,255)
    end
    UpdateBindText()
    BindBtnRegistry[key] = UpdateBindText

    bindBtn.MouseButton1Click:Connect(function()
        if waitingForBind == key then
            Binds[key] = Enum.KeyCode.Unknown
            waitingForBind = nil; waitingBindBtn = nil
            UpdateBindText(); SaveSettings()
            return
        end
        waitingForBind = key
        waitingBindBtn = UpdateBindText
        bindBtn.Text = "⌨ Натисни (ПКМ=Скинути)"
        bindBtn.TextColor3 = Color3.fromRGB(255,220,60)
    end)
    bindBtn.MouseButton2Click:Connect(function()
        Binds[key] = Enum.KeyCode.Unknown
        waitingForBind = nil; waitingBindBtn = nil
        UpdateBindText(); SaveSettings()
    end)

    if opts.scKey then
        local scBtn = Instance.new("TextButton",topRow)
        scBtn.Size = UDim2.new(0.49,0,1,0); scBtn.Position = UDim2.new(0.51,0,0,0)
        scBtn.Font = Enum.Font.GothamBold; scBtn.TextSize = isSmallScreen and 9 or 10; scBtn.BorderSizePixel = 0
        Instance.new("UICorner",scBtn).CornerRadius = UDim.new(0,6)
        local function UpdSCBtn()
            if Config[opts.scKey] then
                scBtn.BackgroundColor3 = Color3.fromRGB(18,75,50)
                scBtn.TextColor3 = Color3.fromRGB(120,255,165)
                scBtn.Text = "📱 На екрані: ON"
            else
                scBtn.BackgroundColor3 = Color3.fromRGB(38,22,28)
                scBtn.TextColor3 = Color3.fromRGB(235,130,140)
                scBtn.Text = "📱 На екрані: OFF"
            end
            if ShortcutBtns[key] then ShortcutBtns[key].update() end
        end
        UpdSCBtn()
        scBtn.MouseButton1Click:Connect(function()
            Config[opts.scKey] = not Config[opts.scKey]
            UpdSCBtn(); SaveSettings()
        end)
    end

    if opts.buildDrawer then
        opts.buildDrawer(drawer)
    end

    local function ToggleDrawer()
        drawerRecord.open = not drawerRecord.open
        drawer.Visible = (ActiveTab == tab) and drawerRecord.open
        gearBtn.BackgroundColor3 = drawerRecord.open and ColorThemes[currentThemeIndex].primary or Color3.fromRGB(24,27,42)
        gearBtn.TextColor3 = drawerRecord.open and Color3.new(1,1,1) or Color3.fromRGB(170,185,225)
        task.defer(RefreshCanvas)
    end

    gearBtn.MouseButton1Click:Connect(ToggleDrawer)
    btn.MouseButton2Click:Connect(ToggleDrawer)

    local function Upd(s)
        local theme = ColorThemes[currentThemeIndex]
        if s then
            btn.BackgroundColor3=theme.secondary; btn.TextColor3=Color3.new(1,1,1)
            dot.BackgroundColor3=Color3.fromRGB(40,235,110); btnStroke.Color=theme.primary
            btn.Text="   "..name..": ON"
        else
            btn.BackgroundColor3=Color3.fromRGB(20,22,34); btn.TextColor3=Color3.fromRGB(200,205,220)
            dot.BackgroundColor3=Color3.fromRGB(210,55,65); btnStroke.Color=Color3.fromRGB(38,42,62)
            btn.Text="   "..name..": OFF"
        end
        if ShortcutBtns[key] then ShortcutBtns[key].update() end
    end

    table.insert(themeRefs.toggleBtns,{btn=btn, getState=function() return Config[key] end})
    UpdFuncs[key] = Upd; Upd(Config[key])

    btn.MouseButton1Click:Connect(function()
        Config[key] = not Config[key]; Upd(Config[key])
        ApplyFeatureSideEffects(key)
        SaveSettings(); Notify(name,Config[key] and "ON ✓" or "OFF ✗",1.5)
    end)
end

local function AddAction(tab, name, color, cb)
    local f = Instance.new("Frame",Scroll); f.Size=UDim2.new(0.97,0,0,BtnH); f.LayoutOrder=NextOrder()
    f.BackgroundTransparency = 1; f.BorderSizePixel=0; f.Visible=false
    RegisterSectionItem(tab, f, false)
    local btn = Instance.new("TextButton",f); btn.Size=UDim2.new(1,0,1,0); btn.BackgroundColor3=color
    btn.TextColor3 = Color3.new(1,1,1); btn.Font=Enum.Font.GothamBold; btn.TextSize=btnTextSize
    btn.BorderSizePixel = 0; btn.AutoButtonColor=false; btn.Text=name
    Instance.new("UICorner",btn).CornerRadius = UDim.new(0,8)
    btn.MouseButton1Click:Connect(function() task.spawn(cb) end)
end

local function AddTP(tab, name, vec)
    AddAction(tab, "📍 TP: "..name, Color3.fromRGB(24,28,46), function()
        if SafeTeleport(vec) then Notify("TP","➜ "..name,2) end
    end)
end

-- ============================================================
-- BUILD TABS (COMBAT, MOVE, FARM, MISC)
-- ============================================================
do
    AddCategory("Combat","AIM & ESP (ПКМ або ⚙ = Настройки)")
    AddFeature("Combat","AIM LOCK","AimActive",{
        scKey="SC_Aim",
        buildDrawer=function(d)
            AddDrawerSlider(d,"Радіус FOV",50,500,Config.AimFOV,"AimFOV",function(v) Config.AimFOV=v; UpdateFOV() end)
            AddDrawerSlider(d,"Упередження (x0.001)",100,250,Config.AimPrediction,"AimPrediction")
            AddDrawerSlider(d,"Плавність (0=Hard)",0,50,Config.AimSmooth,"AimSmooth")
            AddDrawerSubToggle(d,"Перевірка стін (WallCheck)","AimWallCheck")
        end
    })
    AddFeature("Combat","SILENT AIM (RAYCAST)","SilentAim",{
        scKey="SC_Silent",
        buildDrawer=function(d)
            AddDrawerSlider(d,"Радіус FOV",50,500,Config.AimFOV,"AimFOV",function(v) Config.AimFOV=v; UpdateFOV() end)
            AddDrawerSlider(d,"Упередження (x0.001)",100,250,Config.AimPrediction,"AimPrediction")
            AddDrawerSubToggle(d,"Перевірка стін (WallCheck)","AimWallCheck")
        end
    })
    AddFeature("Combat","PLAYER ESP","ESP",{})
    AddFeature("Combat","🎯 PRIORITY LOOT ESP","LootESP",{})

    AddCategory("Combat","MAGNET & UNDERGROUND")
    AddFeature("Combat","👻 SHADOW MAGNET","ShadowMagnet",{
        scKey="SC_Shadow",
        buildDrawer=function(d)
            AddDrawerSlider(d,"Глибина під землею",5,40,Config.ShadowDepth,"ShadowDepth")
            AddDrawerSlider(d,"Затримка стрибка (x100мс)",5,50,Config.ShadowJumpDelay,"ShadowJumpDelay",function(v) shadowState.HIGH_Y_DELAY=v/10 end)
        end
    })
    AddFeature("Combat","MAGNET (BEHIND)","Magnet",{})
end

do
    AddCategory("Move","MOVEMENT (ПКМ або ⚙ = Настройки)")
    AddFeature("Move","FLY (ПОЛІТ)","Fly",{
        scKey="SC_Fly",
        buildDrawer=function(d)
            AddDrawerSlider(d,"Швидкість польоту",10,IsPC and 250 or 150,Config.FlySpeedValue,"FlySpeedValue")
        end
    })
    AddFeature("Move","SPEED (ШВИДКІСТЬ)","Speed",{
        scKey="SC_Speed",
        buildDrawer=function(d)
            AddDrawerSlider(d,"Швидкість бігу",16,IsPC and 150 or 100,Config.WalkSpeedValue,"WalkSpeedValue",function(v)
                if Config.Speed then local h=GetHum(); if h then h.WalkSpeed=v end end
            end)
        end
    })
    AddFeature("Move","HIGH JUMP","HighJump",{
        scKey="SC_HighJump",
        buildDrawer=function(d)
            AddDrawerSlider(d,"Сила стрибка",50,300,Config.JumpPowerValue,"JumpPowerValue",function(v)
                if Config.HighJump then local h=GetHum(); if h then h.UseJumpPower=true; h.JumpPower=v end end
            end)
        end
    })
    AddFeature("Move","NOCLIP (КРІЗЬ СТІНИ)","Noclip",{scKey="SC_Noclip"})
    AddFeature("Move","INFINITE JUMP","InfJump",{})

    AddCategory("Move","ШВИДКІ ТЕЛЕПОРТИ")
    AddTP("Move","GUN SHOP (ЗБРОЯ)",COORDS.GUN_SHOP)
    AddTP("Move","BANK (БАНК)",COORDS.BANK_ENT)
    AddTP("Move","SAFE ZONE (СЕЙФ ЗОНА)",COORDS.SAFE_ZONE)
end

do
    AddCategory("Farm","🏦 БАНК, 🏧 ATM ТА 🎯 СНАЙП (ПКМ / ⚙)")
    AddFeature("Farm","🏦 AUTO ROB BANK (SMART)","AutoBank",{
        scKey="SC_Bank",
        buildDrawer=function(d)
            AddDrawerSubToggle(d,"Ламати Золоті/Великі сейфи в банку","BankBreakSafes")
            AddDrawerSubToggle(d,"Відходити у Safe Zone після зачистки","BankReturnSafeZone")
            AddDrawerSlider(d,"Інтервал перевірки банку (сек)",2,15,Config.BankCheckInterval,"BankCheckInterval")
        end
    })
    AddFeature("Farm","🏧 AUTO ATM & SAFE FARM","ATMFarm",{
        scKey="SC_ATM",
        buildDrawer=function(d)
            AddDrawerSubToggle(d,"Ламати Каси (Cash Register)","ATMIncludeRegisters")
            AddDrawerSubToggle(d,"Ламати Сейфи (Large/Med/Small/Gold)","ATMIncludeSafes")
            AddDrawerSubToggle(d,"Авто-збір грошей після зламу","ATMCollectCash")
            AddDrawerSlider(d,"Інтервал удару (x10мс)",5,35,Config.ATMAttackDelay,"ATMAttackDelay")
        end
    })
    AddFeature("Farm","🎯 INSTA-SNIPE (ПРІОРИТЕТ)","AutoSnipe",{
        scKey="SC_Snipe",
        buildDrawer=function(d)
            AddDrawerSubToggle(d,"Розумний снайп нових ліміток","SmartUnknownSnipe")
            AddDrawerSubToggle(d,"Миттєвий підбір (0с Hold)","InstantPrompt")
        end
    })
    AddFeature("Farm","📦 AUTO ITEM FARM","Farm",{
        scKey="SC_Farm",
        buildDrawer=function(d)
            AddDrawerSlider(d,"Дистанція фарму",50,2000,Config.FarmRange,"FarmRange")
            AddDrawerSlider(d,"Затримка між лутом (x10мс)",1,100,Config.FarmDelay,"FarmDelay")
            AddDrawerSlider(d,"Макс час затискання (x100мс)",1,50,Config.FarmMaxHold,"FarmMaxHold")
            AddDrawerSlider(d,"Предметів за цикл",1,20,Config.FarmBatchSize,"FarmBatchSize")
            AddDrawerSubToggle(d,"Миттєвий підбір (0с Hold)","InstantPrompt")
        end
    })
    AddFeature("Farm","💰 AUTO MONEY FARM","MoneyFarm",{
        scKey="SC_MoneyFarm",
        buildDrawer=function(d)
            AddDrawerSlider(d,"Мін. сума пачки ($)",0,5000,Config.MoneyMinSum,"MoneyMinSum")
        end
    })
    AddAction("Farm","🏦 ЗАЧИСТИТИ БАНК ЗАРАЗ (SMART RAID)",Color3.fromRGB(175,30,40),StartRobbery)
    AddAction("Farm","💰 ЗІБРАТИ ВСІ ГРОШІ ЗАРАЗ",Color3.fromRGB(150,115,10),function()
        if not IsHumAlive() then Notify("💰","Ти мертвий!",2); return end
        Notify("💰 COLLECT","Збираємо всі гроші...",3)
        local root = GetRoot(); local savedPos = root and root.Position or nil
        local bundles = GetAllCashBundles(); local count = 0
        for _, bundle in ipairs(bundles) do
            if not IsHumAlive() or snipeInProgress or bankRobInProgress then break end
            if not bundle.Parent then continue end
            CollectOneCashBundle(bundle); count=count+1; task.wait(0.08)
        end
        if savedPos and IsHumAlive() and not snipeInProgress and not bankRobInProgress then SafeTeleport(savedPos) end
        Notify("💰 COLLECT","Зібрано "..count.." бандлів!",3)
    end)
end

do
    AddCategory("Misc","ЗАХИСТ ТА ВІЗУАЛ (ПКМ / ⚙)")
    AddFeature("Misc","🛡 AUTO SAFE TP","AutoSafe",{
        scKey="SC_Safe",
        buildDrawer=function(d)
            AddDrawerSlider(d,"Поріг HP для втечі",5,80,Config.SafeHealth,"SafeHealth")
        end
    })
    AddFeature("Misc","ANTI-RAGDOLL / TASER","AntiRagdoll",{})
    AddFeature("Misc","FULLBRIGHT (ЯСКРАВІСТЬ)","Fullbright",{})
    AddFeature("Misc","FPS BOOST","FPSBoost",{})
    AddFeature("Misc","ANTI-SEAT","AntiSeat",{})
    AddFeature("Misc","ANTI-AFK","AntiAFK",{})

    AddCategory("Misc","🌐 КЕРУВАННЯ СЕРВЕРОМ")
    AddAction("Misc","🔀 SERVER HOP (Рандомний)",Color3.fromRGB(25,95,185),function() SaveSettings(); DoServerHop() end)
    AddAction("Misc","🔍 SMALL SERVER (Найменший)",Color3.fromRGB(115,35,175),function() SaveSettings(); DoJoinSmallServer() end)
    AddAction("Misc","👥 BIG SERVER (Найбільший)",Color3.fromRGB(185,65,15),function() SaveSettings(); DoJoinBigServer() end)
    AddAction("Misc","🔄 REJOIN (Перезайти)",Color3.fromRGB(20,130,85),function() SaveSettings(); DoRejoin() end)
end

-- ============================================================
-- ITEMS TAB (DUAL PICKER: ✓ AUTO FARM + 🎯 AUTO SNIPE)
-- ============================================================
local itemBtns = {}
local sB

do
    local iTotalLabel = Instance.new("Frame",Scroll)
    iTotalLabel.Size = UDim2.new(0.97,0,0,isSmallScreen and 26 or 30); iTotalLabel.LayoutOrder=NextOrder()
    iTotalLabel.BackgroundColor3 = Color3.fromRGB(20,38,78); iTotalLabel.BorderSizePixel=0; iTotalLabel.Visible=false
    Instance.new("UICorner",iTotalLabel).CornerRadius = UDim.new(0,7)
    RegisterSectionItem("Items", iTotalLabel, false)
    local iTL = Instance.new("TextLabel",iTotalLabel); iTL.Size=UDim2.new(1,0,1,0); iTL.BackgroundTransparency=1
    iTL.TextColor3 = Color3.new(1,1,1); iTL.Font=Enum.Font.GothamBold; iTL.TextSize=isSmallScreen and 8 or 10
    iTL.Text = "Ліва кнопка (✓) = AutoFarm | Права (🎯) = AutoSnipe ("..#ALL_ITEMS.." речей)"

    local searchH = isSmallScreen and 34 or 38
    local searchBtnH = isSmallScreen and 24 or 28
    local sFr = Instance.new("Frame",Scroll); sFr.Size=UDim2.new(0.97,0,0,searchH); sFr.LayoutOrder=NextOrder()
    sFr.BackgroundColor3 = Color3.fromRGB(18,20,30); sFr.BorderSizePixel=0; sFr.Visible=false
    Instance.new("UICorner",sFr).CornerRadius = UDim.new(0,8)
    RegisterSectionItem("Items", sFr, false)

    sB = Instance.new("TextBox",sFr); sB.Size=UDim2.new(0.46,-4,0,searchBtnH)
    sB.Position = UDim2.new(0,6,0.5,-searchBtnH/2); sB.BackgroundColor3=Color3.fromRGB(26,28,44)
    sB.TextColor3 = Color3.new(1,1,1); sB.PlaceholderText="🔍 Пошук предмета..."; sB.PlaceholderColor3=Color3.fromRGB(115,120,145)
    sB.Font = Enum.Font.Gotham; sB.TextSize=isSmallScreen and 9 or 11; sB.ClearTextOnFocus=false; sB.BorderSizePixel=0
    Instance.new("UICorner",sB).CornerRadius = UDim.new(0,6)

    local eA = Instance.new("TextButton",sFr); eA.Size=UDim2.new(0.16,0,0,searchBtnH)
    eA.Position = UDim2.new(0.47,2,0.5,-searchBtnH/2); eA.BackgroundColor3=Color3.fromRGB(15,115,55)
    eA.TextColor3 = Color3.new(1,1,1); eA.Font=Enum.Font.GothamBold; eA.TextSize=isSmallScreen and 8 or 9; eA.Text="Фарм✓"; eA.BorderSizePixel=0
    Instance.new("UICorner",eA).CornerRadius = UDim.new(0,6)

    local dAB = Instance.new("TextButton",sFr); dAB.Size=UDim2.new(0.16,0,0,searchBtnH)
    dAB.Position = UDim2.new(0.64,2,0.5,-searchBtnH/2); dAB.BackgroundColor3=Color3.fromRGB(145,30,35)
    dAB.TextColor3 = Color3.new(1,1,1); dAB.Font=Enum.Font.GothamBold; dAB.TextSize=isSmallScreen and 8 or 9; dAB.Text="Фарм✗"; dAB.BorderSizePixel=0
    Instance.new("UICorner",dAB).CornerRadius = UDim.new(0,6)

    local sPrio = Instance.new("TextButton",sFr); sPrio.Size=UDim2.new(0.18,0,0,searchBtnH)
    sPrio.Position = UDim2.new(0.81,2,0.5,-searchBtnH/2); sPrio.BackgroundColor3=Color3.fromRGB(190,105,0)
    sPrio.TextColor3 = Color3.new(1,1,1); sPrio.Font=Enum.Font.GothamBold; sPrio.TextSize=isSmallScreen and 8 or 9; sPrio.Text="🎯Топ"; sPrio.BorderSizePixel=0
    Instance.new("UICorner",sPrio).CornerRadius = UDim.new(0,6)

    eA.MouseButton1Click:Connect(function()
        local q = sB.Text:lower()
        for _, e in pairs(itemBtns) do if q=="" or e.itemName:lower():find(q,1,true) then ItemPickerState[e.itemName]=true; e.update() end end
        SaveSettings()
    end)
    dAB.MouseButton1Click:Connect(function()
        local q = sB.Text:lower()
        for _, e in pairs(itemBtns) do if q=="" or e.itemName:lower():find(q,1,true) then ItemPickerState[e.itemName]=false; e.update() end end
        SaveSettings()
    end)
    sPrio.MouseButton1Click:Connect(function()
        for _, e in pairs(itemBtns) do
            SnipePickerState[e.itemName] = PriorityLoot[e.itemName:lower()] and true or false
            e.update()
        end
        SaveSettings()
        Notify("🎯 AUTO SNIPE", "Вибрано тільки Пріоритетні/Лімітки 2026!", 2)
    end)
end

do
    local itemH = isSmallScreen and 28 or (IsMobile and 32 or 28)
    local catH_menu = isSmallScreen and 26 or (IsMobile and 30 or 28)
    local catBtnH = isSmallScreen and 18 or 20

    for _, cat in ipairs(ItemCategories) do
        local catF = Instance.new("Frame",Scroll); catF.Size=UDim2.new(0.97,0,0,catH_menu); catF.LayoutOrder=NextOrder()
        catF.BackgroundColor3 = cat.color; catF.BorderSizePixel=0; catF.Visible=false
        Instance.new("UICorner",catF).CornerRadius = UDim.new(0,6)
        RegisterSectionItem("Items", catF, false)

        local catLbl = Instance.new("TextLabel",catF); catLbl.Size=UDim2.new(0.62,0,1,0); catLbl.Position=UDim2.new(0,8,0,0)
        catLbl.BackgroundTransparency = 1; catLbl.TextColor3=Color3.new(1,1,1); catLbl.Font=Enum.Font.GothamBold
        catLbl.TextSize = isSmallScreen and 8 or 10; catLbl.TextXAlignment=Enum.TextXAlignment.Left
        catLbl.Text = cat.name.." ("..#cat.items..")"

        local catOn = Instance.new("TextButton",catF); catOn.Size=UDim2.new(0.11,0,0,catBtnH)
        catOn.Position = UDim2.new(0.64,0,0.5,-catBtnH/2); catOn.BackgroundColor3=Color3.fromRGB(0,105,45)
        catOn.TextColor3 = Color3.new(1,1,1); catOn.Font=Enum.Font.GothamBold; catOn.TextSize=8; catOn.Text="✓"; catOn.BorderSizePixel=0
        Instance.new("UICorner",catOn).CornerRadius = UDim.new(0,4)

        local catOff = Instance.new("TextButton",catF); catOff.Size=UDim2.new(0.11,0,0,catBtnH)
        catOff.Position = UDim2.new(0.76,0,0.5,-catBtnH/2); catOff.BackgroundColor3=Color3.fromRGB(130,25,25)
        catOff.TextColor3 = Color3.new(1,1,1); catOff.Font=Enum.Font.GothamBold; catOff.TextSize=8; catOff.Text="✗"; catOff.BorderSizePixel=0
        Instance.new("UICorner",catOff).CornerRadius = UDim.new(0,4)

        local catSnipe = Instance.new("TextButton",catF); catSnipe.Size=UDim2.new(0.11,0,0,catBtnH)
        catSnipe.Position = UDim2.new(0.88,0,0.5,-catBtnH/2); catSnipe.BackgroundColor3=Color3.fromRGB(195,110,0)
        catSnipe.TextColor3 = Color3.new(1,1,1); catSnipe.Font=Enum.Font.GothamBold; catSnipe.TextSize=8; catSnipe.Text="🎯"; catSnipe.BorderSizePixel=0
        Instance.new("UICorner",catSnipe).CornerRadius = UDim.new(0,4)

        local catItemBtns = {}
        for _, iN in ipairs(cat.items) do
            local f = Instance.new("Frame",Scroll); f.Size=UDim2.new(0.97,0,0,itemH); f.LayoutOrder=NextOrder()
            f.BackgroundTransparency = 1; f.BorderSizePixel=0; f.Visible=false
            RegisterSectionItem("Items", f, false)

            local b = Instance.new("TextButton",f); b.Size=UDim2.new(0.82,-3,1,0)
            b.Font = Enum.Font.GothamBold; b.TextSize=itemTextSize; b.BorderSizePixel=0; b.AutoButtonColor=false
            b.TextXAlignment = Enum.TextXAlignment.Left
            Instance.new("UICorner",b).CornerRadius = UDim.new(0,6)

            local snipeBtn = Instance.new("TextButton",f); snipeBtn.Size=UDim2.new(0.18,0,1,0); snipeBtn.Position=UDim2.new(0.82,3,0,0)
            snipeBtn.Font = Enum.Font.GothamBold; snipeBtn.TextSize=isSmallScreen and 9 or 10; snipeBtn.BorderSizePixel=0; snipeBtn.AutoButtonColor=false
            Instance.new("UICorner",snipeBtn).CornerRadius = UDim.new(0,6)

            local function U()
                if ItemPickerState[iN] then
                    b.BackgroundColor3 = Color3.fromRGB(16,58,34)
                    b.TextColor3 = Color3.fromRGB(120,255,155)
                    b.Text = "  ✓ " .. iN
                else
                    b.BackgroundColor3 = Color3.fromRGB(42,18,22)
                    b.TextColor3 = Color3.fromRGB(235,120,125)
                    b.Text = "  ✗ " .. iN
                end
                if SnipePickerState[iN] then
                    snipeBtn.BackgroundColor3 = Color3.fromRGB(195,115,10)
                    snipeBtn.TextColor3 = Color3.fromRGB(255,245,190)
                    snipeBtn.Text = "🎯 ON"
                else
                    snipeBtn.BackgroundColor3 = Color3.fromRGB(24,26,38)
                    snipeBtn.TextColor3 = Color3.fromRGB(120,125,145)
                    snipeBtn.Text = "🎯"
                end
            end
            U()
            b.MouseButton1Click:Connect(function() ItemPickerState[iN]=not ItemPickerState[iN]; U(); SaveSettings() end)
            snipeBtn.MouseButton1Click:Connect(function() SnipePickerState[iN]=not SnipePickerState[iN]; U(); SaveSettings() end)
            local entry = {frame=f, itemName=iN, update=U}
            table.insert(itemBtns,entry); table.insert(catItemBtns,entry)
        end
        catOn.MouseButton1Click:Connect(function() for _, e in pairs(catItemBtns) do ItemPickerState[e.itemName]=true; e.update() end; SaveSettings() end)
        catOff.MouseButton1Click:Connect(function() for _, e in pairs(catItemBtns) do ItemPickerState[e.itemName]=false; e.update() end; SaveSettings() end)
        catSnipe.MouseButton1Click:Connect(function()
            local anyOff = false
            for _, e in pairs(catItemBtns) do if not SnipePickerState[e.itemName] then anyOff = true; break end end
            for _, e in pairs(catItemBtns) do SnipePickerState[e.itemName] = anyOff; e.update() end
            SaveSettings()
        end)
    end
end

local function FilterItems(q)
    local ql = q:lower()
    for _, e in pairs(itemBtns) do
        e.frame.Visible = (ActiveTab=="Items") and (ql=="" or e.itemName:lower():find(ql,1,true)~=nil)
    end
    task.defer(RefreshCanvas)
end
TrackConn(sB:GetPropertyChangedSignal("Text"):Connect(function() if ActiveTab=="Items" then FilterItems(sB.Text) end end))

-- ============================================================
-- THEME TAB
-- ============================================================
do
    AddCategory("Theme","🎨 КОЛЬОРОВІ ТЕМИ V80")
    local themeBtnUpdaters = {}
    for idx, theme in ipairs(ColorThemes) do
        local themeF = Instance.new("Frame",Scroll); themeF.Size=UDim2.new(0.97,0,0,isSmallScreen and 36 or 40); themeF.LayoutOrder=NextOrder()
        themeF.BackgroundTransparency = 1; themeF.BorderSizePixel=0; themeF.Visible=false
        RegisterSectionItem("Theme", themeF, false)

        local themeBtn = Instance.new("TextButton",themeF); themeBtn.Size=UDim2.new(1,0,1,0)
        themeBtn.Font = Enum.Font.GothamBold; themeBtn.TextSize=isSmallScreen and 10 or 12
        themeBtn.BorderSizePixel = 0; themeBtn.AutoButtonColor=false
        Instance.new("UICorner",themeBtn).CornerRadius = UDim.new(0,8)
        local themeStroke = Instance.new("UIStroke",themeBtn); themeStroke.Thickness=1.5

        local function UpdateThisBtn()
            local isActive = (currentThemeIndex == idx)
            if isActive then
                themeStroke.Color=Color3.new(1,1,1); themeBtn.BackgroundColor3=theme.primary
                themeBtn.TextColor3=Color3.new(1,1,1); themeBtn.Text=theme.name.."  ✓ ACTIVE"
            else
                themeStroke.Color=theme.primary; themeBtn.BackgroundColor3=Color3.fromRGB(18,20,30)
                themeBtn.TextColor3=Color3.fromRGB(200,205,220); themeBtn.Text=theme.name
            end
        end
        UpdateThisBtn(); themeBtnUpdaters[idx]=UpdateThisBtn
        themeBtn.MouseButton1Click:Connect(function()
            currentThemeIndex=idx; Config.ThemeIndex=idx; ApplyThemeToAll()
            for _, upd in pairs(themeBtnUpdaters) do upd() end
            SaveSettings(); Notify("🎨 Тема",theme.name.." застосована!",2)
        end)
    end
end

-- ============================================================
-- SHOW TAB & INPUT HANDLER
-- ============================================================
local function ShowTab(n)
    ActiveTab = n
    for nn, list in pairs(Sections) do
        for _, item in ipairs(list) do
            pcall(function()
                if item.isDrawer then
                    item.frame.Visible = (nn == n) and item.open
                else
                    item.frame.Visible = (nn == n)
                end
            end)
        end
    end
    if n == "Items" then FilterItems(sB.Text) end
    local theme = ColorThemes[currentThemeIndex]
    for nn, b in pairs(TabButtons) do
        if nn == n then b.BackgroundColor3=theme.primary; b.TextColor3=Color3.new(1,1,1)
        else b.BackgroundColor3=Color3.fromRGB(22,24,36); b.TextColor3=Color3.fromRGB(155,160,180) end
    end
    task.defer(function()
        RefreshCanvas()
        Scroll.CanvasPosition = Vector2.zero
    end)
end
for n, b in pairs(TabButtons) do b.MouseButton1Click:Connect(function() ShowTab(n) end) end

TrackConn(UIS.InputBegan:Connect(function(inp, gpe)
    if waitingForBind then
        if inp.UserInputType == Enum.UserInputType.Keyboard then
            if inp.KeyCode == Enum.KeyCode.Escape or inp.KeyCode == Enum.KeyCode.Backspace then
                Binds[waitingForBind] = Enum.KeyCode.Unknown
            elseif inp.KeyCode ~= Enum.KeyCode.F then
                Binds[waitingForBind] = inp.KeyCode
            end
            if waitingBindBtn then pcall(waitingBindBtn) end
            waitingForBind = nil; waitingBindBtn = nil
            SaveSettings()
        end
        return
    end
    if gpe then return end
    if inp.KeyCode == Enum.KeyCode.F or inp.KeyCode == Enum.KeyCode.Unknown then return end
    for a, k in pairs(Binds) do
        if inp.KeyCode ~= k then continue end
        if a == "ToggleUI" then
            Main.Visible = not Main.Visible
        elseif Config[a] ~= nil then
            Config[a] = not Config[a]
            ApplyFeatureSideEffects(a)
            if UpdFuncs[a] then UpdFuncs[a](Config[a]) end
            UpdateAllShortcuts()
            Notify(a, Config[a] and "ON ✓" or "OFF ✗", 1.2)
            SaveSettings()
        end
    end
end))

-- ============================================================
-- FLOATING MENU BUTTON
-- ============================================================
do
    local MS = isSmallScreen and 44 or (IsMobile and 54 or 44)
    MB = Instance.new("TextButton",SG)
    MB.Size = UDim2.new(0,MS,0,MS); MB.Position=UDim2.new(0,10,0.25,0)
    MB.Text = "M"; MB.Font=Enum.Font.GothamBlack; MB.TextSize=isSmallScreen and 18 or (IsMobile and 22 or 20)
    MB.BackgroundColor3 = ColorThemes[currentThemeIndex].primary; MB.TextColor3=Color3.new(1,1,1)
    MB.BorderSizePixel = 0; MB.AutoButtonColor=false; MB.ZIndex=100
    Instance.new("UICorner",MB).CornerRadius = UDim.new(0,12)
    Instance.new("UIStroke",MB).Color=Color3.new(1,1,1)

    local d, s, p, t, m = false, nil, nil, 0, false
    MB.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            d=true; s=i.Position; p=MB.Position; t=tick(); m=false
        end
    end)
    MB.InputChanged:Connect(function(i)
        if not d then return end
        if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then
            local dl = i.Position-s; if dl.Magnitude > 8 then m=true end
            MB.Position = UDim2.new(p.X.Scale,p.X.Offset+dl.X,p.Y.Scale,p.Y.Offset+dl.Y)
        end
    end)
    MB.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            if d and not m and tick()-t < 0.3 then Main.Visible=not Main.Visible end
            d=false
        end
    end)
    TrackConn(UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then d=false end end))
end

-- ============================================================
-- REVERSE PATH (CLEANUP)
-- ============================================================
getgenv().MarkiyanCleanup = function()
    ScriptAlive = false
    bankRobInProgress = false
    snipeInProgress = false
    getgenv().MrkSilentCallback = nil
    for _, conn in ipairs(ActiveConnections) do
        pcall(function() conn:Disconnect() end)
    end
    table.clear(ActiveConnections)
    pcall(function() RS:UnbindFromRenderStep("MrkAim") end)
    pcall(function() RS:UnbindFromRenderStep("MrkSpeedHJ") end)
    pcall(ClearAllESP)
    pcall(ClearAllLootESP)
    pcall(RestoreSilentAim)
    pcall(function() if SG and SG.Parent then SG:Destroy() end end)
end

-- ============================================================
-- INIT
-- ============================================================
ShowTab("Farm")
ApplyThemeToAll()
if Config.Fullbright then task.spawn(EnableFB) end
if Config.FPSBoost then task.spawn(ApplyFPS) end
task.spawn(function()
    task.wait(2)
    if not ScriptAlive then return end
    local hum = GetHum()
    if hum then
        if Config.Speed then pcall(function() hum.WalkSpeed = Config.WalkSpeedValue end) end
        if Config.HighJump then pcall(function() hum.UseJumpPower=true; hum.JumpPower=Config.JumpPowerValue end) end
    end
end)
UpdateAllShortcuts()
if UpdateFlyBtns_ then UpdateFlyBtns_() end

if loadedDataStatus then Notify("💾 CONFIG", "Налаштування V80 завантажено!", 3) end
Notify("⚡ MarkiyanPro V80", "Smart Bank Raid + ATM/Safes + 2026 DB!", 5)
