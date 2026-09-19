local P = game:GetService("Players")
local T = game:GetService("TweenService")
local U = game:GetService("UserInputService")
local R = game:GetService("RunService")
local L = P.LocalPlayer

if _G.HubActive then _G.HubActive = false task.wait(0.1) end
_G.HubActive = true

local old = L.PlayerGui:FindFirstChild("ZeroTwoConsoleHub")
if old then old:Destroy() end

local SG = Instance.new("ScreenGui", L.PlayerGui)
SG.Name = "ZeroTwoConsoleHub"
SG.IgnoreGuiInset = true

local BL = Color3.fromRGB(0, 150, 255) 
local BK = Color3.fromRGB(10, 10, 12)  
local WH = Color3.fromRGB(240, 240, 245)
local PINK = Color3.fromRGB(255, 155, 180) 
local RED_HORN = Color3.fromRGB(220, 40, 40)

local St = {Speed = 16, Jump = false, Gh = false, AutoFarm = false, Stealth = false}
local cW, origStats = {}, {}

local AT = Instance.new("Frame", SG)
AT.Size = UDim2.new(0, 80, 0, 80)
AT.Position = UDim2.new(0.05, 0, 0.2, 0)
AT.BackgroundColor3 = BK; AT.BorderColor3 = BL; AT.BorderSizePixel = 2; AT.Active = true

local HairBack = Instance.new("Frame", AT)
HairBack.Size = UDim2.new(0.9, 0, 0.85, 0)
HairBack.Position = UDim2.new(0.05, 0, 0.1, 0)
HairBack.BackgroundColor3 = PINK; HairBack.BorderSizePixel = 0; HairBack.ZIndex = 1

local Face = Instance.new("Frame", AT)
Face.Size = UDim2.new(0.65, 0, 0.55, 0)
Face.Position = UDim2.new(0.175, 0, 0.35, 0)
Face.BackgroundColor3 = Color3.fromRGB(255, 230, 215); Face.BorderSizePixel = 0; Face.ZIndex = 1

local Bangs = Instance.new("Frame", AT)
Bangs.Size = UDim2.new(0.65, 0, 0.15, 0)
Bangs.Position = UDim2.new(0.175, 0, 0.3, 0)
Bangs.BackgroundColor3 = PINK; Bangs.BorderSizePixel = 0; Bangs.ZIndex = 1

local WhiteBand = Instance.new("Frame", AT)
WhiteBand.Size = UDim2.new(0.6, 0, 0.05, 0)
WhiteBand.Position = UDim2.new(0.2, 0, 0.27, 0)
WhiteBand.BackgroundColor3 = WH; WhiteBand.BorderSizePixel = 0; WhiteBand.ZIndex = 1

local HornL = Instance.new("Frame", AT)
HornL.Size = UDim2.new(0.08, 0, 0.18, 0)
HornL.Position = UDim2.new(0.22, 0, 0.1, 0)
HornL.BackgroundColor3 = RED_HORN; HornL.BorderSizePixel = 0; HornL.ZIndex = 1

local HornR = Instance.new("Frame", AT)
HornR.Size = UDim2.new(0.08, 0, 0.18, 0)
HornR.Position = UDim2.new(0.7, 0, 0.1, 0)
HornR.BackgroundColor3 = RED_HORN; HornR.BorderSizePixel = 0; HornR.ZIndex = 1

local EyeL = Instance.new("Frame", Face)
EyeL.Size = UDim2.new(0.24, 0, 0.35, 0)
EyeL.Position = UDim2.new(0.12, 0, 0.25, 0)
EyeL.BackgroundColor3 = Color3.fromRGB(40, 180, 185); EyeL.BorderSizePixel = 0; EyeL.ZIndex = 1

local EyeR = Instance.new("Frame", Face)
EyeR.Size = UDim2.new(0.24, 0, 0.35, 0)
EyeR.Position = UDim2.new(0.64, 0, 0.25, 0)
EyeR.BackgroundColor3 = Color3.fromRGB(40, 180, 185); EyeR.BorderSizePixel = 0; EyeR.ZIndex = 1

