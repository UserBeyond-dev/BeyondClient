-- ======================================================
-- DEPSEEK PREMIUM AUTH & UTILITY SCRIPT
-- Создано специально для Delta Executor
-- ======================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Настройки скрипта
local Config = {
    Authorized = false,
    ValidKey = "0000", -- ПАРОЛЬ ИЗМЕНЕН НА 0000
    CameraDistance = 12,
    ShoulderOffset = true,
    HideExecutor = true
}

-- ======================================================
-- 1. СОЗДАНИЕ ГЛАВНОГО ИНТЕРФЕЙСА (БИБЛИОТЕКА UI)
-- ======================================================

-- Удаляем старый интерфейс, если он есть
if CoreGui:FindFirstChild("DepsikAuthUI") then
    CoreGui:FindFirstChild("DepsikAuthUI"):Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DepsikAuthUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui

-- Главный фрейм
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 500, 0, 350)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- Встроенная функция перетаскивания
MainFrame.Parent = ScreenGui

-- Закругление углов
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

-- Верхняя панель (для перетаскивания)
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 10)
TopBarCorner.Parent = TopBar

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, -20, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Depsik Premium | Авторизация"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- Кнопка закрытия (сворачивания)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.Parent = TopBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

-- Контейнер для вкладок
local TabContainer = Instance.new("Frame")
TabContainer.Name = "TabContainer"
TabContainer.Size = UDim2.new(1, -20, 1, -50)
TabContainer.Position = UDim2.new(0, 10, 0, 45)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = MainFrame

-- ======================================================
-- 2. СОЗДАНИЕ ВКЛАДОК И ЭЛЕМЕНТОВ
-- ======================================================

-- Функция для создания кнопки-вкладки
local function CreateTab(name, index)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Name = name .. "Tab"
    TabBtn.Size = UDim2.new(0, 120, 0, 30)
    TabBtn.Position = UDim2.new(0, (index - 1) * 125, 0, 0)
    TabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    TabBtn.Text = name
    TabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    TabBtn.Font = Enum.Font.Gotham
    TabBtn.TextSize = 14
    TabBtn.Parent = TabContainer

    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 6)
    TabCorner.Parent = TabBtn

    return TabBtn
end

-- Вкладки
local AuthTab = CreateTab("Авторизация", 1)
local VisualTab = CreateTab("Визуал / Камера", 2)
local SettingsTab = CreateTab("Настройки", 3)

-- Контент вкладок (показываем/скрываем)
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, 0, 1, -40)
ContentFrame.Position = UDim2.new(0, 0, 0, 40)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = TabContainer

-- Функция переключения вкладок
local function SwitchTab(activeTab)
    for _, v in pairs(TabContainer:GetChildren()) do
        if v:IsA("TextButton") then
            v.BackgroundColor3 = (v == activeTab) and Color3.fromRGB(50, 100, 200) or Color3.fromRGB(30, 30, 40)
            v.TextColor3 = (v == activeTab) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
        end
    end
    
    -- Очищаем контент
    for _, v in pairs(ContentFrame:GetChildren()) do
        if v:IsA("Frame") then v.Visible = false end
    end
    
    -- Показываем нужный контент
    local targetContent = ContentFrame:FindFirstChild(activeTab.Name:gsub("Tab", "Content"))
    if targetContent then targetContent.Visible = true end
end

-- Создание контента для Авторизации
local AuthContent = Instance.new("Frame")
AuthContent.Name = "AuthTabContent"
AuthContent.Size = UDim2.new(1, 0, 1, 0)
AuthContent.BackgroundTransparency = 1
AuthContent.Visible = true
AuthContent.Parent = ContentFrame

