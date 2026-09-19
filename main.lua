--[[
    BeyondClient v6.0 - Thick Monolith Edition
    Target: HONOR Play5 (Dimensity 800U / 8GB RAM / Android 10)
    Developer: UserBeyond-dev
    File: main.lua (Full single-file build, ~30 KB)

    ПОРЯДОК ИСПОЛНЕНИЯ:
      [1]  Сервисы
      [2]  Глобальный конфиг (все таблицы заранее)
      [3]  Система уведомлений
      [4]  Загрузочный экран
      [5]  Каркас ScreenGui + MainFrame + Header + Tabs
      [6]  Self-destruct + minimize/expand
      [7]  Touch drag + ФАБРИКА UI (Toggle/Slider/Button/Dropdown/Keybind/TextBox)
      [8]  Логика переключения табов
      [9]  Модули вкладки VISUAL
      [10] Модули вкладки MOVEMENT
      [11] Модули вкладки AUTOMATION
      [12] Модули вкладки CONFIG
      [13] Модули вкладки DEBUG
      [14] Boot
--]]

-- ====================================================================
-- [1] СЕРВИСЫ
-- ====================================================================
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local CoreGui           = game:GetService("CoreGui")
local TweenService      = game:GetService("TweenService")
local HttpService       = game:GetService("HttpService")
local Lighting          = game:GetService("Lighting")
local SoundService      = game:GetService("SoundService")
local TextChatService   = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StatsService      = game:GetService("Stats")
local ContextActionService = game:GetService("ContextActionService")
local StarterGui        = game:GetService("StarterGui")

local NetworkStats = StatsService:FindFirstChild("Network")
local Terrain      = workspace:FindFirstChildOfClass("Terrain")

local VirtualUser = nil
pcall(function() VirtualUser = game:GetService("VirtualUser") end)

local LocalPlayer = Players.LocalPlayer
local Camera      = workspace.CurrentCamera or workspace:WaitForChild("Camera")

if _G.BeyondClient_SelfDestruct then pcall(_G.BeyondClient_SelfDestruct) end

-- ====================================================================
-- [2] ГЛОБАЛЬНЫЙ КОНФИГ
-- ====================================================================
_G.BeyondConfig = {
    Version      = "6.0-Thick-Edition",
    Developer    = "UserBeyond-dev",
    Build        = "monolith-30kb",

    SpeedValue   = 16,
    JumpPower    = 50,
    InfiniteJump = false,
    Noclip       = false,
    FlyEnabled   = false,
    FlySpeed     = 60,
    AntiAFK      = true,

    ThemeColor   = Color3.fromRGB(255, 43, 90),
    AccentGlow   = Color3.fromRGB(255, 100, 130),
    BgColor      = Color3.fromRGB(15, 15, 20),
    CardColor    = Color3.fromRGB(22, 22, 30),
    HeaderColor  = Color3.fromRGB(28, 26, 36),
    IsMenuOpened = true,
    GlowPhase    = 0,
    ActiveTab    = "Visual",

    Visuals = {
        HighlightESP           = false,
        EspOutlineTransparency = 0,
        EspFillTransparency    = 0.5,
        EspDepthMode           = "AlwaysOnTop",
        RainbowGlow            = false,
        GlowSpeed              = 50,
        NamesOverhead          = false,
        DistanceESP            = false,
        BoxESP                 = false,
        TracerESP              = false,
        TeamCheck              = false
    },

    Movement = {
        WalkSpeed   = 16,
        JumpPower   = 50,
        Gravity     = 196.2,
        FlySpeed    = 60,
        NoclipSpeed = 1.0
    },

    Automation = {
        AutoClickEnabled     = false,
        ClickInterval        = 100,
        ClickType            = "Левая кнопка",
        TotalClicksSimulated = 0,
        AutoJumpEnabled      = false,
        AutoJumpInterval     = 300
    },

    Crosshair = {
        Enabled   = false,
        Size      = 14,
        Thickness = 2,
        Gap       = 4,
        CenterDot = false,
        Style     = "Classic",
        Color     = Color3.fromRGB(255, 43, 90)
    },

    Audio = {
        MuteAll      = false,
        MasterVolume = 0.5,
        AssetClickId = "rbxassetid://6140381534",
        AssetHoverId = "rbxassetid://6895079633",
        AssetOpenId  = "rbxassetid://5153824423",
        AssetErrorId = "rbxassetid://5153825503"
    },

    Logger = {
        MaxLinesStored = 80,
        LogCount       = 0,
        Verbose        = true
    },

    PerformanceBoost = {
        OptimizerActive = false,
        OriginalShadows = Lighting.GlobalShadows,
        OriginalTech    = Lighting.Technology,
        OriginalFogEnd  = Lighting.FogEnd
    },

    Notifications = {
        Enabled = true,
        Duration = 3,
        MaxStack = 5,
        Queue = {}
    },

    Styles = {
        CurrentThemePreset  = "Розовый Zero Two",
        CardBackgroundColor = Color3.fromRGB(20, 20, 28),
        BorderStrokeColor   = Color3.fromRGB(35, 35, 45),
        FontsList = {
            Bold      = Enum.Font.GothamBold,
            Semibold  = Enum.Font.GothamSemibold,
            Regular   = Enum.Font.Gotham,
            Monospace = Enum.Font.Code,
            Black     = Enum.Font.GothamBlack
        }
    },

    ConfigSlots = {
        ActiveSlot = 1,
        SlotCount  = 5
    },

    Keybinds = {
        ToggleMenu = Enum.KeyCode.RightShift,
        PanicKey   = Enum.KeyCode.End
    }
}

local ScriptActive = true

-- ====================================================================
-- [3] СИСТЕМА УВЕДОМЛЕНИЙ
-- ====================================================================
local NotifyFolder = nil

local function InitNotifyFolder()
    if NotifyFolder then return end
    NotifyFolder = Instance.new("ScreenGui")
    NotifyFolder.Name = "Beyond_Notifications"
    NotifyFolder.ResetOnSpawn = false
    NotifyFolder.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    local ok = pcall(function() NotifyFolder.Parent = CoreGui end)
    if not ok then NotifyFolder.Parent = LocalPlayer:WaitForChild("PlayerGui") end
end

InitNotifyFolder()

local function PushNotification(title, message, notifType)
    if not ScriptActive or not _G.BeyondConfig then return end
    if not _G.BeyondConfig.Notifications.Enabled then return end

    local accentColor = _G.BeyondConfig.ThemeColor
    if notifType == "warn" then accentColor = Color3.fromRGB(255, 185, 0)
    elseif notifType == "error" then accentColor = Color3.fromRGB(255, 60, 80)
    elseif notifType == "success" then accentColor = Color3.fromRGB(0, 220, 130) end

    local notifFrame = Instance.new("Frame")
    notifFrame.Size = UDim2.new(0, 260, 0, 0)
    notifFrame.Position = UDim2.new(1, -280, 0, 80)
    notifFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
    notifFrame.BorderSizePixel = 0
    notifFrame.ClipsDescendants = true
    notifFrame.Parent = NotifyFolder
    Instance.new("UICorner", notifFrame).CornerRadius = UDim.new(0, 10)

    local notifStroke = Instance.new("UIStroke")
    notifStroke.Thickness = 2
    notifStroke.Color = accentColor
    notifStroke.Parent = notifFrame

    local accentBar = Instance.new("Frame")
    accentBar.Size = UDim2.new(0, 4, 1, 0)
    accentBar.BackgroundColor3 = accentColor
    accentBar.BorderSizePixel = 0
    accentBar.Parent = notifFrame

    local notifTitle = Instance.new("TextLabel")
    notifTitle.Size = UDim2.new(1, -20, 0, 20)
    notifTitle.Position = UDim2.new(0, 14, 0, 8)
    notifTitle.BackgroundTransparency = 1
    notifTitle.Text = title or "Beyond"
    notifTitle.TextColor3 = Color3.fromRGB(245, 245, 250)
    notifTitle.Font = Enum.Font.GothamBold
    notifTitle.TextSize = 12
    notifTitle.TextXAlignment = Enum.TextXAlignment.Left
    notifTitle.Parent = notifFrame

    local notifBody = Instance.new("TextLabel")
    notifBody.Size = UDim2.new(1, -20, 0, 30)
    notifBody.Position = UDim2.new(0, 14, 0, 28)
    notifBody.BackgroundTransparency = 1
    notifBody.Text = message or ""
    notifBody.TextColor3 = Color3.fromRGB(180, 180, 195)
    notifBody.Font = Enum.Font.Gotham
    notifBody.TextSize = 11
    notifBody.TextWrapped = true
    notifBody.TextXAlignment = Enum.TextXAlignment.Left
    notifBody.TextYAlignment = Enum.TextYAlignment.Top
    notifBody.Parent = notifFrame

    TweenService:Create(notifFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        {Size = UDim2.new(0, 260, 0, 62)}):Play()

    task.spawn(function()
        task.wait(_G.BeyondConfig.Notifications.Duration or 3)
        if notifFrame and notifFrame.Parent then
            TweenService:Create(notifFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
                {Size = UDim2.new(0, 260, 0, 0), BackgroundTransparency = 1}):Play()
            task.wait(0.35)
            pcall(function() notifFrame:Destroy() end)
        end
    end)
end