local Mouth = Instance.new("Frame", Face)
Mouth.Size = UDim2.new(0.35, 0, 0.25, 0)
Mouth.Position = UDim2.new(0.325, 0, 0.65, 0)
Mouth.BackgroundColor3 = Color3.fromRGB(240, 100, 110); Mouth.BorderSizePixel = 0; Mouth.ZIndex = 1
Instance.new("UICorner", Mouth).CornerRadius = UDim.new(0, 6)

local ToothL = Instance.new("Frame", Mouth)
ToothL.Size = UDim2.new(0.15, 0, 0.2, 0)
ToothL.Position = UDim2.new(0.1, 0, 0, 0)
ToothL.BackgroundColor3 = WH; ToothL.BorderSizePixel = 0; ToothL.ZIndex = 2

local ToothR = Instance.new("Frame", Mouth)
ToothR.Size = UDim2.new(0.15, 0, 0.2, 0)
ToothR.Position = UDim2.new(0.75, 0, 0, 0)
ToothR.BackgroundColor3 = WH; ToothR.BorderSizePixel = 0; ToothR.ZIndex = 2

local TB = Instance.new("TextButton", AT)
TB.Size = UDim2.new(1, 0, 1, 0)
TB.BackgroundTransparency = 1; TB.Text = ""; TB.ZIndex = 100

local MM = Instance.new("Frame", SG)
MM.Size = UDim2.new(0.50, 0, 0.80, 0)
MM.Position = UDim2.new(0.5, 0, 0.5, 0)
MM.AnchorPoint = Vector2.new(0.5, 0.5)
MM.BackgroundColor3 = BK; MM.BorderColor3 = BL; MM.BorderSizePixel = 4; MM.Visible = false; MM.Active = true; MM.ZIndex = 10

local Ly = Instance.new("UIListLayout", MM)
Ly.Padding = UDim.new(0, 6)
Ly.HorizontalAlignment, Ly.VerticalAlignment = Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Top

local function drag(frame, trigger)
	local tr = trigger or frame; local d, di, ds, sp
	tr.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then d = true; ds = i.Position; sp = frame.Position end end)
	tr.InputChanged:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then di = i end end)
	R.RenderStepped:Connect(function() if d and di then local dl = di.Position - ds; frame.Position = UDim2.new(sp.X.Scale, sp.X.Offset + dl.X, sp.Y.Scale, sp.Y.Offset + dl.Y) end end)
	U.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then d = false end end)
end drag(AT, TB); drag(MM)

local Bar = Instance.new("Frame", MM) Bar.Size = UDim2.new(0.95, 0, 0, 40) Bar.BackgroundTransparency = 1; Bar.ZIndex = 11
local Title = Instance.new("TextLabel", Bar) Title.Size = UDim2.new(0.6, 0, 1, 0) Title.Text = "USERBEYOND // DEV_CONSOLE_v3.0" Title.TextColor3 = BL; Title.TextSize = 13; Title.TextXAlignment = Enum.TextXAlignment.Left; Title.Font = Enum.Font.Code; Title.ZIndex = 11
local Cl = Instance.new("TextButton", Bar) Cl.Size = UDim2.new(0, 35, 0, 35) Cl.Position = UDim2.new(1, -35, 0, 2) Cl.BackgroundColor3 = Color3.fromRGB(180, 40, 40) Cl.Text = "X" Cl.TextColor3 = WH; Cl.ZIndex = 12; Instance.new("UICorner", Cl)
local Mn = Instance.new("TextButton", Bar) Mn.Size = UDim2.new(0, 35, 0, 35) Mn.Position = UDim2.new(1, -75, 0, 2) Mn.BackgroundColor3 = Color3.fromRGB(60, 60, 60) Mn.Text = "—" Mn.TextColor3 = WH; Mn.ZIndex = 12; Instance.new("UICorner", Mn)
local function cB(t)
	local b = Instance.new("TextButton", MM) b.Size = UDim2.new(0.94, 0, 0, 36) b.BackgroundColor3 = Color3.fromRGB(22, 22, 26) b.BorderColor3 = Color3.fromRGB(40, 40, 40) b.Text = ">> " .. t .. " [ВЫКЛ]" b.TextColor3 = WH; b.TextSize = 12; b.Font = Enum.Font.Code; b.TextXAlignment = Enum.TextXAlignment.Left; b.ZIndex = 11; Instance.new("UICorner", b) return b
