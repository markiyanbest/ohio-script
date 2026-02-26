-- ============================================================
-- GUI (ФІКС ДЛЯ ТЕЛЕФОНІВ — МЕНШИЙ РОЗМІР + FLY КНОПКИ ПЕРЕМІЩЕНІ)
-- ============================================================
local SG = Instance.new("ScreenGui")
SG.Name="MarkiyanPro"; SG.ResetOnSpawn=false
SG.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; SG.IgnoreGuiInset=true
pcall(function() SG.Parent=game:GetService("CoreGui") end)
if not SG.Parent or not SG.Parent.Name then SG.Parent=lp:WaitForChild("PlayerGui") end

-- ★★★ АДАПТИВНИЙ РОЗМІР ДЛЯ ТЕЛЕФОНІВ ★★★
local screenSize = SG.AbsoluteSize
local isSmallScreen = IsMobile and (screenSize.Y < 700 or screenSize.X < 400)

local MW, MH
if isSmallScreen then
	MW = 240
	MH = 400
elseif IsMobile then
	MW = 300
	MH = 560
else
	MW = 420
	MH = 660
end

local Main=Instance.new("Frame",SG)
Main.Size=UDim2.new(0,MW,0,MH); Main.AnchorPoint=Vector2.new(0.5,0.5)
Main.Position=UDim2.new(0.5,0,0.5,0); Main.BackgroundColor3=Color3.fromRGB(8,8,14)
Main.BorderSizePixel=0; Main.Visible=false
Instance.new("UICorner",Main)
local mainStroke=Instance.new("UIStroke",Main); mainStroke.Color=Color3.fromRGB(0,120,255); mainStroke.Thickness=1.5

-- ★★★ АДАПТИВНІ РОЗМІРИ ТЕКСТУ ★★★
local headerTextSize = isSmallScreen and 11 or (IsMobile and 13 or 15)
local tabTextSize = isSmallScreen and 8 or (IsMobile and 9 or 11)
local btnTextSize = isSmallScreen and 10 or (IsMobile and 12 or 13)
local categoryTextSize = isSmallScreen and 9 or (IsMobile and 10 or 11)
local sliderTextSize = isSmallScreen and 10 or 12
local itemTextSize = isSmallScreen and 9 or (IsMobile and 10 or 11)

local headerH = isSmallScreen and 36 or 44
local Header=Instance.new("Frame",Main)
Header.Size=UDim2.new(1,0,0,headerH); Header.BackgroundColor3=Color3.fromRGB(10,10,20); Header.BorderSizePixel=0
Instance.new("UICorner",Header)
local hGrad=Instance.new("UIGradient",Header)
hGrad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(0,50,180)),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(0,130,255)),ColorSequenceKeypoint.new(1,Color3.fromRGB(0,50,180))})

local HL=Instance.new("TextLabel",Header)
HL.Size=UDim2.new(1,-55,1,0); HL.Position=UDim2.new(0,10,0,0)
HL.BackgroundTransparency=1; HL.TextColor3=Color3.new(1,1,1)
HL.Font=Enum.Font.GothamBlack; HL.TextSize=headerTextSize
HL.TextXAlignment=Enum.TextXAlignment.Left
HL.Text="⚡MarkiyanPro V64"..(IsMobile and " [📱]" or "")

local closeSize = isSmallScreen and 24 or 30
local CB=Instance.new("TextButton",Header)
CB.Size=UDim2.new(0,closeSize,0,closeSize); CB.Position=UDim2.new(1,-(closeSize+6),0,(headerH-closeSize)/2)
CB.BackgroundColor3=Color3.fromRGB(180,30,30); CB.Text="✕"
CB.TextColor3=Color3.new(1,1,1); CB.Font=Enum.Font.GothamBold
CB.TextSize=isSmallScreen and 12 or 14; CB.BorderSizePixel=0; CB.ZIndex=5
Instance.new("UICorner",CB).CornerRadius=UDim.new(0,6)
CB.MouseButton1Click:Connect(function() Main.Visible=false end)

local tabBarH = isSmallScreen and 24 or 30
local TabBar=Instance.new("Frame",Main)
TabBar.Size=UDim2.new(1,-8,0,tabBarH); TabBar.Position=UDim2.new(0,4,0,headerH+4)
TabBar.BackgroundColor3=Color3.fromRGB(12,12,20); TabBar.BorderSizePixel=0
Instance.new("UICorner",TabBar)
local TL=Instance.new("UIListLayout",TabBar); TL.FillDirection=Enum.FillDirection.Horizontal
TL.HorizontalAlignment=Enum.HorizontalAlignment.Center; TL.VerticalAlignment=Enum.VerticalAlignment.Center; TL.Padding=UDim.new(0,2)

local scrollTop = headerH + tabBarH + 12
local Scroll=Instance.new("ScrollingFrame",Main)
Scroll.Size=UDim2.new(1,-8,1,-(scrollTop+4)); Scroll.Position=UDim2.new(0,4,0,scrollTop)
Scroll.BackgroundTransparency=1; Scroll.BorderSizePixel=0; Scroll.ClipsDescendants=true
Scroll.ScrollBarThickness=IsMobile and 7 or 3; Scroll.ScrollBarImageColor3=Color3.fromRGB(0,120,255)
Scroll.ScrollingDirection=Enum.ScrollingDirection.Y; Scroll.ElasticBehavior=Enum.ElasticBehavior.Always
Scroll.TopImage="rbxasset://textures/ui/Scroll/scroll-middle.png"
Scroll.BottomImage="rbxasset://textures/ui/Scroll/scroll-middle.png"

local LL=Instance.new("UIListLayout",Scroll); LL.Padding=UDim.new(0,isSmallScreen and 3 or 4); LL.HorizontalAlignment=Enum.HorizontalAlignment.Center
local scrollPad=Instance.new("UIPadding",Scroll); scrollPad.PaddingTop=UDim.new(0,4); scrollPad.PaddingBottom=UDim.new(0,4)
LL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Scroll.CanvasSize=UDim2.new(0,0,0,LL.AbsoluteContentSize.Y+20) end)

local fovC=Instance.new("Frame",SG)
fovC.Size=UDim2.new(0,Config.AimFOV*2,0,Config.AimFOV*2)
fovC.Position=UDim2.new(0.5,-Config.AimFOV,0.5,-Config.AimFOV)
fovC.BackgroundTransparency=1; fovC.BorderSizePixel=0; fovC.Visible=false; fovC.ZIndex=10
Instance.new("UICorner",fovC).CornerRadius=UDim.new(1,0)
local fS=Instance.new("UIStroke",fovC); fS.Color=Color3.fromRGB(0,120,255); fS.Thickness=1.5; fS.Transparency=0.3

local tI=Instance.new("TextLabel",SG)
tI.Size=UDim2.new(0,isSmallScreen and 180 or 220,0,isSmallScreen and 20 or 24)
tI.Position=UDim2.new(0.5,isSmallScreen and -90 or -110,0.5,-(Config.AimFOV+(isSmallScreen and 28 or 34)))
tI.BackgroundColor3=Color3.fromRGB(10,10,16); tI.BackgroundTransparency=0.25
tI.BorderSizePixel=0; tI.TextColor3=Color3.fromRGB(0,200,100)
tI.Font=Enum.Font.GothamBold; tI.TextSize=isSmallScreen and 9 or 11; tI.Text=""; tI.Visible=false; tI.ZIndex=12
Instance.new("UICorner",tI); Instance.new("UIStroke",tI).Color=Color3.fromRGB(40,40,58)