local KeyLabel = Instance.new("TextLabel")
KeyLabel.Size = UDim2.new(1, 0, 0, 30)
KeyLabel.Position = UDim2.new(0, 0, 0, 20)
KeyLabel.BackgroundTransparency = 1
KeyLabel.Text = "Введите пароль авторизации:"
KeyLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
KeyLabel.Font = Enum.Font.Gotham
KeyLabel.TextSize = 14
KeyLabel.TextXAlignment = Enum.TextXAlignment.Left
KeyLabel.Parent = AuthContent

local KeyInput = Instance.new("TextBox")
KeyInput.Size = UDim2.new(1, 0, 0, 40)
KeyInput.Position = UDim2.new(0, 0, 0, 60)
KeyInput.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyInput.PlaceholderText = "Введите 0000..."
KeyInput.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
KeyInput.Font = Enum.Font.Gotham
KeyInput.TextSize = 14
KeyInput.Parent = AuthContent

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 6)
InputCorner.Parent = KeyInput

local AuthBtn = Instance.new("TextButton")
AuthBtn.Size = UDim2.new(0, 200, 0, 40)
AuthBtn.Position = UDim2.new(0.5, -100, 0, 120)
AuthBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
AuthBtn.Text = "Авторизоваться"
AuthBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AuthBtn.Font = Enum.Font.GothamBold
AuthBtn.TextSize = 14
AuthBtn.Parent = AuthContent

local AuthBtnCorner = Instance.new("UICorner")
AuthBtnCorner.CornerRadius = UDim.new(0, 6)
AuthBtnCorner.Parent = AuthBtn

-- Создание контента для Визуала
local VisualContent = Instance.new("Frame")
VisualContent.Name = "VisualTabContent"
VisualContent.Size = UDim2.new(1, 0, 1, 0)
VisualContent.BackgroundTransparency = 1
VisualContent.Visible = false
VisualContent.Parent = ContentFrame

local CamLabel = Instance.new("TextLabel")
CamLabel.Size = UDim2.new(1, 0, 0, 30)
CamLabel.Position = UDim2.new(0, 0, 0, 20)
CamLabel.BackgroundTransparency = 1
CamLabel.Text = "Дистанция камеры (как в Free Fire):"
CamLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
CamLabel.Font = Enum.Font.Gotham
CamLabel.TextSize = 14
CamLabel.TextXAlignment = Enum.TextXAlignment.Left
CamLabel.Parent = VisualContent

local CamSlider = Instance.new("TextButton")
CamSlider.Size = UDim2.new(1, 0, 0, 30)
CamSlider.Position = UDim2.new(0, 0, 0, 50)
CamSlider.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
CamSlider.Text = "Текущая дистанция: " .. Config.CameraDistance
CamSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
CamSlider.Font = Enum.Font.Gotham
CamSlider.TextSize = 14
CamSlider.Parent = VisualContent

local ShoulderBtn = Instance.new("TextButton")
ShoulderBtn.Size = UDim2.new(1, 0, 0, 40)
ShoulderBtn.Position = UDim2.new(0, 0, 0, 100)
ShoulderBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
ShoulderBtn.Text = "Смещение камеры к плечу: ВКЛ"
ShoulderBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ShoulderBtn.Font = Enum.Font.Gotham
ShoulderBtn.TextSize = 14
ShoulderBtn.Parent = VisualContent

-- Создание контента для Настроек
local SettingsContent = Instance.new("Frame")
SettingsContent.Name = "SettingsTabContent"
SettingsContent.Size = UDim2.new(1, 0, 1, 0)
SettingsContent.BackgroundTransparency = 1
SettingsContent.Visible = false
SettingsContent.Parent = ContentFrame

local HideDeltaBtn = Instance.new("TextButton")
HideDeltaBtn.Size = UDim2.new(1, 0, 0, 40)
HideDeltaBtn.Position = UDim2.new(0, 0, 0, 20)
HideDeltaBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
HideDeltaBtn.Text = "Скрыть кнопку Delta: ВКЛ"
HideDeltaBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
HideDeltaBtn.Font = Enum.Font.Gotham
HideDeltaBtn.TextSize = 14
HideDeltaBtn.Parent = SettingsContent