end
local bSp = cB("Скорость Бега (Постоянный Форс)")
local bJm = cB("Бесконечный Прыжок (Взлет в воздух)")
local bGh = cB("Проход Сквозь Все Стены (Noclip Mode)")
local bFm = cB("Сверх-Фарм Опыта и Силы (Млн EXP/мс)")
local bSth = cB("Анонимность (Скрыть Ник и Топ Лидеров)")

local SliderFrame = Instance.new("Frame", MM) SliderFrame.Size = UDim2.new(0.94, 0, 0, 35) SliderFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 26) SliderFrame.ZIndex = 11; Instance.new("UICorner", SliderFrame)
local SliderText = Instance.new("TextLabel", SliderFrame) SliderText.Size = UDim2.new(0.4, 0, 1, 0) SliderText.BackgroundTransparency = 1; SliderText.Text = "Скорость: 35" SliderText.TextColor3 = WH; SliderText.TextSize = 11; SliderText.ZIndex = 12; SliderText.Font = Enum.Font.Code
local SliderBar = Instance.new("Frame", SliderFrame) SliderBar.Size = UDim2.new(0.55, 0, 0, 8) SliderBar.Position = UDim2.new(0.4, 0, 0.4, 0) SliderBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50); SliderBar.ZIndex = 12
local SliderButton = Instance.new("TextButton", SliderBar) SliderButton.Size = UDim2.new(0, 16, 0, 16) SliderButton.Position = UDim2.new(0.1, 0, -0.5, 0) SliderButton.BackgroundColor3 = BL; SliderButton.Text = ""; SliderButton.ZIndex = 13; Instance.new("UICorner", SliderButton)

local sliderDragging = false
SliderButton.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliderDragging = true end end)
U.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliderDragging = false end end)
R.RenderStepped:Connect(function()
	if sliderDragging then
		local mousePos = U:GetMouseLocation().X; local barGlobalPos = SliderBar.AbsolutePosition.X; local barWidth = SliderBar.AbsoluteSize.X
		local percentage = math.clamp((mousePos - barGlobalPos) / barWidth, 0, 1)
		SliderButton.Position = UDim2.new(percentage, -8, -0.5, 0)
		St.Speed = math.floor(16 + (percentage * (300 - 16)))
		SliderText.Text = "Скорость: " .. tostring(St.Speed)
	end
end)

TB.TouchTap:Connect(function() AT.Visible = false; MM.Visible = true end)
TB.MouseButton1Click:Connect(function() AT.Visible = false; MM.Visible = true end)
Mn.TouchTap:Connect(function() MM.Visible = false; AT.Visible = true end)
Mn.MouseButton1Click:Connect(function() MM.Visible = false; AT.Visible = true end)

R.RenderStepped:Connect(function() if St.Speed > 16 and _G.HubActive then local c = L.Character; local h = c and c:FindFirstChildOfClass("Humanoid") if h then h.WalkSpeed = St.Speed end end end)
bSp.MouseButton1Click:Connect(function() if St.Speed == 16 then St.Speed = 35; bSp.Text = ">> Скорость Бега [АКТИВЕН]" bSp.BackgroundColor3 = Color3.fromRGB(0, 80, 150) else St.Speed = 16; bSp.Text = ">> Скорость Бега (Постоянный Форс)" bSp.BackgroundColor3 = Color3.fromRGB(22, 22, 26) end end)

bJm.MouseButton1Click:Connect(function() St.Jump = not St.Jump; bJm.Text = St.Jump and ">> Бесконечный Прыжок [ВКЛ]" or ">> Бесконечный Прыжок (Взлет в воздух)" bJm.BackgroundColor3 = St.Jump and Color3.fromRGB(0, 80, 150) or Color3.fromRGB(22, 22, 26) end)
U.JumpRequest:Connect(function() local c = L.Character; local h = c and c:FindFirstChildOfClass("Humanoid") if St.Jump and h and _G.HubActive then h:ChangeState(Enum.HumanoidStateType.Jumping) end end)

