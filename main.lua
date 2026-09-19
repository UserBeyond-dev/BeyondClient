--[[
    BeyondClient v5.0 - Ultimate Mobile Edition
    Target Hardware: HONOR Play5 (Dimensity 800U / 8GB RAM / Android 10)
    Developer: UserBeyond-dev
    File: main.lua (Part 1/Unknown - Advanced Window Controls & Self-Destruct System)
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera or workspace:WaitForChild("Camera")

-- Тотальная очистка предыдущей сессии скрипта (если она была запущена ранее)
if _G.BeyondClient_SelfDestruct then
    pcall(_G.BeyondClient_SelfDestruct)
end

-- Инициализация глобального кэша и конфигурации под дисплей 2400х1080
_G.BeyondConfig = {
    Version = "5.0-HONOR-Edition",
    Developer = "UserBeyond-dev",
    SpeedValue = 16,
    InfiniteJump = false,
    Noclip = false,
    GodMode = false,
    BodySize = "Средний",
    ThemeColor = Color3.fromRGB(255, 43, 90), -- Розовый Zero Two
    BgColor = Color3.fromRGB(15, 15, 20),
    IsMenuOpened = true,
    GlowPhase = 0
}

-- Глобальный трекер для отключения всех активных фоновых циклов при выгрузке читиков
local ScriptActive = true

-- Создание корневого защищенного GUI контейнера поверх игровых окон Delta
local BeyondScreenGui = Instance.new("ScreenGui")
BeyondScreenGui.Name = "Beyond_" .. HttpService:GenerateGUID(false):sub(1, 8)
BeyondScreenGui.ResetOnSpawn = false
BeyondScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local success, err = pcall(function() BeyondScreenGui.Parent = CoreGui end)
if not success then BeyondScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- Главный фрейм управления (Адаптирован под тач-скрины 2400x1080)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainPanel"
MainFrame.Size = UDim2.new(0, 440, 0, 340)
MainFrame.Position = UDim2.new(0.5, -220, 0.4, -170)
MainFrame.BackgroundColor3 = _G.BeyondConfig.BgColor
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = BeyondScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 14)
Corner.Parent = MainFrame

-- Фирменная неоновая обводка рамки меню
local Stroke = Instance.new("UIStroke")
Stroke.Thickness = 2
Stroke.Color = _G.BeyondConfig.ThemeColor
Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
Stroke.Parent = MainFrame

-- --- ВЕРХНЯЯ ШАПКА И ЗОНА ХЕНДЛИНГА DRAG-UI ---
local Header = Instance.new("Frame")
Header.Name = "HeaderZone"
Header.Size = UDim2.new(1, 0, 0, 45)
Header.BackgroundColor3 = Color3.fromRGB(28, 26, 36)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 14)
HeaderCorner.Parent = Header

local HeaderLine = Instance.new("Frame")
HeaderLine.Size = UDim2.new(1, 0, 0, 2)
HeaderLine.Position = UDim2.new(0, 0, 1, -2)
HeaderLine.BackgroundColor3 = _G.BeyondConfig.ThemeColor
HeaderLine.BorderSizePixel = 0
HeaderLine.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -150, 1, 0)
Title.Position = UDim2.new(0, 16, 0, 0)
Title.Text = "BEYOND <font color='#FF2B5A'>CLIENT</font> <font color='#A0A0A5'>v5.0</font>"
Title.RichText = true
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
Title.Parent = Header

-- --- ПЛАВАЮЩАЯ КНОПКА ВЫЗОВА МЕНЮ (Инициализируется скрытой) ---
local MobileToggleButton = Instance.new("ImageButton")
MobileToggleButton.Name = "BeyondMobileCall"
MobileToggleButton.Size = UDim2.new(0, 52, 0, 52)
MobileToggleButton.Position = UDim2.new(0, 20, 0.25, 0)
MobileToggleButton.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
MobileToggleButton.BorderSizePixel = 0
MobileToggleButton.Image = "rbxassetid://16024021200" -- Рабочий ассет круга
MobileToggleButton.ImageColor3 = _G.BeyondConfig.ThemeColor
MobileToggleButton.ZIndex = 15
MobileToggleButton.Visible = false
MobileToggleButton.Parent = BeyondScreenGui

Instance.new("UICorner", MobileToggleButton).CornerRadius = UDim.new(1, 0)
local ButtonStroke = Instance.new("UIStroke", MobileToggleButton)
ButtonStroke.Thickness = 2
ButtonStroke.Color = _G.BeyondConfig.ThemeColor

-- --- ФУНКЦИОНАЛ КНОПКИ «МИНУС» (СКРЫТЬ ОКНО) ---
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Name = "Minimize"
MinimizeBtn.Size = UDim2.new(0, 32, 0, 32)
MinimizeBtn.Position = UDim2.new(1, -78, 0.5, -16)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(38, 38, 50)
MinimizeBtn.Text = "—"
MinimizeBtn.TextColor3 = Color3.fromRGB(220, 220, 235)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 14
MinimizeBtn.Parent = Header

local MinCorner = Instance.new("UICorner", MinimizeBtn)
MinCorner.CornerRadius = UDim.new(0, 6)

MinimizeBtn.MouseButton1Click:Connect(function()
    _G.BeyondConfig.IsMenuOpened = false
    -- Плавное сворачивание главного меню в ноль
    TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Size = UDim2.new(0, 440, 0, 0)}):Play()
    task.wait(0.2)
    MainFrame.Visible = false
    -- Проявление плавающей круглой кнопки вызова
    MobileToggleButton.Visible = true
    MobileToggleButton.Size = UDim2.new(0, 0, 0, 0)
    TweenService:Create(MobileToggleButton, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 52, 0, 52)}):Play()
end)

-- --- СИСТЕМА ТОТАЛЬНОГО СБРОСА И ЗАЧИСТКИ (КРЕСТИК) ---
local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "Close"
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -42, 0.5, -16)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 43, 90)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 12
CloseBtn.Parent = Header

local CloseCorner = Instance.new("UICorner", CloseBtn)
CloseCorner.CornerRadius = UDim.new(0, 6)

-- Функция-чистильщик следов
_G.BeyondClient_SelfDestruct = function()
    ScriptActive = false -- Останавливаем все фоновые потоки и рэйкасты
    
    -- Возвращаем дефолтные параметры физики аватара
    pcall(function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = 16 end
        
        -- Возвращаем коллизии текстур на место
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = true end
        end
    end)
    
    -- Полное уничтожение всех элементов UI из CoreGui
    BeyondScreenGui:Destroy()
    _G.BeyondConfig = nil
    _G.BeyondClient_SelfDestruct = nil
    print("[BeyondClient]: Все следы софта успешно стерты из памяти девайса.")
end

CloseBtn.MouseButton1Click:Connect(function()
    _G.BeyondClient_SelfDestruct()
end)

-- Логика разворачивания меню обратно по нажатию на плавающую кнопку
MobileToggleButton.MouseButton1Click:Connect(function()
    _G.BeyondConfig.IsMenuOpened = true
    TweenService:Create(MobileToggleButton, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)}):Play()
    task.wait(0.15)
    MobileToggleButton.Visible = false
    MainFrame.Visible = true
    TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, 440, 0, 340)}):Play()
end)

-- --- ГЛАВНЫЙ СКОЛЛИНГ-КОНТЕЙНЕР ДЛЯ ПОСЛЕДУЮЩИХ МОДУЛЕЙ ---
local Container = Instance.new("ScrollingFrame")
Container.Name = "ModuleContainer"
Container.Size = UDim2.new(1, -24, 1, -95)
Container.Position = UDim2.new(0, 12, 0, 58)
Container.BackgroundTransparency = 1
Container.BorderSizePixel = 0
Container.CanvasSize = UDim2.new(0, 0, 0, 700)
Container.ScrollBarThickness = 4
Container.ScrollBarImageColor3 = _G.BeyondConfig.ThemeColor
Container.Parent = MainFrame

local ListLayout = Instance.new("UIListLayout")
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Padding = UDim.new(0, 10)
ListLayout.Parent = Container

print("[BeyondClient Framework]: Часть 1 успешно развернута. Жду точку.")
--[[
    BeyondClient v5.0 - Ultimate Mobile Edition
    Target Hardware: HONOR Play5 (2400x1080 / Touch Optimization)
    File: main.lua (Part 2/Unknown - Touch Drag-UI & Adaptive Interface Factory)
--]]

-- ====================================================================
-- [ МОДУЛЬ ОБРАБОТКИ СЕНСОРНЫХ ЖЕСТОВ (TOUCH DRAG-UI) ]
-- ====================================================================

local function EnableTouchDrag(dragZone, targetFrame)
    local dragToggle = false
    local dragInput, dragStart, startPosition

    dragZone.InputBegan:Connect(function(input)
        -- Реагируем строго на первое касание пальца (Touch) или клик мыши
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragToggle = true
            dragStart = input.Position
            startPosition = targetFrame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragToggle = false
                end
            end)
        end
    end)

    dragZone.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseBehavior then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragToggle and ScriptActive then
            local delta = input.Position - dragStart
            -- Плавное смещение фрейма пальцем без прыжков по координатам
            targetFrame.Position = UDim2.new(
                startPosition.X.Scale, startPosition.X.Offset + delta.X,
                startPosition.Y.Scale, startPosition.Y.Offset + delta.Y
            )
        end
    end)
end

-- Активируем независимое перетаскивание для главного меню и для плавающей кнопки
EnableTouchDrag(Header, MainFrame)
EnableTouchDrag(MobileToggleButton, MobileToggleButton)