local function UpdateFOV()
	local r=Config.AimFOV
	fovC.Size=UDim2.new(0,r*2,0,r*2); fovC.Position=UDim2.new(0.5,-r,0.5,-r)
	tI.Position=UDim2.new(0.5,isSmallScreen and -90 or -110,0.5,-(r+(isSmallScreen and 28 or 34)))
end

local fUT=0
RS.RenderStepped:Connect(function()
	local now=tick(); if now-fUT<0.05 then return end; fUT=now
	fovC.Visible=Config.AimActive or Config.SilentAim; tI.Visible=false
	if Config.AimActive then
		local tc=aimTarget and aimTarget.Character; local p=tc and FindAimPart(tc)
		if p and aimLocked then
			local plr=Players:GetPlayerFromCharacter(tc)
			local dist=math.floor((Camera.CFrame.Position-p.Position).Magnitude)
			tI.Text="🔒 "..(plr and plr.Name or "?").." ["..dist.."m]"
			tI.TextColor3=Color3.fromRGB(0,230,120); tI.Visible=true; fS.Color=Color3.fromRGB(0,200,100)
		else
			tI.Text="No target (toggle to re-lock)"; tI.Visible=true; fS.Color=Color3.fromRGB(100,100,180)
		end
	elseif Config.SilentAim then
		local tc=aimTarget and aimTarget.Character; local p=tc and FindAimPart(tc)
		if p then
			local plr=Players:GetPlayerFromCharacter(tc)
			local dist=math.floor((Camera.CFrame.Position-p.Position).Magnitude)
			tI.Text="🔇 "..(plr and plr.Name or "?").." ["..dist.."m]"
			tI.TextColor3=Color3.fromRGB(255,200,50); tI.Visible=true; fS.Color=Color3.fromRGB(255,200,50)
		else tI.Text="No target"; tI.Visible=true; fS.Color=Color3.fromRGB(100,100,180) end
	end
end)

-- ★★★ FLY КНОПКИ — ПЕРЕМІЩЕНІ ЛІВОРУЧ ВГОРУ ЩОБ НЕ НАЛАЗИЛИ НА JUMP ★★★
local flyBtnSize = isSmallScreen and 48 or 60
local flyH=Instance.new("Frame",SG)
flyH.Size=UDim2.new(0,flyBtnSize*2+16,0,flyBtnSize)
flyH.Position=UDim2.new(0,10,1,-(flyBtnSize+120))  -- ★ Ліворуч, вище кнопки jump
flyH.BackgroundTransparency=1; flyH.Visible=false; flyH.ZIndex=50

local function MkFB(l,x,cb)
	local b=Instance.new("TextButton",flyH); b.Size=UDim2.new(0,flyBtnSize,0,flyBtnSize); b.Position=UDim2.new(0,x,0,0)
	b.BackgroundColor3=Color3.fromRGB(12,12,18); b.Text=l; b.TextColor3=Color3.new(1,1,1)
	b.Font=Enum.Font.GothamBlack; b.TextSize=isSmallScreen and 22 or 28; b.BorderSizePixel=0; b.ZIndex=51; b.AutoButtonColor=false
	Instance.new("UICorner",b); Instance.new("UIStroke",b).Color=Color3.fromRGB(40,40,58)
	b.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then cb(true); b.BackgroundColor3=Color3.fromRGB(32,32,52) end end)
	b.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then cb(false); b.BackgroundColor3=Color3.fromRGB(12,12,18) end end)
end
MkFB("▲",0,function(v) MobUp=v end); MkFB("▼",flyBtnSize+12,function(v) MobDn=v end)
local function UpdateFlyBtns() flyH.Visible=Config.Fly and IsMobile end
UpdateFlyBtns_=UpdateFlyBtns

-- ★★★ SHORTCUT КНОПКИ — АДАПТИВНИЙ РОЗМІР ★★★
local scBtnSize = isSmallScreen and 40 or 52
local scBtnW = isSmallScreen and 44 or 56
local scHolder=Instance.new("Frame",SG); scHolder.Size=UDim2.new(0,scBtnW,0,580)
scHolder.Position=UDim2.new(1,-(scBtnW+6),0.10,0); scHolder.BackgroundTransparency=1; scHolder.BorderSizePixel=0; scHolder.ZIndex=90
local scLayout=Instance.new("UIListLayout",scHolder); scLayout.Padding=UDim.new(0,isSmallScreen and 3 or 5); scLayout.HorizontalAlignment=Enum.HorizontalAlignment.Center

local ShortcutBtns={}
local ShortcutDefs={
	{key="AimActive",label="AIM",scKey="SC_Aim",color=Color3.fromRGB(220,50,50)},
	{key="SilentAim",label="SIL",scKey="SC_Silent",color=Color3.fromRGB(200,150,0)},
	{key="Fly",label="FLY",scKey="SC_Fly",color=Color3.fromRGB(0,100,220)},
	{key="Noclip",label="NC",scKey="SC_Noclip",color=Color3.fromRGB(0,160,100)},
	{key="Speed",label="SPD",scKey="SC_Speed",color=Color3.fromRGB(100,180,0)},
	{key="Farm",label="FRM",scKey="SC_Farm",color=Color3.fromRGB(200,120,0)},
	{key="ShadowMagnet",label="SHD",scKey="SC_Shadow",color=Color3.fromRGB(80,0,160)},
	{key="HighJump",label="HJP",scKey="SC_HighJump",color=Color3.fromRGB(0,180,180)},
	{key="_SafeTP",label="SAFE",scKey="SC_Safe",color=Color3.fromRGB(0,120,60)},
}

for _, def in ipairs(ShortcutDefs) do
	local btn=Instance.new("TextButton",scHolder); btn.Size=UDim2.new(0,scBtnSize,0,isSmallScreen and 34 or 42)
	btn.BackgroundColor3=Color3.fromRGB(20,20,30); btn.TextColor3=Color3.fromRGB(180,180,190)
	btn.Font=Enum.Font.GothamBlack; btn.TextSize=isSmallScreen and 9 or (IsMobile and 11 or 10); btn.Text=def.label
	btn.BorderSizePixel=0; btn.AutoButtonColor=false; btn.ZIndex=91; btn.Visible=Config[def.scKey] or false
	Instance.new("UICorner",btn).CornerRadius=UDim.new(0,8)
	local stroke=Instance.new("UIStroke",btn); stroke.Color=Color3.fromRGB(40,40,58); stroke.Thickness=1
	local function UpdateSC()
		local on=(def.key~="_SafeTP") and Config[def.key]
		if on then btn.BackgroundColor3=def.color; btn.TextColor3=Color3.new(1,1,1); stroke.Color=Color3.new(1,1,1)
		else btn.BackgroundColor3=Color3.fromRGB(20,20,30); btn.TextColor3=Color3.fromRGB(150,150,160); stroke.Color=Color3.fromRGB(40,40,58) end
		btn.Visible=Config[def.scKey] or false
	end
	if def.key=="_SafeTP" then
		btn.MouseButton1Click:Connect(function() if SafeTeleport(COORDS.SAFE_ZONE) then Notify("TP","➜ Safe Zone",2) end end)
	else
		btn.MouseButton1Click:Connect(function()
			Config[def.key]=not Config[def.key]; UpdateSC()
			if def.key=="Fly" then UpdateFlyBtns() end
			if def.key=="AimActive" then aimTarget=nil; aimLocked=false; aimLostFrames=0; aimHasLockedOnce=not Config.AimActive end
			if def.key=="Noclip" and not Config.Noclip then RestoreCollision() end
			if def.key=="ShadowMagnet" then if Config.ShadowMagnet then shadowSavedPos=nil else Config.ShadowTarget=nil end end
			if def.key=="ESP" and not Config.ESP then ClearAllESP() end
			if def.key=="Speed" and not Config.Speed then local h=GetHum(); if h then h.WalkSpeed=16 end end
			if def.key=="HighJump" then local h=GetHum(); if h then h.UseJumpPower=true; h.JumpPower=Config.HighJump and Config.JumpPowerValue or 50 end end
			if def.key=="SilentAim" and not Config.SilentAim then StopSilentAim() end
			if UpdFuncs[def.key] then UpdFuncs[def.key](Config[def.key]) end
			SaveSettings(Config,ItemPickerState)
		end)
	end
	ShortcutBtns[def.key]={btn=btn,update=UpdateSC,def=def}; UpdateSC()
