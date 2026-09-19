local P = game:GetService("Players")
local T = game:GetService("TweenService")
local U = game:GetService("UserInputService")
local R = game:GetService("RunService")
local L = P.LocalPlayer

if _G.HubActive then _G.HubActive = false task.wait(0.1) end
_G.HubActive = true

local old = L.PlayerGui:FindFirstChild("BeyondConsoleHub")
if old then old:Destroy() end

local SG = Instance.new("ScreenGui", L.PlayerGui)
SG.Name = "BeyondConsoleHub"
SG.IgnoreGuiInset = true

local BL = Color3.fromRGB(0, 150, 255) 
local BK = Color3.fromRGB(10, 10, 12)  
local WH = Color3.fromRGB(240, 240, 245)
local RED = Color3.fromRGB(255, 60, 100) 

local St = {Speed = 16, Gh = false, AutoFarm = false, Stealth = false, St = false}
local cW, origStats = {}, {}

-- 1. ИКОНКА (Черный квадрат с синей неоновой рамкой)
local AT = Instance.new("Frame", SG)
AT.Size = UDim2.new(0, 85, 0, 80)
AT.Position = UDim2.new(0.05, 0, 0.2, 0)
AT.BackgroundColor3 = BK
AT.BorderColor3 = BL
AT.BorderSizePixel = 2
AT.Active = true

-- СЛОИ ПИКСЕЛЬНОЙ ZERO TWO С ЧУПА-ЧУПСОМ (ZIndex = 1)
local HairBack = Instance.new("Frame", AT)
HairBack.Size = UDim2.new(0.85, 0, 0.75, 0)
HairBack.Position = UDim2.new(0.075, 0, 0.15, 0)
HairBack.BackgroundColor3 = RED; HairBack.BorderSizePixel = 0; HairBack.ZIndex = 1

local Face = Instance.new("Frame", AT)
Face.Size = UDim2.new(0.5, 0, 0.5, 0)
Face.Position = UDim2.new(0.25, 0, 0.35, 0)
Face.BackgroundColor3 = Color3.fromRGB(255, 225, 210); Face.BorderSizePixel = 0; Face.ZIndex = 1

local Bangs = Instance.new("Frame", AT)
Bangs.Size = UDim2.new(0.6, 0, 0.18, 0)
Bangs.Position = UDim2.new(0.2, 0, 0.25, 0)
Bangs.BackgroundColor3 = RED; Bangs.BorderSizePixel = 0; Bangs.ZIndex = 1

local LeftHorn = Instance.new("Frame", AT)
LeftHorn.Size = UDim2.new(0.1, 0, 0.22, 0)
LeftHorn.Position = UDim2.new(0.25, 0, 0.04, 0)
LeftHorn.BackgroundColor3 = Color3.fromRGB(240, 30, 30); LeftHorn.BorderSizePixel = 0; LeftHorn.ZIndex = 1

local RightHorn = Instance.new("Frame", AT)
RightHorn.Size = UDim2.new(0.1, 0, 0.22, 0)
RightHorn.Position = UDim2.new(0.65, 0, 0.04, 0)
RightHorn.BackgroundColor3 = Color3.fromRGB(240, 30, 30); RightHorn.BorderSizePixel = 0; RightHorn.ZIndex = 1

local Headband = Instance.new("Frame", AT)
Headband.Size = UDim2.new(0.5, 0, 0.05, 0)
Headband.Position = UDim2.new(0.25, 0, 0.23, 0)
Headband.BackgroundColor3 = WH; Headband.BorderSizePixel = 0; Headband.ZIndex = 1

local EyeL = Instance.new("Frame", Face)
EyeL.Size = UDim2.new(0.22, 0, 0.14, 0)
EyeL.Position = UDim2.new(0.12, 0, 0.3, 0)
EyeL.BackgroundColor3 = Color3.fromRGB(30, 190, 190); EyeL.BorderSizePixel = 0; EyeL.ZIndex = 1

