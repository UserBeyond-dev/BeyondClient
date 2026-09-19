--[[
    BeyondClient v5.0 - Ultimate Premium Edition
    Developer: UserBeyond-dev
    Repository: GitHub (Japan) / BeyondClient
    File: main.lua (Part 1/4 - Core Architecture & UI Framework)
    Icon Asset ID: rbxassetid://114254245648192 (Chibi Zero Two 4K)
--]]

-- Безопасное кэширование системных сервисов (Защита от хуков со стороны игры)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
assert(LocalPlayer, "[BeyondClient Error]: Окружение игры не инициализировано.")
local Camera = workspace.CurrentCamera or workspace:WaitForChild("Camera")

-- Очистка старых сессий скрипта во избежание утечек памяти (Memory Leaks)
if _G.BeyondClient_Shutdown then
    pcall(_G.BeyondClient_Shutdown)
end

-- Инициализация глобального хранилища конфигурации
_G.BeyondConfig = {
    Version = "5.0-Alpha",
    Developer = "UserBeyond-dev",
    SpeedValue = 16,
    InfiniteJump = false,
    Noclip = false,
    GodMode = false,
    BodySize = "Средний",
    ThemeColor = Color3.fromRGB(255, 43, 90), -- Розовый Zero Two
    BgColor = Color3.fromRGB(15, 15, 20),
    AccentGlow = Color3.fromRGB(255, 100, 130)
}

-- ====================================================================
-- [ МОДУЛЬ ОБХОДА И ЗАЩИТЫ (ANTI-CHEAT BYPASS CORE) ]
-- ====================================================================
local BypassModule = {}
do
    local mt = getrawmetatable(game)
    local old_namecall = mt.__namecall
    local old_index = mt.__index
    
    setreadonly(mt, false)
    
    -- Защита от детекта скрипта через сканирование CoreGui / Namecall
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        if not checkcaller() then
            -- Блокируем отправку подозрительных репортов на сервер игры
            if method == "FireServer" and tostring(self) == "AntiCheatReport" then
                return nil
            end
            if method == "Kick" then
                print("[BeyondClient Bypass]: Заблокирована попытка кика со стороны сервера.")
                return nil
            end
        end
        return old_namecall(self, ...)
    end)
    
    setreadonly(mt, true)
    print("[BeyondClient]: Модуль Anti-Cheat Bypass успешно интегрирован в Metatable.")
end

-- ====================================================================
-- [ БАЗОВЫЙ ИНТЕРФЕЙС И ГЛУБОКАЯ СТИЛИЗАЦИЯ (TOP-TIER WEB DESIGN) ]
-- ====================================================================
local BeyondScreenGui = Instance.new("ScreenGui")
BeyondScreenGui.Name = HttpService:GenerateGUID(false) -- Рандомное имя от детекта
BeyondScreenGui.ResetOnSpawn = false
BeyondScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local success, err = pcall(function()
    BeyondScreenGui.Parent = CoreGui
end)
if not success then
    BeyondScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- Функция безопасного закрытия интерфейса
_G.BeyondClient_Shutdown = function()
    BeyondScreenGui:Destroy()
    _G.BeyondConfig = nil
end

-- Главный фрейм меню
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainPanel"
MainFrame.Size = UDim2.new(0, 440, 0, 340)
MainFrame.Position = UDim2.new(0.5, -220, 0.4, -170)
MainFrame.BackgroundColor3 = _G.BeyondConfig.BgColor
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = BeyondScreenGui

-- Скругление и размытие углов
local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 14)
Corner.Parent = MainFrame

-- Кастомная неоновая обводка (Stroke Effects)
local Stroke = Instance.new("UIStroke")
Stroke.Thickness = 2
Stroke.Color = _G.BeyondConfig.ThemeColor
Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
Stroke.Parent = MainFrame

-- Сложный градиент заднего плана
local BgGradient = Instance.new("UIGradient")
BgGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(24, 22, 30)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(14, 14, 18)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 14))
}
BgGradient.Rotation = 135
BgGradient.Parent = MainFrame

-- --- ВЕРХНЯЯ ШАПКА МЕНЮ (ЗОНА ХЕНДЛИНГА DRAG-UI #1) ---
local Header = Instance.new("Frame")
Header.Name = "HeaderZone"
Header.Size = UDim2.new(1, 0, 0, 45)
Header.BackgroundColor3 = Color3.fromRGB(28, 26, 36)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 14)
HeaderCorner.Parent = Header

-- Срез нижних углов шапки (визуальный паттерн)
local HeaderLine = Instance.new("Frame")
HeaderLine.Size = UDim2.new(1, 0, 0, 2)
HeaderLine.Position = UDim2.new(0, 0, 1, -2)
HeaderLine.BackgroundColor3 = _G.BeyondConfig.ThemeColor
HeaderLine.BorderSizePixel = 0
HeaderLine.Parent = Header

-- Иконка аниме чиби Ноль Два (4K Asset Инициализация)
local AvatarIcon = Instance.new("ImageLabel")
AvatarIcon.Name = "ZeroTwo_4K"
AvatarIcon.Size = UDim2.new(0, 32, 0, 32)
AvatarIcon.Position = UDim2.new(0, 12, 0, 6)
AvatarIcon.BackgroundTransparency = 1
AvatarIcon.Image = "rbxassetid://114254245648192"
AvatarIcon.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -120, 1, 0)
Title.Position = UDim2.new(0, 52, 0, 0)
Title.Text = "BEYOND <font color='#FF2B5A'>CLIENT</font> <font color='#A0A0A5'>v5.0</font>"
Title.RichText = true
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 15
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
Title.Parent = Header

local DevTag = Instance.new("TextLabel")
DevTag.Size = UDim2.new(0, 120, 1, 0)
DevTag.Position = UDim2.new(1, -132, 0, 0)
DevTag.Text = "by UserBeyond-dev"
DevTag.TextColor3 = Color3.fromRGB(140, 140, 160)
DevTag.Font = Enum.Font.GothamItalic
DevTag.TextSize = 11
DevTag.TextXAlignment = Enum.TextXAlignment.Right
DevTag.BackgroundTransparency = 1
DevTag.Parent = Header

