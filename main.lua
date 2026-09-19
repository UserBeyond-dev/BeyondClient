local P = game:GetService("Players")
local T = game:GetService("TweenService")
local U = game:GetService("UserInputService")
local R = game:GetService("RunService")
local L = P.LocalPlayer

if _G.ZeroTwoActive then _G.ZeroTwoActive = false task.wait(0.2) end
_G.ZeroTwoActive = true

local old = L.PlayerGui:FindFirstChild("ZeroTwoPremiumHub")
if old then old:Destroy() end

local SG = Instance.new("ScreenGui", L.PlayerGui)
SG.Name = "ZeroTwoPremiumHub"
SG.IgnoreGuiInset = true

local BL = Color3.fromRGB(0, 150, 255)
local BK = Color3.fromRGB(12, 12, 14)
local WH = Color3.fromRGB(255, 255, 255)

local St = {Speed = 16, Jump = false, Gh = false, God = false, Scale = 1, SizeMenu = false}
local cW, origStats = {}, {}

local AT = Instance.new("Frame", SG)
AT.Size = UDim2.new(0, 80, 0, 80)
AT.Position = UDim2.new(0.05, 0, 0.2, 0)
AT.BackgroundColor3 = BK; AT.BorderColor3 = BL; AT.BorderSizePixel = 2; AT.Active = true

local Img = Instance.new("ImageLabel", AT)
Img.Size = UDim2.new(0.9, 0, 0.9, 0)
Img.Position = UDim2.new(0.05, 0, 0.05, 0)
Img.BackgroundTransparency = 1
Img.Image = "rbxassetid://114254245648192"

local TB = Instance.new("TextButton", AT)
TB.Size = UDim2.new(1, 0, 1, 0)
TB.BackgroundTransparency = 1; TB.Text = ""; TB.ZIndex = 100
local MM = Instance.new("Frame", SG)
MM.Size = UDim2.new(0.48, 0, 0.85, 0)
MM.Position = UDim2.new(0.5, 0, 0.5, 0)
MM.AnchorPoint = Vector2.new(0.5, 0.5)
MM.BackgroundColor3 = BK; MM.BorderColor3 = BL; MM.BorderSizePixel = 4; MM.Visible = false; MM.Active = true; MM.ZIndex = 10

local ContentFrame = Instance.new("Frame", MM)
ContentFrame.Size = UDim2.new(1, 0, 0.82, 0)
ContentFrame.Position = UDim2.new(0, 0, 0.09, 0)
ContentFrame.BackgroundTransparency = 1
ContentFrame.ZIndex = 11

local Ly = Instance.new("UIListLayout", ContentFrame)
Ly.Padding = UDim.new(0, 5)
Ly.HorizontalAlignment, Ly.VerticalAlignment = Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Top

local TopBar = Instance.new("Frame", MM) TopBar.Size = UDim2.new(1, 0, 0, 35) TopBar.BackgroundColor3 = Color3.fromRGB(18, 18, 22); TopBar.ZIndex = 12
local BottomBar = Instance.new("Frame", MM) BottomBar.Size = UDim2.new(1, 0, 0, 25) BottomBar.Position = UDim2.new(0, 0, 1, -25) BottomBar.BackgroundColor3 = Color3.fromRGB(18, 18, 22); BottomBar.ZIndex = 12

local function makeDraggable(frame, trigger)
	local d, di, ds, sp
	trigger.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then d = true; ds = i.Position; sp = frame.Position end end)
	trigger.InputChanged:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then di = i end end)
	R.RenderStepped:Connect(function() if d and di then local dl = di.Position - ds; frame.Position = UDim2.new(sp.X.Scale, sp.X.Offset + dl.X, sp.Y.Scale, sp.Y.Offset + dl.Y) end end)
	U.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then d = false end end)
end
makeDraggable(AT, TB)
makeDraggable(MM, TopBar)
makeDraggable(MM, BottomBar)

local Title = Instance.new("TextLabel", TopBar) Title.Size = UDim2.new(0.6, 0, 1, 0) Title.Position = UDim2.new(0.03, 0, 0, 0) Title.Text = "BEYOND CLIENT v4.0" Title.TextColor3 = BL; Title.TextSize = 13; Title.TextXAlignment = Enum.TextXAlignment.Left; Title.Font = Enum.Font.Code; Title.ZIndex = 13
local Cl = Instance.new("TextButton", TopBar) Cl.Size = UDim2.new(0, 30, 0, 30) Cl.Position = UDim2.new(1, -35, 0, 2) Cl.BackgroundColor3 = Color3.fromRGB(180, 40, 40) Cl.Text = "X" Cl.TextColor3 = WH; Cl.ZIndex = 14; Instance.new("UICorner", Cl)
local Mn = Instance.new("TextButton", TopBar) Mn.Size = UDim2.new(0, 30, 0, 30) Mn.Position = UDim2.new(1, -70, 0, 2) Mn.BackgroundColor3 = Color3.fromRGB(60, 60, 60) Mn.Text = "—" Mn.TextColor3 = WH; Mn.ZIndex = 14; Instance.new("UICorner", Mn)
local function cB(t)
	local b = Instance.new("TextButton", ContentFrame) b.Size = UDim2.new(0.94, 0, 0, 35) b.BackgroundColor3 = Color3.fromRGB(22, 22, 26) b.Text = t b.TextColor3 = WH; b.TextSize = 13; b.Font = Enum.Font.SourceSansBold; b.ZIndex = 12; Instance.new("UICorner", b) return b