local EyeR = Instance.new("Frame", Face)
EyeR.Size = UDim2.new(0.22, 0, 0.14, 0)
EyeR.Position = UDim2.new(0.66, 0, 0.3, 0)
EyeR.BackgroundColor3 = Color3.fromRGB(30, 190, 190); EyeR.BorderSizePixel = 0; EyeR.ZIndex = 1

local CandyStick = Instance.new("Frame", Face)
CandyStick.Size = UDim2.new(0.06, 0, 0.3, 0)
CandyStick.Position = UDim2.new(0.47, 0, 0.72, 0)
CandyStick.BackgroundColor3 = WH; CandyStick.BorderSizePixel = 0; CandyStick.ZIndex = 1

local CandyPop = Instance.new("Frame", Face)
CandyPop.Size = UDim2.new(0.18, 0, 0.18, 0)
CandyPop.Position = UDim2.new(0.41, 0, 0.62, 0)
CandyPop.BackgroundColor3 = Color3.fromRGB(255, 50, 50); CandyPop.BorderSizePixel = 0; CandyPop.ZIndex = 1
Instance.new("UICorner", CandyPop).CornerRadius = UDim.new(0, 4)

-- ВЫНОСИМ КНОПКУ ТАПА НА САМЫЙ ПЕРЕДНИЙ ПЛАН (ZIndex = 100)
local TB = Instance.new("TextButton", AT)
TB.Size = UDim2.new(1, 0, 1, 0)
TB.BackgroundTransparency = 1; TB.Text = ""; TB.ZIndex = 100

-- 2. ГЛАВНАЯ ПРОФЕССИОНАЛЬНАЯ КОНСОЛЬ
local MM = Instance.new("Frame", SG)
MM.Size = UDim2.new(0.50, 0, 0.80, 0)
MM.Position = UDim2.new(0.5, 0, 0.5, 0)
MM.AnchorPoint = Vector2.new(0.5, 0.5)
MM.BackgroundColor3 = BK; MM.BorderColor3 = BL; MM.BorderSizePixel = 4; MM.Visible = false; MM.Active = true; MM.ZIndex = 10

local Ly = Instance.new("UIListLayout", MM)
Ly.Padding = UDim.new(0, 6)
Ly.HorizontalAlignment, Ly.VerticalAlignment = Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Top

-- ИСПРАВЛЕННЫЙ МОБИЛЬНЫЙ ПЕРЕТАСКИВАТЕЛЬ
local function drag(frame, trigger)
	local tr = trigger or frame; local d, di, ds, sp
	tr.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then d = true; ds = i.Position; sp = frame.Position end end)
	tr.InputChanged:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then di = i end end)
	R.RenderStepped:Connect(function() if d and di then local dl = di.Position - ds; frame.Position = UDim2.new(sp.X.Scale, sp.X.Offset + dl.X, sp.Y.Scale, sp.Y.Offset + dl.Y) end end)
	U.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then d = false end end)
end drag(AT, TB) drag(MM)

local Bar = Instance.new("Frame", MM) Bar.Size = UDim2.new(0.95, 0, 0, 40) Bar.BackgroundTransparency = 1; Bar.ZIndex = 11
local Title = Instance.new("TextLabel", Bar) Title.Size = UDim2.new(0.6, 0, 1, 0) Title.Text = "USERBEYOND // DEV_CONSOLE_v3.0" Title.TextColor3 = BL; Title.TextSize = 13; Title.TextXAlignment = Enum.TextXAlignment.Left; Title.Font = Enum.Font.Code; Title.ZIndex = 11
local Cl = Instance.new("TextButton", Bar) Cl.Size = UDim2.new(0, 35, 0, 35) Cl.Position = UDim2.new(1, -35, 0, 2) Cl.BackgroundColor3 = Color3.fromRGB(180, 40, 40) Cl.Text = "X" Cl.TextColor3 = WH; Cl.ZIndex = 12; Instance.new("UICorner", Cl)
local Mn = Instance.new("TextButton", Bar) Mn.Size = UDim2.new(0, 35, 0, 35) Mn.Position = UDim2.new(1, -75, 0, 2) Mn.BackgroundColor3 = Color3.fromRGB(60, 60, 60) Mn.Text = "—" Mn.TextColor3 = WH; Mn.ZIndex = 12; Instance.new("UICorner", Mn)
local function cB(t)
	local b = Instance.new("TextButton", MM) b.Size = UDim2.new(0.94, 0, 0, 36) b.BackgroundColor3 = Color3.fromRGB(22, 22, 26) b.BorderColor3 = Color3.fromRGB(40, 40, 40) b.Text = ">> " .. t .. " [ВЫКЛ]" b.TextColor3 = WH; b.TextSize = 12; b.Font = Enum.Font.Code; b.TextXAlignment = Enum.TextXAlignment.Left; b.ZIndex = 11; Instance.new("UICorner", b) return b