-- --- НИЖНЯЯ ПАНЕЛЬ МЕНЮ (ЗОНА ХЕНДЛИНГА DRAG-UI #2) ---
local Footer = Instance.new("Frame")
Footer.Name = "FooterZone"
Footer.Size = UDim2.new(1, 0, 0, 25)
Footer.Position = UDim2.new(0, 0, 1, -25)
Footer.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
Footer.BorderSizePixel = 0
Footer.Parent = MainFrame

local FooterCorner = Instance.new("UICorner")
FooterCorner.CornerRadius = UDim.new(0, 10)
FooterCorner.Parent = Footer

local FooterText = Instance.new("TextLabel")
FooterText.Size = UDim2.new(1, -24, 1, 0)
FooterText.Position = UDim2.new(0, 12, 0, 0)
FooterText.Text = "Repository: Japan/BeyondClient // Mainframe Stack Connected Successfully"
FooterText.TextColor3 = Color3.fromRGB(0, 255, 140)
FooterText.Font = Enum.Font.Code
FooterText.TextSize = 10
FooterText.TextXAlignment = Enum.TextXAlignment.Left
FooterText.BackgroundTransparency = 1
FooterText.Parent = Footer

-- --- ГЛАВНЫЙ СКОЛЛИНГ-КОНТЕЙНЕР ДЛЯ МОДУЛЕЙ ---
local Container = Instance.new("ScrollingFrame")
Container.Name = "ModuleContainer"
Container.Size = UDim2.new(1, -24, 1, -95)
Container.Position = UDim2.new(0, 12, 0, 58)
Container.BackgroundTransparency = 1
Container.BorderSizePixel = 0
Container.CanvasSize = UDim2.new(0, 0, 0, 550) -- Запас под весь пак тяжелого функционала
Container.ScrollBarThickness = 4
Container.ScrollBarImageColor3 = _G.BeyondConfig.ThemeColor
Container.Parent = MainFrame

local ListLayout = Instance.new("UIListLayout")
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Padding = UDim.new(0, 12)
ListLayout.Parent = Container

-- ====================================================================
-- [ ПРОФЕССИОНАЛЬНЫЙ СТАБИЛЬНЫЙ DRAG-UI (БЕЗ ПРЫЖКОВ ОКНА) ]
-- ====================================================================
local dragging = false
local dragInput, dragStart, startPos

local function updateDrag(input)
    local delta = input.Position - dragStart
    -- Полная свобода перемещения, включая увод за края мобильного дисплея
    MainFrame.Position = UDim2.new(
        startPos.X.Scale, startPos.X.Offset + delta.x, 
        startPos.Y.Scale, startPos.Y.Offset + delta.y
    )
end

local function setupDragZone(zone)
    zone.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    zone.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseBehavior or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
end

-- Фиксация перетаскивания СТРОГО за шапку и футер (слайдеры теперь работают автономно!)
setupDragZone(Header)
setupDragZone(Footer)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        updateDrag(input)
    end
end)

print("[BeyondClient Framework]: Часть 1 успешно развернута.")
--[[
    BeyondClient v5.0 - Ultimate Premium Edition
    Developer: UserBeyond-dev
    File: main.lua (Part 2/4 - UI Factory & Velocity Physics Module)
--]]

-- ====================================================================
-- [ ПРОФЕССИОНАЛЬНАЯ UI-ФАБРИКА С АНИМАЦИЯМИ (ВЕБ-СТИЛЬ) ]
-- ====================================================================

-- Конструктор кастомных премиум-слайдеров
local function CreateSlider(parent, text, min, max, default, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, 0, 0, 55)
    SliderFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    SliderFrame.BorderSizePixel = 0
    SliderFrame.Parent = parent
    
    local SliderCorner = Instance.new("UICorner")
    SliderCorner.CornerRadius = UDim.new(0, 8)
    SliderCorner.Parent = SliderFrame
    
    local SliderStroke = Instance.new("UIStroke")
    SliderStroke.Thickness = 1
    SliderStroke.Color = Color3.fromRGB(35, 35, 45)
    SliderStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    SliderStroke.Parent = SliderFrame
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.8, 0, 0, 25)
    Label.Position = UDim2.new(0, 12, 0, 4)
    Label.Text = text .. ": <font color='#FF2B5A'>" .. tostring(default) .. "</font>"
    Label.RichText = true
    Label.TextColor3 = Color3.fromRGB(220, 220, 230)
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1
    Label.Parent = SliderFrame
    
    local ContainerTrack = Instance.new("Frame")
    ContainerTrack.Size = UDim2.new(1, -24, 0, 6)
    ContainerTrack.Position = UDim2.new(0, 12, 0, 36)
    ContainerTrack.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    ContainerTrack.BorderSizePixel = 0
    ContainerTrack.Parent = SliderFrame
    
    local TrackCorner = Instance.new("UICorner")
    TrackCorner.CornerRadius = UDim.new(0, 3)
    TrackCorner.Parent = ContainerTrack
    
    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = _G.BeyondConfig.ThemeColor
    Fill.BorderSizePixel = 0
    Fill.Parent = ContainerTrack
    
    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(0, 3)
    FillCorner.Parent = Fill
    
    local SliderBtn = Instance.new("TextButton")
    SliderBtn.Size = UDim2.new(1, 0, 1, 0)
    SliderBtn.BackgroundTransparency = 1
    SliderBtn.Text = ""
    SliderBtn.Parent = ContainerTrack
    
    local isSliding = false
    
    local function updateSlider(input)
        local xOffset = math.clamp(input.Position.X - ContainerTrack.AbsolutePosition.X, 0, ContainerTrack.AbsoluteSize.X)
        local percentage = xOffset / ContainerTrack.AbsoluteSize.X
        local rawValue = min + (percentage * (max - min))
        local finalValue = math.round(rawValue)
        
        TweenService:Create(Fill, TweenInfo.new(0.15, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {Size = UDim2.new(percentage, 0, 1, 0)}):Play()
        Label.Text = text .. ": <font color='#FF2B5A'>" .. tostring(finalValue) .. "</font>"
        callback(finalValue)
    end
    
    SliderBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isSliding = true
            TweenService:Create(SliderStroke, TweenInfo.new(0.2), {Color = _G.BeyondConfig.AccentGlow}):Play()
            updateSlider(input)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if isSliding and (input.UserInputType == Enum.UserInputType.MouseBehavior or input.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isSliding = false
            TweenService:Create(SliderStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(35, 35, 45)}):Play()
        end
    end)