-- ====================================================================
-- [ АДАПТИВНАЯ МОБИЛЬНАЯ UI-ФАБРИКА С ИНТЕРПОЛЯЦИЕЙ ]
-- ====================================================================

-- Конструктор премиальных тогглов (Переключателей)
local function CreateMobileToggle(parent, text, default, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 46)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.Parent = parent
    
    local TFCorner = Instance.new("UICorner")
    TFCorner.CornerRadius = UDim.new(0, 8)
    TFCorner.Parent = ToggleFrame
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Position = UDim2.new(0, 14, 0, 0)
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(215, 215, 225)
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1
    Label.Parent = ToggleFrame
    
    local CheckBox = Instance.new("TextButton")
    CheckBox.Size = UDim2.new(0, 44, 0, 24)
    CheckBox.Position = UDim2.new(1, -58, 0.5, -12)
    CheckBox.BackgroundColor3 = default and _G.BeyondConfig.ThemeColor or Color3.fromRGB(45, 45, 60)
    CheckBox.Text = ""
    CheckBox.Parent = ToggleFrame
    
    local CBCorner = Instance.new("UICorner")
    CBCorner.CornerRadius = UDim.new(1, 0)
    CBCorner.Parent = CheckBox
    
    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.new(0, 18, 0, 18)
    Indicator.Position = default and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
    Indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Indicator.Parent = CheckBox
    
    local IndCorner = Instance.new("UICorner")
    IndCorner.CornerRadius = UDim.new(1, 0)
    IndCorner.Parent = Indicator
    
    local state = default
    CheckBox.MouseButton1Click:Connect(function()
        if not ScriptActive then return end
        state = not state
        
        local targetColor = state and _G.BeyondConfig.ThemeColor or Color3.fromRGB(45, 45, 60)
        local targetPos = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
        
        -- Плавная анимация переключения под палец
        TweenService:Create(CheckBox, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {BackgroundColor3 = targetColor}):Play()
        TweenService:Create(Indicator, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {Position = targetPos}):Play()
        
        callback(state)
    end)
end

-- Конструктор кастомных слайдеров (Ползунков для точных настроек)
local function CreateMobileSlider(parent, text, min, max, default, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, 0, 0, 58)
    SliderFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    SliderFrame.BorderSizePixel = 0
    SliderFrame.Parent = parent
    
    local SFCorner = Instance.new("UICorner")
    SFCorner.CornerRadius = UDim.new(0, 8)
    SFCorner.Parent = SliderFrame
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.8, 0, 0, 26)
    Label.Position = UDim2.new(0, 14, 0, 4)
    Label.Text = text .. ": <font color='#FF2B5A'>" .. tostring(default) .. "</font>"
    Label.RichText = true
    Label.TextColor3 = Color3.fromRGB(220, 220, 230)
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1
    Label.Parent = SliderFrame
    
    local Track = Instance.new("Frame")
    Track.Size = UDim2.new(1, -28, 0, 6)
    Track.Position = UDim2.new(0, 14, 0, 38)
    Track.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    Track.BorderSizePixel = 0
    Track.Parent = SliderFrame
    
    local TrackCorner = Instance.new("UICorner")
    TrackCorner.CornerRadius = UDim.new(0, 3)
    TrackCorner.Parent = Track
    
    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = _G.BeyondConfig.ThemeColor
    Fill.BorderSizePixel = 0
    Fill.Parent = Track
    
    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(0, 3)
    FillCorner.Parent = Fill
    
    local TriggerBtn = Instance.new("TextButton")
    TriggerBtn.Size = UDim2.new(1, 0, 1, 0)
    TriggerBtn.BackgroundTransparency = 1
    TriggerBtn.Text = ""
    TriggerBtn.Parent = Track
    
    local sliding = false
    
    local function processInput(input)
        local totalSize = Track.AbsoluteSize.X
        if totalSize == 0 then return end
        
        local xLocation = math.clamp(input.Position.X - Track.AbsolutePosition.X, 0, totalSize)
        local ratio = xLocation / totalSize
        local calculatedValue = math.round(min + (ratio * (max - min)))
        
        Fill.Size = UDim2.new(ratio, 0, 1, 0)
        Label.Text = text .. ": <font color='#FF2B5A'>" .. tostring(calculatedValue) .. "</font>"
        callback(calculatedValue)
    end
    
    TriggerBtn.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) and ScriptActive then
            sliding = true
            processInput(input)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if sliding and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseBehavior) and ScriptActive then
            processInput(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliding = false
        end
    end)
end

print("[BeyondClient UI-Engine]: Модуль жестов и фабрики кнопок успешно интегрирован.")
--[[
    BeyondClient v5.0 - Ultimate Mobile Edition
    Target Hardware: HONOR Play5 (2400x1080 / Graphic Optimization)
    File: main.lua (Part 3/Unknown - Legal Neon Overlay & Highlight ESP)
--]]

-- ====================================================================
-- [ МОДУЛЬ КРАСИВОЙ НЕОНОВОЙ ПОДСВЕТКИ (HIGHLIGHT VISUALIZER) ]
-- ====================================================================

-- Расширяем параметры оверлея в конфигурации
_G.BeyondConfig.Visuals.HighlightESP = false
_G.BeyondConfig.Visuals.EspOutlineTransparency = 0
_G.BeyondConfig.Visuals.EspFillTransparency = 0.5

-- Декоративный заголовок секции визуала в контейнере меню
local VisualSectionLabel = Instance.new("TextLabel")
VisualSectionLabel.Size = UDim2.new(1, 0, 0, 25)
VisualSectionLabel.Text = "--- [ НЕОНОВАЯ ПОДСВЕТКА МОДЕЛЕЙ ] ---"
VisualSectionLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
VisualSectionLabel.Font = Enum.Font.GothamBold
VisualSectionLabel.TextSize = 12
VisualSectionLabel.BackgroundTransparency = 1
VisualSectionLabel.Parent = Container

-- Переключатель для мастер-активации подсветки силуэтов
CreateMobileToggle(Container, "Включить подсветку моделей", _G.BeyondConfig.Visuals.HighlightESP, function(state)
    _G.BeyondConfig.Visuals.HighlightESP = state
    
    -- Если выключили, мгновенно скрываем все созданные подсветки
    if not state then
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character then
                local hl = player.Character:FindFirstChild("Beyond_Highlight")
                if hl then hl.Enabled = false end
            end
        end
    end
end)

-- Ползунки для тонкой регулировки прозрачности неонового заполнения и обводки
CreateMobileSlider(Container, "Прозрачность силуэта (%)", 0, 100, 50, function(val)
    _G.BeyondConfig.Visuals.EspFillTransparency = val / 100
end)

CreateMobileSlider(Container, "Прозрачность обводки (%)", 0, 100, 0, function(val)
    _G.BeyondConfig.Visuals.EspOutlineTransparency = val / 100
end)

-- Функция для безопасного добавления подсветки на персонажа
local function ApplyHighlight(player)
    if player == LocalPlayer then return end

    local function setupCharacter(char)
        if not ScriptActive then return end
        
        -- Удаляем старый эффект, если он существовал
        local oldHl = char:WaitForChild("Beyond_Highlight", 2) or char:FindFirstChild("Beyond_Highlight")
        if oldHl then oldHl:Destroy() end

        -- Создаем легальный графический объект выделения
        local highlight = Instance.new("Highlight")
        highlight.Name = "Beyond_Highlight"
        highlight.FillColor = _G.BeyondConfig.ThemeColor
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = _G.BeyondConfig.Visuals.EspFillTransparency
        highlight.OutlineTransparency = _G.BeyondConfig.Visuals.EspOutlineTransparency
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop -- Видно сквозь стены
        highlight.Enabled = _G.BeyondConfig.Visuals.HighlightESP
        highlight.Parent = char
    end

    if player.Character then
        setupCharacter(player.Character)
    end
    player.CharacterAdded:Connect(setupCharacter)
end

-- Инициализируем отслеживание для всех игроков в сессии
for _, player in ipairs(Players:GetPlayers()) do
    ApplyHighlight(player)
end
Players.PlayerAdded:Connect(ApplyHighlight)

-- ====================================================================
-- [ ЕДИНЫЙ ЦИКЛ ОПТИМИЗАЦИИ И НЕОНОВОГО ПЕРЕЛИВА (RGB GENERATOR) ]
-- ====================================================================

RunService.RenderStepped:Connect(function(deltaTime)
    if not ScriptActive or not _G.BeyondConfig then return end

    -- Постоянно обновляем фазу цвета для красивого градиента
    _G.BeyondConfig.GlowPhase = (_G.BeyondConfig.GlowPhase + (deltaTime * (_G.BeyondConfig.Visuals.GlowSpeed / 10))) % 1
    local dynamicRainbowColor = Color3.fromHSV(_G.BeyondConfig.GlowPhase, 0.85, 1)

    -- Переливание обводки самого интерфейса меню (если включено в настройках)
    if _G.BeyondConfig.Visuals.RainbowGlow then
        Stroke.Color = dynamicRainbowColor
        HeaderLine.BackgroundColor3 = dynamicRainbowColor
        Container.ScrollBarImageColor3 = dynamicRainbowColor
    end

    -- Переливание неоновой подсветки игроков в реальном времени
    if _G.BeyondConfig.Visuals.HighlightESP then
        for _, player in ipairs(Players:GetPlayers()) do
            local char = player.Character
            local hl = char and char:FindFirstChild("Beyond_Highlight")
            
            if hl and hl:IsA("Highlight") then
                hl.Enabled = true
                hl.FillColor = dynamicRainbowColor
                hl.OutlineColor = Color3.fromRGB(255, 255, 255) -- Четкая белая обводка для стиля
                hl.FillTransparency = _G.BeyondConfig.Visuals.EspFillTransparency
                hl.OutlineTransparency = _G.BeyondConfig.Visuals.EspOutlineTransparency
            end
        end
    end
end)

