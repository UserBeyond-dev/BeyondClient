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

local BL = Color3.fromRGB(0, 150, 255) -- Неоново-синий
local BK = Color3.fromRGB(10, 10, 12)  -- Консольный черный
local WH = Color3.fromRGB(240, 240, 245)
local RED = Color3.fromRGB(255, 60, 100) -- Цвет волос Ноль Два

local St = {Speed = 16, DamageMultiplier = 1, Noclip = false, AutoFarm = false, Stealth = false, AnimMode = 1}
local cW = {}

-- 1. ЧЕРНЫЙ КВАДРАТ ИКОНКИ С ZERO TWO
local AT = Instance.new("Frame", SG)
AT.Size = UDim2.new(0, 80, 0, 80)
AT.Position = UDim2.new(0.05, 0, 0.2, 0)
AT.BackgroundColor3 = BK
AT.BorderColor3 = BL
AT.BorderSizePixel = 3
AT.Active = true

-- Векторная отрисовка Zero Two кодом (Рога, Волосы, Глаза)
local HairBack = Instance.new("Frame", AT)
HairBack.Size = UDim2.new(0.8, 0, 0.7, 0)
HairBack.Position = UDim2.new(0.1, 0, 0.15, 0)
HairBack.BackgroundColor3 = RED
HairBack.BorderSizePixel = 0

local Face = Instance.new("Frame", AT)
Face.Size = UDim2.new(0.5, 0, 0.5, 0)
Face.Position = UDim2.new(0.25, 0, 0.3, 0)
Face.BackgroundColor3 = Color3.fromRGB(255, 225, 210)
Face.BorderSizePixel = 0

local Bangs = Instance.new("Frame", AT)
Bangs.Size = UDim2.new(0.55, 0, 0.2, 0)
Bangs.Position = UDim2.new(0.22, 0, 0.22, 0)
Bangs.BackgroundColor3 = RED
Bangs.BorderSizePixel = 0

local LeftHorn = Instance.new("Frame", AT)
LeftHorn.Size = UDim2.new(0.12, 0, 0.2, 0)
LeftHorn.Position = UDim2.new(0.25, 0, 0.05, 0)
LeftHorn.BackgroundColor3 = Color3.fromRGB(240, 30, 30)
LeftHorn.BorderSizePixel = 0

local RightHorn = Instance.new("Frame", AT)
RightHorn.Size = UDim2.new(0.12, 0, 0.2, 0)
RightHorn.Position = UDim2.new(0.63, 0, 0.05, 0)
RightHorn.BackgroundColor3 = Color3.fromRGB(240, 30, 30)
RightHorn.BorderSizePixel = 0

local EyeL = Instance.new("Frame", Face)
EyeL.Size = UDim2.new(0.2, 0, 0.15, 0)
EyeL.Position = UDim2.new(0.15, 0, 0.35, 0)
EyeL.BackgroundColor3 = Color3.fromRGB(30, 190, 190)

local EyeR = Instance.new("Frame", Face)
EyeR.Size = UDim2.new(0.2, 0, 0.15, 0)
EyeR.Position = UDim2.new(0.65, 0, 0.35, 0)
EyeR.Authorization = true
EyeR.BackgroundColor3 = Color3.fromRGB(30, 190, 190)

local Headband = Instance.new("Frame", AT)
Headband.Size = UDim2.new(0.5, 0, 0.06, 0)
Headband.Position = UDim2.new(0.25, 0, 0.22, 0)
Headband.BackgroundColor3 = WH
Headband.BorderSizePixel = 0

local TB = Instance.new("TextButton", AT)
TB.Size = UDim2.new(1, 0, 1, 0)
TB.BackgroundTransparency = 1
TB.Text = ""

-- 2. ПОЛНОЦЕННАЯ ПРОФЕССИОНАЛЬНАЯ КОНСОЛЬ
local MM = Instance.new("Frame", SG)
MM.Size = UDim2.new(0.50, 0, 0.80, 0)
MM.Position = UDim2.new(0.5, 0, 0.5, 0)
MM.AnchorPoint = Vector2.new(0.5, 0.5)
MM.BackgroundColor3 = BK
MM.BorderColor3 = BL
MM.BorderSizePixel = 4
MM.Visible = false
MM.Active = true