end

local function UpdateAllShortcuts() for _, sc in pairs(ShortcutBtns) do sc.update() end end

local Sections,TabButtons,ActiveTab={},{},nil
local tabNames={"Combat","Move","Misc","Items","Binds"}
local tabW=isSmallScreen and 38 or (IsMobile and 48 or 64)
local tabBtnH = isSmallScreen and 20 or 24

for _, n in pairs(tabNames) do
	Sections[n]={}
	local b=Instance.new("TextButton",TabBar); b.Size=UDim2.new(0,tabW,0,tabBtnH)
	b.BackgroundColor3=Color3.fromRGB(18,18,30); b.TextColor3=Color3.fromRGB(150,150,170)
	b.Font=Enum.Font.GothamBold; b.TextSize=tabTextSize; b.Text=n
	b.BorderSizePixel=0; b.AutoButtonColor=false; Instance.new("UICorner",b); TabButtons[n]=b
end

-- Draggable header
do
	local d,s,p=false,nil,nil
	Header.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then d=true; s=i.Position; p=Main.Position end end)
	Header.InputChanged:Connect(function(i) if not d then return end; if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then local dl=i.Position-s; Main.Position=UDim2.new(p.X.Scale,p.X.Offset+dl.X,p.Y.Scale,p.Y.Offset+dl.Y) end end)
	Header.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then d=false end end)
	UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then d=false end end)
end

-- ★★★ АДАПТИВНА ВИСОТА КНОПОК ★★★
local BtnH=isSmallScreen and 34 or (IsMobile and 42 or 34)

local function MakeFrame(tab)
	local f=Instance.new("Frame",Scroll); f.Size=UDim2.new(0.97,0,0,BtnH)
	f.BackgroundTransparency=1; f.BorderSizePixel=0; f.Visible=false
	table.insert(Sections[tab],f); return f
end

local function AddCategory(tab,text)
	local catH = isSmallScreen and 18 or 22
	local f=Instance.new("Frame",Scroll); f.Size=UDim2.new(0.97,0,0,catH)
	f.BackgroundColor3=Color3.fromRGB(0,55,155); f.BorderSizePixel=0; f.Visible=false
	Instance.new("UICorner",f)
	local l=Instance.new("TextLabel",f); l.Size=UDim2.new(1,0,1,0); l.BackgroundTransparency=1
	l.TextColor3=Color3.new(1,1,1); l.Font=Enum.Font.GothamBold; l.TextSize=categoryTextSize
	l.Text="── "..text.." ──"
	table.insert(Sections[tab],f)
end

local function AddToggle(tab,name,key,cbOn,cbOff)
	local f=MakeFrame(tab)
	local btn=Instance.new("TextButton",f); btn.Size=UDim2.new(1,0,1,0)
	btn.BackgroundColor3=Color3.fromRGB(20,20,30); btn.TextColor3=Color3.fromRGB(190,190,200)
	btn.Font=Enum.Font.GothamBold; btn.TextSize=btnTextSize
	btn.BorderSizePixel=0; btn.AutoButtonColor=false; btn.TextXAlignment=Enum.TextXAlignment.Left
	btn.Text="      "..name..": OFF"; Instance.new("UICorner",btn)
	local dotSize = isSmallScreen and 7 or 9
	local dot=Instance.new("Frame",btn); dot.Size=UDim2.new(0,dotSize,0,dotSize); dot.AnchorPoint=Vector2.new(0,0.5)
	dot.Position=UDim2.new(0,isSmallScreen and 6 or 10,0.5,0); dot.BackgroundColor3=Color3.fromRGB(200,50,50)
	dot.BorderSizePixel=0; dot.ZIndex=btn.ZIndex+1; Instance.new("UICorner",dot)
	local function Upd(s)
		if s then btn.BackgroundColor3=Color3.fromRGB(0,70,190); btn.TextColor3=Color3.new(1,1,1); dot.BackgroundColor3=Color3.fromRGB(0,220,80); btn.Text="      "..name..": ON"
		else btn.BackgroundColor3=Color3.fromRGB(20,20,30); btn.TextColor3=Color3.fromRGB(190,190,200); dot.BackgroundColor3=Color3.fromRGB(200,50,50); btn.Text="      "..name..": OFF" end
		if ShortcutBtns[key] then ShortcutBtns[key].update() end
	end
	UpdFuncs[key]=Upd; if Config[key] then Upd(true) end
	btn.MouseButton1Click:Connect(function()
		Config[key]=not Config[key]; Upd(Config[key])
		if Config[key] then if cbOn then task.spawn(cbOn) end else if cbOff then task.spawn(cbOff) end end
		if key=="Fly" then UpdateFlyBtns() end
		if key=="AimActive" then aimTarget=nil; aimLocked=false; aimLostFrames=0; aimHasLockedOnce=not Config.AimActive end
		if key=="ESP" and not Config[key] then ClearAllESP() end
		if key=="ShadowMagnet" then if Config.ShadowMagnet then shadowSavedPos=nil else Config.ShadowTarget=nil end end
		if key=="Noclip" and not Config.Noclip then RestoreCollision() end
		if key=="SilentAim" and not Config.SilentAim then StopSilentAim() end
		SaveSettings(Config,ItemPickerState); Notify(name,Config[key] and "ON ✓" or "OFF ✗",1.5)
	end)
	return Upd
end

local function AddSlider(tab,label,minV,maxV,def,cKey,cb)
	local sliderH = isSmallScreen and 46 or (IsMobile and 56 or 54)
	local f=Instance.new("Frame",Scroll); f.Size=UDim2.new(0.97,0,0,sliderH)
	f.BackgroundColor3=Color3.fromRGB(16,16,24); f.BorderSizePixel=0; f.Visible=false
	Instance.new("UICorner",f); table.insert(Sections[tab],f)
	local cv=Config[cKey] or def
	local lbl=Instance.new("TextLabel",f); lbl.Size=UDim2.new(1,-8,0,isSmallScreen and 18 or 22); lbl.Position=UDim2.new(0,4,0,2)
	lbl.BackgroundTransparency=1; lbl.TextColor3=Color3.fromRGB(200,200,210)
	lbl.Font=Enum.Font.GothamBold; lbl.TextSize=sliderTextSize; lbl.TextXAlignment=Enum.TextXAlignment.Left
	lbl.Text=label..": "..cv
	local trackH = isSmallScreen and 12 or (IsMobile and 14 or 10)
	local trackY = isSmallScreen and 28 or (IsMobile and 36 or 36)
	local tr=Instance.new("Frame",f); tr.Size=UDim2.new(0.92,0,0,trackH)
	tr.Position=UDim2.new(0.04,0,0,trackY)
	tr.BackgroundColor3=Color3.fromRGB(35,35,50); tr.BorderSizePixel=0; Instance.new("UICorner",tr)
	local iR=math.clamp((cv-minV)/(maxV-minV),0,1)
	local fl=Instance.new("Frame",tr); fl.Size=UDim2.new(iR,0,1,0)
	fl.BackgroundColor3=Color3.fromRGB(0,100,255); fl.BorderSizePixel=0; Instance.new("UICorner",fl)
	local kS=isSmallScreen and 18 or (IsMobile and 22 or 14)
	local kn=Instance.new("Frame",tr); kn.Size=UDim2.new(0,kS,0,kS)
	kn.Position=UDim2.new(iR,-kS/2,0.5,-kS/2); kn.BackgroundColor3=Color3.new(1,1,1); kn.BorderSizePixel=0
	Instance.new("UICorner",kn)
	local dg=false
	local function US(inp)
		local rel=math.clamp((inp.Position.X-tr.AbsolutePosition.X)/tr.AbsoluteSize.X,0,1)
		local val=math.floor(minV+rel*(maxV-minV))
		fl.Size=UDim2.new(rel,0,1,0); kn.Position=UDim2.new(rel,-kS/2,0.5,-kS/2)
		lbl.Text=label..": "..val; Config[cKey]=val; if cb then cb(val) end
	end
	tr.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dg=true; US(i) end end)
	UIS.InputChanged:Connect(function(i) if not dg then return end; if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then US(i) end end)
	UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dg=false; SaveSettings(Config,ItemPickerState) end end)