-- ======================================================
-- 3. ЛОГИКА РАБОТЫ СКРИПТА
-- ======================================================

-- Переключение вкладок
AuthTab.MouseButton1Click:Connect(function() SwitchTab(AuthTab) end)
VisualTab.MouseButton1Click:Connect(function() SwitchTab(VisualTab) end)
SettingsTab.MouseButton1Click:Connect(function() SwitchTab(SettingsTab) end)

-- Сворачивание меню
local isMinimized = false
CloseBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        MainFrame.Size = UDim2.new(0, 500, 0, 40)
        TabContainer.Visible = false
        CloseBtn.Text = "[]"
    else
        MainFrame.Size = UDim2.new(0, 500, 0, 350)
        TabContainer.Visible = true
        CloseBtn.Text = "X"
    end
end)

-- Авторизация (Проверка пароля 0000)
AuthBtn.MouseButton1Click:Connect(function()
    if KeyInput.Text == Config.ValidKey then
        Config.Authorized = true
        AuthBtn.Text = "Успешно!"
        AuthBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        task.wait(1)
        MainFrame.Visible = false -- Скрываем меню после авторизации
        print("[Depsik Script] Авторизация пройдена! Пароль верный.")
    else
        AuthBtn.Text = "Неверный пароль!"
        AuthBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        task.wait(1)
        AuthBtn.Text = "Авторизоваться"
        AuthBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    end
end)

-- Функция настройки камеры
local function UpdateCamera()
    if not Config.Authorized then return end
    
    pcall(function()
        LocalPlayer.CameraMinZoomDistance = Config.CameraDistance
        LocalPlayer.CameraMaxZoomDistance = Config.CameraDistance + 5
        
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("Humanoid") then
            if Config.ShoulderOffset then
                character.Humanoid.CameraOffset = Vector3.new(1.5, 0.5, 0) -- Смещение вправо и чуть вверх
            else
                character.Humanoid.CameraOffset = Vector3.new(0, 0, 0)
            end
        end
    end)
end

-- Обработка слайдера камеры (упрощенная)
CamSlider.MouseButton1Click:Connect(function()
    Config.CameraDistance = Config.CameraDistance + 2
    if Config.CameraDistance > 30 then Config.CameraDistance = 6 end -- Сброс на минимум
    CamSlider.Text = "Текущая дистанция: " .. Config.CameraDistance
    UpdateCamera()
end)

-- Обработка смещения к плечу
ShoulderBtn.MouseButton1Click:Connect(function()
    Config.ShoulderOffset = not Config.ShoulderOffset
    ShoulderBtn.Text = "Смещение камеры к плечу: " .. (Config.ShoulderOffset and "ВКЛ" or "ВЫКЛ")
    UpdateCamera()
end)

-- Скрытие кнопки Delta (Executor)
HideDeltaBtn.MouseButton1Click:Connect(function()
    Config.HideExecutor = not Config.HideExecutor
    HideDeltaBtn.Text = "Скрыть кнопку Delta: " .. (Config.HideExecutor and "ВКЛ" or "ВЫКЛ")
    
    if Config.HideExecutor then
        -- Пытаемся найти и скрыть GUI Delta
        local success, err = pcall(function()
            local ui = gethui() or CoreGui
            for _, v in pairs(ui:GetChildren()) do
                if v:IsA("ScreenGui") and (v.Name:lower():find("delta") or v.Name:lower():find("executor")) then
                    v.Enabled = false
                end
            end
        end)
        if not success then
            warn("[Depsik Script] Не удалось скрыть Delta GUI: " .. tostring(err))
        end
    end
end)

-- Цикл обновления камеры (чтобы настройки не сбрасывались)
RunService.RenderStepped:Connect(function()
    if Config.Authorized then
        pcall(UpdateCamera)
    end
end)

print("[Depsik Script] Скрипт успешно загружен! Введите пароль 0000 для входа.")