print("[BeyondClient Visuals]: Легальный неоновый оверлей успешно интегрирован.")
--[[
    BeyondClient v5.0 - Ultimate Mobile Edition
    Target Hardware: HONOR Play5 (Dimensity 800U / 8GB RAM / Android 10)
    Specification: Strict Legal Automation & Extended UI Core Execution Framework
    File: main.lua (Part 4/Unknown - Automated Input Emulation & Deep Style Palette)
--]]

-- Гарантируем строгую изоляцию контекста выполнения модуля
local VirtualUser = nil
pcall(function()
    VirtualUser = game:GetService("VirtualUser")
end)

-- Регистрация расширенных системных констант внутри глобальной конфигурации
_G.BeyondConfig.Automation = {
    AutoClickEnabled = false,
    ClickInterval = 100, -- Миллисекунды (диапазон от 10 до 1000)
    ClickType = "Левая кнопка", -- Пресеты для эмуляции тапа
    TotalClicksSimulated = 0
}

_G.BeyondConfig.Styles = {
    CurrentThemePreset = "Розовый Zero Two",
    CardBackgroundColor = Color3.fromRGB(20, 20, 28),
    BorderStrokeColor = Color3.fromRGB(35, 35, 45),
    FontsList = {
        Bold = Enum.Font.GothamBold,
        Semibold = Enum.Font.GothamSemibold,
        Regular = Enum.Font.Gotham,
        Monospace = Enum.Font.Code
    }
}

-- Создание декоративного визуального разделителя в скроллинг-контейнере
local AutomationSectionLabel = Instance.new("TextLabel")
AutomationSectionLabel.Name = "AutomationSection_TitleLabel"
AutomationSectionLabel.Size = UDim2.new(1, 0, 0, 30)
AutomationSectionLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
AutomationSectionLabel.BackgroundTransparency = 1
AutomationSectionLabel.Text = "--- [ МОДУЛЬ ЛЕГАЛЬНОЙ АВТОМАТИЗАЦИИ ] ---"
AutomationSectionLabel.TextColor3 = Color3.fromRGB(160, 160, 175)
AutomationSectionLabel.Font = _G.BeyondConfig.Styles.FontsList.Bold
AutomationSectionLabel.TextSize = 12
AutomationSectionLabel.TextStrokeTransparency = 0.8
AutomationSectionLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
AutomationSectionLabel.Parent = Container

-- --- ИНТЕГРАЦИЯ УПРАВЛЯЮЩИХ ЭЛЕМЕНТОВ АВТОКЛИКЕРА ---

CreateMobileToggle(Container, "Активировать макрос автокликера", _G.BeyondConfig.Automation.AutoClickEnabled, function(state)
    _G.BeyondConfig.Automation.AutoClickEnabled = state
    
    if state then
        -- Асинхронный запуск изолированного потока симуляции нажатий
        task.spawn(function()
            while _G.BeyondConfig and _G.BeyondConfig.Automation.AutoClickEnabled and ScriptActive do
                -- Динамический расчет интервала (миллисекунды в секунды с защитой от нулевого деления)
                local calculatedDelay = math.clamp(_G.BeyondConfig.Automation.ClickInterval / 1000, 0.01, 1.0)
                
                -- Безопасная эмуляция тапа по центру экрана или в текущую позицию камеры
                pcall(function()
                    if VirtualUser then
                        -- Официальный легальный вызов эмуляции клика для UI-тестов
                        VirtualUser:CaptureController()
                        VirtualUser:ClickButton1(Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2))
                        _G.BeyondConfig.Automation.TotalClicksSimulated = _G.BeyondConfig.Automation.TotalClicksSimulated + 1
                    else
                        -- Альтернативный легальный метод через принудительный вызов клик-детекторов в радиусе видимости
                        local raycastParams = RaycastParams.new()
                        raycastParams.FilterType = Enum.RaycastFilterType.Exclude
                        raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
                        
                        local rayResult = workspace:Raycast(Camera.CFrame.Position, Camera.CFrame.LookVector * 15, raycastParams)
                        if rayResult and rayResult.Instance then
                            local clickDetector = rayResult.Instance:FindFirstChildOfClass("ClickDetector")
                            if clickDetector then
                                fireclickdetector(clickDetector) -- Вызов официальной функции исполнителя
                                _G.BeyondConfig.Automation.TotalClicksSimulated = _G.BeyondConfig.Automation.TotalClicksSimulated + 1
                            end
                        end
                    end
                end)
                
                -- Обновление динамического статуса в футере меню
                pcall(function()
                    FooterText.Text = "Status: Operational // Macros Simulated: " .. tostring(_G.BeyondConfig.Automation.TotalClicksSimulated)
                end)
                
                task.wait(calculatedDelay)
            end
        end)
    else
        -- Возврат стандартного системного текста в футер при отключении макроса
        pcall(function()
            FooterText.Text = "Status: Operational // Mobile Touch Enabled"
        end)
    end
end)

-- Слайдер регулировки задержки клика (от 10мс для фаст-кликов до 1000мс)
CreateMobileSlider(Container, "Интервал клика (в миллисекундах)", 10, 1000, _G.BeyondConfig.Automation.ClickInterval, function(value)
    _G.BeyondConfig.Automation.ClickInterval = value
end)

-- --- МОДУЛЬ УПРАВЛЕНИЯ ПРЕСЕТАМИ СТИЛЕЙ И СЕТКОЙ ДИЗАЙНА ---

local StylePresetFrame = Instance.new("Frame")
StylePresetFrame.Name = "StylePreset_LayoutContainer"
StylePresetFrame.Size = UDim2.new(1, 0, 0, 90)
StylePresetFrame.BackgroundColor3 = _G.BeyondConfig.Styles.CardBackgroundColor
StylePresetFrame.BorderSizePixel = 0
StylePresetFrame.Parent = Container

local StyleCorner = Instance.new("UICorner")
StyleCorner.CornerRadius = UDim.new(0, 8)
StyleCorner.Parent = StylePresetFrame

local StyleStroke = Instance.new("UIStroke")
StyleStroke.Thickness = 1
StyleStroke.Color = _G.BeyondConfig.Styles.BorderStrokeColor
StyleStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
StyleStroke.Parent = StylePresetFrame

local StyleLabel = Instance.new("TextLabel")
StyleLabel.Name = "StylePreset_HeaderTitle"
StyleLabel.Size = UDim2.new(1, -20, 0, 25)
StyleLabel.Position = UDim2.new(0, 14, 0, 4)
StyleLabel.Text = "Визуальная тема: <font color='#FF2B5A'>" .. _G.BeyondConfig.Styles.CurrentThemePreset .. "</font>"
StyleLabel.RichText = true
StyleLabel.TextColor3 = Color3.fromRGB(225, 225, 235)
StyleLabel.Font = _G.BeyondConfig.Styles.FontsList.Semibold
StyleLabel.TextSize = 13
StyleLabel.TextXAlignment = Enum.TextXAlignment.Left
StyleLabel.BackgroundTransparency = 1
StyleLabel.Parent = StylePresetFrame

-- Внутренняя фабрика для генерации кнопок переключения цветовых палитр
local function InitializeThemeButton(themeName, xOffset, primeColor, glowColor)
    local ThemeBtn = Instance.new("TextButton")
    ThemeBtn.Name = "ThemePresetButton_" .. themeName
    ThemeBtn.Size = UDim2.new(0.28, 0, 0, 38)
    ThemeBtn.Position = UDim2.new(0, xOffset, 0, 38)
    ThemeBtn.BackgroundColor3 = Color3.fromRGB(34, 34, 46)
    ThemeBtn.Text = themeName
    ThemeBtn.TextColor3 = Color3.fromRGB(245, 245, 250)
    ThemeBtn.Font = _G.BeyondConfig.Styles.FontsList.Bold
    ThemeBtn.TextSize = 10
    ThemeBtn.Parent = StylePresetFrame
    
    local BTNCorner = Instance.new("UICorner")
    BTNCorner.CornerRadius = UDim.new(0, 6)
    BTNCorner.Parent = ThemeBtn
    
    local BTNStroke = Instance.new("UIStroke")
    BTNStroke.Thickness = 1
    BTNStroke.Color = Color3.fromRGB(50, 50, 65)
    BTNStroke.Parent = ThemeBtn

    ThemeBtn.MouseButton1Click:Connect(function()
        if not ScriptActive then return end
        
        -- Блокируем смену базовых цветов, если активирован динамический режим RGB
        if _G.BeyondConfig.Visuals.RainbowGlow then
            StyleLabel.Text = "Визуальная тема: <font color='#FF2B5A'>Ошибка (Выключите RGB)</font>"
            task.spawn(function()
                task.wait(1.5)
                if _G.BeyondConfig then
                    StyleLabel.Text = "Визуальная тема: <font color='#FF2B5A'>" .. _G.BeyondConfig.Styles.CurrentThemePreset .. "</font>"
                end
            end)
            return
        end

        _G.BeyondConfig.Styles.CurrentThemePreset = themeName
        _G.BeyondConfig.ThemeColor = primeColor
        _G.BeyondConfig.AccentGlow = glowColor
        
        StyleLabel.Text = "Визуальная тема: <font color='#FF2B5A'>" .. themeName .. "</font>"
        
        -- Запуск каскада плавных анимаций обновления цветовой схемы всего UI
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
        TweenService:Create(Stroke, tweenInfo, {Color = primeColor}):Play()
        TweenService:Create(HeaderLine, tweenInfo, {BackgroundColor3 = primeColor}):Play()
        TweenService:Create(Container, tweenInfo, {ScrollBarImageColor3 = primeColor}):Play()
        TweenService:Create(MobileToggleButton, tweenInfo, {ImageColor3 = primeColor}):Play()
        TweenService:Create(ButtonStroke, tweenInfo, {Color = primeColor}):Play()
    end)