end

-- Конструктор кастомных интерактивных переключателей (Toggles)
local function CreateToggle(parent, text, default, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 44)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.Parent = parent
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 8)
    ToggleCorner.Parent = ToggleFrame
    
    local ToggleStroke = Instance.new("UIStroke")
    ToggleStroke.Thickness = 1
    ToggleStroke.Color = Color3.fromRGB(35, 35, 45)
    ToggleStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    ToggleStroke.Parent = ToggleFrame
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(210, 210, 220)
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1
    Label.Parent = ToggleFrame
    
    local CheckBox = Instance.new("TextButton")
    CheckBox.Size = UDim2.new(0, 40, 0, 22)
    CheckBox.Position = UDim2.new(1, -52, 0.5, -11)
    CheckBox.BackgroundColor3 = default and _G.BeyondConfig.ThemeColor or Color3.fromRGB(45, 45, 60)
    CheckBox.Text = ""
    CheckBox.Parent = ToggleFrame
    
    local CBCorner = Instance.new("UICorner")
    CBCorner.CornerRadius = UDim.new(1, 0)
    CBCorner.Parent = CheckBox
    
    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.new(0, 16, 0, 16)
    Indicator.Position = default and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
    Indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Indicator.Parent = CheckBox
    
    local IndCorner = Instance.new("UICorner")
    IndCorner.CornerRadius = UDim.new(1, 0)
    IndCorner.Parent = Indicator
    
    local state = default
    CheckBox.MouseButton1Click:Connect(function()
        state = not state
        local targetColor = state and _G.BeyondConfig.ThemeColor or Color3.fromRGB(45, 45, 60)
        local targetPos = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        
        TweenService:Create(CheckBox, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {BackgroundColor3 = targetColor}):Play()
        TweenService:Create(Indicator, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {Position = targetPos}):Play()
        TweenService:Create(ToggleStroke, TweenInfo.new(0.2), {Color = state and _G.BeyondConfig.AccentGlow or Color3.fromRGB(35, 35, 45)}):Play()
        
        callback(state)
    end)
end

-- ====================================================================
-- [ ИНИЦИАЛИЗАЦИЯ ФИЗИЧЕСКОГО МОДУЛЯ СКОРОСТИ ]
-- ====================================================================

-- Слайдер физического импульса скорости AssemblyLinearVelocity (16 - 300)
CreateSlider(Container, "Физический Обход Скорости", 16, 300, _G.BeyondConfig.SpeedValue, function(val)
    _G.BeyondConfig.SpeedValue = val
end)

-- Высокоточный расчет векторов движения через Heartbeat (вызывается перед симуляцией физики)
RunService.Heartbeat:Connect(function()
    local character = LocalPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    
    if rootPart and humanoid and humanoid.MoveDirection.Magnitude > 0 then
        -- Рассчитываем идеальное направление импульса, сохраняя вертикальную силу гравитации
        local calculatedVelocity = humanoid.MoveDirection * _G.BeyondConfig.SpeedValue
        rootPart.AssemblyLinearVelocity = Vector3.new(calculatedVelocity.X, rootPart.AssemblyLinearVelocity.Y, calculatedVelocity.Z)
    end
end)

print("[BeyondClient UI & Physics]: Часть 2 успешно добавлена.")
--[[
    BeyondClient v5.0 - Ultimate Premium Edition
    Developer: UserBeyond-dev
    File: main.lua (Part 3/4 - Jump Vector Impulses & Selective Raycast Noclip)
--]]

-- ====================================================================
-- [ МОДУЛЬ ИМПУЛЬСНОГО БЕСКОНЕЧНОГО ПРЫЖКА ]
-- ====================================================================

CreateToggle(Container, "Бесконечный Прыжок (Импульсный)", _G.BeyondConfig.InfiniteJump, function(state)
    _G.BeyondConfig.InfiniteJump = state
end)

-- Перехват запроса на прыжок напрямую из UserInputService
UserInputService.JumpRequest:Connect(function()
    if _G.BeyondConfig.InfiniteJump then
        local character = LocalPlayer.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        
        if rootPart then
            -- Подаем чистый силовой вектор строго вверх, сохраняя текущую инерцию осей X и Z
            rootPart.AssemblyLinearVelocity = Vector3.new(
                rootPart.AssemblyLinearVelocity.X, 
                55, -- Оптимальная сила импульса прыжка
                rootPart.AssemblyLinearVelocity.Z
            )
        end
    end
end)

-- ====================================================================
-- [ СЕЛЕКТИВНЫЙ NOCLIP С ЛУЧЕВЫМ СКАНИРОВАНИЕМ ПОЛА ]
-- ====================================================================

CreateToggle(Container, "Проход Сквозь Стены (Noclip)", _G.BeyondConfig.Noclip, function(state)
    _G.BeyondConfig.Noclip = state
end)

-- Инициализация параметров лучевого сканирования (Raycast) для оптимизации в цикле
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude

-- Использование Stepped для отключения коллизий внутри физического кадра симуляции
RunService.Stepped:Connect(function()
    if _G.BeyondConfig.Noclip then
        local character = LocalPlayer.Character
        if character then
            raycastParams.FilterDescendantsInstances = {character}
            
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    -- Исключаем критические корневые узлы из базового отключения во избежание десинхронизации
                    if part.Name ~= "UpperTorso" and part.Name ~= "LowerTorso" and part.Name ~= "HumanoidRootPart" then
                        part.CanCollide = false
                    else
                        -- Защита от бесконечного падения: сканируем пространство строго под персонажем
                        local rayOrigin = part.Position
                        local rayDirection = Vector3.new(0, -6.5, 0) -- Дистанция детекции поверхности земли
                        
                        local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
                        
                        if raycastResult then
                            -- Если луч обнаружил твердую опору или ландшафт, удерживаем коллизию для стабильности
                            part.CanCollide = true
                        else
                            -- Во всех остальных случаях (стены, преграды, двери) временно отключаем жесткость
                            part.CanCollide = false
                        end
                    end
                end
            end
        end
    end
end)