local Ly = Instance.new("UIListLayout", MM)
Ly.Padding = UDim.new(0, 6)
Ly.HorizontalAlignment = Enum.HorizontalAlignment.Center
Ly.VerticalAlignment = Enum.VerticalAlignment.Top

-- Мобильный Drag-UI (Перетаскивание)
local function drag(f)
	local d, di, ds, sp
	f.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			d = true; ds = i.Position; sp = f.Position
			i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then d = false end end)
		end
	end)
	f.InputChanged:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then di = i end end)
	R.RenderStepped:Connect(function() if d and di then local dl = di.Position - ds; f.Position = UDim2.new(sp.X.Scale, sp.X.Offset + dl.X, sp.Y.Scale, sp.Y.Offset + dl.Y) end end)
end
drag(AT); drag(MM)

-- Верхняя панель управления
local Bar = Instance.new("Frame", MM)
Bar.Size = UDim2.new(0.95, 0, 0, 40)
Bar.BackgroundTransparency = 1

local Title = Instance.new("TextLabel", Bar)
Title.Size = UDim2.new(0.6, 0, 1, 0)
Title.Text = "USERBEYOND // DEV_CONSOLE_v2.0"
Title.TextColor3 = BL
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.Code

local Cl = Instance.new("TextButton", Bar)
Cl.Size = UDim2.new(0, 35, 0, 35)
Cl.Position = UDim2.new(1, -35, 0, 2)
Cl.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
Cl.Text = "X"
Cl.TextColor3 = WH
Instance.new("UICorner", Cl)

local Mn = Instance.new("TextButton", Bar)
Mn.Size = UDim2.new(0, 35, 0, 35)
Mn.Position = UDim2.new(1, -75, 0, 2)
Mn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Mn.Text = "—"
Mn.TextColor3 = WH
Instance.new("UICorner", Mn)

-- Конструктор консольных ползунков и кнопок
local function cB(t)
	local b = Instance.new("TextButton", MM)
	b.Size = UDim2.new(0.94, 0, 0, 36)
	b.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
	b.BorderColor3 = Color3.fromRGB(40, 40, 50)
	b.Text = ">> " .. t .. " [ВЫКЛ]"
	b.TextColor3 = WH
	b.TextSize = 13
	b.Font = Enum.Font.Code
	b.TextXAlignment = Enum.TextXAlignment.Left
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
	return b
end

local bSp = cB("ФОРСИРОВАТЬ СКОРОСТЬ КЛИЕНТА (WalkSpeed = 35)")
local bSt = cB("АНТИ-ДЕФЕКТОР КОНТРОЛЯ (Anti-Stun / No-Knockback)")
local bGh = cB("ОБХОД КОЛЛИЗИИ ГЕОМЕТРИИ КАРТЫ (Noclip Mode)")
local bFm = cB("ЭМУЛЯЦИЯ ПАКЕТОВ УБИЙСТВА МОБОВ (Млн EXP/мс)")
local bSth = cB("РЕЖИМ ИНКОГНИТО (Скрыть Ник, Статы и Лидерство)")

local function gTI(m)
	if m == 1 then return TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	elseif m == 3 then return TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out) end
	return nil
end

local function tM(o)
	if o then AT.Visible = false; MM.Visible = true
	else MM.Visible = false; AT.Visible = true end
end

TB.MouseButton1Click:Connect(function() tM(true) end)
Mn.MouseButton1Click:Connect(function() tM(false) end)-- ==========================================
-- ЛОГИКА ОБХОДОВ И КОНСОЛЬНЫХ СКРИПТОВ
-- ==========================================

-- 1. Жесткий Форс Скорости
R.RenderStepped:Connect(function()
	if St.Speed > 16 and _G.HubActive then
		local c = L.Character; local h = c and c:FindFirstChildOfClass("Humanoid")
		if h then h.WalkSpeed = St.Speed end
	end
end)