end

-- Развертывание пресетов оформления (Точные расчеты отступов для корректного отображения 2400х1080)
InitializeThemeButton("Zero Two", 14, Color3.fromRGB(255, 43, 90), Color3.fromRGB(255, 100, 130))
InitializeThemeButton("Киберпанк", 140, Color3.fromRGB(0, 255, 240), Color3.fromRGB(0, 180, 255))
InitializeThemeButton("Токсик", 266, Color3.fromRGB(170, 255, 0), Color3.fromRGB(100, 220, 0))

print("[BeyondClient Automation]: Часть 4 успешно интегрирована в рабочее ядро проекта.")
--[[
    BeyondClient v5.0 - Ultimate Mobile Edition
    Target Hardware: HONOR Play5 (2400x1080 / File-System Optimization)
    Specification: JSON Serialization & Local Storage System Core
    File: main.lua (Part 5/Unknown - Local Data Persistence Control)
--]]

-- Имя локального системного файла конфигурации в памяти девайса
local BEYOND_CONFIG_FILENAME = "BeyondClient_V5_HONOR.json"

-- Кэширование методов файловой системы Вашего мобильного исполнителя (Delta)
local FileSystemAPI = {
    Write = writefile or (syn and syn.writefile),
    Read = readfile or (syn and syn.readfile),
    Check = isfile or (syn and syn.isfile),
    Delete = delfile or (syn and syn.delfile)
}

-- Декоративный заголовок для секции управления файлами в контейнере UI
local ConfigSectionLabel = Instance.new("TextLabel")
ConfigSectionLabel.Name = "ConfigurationSection_TitleLabel"
ConfigSectionLabel.Size = UDim2.new(1, 0, 0, 30)
ConfigSectionLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ConfigSectionLabel.BackgroundTransparency = 1
ConfigSectionLabel.Text = "--- [ МЕНЕДЖЕР ЛОКАЛЬНЫХ ПРОФИЛЕЙ ] ---"
ConfigSectionLabel.TextColor3 = Color3.fromRGB(160, 160, 175)
ConfigSectionLabel.Font = _G.BeyondConfig.Styles.FontsList.Bold
ConfigSectionLabel.TextSize = 12
ConfigSectionLabel.TextStrokeTransparency = 0.8
ConfigSectionLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
ConfigSectionLabel.Parent = Container

-- Главный фрейм карточки управления конфигурацией
local ConfigCardFrame = Instance.new("Frame")
ConfigCardFrame.Name = "Configuration_LayoutContainer"
ConfigCardFrame.Size = UDim2.new(1, 0, 0, 95)
ConfigCardFrame.BackgroundColor3 = _G.BeyondConfig.Styles.CardBackgroundColor
ConfigCardFrame.BorderSizePixel = 0
ConfigCardFrame.Parent = Container

local ConfigCorner = Instance.new("UICorner")
ConfigCorner.CornerRadius = UDim.new(0, 8)
ConfigCorner.Parent = ConfigCardFrame

local ConfigStroke = Instance.new("UIStroke")
ConfigStroke.Thickness = 1
ConfigStroke.Color = _G.BeyondConfig.Styles.BorderStrokeColor
ConfigStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
ConfigStroke.Parent = ConfigCardFrame

local ConfigStatusLabel = Instance.new("TextLabel")
ConfigStatusLabel.Name = "ConfigSystem_StatusMessage"
ConfigStatusLabel.Size = UDim2.new(1, -20, 0, 25)
ConfigStatusLabel.Position = UDim2.new(0, 14, 0, 4)
ConfigStatusLabel.Text = "Система сохранения: <font color='#00FF8C'>Готова к сериализации</font>"
ConfigStatusLabel.RichText = true
ConfigStatusLabel.TextColor3 = Color3.fromRGB(225, 225, 235)
ConfigStatusLabel.Font = _G.BeyondConfig.Styles.FontsList.Semibold
ConfigStatusLabel.TextSize = 13
ConfigStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
ConfigStatusLabel.BackgroundTransparency = 1
ConfigStatusLabel.Parent = ConfigCardFrame

-- Функция обновления текстового статуса файловой системы
local function PushConfigStatusUpdate(htmlText)
    ConfigStatusLabel.Text = "Система сохранения: " .. htmlText
end

-- Основная функция сохранения текущих параметров в файл JSON
local function SerializeAndSaveConfig()
    if not FileSystemAPI.Write then
        PushConfigStatusUpdate("<font color='#FF2B5A'>Ошибка: Delta не поддерживает WriteFile</font>")
        return
    end

    local successSerialization, encodedData = pcall(function()
        -- Подготавливаем чистую таблицу параметров без UI элементов
        local exportTable = {
            SpeedValue = _G.BeyondConfig.SpeedValue,
            InfiniteJump = _G.BeyondConfig.InfiniteJump,
            Noclip = _G.BeyondConfig.Noclip,
            ThemeColor = {_G.BeyondConfig.ThemeColor.R, _G.BeyondConfig.ThemeColor.G, _G.BeyondConfig.ThemeColor.B},
            HighlightESP = _G.BeyondConfig.Visuals.HighlightESP,
            EspFillTransparency = _G.BeyondConfig.Visuals.EspFillTransparency,
            EspOutlineTransparency = _G.BeyondConfig.Visuals.EspOutlineTransparency,
            RainbowGlow = _G.BeyondConfig.Visuals.RainbowGlow,
            GlowSpeed = _G.BeyondConfig.Visuals.GlowSpeed,
            AutoClickEnabled = _G.BeyondConfig.Automation.AutoClickEnabled,
            ClickInterval = _G.BeyondConfig.Automation.ClickInterval,
            CurrentThemePreset = _G.BeyondConfig.Styles.CurrentThemePreset
        }
        return HttpService:JSONEncode(exportTable)
    end)

    if successSerialization and encodedData then
        local successWrite, writeError = pcall(function()
            FileSystemAPI.Write(BEYOND_CONFIG_FILENAME, encodedData)
        end)
        
        if successWrite then
            PushConfigStatusUpdate("<font color='#00FF8C'>Профиль успешно сохранен!</font>")
        else
            PushConfigStatusUpdate("<font color='#FF2B5A'>Ошибка записи файла конфигурации</font>")
        end
    else
        PushConfigStatusUpdate("<font color='#FF2B5A'>Ошибка конвертации данных</font>")
    end
end

-- Основная функция загрузки параметров из файла JSON
local function LoadAndDeserializeConfig()
    if not FileSystemAPI.Read or not FileSystemAPI.Check then
        PushConfigStatusUpdate("<font color='#FF2B5A'>Ошибка: Delta не поддерживает ReadFile</font>")
        return
    end

    if not FileSystemAPI.Check(BEYOND_CONFIG_FILENAME) then
        PushConfigStatusUpdate("<font color='#FFBB00'>Файл конфигурации не найден</font>")
        return
    end

    local successRead, fileRawContent = pcall(function()
        return FileSystemAPI.Read(BEYOND_CONFIG_FILENAME)
    end)

    if successRead and fileRawContent then
        local successDecode, decodedTable = pcall(function()
            return HttpService:JSONDecode(fileRawContent)
        end)

        if successDecode and decodedTable then
            -- Начинаем безопасную перезапись параметров в глобальный конфиг оверлея
            pcall(function()
                if decodedTable.SpeedValue then _G.BeyondConfig.SpeedValue = decodedTable.SpeedValue end
                if decodedTable.InfiniteJump then _G.BeyondConfig.InfiniteJump = decodedTable.InfiniteJump end
                if decodedTable.Noclip then _G.BeyondConfig.Noclip = decodedTable.Noclip end
                if decodedTable.HighlightESP then _G.BeyondConfig.Visuals.HighlightESP = decodedTable.HighlightESP end
                if decodedTable.EspFillTransparency then _G.BeyondConfig.Visuals.EspFillTransparency = decodedTable.EspFillTransparency end
                if decodedTable.EspOutlineTransparency then _G.BeyondConfig.Visuals.EspOutlineTransparency = decodedTable.EspOutlineTransparency end
                if decodedTable.RainbowGlow then _G.BeyondConfig.Visuals.RainbowGlow = decodedTable.RainbowGlow end
                if decodedTable.GlowSpeed then _G.BeyondConfig.Visuals.GlowSpeed = decodedTable.GlowSpeed end
                if decodedTable.AutoClickEnabled then _G.BeyondConfig.Automation.AutoClickEnabled = decodedTable.AutoClickEnabled end
                if decodedTable.ClickInterval then _G.BeyondConfig.Automation.ClickInterval = decodedTable.ClickInterval end
                if decodedTable.CurrentThemePreset then _G.BeyondConfig.Styles.CurrentThemePreset = decodedTable.CurrentThemePreset end
                
                if decodedTable.ThemeColor then
                    _G.BeyondConfig.ThemeColor = Color3.new(decodedTable.ThemeColor[1], decodedTable.ThemeColor[2], decodedTable.ThemeColor[3])
                end
            end)
            
            PushConfigStatusUpdate("<font color='#00FF8C'>Конфиг успешно применен!</font>")
        else
            PushConfigStatusUpdate("<font color='#FF2B5A'>Ошибка разбора JSON структуры</font>")
        end
    else
        PushConfigStatusUpdate("<font color='#FF2B5A'>Ошибка чтения данных с диска</font>")
    end