end
local bSp, bSt, bGh, bFm, bSth = cB("ФОРС СКОРОСТИ КЛИЕНТА (WalkSpeed = 35)"), cB("АНТИ-ДЕФЕКТОР КОНТРОЛЯ (Anti-Stun / No-Knockback)"), cB("ОБХОД ГЕОМЕТРИИ КАРТЫ (Noclip Mode)"), cB("ПАКЕТНЫЙ СВЕРХФАРМ МОБОВ (Млн EXP/миллисекунда)"), cB("РЕЖИМ СКРЫТНОСТИ (Убрать из Лидеров и Скрыть Ник)")

TB.TouchTap:Connect(function() AT.Visible = false; MM.Visible = true end)
TB.MouseButton1Click:Connect(function() AT.Visible = false; MM.Visible = true end)
Mn.TouchTap:Connect(function() MM.Visible = false; AT.Visible = true end)
Mn.MouseButton1Click:Connect(function() MM.Visible = false; AT.Visible = true end)

R.RenderStepped:Connect(function() if St.Speed > 16 and _G.HubActive then local c = L.Character; local h = c and c:FindFirstChildOfClass("Humanoid") if h then h.WalkSpeed = St.Speed end end end)
bSp.MouseButton1Click:Connect(function() if St.Speed == 16 then St.Speed = 35; bSp.Text = ">> ФОРС СКОРОСТИ КЛИЕНТА [АКТИВЕН: 35]" bSp.BackgroundColor3 = Color3.fromRGB(0, 80, 150) else St.Speed = 16; bSp.Text = ">> ФОРС СКОРОСТИ КЛИЕНТА (WalkSpeed = 35)" bSp.BackgroundColor3 = Color3.fromRGB(22, 22, 26) end end)
R.Heartbeat:Connect(function() if St.St and _G.HubActive then local c = L.Character; local h, r = c and c:FindFirstChildOfClass("Humanoid"), c and c:FindFirstChild("HumanoidRootPart") if h and r then if h.PlatformStand or h.Sit then h.PlatformStand = false; h.Sit = false; h:ChangeState(Enum.HumanoidStateType.Running) end h:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false) h:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false) for _, ch in ipairs(r:GetChildren()) do if ch:IsA("BodyVelocity") or ch:IsA("LinearVelocity") or ch:IsA("BodyForce") then ch:Destroy() end end end end end)
bSt.MouseButton1Click:Connect(function() St.St = not St.St; bSt.Text = St.St and ">> АНТИ-ДЕФЕКТОР КОНТРОЛЯ [ПЕРЕХВАТ ВКЛ]" or ">> АНТИ-ДЕФЕКТОР КОНТРОЛЯ (Anti-Stun / No-Knockback)" bSt.BackgroundColor3 = St.St and Color3.fromRGB(0, 80, 150) or Color3.fromRGB(22, 22, 26) end)
local function isF(p) if p.Name:lower():find("floor") or p.Name:lower():find("baseplate") then return true end return p.CFrame.UpVector.Y > 0.9 and p.Size.X > 10 end
bGh.MouseButton1Click:Connect(function() St.Gh = not St.Gh; bGh.Text = St.Gh and ">> ОБХОД ГЕОМЕТРИИ КАРТЫ [NOCLIP ВКЛ]" or ">> ОБХОД ГЕОМЕТРИИ КАРТЫ (Noclip Mode)" bGh.BackgroundColor3 = St.Gh and Color3.fromRGB(0, 80, 150) or Color3.fromRGB(22, 22, 26) if St.Gh then for _, o in ipairs(workspace:GetDescendants()) do if o:IsA("BasePart") and not isF(o) and not o:IsDescendantOf(L.Character) then cW[o] = {C = o.CanCollide, T = o.Transparency} o.CanCollide = false; o.Transparency = 0.60 end end else for p, g in pairs(cW) do if p and p.Parent then p.CanCollide = g.C; p.Transparency = g.T end end table.clear(cW) end end)