end

local function AddAction(tab,name,color,cb)
	local f=MakeFrame(tab)
	local btn=Instance.new("TextButton",f); btn.Size=UDim2.new(1,0,1,0); btn.BackgroundColor3=color
	btn.TextColor3=Color3.new(1,1,1); btn.Font=Enum.Font.GothamBold; btn.TextSize=btnTextSize
	btn.BorderSizePixel=0; btn.AutoButtonColor=false; btn.Text=name; Instance.new("UICorner",btn)
	btn.MouseButton1Click:Connect(function() task.spawn(cb) end)
end

local function AddTP(tab,name,vec)
	local f=MakeFrame(tab)
	local btn=Instance.new("TextButton",f); btn.Size=UDim2.new(1,0,1,0)
	btn.BackgroundColor3=Color3.fromRGB(18,18,32); btn.TextColor3=Color3.fromRGB(255,215,0)
	btn.Font=Enum.Font.GothamBold; btn.TextSize=isSmallScreen and 10 or (IsMobile and 12 or 12)
	btn.BorderSizePixel=0; btn.AutoButtonColor=false; btn.Text="📍 "..name; Instance.new("UICorner",btn)
	btn.MouseButton1Click:Connect(function() if SafeTeleport(vec) then Notify("TP","➜ "..name,2) end end)
end

-- BUILD TABS
AddCategory("Combat","AIMING")
AddToggle("Combat","AIM LOCK","AimActive",
	function() aimTarget=nil;aimLocked=false;aimLostFrames=0;aimLastSwitch=0;aimHasLockedOnce=false end,
	function() aimTarget=nil;aimLocked=false;aimLostFrames=0;aimHasLockedOnce=false end)
AddToggle("Combat","SILENT AIM","SilentAim",nil,function() StopSilentAim() end)
AddToggle("Combat","ESP","ESP",nil,function() ClearAllESP() end)
AddCategory("Combat","MAGNET")
AddToggle("Combat","MAGNET","Magnet",nil,function() Config.MagnetTarget=nil end)
AddToggle("Combat","👻 SHADOW MAGNET","ShadowMagnet",function() shadowSavedPos=nil end,function() Config.ShadowTarget=nil end)
AddSlider("Combat","Shadow Depth",5,40,Config.ShadowDepth,"ShadowDepth")
AddCategory("Combat","AIM CONFIG")
AddSlider("Combat","FOV",50,500,Config.AimFOV,"AimFOV",function(v) Config.AimFOV=v; UpdateFOV() end)
AddSlider("Combat","Smooth(x100)",5,100,math.floor(Config.AimSmooth*100),"AimSmooth",function(v) Config.AimSmooth=v/100 end)

AddCategory("Move","MOVEMENT")
AddToggle("Move","FLY","Fly",function() UpdateFlyBtns() end,function() UpdateFlyBtns(); local h=GetHum(); if h then h.PlatformStand=false;h.WalkSpeed=16 end end)
AddSlider("Move","FLY SPEED",10,IsPC and 250 or 150,Config.FlySpeedValue,"FlySpeedValue")
AddToggle("Move","SPEED","Speed",nil,function() local h=GetHum(); if h then h.WalkSpeed=16 end end)
AddSlider("Move","WALK SPEED",16,IsPC and 150 or 100,Config.WalkSpeedValue,"WalkSpeedValue")
AddToggle("Move","NOCLIP","Noclip",nil,function() RestoreCollision() end)
AddToggle("Move","INF JUMP","InfJump")
AddToggle("Move","HIGH JUMP","HighJump",
	function() local h=GetHum(); if h then h.UseJumpPower=true;h.JumpPower=Config.JumpPowerValue end end,
	function() local h=GetHum(); if h then h.UseJumpPower=true;h.JumpPower=50 end end)
AddSlider("Move","JUMP POWER",50,300,Config.JumpPowerValue,"JumpPowerValue",function(v) if Config.HighJump then local h=GetHum(); if h then h.UseJumpPower=true;h.JumpPower=v end end end)
AddCategory("Move","TELEPORTS")
AddTP("Move","GUN SHOP",COORDS.GUN_SHOP)
AddTP("Move","BANK",COORDS.BANK_ENT)
AddTP("Move","SAFE ZONE",COORDS.SAFE_ZONE)

AddCategory("Misc","SURVIVAL")
AddToggle("Misc","AUTO SAFE","AutoSafe")
AddToggle("Misc","AUTO HEAL","Heal")
AddCategory("Misc","FARM & VISUALS")
AddToggle("Misc","AUTO FARM","Farm")
AddSlider("Misc","FARM RANGE",50,2000,Config.FarmRange or 900,"FarmRange")
AddToggle("Misc","FULLBRIGHT","Fullbright",function() EnableFB() end,function() DisableFB() end)
AddToggle("Misc","FPS BOOST","FPSBoost",function() ApplyFPS() end)
AddCategory("Misc","UTILITIES")
AddToggle("Misc","ANTI-SEAT","AntiSeat")
AddToggle("Misc","ANTI-AFK","AntiAFK")
AddCategory("Misc","ACTIONS")
AddAction("Misc","🏦 ROB BANK (10x)",Color3.fromRGB(150,20,20),StartRobbery)