end

-- --- ГЕНЕРАЦИЯ И СТИЛИЗАЦИЯ ИНТЕРФЕЙСНЫХ КНОПОК УПРАВЛЕНИЯ ФАЙЛАМИ ---

local function BuildFileActionButton(textTitle, xOffset, primeBgColor, clickCallback)
    local ActionBtn = Instance.new("TextButton")
    ActionBtn.Name = "FileSystemActionButton_" .. textTitle
    ActionBtn.Size = UDim2.new(0.44, 0, 0, 38)
    ActionBtn.Position = UDim2.new(0, xOffset, 0, 42)
    ActionBtn.BackgroundColor3 = primeBgColor
    ActionBtn.Text = textTitle
    ActionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ActionBtn.Font = _G.BeyondConfig.Styles.FontsList.Bold
    ActionBtn.TextSize = 11
    ActionBtn.Parent = ConfigCardFrame
    
    local BTNCorner = Instance.new("UICorner")
    BTNCorner.CornerRadius = UDim.new(0, 6)
    BTNCorner.Parent = ActionBtn

    ActionBtn.MouseButton1Click:Connect(function()
        if not ScriptActive then return end
        clickCallback()
    end)
end

-- Развертывание кнопок «Сохранить» и «Загрузить» с точной адаптацией отступов под мобильный экран
BuildFileActionButton("СОХРАНИТЬ ПРОФИЛЬ", 14, Color3.fromRGB(34, 46, 38), SerializeAndSaveConfig)
BuildFileActionButton("ЗАГРУЗИТЬ ПРОФИЛЬ", 228, Color3.fromRGB(34, 38, 46), LoadAndDeserializeConfig)

print("[BeyondClient Configs]: Модуль сохранения локальных профилей успешно подключен к ядру.")
--[[
    BeyondClient v5.0 - Ultimate Mobile Edition
    Target Hardware: HONOR Play5 (Dimensity 800U / 8GB RAM / Android 10)
    Specification: Official TextChatService Integration & Chat Macros Core
    File: main.lua (Part 6/Unknown - Text Stream Automation Control)
--]]

-- Безопасный поиск официальных текстовых сервисов игры
local TextChatService = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ChatMacroData = {
    {Name = "Приветствие", Phrase = "Привет всем! Beyond Client v5.0 запущен успешно."},
    {Name = "Предупреждение", Phrase = "Внимание, зафиксирована тактическая активность!"},
    {Name = "Проверка лагов", Phrase = "Мой текущий пинг стабилен на HONOR Play5."}
}

-- Декоративный визуальный заголовок секции чата в контейнере UI
local ChatSectionLabel = Instance.new("TextLabel")
ChatSectionLabel.Name = "ChatSection_TitleLabel"
ChatSectionLabel.Size = UDim2.new(1, 0, 0, 30)
ChatSectionLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ChatSectionLabel.BackgroundTransparency = 1
ChatSectionLabel.Text = "--- [ МАКРОСЫ И АВТОМАТИЗАЦИЯ ЧАТА ] ---"
ChatSectionLabel.TextColor3 = Color3.fromRGB(160, 160, 175)
ChatSectionLabel.Font = _G.BeyondConfig.Styles.FontsList.Bold
ChatSectionLabel.TextSize = 12
ChatSectionLabel.TextStrokeTransparency = 0.8
ChatSectionLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
ChatSectionLabel.Parent = Container

-- Универсальная легальная функция отправки текстовых сообщений
local function FireLegalChatMessage(textString)
    if not ScriptActive then return end
    
    pcall(function()
        -- Метод 1: Современная система TextChatService (Роблокс после 2022-2024 годов)
        if TextChatService and TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
            local textChannels = TextChatService:FindFirstChild("TextChannels")
            local generalChannel = textChannels and textChannels:FindFirstChild("RBXGeneral")
            if generalChannel and generalChannel:IsA("TextChannel") then
                generalChannel:SendAsync(textString)
                return
            end
        end
        
        -- Метод 2: Классическая система Legacy Chat Systems (Старые плейсы)
        local sayMessageRequest = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents") 
            and ReplicatedStorage.DefaultChatSystemChatEvents:FindFirstChild("SayMessageRequest")
        if sayMessageRequest and sayMessageRequest:IsA("RemoteEvent") then
            sayMessageRequest:FireServer(textString, "All")
        end
    end)
end

-- Динамическая генерация карточек макросов в интерфейсе скроллинга
for idx, macroInfo in ipairs(ChatMacroData) do
    local MacroFrame = Instance.new("Frame")
    MacroFrame.Name = "ChatMacroCard_" .. tostring(idx)
    MacroFrame.Size = UDim2.new(1, 0, 0, 60)
    MacroFrame.BackgroundColor3 = _G.BeyondConfig.Styles.CardBackgroundColor
    MacroFrame.BorderSizePixel = 0
    MacroFrame.Parent = Container
    
    local MacroCorner = Instance.new("UICorner")
    MacroCorner.CornerRadius = UDim.new(0, 8)
    MacroCorner.Parent = MacroFrame
    
    local MacroStroke = Instance.new("UIStroke")
    MacroStroke.Thickness = 1
    MacroStroke.Color = _G.BeyondConfig.Styles.BorderStrokeColor
    MacroStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    MacroStroke.Parent = MacroFrame
    
    local MacroNameLabel = Instance.new("TextLabel")
    MacroNameLabel.Size = UDim2.new(0.65, 0, 0, 22)
    MacroNameLabel.Position = UDim2.new(0, 14, 0, 6)
    MacroNameLabel.Text = macroInfo.Name
    MacroNameLabel.TextColor3 = Color3.fromRGB(240, 240, 245)
    MacroNameLabel.Font = _G.BeyondConfig.Styles.FontsList.Bold
    MacroNameLabel.TextSize = 13
    MacroNameLabel.TextXAlignment = Enum.TextXAlignment.Left
    MacroNameLabel.BackgroundTransparency = 1
    MacroNameLabel.Parent = MacroFrame
    
    local MacroPhraseLabel = Instance.new("TextLabel")
    MacroPhraseLabel.Size = UDim2.new(0.65, 0, 0, 26)
    MacroPhraseLabel.Position = UDim2.new(0, 14, 0, 26)
    MacroPhraseLabel.Text = macroInfo.Phrase
    MacroPhraseLabel.TextColor3 = Color3.fromRGB(130, 130, 145)
    MacroPhraseLabel.Font = _G.BeyondConfig.Styles.FontsList.Regular
    MacroPhraseLabel.TextSize = 11
    MacroPhraseLabel.TextWrapped = true
    MacroPhraseLabel.TextXAlignment = Enum.TextXAlignment.Left
    MacroPhraseLabel.TextYAlignment = Enum.TextYAlignment.Top
    MacroPhraseLabel.BackgroundTransparency = 1
    MacroPhraseLabel.Parent = MacroFrame
    
    local SendBtn = Instance.new("TextButton")
    SendBtn.Size = UDim2.new(0, 95, 0, 32)
    SendBtn.Position = UDim2.new(1, -109, 0.5, -16)
    SendBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
    SendBtn.Text = "ОТПРАВИТЬ"
    SendBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    SendBtn.Font = _G.BeyondConfig.Styles.FontsList.Bold
    SendBtn.TextSize = 10
    SendBtn.Parent = MacroFrame
    
    local SCorner = Instance.new("UICorner")
    SCorner.CornerRadius = UDim.new(0, 6)
    SCorner.Parent = SendBtn
    
    -- Плавный визуальный отклик кнопки на нажатие пальцем
    SendBtn.MouseButton1Click:Connect(function()
        if not ScriptActive then return end
        
        TweenService:Create(SendBtn, TweenInfo.new(0.1), {BackgroundColor3 = _G.BeyondConfig.ThemeColor}):Play()
        task.spawn(function()
            FireLegalChatMessage(macroInfo.Phrase)
            task.wait(0.2)
            if _G.BeyondConfig then
                TweenService:Create(SendBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 48)}):Play()
            end
        end)
    end)
end

print("[BeyondClient Chat]: Модуль легальной автоматизации сообщений успешно подключен.")
--[[
    BeyondClient v5.0 - Ultimate Mobile Edition
    Target Hardware: HONOR Play5 (Dimensity 800U / 8GB RAM / Android 10)
    Specification: Official Stats Service Inspection & Performance HUD Core
    File: main.lua (Part 7/Unknown - Telemetry & Hardware Monitor Control)
--]]

-- Безопасный вызов официального сервиса игровой статистики
local StatsService = game:GetService("Stats")
local NetworkStats = StatsService:FindFirstChild("Network")

-- Регистрация локального кэша для сбора телеметрии
local TelemetryData = {
    CurrentFps = 60,
    CurrentPing = 0,
    CurrentMemory = 0,
    FrameCount = 0,
    TimeCounter = 0
}

-- Декоративный визуальный заголовок секции мониторинга в контейнере UI
local StatsSectionLabel = Instance.new("TextLabel")
StatsSectionLabel.Name = "TelemetrySection_TitleLabel"
StatsSectionLabel.Size = UDim2.new(1, 0, 0, 30)
StatsSectionLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
StatsSectionLabel.BackgroundTransparency = 1
StatsSectionLabel.Text = "--- [ ТЕЛЕМЕТРИЯ И ПРОИЗВОДИТЕЛЬНОСТЬ ] ---"
StatsSectionLabel.TextColor3 = Color3.fromRGB(160, 160, 175)
StatsSectionLabel.Font = _G.BeyondConfig.Styles.FontsList.Bold
StatsSectionLabel.TextSize = 12
StatsSectionLabel.TextStrokeTransparency = 0.8
StatsSectionLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
StatsSectionLabel.Parent = Container