print("[BeyondClient Movement]: Часть 3 успешно добавлена.")
--[[
    BeyondClient v5.0 - Ultimate Premium Edition
    Developer: UserBeyond-dev
    File: main.lua (Part 4/4 - Local God Mode, Rig Scaler & Finalization)
--]]

-- ====================================================================
-- [ МОДУЛЬ ADVANCED GOD MODE (ЛОКАЛЬНОЕ БЕССМЕРТИЕ) ]
-- ====================================================================

CreateToggle(Container, "Настоящее Бессмертие (God Mode)", _G.BeyondConfig.GodMode, function(state)
    _G.BeyondConfig.GodMode = state
    
    local char = LocalPlayer.Character
    local model = char and char:FindFirstChildOfClass("Humanoid")
    
    if state and model then
        task.spawn(function()
            -- Разрываем связь с сервером по урону, подменяя сетевой Humanoid локальным клоном
            while _G.BeyondConfig.GodMode and char and model.Parent do
                local clone = model:Clone()
                clone.Parent = char
                
                -- Безопасно перенаправляем камеру на новую рабочую сущность
                Camera.CameraSubject = clone
                LocalPlayer.Character = char
                
                -- Уничтожаем старый Humanoid, очищая стейты входящего серверного урона
                model:Destroy()
                model = clone
                
                task.wait(0.4) -- Оптимальный интервал десинхронизации
            end
        end)
    elseif not state and model then
        -- Мягкий ресет персонажа для возврата в исходное игровое состояние
        if model.Health > 0 then
            model.Health = 0
        end
    end
end)

-- Автоматический перезапуск защиты при респавне (CharacterAdded)
LocalPlayer.CharacterAdded:Connect(function(newChar)
    task.wait(0.4)
    if _G.BeyondConfig.GodMode then
        local currentHum = newChar:WaitForChild("Humanoid", 5)
        if currentHum then
            local clone = currentHum:Clone()
            clone.Parent = newChar
            Camera.CameraSubject = clone
            currentHum:Destroy()
        end
    end
end)

-- ====================================================================
-- [ ПАНЕЛЬ УПРАВЛЕНИЯ РОСТОМ И КОСТЯМИ ПЕРСОНАЖА ]
-- ====================================================================

local ScaleFrame = Instance.new("Frame")
ScaleFrame.Name = "ScaleLayout"
ScaleFrame.Size = UDim2.new(1, 0, 0, 85)
ScaleFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
ScaleFrame.BorderSizePixel = 0
ScaleFrame.Parent = Container

local ScaleCorner = Instance.new("UICorner")
ScaleCorner.CornerRadius = UDim.new(0, 8)
ScaleCorner.Parent = ScaleFrame

local ScaleStroke = Instance.new("UIStroke")
ScaleStroke.Thickness = 1
ScaleStroke.Color = Color3.fromRGB(35, 35, 45)
ScaleStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
ScaleStroke.Parent = ScaleFrame

local ScaleLabel = Instance.new("TextLabel")
ScaleLabel.Size = UDim2.new(1, -20, 0, 25)
ScaleLabel.Position = UDim2.new(0, 12, 0, 4)
ScaleLabel.Text = "Пресеты Роста: <font color='#FF2B5A'>" .. _G.BeyondConfig.BodySize .. "</font>"
ScaleLabel.RichText = true
ScaleLabel.TextColor3 = Color3.fromRGB(220, 220, 230)
ScaleLabel.Font = Enum.Font.GothamSemibold
ScaleLabel.TextSize = 13
ScaleLabel.TextXAlignment = Enum.TextXAlignment.Left
ScaleLabel.BackgroundTransparency = 1
ScaleLabel.Parent = ScaleFrame

-- Глубокое масштабирование костей и пропорций аватара (R15 Rig)
local function RebuildBodyScale(multiplier)
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        local scaleObjects = {"BodyHeightScale", "BodyWidthScale", "BodyDepthScale", "HeadScale"}
        for _, objectName in ipairs(scaleObjects) do
            local scaleValue = hum:FindFirstChild(objectName)
            if scaleValue and scaleValue:IsA("NumberValue") then
                -- Умножаем базовый оригинальный размер на заданный коэффициент
                scaleValue.Value = scaleValue.OriginalSize.Value * multiplier
            end
        end
    end
end

-- Фабрика кнопок для пресетов сетки размеров
local function CreatePresetElement(name, xOffset, multiplier)
    local PresetBtn = Instance.new("TextButton")
    PresetBtn.Size = UDim2.new(0.21, 0, 0, 36)
    PresetBtn.Position = UDim2.new(0, xOffset, 0, 36)
    PresetBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 44)
    PresetBtn.Text = name
    PresetBtn.TextColor3 = Color3.fromRGB(240, 240, 245)
    PresetBtn.Font = Enum.Font.GothamBold
    PresetBtn.TextSize = 11
    PresetBtn.Parent = ScaleFrame
    
    local PCorner = Instance.new("UICorner")
    PCorner.CornerRadius = UDim.new(0, 5)
    PCorner.Parent = PresetBtn
    
    PresetBtn.MouseButton1Click:Connect(function()
        _G.BeyondConfig.BodySize = name
        ScaleLabel.Text = "Пресеты Роста: <font color='#FF2B5A'>" .. name .. "</font>"
        TweenService:Create(PresetBtn, TweenInfo.new(0.15), {BackgroundColor3 = _G.BeyondConfig.ThemeColor}):Play()
        RebuildBodyScale(multiplier)
        task.wait(0.15)
        TweenService:Create(PresetBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(32, 32, 44)}):Play()
    end)
end