-- ====================================================================
-- [4] ЗАГРУЗОЧНЫЙ ЭКРАН
-- ====================================================================
local LoadingScreen = Instance.new("ScreenGui")
LoadingScreen.Name = "Beyond_Loading"
LoadingScreen.ResetOnSpawn = false
LoadingScreen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
local okLoad = pcall(function() LoadingScreen.Parent = CoreGui end)
if not okLoad then LoadingScreen.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local loadingBg = Instance.new("Frame")
loadingBg.Size = UDim2.new(1, 0, 1, 0)
loadingBg.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
loadingBg.BorderSizePixel = 0
loadingBg.Parent = LoadingScreen

local loadingTitle = Instance.new("TextLabel")
loadingTitle.Size = UDim2.new(1, 0, 0, 40)
loadingTitle.Position = UDim2.new(0, 0, 0.4, -40)
loadingTitle.BackgroundTransparency = 1
loadingTitle.Text = "BEYOND <font color='#FF2B5A'>CLIENT</font> v6.0"
loadingTitle.RichText = true
loadingTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
loadingTitle.Font = Enum.Font.GothamBlack
loadingTitle.TextSize = 26
loadingTitle.Parent = loadingBg

local loadingSub = Instance.new("TextLabel")
loadingSub.Size = UDim2.new(1, 0, 0, 20)
loadingSub.Position = UDim2.new(0, 0, 0.4, 6)
loadingSub.BackgroundTransparency = 1
loadingSub.Text = "инициализация ядра..."
loadingSub.TextColor3 = Color3.fromRGB(140, 140, 155)
loadingSub.Font = Enum.Font.Code
loadingSub.TextSize = 13
loadingSub.Parent = loadingBg

local loadingBarBg = Instance.new("Frame")
loadingBarBg.Size = UDim2.new(0, 320, 0, 6)
loadingBarBg.Position = UDim2.new(0.5, -160, 0.4, 40)
loadingBarBg.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
loadingBarBg.BorderSizePixel = 0
loadingBarBg.Parent = loadingBg
Instance.new("UICorner", loadingBarBg).CornerRadius = UDim.new(1, 0)

local loadingBar = Instance.new("Frame")
loadingBar.Size = UDim2.new(0, 0, 1, 0)
loadingBar.BackgroundColor3 = _G.BeyondConfig.ThemeColor
loadingBar.BorderSizePixel = 0
loadingBar.Parent = loadingBarBg
Instance.new("UICorner", loadingBar).CornerRadius = UDim.new(1, 0)

TweenService:Create(loadingBar, TweenInfo.new(1.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    {Size = UDim2.new(1, 0, 1, 0)}):Play()

task.spawn(function()
    task.wait(1.5)
    TweenService:Create(loadingBg, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        {BackgroundTransparency = 1}):Play()
    TweenService:Create(loadingTitle, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
    TweenService:Create(loadingSub, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
    TweenService:Create(loadingBarBg, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
    TweenService:Create(loadingBar, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
    task.wait(0.5)
    pcall(function() LoadingScreen:Destroy() end)
end)

-- ====================================================================
-- [5] КАРКАС GUI
-- ====================================================================
local BeyondScreenGui = Instance.new("ScreenGui")
BeyondScreenGui.Name = "Beyond_" .. HttpService:GenerateGUID(false):sub(1, 8)
BeyondScreenGui.ResetOnSpawn = false
BeyondScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
local okParent = pcall(function() BeyondScreenGui.Parent = CoreGui end)
if not okParent then BeyondScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainPanel"
MainFrame.Size = UDim2.new(0, 460, 0, 380)
MainFrame.Position = UDim2.new(0.5, -230, 0.35, -190)
MainFrame.BackgroundColor3 = _G.BeyondConfig.BgColor
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = BeyondScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 14)

local Stroke = Instance.new("UIStroke")
Stroke.Thickness = 2
Stroke.Color = _G.BeyondConfig.ThemeColor
Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
Stroke.Parent = MainFrame

-- Заголовок
local Header = Instance.new("Frame")
Header.Name = "HeaderZone"
Header.Size = UDim2.new(1, 0, 0, 45)
Header.BackgroundColor3 = _G.BeyondConfig.HeaderColor
Header.BorderSizePixel = 0
Header.Parent = MainFrame
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 14)

local HeaderLine = Instance.new("Frame")
HeaderLine.Size = UDim2.new(1, 0, 0, 2)
HeaderLine.Position = UDim2.new(0, 0, 1, -2)
HeaderLine.BackgroundColor3 = _G.BeyondConfig.ThemeColor
HeaderLine.BorderSizePixel = 0
HeaderLine.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -160, 1, 0)
Title.Position = UDim2.new(0, 16, 0, 0)
Title.Text = "BEYOND <font color='#FF2B5A'>CLIENT</font> <font color='#A0A0A5'>v6.0</font>"
Title.RichText = true
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
Title.Parent = Header

-- Плавающая кнопка вызова
local MobileToggleButton = Instance.new("ImageButton")
MobileToggleButton.Name = "BeyondMobileCall"
MobileToggleButton.Size = UDim2.new(0, 52, 0, 52)
MobileToggleButton.Position = UDim2.new(0, 20, 0.25, 0)
MobileToggleButton.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
MobileToggleButton.BorderSizePixel = 0
MobileToggleButton.Image = "rbxassetid://16024021200"
MobileToggleButton.ImageColor3 = _G.BeyondConfig.ThemeColor
MobileToggleButton.ZIndex = 15
MobileToggleButton.Visible = false
MobileToggleButton.Parent = BeyondScreenGui
Instance.new("UICorner", MobileToggleButton).CornerRadius = UDim.new(1, 0)

local ButtonStroke = Instance.new("UIStroke", MobileToggleButton)
ButtonStroke.Thickness = 2
ButtonStroke.Color = _G.BeyondConfig.ThemeColor

-- Minimize
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
Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 6)

-- Close
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
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

-- Панель табов
local TabBar = Instance.new("Frame")
TabBar.Name = "TabBar"
TabBar.Size = UDim2.new(1, -20, 0, 34)
TabBar.Position = UDim2.new(0, 10, 0, 52)
TabBar.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
TabBar.BorderSizePixel = 0
TabBar.Parent = MainFrame
Instance.new("UICorner", TabBar).CornerRadius = UDim.new(0, 8)

local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.Padding = UDim.new(0, 4)
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabLayout.Parent = TabBar

local TabPadding = Instance.new("UIPadding")
TabPadding.PaddingLeft = UDim.new(0, 4)
TabPadding.PaddingTop = UDim.new(0, 4)
TabPadding.Parent = TabBar

-- Слой контента
local Container = Instance.new("ScrollingFrame")
Container.Name = "ModuleContainer"
Container.Size = UDim2.new(1, -20, 1, -140)
Container.Position = UDim2.new(0, 10, 0, 94)
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
ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    if ScriptActive and Container then
        Container.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 20)
    end
end)

-- Футер
local Footer = Instance.new("Frame")
Footer.Name = "Footer"
Footer.Size = UDim2.new(1, 0, 0, 26)
Footer.Position = UDim2.new(0, 0, 1, -26)
Footer.BackgroundColor3 = Color3.fromRGB(22, 20, 28)
Footer.BorderSizePixel = 0
Footer.Parent = MainFrame
Instance.new("UICorner", Footer).CornerRadius = UDim.new(0, 14)

local FooterText = Instance.new("TextLabel")
FooterText.Name = "FooterText"
FooterText.Size = UDim2.new(1, -20, 1, 0)
FooterText.Position = UDim2.new(0, 12, 0, 0)
FooterText.BackgroundTransparency = 1
FooterText.Text = "Status: Operational // Mobile Touch Enabled"
FooterText.TextColor3 = Color3.fromRGB(150, 150, 165)
FooterText.Font = Enum.Font.Code
FooterText.TextSize = 11
FooterText.TextXAlignment = Enum.TextXAlignment.Left
FooterText.Parent = Footer

-- Хранилище вкладок
local Tabs = {}
local TabPages = {}
local ActiveTabName = "Visual"

local function CreateTabButton(name, layoutOrder)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Name = "Tab_" .. name
    TabBtn.Size = UDim2.new(0, 82, 0, 26)
    TabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    TabBtn.Text = name
    TabBtn.TextColor3 = Color3.fromRGB(200, 200, 215)
    TabBtn.Font = Enum.Font.GothamSemibold
    TabBtn.TextSize = 11
    TabBtn.LayoutOrder = layoutOrder
    TabBtn.Parent = TabBar
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)
    return TabBtn
end

local function CreateTabPage(name)
    local Page = Instance.new("Frame")
    Page.Name = "Page_" .. name
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = (name == ActiveTabName)
    Page.Parent = Container

    local PageLayout = Instance.new("UIListLayout")
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    PageLayout.Padding = UDim.new(0, 10)
    PageLayout.Parent = Page

    PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        if ScriptActive and Container and Page.Visible then
            Container.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 20)
        end
    end)

    return Page, PageLayout
end

for _, tabName in ipairs({"Visual", "Movement", "Auto", "Config", "Debug"}) do
    local btn = CreateTabButton(tabName, #Tabs + 1)
    local page, layout = CreateTabPage(tabName)
    Tabs[tabName] = {Button = btn, Page = page, Layout = layout}
    TabPages[tabName] = page
end

-- ====================================================================
-- [6] SELF-DESTRUCT + MINIMIZE / EXPAND
-- ====================================================================
_G.BeyondClient_SelfDestruct = function()
    ScriptActive = false
    pcall(function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = 16
            hum.JumpPower = 50
        end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = true end
        end
    end)
    pcall(function() BeyondScreenGui:Destroy() end)
    pcall(function() if NotifyFolder then NotifyFolder:Destroy() end end)
    pcall(function() if LoadingScreen then LoadingScreen:Destroy() end end)
    _G.BeyondConfig = nil
    _G.BeyondClient_SelfDestruct = nil
    print("[BeyondClient]: Все следы софта успешно стерты из памяти девайса.")
end

CloseBtn.MouseButton1Click:Connect(function()
    if _G.BeyondClient_SelfDestruct then _G.BeyondClient_SelfDestruct() end
end)

MinimizeBtn.MouseButton1Click:Connect(function()
    if not ScriptActive then return end
    _G.BeyondConfig.IsMenuOpened = false
    TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
        {Size = UDim2.new(0, 460, 0, 0)}):Play()
    task.wait(0.2)
    MainFrame.Visible = false
    MobileToggleButton.Visible = true
    MobileToggleButton.Size = UDim2.new(0, 0, 0, 0)
    TweenService:Create(MobileToggleButton, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Size = UDim2.new(0, 52, 0, 52)}):Play()