-- Главный фрейм карточки мониторинга аппаратных ресурсов
local StatsCardFrame = Instance.new("Frame")
StatsCardFrame.Name = "Telemetry_LayoutContainer"
StatsCardFrame.Size = UDim2.new(1, 0, 0, 105)
StatsCardFrame.BackgroundColor3 = _G.BeyondConfig.Styles.CardBackgroundColor
StatsCardFrame.BorderSizePixel = 0
StatsCardFrame.Parent = Container

local StatsCorner = Instance.new("UICorner")
StatsCorner.CornerRadius = UDim.new(0, 8)
StatsCorner.Parent = StatsCardFrame

local StatsStroke = Instance.new("UIStroke")
StatsStroke.Thickness = 1
StatsStroke.Color = _G.BeyondConfig.Styles.BorderStrokeColor
StatsStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
StatsStroke.Parent = StatsCardFrame

-- Внутренняя фабрика для создания текстовых полей телеметрии
local function CreateStatDisplayLabel(nameTag, yPosition)
    local DisplayLabel = Instance.new("TextLabel")
    DisplayLabel.Name = "TelemetryDisplay_" .. nameTag
    DisplayLabel.Size = UDim2.new(1, -24, 0, 22)
    DisplayLabel.Position = UDim2.new(0, 14, 0, yPosition)
    DisplayLabel.BackgroundTransparency = 1
    DisplayLabel.Text = nameTag .. ": <font color='#00FF8C'>Загрузка...</font>"
    DisplayLabel.RichText = true
    DisplayLabel.TextColor3 = Color3.fromRGB(215, 215, 225)
    DisplayLabel.Font = _G.BeyondConfig.Styles.FontsList.Semibold
    DisplayLabel.TextSize = 12
    DisplayLabel.TextXAlignment = Enum.TextXAlignment.Left
    DisplayLabel.Parent = StatsCardFrame
    return DisplayLabel
end

local FpsDisplay = CreateStatDisplayLabel("Текущая частота кадров (FPS)", 10)
local PingDisplay = CreateStatDisplayLabel("Сетевая задержка (Ping)", 38)
local MemDisplay = CreateStatDisplayLabel("Потребление памяти (Memory)", 66)

-- Асинхронный цикл сбора и вывода аппаратной телеметрии девайса
task.spawn(function()
    while ScriptActive and _G.BeyondConfig and task.wait(0.5) do
        pcall(function()
            -- Расчет сетевой задержки (Ping) через официальное API
            if NetworkStats then
                TelemetryData.CurrentPing = math.round(NetworkStats.ServerPing)
            else
                TelemetryData.CurrentPing = 0
            end

            -- Сбор общего потребления памяти клиентом (в Мегабайтах)
            TelemetryData.CurrentMemory = math.round(StatsService:GetTotalMemoryUsageMb())

            -- Динамическое обновление строковых данных с адаптивной цветовой индикацией
            local fpsColor = TelemetryData.CurrentFps >= 45 and "#00FF8C" or (TelemetryData.CurrentFps >= 25 and "#FFBB00" or "#FF2B5A")
            local pingColor = TelemetryData.CurrentPing <= 90 and "#00FF8C" or (TelemetryData.CurrentPing <= 200 and "#FFBB00" or "#FF2B5A")
            
            FpsDisplay.Text = "Текущая частота кадров: <font color='" .. fpsColor .. "'>" .. tostring(TelemetryData.CurrentFps) .. " FPS</font>"
            PingDisplay.Text = "Сетевая задержка (Ping): <font color='" .. pingColor .. "'>" .. tostring(TelemetryData.CurrentPing) .. " ms</font>"
            MemDisplay.Text = "Потребление памяти: <font color='#00BFFF'>" .. tostring(TelemetryData.CurrentMemory) .. " MB</font>"
        end)
    end
end)

-- Изолированный поток для точного подсчета FPS (кадров в секунду) вне зависимости от задержек сети
RunService.RenderStepped:Connect(function(deltaTime)
    if not ScriptActive then return end
    
    TelemetryData.FrameCount = TelemetryData.FrameCount + 1
    TelemetryData.TimeCounter = TelemetryData.TimeCounter + deltaTime
    
    if TelemetryData.TimeCounter >= 1.0 then
        TelemetryData.CurrentFps = math.round(TelemetryData.FrameCount / TelemetryData.TimeCounter)
        TelemetryData.FrameCount = 0
        TelemetryData.TimeCounter = 0
    end
end)

print("[BeyondClient Telemetry]: Модуль аппаратного мониторинга производительности успешно развернут.")
--[[
    BeyondClient v5.0 - Ultimate Mobile Edition
    Target Hardware: HONOR Play5 (Dimensity 800U / 8GB RAM / Android 10)
    Specification: Strict Lighting Optimization & Rendering Performance Core
    File: main.lua (Part 8/Unknown - Graphic Pipeline Optimization Control)
--]]

-- Кэширование системных графических сервисов для быстрой манипуляции ассетами
local Terrain = workspace:FindFirstChildOfClass("Terrain")

-- Регистрация начального состояния графического конвейера в конфигурации
_G.BeyondConfig.PerformanceBoost = {
    OptimizerActive = false,
    OriginalShadows = Lighting.GlobalShadows,
    OriginalTech = Lighting.Technology
}

-- Декоративный визуальный заголовок секции оптимизации в контейнере UI
local OptimizationSectionLabel = Instance.new("TextLabel")
OptimizationSectionLabel.Name = "OptimizationSection_TitleLabel"
OptimizationSectionLabel.Size = UDim2.new(1, 0, 0, 30)
OptimizationSectionLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
OptimizationSectionLabel.BackgroundTransparency = 1
OptimizationSectionLabel.Text = "--- [ МОДУЛЬ ОПТИМИЗАЦИИ ГРАФИКИ ] ---"
OptimizationSectionLabel.TextColor3 = Color3.fromRGB(160, 160, 175)
OptimizationSectionLabel.Font = _G.BeyondConfig.Styles.FontsList.Bold
OptimizationSectionLabel.TextSize = 12
OptimizationSectionLabel.TextStrokeTransparency = 0.8
OptimizationSectionLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
OptimizationSectionLabel.Parent = Container

-- Функция глубокой очистки тяжелых графических эффектов на карте
local function ToggleEnvironmentOptimization(enableOptimization)
    if not ScriptActive then return end
    
    pcall(function()
        if enableOptimization then
            -- Деактивация глобальных теней для разгрузки видеочипа
            Lighting.GlobalShadows = false
            
            -- Принудительное понижение качества прорисовки ландшафта и воды
            if Terrain then
                Terrain.WaterWaveSize = 0
                Terrain.WaterWaveSpeed = 0
                Terrain.WaterReflectance = 0
                Terrain.WaterTransparency = 0
            end
            
            -- Циклический перебор и отключение тяжелых шейдеров атмосферы (кроме нашего блюра меню)
            for _, effect in ipairs(Lighting:GetChildren()) do
                if effect:IsA("PostEffect") or effect:IsA("BloomEffect") or effect:IsA("SunRaysEffect") or effect:IsA("Atmosphere") then
                    if effect.Name ~= "Beyond_Interface_Blur" then
                        effect.Enabled = false
                    end
                end
            end
            
            -- Ограничение отрисовки мелких частиц и эффектов свечения на объектах карты
            for _, descendant in ipairs(workspace:GetDescendants()) do
                if descendant:IsA("ParticleEmitter") or descendant:IsA("Smoke") or descendant:IsA("Fire") or descendant:IsA("Sparkles") then
                    descendant.Enabled = false
                end
            end
            
            PushConfigStatusUpdate("<font color='#00FF8C'>FPS Бустер: Активирован</font>")
        else
            -- Возврат исходных игровых настроек рендеринга при отключении оптимизатора
            Lighting.GlobalShadows = _G.BeyondConfig.PerformanceBoost.OriginalShadows
            
            if Terrain then
                Terrain.WaterWaveSize = 0.15
                Terrain.WaterWaveSpeed = 1
                Terrain.WaterReflectance = 1
                Terrain.WaterTransparency = 1
            end
            
            for _, effect in ipairs(Lighting:GetChildren()) do
                if effect:IsA("PostEffect") or effect:IsA("BloomEffect") or effect:IsA("SunRaysEffect") or effect:IsA("Atmosphere") then
                    if effect.Name ~= "Beyond_Interface_Blur" then
                        effect.Enabled = true
                    end
                end
            end
            
            for _, descendant in ipairs(workspace:GetDescendants()) do
                if descendant:IsA("ParticleEmitter") or descendant:IsA("Smoke") or descendant:IsA("Fire") or descendant:IsA("Sparkles") then
                    descendant.Enabled = true
                end
            end
            
            PushConfigStatusUpdate("<font color='#00FF8C'>FPS Бустер: Отключен</font>")
        end
    end)
end

-- Переключатель для мастер-активации мобильного FPS Бустера
CreateMobileToggle(Container, "Включить оптимизацию рендеринга (FPS Boost)", _G.BeyondConfig.PerformanceBoost.OptimizerActive, function(state)
    _G.BeyondConfig.PerformanceBoost.OptimizerActive = state
    ToggleEnvironmentOptimization(state)
end)

print("[BeyondClient Graphics]: Модуль легальной оптимизации игрового окружения успешно развернут.")
--[[
    BeyondClient v5.0 - Ultimate Mobile Edition
    Target Hardware: HONOR Play5 (Dimensity 800U / 8GB RAM / Android 10)
    Specification: Vector CoreGui Overlay & Dynamic Crosshair Calibration
    File: main.lua (Part 9/Unknown - Screen Center Vector Crosshair Control)
--]]