-- Инициализация 4 профессиональных пресетов
CreatePresetElement("Мелкий", 12, 0.45)
CreatePresetElement("Средний", 106, 1.0)
CreatePresetElement("Большой", 200, 1.9)
CreatePresetElement("Гигант", 294, 3.8)

-- Ползунок плавного скейлинга костей тела для микронастроек (%)
CreateSlider(Container, "Точный Скейлинг Рига (%)", 40, 400, 100, function(percent)
    RebuildBodyScale(percent / 100)
end)

-- ====================================================================
-- [ ФИНИШНАЯ КОМПИЛЯЦИЯ И ЗАПУСК КЛИЕНТА ]
-- ====================================================================

-- Анимация плавного развертывания интерфейса (Boot Sequence)
MainFrame.Size = UDim2.new(0, 440, 0, 0)
local openTween = TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, 440, 0, 340)})
openTween:Play()

print("[BeyondClient]: Сборка v5.0-Alpha полностью завершена и готова к тестам!")
--[[
    BeyondClient v5.0 - Ultimate Premium Edition
    Developer: UserBeyond-dev
    File: main.lua (Part 5/Unknown - High-Performance ESP Engine)
--]]

-- Расширение глобальной конфигурации новыми параметрами
_G.BeyondConfig.ESP = {
    Enabled = false,
    Boxes = false,
    Tracers = false,
    Names = false,
    Health = false,
    MaxDistance = 1500,
    TeamCheck = false
}

-- Создание секции ESP в главном контейнере UI
local ESPSectionLabel = Instance.new("TextLabel")
ESPSectionLabel.Size = UDim2.new(1, 0, 0, 25)
ESPSectionLabel.Text = "--- [ СИСТЕМА ВИЗУАЛИЗАЦИИ (ESP) ] ---"
ESPSectionLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
ESPSectionLabel.Font = Enum.Font.GothamBold
ESPSectionLabel.TextSize = 12
ESPSectionLabel.BackgroundTransparency = 1
ESPSectionLabel.Parent = Container

CreateToggle(Container, "Включить ESP Мастер-Свитч", _G.BeyondConfig.ESP.Enabled, function(state)
    _G.BeyondConfig.ESP.Enabled = state
end)

CreateToggle(Container, "Отрисовка Боксов (2D Boxes)", _G.BeyondConfig.ESP.Boxes, function(state)
    _G.BeyondConfig.ESP.Boxes = state
end)

CreateToggle(Container, "Линии до Игроков (Tracers)", _G.BeyondConfig.ESP.Tracers, function(state)
    _G.BeyondConfig.ESP.Tracers = state
end)

CreateToggle(Container, "Отображение Никнеймов", _G.BeyondConfig.ESP.Names, function(state)
    _G.BeyondConfig.ESP.Names = state
end)

CreateToggle(Container, "Индикатор Здоровья (HealthBar)", _G.BeyondConfig.ESP.Health, function(state)
    _G.BeyondConfig.ESP.Health = state
end)

-- Создание контейнера для рендеринга 2D-элементов поверх CoreGui
local ESPHolder = Instance.new("Folder")
ESPHolder.Name = "Beyond_ESP_Storage"
ESPHolder.Parent = BeyondScreenGui

local function CreateESPVisuals(player)
    if player == LocalPlayer then return end
    
    local BoxFrame = Instance.new("Frame")
    BoxFrame.BackgroundTransparency = 1
    BoxFrame.BorderSizePixel = 0
    BoxFrame.Visible = false
    BoxFrame.Parent = ESPHolder
    
    local BoxStroke = Instance.new("UIStroke")
    BoxStroke.Thickness = 1.5
    BoxStroke.Color = _G.BeyondConfig.ThemeColor
    BoxStroke.Parent = BoxFrame
    
    local TracerLine = Instance.new("Frame")
    TracerLine.BorderSizePixel = 0
    TracerLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TracerLine.Visible = false
    TracerLine.Parent = ESPHolder
    
    local NameTag = Instance.new("TextLabel")
    NameTag.Size = UDim2.new(0, 200, 0, 20)
    NameTag.BackgroundTransparency = 1
    NameTag.TextColor3 = Color3.fromRGB(255, 255, 255)
    NameTag.Font = Enum.Font.GothamBold
    NameTag.TextSize = 11
    NameTag.Visible = false
    NameTag.Parent = ESPHolder
    
    local HealthBar = Instance.new("Frame")
    HealthBar.BorderSizePixel = 0
    HealthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
    HealthBar.Visible = false
    HealthBar.Parent = ESPHolder

    local function UpdateVisuals()
        local connection
        connection = RunService.RenderStepped:Connect(function()
            if not player.Parent or not _G.BeyondConfig or not _G.BeyondConfig.ESP.Enabled then
                BoxFrame.Visible = false
                TracerLine.Visible = false
                NameTag.Visible = false
                HealthBar.Visible = false
                if not player.Parent then connection:Disconnect() end
                return
            end
            
            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            
            if hrp and hum and hum.Health > 0 then
                local hrpPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                
                if onScreen then
                    local distance = (Camera.CFrame.Position - hrp.Position).Magnitude
                    if distance <= _G.BeyondConfig.ESP.MaxDistance then
                        
                        -- Командный фильтр
                        if _G.BeyondConfig.ESP.TeamCheck and player.Team == LocalPlayer.Team then
                            BoxFrame.Visible = false; TracerLine.Visible = false; NameTag.Visible = false; HealthBar.Visible = false
                            return
                        end
                        
                        -- Вычисление динамического размера 2D бокса на основе дистанции
                        local scaleFactor = 1 / (hrpPos.Z * math.tan(math.rad(Camera.FieldOfView * 0.5))) * 1000
                        local boxWidth = scaleFactor * 4.5
                        local boxHeight = scaleFactor * 6
                        
                        -- Рендеринг Боксов
                        if _G.BeyondConfig.ESP.Boxes then
                            BoxFrame.Size = UDim2.new(0, boxWidth, 0, boxHeight)
                            BoxFrame.Position = UDim2.new(0, hrpPos.X - boxWidth/2, 0, hrpPos.Y - boxHeight/2)
                            BoxFrame.Visible = true
                        else
                            BoxFrame.Visible = false
                        end
                        
                        -- Рендеринг Трейсеров (Линий из центра нижней части экрана)
                        if _G.BeyondConfig.ESP.Tracers then
                            local startX = Camera.ViewportSize.X / 2
                            local startY = Camera.ViewportSize.Y
                            local deltaX = hrpPos.X - startX
                            local deltaY = hrpPos.Y - startY
                            local angle = math.atan2(deltaY, deltaX)
                            local lineLength = math.sqrt(deltaX^2 + deltaY^2)
                            
                            TracerLine.Size = UDim2.new(0, lineLength, 0, 1.5)
                            TracerLine.Position = UDim2.new(0, startX, 0, startY)
                            TracerLine.Rotation = math.rad(angle)
                            TracerLine.Visible = true
                        else
                            TracerLine.Visible = false
                        end
                        
                        -- Рендеринг Имен
                        if _G.BeyondConfig.ESP.Names then
                            NameTag.Text = player.Name .. " [" .. math.round(distance) .. "m]"
                            NameTag.Position = UDim2.new(0, hrpPos.X - 100, 0, hrpPos.Y - boxHeight/2 - 22)
                            NameTag.Visible = true
                        else
                            NameTag.Visible = false
                        end
                        
                        -- Рендеринг Полоски здоровья (HealthBar слева от бокса)
                        if _G.BeyondConfig.ESP.Health and _G.BeyondConfig.ESP.Boxes then
                            local healthPercent = hum.Health / hum.MaxHealth
                            HealthBar.Size = UDim2.new(0, 3, 0, boxHeight * healthPercent)
                            HealthBar.Position = UDim2.new(0, hrpPos.X - boxWidth/2 - 7, 0, hrpPos.Y - boxHeight/2 + (boxHeight * (1 - healthPercent)))
                            HealthBar.BackgroundColor3 = Color3.fromHSV(healthPercent * 0.33, 1, 1) -- Смена цвета от красного к зеленому
                            HealthBar.Visible = true
                        else
                            HealthBar.Visible = false
                        end
                        
                        return
                    end
                end
            end
            
            -- Скрытие элементов, если игрок мертв или за пределами видимости экрана
            BoxFrame.Visible = false
            TracerLine.Visible = false
            NameTag.Visible = false
            HealthBar.Visible = false
        end)
    end
    
    task.spawn(UpdateVisuals)