-- ============================================================
-- ITEMS TAB
-- ============================================================
local ItemCategories = {
	{name="🏆 ПРІОРИТЕТ",color=Color3.fromRGB(180,100,0),items={
		"Money printer","Unusual Money Printer","Money Balloon","Dollar Balloon",
		"Clover Balloon","Golden Clover Balloon","Heart Balloon",
		"Mustang Keys","Helicopter Keys","Cruiser Keys",
		"Military Keycard","Military Key Card","Police Keycard","Police Key Card",
		"Gold AK-47","Gold Deagle","Diamond Glock",
		"Admin AK-47","Admin RPG","Admin Nuke",
		"Suitcase Nuke","Nuke Launcher","Raygun","Barrett M107",
		"Spectral Scythe","SPAS-12","Kunai",
		"Diamond Taco","Airdrop Marker","X-Ray Goggles","Night Vision Goggles",
		"Lockpick","Candy Cane","Blue Candy Cane","Sparkler",
		"Green Firework","Pink Firework","Gems","Safes",
	}},
	{name="🔫 ЗБРОЯ",color=Color3.fromRGB(160,30,30),items={
		"Acid Gun","AK-47","AR-15","AS VAL","AUG","Baseball Bat","Baton",
		"Brass Knuckles","C4","Clown Mallet","Crowbar","Deagle","Double barrel",
		"Dragunov","Fire Extinguisher","Fireaxe","Fists","Flamethrower","Flashbang",
		"Frag grenade","Glock","Glock 18","Gravity Gun","Heavy C4","Katana","Knife",
		"Landmines","M1 Garand","M1911","M249 SAW","M4A1","Meat Grinder","Molotov",
		"Money Gun","Mossberg","MP7","Pepper Spray","Python","Rifles","Riot Shield",
		"RPG","RPK","Saber","Saiga 12","Sawn off","Smoke grenade",
		"Spiked baseball bat","USP 45","Uzi",
	}},
	{name="🛡 БРОНЯ/МЕД",color=Color3.fromRGB(0,100,160),items={
		"Bandage","Heavy Vest","Light vest","Medium Vest","Medkit",
		"Military Vest","Stretcher","Surgeon Mask",
	}},
	{name="💰 ГРОШІ",color=Color3.fromRGB(180,150,0),items={"ATM","Cash Register","Slot machine","Wallet"}},
	{name="🍎 ЇЖА",color=Color3.fromRGB(0,140,60),items={
		"Apple","Banana","Banana Peel","Beans","Bloxaide","Bloxy Cola","Burger",
		"Cake","Chicken","Choco Bunny","Chocolates","Coffee","Cookie",
		"Cotton Candy","Donut","Hotdog","Pizza","Rose",
	}},
	{name="📦 ЯЩИКИ",color=Color3.fromRGB(100,60,0),items={
		"Airstrike","Armored Truck","Component Boxes","Crafting table","Drone",
		"Easter Basket","Locker","Gold Lucky Block","Green Lucky Block","Orange Lucky Block",
		"Purple Lucky Block","Red Lucky Block","Large Present","Presents","Small Present",
	}},
	{name="🎈 БАЛОНИ/СВЯТО",color=Color3.fromRGB(180,0,120),items={
		"4th of July Hat","Balloon","Basketball","Beach Ball","Bear Trap",
		"Clown","Dollar Balloon","Firework","Firework Cake","Firework Cone","Firework Mortar",
		"Hockey Mask","July 4th Firework","Money Balloon","Roman Candle","Sombrero Hat",
	}},
	{name="👗 ОДЯГ",color=Color3.fromRGB(80,0,180),items={"Black Bandana","Blue Bandana","Blue Gloves","Red Bandana","Red Gloves"}},
	{name="🔧 ІНСТРУМЕНТИ",color=Color3.fromRGB(60,60,60),items={
		"Dumbell","Festive Guitar","Flashlight","Grocery Cart","Guitar",
		"Hoverboard","Maraca","Megaphone","Shopping Cart","Sign","Skateboard",
		"Stagecoach","Stop Sign",
	}},
	{name="⚙️ МАТЕРІАЛИ",color=Color3.fromRGB(40,80,40),items={"Electronics","Explosives Scrap","Materials","Medical Supplies","Weapon Parts"}},
	{name="💎 VOID",color=Color3.fromRGB(50,0,80),items={
		"Void RPG","Void AS VAL","Void AUG","Void M4A1","Void Barrett M107",
		"Void AK-47","Void Tommy Gun","Void RPK","Void Sawn Off","Void Riot Shield",
		"Void M249 SAW","Void MP7","Void Double Barrel","Void Deagle","Void AR-15",
		"Void Flamethrower","Void Mossberg","Void Python","Void Uzi",
		"Void Glock 18","Void Glock","Void Dragunov","Void Stagecoach",
		"Void Saiga 12","Void M1911","Void USP 45","Void Raygun",
	}},
	{name="🥇 SOLID GOLD",color=Color3.fromRGB(160,120,0),items={
		"Solid Gold RPG","Solid Gold AS VAL","Solid Gold AUG","Solid Gold Barrett",
		"Solid Gold M4A1","Solid Gold AK-47","Solid Gold Tommy Gun","Solid Gold RPK",
		"Solid Gold Sawn Off","Solid Gold Riot Shield","Solid Gold M249 SAW",
		"Solid Gold Double Barrel","Solid Gold MP7","Solid Gold Deagle",
		"Solid Gold AR-15","Solid Gold Flamethrower","Solid Gold Glock 18",
		"Solid Gold Mossberg","Solid Gold Python","Solid Gold Uzi",
		"Solid Gold Dragunov","Solid Gold Glock","Solid Gold Stagecoach",
		"Solid Gold Saiga 12","Solid Gold M1911","Solid Gold USP 45","Solid Gold Raygun",
	}},
	{name="🌿 ІНШІ СКІНИ",color=Color3.fromRGB(60,80,40),items={
		"CyberPunk AUG","CyberPunk AS VAL","CyberPunk M4A1","CyberPunk AK-47",
		"CyberPunk Tommy Gun","CyberPunk Sawn Off","CyberPunk RPK",
		"CyberPunk Double Barrel","CyberPunk Uzi","CyberPunk Glock 18","CyberPunk Glock",
		"Diamond Deagle","Diamond RPG","Diamond AS VAL","Diamond Scar L",
		"Diamond Barrett","Diamond Double Barrel","Diamond Mossberg","Diamond Python","Diamond Glock",
		"Ruby RPG","Ruby Scar L","Ruby AUG","Ruby AS VAL","Ruby Barrett",
		"Ruby MiniGun","Ruby M4A1","Ruby Sawn Off","Ruby Riot Shield",
		"Ruby Double Barrel","Ruby M249 SAW","Ruby Deagle","Ruby Mossberg",
		"Ruby Dragunov","Ruby Saiga 12","Ruby Python","Ruby Glock",
		"Amethyst RPG","Amethyst AS VAL","Amethyst AUG","Amethyst Scar L",
		"Amethyst Barrett","Amethyst M4A1","Amethyst AK-47","Amethyst Deagle",
		"Amethyst Glock","Amethyst Mossberg","Amethyst Python","Amethyst Dragunov",
		"Sapphire RPG","Sapphire AS VAL","Sapphire AUG","Sapphire Scar L",
		"Sapphire Barrett","Sapphire M4A1","Sapphire AK-47","Sapphire Deagle",
		"Sapphire Glock","Sapphire Mossberg","Sapphire Python","Sapphire Dragunov",
		"Sapphire M249 SAW","Sapphire RPK",
		"Emerald RPG","Emerald AS VAL","Emerald AUG","Emerald Scar L",
		"Emerald Barrett","Emerald M4A1","Emerald AK-47","Emerald Deagle",
		"Emerald Glock","Emerald Mossberg","Emerald Python","Emerald Dragunov",
		"Nature RPG","Nature AS VAL","Nature AUG","Nature M4A1","Nature AK-47",
		"Nature Barrett","Nature Scar L","Nature Deagle","Nature Glock","Nature Mossberg","Nature Dragunov",
		"Water RPG","Water AS VAL","Water AUG","Water M4A1","Water AK-47",
		"Water Barrett","Water Scar L","Water Deagle","Water Glock","Water Mossberg","Water Dragunov",
		"Flame RPG","Flame AS VAL","Flame AUG","Flame M4A1","Flame AK-47",
		"Flame Barrett","Flame Scar L","Flame Deagle","Flame Glock","Flame Mossberg","Flame Dragunov",
		"Tactical RPG","Tactical AS VAL","Tactical AUG","Tactical M4A1",
		"Tactical AK-47","Tactical Barrett","Tactical Scar L","Tactical Deagle",
		"Tactical Glock","Tactical Mossberg","Tactical Dragunov",
		"Future White RPG","Future White AS VAL","Future White AUG",
		"Future White M4A1","Future White AK-47","Future White Barrett",
		"Future White Deagle","Future White Glock",
		"Future Black RPG","Future Black AS VAL","Future Black AUG",
		"Future Black M4A1","Future Black AK-47","Future Black Barrett",
		"Future Black Deagle","Future Black Glock",
		"Frozen Diamond RPG","Frozen Diamond AS VAL","Frozen Diamond AUG",
		"Frozen Diamond M4A1","Frozen Diamond AK-47","Frozen Diamond Barrett",
		"Frozen Diamond Scar L","Frozen Diamond Deagle","Frozen Diamond Glock",
		"Frozen Diamond Mossberg","Frozen Diamond Dragunov",
		"Elite RPG","Elite AS VAL","Elite AUG","Elite M4A1","Elite AK-47",
		"Elite Barrett","Elite Scar L","Elite Deagle","Elite Glock","Elite Mossberg","Elite Dragunov",
		"Steampunk RPG","Steampunk AS VAL","Steampunk AUG","Steampunk M4A1",
		"Steampunk AK-47","Steampunk Barrett","Steampunk Scar L","Steampunk Deagle",
		"Steampunk Glock","Steampunk Mossberg","Steampunk Dragunov",
		"Pirate RPG","Pirate AS VAL","Pirate AUG","Pirate M4A1","Pirate AK-47",
		"Pirate Barrett","Pirate Scar L","Pirate Deagle","Pirate Glock","Pirate Mossberg","Pirate Dragunov",
		"Treasure RPG","Treasure AS VAL","Treasure AUG","Treasure M4A1",
		"Treasure AK-47","Treasure Barrett","Treasure Scar L","Treasure Deagle",
		"Treasure Glock","Treasure Mossberg",
		"Cannon RPG","Cannon AS VAL","Cannon AUG","Cannon M4A1","Cannon AK-47",
		"Gold Cannon RPG","Gold Cannon AS VAL","Gold Cannon AUG","Gold Cannon M4A1","Gold Cannon AK-47",
		"WW2 RPG","WW2 AS VAL","WW2 AUG","WW2 M4A1","WW2 AK-47","WW2 Barrett",
		"WW2 Scar L","WW2 Deagle","WW2 Glock","WW2 Mossberg","WW2 Dragunov",
		"Prestige RPG","Prestige AS VAL","Prestige AUG","Prestige M4A1",
		"Prestige AK-47","Prestige Barrett","Prestige Scar L","Prestige Deagle",
		"Prestige Glock","Prestige Mossberg","Prestige Dragunov","Prestige Raygun",
	}},
}