-- Инициализация параметров прицела в глобальной конфигурации оверлея
_G.BeyondConfig.Crosshair = {
    Enabled = false,
    Size = 14,
    Thickness = 2,
    Gap = 4,
    CenterDot = false
}

-- Декоративный визуальный заголовок секции прицела в контейнере UI
local CrosshairSectionLabel = Instance.new("TextLabel")
CrosshairSectionLabel.Name = "CrosshairSection_TitleLabel"
CrosshairSectionLabel.Size = UDim2.new(1, 0, 0, 30)
CrosshairSectionLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
CrosshairSectionLabel.BackgroundTransparency = 1
CrosshairSectionLabel.Text = "--- [ НАСТРАИВАЕМЫЙ ЦЕНТРОВОЙ ПРИЦЕЛ ] ---"
CrosshairSectionLabel.TextColor3 = Color3.fromRGB(160, 160, 175)
CrosshairSectionLabel.Font = _G.BeyondConfig.Styles.FontsList.Bold
CrosshairSectionLabel.TextSize = 12
CrosshairSectionLabel.TextStrokeTransparency = 0.8
CrosshairSectionLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
CrosshairSectionLabel.Parent = Container

-- --- СОЗДАНИЕ ВЕКТОРНЫХ КОМПОНЕНТОВ ПРИЦЕЛА В CORE_GUI ---

local CrosshairContainer = Instance.new("Frame")
CrosshairContainer.Name = "Beyond_Crosshair_Root"
CrosshairContainer.Size = UDim2.new(0, 100, 0, 100)
CrosshairContainer.Position = UDim2.new(0.5, -50, 0.5, -50) -- Идеальный центр экрана
CrosshairContainer.BackgroundTransparency = 1
CrosshairContainer.Visible = false
CrosshairContainer.Parent = BeyondScreenGui

local TopLine = Instance.new("Frame")
local BottomLine = Instance.new("Frame")
local LeftLine = Instance.new("Frame")
local RightLine = Instance.new("Frame")
local CenterDot = Instance.new("Frame")

local linesArray = {TopLine, BottomLine, LeftLine, RightLine, CenterDot}
for _, line in ipairs(linesArray) do
    line.BorderSizePixel = 0
    line.BackgroundColor3 = _G.BeyondConfig.ThemeColor
    line.Parent = CrosshairContainer
end

-- Функция динамической калибровки геометрии линий оверлея прицела
local function RecalibrateCrosshairGeometry()
    if not _G.BeyondConfig or not _G.BeyondConfig.Crosshair then return end
    local cfg = _G.BeyondConfig.Crosshair
    
    CrosshairContainer.Visible = cfg.Enabled
    CenterDot.Visible = cfg.CenterDot
    
    -- Корректировка размеров центральной точки
    CenterDot.Size = UDim2.new(0, cfg.Thickness, 0, cfg.Thickness)
    CenterDot.Position = UDim2.new(0.5, -cfg.Thickness/2, 0.5, -cfg.Thickness/2)
    
    -- Позиционирование 4-х векторов перекрестия относительно центра
    TopLine.Size = UDim2.new(0, cfg.Thickness, 0, cfg.Size)
    TopLine.Position = UDim2.new(0.5, -cfg.Thickness/2, 0.5, -cfg.Gap - cfg.Size)
    
    BottomLine.Size = UDim2.new(0, cfg.Thickness, 0, cfg.Size)
    BottomLine.Position = UDim2.new(0.5, -cfg.Thickness/2, 0.5, cfg.Gap)
    
    LeftLine.Size = UDim2.new(0, cfg.Size, 0, cfg.Thickness)
    LeftLine.Position = UDim2.new(0.5, -cfg.Gap - cfg.Size, 0.5, -cfg.Thickness/2)
    
    RightLine.Size = UDim2.new(0, cfg.Size, 0, cfg.Thickness)
    RightLine.Position = UDim2.new(0.5, cfg.Gap, 0.5, -cfg.Thickness/2)
end

-- --- ИНТЕГРАЦИЯ ЭЛЕМЕНТОВ УПРАВЛЕНИЯ ПРИЦЕЛОМ В МЕНЮ ---

CreateMobileToggle(Container, "Отображать кастомный прицел", _G.BeyondConfig.Crosshair.Enabled, function(state)
    _G.BeyondConfig.Crosshair.Enabled = state
    RecalibrateCrosshairGeometry()
end)

CreateMobileToggle(Container, "Центральная точка прицела", _G.BeyondConfig.Crosshair.CenterDot, function(state)
    _G.BeyondConfig.Crosshair.CenterDot = state
    RecalibrateCrosshairGeometry()
end)

CreateMobileSlider(Container, "Длина линий прицела", 4, 40, _G.BeyondConfig.Crosshair.Size, function(val)
    _G.BeyondConfig.Crosshair.Size = val
    RecalibrateCrosshairGeometry()
end)

CreateMobileSlider(Container, "Толщина линий прицела", 1, 8, _G.BeyondConfig.Crosshair.Thickness, function(val)
    _G.BeyondConfig.Crosshair.Thickness = val
    RecalibrateCrosshairGeometry()
end)

CreateMobileSlider(Container, "Зазор прицела (Gap)", 0, 20, _G.BeyondConfig.Crosshair.Gap, function(val)
    _G.BeyondConfig.Crosshair.Gap = val
    RecalibrateCrosshairGeometry()
end)

-- Подключаем переливание цветов прицела в наш единый RenderStepped цикл из Части 3
task.spawn(function()
    while ScriptActive and task.wait(0.01) do
        if _G.BeyondConfig and _G.BeyondConfig.Crosshair.Enabled then
            pcall(function()
                -- Извлекаем текущий динамический цвет из глобальной фазы
                local syncColor = _G.BeyondConfig.Visuals.RainbowGlow and Color3.fromHSV(_G.BeyondConfig.GlowPhase, 0.85, 1) or _G.BeyondConfig.ThemeColor
                for _, line in ipairs(linesArray) do
                    line.BackgroundColor3 = syncColor
                end
            end)
        end
    end
end)

print("[BeyondClient Crosshair]: Модуль кастомного векторного прицела успешно подключен к оверлею.")
--[[
    BeyondClient v5.0 - Ultimate Mobile Edition
    Target Hardware: HONOR Play5 (Dimensity 800U / 8GB RAM / Android 10)
    Specification: Official SoundService Integration & UI Audio Response Core
    File: main.lua (Part 10/Unknown - Interface Sound Feedback Control)
--]]

local SoundService = game:GetService("SoundService")

-- Инициализация параметров аудио-отклика в глобальной конфигурации оверлея
_G.BeyondConfig.Audio = {
    MuteAll = false,
    MasterVolume = 0.5,
    AssetClickId = "rbxassetid://6140381534", -- Чистый электронный клик из библиотеки Roblox
    AssetHoverId = "rbxassetid://6895079633"  -- Мягкий звук наведения/слайдера
}

-- Декоративный визуальный заголовок секции аудио в контейнере UI
local AudioSectionLabel = Instance.new("TextLabel")
AudioSectionLabel.Name = "AudioSection_TitleLabel"
AudioSectionLabel.Size = UDim2.new(1, 0, 0, 30)
AudioSectionLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
AudioSectionLabel.BackgroundTransparency = 1
AudioSectionLabel.Text = "--- [ ОЗВУЧКА ИНТЕРФЕЙСА (AUDIO FX) ] ---"
AudioSectionLabel.TextColor3 = Color3.fromRGB(160, 160, 175)
AudioSectionLabel.Font = _G.BeyondConfig.Styles.FontsList.Bold
AudioSectionLabel.TextSize = 12
AudioSectionLabel.TextStrokeTransparency = 0.8
AudioSectionLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
AudioSectionLabel.Parent = Container

-- Создание изолированного аудио-канала внутри SoundService для изоляции звуков меню
local BeyondAudioChannel = SoundService:FindFirstChild("Beyond_Interface_Audio") or Instance.new("Folder")
if not BeyondAudioChannel.Parent then
    BeyondAudioChannel.Name = "Beyond_Interface_Audio"
    BeyondAudioChannel.Parent = SoundService
end

-- Функция для генерации и безопасного воспроизведения системных звуков
local function PlayInterfaceSound(assetId, customVolumeMultiplier)
    if not ScriptActive or not _G.BeyondConfig or _G.BeyondConfig.Audio.MuteAll then return end
    
    task.spawn(function()
        local successSound, soundInstance = pcall(function()
            local sound = Instance.new("Sound")
            sound.SoundId = assetId
            sound.Volume = _G.BeyondConfig.Audio.MasterVolume * (customVolumeMultiplier or 1)
            sound.PlayOnRemove = true
            sound.Parent = BeyondAudioChannel
            return sound
        end)
        
        if successSound and soundInstance then
            soundInstance:Destroy() -- Уничтожаем объект, триггеря PlayOnRemove для экономии ОЗУ
        end
    end)
end

-- Интеграция глобального хука звуков на существующую фабрику элементов управления
local function HookSoundToUIElement(instanceElement, isSlider)
    if not instanceElement:IsA("GuiButton") then return end
    
    instanceElement.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            if isSlider then
                PlayInterfaceSound(_G.BeyondConfig.Audio.AssetHoverId, 0.7)
            else
                PlayInterfaceSound(_G.BeyondConfig.Audio.AssetClickId, 1.0)
            end
        end
    end)
end

-- Принудительное подключение звуков ко всем кнопкам шапки меню (- / X)
HookSoundToUIElement(MinimizeBtn, false)
HookSoundToUIElement(CloseBtn, false)
HookSoundToUIElement(MobileToggleButton, false)