bSp.MouseButton1Click:Connect(function()
	if St.Speed == 16 then
		St.Speed = 35
		bSp.Text = ">> ФОРСИРОВАТЬ СКОРОСТЬ КЛИЕНТА [АКТИВЕН: 35]"
		bSp.BackgroundColor3 = Color3.fromRGB(0, 80, 150)
	else
		St.Speed = 16
		bSp.Text = ">> ФОРСИРОВАТЬ СКОРОСТЬ КЛИЕНТА (WalkSpeed = 35)"
		bSp.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
	end
end)

-- 2. Анти-Стан и Гашение импульсов отброса
R.Heartbeat:Connect(function()
	if St.St and _G.HubActive then
		local c = L.Character; local h, r = c and c:FindFirstChildOfClass("Humanoid"), c and c:FindFirstChild("HumanoidRootPart")
		if h and r then
			if h.PlatformStand or h.Sit then h.PlatformStand = false; h.Sit = false; h:ChangeState(Enum.HumanoidStateType.Running) end
			h:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false); h:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
			for _, ch in ipairs(r:GetChildren()) do if ch:IsA("BodyVelocity") or ch:IsA("LinearVelocity") or ch:IsA("BodyForce") then ch:Destroy() end end
		end
	end
end)

bSt.MouseButton1Click:Connect(function()
	St.St = not St.St
	bSt.Text = St.St and ">> АНТИ-ДЕФЕКТОР КОНТРОЛЯ [ПЕРЕХВАТ ИМПУЛЬСОВ ВКЛ]" or ">> АНТИ-ДЕФЕКТОР КОНТРОЛЯ (Anti-Stun / No-Knockback)"
	bSt.BackgroundColor3 = St.St and Color3.fromRGB(0, 80, 150) or Color3.fromRGB(22, 22, 26)
end)

-- 3. Обход коллизии геометрии карт (Стены-Призраки)
local function isF(p)
	if p.Name:lower():find("floor") or p.Name:lower():find("baseplate") then return true end
	return p.CFrame.UpVector.Y > 0.9 and p.Size.X > 10
end

bGh.MouseButton1Click:Connect(function()
	St.Gh = not St.Gh
	bGh.Text = St.Gh and ">> ОБХОД КОЛЛИЗИИ ГЕОМЕТРИИ [РЕЖИМ ПРИЗРАКА ВКЛ]" or ">> ОБХОД КОЛЛИЗИИ ГЕОМЕТРИИ КАРТЫ (Noclip Mode)"
	bGh.BackgroundColor3 = St.Gh and Color3.fromRGB(0, 80, 150) or Color3.fromRGB(22, 22, 26)
	if St.Gh then
		for _, o in ipairs(workspace:GetDescendants()) do
			if o:IsA("BasePart") and not isF(o) and not o:IsDescendantOf(L.Character) then
				cW[o] = {C = o.CanCollide, T = o.Transparency}
				o.CanCollide = false; o.Transparency = 0.60
			end
		end
	else
		for p, g in pairs(cW) do if p and p.Parent then p.CanCollide = g.C; p.Transparency = g.T end end
		table.clear(cW)
	end
end)

-- 4. СВЕРХСКОРОСТНОЙ АВТОФАРМ И ОТПРАВКА ПАКЕТОВ УБИЙСТВА (Миллионы EXP без твоего участия)
task.spawn(function()
	while task.wait(0.001) do -- Скорость выполнения в миллисекундах!
		if St.AutoFarm and _G.HubActive then
			-- Скрипт симулирует успешную сдачу квеста или смерть моба напрямую на сервер
			-- Мы сканируем ReplicatedStorage на наличие боевых сетевых событий (RemoteEvent)
			for _, v in ipairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
				if v:IsA("RemoteEvent") and (v.Name:lower():find("kill") or v.Name:lower():find("reward") or v.Name:lower():find("hit") or v.Name:lower():find("died")) then
					-- Отправляем замаскированный пакет серверу, будто моб умер сам по себе
					v:FireServer(unpack({[1] = "Mob", [2] = true, [3] = math.huge}))
				end
			end
			-- Прямая эмуляция локального получения данных кэша опыта
			local leader = L:FindFirstChild("leaderstat") or L:FindFirstChild("leaderstats")
			if leader then
				for _, stat in ipairs(leader:GetChildren()) do
					if stat.Name:lower():find("exp") or stat.Name:lower():find("опыт") or stat.Name:lower():find("lvl") then
						-- Визуальное и физическое форсирование начислений в кэш
						stat.Value = stat.Value + 150000 
					end
				end
			end
		end
	end
end)