end)

MobileToggleButton.MouseButton1Click:Connect(function()
    if not ScriptActive then return end
    _G.BeyondConfig.IsMenuOpened = true
    TweenService:Create(MobileToggleButton, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
        {Size = UDim2.new(0, 0, 0, 0)}):Play()
    task.wait(0.15)
    MobileToggleButton.Visible = false
    MainFrame.Visible = true
    TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        {Size = UDim2.new(0, 460, 0, 380)}):Play()
end)

-- ====================================================================
-- [7] TOUCH DRAG + ФАБРИКА UI
-- ====================================================================
local function EnableTouchDrag(dragZone, targetFrame)
    local dragToggle, dragInput, dragStart, startPosition = false, nil, nil, nil

    dragZone.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
           or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragToggle = true
            dragStart = input.Position
            startPosition = targetFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragToggle = false end
            end)
        end
    end)

    dragZone.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
           or input.UserInputType == Enum.UserInputType.MouseBehavior then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragToggle and ScriptActive then
            local delta = input.Position - dragStart
            targetFrame.Position = UDim2.new(
                startPosition.X.Scale, startPosition.X.Offset + delta.X,
                startPosition.Y.Scale, startPosition.Y.Offset + delta.Y
            )
        end
    end)
end

EnableTouchDrag(Header, MainFrame)
EnableTouchDrag(MobileToggleButton, MobileToggleButton)

-- Toggle
local function CreateMobileToggle(parent, text, default, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 46)
    ToggleFrame.BackgroundColor3 = _G.BeyondConfig.CardColor
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.Parent = parent
    Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 8)

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
    Instance.new("UICorner", CheckBox).CornerRadius = UDim.new(1, 0)

    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.new(0, 18, 0, 18)
    Indicator.Position = default and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
    Indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Indicator.Parent = CheckBox
    Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1, 0)

    local state = default
    CheckBox.MouseButton1Click:Connect(function()
        if not ScriptActive or not _G.BeyondConfig then return end
        state = not state
        local targetColor = state and _G.BeyondConfig.ThemeColor or Color3.fromRGB(45, 45, 60)
        local targetPos   = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
        TweenService:Create(CheckBox, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {BackgroundColor3 = targetColor}):Play()
        TweenService:Create(Indicator, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {Position = targetPos}):Play()
        callback(state)
    end)

    return CheckBox
end

-- Slider
local function CreateMobileSlider(parent, text, min, max, default, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, 0, 0, 58)
    SliderFrame.BackgroundColor3 = _G.BeyondConfig.CardColor
    SliderFrame.BorderSizePixel = 0
    SliderFrame.Parent = parent
    Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(0, 8)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.85, 0, 0, 26)
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
    Instance.new("UICorner", Track).CornerRadius = UDim.new(0, 3)

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((default - min) / math.max(1, (max - min)), 0, 1, 0)
    Fill.BackgroundColor3 = _G.BeyondConfig.ThemeColor
    Fill.BorderSizePixel = 0
    Fill.Parent = Track
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(0, 3)

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
        if not ScriptActive then return end
        if input.UserInputType == Enum.UserInputType.Touch
           or input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliding = true
            processInput(input)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if sliding and ScriptActive and
           (input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseBehavior) then
            processInput(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
           or input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliding = false
        end
    end)
end

-- Section Label
local function CreateSectionLabel(parent, titleText)
    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(1, 0, 0, 26)
    Lbl.BackgroundTransparency = 1
    Lbl.Text = "--- [ " .. titleText .. " ] ---"
    Lbl.TextColor3 = Color3.fromRGB(160, 160, 175)
    Lbl.Font = _G.BeyondConfig.Styles.FontsList.Bold
    Lbl.TextSize = 12
    Lbl.TextStrokeTransparency = 0.8
    Lbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    Lbl.Parent = parent
    return Lbl
end

-- Action Button
local function CreateActionButton(parent, textTitle, bgColor, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 38)
    Btn.BackgroundColor3 = bgColor or Color3.fromRGB(34, 34, 46)
    Btn.Text = textTitle
    Btn.TextColor3 = Color3.fromRGB(240, 240, 245)
    Btn.Font = _G.BeyondConfig.Styles.FontsList.Bold
    Btn.TextSize = 11
    Btn.Parent = parent
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)

    local BStroke = Instance.new("UIStroke")
    BStroke.Thickness = 1
    BStroke.Color = _G.BeyondConfig.Styles.BorderStrokeColor
    BStroke.Parent = Btn

    Btn.MouseButton1Click:Connect(function()
        if not ScriptActive then return end
        TweenService:Create(Btn, TweenInfo.new(0.08), {BackgroundColor3 = _G.BeyondConfig.ThemeColor}):Play()
        task.spawn(function()
            callback()
            task.wait(0.15)
            if Btn and Btn.Parent then
                TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = bgColor or Color3.fromRGB(34, 34, 46)}):Play()
            end
        end)
    end)
    return Btn
end

-- Card Frame
local function CreateCardFrame(parent, height)
    local Card = Instance.new("Frame")
    Card.Size = UDim2.new(1, 0, 0, height or 90)
    Card.BackgroundColor3 = _G.BeyondConfig.CardColor
    Card.BorderSizePixel = 0
    Card.Parent = parent
    Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 8)

    local CStroke = Instance.new("UIStroke")
    CStroke.Thickness = 1
    CStroke.Color = _G.BeyondConfig.Styles.BorderStrokeColor
    CStroke.Parent = Card
    return Card
end

-- ====================================================================
-- [8] ЛОГИКА ПЕРЕКЛЮЧЕНИЯ ТАБОВ
-- ====================================================================
local function SwitchTab(name)
    if not Tabs[name] then return end
    for tabName, tabData in pairs(Tabs) do
        local isActive = (tabName == name)
        tabData.Page.Visible = isActive
        TweenService:Create(tabData.Button, TweenInfo.new(0.2),
            {BackgroundColor3 = isActive and _G.BeyondConfig.ThemeColor or Color3.fromRGB(30, 30, 40)}):Play()
        tabData.Button.TextColor3 = isActive and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 215)
    end
    ActiveTabName = name
    _G.BeyondConfig.ActiveTab = name
    Container.CanvasSize = UDim2.new(0, 0, 0, Tabs[name].Layout.AbsoluteContentSize.Y + 20)
    Container.CanvasPosition = Vector2.new(0, 0)
end

for tabName, tabData in pairs(Tabs) do
    tabData.Button.MouseButton1Click:Connect(function()
        if not ScriptActive then return end
        SwitchTab(tabName)
    end)
end

SwitchTab("Visual")

-- ====================================================================
-- [9] ВКЛАДКА VISUAL
-- ====================================================================
local visualPage = TabPages["Visual"]

CreateSectionLabel(visualPage, "НЕОНОВАЯ ПОДСВЕТКА (ESP)")

CreateMobileToggle(visualPage, "Включить подсветку игроков", _G.BeyondConfig.Visuals.HighlightESP, function(state)
    _G.BeyondConfig.Visuals.HighlightESP = state
    PushNotification("Visuals", state and "Highlight ESP включён" or "Highlight ESP выключен",
        state and "success" or "warn")
    if not state then
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character then
                local hl = player.Character:FindFirstChild("Beyond_Highlight")
                if hl then hl.Enabled = false end
            end
        end
    end
end)

CreateMobileSlider(visualPage, "Прозрачность силуэта (%)", 0, 100, 50, function(val)
    _G.BeyondConfig.Visuals.EspFillTransparency = val / 100
end)

CreateMobileSlider(visualPage, "Прозрачность обводки (%)", 0, 100, 0, function(val)
    _G.BeyondConfig.Visuals.EspOutlineTransparency = val / 100
end)

CreateMobileToggle(visualPage, "RGB переливание интерфейса", _G.BeyondConfig.Visuals.RainbowGlow, function(state)
    _G.BeyondConfig.Visuals.RainbowGlow = state
    if not state then
        Stroke.Color = _G.BeyondConfig.ThemeColor
        HeaderLine.BackgroundColor3 = _G.BeyondConfig.ThemeColor
        Container.ScrollBarImageColor3 = _G.BeyondConfig.ThemeColor
    end
end)

CreateSectionLabel(visualPage, "ПРИЦЕЛ")

CreateMobileToggle(visualPage, "Отображать прицел", _G.BeyondConfig.Crosshair.Enabled, function(state)
    _G.BeyondConfig.Crosshair.Enabled = state
    if _G.BeyondConfig._RecalibrateCrosshair then _G.BeyondConfig._RecalibrateCrosshair() end
end)

CreateMobileToggle(visualPage, "Центральная точка", _G.BeyondConfig.Crosshair.CenterDot, function(state)
    _G.BeyondConfig.Crosshair.CenterDot = state
    if _G.BeyondConfig._RecalibrateCrosshair then _G.BeyondConfig._RecalibrateCrosshair() end
end)