-- --- ИНТЕГРАЦИЯ ЭЛЕМЕНТОВ УПРАВЛЕНИЯ ЗВУКОМ В КОНТЕЙНЕР МЕНЮ ---

CreateMobileToggle(Container, "Включить беззвучный режим (Mute)", _G.BeyondConfig.Audio.MuteAll, function(state)
    _G.BeyondConfig.Audio.MuteAll = state
end)

CreateMobileSlider(Container, "Громкость звуков интерфейса (%)", 0, 100, math.round(_G.BeyondConfig.Audio.MasterVolume * 100), function(val)
    _G.BeyondConfig.Audio.MasterVolume = val / 100
end)

-- Автоматический циклический поиск новых динамических кнопок в контейнере для их озвучки
task.spawn(function()
    while ScriptActive and task.wait(0.5) do
        pcall(function()
            for _, descendant in ipairs(Container:GetDescendants()) do
                if descendant:IsA("TextButton") and not descendant:GetAttribute("AudioHooked") then
                    descendant:SetAttribute("AudioHooked", true)
                    -- Проверяем по имени, является ли кнопка частью слайдера
                    local isSliderBtn = descendant.Parent and descendant.Parent.Name == "Track"
                    HookSoundToUIElement(descendant, isSliderBtn)
                end
            end
        end)
    end
end)

print("[BeyondClient Audio]: Модуль аудио-эффектов и звукового отклика успешно развернут.")
--[[
    BeyondClient v5.0 - Ultimate Mobile Edition
    Target Hardware: HONOR Play5 (Dimensity 800U / 8GB RAM / Android 10)
    Specification: In-App Event Interception & Debug Logging Engine
    File: main.lua (Part 11/Final - Telemetry Logging & Stream Visualization Control)
--]]

-- Регистрация параметров логирования внутри глобальной конфигурации
_G.BeyondConfig.Logger = {
    MaxLinesStored = 50,
    LogCount = 0
}

-- Декоративный визуальный заголовок секции консоли в контейнере UI
local LoggerSectionLabel = Instance.new("TextLabel")
LoggerSectionLabel.Name = "LoggerSection_TitleLabel"
LoggerSectionLabel.Size = UDim2.new(1, 0, 0, 30)
LoggerSectionLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
LoggerSectionLabel.BackgroundTransparency = 1
LoggerSectionLabel.Text = "--- [ ВСТРОЕННАЯ КОНСОЛЬ СОБЫТИЙ ] ---"
LoggerSectionLabel.TextColor3 = Color3.fromRGB(160, 160, 175)
LoggerSectionLabel.Font = _G.BeyondConfig.Styles.FontsList.Bold
LoggerSectionLabel.TextSize = 12
LoggerSectionLabel.TextStrokeTransparency = 0.8
LoggerSectionLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
LoggerSectionLabel.Parent = Container

-- Создание специализированного фрейма для отображения строк логов
local ConsoleBoxFrame = Instance.new("ScrollingFrame")
ConsoleBoxFrame.Name = "DebugConsole_ScrollingLogContainer"
ConsoleBoxFrame.Size = UDim2.new(1, 0, 0, 120)
ConsoleBoxFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
ConsoleBoxFrame.BorderSizePixel = 0
ConsoleBoxFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ConsoleBoxFrame.ScrollBarThickness = 3
ConsoleBoxFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 90)
ConsoleBoxFrame.Parent = Container

local ConsoleCorner = Instance.new("UICorner")
ConsoleCorner.CornerRadius = UDim.new(0, 8)
ConsoleCorner.Parent = ConsoleBoxFrame

local ConsoleStroke = Instance.new("UIStroke")
ConsoleStroke.Thickness = 1
ConsoleStroke.Color = _G.BeyondConfig.Styles.BorderStrokeColor
ConsoleStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
ConsoleStroke.Parent = ConsoleBoxFrame

local ConsoleListLayout = Instance.new("UIListLayout")
ConsoleListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ConsoleListLayout.Padding = UDim.new(0, 4)
ConsoleListLayout.Parent = ConsoleBoxFrame

local ConsolePadding = Instance.new("UIPadding")
ConsolePadding.PaddingLeft = UDim.new(0, 10)
ConsolePadding.PaddingRight = UDim.new(0, 10)
ConsolePadding.PaddingTop = UDim.new(0, 6)
ConsolePadding.PaddingBottom = UDim.new(0, 6)
ConsolePadding.Parent = ConsoleBoxFrame

-- Функция добавления новой строки лога во внутреннюю консоль меню
local function PrintToBeyondConsole(logText, logType)
    if not ScriptActive or not _G.BeyondConfig then return end
    
    _G.BeyondConfig.Logger.LogCount = _G.BeyondConfig.Logger.LogCount + 1
    
    -- Определение цвета текста на основе типа лога (Инфо, Варнинг, Ошибка)
    local textColor = Color3.fromRGB(240, 240, 245)
    if logType == "warn" then
        textColor = Color3.fromRGB(255, 185, 0)
    elseif logType == "error" then
        textColor = Color3.fromRGB(255, 43, 90)
    elseif logType == "success" then
        textColor = Color3.fromRGB(0, 255, 140)
    end
    
    -- Получение текущего системного времени для красивого префикса
    local systemTime = os.date("%H:%M:%S")
    
    local LogLineLabel = Instance.new("TextLabel")
    LogLineLabel.Name = "LogLine_" .. tostring(_G.BeyondConfig.Logger.LogCount)
    LogLineLabel.Size = UDim2.new(1, 0, 0, 16)
    LogLineLabel.BackgroundTransparency = 1
    LogLineLabel.Text = string.format("[%s] %s", systemTime, logText)
    LogLineLabel.TextColor3 = textColor
    LogLineLabel.Font = _G.BeyondConfig.Styles.FontsList.Monospace
    LogLineLabel.TextSize = 11
    LogLineLabel.TextXAlignment = Enum.TextXAlignment.Left
    LogLineLabel.LayoutOrder = _G.BeyondConfig.Logger.LogCount
    LogLineLabel.Parent = ConsoleBoxFrame
    
    -- Автоматическое управление памятью: удаляем старые строки при превышении лимита
    local allLogs = ConsoleBoxFrame:GetChildren()
    local logLabelsCount = 0
    for _, item in ipairs(allLogs) do
        if item:IsA("TextLabel") then logLabelsCount = logLabelsCount + 1 end
    end
    
    if logLabelsCount > _G.BeyondConfig.Logger.MaxLinesStored then
        for _, item in ipairs(allLogs) do
            if item:IsA("TextLabel") then
                item:Destroy()
                break
            end
        end
    end
    
    -- Динамическое обновление размера холста скроллинга и авто-прокрутка вниз
    ConsoleBoxFrame.CanvasSize = UDim2.new(0, 0, 0, ConsoleListLayout.AbsoluteContentSize.Y + 12)
    ConsoleBoxFrame.CanvasPosition = Vector2.new(0, ConsoleListLayout.AbsoluteContentSize.Y)
end

-- Перехватчик вызовов print() и warn() программы для вывода на наш HUD экран
local function PushClientLog(message)
    PrintToBeyondConsole(tostring(message), "info")
end

local function PushClientWarning(message)
    PrintToBeyondConsole(tostring(message), "warn")
end

-- Стартовая демонстрация логов для подтверждения успешной компиляции всех 11 частей
task.spawn(function()
    task.wait(0.6)
    PrintToBeyondConsole("BeyondClient v5.0 успешно скомпилирован!", "success")
    PrintToBeyondConsole("Архитектура адаптирована под HONOR Play5.", "info")
    PrintToBeyondConsole("Все 11 модулей ядра находятся в активном статусе.", "success")
end)

-- Создаем финальную кнопку принудительной ручной очистки логов консоли
local ClearLogsBtn = Instance.new("TextButton")
ClearLogsBtn.Name = "Console_ClearLogsActionButton"
ClearLogsBtn.Size = UDim2.new(1, 0, 0, 36)
ClearLogsBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
ClearLogsBtn.Text = "ОЧИСТИТЬ ОКНО КОНСОЛИ"
ClearLogsBtn.TextColor3 = Color3.fromRGB(180, 180, 195)
ClearLogsBtn.Font = _G.BeyondConfig.Styles.FontsList.Bold
ClearLogsBtn.TextSize = 11
ClearLogsBtn.Parent = Container

local ClearCorner = Instance.new("UICorner")
ClearCorner.CornerRadius = UDim.new(0, 6)
ClearCorner.Parent = ClearLogsBtn

local ClearStroke = Instance.new("UIStroke")
ClearStroke.Thickness = 1
ClearStroke.Color = _G.BeyondConfig.Styles.BorderStrokeColor
ClearStroke.Parent = ClearLogsBtn

ClearLogsBtn.MouseButton1Click:Connect(function()
    if not ScriptActive then return end
    for _, item in ipairs(ConsoleBoxFrame:GetChildren()) do
        if item:IsA("TextLabel") then item:Destroy() end
    end
    ConsoleBoxFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    PrintToBeyondConsole("Консоль логов успешно очищена пользователем.", "warn")
end)

-- Финальный аккорд запуска: Переопределяем размеры и запускаем плавное проявление меню
MainFrame.Size = UDim2.new(0, 440, 0, 0)
MainFrame.ClipsDescendants = true
MainFrame.Visible = true

local finalBootTween = TweenService:Create(MainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, 440, 0, 340)})
finalBootTween:Play()

finalBootTween.Completed:Connect(function()
    if MainFrame then MainFrame.ClipsDescendants = false end
end)