local categorizedItems={}
for _, cat in ipairs(ItemCategories) do for _, item in ipairs(cat.items) do categorizedItems[item]=true end end
local otherItems={}
for _, item in ipairs(ALL_ITEMS) do if not categorizedItems[item] then table.insert(otherItems,item) end end
if #otherItems>0 then table.insert(ItemCategories,{name="📋 ІНШЕ",color=Color3.fromRGB(50,50,80),items=otherItems}) end

local iTotalLabel=Instance.new("Frame",Scroll); iTotalLabel.Size=UDim2.new(0.97,0,0,isSmallScreen and 22 or 28)
iTotalLabel.BackgroundColor3=Color3.fromRGB(0,60,130); iTotalLabel.BorderSizePixel=0; iTotalLabel.Visible=false
Instance.new("UICorner",iTotalLabel); table.insert(Sections["Items"],iTotalLabel)
local iTL=Instance.new("TextLabel",iTotalLabel); iTL.Size=UDim2.new(1,0,1,0); iTL.BackgroundTransparency=1
iTL.TextColor3=Color3.new(1,1,1); iTL.Font=Enum.Font.GothamBold; iTL.TextSize=isSmallScreen and 8 or (IsMobile and 10 or 11)
iTL.Text="📦 ITEM PICKER — "..#ALL_ITEMS.." items | ⭐=priority"

local farmStatsLabel=Instance.new("Frame",Scroll); farmStatsLabel.Size=UDim2.new(0.97,0,0,isSmallScreen and 20 or 24)
farmStatsLabel.BackgroundColor3=Color3.fromRGB(30,60,0); farmStatsLabel.BorderSizePixel=0; farmStatsLabel.Visible=false
Instance.new("UICorner",farmStatsLabel); table.insert(Sections["Items"],farmStatsLabel)
local fSL=Instance.new("TextLabel",farmStatsLabel); fSL.Size=UDim2.new(1,0,1,0); fSL.BackgroundTransparency=1
fSL.TextColor3=Color3.fromRGB(150,255,150); fSL.Font=Enum.Font.Gotham; fSL.TextSize=isSmallScreen and 8 or 10

task.spawn(function() while task.wait(2) do if ActiveTab=="Items" then fSL.Text=string.format("📊 Collected: %d | Skipped: %d | Last: %s",farmStats.collected,farmStats.skipped,farmStats.lastItem) end end end)

local searchH = isSmallScreen and 34 or (IsMobile and 42 or 36)
local searchBtnH = isSmallScreen and 24 or (IsMobile and 30 or 26)
local sFr=Instance.new("Frame",Scroll); sFr.Size=UDim2.new(0.97,0,0,searchH)
sFr.BackgroundColor3=Color3.fromRGB(16,16,26); sFr.BorderSizePixel=0; sFr.Visible=false
Instance.new("UICorner",sFr); table.insert(Sections["Items"],sFr)
local sB=Instance.new("TextBox",sFr); sB.Size=UDim2.new(0.55,-4,0,searchBtnH)
sB.Position=UDim2.new(0,6,0.5,-searchBtnH/2); sB.BackgroundColor3=Color3.fromRGB(25,25,40)
sB.TextColor3=Color3.new(1,1,1); sB.PlaceholderText="🔍 search..."
sB.PlaceholderColor3=Color3.fromRGB(100,100,130); sB.Font=Enum.Font.Gotham; sB.TextSize=isSmallScreen and 10 or 12
sB.ClearTextOnFocus=false; sB.BorderSizePixel=0; Instance.new("UICorner",sB)
local eA=Instance.new("TextButton",sFr); eA.Size=UDim2.new(0.21,0,0,searchBtnH)
eA.Position=UDim2.new(0.57,2,0.5,-searchBtnH/2); eA.BackgroundColor3=Color3.fromRGB(0,120,50)
eA.TextColor3=Color3.new(1,1,1); eA.Font=Enum.Font.GothamBold; eA.TextSize=isSmallScreen and 8 or 10; eA.Text="ALL✓"; eA.BorderSizePixel=0
Instance.new("UICorner",eA)
local dAB=Instance.new("TextButton",sFr); dAB.Size=UDim2.new(0.21,0,0,searchBtnH)
dAB.Position=UDim2.new(0.79,2,0.5,-searchBtnH/2); dAB.BackgroundColor3=Color3.fromRGB(150,30,30)
dAB.TextColor3=Color3.new(1,1,1); dAB.Font=Enum.Font.GothamBold; dAB.TextSize=isSmallScreen and 8 or 10; dAB.Text="ALL✗"; dAB.BorderSizePixel=0
Instance.new("UICorner",dAB)

local itemBtns={}
local itemH = isSmallScreen and 26 or (IsMobile and 32 or 28)
local catH = isSmallScreen and 26 or (IsMobile and 32 or 28)
local catBtnH = isSmallScreen and 18 or (IsMobile and 22 or 20)