CreateMobileSlider(visualPage, "Длина линий", 4, 40, _G.BeyondConfig.Crosshair.Size, function(val)
    _G.BeyondConfig.Crosshair.Size = val
    if _G.BeyondConfig._RecalibrateCrosshair then _G.BeyondConfig._RecalibrateCrosshair() end
end)

CreateMobileSlider(visualPage, "Толщина линий", 1, 8, _G.BeyondConfig.Crosshair.Thickness, function(val)
    _G.BeyondConfig.Crosshair.Thickness = val
    if _G.BeyondConfig._RecalibrateCrosshair then _G.BeyondConfig._RecalibrateCrosshair() end
end)

CreateMobileSlider(visualPage, "Зазор (Gap)", 0, 20, _G.BeyondConfig.Crosshair.Gap, function(val)
    _G.BeyondConfig.Crosshair.Gap = val
    if _G.BeyondConfig._RecalibrateCrosshair then _G.BeyondConfig._RecalibrateCrosshair() end
end)

CreateSectionLabel(visualPage, "ПРЕСЕТЫ ТЕМ")

local StylePresetFrame = CreateCardFrame(visualPage, 90)

local StyleLabel = Instance.new("TextLabel")
StyleLabel.Size = UDim2.new(1, -20, 0, 25)
StyleLabel.Position = UDim2.new(0, 14, 0, 4)
StyleLabel.Text = "Тема: <font color='#FF2B5A'>" .. _G.BeyondConfig.Styles.CurrentThemePreset .. "</font>"
StyleLabel.RichText = true
StyleLabel.TextColor3 = Color3.fromRGB(225, 225, 235)
StyleLabel.Font = _G.BeyondConfig.Styles.FontsList.Semibold
StyleLabel.TextSize = 13
StyleLabel.TextXAlignment = Enum.TextXAlignment.Left
StyleLabel.BackgroundTransparency = 1
StyleLabel.Parent = StylePresetFrame

local function InitializeThemeButton(themeName, xOffset, primeColor)
    local ThemeBtn = Instance.new("TextButton")
    ThemeBtn.Size = UDim2.new(0.28, 0, 0, 38)
    ThemeBtn.Position = UDim2.new(0, xOffset, 0, 38)
    ThemeBtn.BackgroundColor3 = Color3.fromRGB(34, 34, 46)
    ThemeBtn.Text = themeName
    ThemeBtn.TextColor3 = Color3.fromRGB(245, 245, 250)
    ThemeBtn.Font = _G.BeyondConfig.Styles.FontsList.Bold
    ThemeBtn.TextSize = 10
    ThemeBtn.Parent = StylePresetFrame
    Instance.new("UICorner", ThemeBtn).CornerRadius = UDim.new(0, 6)

    ThemeBtn.MouseButton1Click:Connect(function()
        if not ScriptActive or not _G.BeyondConfig then return end
        if _G.BeyondConfig.Visuals.RainbowGlow then
            PushNotification("Theme", "Отключите RGB переливание перед сменой темы", "warn")
            return
        end
        _G.BeyondConfig.Styles.CurrentThemePreset = themeName
        _G.BeyondConfig.ThemeColor = primeColor
        _G.BeyondConfig.Crosshair.Color = primeColor
        StyleLabel.Text = "Тема: <font color='#FF2B5A'>" .. themeName .. "</font>"

        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
        TweenService:Create(Stroke, tweenInfo, {Color = primeColor}):Play()
        TweenService:Create(HeaderLine, tweenInfo, {BackgroundColor3 = primeColor}):Play()
        TweenService:Create(Container, tweenInfo, {ScrollBarImageColor3 = primeColor}):Play()
        TweenService:Create(MobileToggleButton, tweenInfo, {ImageColor3 = primeColor}):Play()
        TweenService:Create(ButtonStroke, tweenInfo, {Color = primeColor}):Play()
        PushNotification("Theme", "Тема применена: " .. themeName, "success")
    end)
end

InitializeThemeButton("Zero Two",  14,  Color3.fromRGB(255, 43, 90))
InitializeThemeButton("Киберпанк", 140, Color3.fromRGB(0, 255, 240))
InitializeThemeButton("Токсик",    266, Color3.fromRGB(170, 255, 0))

-- Crosshair core
local CrosshairContainer = Instance.new("Frame")
CrosshairContainer.Name = "Beyond_Crosshair_Root"
CrosshairContainer.Size = UDim2.new(0, 100, 0, 100)
CrosshairContainer.Position = UDim2.new(0.5, -50, 0.5, -50)
CrosshairContainer.BackgroundTransparency = 1
CrosshairContainer.Visible = false
CrosshairContainer.Parent = BeyondScreenGui

local TopLine    = Instance.new("Frame")
local BottomLine = Instance.new("Frame")
local LeftLine   = Instance.new("Frame")
local RightLine  = Instance.new("Frame")
local CenterDot  = Instance.new("Frame")

local linesArray = {TopLine, BottomLine, LeftLine, RightLine, CenterDot}
for _, line in ipairs(linesArray) do
    line.BorderSizePixel = 0
    line.BackgroundColor3 = _G.BeyondConfig.ThemeColor
    line.Parent = CrosshairContainer
end

_G.BeyondConfig._RecalibrateCrosshair = function()
    if not _G.BeyondConfig or not _G.BeyondConfig.Crosshair then return end
    local cfg = _G.BeyondConfig.Crosshair
    CrosshairContainer.Visible = cfg.Enabled
    CenterDot.Visible = cfg.CenterDot
    CenterDot.Size = UDim2.new(0, cfg.Thickness, 0, cfg.Thickness)
    CenterDot.Position = UDim2.new(0.5, -cfg.Thickness / 2, 0.5, -cfg.Thickness / 2)
    TopLine.Size = UDim2.new(0, cfg.Thickness, 0, cfg.Size)
    TopLine.Position = UDim2.new(0.5, -cfg.Thickness / 2, 0.5, -cfg.Gap - cfg.Size)
    BottomLine.Size = UDim2.new(0, cfg.Thickness, 0, cfg.Size)
    BottomLine.Position = UDim2.new(0.5, -cfg.Thickness / 2, 0.5, cfg.Gap)
    LeftLine.Size = UDim2.new(0, cfg.Size, 0, cfg.Thickness)
    LeftLine.Position = UDim2.new(0.5, -cfg.Gap - cfg.Size, 0.5, -cfg.Thickness / 2)
    RightLine.Size = UDim2.new(0, cfg.Size, 0, cfg.Thickness)
    RightLine.Position = UDim2.new(0.5, cfg.Gap, 0.5, -cfg.Thickness / 2)
end

-- Highlight system
local function ApplyHighlight(player)
    if player == LocalPlayer then return end
    local function setupCharacter(char)
        if not ScriptActive or not _G.BeyondConfig then return end
        local oldHl = char:FindFirstChild("Beyond_Highlight")
        if oldHl then oldHl:Destroy() end
        local highlight = Instance.new("Highlight")
        highlight.Name = "Beyond_Highlight"
        highlight.FillColor = _G.BeyondConfig.ThemeColor
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = _G.BeyondConfig.Visuals.EspFillTransparency
        highlight.OutlineTransparency = _G.BeyondConfig.Visuals.EspOutlineTransparency
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Enabled = _G.BeyondConfig.Visuals.HighlightESP
        highlight.Parent = char
    end
    if player.Character then setupCharacter(player.Character) end
    player.CharacterAdded:Connect(setupCharacter)
end

for _, player in ipairs(Players:GetPlayers()) do ApplyHighlight(player) end
Players.PlayerAdded:Connect(ApplyHighlight)

-- Main render loop
RunService.RenderStepped:Connect(function(deltaTime)
    if not ScriptActive or not _G.BeyondConfig then return end
    _G.BeyondConfig.GlowPhase = (_G.BeyondConfig.GlowPhase
        + (deltaTime * (_G.BeyondConfig.Visuals.GlowSpeed / 10))) % 1
    local dynamicRainbowColor = Color3.fromHSV(_G.BeyondConfig.GlowPhase, 0.85, 1)

    if _G.BeyondConfig.Visuals.RainbowGlow then
        Stroke.Color = dynamicRainbowColor
        HeaderLine.BackgroundColor3 = dynamicRainbowColor
        Container.ScrollBarImageColor3 = dynamicRainbowColor
    end

    if _G.BeyondConfig.Visuals.HighlightESP then
        for _, player in ipairs(Players:GetPlayers()) do
            local char = player.Character
            local hl = char and char:FindFirstChild("Beyond_Highlight")
            if hl and hl:IsA("Highlight") then
                hl.Enabled = true
                hl.FillColor = dynamicRainbowColor
                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                hl.FillTransparency = _G.BeyondConfig.Visuals.EspFillTransparency
                hl.OutlineTransparency = _G.BeyondConfig.Visuals.EspOutlineTransparency
            end
        end
    end
end)

-- Crosshair color loop
task.spawn(function()
    while ScriptActive and task.wait(0.01) do
        if _G.BeyondConfig and _G.BeyondConfig.Crosshair.Enabled then
            pcall(function()
                local syncColor = _G.BeyondConfig.Visuals.RainbowGlow
                    and Color3.fromHSV(_G.BeyondConfig.GlowPhase, 0.85, 1)
                    or  _G.BeyondConfig.Crosshair.Color
                for _, line in ipairs(linesArray) do
                    line.BackgroundColor3 = syncColor
                end
            end)
        end
    end
end)