local function isF(p) if p.Name:lower():find("floor") or p.Name:lower():find("baseplate") then return true end return p.CFrame.UpVector.Y > 0.9 and p.Size.X > 10 end
bGh.MouseButton1Click:Connect(function() St.Gh = not St.Gh; bGh.Text = St.Gh and ">> Проход Сквозь Все Стены [АКТИВЕН]" or ">> Проход Сквозь Все Стены (Noclip Mode)" bGh.BackgroundColor3 = St.Gh and Color3.fromRGB(0, 80, 150) or Color3.fromRGB(22, 22, 26)
	if St.Gh then for _, o in ipairs(workspace:GetDescendants()) do if o:IsA("BasePart") and not isF(o) and not o:IsDescendantOf(L.Character) then cW[o] = {C = o.CanCollide, T = o.Transparency} o.CanCollide = false; o.Transparency = 0.60 end end
	else for p, g in pairs(cW) do if p and p.Parent then p.CanCollide = g.C; p.Transparency = g.T end end table.clear(cW) end
end)

local remoteCache = {}
local function updateRemoteCache()
	table.clear(remoteCache)
	for _, v in ipairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
		if v:IsA("RemoteEvent") and (v.Name:lower():find("kill") or v.Name:lower():find("reward") or v.Name:lower():find("hit") or v.Name:lower():find("weapon")) then table.insert(remoteCache, v) end
	end
end

task.spawn(function()
	while task.wait(0.001) do 
		if St.AutoFarm and _G.HubActive then
			for _, remote in ipairs(remoteCache) do if remote and remote.Parent then remote:FireServer("Mob", true) remote:FireServer() end end
			local leader = L:FindFirstChild("leaderstat") or L:FindFirstChild("leaderstats")
			if leader then for _, stat in ipairs(leader:GetChildren()) do if stat.Name:lower():find("exp") or stat.Name:lower():find("опыт") or stat.Name:lower():find("lvl") or stat.Name:lower():find("power") or stat.Name:lower():find("сила") then stat.Value = stat.Value + 250000 end end end
		end
	end
end)
bFm.MouseButton1Click:Connect(function() St.AutoFarm = not St.AutoFarm; if St.AutoFarm then updateRemoteCache() end; bFm.Text = St.AutoFarm and ">> Сверх-Фарм Опыта [АКТИВЕН]" or ">> Сверх-Фарм Опыта и Силы (Млн EXP/мс)" bFm.BackgroundColor3 = St.AutoFarm and Color3.fromRGB(0, 80, 150) or Color3.fromRGB(22, 22, 26) end)

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
bSth.MouseButton1Click:Connect(function() St.Stealth = not St.Stealth; bSth.Text = St.Stealth and ">> Анонимность [АКТИВЕН]" or ">> Анонимность (Скрыть Ник и Топ Лидеров)" bSth.BackgroundColor3 = St.Stealth and Color3.fromRGB(0, 80, 150) or Color3.fromRGB(22, 22, 26)
	if not St.Stealth then local pList = game:GetService("CoreGui"):FindFirstChild("PlayerList") or L.PlayerGui:FindFirstChild("PlayerList") if pList then pList.Enabled = true end local leader = L:FindFirstChild("leaderstat") or L:FindFirstChild("leaderstats") if leader then for _, stat in ipairs(leader:GetChildren()) do if origStats[stat.Name] then stat.Value = origStats[stat.Name] end end end table.clear(origStats) end
end)

Cl.MouseButton1Click:Connect(function()
	_G.HubActive = false; task.wait(0.1)
	for p, g in pairs(cW) do if p and p.Parent then p.CanCollide = g.C; p.Transparency = g.T end end
	local c = L.Character; local h = c and c:FindFirstChildOfClass("Humanoid") if h then h.WalkSpeed = 16 end SG:Destroy()
end)