end

-- Инициализация ESP трекера для всех текущих и будущих игроков
for _, player in ipairs(Players:GetPlayers()) do
    CreateESPVisuals(player)
end
Players.PlayerAdded:Connect(CreateESPVisuals)

print("[BeyondClient Visuals]: Продвинутый ESP-движок успешно добавлен.")
--[[
    BeyondClient v5.0 - Ultimate Premium Edition
    Developer: UserBeyond-dev
    File: main.lua (Part 6/Unknown - Premium UI Shaders & Theme Engine)
--]]

-- Расширение настроек визуального стиля интерфейса
_G.BeyondConfig.Visuals = {
    BackgroundBlur = true,
    RainbowGlow = false,
    GlowSpeed = 2,
    MenuOpened = true
}

-- Инициализация системного шейдера размытия заднего плана (Lighting Blur)
local UIBlur = Lighting:FindFirstChild("Beyond_Interface_Blur")
if not UIBlur then
    UIBlur = Instance.new("BlurEffect")
    UIBlur.Name = "Beyond_Interface_Blur"
    UIBlur.Size = _G.BeyondConfig.Visuals.BackgroundBlur and 14 or 0
    UIBlur.Enabled = true
    UIBlur.Parent = Lighting
end

-- Создание декоративной панели управления стилем внутри контейнера меню
local VisualSectionLabel = Instance.new("TextLabel")
VisualSectionLabel.Size = UDim2.new(1, 0, 0, 25)
VisualSectionLabel.Text = "--- [ НАСТРОЙКИ СТИЛЯ И ИНТЕРФЕЙСА ] ---"
VisualSectionLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
VisualSectionLabel.Font = Enum.Font.GothamBold
VisualSectionLabel.TextSize = 12
VisualSectionLabel.BackgroundTransparency = 1
VisualSectionLabel.Parent = Container

CreateToggle(Container, "Размытие Заднего Плана (Blur)", _G.BeyondConfig.Visuals.BackgroundBlur, function(state)
    _G.BeyondConfig.Visuals.BackgroundBlur = state
    TweenService:Create(UIBlur, TweenInfo.new(0.3), {Size = state and 14 or 0}):Play()
end)

CreateToggle(Container, "RGB Неоновое Свечение Рамки", _G.BeyondConfig.Visuals.RainbowGlow, function(state)
    _G.BeyondConfig.Visuals.RainbowGlow = state
    if not state then
        -- Возвращаем дефолтный розовый цвет Zero Two при выключении
        TweenService:Create(Stroke, TweenInfo.new(0.3), {Color = _G.BeyondConfig.ThemeColor}):Play()
        TweenService:Create(HeaderLine, TweenInfo.new(0.3), {BackgroundColor3 = _G.BeyondConfig.ThemeColor}):Play()
    end
end)

-- Слайдер регулировки скорости перелива цветов (RGB Speed)
CreateSlider(Container, "Скорость Перелива RGB", 1, 10, _G.BeyondConfig.Visuals.GlowSpeed, function(val)
    _G.BeyondConfig.Visuals.GlowSpeed = val
end)

-- Выделенный цикл для динамического рендеринга RGB-эффекта по фазам HSV
local hueValue = 0
RunService.RenderStepped:Connect(function(deltaTime)
    if _G.BeyondConfig and _G.BeyondConfig.Visuals and _G.BeyondConfig.Visuals.RainbowGlow then
        -- Плавное смещение цветовой фазы в зависимости от заданного ползунка скорости
        hueValue = (hueValue + (deltaTime * (_G.BeyondConfig.Visuals.GlowSpeed / 10))) % 1
        local currentRainbowColor = Color3.fromHSV(hueValue, 0.8, 1)
        
        -- Синхронное обновление цвета обводки и разделительной линии шапки
        Stroke.Color = currentRainbowColor
        HeaderLine.BackgroundColor3 = currentRainbowColor
        Container.ScrollBarImageColor3 = currentRainbowColor
    end
end)