-- ====================================================================
-- [10] ВКЛАДКА MOVEMENT
-- ====================================================================
local movementPage = TabPages["Movement"]

CreateSectionLabel(movementPage, "СКОРОСТЬ И ПРЫЖОК")

CreateMobileSlider(movementPage, "WalkSpeed", 16, 250, _G.BeyondConfig.Movement.WalkSpeed, function(val)
    _G.BeyondConfig.Movement.WalkSpeed = val
    pcall(function()
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = val end
    end)
end)

CreateMobileSlider(movementPage, "JumpPower", 50, 500, _G.BeyondConfig.Movement.JumpPower, function(val)
    _G.BeyondConfig.Movement.JumpPower = val
    pcall(function()
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.UseJumpPower = true
            hum.JumpPower = val
        end
    end)
end)

CreateMobileToggle(movementPage, "Бесконечный прыжок", false, function(state)
    _G.BeyondConfig.InfiniteJump = state
    PushNotification("Movement", state and "Infinite Jump ON" or "Infinite Jump OFF",
        state and "success" or "warn")
end)

CreateMobileToggle(movementPage, "Noclip", false, function(state)
    _G.BeyondConfig.Noclip = state
    PushNotification("Movement", state and "Noclip ON" or "Noclip OFF",
        state and "success" or "warn")
end)

CreateSectionLabel(movementPage, "ПОЛЁТ (FLY)")

CreateMobileToggle(movementPage, "Включить Fly", false, function(state)
    _G.BeyondConfig.FlyEnabled = state
    PushNotification("Movement", state and "Fly ON" or "Fly OFF",
        state and "success" or "warn")
end)

CreateMobileSlider(movementPage, "FlySpeed", 20, 300, _G.BeyondConfig.Movement.FlySpeed, function(val)
    _G.BeyondConfig.FlySpeed = val
end)

CreateSectionLabel(movementPage, "АВТОМАТИКА ДВИЖЕНИЯ")

CreateMobileToggle(movementPage, "Anti-AFK", true, function(state)
    _G.BeyondConfig.AntiAFK = state
end)

-- Infinite jump + Noclip + Fly implementation
local flyBodyVelocity, flyBodyGyro
local flyConnection
local flyHeartbeat

UserInputService.JumpRequest:Connect(function()
    if not ScriptActive or not _G.BeyondConfig then return end
    if _G.BeyondConfig.InfiniteJump then
        pcall(function()
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    end
end)

RunService.Stepped:Connect(function()
    if not ScriptActive or not _G.BeyondConfig then return end
    if _G.BeyondConfig.Noclip then
        pcall(function()
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end)
    end
end)

-- Fly controller
local function StartFly()
    if flyConnection then return end
    pcall(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        flyBodyVelocity = Instance.new("BodyVelocity")
        flyBodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        flyBodyVelocity.Velocity = Vector3.zero
        flyBodyVelocity.Parent = hrp
        flyBodyGyro = Instance.new("BodyGyro")
        flyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        flyBodyGyro.P = 9e4
        flyBodyGyro.CFrame = hrp.CFrame
        flyBodyGyro.Parent = hrp

        flyConnection = RunService.Heartbeat:Connect(function()
            if not ScriptActive or not _G.BeyondConfig or not _G.BeyondConfig.FlyEnabled then
                if flyBodyVelocity then flyBodyVelocity:Destroy() end
                if flyBodyGyro then flyBodyGyro:Destroy() end
                if flyConnection then flyConnection:Disconnect() end
                flyBodyVelocity = nil
                flyBodyGyro = nil
                flyConnection = nil
                return
            end
            local ch = LocalPlayer.Character
            local root = ch and ch:FindFirstChild("HumanoidRootPart")
            if not root then return end
            local cam = workspace.CurrentCamera
            local moveDir = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
            if moveDir.Magnitude > 0 then
                moveDir = moveDir.Unit * _G.BeyondConfig.FlySpeed
            end
            flyBodyVelocity.Velocity = moveDir
            flyBodyGyro.CFrame = cam.CFrame
        end)
    end)
end

local function StopFly()
    pcall(function()
        if flyBodyVelocity then flyBodyVelocity:Destroy() end
        if flyBodyGyro then flyBodyGyro:Destroy() end
        if flyConnection then flyConnection:Disconnect() end
        flyBodyVelocity = nil
        flyBodyGyro = nil
        flyConnection = nil
    end)
end

_G.BeyondConfig._StartFly = StartFly
_G.BeyondConfig._StopFly  = StopFly

-- Re-apply speed on respawn
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    if not _G.BeyondConfig then return end
    pcall(function()
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = _G.BeyondConfig.Movement.WalkSpeed
            hum.UseJumpPower = true
            hum.JumpPower = _G.BeyondConfig.Movement.JumpPower
        end
    end)
    if _G.BeyondConfig.FlyEnabled then StartFly() end
end)

-- Fly toggle watcher
task.spawn(function()
    while ScriptActive and task.wait(0.2) do
        if not _G.BeyondConfig then break end
        if _G.BeyondConfig.FlyEnabled and not flyConnection then
            StartFly()
        elseif not _G.BeyondConfig.FlyEnabled and flyConnection then
            StopFly()
        end
    end
end)

-- Anti-AFK
pcall(function()
    LocalPlayer.Idled:Connect(function()
        if not ScriptActive or not _G.BeyondConfig then return end
        if not _G.BeyondConfig.AntiAFK then return end
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(0, 0))
        end)
    end)
end)

-- ====================================================================
-- [11] ВКЛАДКА AUTOMATION
-- ====================================================================
local autoPage = TabPages["Auto"]

CreateSectionLabel(autoPage, "АВТОКЛИКЕР")

CreateMobileToggle(autoPage, "Активировать автокликер", _G.BeyondConfig.Automation.AutoClickEnabled, function(state)
    _G.BeyondConfig.Automation.AutoClickEnabled = state
    PushNotification("Automation", state and "AutoClick ON" or "AutoClick OFF",
        state and "success" or "warn")
    if state then
        task.spawn(function()
            while _G.BeyondConfig and _G.BeyondConfig.Automation.AutoClickEnabled and ScriptActive do
                local calculatedDelay = math.clamp(_G.BeyondConfig.Automation.ClickInterval / 1000, 0.01, 1.0)
                pcall(function()
                    if VirtualUser then
                        VirtualUser:CaptureController()
                        VirtualUser:ClickButton1(Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2))
                        _G.BeyondConfig.Automation.TotalClicksSimulated =
                            _G.BeyondConfig.Automation.TotalClicksSimulated + 1
                    else
                        local rayParams = RaycastParams.new()
                        rayParams.FilterType = Enum.RaycastFilterType.Exclude
                        rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
                        local rayResult = workspace:Raycast(Camera.CFrame.Position, Camera.CFrame.LookVector * 15, rayParams)
                        if rayResult and rayResult.Instance then
                            local clickDetector = rayResult.Instance:FindFirstChildOfClass("ClickDetector")
                            if clickDetector then
                                fireclickdetector(clickDetector)
                                _G.BeyondConfig.Automation.TotalClicksSimulated =
                                    _G.BeyondConfig.Automation.TotalClicksSimulated + 1
                            end
                        end
                    end
                end)
                pcall(function()
                    if FooterText and FooterText.Parent then
                        FooterText.Text = "Status: Operational // Macros Simulated: "
                            .. tostring(_G.BeyondConfig.Automation.TotalClicksSimulated)
                    end
                end)
                task.wait(calculatedDelay)
            end
        end)
    else
        pcall(function()
            if FooterText and FooterText.Parent then
                FooterText.Text = "Status: Operational // Mobile Touch Enabled"
            end
        end)
    end
end)

CreateMobileSlider(autoPage, "Интервал клика (мс)", 10, 1000, _G.BeyondConfig.Automation.ClickInterval, function(value)
    _G.BeyondConfig.Automation.ClickInterval = value
end)

CreateSectionLabel(autoPage, "АВТОПРЫЖОК")

CreateMobileToggle(autoPage, "Автопрыжок", false, function(state)
    _G.BeyondConfig.Automation.AutoJumpEnabled = state
    if state then
        task.spawn(function()
            while _G.BeyondConfig and _G.BeyondConfig.Automation.AutoJumpEnabled and ScriptActive do
                pcall(function()
                    local char = LocalPlayer.Character
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
                end)
                task.wait(_G.BeyondConfig.Automation.AutoJumpInterval / 1000)
            end
        end)
    end
end)

CreateMobileSlider(autoPage, "Интервал прыжка (мс)", 100, 2000, 300, function(value)
    _G.BeyondConfig.Automation.AutoJumpInterval = value
end)

CreateSectionLabel(autoPage, "МАКРОСЫ ЧАТА")

local ChatMacroData = {
    {Name = "Приветствие",    Phrase = "Привет всем! Beyond Client v6.0 запущен успешно."},
    {Name = "Предупреждение", Phrase = "Внимание, зафиксирована тактическая активность!"},
    {Name = "Проверка лагов", Phrase = "Мой текущий пинг стабилен на HONOR Play5."},
    {Name = "GG",             Phrase = "GG WP всем!"}
}

local function FireLegalChatMessage(textString)
    if not ScriptActive then return end
    pcall(function()
        if TextChatService and TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
            local textChannels = TextChatService:FindFirstChild("TextChannels")
            local generalChannel = textChannels and textChannels:FindFirstChild("RBXGeneral")
            if generalChannel and generalChannel:IsA("TextChannel") then
                generalChannel:SendAsync(textString)
                return
            end
        end
        local legacy = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
        local sayMessageRequest = legacy and legacy:FindFirstChild("SayMessageRequest")
        if sayMessageRequest and sayMessageRequest:IsA("RemoteEvent") then
            sayMessageRequest:FireServer(textString, "All")
        end
    end)