local remoteCache = {}
local function updateRemoteCache()
	table.clear(remoteCache)
	for _, v in ipairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
		if v:IsA("RemoteEvent") and (v.Name:lower():find("kill") or v.Name:lower():find("reward") or v.Name:lower():find("hit")) then table.insert(remoteCache, v) end
	end
end

task.spawn(function()
	while task.wait(0.001) do 
		if St.AutoFarm and _G.HubActive then
			for _, remote in ipairs(remoteCache) do if remote and remote.Parent then remote:FireServer("Mob", true) end end
			local leader = L:FindFirstChild("leaderstat") or L:FindFirstChild("leaderstats")
			if leader then for _, stat in ipairs(leader:GetChildren()) do if stat.Name:lower():find("exp") or stat.Name:lower():find("опыт") or stat.Name:lower():find("lvl") then stat.Value = stat.Value + 250000 end end end
		end
	end
end)
bFm.MouseButton1Click:Connect(function() St.AutoFarm = not St.AutoFarm; if St.AutoFarm then updateRemoteCache() end; bFm.Text = St.AutoFarm and ">> ПАКЕТНЫЙ СВЕРХФАРМ [ГЕНЕРАЦИЯ EXP: МЛН/МС]" or ">> ПАКЕТНЫЙ СВЕРХФАРМ МОБОВ (Мнл EXP/мс)" bFm.BackgroundColor3 = St.AutoFarm and Color3.fromRGB(0, 80, 150) or Color3.fromRGB(22, 22, 26) end)

task.spawn(function()
	while task.wait(0.2) do
		if St.Stealth and _G.HubActive then
			local c = L.Character; if c and c:FindFirstChild("Head") and c.Head:FindFirstChildOfClass("BillboardGui") then c.Head:FindFirstChildOfClass("BillboardGui"):Destroy() end
			local pList = game:GetService("CoreGui"):FindFirstChild("PlayerList") or L.PlayerGui:FindFirstChild("PlayerList") if pList then pList.Enabled = false end
			local leader = L:FindFirstChild("leaderstat") or L:FindFirstChild("leaderstats")
			if leader then for _, stat in ipairs(leader:GetChildren()) do if not origStats[stat.Name] then origStats[stat.Name] = stat.Value end stat.Value = 0 end end
		end
	end
end)
bSth.MouseButton1Click:Connect(function() St.Stealth = not St.Stealth; bSth.Text = St.Stealth and ">> РЕЖИМ СКРЫТНОСТИ [СТАТУС: ПОЛНАЯ АНОНИМНОСТЬ]" or ">> РЕЖИМ СКРЫТНОСТИ (Скрыть Ник, Статы и Лидерство)" bSth.BackgroundColor3 = St.Stealth and Color3.fromRGB(0, 80, 150) or Color3.fromRGB(22, 22, 26)
	if not St.Stealth then local pList = game:GetService("CoreGui"):FindFirstChild("PlayerList") or L.PlayerGui:FindFirstChild("PlayerList") if pList then pList.Enabled = true end local leader = L:FindFirstChild("leaderstat") or L:FindFirstChild("leaderstats") if leader then for _, stat in ipairs(leader:GetChildren()) do if origStats[stat.Name] then stat.Value = origStats[stat.Name] end end end table.clear(origStats) end
end)

Cl.MouseButton1Click:Connect(function()
	_G.HubActive = false; task.wait(0.1)
	for p, g in pairs(cW) do if p and p.Parent then p.CanCollide = g.C; p.Transparency = g.T end end
	local c = L.Character; local h = c and c:FindFirstChildOfClass("Humanoid") if h then h.WalkSpeed = 16 end SG:Destroy()
end