-- ТРИГГЕР СКРЫТИЯ/ОТКРЫТИЯ МЕНЮ НА КЛАВИШУ "Правый Shift" (RightShift)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    -- Проверяем, что игрок нажал клавишу вне поля чата
    if not gameProcessed and input.KeyCode == Enum.KeyCode.RightShift then
        _G.BeyondConfig.Visuals.MenuOpened = not _G.BeyondConfig.Visuals.MenuOpened
        
        local isVisible = _G.BeyondConfig.Visuals.MenuOpened
        local targetSize = isVisible and UDim2.new(0, 440, 0, 340) or UDim2.new(0, 440, 0, 0)
        local targetBlur = (isVisible and _G.BeyondConfig.Visuals.BackgroundBlur) and 14 or 0
        
        -- Плавная анимация сворачивания меню и отключения размытия экрана
        TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = targetSize}):Play()
        TweenService:Create(UIBlur, TweenInfo.new(0.3), {Size = targetBlur}):Play()
        
        -- Отключаем видимость дочерних элементов во время закрытия, чтобы не вылезали за рамку
        task.spawn(function()
            if not isVisible then
                task.wait(0.1)
                MainFrame.ClipsDescendants = true
            else
                MainFrame.ClipsDescendants = false
            end
        end)
    end
end)

print("[BeyondClient Shaders]: Модуль графических шейдеров успешно интегрирован.")
--[[
    BeyondClient v5.0 - Ultimate Premium Edition
    Developer: UserBeyond-dev
    File: main.lua (Part 7/Unknown - Advanced Script Hub & Loader Core)
--]]

-- Инициализация локального хранилища скриптов внутри хаба
local ScriptHubData = {
    {
        Name = "Infinite Yield (FE Admin)",
        Desc = "Самый мощный консольный админ-скрипт (более 500 команд).",
        Url = "https://githubusercontent.com"
    },
    {
        Name = "Dex Explorer (v4 R15)",
        Desc = "Профессиональный инспектор объектов и свойств workspace.",
        Url = "https://githubusercontent.com"
    },
    {
        Name = "Hydroxide (Network Spy)",
        Desc = "Сканер удаленных событий (RemoteEvent / RemoteFunction).",
        Url = "https://githubusercontent.com"
    }
}

-- Декоративный заголовок для секции хаба в контейнере UI
local HubSectionLabel = Instance.new("TextLabel")
HubSectionLabel.Size = UDim2.new(1, 0, 0, 25)
HubSectionLabel.Text = "--- [ ВСТРОЕННЫЙ SCRIPT HUB ] ---"
HubSectionLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
HubSectionLabel.Font = Enum.Font.GothamBold
HubSectionLabel.TextSize = 12
HubSectionLabel.BackgroundTransparency = 1
HubSectionLabel.Parent = Container

-- Функция безопасного выполнения удаленного кода (HTTP Execution Bypass)
local function SafeExecuteHTTP(scriptName, targetUrl)
    print("[BeyondClient Hub]: Запрос на загрузку модуля -> " .. scriptName)
    
    task.spawn(function()
        -- Проверка наличия HTTP-клиента в текущем эксплойте
        local loadstringCheck = (loadstring or loadstringG)
        local requestCheck = (syn and syn.request) or (http and http.request) or request or http_request
        
        if not loadstringCheck then
            warn("[BeyondClient Error]: Ваша среда выполнения не поддерживает loadstring.")
            return
        end
        
        -- Попытка безопасного чтения исходного кода через game:HttpGet или request хуки
        local success, scriptRawCode = pcall(function()
            if game.HttpGet then
                return game:HttpGet(targetUrl)
            elseif requestCheck then
                local response = requestCheck({Url = targetUrl, Method = "GET"})
                return response.Body
            end
            error("Нет доступных HTTP методов для загрузки.")
        end)
        
        if success and scriptRawCode and #scriptRawCode > 0 then
            -- Компиляция полученных строковых данных в байт-код Lua
            local compiledFunction, compileError = loadstring(scriptRawCode)
            
            if compiledFunction then
                local execSuccess, execError = pcall(compiledFunction)
                if execSuccess then
                    print("[BeyondClient Hub]: Модуль " .. scriptName .. " успешно инжектирован!")
                else
                    warn("[BeyondClient Runtime Error]: Ошибка выполнения скрипта: " .. tostring(execError))
                end
            else
                warn("[BeyondClient Syntax Error]: Ошибка компиляции кода: " .. tostring(compileError))
            end
        else
            warn("[BeyondClient Connection Error]: Не удалось получить данные по ссылке: " .. tostring(targetUrl))
        end
    end)
end