end

for _, macroInfo in ipairs(ChatMacroData) do
    local MacroFrame = CreateCardFrame(autoPage, 60)

    local MacroNameLabel = Instance.new("TextLabel")
    MacroNameLabel.Size = UDim2.new(0.6, 0, 0, 22)
    MacroNameLabel.Position = UDim2.new(0, 14, 0, 6)
    MacroNameLabel.Text = macroInfo.Name
    MacroNameLabel.TextColor3 = Color3.fromRGB(240, 240, 245)
    MacroNameLabel.Font = _G.BeyondConfig.Styles.FontsList.Bold
    MacroNameLabel.TextSize = 13
    MacroNameLabel.TextXAlignment = Enum.TextXAlignment.Left
    MacroNameLabel.BackgroundTransparency = 1
    MacroNameLabel.Parent = MacroFrame

    local MacroPhraseLabel = Instance.new("TextLabel")
    MacroPhraseLabel.Size = UDim2.new(0.6, 0, 0, 26)
    MacroPhraseLabel.Position = UDim2.new(0, 14, 0, 26)
    MacroPhraseLabel.Text = macroInfo.Phrase
    MacroPhraseLabel.TextColor3 = Color3.fromRGB(130, 130, 145)
    MacroPhraseLabel.Font = _G.BeyondConfig.Styles.FontsList.Regular
    MacroPhraseLabel.TextSize = 10
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
    Instance.new("UICorner", SendBtn).CornerRadius = UDim.new(0, 6)

    SendBtn.MouseButton1Click:Connect(function()
        if not ScriptActive or not _G.BeyondConfig then return end
        TweenService:Create(SendBtn, TweenInfo.new(0.1), {BackgroundColor3 = _G.BeyondConfig.ThemeColor}):Play()
        task.spawn(function()
            FireLegalChatMessage(macroInfo.Phrase)
            task.wait(0.2)
            if _G.BeyondConfig then
                TweenService:Create(SendBtn, TweenInfo.new(0.2),
                    {BackgroundColor3 = Color3.fromRGB(35, 35, 48)}):Play()
            end
        end)
    end)
end

-- ====================================================================
-- [12] ВКЛАДКА CONFIG
-- ====================================================================
local configPage = TabPages["Config"]

local BEYOND_CONFIG_BASE = "BeyondClient_V6_slot"
local FileSystemAPI = {
    Write  = writefile or (syn and syn.writefile),
    Read   = readfile  or (syn and syn.readfile),
    Check  = isfile    or (syn and syn.isfile),
    Delete = delfile   or (syn and syn.delfile),
    List   = listfiles or (syn and syn.listfiles)
}

CreateSectionLabel(configPage, "УПРАВЛЕНИЕ СЛОТАМИ")

local ConfigCardFrame = CreateCardFrame(configPage, 150)

local ConfigStatusLabel = Instance.new("TextLabel")
ConfigStatusLabel.Size = UDim2.new(1, -20, 0, 25)
ConfigStatusLabel.Position = UDim2.new(0, 14, 0, 4)
ConfigStatusLabel.Text = "Система: <font color='#00FF8C'>Готова к сериализации</font>"
ConfigStatusLabel.RichText = true
ConfigStatusLabel.TextColor3 = Color3.fromRGB(225, 225, 235)
ConfigStatusLabel.Font = _G.BeyondConfig.Styles.FontsList.Semibold
ConfigStatusLabel.TextSize = 13
ConfigStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
ConfigStatusLabel.BackgroundTransparency = 1
ConfigStatusLabel.Parent = ConfigCardFrame

local ActiveSlotLabel = Instance.new("TextLabel")
ActiveSlotLabel.Size = UDim2.new(1, -20, 0, 20)
ActiveSlotLabel.Position = UDim2.new(0, 14, 0, 30)
ActiveSlotLabel.Text = "Активный слот: <font color='#FF2B5A'>" .. _G.BeyondConfig.ConfigSlots.ActiveSlot .. "</font> / "
    .. _G.BeyondConfig.ConfigSlots.SlotCount
ActiveSlotLabel.RichText = true
ActiveSlotLabel.TextColor3 = Color3.fromRGB(215, 215, 225)
ActiveSlotLabel.Font = _G.BeyondConfig.Styles.FontsList.Regular
ActiveSlotLabel.TextSize = 12
ActiveSlotLabel.TextXAlignment = Enum.TextXAlignment.Left
ActiveSlotLabel.BackgroundTransparency = 1
ActiveSlotLabel.Parent = ConfigCardFrame

local function PushConfigStatusUpdate(htmlText)
    if ConfigStatusLabel and ConfigStatusLabel.Parent then
        ConfigStatusLabel.Text = "Система: " .. htmlText
    end
end

local function UpdateActiveSlotLabel()
    if ActiveSlotLabel and ActiveSlotLabel.Parent then
        ActiveSlotLabel.Text = "Активный слот: <font color='#FF2B5A'>"
            .. _G.BeyondConfig.ConfigSlots.ActiveSlot .. "</font> / "
            .. _G.BeyondConfig.ConfigSlots.SlotCount
    end
end

local function SerializeConfig()
    return {
        SpeedValue             = _G.BeyondConfig.Movement.WalkSpeed,
        JumpPower              = _G.BeyondConfig.Movement.JumpPower,
        FlySpeed               = _G.BeyondConfig.Movement.FlySpeed,
        InfiniteJump           = _G.BeyondConfig.InfiniteJump,
        Noclip                 = _G.BeyondConfig.Noclip,
        FlyEnabled             = _G.BeyondConfig.FlyEnabled,
        AntiAFK                = _G.BeyondConfig.AntiAFK,
        ThemeColor             = {_G.BeyondConfig.ThemeColor.R, _G.BeyondConfig.ThemeColor.G, _G.BeyondConfig.ThemeColor.B},
        HighlightESP           = _G.BeyondConfig.Visuals.HighlightESP,
        EspFillTransparency    = _G.BeyondConfig.Visuals.EspFillTransparency,
        EspOutlineTransparency = _G.BeyondConfig.Visuals.EspOutlineTransparency,
        RainbowGlow            = _G.BeyondConfig.Visuals.RainbowGlow,
        GlowSpeed              = _G.BeyondConfig.Visuals.GlowSpeed,
        AutoClickEnabled       = _G.BeyondConfig.Automation.AutoClickEnabled,
        ClickInterval          = _G.BeyondConfig.Automation.ClickInterval,
        CrosshairEnabled       = _G.BeyondConfig.Crosshair.Enabled,
        CrosshairSize          = _G.BeyondConfig.Crosshair.Size,
        CrosshairThickness     = _G.BeyondConfig.Crosshair.Thickness,
        CrosshairGap           = _G.BeyondConfig.Crosshair.Gap,
        CurrentThemePreset     = _G.BeyondConfig.Styles.CurrentThemePreset
    }
end

local function SaveConfigToSlot()
    if not FileSystemAPI.Write then
        PushConfigStatusUpdate("<font color='#FF2B5A'>WriteFile недоступен</font>")
        return
    end
    local slot = _G.BeyondConfig.ConfigSlots.ActiveSlot
    local fileName = BEYOND_CONFIG_BASE .. tostring(slot) .. ".json"
    local okSer, encoded = pcall(function()
        return HttpService:JSONEncode(SerializeConfig())
    end)
    if not (okSer and encoded) then
        PushConfigStatusUpdate("<font color='#FF2B5A'>Ошибка сериализации</font>")
        return
    end
    local okWrite = pcall(function() FileSystemAPI.Write(fileName, encoded) end)
    if okWrite then
        PushConfigStatusUpdate("<font color='#00FF8C'>Слот " .. slot .. " сохранён!</font>")
        PushNotification("Config", "Профиль сохранён в слот " .. slot, "success")
    else
        PushConfigStatusUpdate("<font color='#FF2B5A'>Ошибка записи файла</font>")
    end
end