end

local bSp = cB("Бег [ВЫКЛ]")
local bJm = cB("Бесконечный Прыжок [ВЫКЛ]")
local bGh = cB("Стены-Призраки [ВЫКЛ]")
local bGd = cB("Бессмертие [ВЫКЛ]")
local bSz = cB("Размер тела >>")

local SFrame = Instance.new("Frame", ContentFrame) SFrame.Size = UDim2.new(0.94, 0, 0, 32) SFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 26) SFrame.ZIndex = 12; Instance.new("UICorner", SFrame)
local SText = Instance.new("TextLabel", SFrame) SText.Size = UDim2.new(0.35, 0, 1, 0) SText.BackgroundTransparency = 1; SText.Text = "Скорость: 16" SText.TextColor3 = WH; SText.TextSize = 11; SText.ZIndex = 13; SText.Font = Enum.Font.Code
local SBar = Instance.new("Frame", SFrame) SBar.Size = UDim2.new(0.58, 0, 0, 6) SBar.Position = UDim2.new(0.38, 0, 0.4, 0) SBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50); SBar.ZIndex = 13
local SButton = Instance.new("TextButton", SBar) SButton.Size = UDim2.new(0, 14, 0, 14) SButton.Position = UDim2.new(0, 0, -0.5, 0) SButton.BackgroundColor3 = BL; SButton.Text = ""; SButton.ZIndex = 14; Instance.new("UICorner", SButton)

local sDrag = false
SButton.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then sDrag = true end end)
U.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then sDrag = false end end)
R.RenderStepped:Connect(function()
	if sDrag then
		local percentage = math.clamp((U:GetMouseLocation().X - SBar.AbsolutePosition.X) / SBar.AbsoluteSize.X, 0, 1)
		SButton.Position = UDim2.new(percentage, -7, -0.5, 0)
		St.Speed = math.floor(16 + (percentage * 284))
		SText.Text = "Скорость: " .. tostring(St.Speed)
	end
end)

local SizeSubFrame = Instance.new("Frame", ContentFrame) SizeSubFrame.Size = UDim2.new(0.94, 0, 0, 75) SizeSubFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 32) SizeSubFrame.Visible = false; SizeSubFrame.ZIndex = 12; Instance.new("UICorner", SizeSubFrame)
local SzGrid = Instance.new("UIGridLayout", SizeSubFrame) SzGrid.CellSize = UDim2.new(0.23, 0, 0, 30) SzGrid.Padding = UDim2.new(0, 4, 0, 4) SzGrid.HorizontalAlignment, SzGrid.VerticalAlignment = Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Center

local function cSzB(t, val)
	local b = Instance.new("TextButton", SizeSubFrame) b.BackgroundColor3 = Color3.fromRGB(45, 45, 50) b.Text = t; b.TextColor3 = WH; b.TextSize = 10; b.ZIndex = 13; Instance.new("UICorner", b)
	b.MouseButton1Click:Connect(function() St.Scale = val end) return b
end
cSzB("Мелкий", 0.3) cSzB("Средний", 1) cSzB("Большой", 2.5) cSzB("Гигант", 5)
local SizeSliderFrame = Instance.new("Frame", ContentFrame) SizeSliderFrame.Size = UDim2.new(0.94, 0, 0, 32) SizeSliderFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 26) SizeSliderFrame.ZIndex = 12; Instance.new("UICorner", SizeSliderFrame)
local SizeSliderText = Instance.new("TextLabel", SizeSliderFrame) SizeSliderText.Size = UDim2.new(0.35, 0, 1, 0) SizeSliderText.BackgroundTransparency = 1; SizeSliderText.Text = "Рост: 1.0" SizeSliderText.TextColor3 = WH; SizeSliderText.TextSize = 11; SizeSliderText.ZIndex = 13; SizeSliderText.Font = Enum.Font.Code
local SizeSliderBar = Instance.new("Frame", SizeSliderFrame) SizeSliderBar.Size = UDim2.new(0.58, 0, 0, 6) SizeSliderBar.Position = UDim2.new(0.38, 0, 0.4, 0) SizeSliderBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50); SizeSliderBar.ZIndex = 13
local SizeSliderButton = Instance.new("TextButton", SizeSliderBar) SizeSliderButton.Size = UDim2.new(0, 14, 0, 14) SizeSliderButton.Position = UDim2.new(0.1, 0, -0.5, 0) SizeSliderButton.BackgroundColor3 = BL; SizeSliderButton.Text = ""; SizeSliderButton.ZIndex = 14; Instance.new("UICorner", SizeSliderButton)