-- Динамическая генерация карточек скриптов в интерфейсе меню
for idx, scriptInfo in ipairs(ScriptHubData) do
    local HubFrame = Instance.new("Frame")
    HubFrame.Name = "HubCard_" .. tostring(idx)
    HubFrame.Size = UDim2.new(1, 0, 0, 60)
    HubFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    HubFrame.BorderSizePixel = 0
    HubFrame.Parent = Container
    
    local HubCorner = Instance.new("UICorner")
    HubCorner.CornerRadius = UDim.new(0, 8)
    HubCorner.Parent = HubFrame
    
    local HubStroke = Instance.new("UIStroke")
    HubStroke.Thickness = 1
    HubStroke.Color = Color3.fromRGB(35, 35, 45)
    HubStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    HubStroke.Parent = HubFrame
    
    local NameLabel = Instance.new("TextLabel")
    NameLabel.Size = UDim2.new(0.65, 0, 0, 22)
    NameLabel.Position = UDim2.new(0, 12, 0, 6)
    NameLabel.Text = scriptInfo.Name
    NameLabel.TextColor3 = Color3.fromRGB(240, 240, 245)
    NameLabel.Font = Enum.Font.GothamBold
    NameLabel.TextSize = 13
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    NameLabel.BackgroundTransparency = 1
    NameLabel.Parent = HubFrame
    
    local DescLabel = Instance.new("TextLabel")
    DescLabel.Size = UDim2.new(0.65, 0, 0, 26)
    DescLabel.Position = UDim2.new(0, 12, 0, 26)
    DescLabel.Text = scriptInfo.Desc
    DescLabel.TextColor3 = Color3.fromRGB(130, 130, 145)
    DescLabel.Font = Enum.Font.Gotham
    DescLabel.TextSize = 11
    DescLabel.TextWrapped = true
    DescLabel.TextXAlignment = Enum.TextXAlignment.Left
    DescLabel.TextYAlignment = Enum.TextYAlignment.Top
    DescLabel.BackgroundTransparency = 1
    DescLabel.Parent = HubFrame
    
    local LaunchBtn = Instance.new("TextButton")
    LaunchBtn.Size = UDim2.new(0, 90, 0, 32)
    LaunchBtn.Position = UDim2.new(1, -102, 0.5, -16)
    LaunchBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
    LaunchBtn.Text = "ЗАПУСТИТЬ"
    LaunchBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    LaunchBtn.Font = Enum.Font.GothamBold
    LaunchBtn.TextSize = 10
    LaunchBtn.Parent = HubFrame
    
    local LCorner = Instance.new("UICorner")
    LCorner.CornerRadius = UDim.new(0, 6)
    LCorner.Parent = LaunchBtn
    
    -- Интерактивная анимация клика по кнопке запуска
    LaunchBtn.MouseButton1Click:Connect(function()
        TweenService:Create(LaunchBtn, TweenInfo.new(0.1), {BackgroundColor3 = _G.BeyondConfig.ThemeColor}):Play()
        task.spawn(function()
            SafeExecuteHTTP(scriptInfo.Name, scriptInfo.Url)
            task.wait(0.2)
            TweenService:Create(LaunchBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 48)}):Play()
        end)
    end)
end

print("[BeyondClient ScriptHub]: Модуль Script Hub успешно добавлен в ядро клиента.")
-- ====================================================================
-- [ МОБИЛЬНЫЙ МОДУЛЬ: ПЛАВАЮЩАЯ КНОПКА ДЛЯ DELTA EXECUTOR ]
-- ====================================================================

local TouchInpService = game:GetService("UserInputService")
local TwService = game:GetService("TweenService")

-- Проверяем, что базовый интерфейс существует
local CoreGuiContainer = MainFrame and MainFrame.Parent
if not CoreGuiContainer or not MainFrame then
    warn("[BeyondClient Mobile Error]: Главное меню не найдено. Убедитесь, что этот код вставлен в самый конец!")
    return
end

-- Создаем круглую кнопку-иконку
local MobileToggleButton = Instance.new("ImageButton")
MobileToggleButton.Name = "BeyondMobileToggle"
MobileToggleButton.Size = UDim2.new(0, 50, 0, 50)
-- Начальная позиция в левой части экрана, чуть ниже верхнего края
MobileToggleButton.Position = UDim2.new(0, 15, 0.2, 0)
MobileToggleButton.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MobileToggleButton.BorderSizePixel = 0
MobileToggleButton.Image = "rbxassetid://114254245648192" -- Иконка Ноль Два
MobileToggleButton.ZIndex = 10
MobileToggleButton.Parent = CoreGuiContainer

-- Скругление кнопки в идеальный круг
local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(1, 0)
ButtonCorner.Parent = MobileToggleButton

-- Неоновая розовая обводка кнопки в стиле Zero Two
local ButtonStroke = Instance.new("UIStroke")
ButtonStroke.Thickness = 1.5
ButtonStroke.Color = Color3.fromRGB(255, 43, 90)
ButtonStroke.Parent = MobileToggleButton

-- --- СИСТЕМА ПЕРЕТАСКИВАНИЯ МОБИЛЬНОЙ КНОПКИ (DRAG) ---
local btnDragging = false
local btnDragInput, btnDragStart, btnStartPos

local function updateBtnDrag(input)
    local delta = input.Position - btnDragStart
    MobileToggleButton.Position = UDim2.new(
        btnStartPos.X.Scale, btnStartPos.X.Offset + delta.x, 
        btnStartPos.Y.Scale, btnStartPos.Y.Offset + delta.y
    )
end

MobileToggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        btnDragging = true
        btnDragStart = input.Position
        btnStartPos = MobileToggleButton.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                btnDragging = false
            end
        end)
    end
end)

MobileToggleButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseBehavior or input.UserInputType == Enum.UserInputType.Touch then
        btnDragInput = input
    end
end)

TouchInpService.InputChanged:Connect(function(input)
    if input == btnDragInput and btnDragging then
        updateBtnDrag(input)
    end
end)

-- --- ЛОГИКА НАЖАТИЯ: ОТКРЫТИЕ И ЗАКРЫТИЕ ---
MobileToggleButton.MouseButton1Click:Connect(function()
    if not _G.BeyondConfig or not _G.BeyondConfig.Visuals then return end
    
    -- Меняем статус видимости меню
    _G.BeyondConfig.Visuals.MenuOpened = not _G.BeyondConfig.Visuals.MenuOpened
    local isVisible = _G.BeyondConfig.Visuals.MenuOpened
    
    local targetSize = isVisible and UDim2.new(0, 440, 0, 340) or UDim2.new(0, 440, 0, 0)
    
    -- Анимация кнопки при клике (визуальный отклик)
    MobileToggleButton.Size = UDim2.new(0, 45, 0, 45)
    TwService:Create(MobileToggleButton, TweenInfo.new(0.1), {Size = UDim2.new(0, 50, 0, 50)}):Play()
    
    -- Плавное сворачивание/разворачивание основного меню
    TwService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = targetSize}):Play()
    
    -- Управление обрезкой элементов (ClipsDescendants), чтобы интерфейс не ломался визуально
    task.spawn(function()
        if not isVisible then
            task.wait(0.05)
            MainFrame.ClipsDescendants = true
        else
            MainFrame.ClipsDescendants = false
        end
    end)
end)

print("[BeyondClient Mobile]: Плавающая кнопка для сенсорных экранов успешно инициализирована.")