local function LoadConfigFromSlot()
    if not FileSystemAPI.Read or not FileSystemAPI.Check then
        PushConfigStatusUpdate("<font color='#FF2B5A'>ReadFile недоступен</font>")
        return
    end
    local slot = _G.BeyondConfig.ConfigSlots.ActiveSlot
    local fileName = BEYOND_CONFIG_BASE .. tostring(slot) .. ".json"
    if not FileSystemAPI.Check(fileName) then
        PushConfigStatusUpdate("<font color='#FFBB00'>Слот " .. slot .. " пуст</font>")
        return
    end
    local okRead, fileRaw = pcall(function() return FileSystemAPI.Read(fileName) end)
    if not (okRead and fileRaw) then
        PushConfigStatusUpdate("<font color='#FF2B5A'>Ошибка чтения файла</font>")
        return
    end
    local okDecode, decoded = pcall(function() return HttpService:JSONDecode(fileRaw) end)
    if not (okDecode and decoded) then
        PushConfigStatusUpdate("<font color='#FF2B5A'>Ошибка JSON</font>")
        return
    end
    pcall(function()
        if decoded.SpeedValue             then _G.BeyondConfig.Movement.WalkSpeed = decoded.SpeedValue end
        if decoded.JumpPower              then _G.BeyondConfig.Movement.JumpPower = decoded.JumpPower end
        if decoded.FlySpeed               then _G.BeyondConfig.Movement.FlySpeed = decoded.FlySpeed end
        if decoded.InfiniteJump           then _G.BeyondConfig.InfiniteJump = decoded.InfiniteJump end
        if decoded.Noclip                 then _G.BeyondConfig.Noclip = decoded.Noclip end
        if decoded.FlyEnabled             then _G.BeyondConfig.FlyEnabled = decoded.FlyEnabled end
        if decoded.AntiAFK                then _G.BeyondConfig.AntiAFK = decoded.AntiAFK end
        if decoded.HighlightESP           then _G.BeyondConfig.Visuals.HighlightESP = decoded.HighlightESP end
        if decoded.EspFillTransparency    then _G.BeyondConfig.Visuals.EspFillTransparency = decoded.EspFillTransparency end
        if decoded.EspOutlineTransparency then _G.BeyondConfig.Visuals.EspOutlineTransparency = decoded.EspOutlineTransparency end
        if decoded.RainbowGlow            then _G.BeyondConfig.Visuals.RainbowGlow = decoded.RainbowGlow end
        if decoded.GlowSpeed              then _G.BeyondConfig.Visuals.GlowSpeed = decoded.GlowSpeed end
        if decoded.AutoClickEnabled       then _G.BeyondConfig.Automation.AutoClickEnabled = decoded.AutoClickEnabled end
        if decoded.ClickInterval          then _G.BeyondConfig.Automation.ClickInterval = decoded.ClickInterval end
        if decoded.CurrentThemePreset     then _G.BeyondConfig.Styles.CurrentThemePreset = decoded.CurrentThemePreset end
        if decoded.ThemeColor then
            _G.BeyondConfig.ThemeColor = Color3.new(decoded.ThemeColor[1], decoded.ThemeColor[2], decoded.ThemeColor[3])
        end
    end)
    PushConfigStatusUpdate("<font color='#00FF8C'>Слот " .. slot .. " применён!</font>")
    PushNotification("Config", "Профиль загружен из слота " .. slot, "success")
end

local SlotRow = Instance.new("Frame")
SlotRow.Size = UDim2.new(1, -20, 0, 30)
SlotRow.Position = UDim2.new(0, 10, 0, 56)
SlotRow.BackgroundTransparency = 1
SlotRow.Parent = ConfigCardFrame

local SlotBtnLayout = Instance.new("UIListLayout")
SlotBtnLayout.FillDirection = Enum.FillDirection.Horizontal
SlotBtnLayout.Padding = UDim.new(0, 6)
SlotBtnLayout.Parent = SlotRow

for i = 1, _G.BeyondConfig.ConfigSlots.SlotCount do
    local SlotBtn = Instance.new("TextButton")
    SlotBtn.Size = UDim2.new(0, 42, 0, 28)
    SlotBtn.BackgroundColor3 = (i == _G.BeyondConfig.ConfigSlots.ActiveSlot)
        and _G.BeyondConfig.ThemeColor or Color3.fromRGB(34, 34, 46)
    SlotBtn.Text = "S" .. i
    SlotBtn.TextColor3 = Color3.fromRGB(245, 245, 250)
    SlotBtn.Font = _G.BeyondConfig.Styles.FontsList.Bold
    SlotBtn.TextSize = 11
    SlotBtn.LayoutOrder = i
    SlotBtn.Parent = SlotRow
    Instance.new("UICorner", SlotBtn).CornerRadius = UDim.new(0, 5)

    SlotBtn.MouseButton1Click:Connect(function()
        if not ScriptActive then return end
        _G.BeyondConfig.ConfigSlots.ActiveSlot = i
        for _, child in ipairs(SlotRow:GetChildren()) do
            if child:IsA("TextButton") then
                local idx = tonumber(child.Text:sub(2))
                TweenService:Create(child, TweenInfo.new(0.2), {
                    BackgroundColor3 = (idx == i) and _G.BeyondConfig.ThemeColor or Color3.fromRGB(34, 34, 46)
                }):Play()
            end
        end
        UpdateActiveSlotLabel()
    end)
end

local SaveRow = Instance.new("Frame")
SaveRow.Size = UDim2.new(1, -20, 0, 38)
SaveRow.Position = UDim2.new(0, 10, 0, 96)
SaveRow.BackgroundTransparency = 1
SaveRow.Parent = ConfigCardFrame

local SaveBtn = Instance.new("TextButton")
SaveBtn.Size = UDim2.new(0.48, 0, 1, 0)
SaveBtn.Position = UDim2.new(0, 0, 0, 0)
SaveBtn.BackgroundColor3 = Color3.fromRGB(34, 46, 38)
SaveBtn.Text = "СОХРАНИТЬ"
SaveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SaveBtn.Font = _G.BeyondConfig.Styles.FontsList.Bold
SaveBtn.TextSize = 11
SaveBtn.Parent = SaveRow
Instance.new("UICorner", SaveBtn).CornerRadius = UDim.new(0, 6)
SaveBtn.MouseButton1Click:Connect(function() if ScriptActive then SaveConfigToSlot() end end)

local LoadBtn = Instance.new("TextButton")
LoadBtn.Size = UDim2.new(0.48, 0, 1, 0)
LoadBtn.Position = UDim2.new(0.52, 0, 0, 0)
LoadBtn.BackgroundColor3 = Color3.fromRGB(34, 38, 46)
LoadBtn.Text = "ЗАГРУЗИТЬ"
LoadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
LoadBtn.Font = _G.BeyondConfig.Styles.FontsList.Bold
LoadBtn.TextSize = 11
LoadBtn.Parent = SaveRow
Instance.new("UICorner", LoadBtn).CornerRadius = UDim.new(0, 6)
LoadBtn.MouseButton1Click:Connect(function() if ScriptActive then LoadConfigFromSlot() end end)

CreateSectionLabel(configPage, "УТИЛИТЫ")

CreateActionButton(configPage, "СБРОСИТЬ ВСЕ НАСТРОЙКИ", Color3.fromRGB(60, 30, 34), function()
    pcall(function()
        _G.BeyondConfig.Movement.WalkSpeed   = 16
        _G.BeyondConfig.Movement.JumpPower   = 50
        _G.BeyondConfig.Movement.FlySpeed    = 60
        _G.BeyondConfig.InfiniteJump         = false
        _G.BeyondConfig.Noclip               = false
        _G.BeyondConfig.FlyEnabled           = false
        _G.BeyondConfig.Visuals.HighlightESP = false
        _G.BeyondConfig.Visuals.RainbowGlow  = false
    end)
    PushNotification("Config", "Настройки сброшены к дефолту", "warn")
end)

CreateActionButton(configPage, "СОХРАНИТЬ КАК ФАЙЛ .TXT", Color3.fromRGB(34, 34, 46), function()
    if not FileSystemAPI.Write then
        PushNotification("Config", "WriteFile недоступен", "error")
        return
    end
    pcall(function()
        FileSystemAPI.Write("BeyondClient_export.txt", HttpService:JSONEncode(SerializeConfig()))
        PushNotification("Config", "Экспортировано в BeyondClient_export.txt", "success")
    end)
end)

-- ====================================================================
-- [13] ВКЛАДКА DEBUG
-- ====================================================================
local debugPage = TabPages["Debug"]

local TelemetryData = {
    CurrentFps = 60, CurrentPing = 0, CurrentMemory = 0,
    FrameCount = 0,  TimeCounter = 0
}

CreateSectionLabel(debugPage, "ТЕЛЕМЕТРИЯ")

local StatsCardFrame = CreateCardFrame(debugPage, 105)

local function CreateStatDisplayLabel(nameTag, yPosition)
    local DisplayLabel = Instance.new("TextLabel")
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

local FpsDisplay  = CreateStatDisplayLabel("FPS",  10)
local PingDisplay = CreateStatDisplayLabel("Ping", 38)
local MemDisplay  = CreateStatDisplayLabel("Memory", 66)

task.spawn(function()
    while ScriptActive and _G.BeyondConfig and task.wait(0.5) do
        pcall(function()
            if NetworkStats then
                TelemetryData.CurrentPing = math.round(NetworkStats.ServerPing)
            end
            TelemetryData.CurrentMemory = math.round(StatsService:GetTotalMemoryUsageMb())
            local fpsColor  = TelemetryData.CurrentFps >= 45 and "#00FF8C" or (TelemetryData.CurrentFps >= 25 and "#FFBB00" or "#FF2B5A")
            local pingColor = TelemetryData.CurrentPing <= 90 and "#00FF8C" or (TelemetryData.CurrentPing <= 200 and "#FFBB00" or "#FF2B5A")
            FpsDisplay.Text  = "FPS: <font color='" .. fpsColor .. "'>" .. tostring(TelemetryData.CurrentFps) .. "</font>"
            PingDisplay.Text = "Ping: <font color='" .. pingColor .. "'>" .. tostring(TelemetryData.CurrentPing) .. " ms</font>"
            MemDisplay.Text  = "Memory: <font color='#00BFFF'>" .. tostring(TelemetryData.CurrentMemory) .. " MB</font>"
        end)
    end
end)

RunService.RenderStepped:Connect(function(deltaTime)
    if not ScriptActive then return end
    TelemetryData.FrameCount  = TelemetryData.FrameCount + 1
    TelemetryData.TimeCounter = TelemetryData.TimeCounter + deltaTime
    if TelemetryData.TimeCounter >= 1.0 then
        TelemetryData.CurrentFps = math.round(TelemetryData.FrameCount / TelemetryData.TimeCounter)
        TelemetryData.FrameCount  = 0
        TelemetryData.TimeCounter = 0
    end
end)

CreateSectionLabel(debugPage, "ОПТИМИЗАЦИЯ ГРАФИКИ")

