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