for _, cat in ipairs(ItemCategories) do
	local catF=Instance.new("Frame",Scroll); catF.Size=UDim2.new(0.97,0,0,catH)
	catF.BackgroundColor3=cat.color; catF.BorderSizePixel=0; catF.Visible=false
	Instance.new("UICorner",catF); table.insert(Sections["Items"],catF)
	local catLbl=Instance.new("TextLabel",catF); catLbl.Size=UDim2.new(0.75,0,1,0); catLbl.Position=UDim2.new(0,8,0,0)
	catLbl.BackgroundTransparency=1; catLbl.TextColor3=Color3.new(1,1,1)
	catLbl.Font=Enum.Font.GothamBold; catLbl.TextSize=isSmallScreen and 8 or (IsMobile and 10 or 11); catLbl.TextXAlignment=Enum.TextXAlignment.Left
	catLbl.Text=cat.name.." ("..#cat.items..")"

	local catOn=Instance.new("TextButton",catF); catOn.Size=UDim2.new(0.11,0,0,catBtnH)
	catOn.Position=UDim2.new(0.76,0,0.5,-catBtnH/2); catOn.BackgroundColor3=Color3.fromRGB(0,100,40)
	catOn.TextColor3=Color3.new(1,1,1); catOn.Font=Enum.Font.GothamBold; catOn.TextSize=isSmallScreen and 8 or 9; catOn.Text="✓"; catOn.BorderSizePixel=0
	Instance.new("UICorner",catOn)
	local catOff=Instance.new("TextButton",catF); catOff.Size=UDim2.new(0.11,0,0,catBtnH)
	catOff.Position=UDim2.new(0.88,0,0.5,-catBtnH/2); catOff.BackgroundColor3=Color3.fromRGB(120,20,20)
	catOff.TextColor3=Color3.new(1,1,1); catOff.Font=Enum.Font.GothamBold; catOff.TextSize=isSmallScreen and 8 or 9; catOff.Text="✗"; catOff.BorderSizePixel=0
	Instance.new("UICorner",catOff)

	local catItemBtns={}
	for _, iN in ipairs(cat.items) do
		if ItemPickerState[iN]==nil then ItemPickerState[iN]=true end
		local f=Instance.new("Frame",Scroll); f.Size=UDim2.new(0.97,0,0,itemH)
		f.BackgroundTransparency=1; f.BorderSizePixel=0; f.Visible=false
		table.insert(Sections["Items"],f)
		local b=Instance.new("TextButton",f); b.Size=UDim2.new(1,0,1,0)
		b.Font=Enum.Font.GothamBold; b.TextSize=itemTextSize
		b.BorderSizePixel=0; b.AutoButtonColor=false; b.TextXAlignment=Enum.TextXAlignment.Left
		Instance.new("UICorner",b)
		local isPrio=PriorityLoot[iN:lower()] or IsGunSkin(iN:lower())
		local function U()
			if ItemPickerState[iN] then
				b.BackgroundColor3=isPrio and Color3.fromRGB(0,80,0) or Color3.fromRGB(10,50,25)
				b.TextColor3=isPrio and Color3.fromRGB(255,215,0) or Color3.fromRGB(100,255,130)
				b.Text=(isPrio and " ⭐ " or " ✓ ")..iN
			else
				b.BackgroundColor3=Color3.fromRGB(50,15,15); b.TextColor3=Color3.fromRGB(255,120,120)
				b.Text=" ✗ "..iN
			end
		end; U()
		b.MouseButton1Click:Connect(function() ItemPickerState[iN]=not ItemPickerState[iN]; U(); SaveSettings(Config,ItemPickerState) end)
		local entry={frame=f,itemName=iN,update=U}; table.insert(itemBtns,entry); table.insert(catItemBtns,entry)
	end
	catOn.MouseButton1Click:Connect(function() for _,e in pairs(catItemBtns) do ItemPickerState[e.itemName]=true; e.update() end; SaveSettings(Config,ItemPickerState) end)
	catOff.MouseButton1Click:Connect(function() for _,e in pairs(catItemBtns) do ItemPickerState[e.itemName]=false; e.update() end; SaveSettings(Config,ItemPickerState) end)
end

local function FilterItems(q)
	local ql=q:lower()
	for _, e in pairs(itemBtns) do e.frame.Visible=(ActiveTab=="Items") and (ql=="" or e.itemName:lower():find(ql,1,true)~=nil) end
	task.wait(); Scroll.CanvasSize=UDim2.new(0,0,0,LL.AbsoluteContentSize.Y+20)
end
sB:GetPropertyChangedSignal("Text"):Connect(function() if ActiveTab=="Items" then FilterItems(sB.Text) end end)
eA.MouseButton1Click:Connect(function() local q=sB.Text:lower(); for _,e in pairs(itemBtns) do if q=="" or e.itemName:lower():find(q,1,true) then ItemPickerState[e.itemName]=true; e.update() end end; SaveSettings(Config,ItemPickerState) end)
dAB.MouseButton1Click:Connect(function() local q=sB.Text:lower(); for _,e in pairs(itemBtns) do if q=="" or e.itemName:lower():find(q,1,true) then ItemPickerState[e.itemName]=false; e.update() end end; SaveSettings(Config,ItemPickerState) end)

-- BINDS TAB
AddCategory("Binds","KEYBINDS (PC)")
local bA={{key="Fly",name="FLY"},{key="AimActive",name="AIM"},{key="Noclip",name="NOCLIP"},{key="SilentAim",name="SILENT"},{key="ToggleUI",name="UI"}}
local BBtns={}
local function AddBR(tab,aK,aN)
	local bindH = isSmallScreen and 36 or (IsMobile and 44 or 38)
	local bindBtnH = isSmallScreen and 24 or (IsMobile and 30 or 26)
	local f=Instance.new("Frame",Scroll); f.Size=UDim2.new(0.97,0,0,bindH)
	f.BackgroundColor3=Color3.fromRGB(16,16,26); f.BorderSizePixel=0; f.Visible=false
	Instance.new("UICorner",f); table.insert(Sections[tab],f)
	local nl=Instance.new("TextLabel",f); nl.Size=UDim2.new(0.52,0,1,0); nl.Position=UDim2.new(0,10,0,0)
	nl.BackgroundTransparency=1; nl.TextColor3=Color3.fromRGB(200,200,210)
	nl.Font=Enum.Font.GothamBold; nl.TextSize=btnTextSize; nl.TextXAlignment=Enum.TextXAlignment.Left; nl.Text=aN
	local bb=Instance.new("TextButton",f); bb.Size=UDim2.new(0.42,0,0,bindBtnH)
	bb.Position=UDim2.new(0.55,0,0.5,-bindBtnH/2); bb.BackgroundColor3=Color3.fromRGB(22,22,38)
	bb.TextColor3=Color3.fromRGB(170,200,255); bb.Font=Enum.Font.GothamBold; bb.TextSize=isSmallScreen and 9 or 11
	bb.BorderSizePixel=0; bb.AutoButtonColor=false
	bb.Text=Binds[aK] and tostring(Binds[aK]):gsub("Enum%.KeyCode%.","") or "?"
	Instance.new("UICorner",bb); Instance.new("UIStroke",bb).Color=Color3.fromRGB(0,100,200)
	BBtns[aK]=bb
	bb.MouseButton1Click:Connect(function() if waitingForBind then return end; waitingForBind=aK; bb.Text="[...]"; bb.TextColor3=Color3.fromRGB(255,220,50) end)
end
for _, e in pairs(bA) do AddBR("Binds",e.key,e.name) end

AddCategory("Binds","SCREEN SHORTCUTS 📱")
local scInfo=Instance.new("Frame",Scroll); scInfo.Size=UDim2.new(0.97,0,0,isSmallScreen and 24 or (IsMobile and 30 or 24))
scInfo.BackgroundColor3=Color3.fromRGB(12,12,22); scInfo.BorderSizePixel=0; scInfo.Visible=false
Instance.new("UICorner",scInfo); table.insert(Sections["Binds"],scInfo)
local scInfoL=Instance.new("TextLabel",scInfo); scInfoL.Size=UDim2.new(1,0,1,0); scInfoL.BackgroundTransparency=1
scInfoL.TextColor3=Color3.fromRGB(120,160,255); scInfoL.Font=Enum.Font.Gotham; scInfoL.TextSize=isSmallScreen and 8 or 10; scInfoL.TextWrapped=true
scInfoL.Text="Show/hide screen buttons"