local szDrag = false
SizeSliderButton.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then szDrag = true end end)
U.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then szDrag = false end end)
R.RenderStepped:Connect(function()
	if szDrag then
		local percentage = math.clamp((U:GetMouseLocation().X - SizeSliderBar.AbsolutePosition.X) / SizeSliderBar.AbsoluteSize.X, 0, 1)
		SizeSliderButton.Position = UDim2.new(percentage, -7, -0.5, 0)
		St.Scale = 0.2 + (percentage * 5.8)
		SizeSliderText.Text = "Рост: " .. string.format("%.1f", St.Scale)
	end
end)

TB.TouchTap:Connect(function() AT.Visible = false; MM.Visible = true end)
Mn.TouchTap:Connect(function() MM.Visible = false; AT.Visible = true end)

R.RenderStepped:Connect(function()
	local char = L.Character; local root = char and char:FindFirstChild("HumanoidRootPart")
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if St.Speed > 16 and root and hum and hum.MoveDirection.Magnitude > 0 and _G.ZeroTwoActive then
		local dir = hum.MoveDirection.Unit
		root.AssemblyLinearVelocity = Vector3.new(dir.X * St.Speed, root.AssemblyLinearVelocity.Y, dir.Z * St.Speed)
	end
	if hum and _G.ZeroTwoActive then
		local hs = hum:FindFirstChild("HeadScale") if hs then hs.Value = St.Scale end
		local bds = hum:FindFirstChild("BodyDepthScale") if bds then bds.Value = St.Scale end
		local bws = hum:FindFirstChild("BodyWidthScale") if bws then bws.Value = St.Scale end
		local bhs = hum:FindFirstChild("BodyHeightScale") if bhs then bhs.Value = St.Scale end
	end
end)

bSp.MouseButton1Click:Connect(function() if St.Speed == 16 then St.Speed = 45; bSp.Text = "Бег [ВКЛ]" bSp.BackgroundColor3 = Color3.fromRGB(0, 150, 100) else St.Speed = 16; bSp.Text = "Бег [ВЫКЛ]" bSp.BackgroundColor3 = Color3.fromRGB(22, 22, 26) end end)
bJm.MouseButton1Click:Connect(function() St.Jump = not St.Jump; bJm.Text = St.Jump and "Бесконечный Прыжок [ВКЛ]" or "Бесконечный Прыжок [ВЫКЛ]" bJm.BackgroundColor3 = St.Jump and Color3.fromRGB(0, 150, 100) or Color3.fromRGB(22, 22, 26) end)
U.JumpRequest:Connect(function() local root = L.Character and L.Character:FindFirstChild("HumanoidRootPart") if St.Jump and root and _G.ZeroTwoActive then root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, 55, root.AssemblyLinearVelocity.Z) end end)

bGh.MouseButton1Click:Connect(function() St.Gh = not St.Gh; bGh.Text = St.Gh and "Стены-Призраки [ВКЛ]" or "Стены-Призраки [ВЫКЛ]" bGh.BackgroundColor3 = St.Gh and Color3.fromRGB(0, 150, 100) or Color3.fromRGB(22, 22, 26)
	if St.Gh then for _, o in ipairs(workspace:GetDescendants()) do if o:IsA("BasePart") and o.Name:lower() ~= "floor" and o.Name:lower() ~= "baseplate" and not o:IsDescendantOf(L.Character) then cW[o] = {C = o.CanCollide, T = o.Transparency} o.CanCollide = false; o.Transparency = 0.60 end end
	else for p, g in pairs(cW) do if p and p.Parent then p.CanCollide = g.C; p.Transparency = g.T end end table.clear(cW) end
end)

bGd.MouseButton1Click:Connect(function() St.God = not St.God; bGd.Text = St.God and "Бессмертие [ВКЛ]" or "Бессмертие [ВЫКЛ]" bGd.BackgroundColor3 = St.God and Color3.fromRGB(0, 150, 100) or Color3.fromRGB(22, 22, 26)
	if St.God then
		local char = L.Character; local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum then
			local clone = hum:Clone() hum:Destroy() clone.Parent = char
			game:Workspace.CurrentCamera.CameraSubject = clone
		end
	end
end)

bSz.MouseButton1Click:Connect(function() St.SizeMenu = not St.SizeMenu; SizeSubFrame.Visible = St.SizeMenu; bSz.Text = St.SizeMenu and "Размер тела <<" or "Размер тела >>" end)
Cl.MouseButton1Click:Connect(function() _G.ZeroTwoActive = false; task.wait(0.1) for p, g in pairs(cW) do if p and p.Parent then p.CanCollide = g.C; p.Transparency = g.T end end SG:Destroy() end)