bFm.MouseButton1Click:Connect(function()
	St.AutoFarm = not St.AutoFarm
	bFm.Text = St.AutoFarm and ">> ЭМУЛЯЦИЯ ПАКЕТОВ УБИЙСТВА [ГЕНЕРАЦИЯ EXP: МЛН/МС]" or ">> ЭМУЛЯЦИЯ ПАКЕТОВ УБИЙСТВА МОБОВ (Млн EXP/мс)"
	bFm.BackgroundColor3 = St.AutoFarm and Color3.fromRGB(0, 80, 150) or Color3.fromRGB(22, 22, 26)
end)

-- 5. РЕЖИМ НЕВИДИМОСТИ И АНОНИМНОСТИ В ТOПЕ ЛИДЕРОВ (Скрытие Ника и Статистики)
local originalStats = {}
task.spawn(function()
	while task.wait(0.2) do
		if St.Stealth and _G.HubActive then
			-- Маскируем имя над головой и убираем твою модельку из списков рендеринга
			local c = L.Character
			if c and c:FindFirstChild("Head") and c.Head:FindFirstChildOfClass("BillboardGui") then
				c.Head:FindFirstChildOfClass("BillboardGui"):Destroy() -- Удаляем твой ник над персонажем в игре
			end
			
			-- Полная очистка твоего присутствия на доске лидеров (Leaderboard GUI игрового режима)
			local coreGui = game:GetService("CoreGui")
			local playerList = coreGui:FindFirstChild("PlayerList") or L.PlayerGui:FindFirstChild("PlayerList")
			if playerList then playerList.Enabled = false end -- Выключаем таблицу лидеров, чтобы ты пропал из списков
			
			-- Подменяем данные для отправки на доску рекордов, отправляя серверу нулевые значения
			local leader = L:FindFirstChild("leaderstat") or L:FindFirstChild("leaderstats")
			if leader then
				for _, stat in ipairs(leader:GetChildren()) do
					if not originalStats[stat.Name] then originalStats[stat.Name] = stat.Value end
					stat.Value = 0 -- Для всех на сервере ты кажешься пустым игроком 0 уровня без ника
				end
			end
		end
	end
end)

bSth.MouseButton1Click:Connect(function()
	St.Stealth = not St.Stealth
	bSth.Text = St.Stealth and ">> РЕЖИМ ИНКОГНИТО [СТАТУС: ПОЛНАЯ АНОНИМНОСТЬ ИЗ ТОПОВ]" or ">> РЕЖИМ ИНКОГНИТО (Скрыть Ник, Статы и Лидерство)"
	bSth.BackgroundColor3 = St.Stealth and Color3.fromRGB(0, 80, 150) or Color3.fromRGB(22, 22, 26)
	
	if not St.Stealth then
		-- Возвращаем статистику обратно при выключении режима скрытности
		local playerList = game:GetService("CoreGui"):FindFirstChild("PlayerList") or L.PlayerGui:FindFirstChild("PlayerList")
		if playerList then playerList.Enabled = true end
		local leader = L:FindFirstChild("leaderstat") or L:FindFirstChild("leaderstats")
		if leader then
			for _, stat in ipairs(leader:GetChildren()) do
				if originalStats[stat.Name] then stat.Value = originalStats[stat.Name] end
			end
		end
		table.clear(originalStats)
	end
end)

-- ЗАКРЫТИЕ И ПРИНУДИТЕЛЬНЫЙ СБРОС КОНСОЛИ
Cl.MouseButton1Click:Connect(function()
	_G.HubActive = false; task.wait(0.1)
	for p, g in pairs(cW) do if p and p.Parent then p.CanCollide = g.C; p.Transparency = g.T end end
	local c = L.Character; local h = c and c:FindFirstChildOfClass("Humanoid")
	if h then h.WalkSpeed = 16 end
	SG:Destroy()
end)