local scToggleH = isSmallScreen and 30 or (IsMobile and 38 or 34)
for _, def in ipairs(ShortcutDefs) do
	local f=Instance.new("Frame",Scroll); f.Size=UDim2.new(0.97,0,0,scToggleH)
	f.BackgroundTransparency=1; f.BorderSizePixel=0; f.Visible=false; table.insert(Sections["Binds"],f)
	local btn=Instance.new("TextButton",f); btn.Size=UDim2.new(1,0,1,0); btn.Font=Enum.Font.GothamBold
	btn.TextSize=isSmallScreen and 9 or (IsMobile and 11 or 12); btn.BorderSizePixel=0; btn.AutoButtonColor=false
	btn.TextXAlignment=Enum.TextXAlignment.Left; Instance.new("UICorner",btn)
	local function U()
		if Config[def.scKey] then btn.BackgroundColor3=Color3.fromRGB(0,60,40); btn.TextColor3=Color3.fromRGB(100,255,130); btn.Text=" 📱 "..def.label..": VISIBLE"
		else btn.BackgroundColor3=Color3.fromRGB(40,15,15); btn.TextColor3=Color3.fromRGB(255,130,130); btn.Text=" 📱 "..def.label..": HIDDEN" end
		if ShortcutBtns[def.key] then ShortcutBtns[def.key].update() end
	end; U()
	btn.MouseButton1Click:Connect(function() Config[def.scKey]=not Config[def.scKey]; U(); SaveSettings(Config,ItemPickerState) end)
end

local function ShowTab(n)
	ActiveTab=n
	for nn,frames in pairs(Sections) do for _,f in pairs(frames) do pcall(function() f.Visible=(nn==n) end) end end
	if n=="Items" then FilterItems(sB.Text) end
	for nn,b in pairs(TabButtons) do
		if nn==n then b.BackgroundColor3=Color3.fromRGB(0,100,220); b.TextColor3=Color3.new(1,1,1)
		else b.BackgroundColor3=Color3.fromRGB(18,18,30); b.TextColor3=Color3.fromRGB(150,150,170) end
	end
	task.wait(); Scroll.CanvasPosition=Vector2.zero; Scroll.CanvasSize=UDim2.new(0,0,0,LL.AbsoluteContentSize.Y+20)
end
for n,b in pairs(TabButtons) do b.MouseButton1Click:Connect(function() ShowTab(n) end) end

UIS.InputBegan:Connect(function(inp,gpe)
	if waitingForBind then
		if inp.UserInputType==Enum.UserInputType.Keyboard then
			if inp.KeyCode==Enum.KeyCode.F then
				if BBtns[waitingForBind] then BBtns[waitingForBind].Text="⚠ Not F!"; BBtns[waitingForBind].TextColor3=Color3.fromRGB(255,80,80) end
				task.delay(1,function() if BBtns[waitingForBind] then local a=waitingForBind; BBtns[a].Text=Binds[a] and tostring(Binds[a]):gsub("Enum%.KeyCode%.","") or "?"; BBtns[a].TextColor3=Color3.fromRGB(170,200,255) end; waitingForBind=nil end)
				return
			end
			local a=waitingForBind; Binds[a]=inp.KeyCode
			if BBtns[a] then BBtns[a].Text=tostring(inp.KeyCode):gsub("Enum%.KeyCode%.",""); BBtns[a].TextColor3=Color3.fromRGB(170,200,255) end
			waitingForBind=nil; SaveSettings(Config,ItemPickerState)
		end; return
	end
	if gpe then return end
	if inp.KeyCode==Enum.KeyCode.F then return end
	for a,k in pairs(Binds) do
		if inp.KeyCode~=k then continue end
		if a=="ToggleUI" then Main.Visible=not Main.Visible
		elseif a=="Fly" then
			Config.Fly=not Config.Fly; if UpdFuncs.Fly then UpdFuncs.Fly(Config.Fly) end
			UpdateFlyBtns(); UpdateAllShortcuts()
			if not Config.Fly then local h=GetHum(); if h then h.PlatformStand=false;h.WalkSpeed=16 end end
		elseif a=="AimActive" then
			Config.AimActive=not Config.AimActive; if UpdFuncs.AimActive then UpdFuncs.AimActive(Config.AimActive) end
			UpdateAllShortcuts(); aimTarget=nil;aimLocked=false;aimLostFrames=0;aimHasLockedOnce=not Config.AimActive
		elseif a=="Noclip" then
			Config.Noclip=not Config.Noclip; if UpdFuncs.Noclip then UpdFuncs.Noclip(Config.Noclip) end
			UpdateAllShortcuts(); if not Config.Noclip then RestoreCollision() end
		elseif a=="SilentAim" then
			Config.SilentAim=not Config.SilentAim; if UpdFuncs.SilentAim then UpdFuncs.SilentAim(Config.SilentAim) end
			UpdateAllShortcuts(); if not Config.SilentAim then StopSilentAim() end
		end
	end
end)

-- ★★★ M КНОПКА — АДАПТИВНИЙ РОЗМІР ★★★
local MS=isSmallScreen and 44 or (IsMobile and 56 or 44)
local MB=Instance.new("TextButton",SG); MB.Size=UDim2.new(0,MS,0,MS); MB.Position=UDim2.new(0,10,0.25,0)
MB.Text="M"; MB.Font=Enum.Font.GothamBlack; MB.TextSize=isSmallScreen and 18 or (IsMobile and 24 or 20)
MB.BackgroundColor3=Color3.fromRGB(0,80,200); MB.TextColor3=Color3.new(1,1,1)
MB.BorderSizePixel=0; MB.AutoButtonColor=false; MB.ZIndex=100
Instance.new("UICorner",MB); Instance.new("UIStroke",MB).Color=Color3.new(1,1,1)
task.spawn(function()
	while true do
		TweenService:Create(MB,TweenInfo.new(1.6),{BackgroundColor3=Color3.fromRGB(0,40,160)}):Play(); task.wait(1.6)
		TweenService:Create(MB,TweenInfo.new(1.6),{BackgroundColor3=Color3.fromRGB(0,110,255)}):Play(); task.wait(1.6)
	end
end)
do
	local d,s,p,t,m=false,nil,nil,0,false
	MB.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then d=true;s=i.Position;p=MB.Position;t=tick();m=false end end)
	MB.InputChanged:Connect(function(i) if not d then return end; if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then local dl=i.Position-s; if dl.Magnitude>8 then m=true end; MB.Position=UDim2.new(p.X.Scale,p.X.Offset+dl.X,p.Y.Scale,p.Y.Offset+dl.Y) end end)
	MB.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then if d and not m and tick()-t<0.3 then Main.Visible=not Main.Visible end; d=false end end)
	UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then d=false end end)
end

ShowTab("Combat")
if Config.Fullbright then task.spawn(EnableFB) end
if Config.FPSBoost then task.spawn(ApplyFPS) end
if Config.HighJump then local h=GetHum(); if h then h.UseJumpPower=true;h.JumpPower=Config.JumpPowerValue end end
if Config.Speed then local h=GetHum(); if h then h.WalkSpeed=Config.WalkSpeedValue end end
UpdateAllShortcuts(); UpdateFlyBtns()

Notify("⚡ V64","M=menu | Adaptive UI ✓",5)