local function ToggleEnvironmentOptimization(enableOptimization)
    if not ScriptActive or not _G.BeyondConfig then return end
    pcall(function()
        if enableOptimization then
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 100000
            if Terrain then
                Terrain.WaterWaveSize = 0
                Terrain.WaterWaveSpeed = 0
                Terrain.WaterReflectance = 0
                Terrain.WaterTransparency = 0
            end
            for _, effect in ipairs(Lighting:GetChildren()) do
                if effect:IsA("PostEffect") or effect:IsA("BloomEffect")
                   or effect:IsA("SunRaysEffect") or effect:IsA("Atmosphere") then
                    if effect.Name ~= "Beyond_Interface_Blur" then
                        effect.Enabled = false
                    end
                end
            end
            for _, d in ipairs(workspace:GetDescendants()) do
                if d:IsA("ParticleEmitter") or d:IsA("Smoke") or d:IsA("Fire") or d:IsA("Sparkles") then
                    d.Enabled = false
                end
            end
            PushConfigStatusUpdate("<font color='#00FF8C'>FPS Бустер: ON</font>")
        else
            Lighting.GlobalShadows = _G.BeyondConfig.PerformanceBoost.OriginalShadows
            Lighting.FogEnd = _G.BeyondConfig.PerformanceBoost.OriginalFogEnd or 100000
            if Terrain then
                Terrain.WaterWaveSize = 0.15
                Terrain.WaterWaveSpeed = 1
                Terrain.WaterReflectance = 1
                Terrain.WaterTransparency = 1
            end
            for _, effect in ipairs(Lighting:GetChildren()) do
                if effect:IsA("PostEffect") or effect:IsA("BloomEffect")
                   or effect:IsA("SunRaysEffect") or effect:IsA("Atmosphere") then
                    if effect.Name ~= "Beyond_Interface_Blur" then
                        effect.Enabled = true
                    end
                end
            end
            for _, d in ipairs(workspace:GetDescendants()) do
                if d:IsA("ParticleEmitter") or d:IsA("Smoke") or d:IsA("Fire") or d:IsA("Sparkles") then
                    d.Enabled = true
                end
            end
            PushConfigStatusUpdate("<font color='#FFBB00'>FPS Бустер: OFF</font>")
        end
    end)
end

CreateMobileToggle(debugPage, "Оптимизация рендеринга (FPS Boost)",
    _G.BeyondConfig.PerformanceBoost.OptimizerActive,
    function(state)
        _G.BeyondConfig.PerformanceBoost.OptimizerActive = state
        ToggleEnvironmentOptimization(state)
        PushNotification("Graphics", state and "FPS Boost ON" or "FPS Boost OFF",
            state and "success" or "warn")
    end)

CreateSectionLabel(debugPage, "КОНСОЛЬ СОБЫТИЙ")

local ConsoleBoxFrame = Instance.new("ScrollingFrame")
ConsoleBoxFrame.Size = UDim2.new(1, 0, 0, 160)
ConsoleBoxFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
ConsoleBoxFrame.BorderSizePixel = 0
ConsoleBoxFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ConsoleBoxFrame.ScrollBarThickness = 3
ConsoleBoxFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 90)
ConsoleBoxFrame.Parent = debugPage
Instance.new("UICorner", ConsoleBoxFrame).CornerRadius = UDim.new(0, 8)

local ConsoleStroke = Instance.new("UIStroke")
ConsoleStroke.Thickness = 1
ConsoleStroke.Color = _G.BeyondConfig.Styles.BorderStrokeColor
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

function PrintToBeyondConsole(logText, logType)
    if not ScriptActive or not _G.BeyondConfig then return end
    _G.BeyondConfig.Logger.LogCount = _G.BeyondConfig.Logger.LogCount + 1
    local textColor = Color3.fromRGB(240, 240, 245)
    if logType == "warn" then textColor = Color3.fromRGB(255, 185, 0)
    elseif logType == "error" then textColor = Color3.fromRGB(255, 43, 90)
    elseif logType == "success" then textColor = Color3.fromRGB(0, 255, 140) end
    local systemTime = os.date("%H:%M:%S")
    local LogLineLabel = Instance.new("TextLabel")
    LogLineLabel.Size = UDim2.new(1, 0, 0, 16)
    LogLineLabel.BackgroundTransparency = 1
    LogLineLabel.Text = string.format("[%s] %s", systemTime, logText)
    LogLineLabel.TextColor3 = textColor
    LogLineLabel.Font = _G.BeyondConfig.Styles.FontsList.Monospace
    LogLineLabel.TextSize = 11
    LogLineLabel.TextXAlignment = Enum.TextXAlignment.Left
    LogLineLabel.LayoutOrder = _G.BeyondConfig.Logger.LogCount
    LogLineLabel.Parent = ConsoleBoxFrame

    local labels = {}
    for _, item in ipairs(ConsoleBoxFrame:GetChildren()) do
        if item:IsA("TextLabel") then table.insert(labels, item) end
    end
    if #labels > _G.BeyondConfig.Logger.MaxLinesStored then
        labels[1]:Destroy()
    end

    ConsoleBoxFrame.CanvasSize = UDim2.new(0, 0, 0, ConsoleListLayout.AbsoluteContentSize.Y + 12)
    ConsoleBoxFrame.CanvasPosition = Vector2.new(0, ConsoleListLayout.AbsoluteContentSize.Y)
end

CreateActionButton(debugPage, "ОЧИСТИТЬ КОНСОЛЬ", Color3.fromRGB(28, 28, 38), function()
    for _, item in ipairs(ConsoleBoxFrame:GetChildren()) do
        if item:IsA("TextLabel") then item:Destroy() end
    end
    ConsoleBoxFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    PrintToBeyondConsole("Консоль очищена.", "warn")
end)

CreateSectionLabel(debugPage, "АУДИО-ОТКЛИК")

local BeyondAudioChannel = SoundService:FindFirstChild("Beyond_Interface_Audio")
if not BeyondAudioChannel then
    BeyondAudioChannel = Instance.new("Folder")
    BeyondAudioChannel.Name = "Beyond_Interface_Audio"
    BeyondAudioChannel.Parent = SoundService
end

local function PlayInterfaceSound(assetId, volumeMultiplier)
    if not ScriptActive or not _G.BeyondConfig or _G.BeyondConfig.Audio.MuteAll then return end
    task.spawn(function()
        local ok, sound = pcall(function()
            local s = Instance.new("Sound")
            s.SoundId = assetId
            s.Volume = _G.BeyondConfig.Audio.MasterVolume * (volumeMultiplier or 1)
            s.PlayOnRemove = true
            s.Parent = BeyondAudioChannel
            return s
        end)
        if ok and sound then sound:Destroy() end
    end)
end

local function HookSoundToUIElement(instanceElement, isSlider)
    if not instanceElement or not instanceElement:IsA("GuiButton") then return end
    instanceElement.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
           or input.UserInputType == Enum.UserInputType.MouseButton1 then
            PlayInterfaceSound(isSlider and _G.BeyondConfig.Audio.AssetHoverId
                                        or _G.BeyondConfig.Audio.AssetClickId,
                               isSlider and 0.7 or 1.0)
        end
    end)
end

HookSoundToUIElement(MinimizeBtn, false)
HookSoundToUIElement(CloseBtn, false)
HookSoundToUIElement(MobileToggleButton, false)

CreateMobileToggle(debugPage, "Беззвучный режим (Mute)", _G.BeyondConfig.Audio.MuteAll, function(state)
    _G.BeyondConfig.Audio.MuteAll = state
end)

CreateMobileSlider(debugPage, "Громкость UI (%)",
    0, 100, math.round(_G.BeyondConfig.Audio.MasterVolume * 100),
    function(val) _G.BeyondConfig.Audio.MasterVolume = val / 100 end)

task.spawn(function()
    while ScriptActive and task.wait(0.5) do
        pcall(function()
            for _, desc in ipairs(Container:GetDescendants()) do
                if desc:IsA("TextButton") and not desc:GetAttribute("AudioHooked") then
                    desc:SetAttribute("AudioHooked", true)
                    local isSliderBtn = desc.Parent and desc.Parent.Name == "Track"
                    HookSoundToUIElement(desc, isSliderBtn)
                end
            end
        end)
    end
end)

-- ====================================================================
-- [14] BOOT
-- ====================================================================
task.spawn(function()
    task.wait(0.8)
    PrintToBeyondConsole("BeyondClient v6.0 (Thick) успешно скомпилирован!", "success")
    PrintToBeyondConsole("Архитектура адаптирована под HONOR Play5.", "info")
    PrintToBeyondConsole("Все модули ядра находятся в активном статусе.", "success")
    PushNotification("Beyond", "BeyondClient v6.0 загружен!", "success")
end)

MainFrame.Size = UDim2.new(0, 460, 0, 0)
MainFrame.ClipsDescendants = true
MainFrame.Visible = true

local finalBootTween = TweenService:Create(
    MainFrame,
    TweenInfo.new(0.7, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    {Size = UDim2.new(0, 460, 0, 380)}
)
finalBootTween:Play()
finalBootTween.Completed:Connect(function()
    if MainFrame then MainFrame.ClipsDescendants = false end
end)

-- Panic key
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if not ScriptActive or not _G.BeyondConfig then return end
    if input.KeyCode == _G.BeyondConfig.Keybinds.PanicKey then
        if _G.BeyondClient_SelfDestruct then _G.BeyondClient_SelfDestruct() end
    end
end)

print("[BeyondClient v6.0 Thick]: Полная сборка успешно развернута. Размер ~30 КБ.")
