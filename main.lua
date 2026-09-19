--[[
    BeyondClient v6.2 - Adaptive Edition
    Target: HONOR Play5 (HJC-AN90 / Dimensity 800U / 8GB / 2400x1080 / DPI 440 / Android 10)
    Developer: UserBeyond-dev
    File: main.lua (Full single-file build)

    v6.2 CHANGELOG:
      [+] Адаптивный UIScale от ViewportSize (авто-подгон под экран)
      [+] MainFrame увеличен до 640x560 (было 460x380)
      [+] Все тач-кнопки минимум 44x44 px
      [+] Единый RenderStepped (было 4 -> стало 1) — экономия CPU
      [+] Distance-based ESP (слайдер MaxDistance 10-500 studs)
      [+] Автоотключение ESP при FPS ниже порога
      [+] Loading spinner на кнопках Config
      [+] Плавный Tween на всех переходах UI
      [+] Fallback _G.BeyondFS для Delta
--]]

-- ====================================================================
-- [1] SERVICES
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

local NetworkStats = StatsService:FindFirstChild("Network")
local Terrain      = workspace:FindFirstChildOfClass("Terrain")

local VirtualUser = nil
pcall(function() VirtualUser = game:GetService("VirtualUser") end)

local LocalPlayer = Players.LocalPlayer
local Camera      = workspace.CurrentCamera or workspace:WaitForChild("Camera")

if _G.BeyondClient_SelfDestruct then pcall(_G.BeyondClient_SelfDestruct) end

-- ====================================================================
-- [2] ADAPTIVE UI SCALE (под 2400x1080 @ DPI 440)
-- ====================================================================
local function CalculateAdaptiveScale()
    local vp = Camera.ViewportSize
    -- Базовое разрешение = 1600x720 (Roblox рендерит в уменьшенном масштабе на мобилке)
    -- Для 2400x1080 это ~1.5, для 1600x720 это 1.0
    local scaleByWidth  = vp.X / 1600
    local scaleByHeight = vp.Y / 720
    local scale = math.clamp(math.min(scaleByWidth, scaleByHeight), 0.75, 1.6)
    return scale
end

-- ====================================================================
-- [3] ГЛОБАЛЬНЫЙ КОНФИГ
-- ====================================================================
_G.BeyondConfig = {
    Version    = "6.2-Adaptive",
    Developer  = "UserBeyond-dev",
    DeviceTarget = "HONOR Play5 / 2400x1080 / DPI 440",

    SpeedValue   = 16,
    JumpPower    = 50,
    InfiniteJump = false,
    Noclip       = false,
    FlyEnabled   = false,
    FlySpeed     = 60,
    AntiAFK      = true,

    ThemeColor  = Color3.fromRGB(255, 43, 90),
    AccentGlow  = Color3.fromRGB(255, 100, 130),
    BgColor     = Color3.fromRGB(15, 15, 20),
    CardColor   = Color3.fromRGB(22, 22, 30),
    HeaderColor = Color3.fromRGB(28, 26, 36),

    IsMenuOpened = true,
    GlowPhase    = 0,
    ActiveTab    = "Visual",
    UIScale      = 1,

    Visuals = {
        HighlightESP           = false,
        EspOutlineTransparency = 0,
        EspFillTransparency    = 0.5,
        MaxDistance            = 300,      -- НОВОЕ: дистанция ESP
        FpsAutoDisable         = true,     -- НОВОЕ: авто-выкл при лагах
        FpsThreshold           = 20,
        RainbowGlow            = false,
        GlowSpeed              = 50
    },

    Movement = {
        WalkSpeed = 16,
        JumpPower = 50,
        FlySpeed  = 60
    },

    Automation = {
        AutoClickEnabled     = false,
        ClickInterval        = 100,
        TotalClicksSimulated = 0,
        AutoJumpEnabled      = false,
        AutoJumpInterval     = 300
    },

    Crosshair = {
        Enabled   = false,
        Size      = 18,     -- увеличено под DPI 440
        Thickness = 3,      -- увеличено
        Gap       = 6,      -- увеличено
        CenterDot = false,
        Color     = Color3.fromRGB(255, 43, 90)
    },

    Audio = {
        MuteAll      = false,
        MasterVolume = 0.5,
        AssetClickId = "rbxassetid://6140381534",
        AssetHoverId = "rbxassetid://6895079633"
    },

    Logger = {
        MaxLinesStored = 80,
        LogCount       = 0
    },

    PerformanceBoost = {
        OptimizerActive = false,
        OriginalShadows = Lighting.GlobalShadows,
        OriginalFogEnd  = Lighting.FogEnd
    },

    Notifications = {
        Enabled  = true,
        Duration = 3
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
        PanicKey = Enum.KeyCode.End
    }
}

local ScriptActive = true
_G.BeyondScriptActive = true

-- ====================================================================
-- [4] FILE SYSTEM API — ДУБЛИРУЕМ В _G (Delta-safe)
-- ====================================================================
local FileSystemAPI = {
    Write  = writefile or (syn and syn.writefile) or (getgenv and getgenv().writefile),
    Read   = readfile  or (syn and syn.readfile)  or (getgenv and getgenv().readfile),
    Check  = isfile    or (syn and syn.isfile)    or (getgenv and getgenv().isfile),
    Delete = delfile   or (syn and syn.delfile)   or (getgenv and getgenv().delfile),
    List   = listfiles or (syn and syn.listfiles) or (getgenv and getgenv().listfiles)
}
_G.BeyondFS = FileSystemAPI

local BEYOND_CONFIG_BASE = "BeyondClient_V62_slot"

-- ====================================================================
-- [5] UI SCAFFOLDING (адаптировано под 2400x1080)
-- ====================================================================
local BeyondScreenGui = Instance.new("ScreenGui")
BeyondScreenGui.Name = "Beyond_" .. HttpService:GenerateGUID(false):sub(1, 8)
BeyondScreenGui.ResetOnSpawn = false
BeyondScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
local okParent = pcall(function() BeyondScreenGui.Parent = CoreGui end)
if not okParent then BeyondScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- MainFrame с базовым размером 640x560 (для 1600x720 Roblox viewport)
-- UIScale будет масштабировать дальше
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainPanel"
MainFrame.Size = UDim2.new(0, 640, 0, 560)
MainFrame.Position = UDim2.new(0.5, -320, 0.5, -280)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = _G.BeyondConfig.BgColor
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = BeyondScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 16)

-- АДАПТИВНЫЙ UIScale
local MainUIScale = Instance.new("UIScale")
MainUIScale.Scale = CalculateAdaptiveScale()
MainUIScale.Parent = MainFrame
_G.BeyondConfig.UIScale = MainUIScale.Scale

local Stroke = Instance.new("UIStroke")
Stroke.Thickness = 2
Stroke.Color = _G.BeyondConfig.ThemeColor
Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
Stroke.Parent = MainFrame

-- Header (высота 56 вместо 45 — под DPI 440)
local Header = Instance.new("Frame")
Header.Name = "HeaderZone"
Header.Size = UDim2.new(1, 0, 0, 56)
Header.BackgroundColor3 = _G.BeyondConfig.HeaderColor
Header.BorderSizePixel = 0
Header.Parent = MainFrame
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 16)

local HeaderLine = Instance.new("Frame")
HeaderLine.Size = UDim2.new(1, 0, 0, 2)
HeaderLine.Position = UDim2.new(0, 0, 1, -2)
HeaderLine.BackgroundColor3 = _G.BeyondConfig.ThemeColor
HeaderLine.BorderSizePixel = 0
HeaderLine.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -200, 1, 0)
Title.Position = UDim2.new(0, 20, 0, 0)
Title.Text = "BEYOND <font color='#FF2B5A'>CLIENT</font> <font color='#A0A0A5'>v6.2</font>"
Title.RichText = true
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
Title.Parent = Header

-- Плавающая кнопка вызова (увеличена до 64x64 под DPI 440)
local MobileToggleButton = Instance.new("ImageButton")
MobileToggleButton.Name = "BeyondMobileCall"
MobileToggleButton.Size = UDim2.new(0, 64, 0, 64)
MobileToggleButton.Position = UDim2.new(0, 24, 0.25, 0)
MobileToggleButton.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
MobileToggleButton.BorderSizePixel = 0
MobileToggleButton.Image = "rbxassetid://16024021200"
MobileToggleButton.ImageColor3 = _G.BeyondConfig.ThemeColor
MobileToggleButton.ZIndex = 15
MobileToggleButton.Visible = false
MobileToggleButton.Parent = BeyondScreenGui
Instance.new("UICorner", MobileToggleButton).CornerRadius = UDim.new(1, 0)
local ButtonStroke = Instance.new("UIStroke", MobileToggleButton)
ButtonStroke.Thickness = 3
ButtonStroke.Color = _G.BeyondConfig.ThemeColor

local MobileButtonScale = Instance.new("UIScale")
MobileButtonScale.Scale = CalculateAdaptiveScale()
MobileButtonScale.Parent = MobileToggleButton

-- Minimize (44x44 вместо 32x32)
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Name = "Minimize"
MinimizeBtn.Size = UDim2.new(0, 44, 0, 44)
MinimizeBtn.Position = UDim2.new(1, -104, 0.5, -22)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(38, 38, 50)
MinimizeBtn.Text = "—"
MinimizeBtn.TextColor3 = Color3.fromRGB(220, 220, 235)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 18
MinimizeBtn.Parent = Header
Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 8)

-- Close (44x44)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "Close"
CloseBtn.Size = UDim2.new(0, 44, 0, 44)
CloseBtn.Position = UDim2.new(1, -56, 0.5, -22)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 43, 90)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.Parent = Header
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)

-- TabBar (высота 44 вместо 34)
local TabBar = Instance.new("Frame")
TabBar.Name = "TabBar"
TabBar.Size = UDim2.new(1, -24, 0, 44)
TabBar.Position = UDim2.new(0, 12, 0, 66)
TabBar.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
TabBar.BorderSizePixel = 0
TabBar.Parent = MainFrame
Instance.new("UICorner", TabBar).CornerRadius = UDim.new(0, 10)

local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.Padding = UDim.new(0, 6)
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabLayout.Parent = TabBar

local TabPadding = Instance.new("UIPadding")
TabPadding.PaddingLeft = UDim.new(0, 6)
TabPadding.PaddingTop = UDim.new(0, 6)
TabPadding.Parent = TabBar

-- Container
local Container = Instance.new("ScrollingFrame")
Container.Name = "ModuleContainer"
Container.Size = UDim2.new(1, -24, 1, -186)
Container.Position = UDim2.new(0, 12, 0, 122)
Container.BackgroundTransparency = 1
Container.BorderSizePixel = 0
Container.CanvasSize = UDim2.new(0, 0, 0, 700)
Container.ScrollBarThickness = 5
Container.ScrollBarImageColor3 = _G.BeyondConfig.ThemeColor
Container.Parent = MainFrame

local Footer = Instance.new("Frame")
Footer.Name = "Footer"
Footer.Size = UDim2.new(1, 0, 0, 32)
Footer.Position = UDim2.new(0, 0, 1, -32)
Footer.BackgroundColor3 = Color3.fromRGB(22, 20, 28)
Footer.BorderSizePixel = 0
Footer.Parent = MainFrame
Instance.new("UICorner", Footer).CornerRadius = UDim.new(0, 16)

local FooterText = Instance.new("TextLabel")
FooterText.Name = "FooterText"
FooterText.Size = UDim2.new(1, -24, 1, 0)
FooterText.Position = UDim2.new(0, 14, 0, 0)
FooterText.BackgroundTransparency = 1
FooterText.Text = "Status: Operational // Adaptive Mode ON"
FooterText.TextColor3 = Color3.fromRGB(150, 150, 165)
FooterText.Font = Enum.Font.Code
FooterText.TextSize = 12
FooterText.TextXAlignment = Enum.TextXAlignment.Left
FooterText.Parent = Footer

-- Tab storage
local Tabs = {}
local TabPages = {}
local ActiveTabName = "Visual"

-- ====================================================================
-- [6] СИСТЕМА УВЕДОМЛЕНИЙ
-- ====================================================================
local NotifyFolder = Instance.new("ScreenGui")
NotifyFolder.Name = "Beyond_Notifications"
NotifyFolder.ResetOnSpawn = false
NotifyFolder.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
local okNotif = pcall(function() NotifyFolder.Parent = CoreGui end)
if not okNotif then NotifyFolder.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local NotifyStack = {}

function PushNotification(title, message, notifType)
    if not ScriptActive or not _G.BeyondConfig then return end
    if not _G.BeyondConfig.Notifications.Enabled then return end

    local accentColor = _G.BeyondConfig.ThemeColor
    if notifType == "warn" then accentColor = Color3.fromRGB(255, 185, 0)
    elseif notifType == "error" then accentColor = Color3.fromRGB(255, 60, 80)
    elseif notifType == "success" then accentColor = Color3.fromRGB(0, 220, 130) end

    local notifFrame = Instance.new("Frame")
    notifFrame.Size = UDim2.new(0, 320, 0, 0)
    notifFrame.Position = UDim2.new(1, -340, 0, 100)
    notifFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
    notifFrame.BorderSizePixel = 0
    notifFrame.ClipsDescendants = true
    notifFrame.Parent = NotifyFolder
    Instance.new("UICorner", notifFrame).CornerRadius = UDim.new(0, 12)

    local notifScale = Instance.new("UIScale")
    notifScale.Scale = CalculateAdaptiveScale()
    notifScale.Parent = notifFrame

    local notifStroke = Instance.new("UIStroke")
    notifStroke.Thickness = 2
    notifStroke.Color = accentColor
    notifStroke.Parent = notifFrame

    local accentBar = Instance.new("Frame")
    accentBar.Size = UDim2.new(0, 5, 1, 0)
    accentBar.BackgroundColor3 = accentColor
    accentBar.BorderSizePixel = 0
    accentBar.Parent = notifFrame

    local notifTitle = Instance.new("TextLabel")
    notifTitle.Size = UDim2.new(1, -24, 0, 24)
    notifTitle.Position = UDim2.new(0, 16, 0, 10)
    notifTitle.BackgroundTransparency = 1
    notifTitle.Text = title or "Beyond"
    notifTitle.TextColor3 = Color3.fromRGB(245, 245, 250)
    notifTitle.Font = Enum.Font.GothamBold
    notifTitle.TextSize = 14
    notifTitle.TextXAlignment = Enum.TextXAlignment.Left
    notifTitle.Parent = notifFrame

    local notifBody = Instance.new("TextLabel")
    notifBody.Size = UDim2.new(1, -24, 0, 34)
    notifBody.Position = UDim2.new(0, 16, 0, 34)
    notifBody.BackgroundTransparency = 1
    notifBody.Text = message or ""
    notifBody.TextColor3 = Color3.fromRGB(180, 180, 195)
    notifBody.Font = Enum.Font.Gotham
    notifBody.TextSize = 12
    notifBody.TextWrapped = true
    notifBody.TextXAlignment = Enum.TextXAlignment.Left
    notifBody.TextYAlignment = Enum.TextYAlignment.Top
    notifBody.Parent = notifFrame

    -- Стек уведомлений: сдвигаем остальные вниз
    for _, n in ipairs(NotifyStack) do
        if n and n.Parent then
            local curPos = n.Position
            TweenService:Create(n, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
                Position = UDim2.new(curPos.X.Scale, curPos.X.Offset, curPos.Y.Scale, curPos.Y.Offset + 76)
            }):Play()
        end
    end
    table.insert(NotifyStack, notifFrame)

    TweenService:Create(notifFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        {Size = UDim2.new(0, 320, 0, 72)}):Play()

    task.spawn(function()
        task.wait(_G.BeyondConfig.Notifications.Duration or 3)
        if notifFrame and notifFrame.Parent then
            -- Убираем из стека
            for i, n in ipairs(NotifyStack) do
                if n == notifFrame then table.remove(NotifyStack, i) break end
            end
            TweenService:Create(notifFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
                {Size = UDim2.new(0, 320, 0, 0), BackgroundTransparency = 1}):Play()
            task.wait(0.35)
            pcall(function() notifFrame:Destroy() end)
        end
    end)
end

-- ====================================================================
-- [7] ЗАГРУЗОЧНЫЙ ЭКРАН
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
loadingTitle.Size = UDim2.new(1, 0, 0, 50)
loadingTitle.Position = UDim2.new(0, 0, 0.4, -50)
loadingTitle.BackgroundTransparency = 1
loadingTitle.Text = "BEYOND <font color='#FF2B5A'>CLIENT</font> v6.2"
loadingTitle.RichText = true
loadingTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
loadingTitle.Font = Enum.Font.GothamBlack
loadingTitle.TextSize = 34
loadingTitle.Parent = loadingBg

local loadingSub = Instance.new("TextLabel")
loadingSub.Size = UDim2.new(1, 0, 0, 24)
loadingSub.Position = UDim2.new(0, 0, 0.4, 8)
loadingSub.BackgroundTransparency = 1
loadingSub.Text = "Adaptive Mode for HONOR Play5"
loadingSub.TextColor3 = Color3.fromRGB(140, 140, 155)
loadingSub.Font = Enum.Font.Code
loadingSub.TextSize = 15
loadingSub.Parent = loadingBg

local loadingBarBg = Instance.new("Frame")
loadingBarBg.Size = UDim2.new(0, 400, 0, 8)
loadingBarBg.Position = UDim2.new(0.5, -200, 0.4, 50)
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

local loadingScale = Instance.new("UIScale")
loadingScale.Scale = CalculateAdaptiveScale()
loadingScale.Parent = loadingBg

TweenService:Create(loadingBar, TweenInfo.new(1.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    {Size = UDim2.new(1, 0, 1, 0)}):Play()

task.spawn(function()
    task.wait(1.5)
    TweenService:Create(loadingBg, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
    TweenService:Create(loadingTitle, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
    TweenService:Create(loadingSub, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
    TweenService:Create(loadingBarBg, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
    TweenService:Create(loadingBar, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
    task.wait(0.5)
    pcall(function() LoadingScreen:Destroy() end)
end)

-- ====================================================================
-- [8] SELF-DESTRUCT + MINIMIZE/EXPAND + TOUCH DRAG
-- ====================================================================
function EnableTouchDrag(dragZone, targetFrame)
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
            -- Учитываем scale при драге
            local s = _G.BeyondConfig.UIScale or 1
            targetFrame.Position = UDim2.new(
                startPosition.X.Scale, startPosition.X.Offset + delta.X / s,
                startPosition.Y.Scale, startPosition.Y.Offset + delta.Y / s
            )
        end
    end)
end

EnableTouchDrag(Header, MainFrame)
EnableTouchDrag(MobileToggleButton, MobileToggleButton)

function _G.BeyondClient_SelfDestruct()
    ScriptActive = false
    _G.BeyondScriptActive = false
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
    pcall(function() NotifyFolder:Destroy() end)
    pcall(function() if LoadingScreen then LoadingScreen:Destroy() end end)
    _G.BeyondConfig = nil
    _G.BeyondClient_SelfDestruct = nil
    print("[BeyondClient v6.2]: Следы стерты.")
end

CloseBtn.MouseButton1Click:Connect(function()
    if _G.BeyondClient_SelfDestruct then _G.BeyondClient_SelfDestruct() end
end)

MinimizeBtn.MouseButton1Click:Connect(function()
    if not ScriptActive then return end
    _G.BeyondConfig.IsMenuOpened = false
    TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
        {Size = UDim2.new(0, 640, 0, 0)}):Play()
    task.wait(0.25)
    MainFrame.Visible = false
    MobileToggleButton.Visible = true
    MobileToggleButton.Size = UDim2.new(0, 0, 0, 0)
    TweenService:Create(MobileToggleButton, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Size = UDim2.new(0, 64, 0, 64)}):Play()
end)

MobileToggleButton.MouseButton1Click:Connect(function()
    if not ScriptActive then return end
    _G.BeyondConfig.IsMenuOpened = true
    TweenService:Create(MobileToggleButton, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
        {Size = UDim2.new(0, 0, 0, 0)}):Play()
    task.wait(0.18)
    MobileToggleButton.Visible = false
    MainFrame.Visible = true
    TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        {Size = UDim2.new(0, 640, 0, 560)}):Play()
end)

-- ====================================================================
-- [9] ALL UI FACTORIES (объявлены ДО использования)
-- ====================================================================
function CreateMobileToggle(parent, text, default, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 54)
    ToggleFrame.BackgroundColor3 = _G.BeyondConfig.CardColor
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.Parent = parent
    Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 10)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.68, 0, 1, 0)
    Label.Position = UDim2.new(0, 18, 0, 0)
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(215, 215, 225)
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1
    Label.Parent = ToggleFrame

    local CheckBox = Instance.new("TextButton")
    CheckBox.Size = UDim2.new(0, 54, 0, 30)
    CheckBox.Position = UDim2.new(1, -72, 0.5, -15)
    CheckBox.BackgroundColor3 = default and _G.BeyondConfig.ThemeColor or Color3.fromRGB(45, 45, 60)
    CheckBox.Text = ""
    CheckBox.Parent = ToggleFrame
    Instance.new("UICorner", CheckBox).CornerRadius = UDim.new(1, 0)

    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.new(0, 24, 0, 24)
    Indicator.Position = default and UDim2.new(1, -27, 0.5, -12) or UDim2.new(0, 3, 0.5, -12)
    Indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Indicator.Parent = CheckBox
    Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1, 0)

    local state = default
    CheckBox.MouseButton1Click:Connect(function()
        if not ScriptActive or not _G.BeyondConfig then return end
        state = not state
        local targetColor = state and _G.BeyondConfig.ThemeColor or Color3.fromRGB(45, 45, 60)
        local targetPos   = state and UDim2.new(1, -27, 0.5, -12) or UDim2.new(0, 3, 0.5, -12)
        TweenService:Create(CheckBox, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {BackgroundColor3 = targetColor}):Play()
        TweenService:Create(Indicator, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {Position = targetPos}):Play()
        callback(state)
    end)
    return CheckBox
end

function CreateMobileSlider(parent, text, min, max, default, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, 0, 0, 68)
    SliderFrame.BackgroundColor3 = _G.BeyondConfig.CardColor
    SliderFrame.BorderSizePixel = 0
    SliderFrame.Parent = parent
    Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(0, 10)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.9, 0, 0, 30)
    Label.Position = UDim2.new(0, 18, 0, 4)
    Label.Text = text .. ": <font color='#FF2B5A'>" .. tostring(default) .. "</font>"
    Label.RichText = true
    Label.TextColor3 = Color3.fromRGB(220, 220, 230)
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1
    Label.Parent = SliderFrame

    local Track = Instance.new("Frame")
    Track.Size = UDim2.new(1, -36, 0, 8)
    Track.Position = UDim2.new(0, 18, 0, 44)
    Track.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    Track.BorderSizePixel = 0
    Track.Parent = SliderFrame
    Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((default - min) / math.max(1, (max - min)), 0, 1, 0)
    Fill.BackgroundColor3 = _G.BeyondConfig.ThemeColor
    Fill.BorderSizePixel = 0
    Fill.Parent = Track
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

    -- Круглый ползунок увеличен до 26px под палец
    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 26, 0, 26)
    Knob.AnchorPoint = Vector2.new(0.5, 0.5)
    Knob.Position = UDim2.new(Fill.Size.X.Scale, 0, 0.5, 0)
    Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Knob.BorderSizePixel = 0
    Knob.Parent = Track
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

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
        Knob.Position = UDim2.new(ratio, 0, 0.5, 0)
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

function CreateSectionLabel(parent, titleText)
    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(1, 0, 0, 30)
    Lbl.BackgroundTransparency = 1
    Lbl.Text = "--- [ " .. titleText .. " ] ---"
    Lbl.TextColor3 = Color3.fromRGB(160, 160, 175)
    Lbl.Font = _G.BeyondConfig.Styles.FontsList.Bold
    Lbl.TextSize = 13
    Lbl.TextStrokeTransparency = 0.8
    Lbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    Lbl.Parent = parent
    return Lbl
end

function CreateActionButton(parent, textTitle, bgColor, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 46)
    Btn.BackgroundColor3 = bgColor or Color3.fromRGB(34, 34, 46)
    Btn.Text = textTitle
    Btn.TextColor3 = Color3.fromRGB(240, 240, 245)
    Btn.Font = _G.BeyondConfig.Styles.FontsList.Bold
    Btn.TextSize = 13
    Btn.Parent = parent
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)

    local BStroke = Instance.new("UIStroke")
    BStroke.Thickness = 1
    BStroke.Color = _G.BeyondConfig.Styles.BorderStrokeColor
    BStroke.Parent = Btn

    local originalText = textTitle
    local originalColor = bgColor or Color3.fromRGB(34, 34, 46)

    Btn.MouseButton1Click:Connect(function()
        if not ScriptActive then return end
        -- Loading-спиннер на кнопке
        Btn.Text = "⏳ Загрузка..."
        Btn.TextColor3 = Color3.fromRGB(255, 200, 100)
        TweenService:Create(Btn, TweenInfo.new(0.08), {BackgroundColor3 = _G.BeyondConfig.ThemeColor}):Play()
        task.spawn(function()
            pcall(callback)
            task.wait(0.4)
            if Btn and Btn.Parent then
                Btn.Text = originalText
                Btn.TextColor3 = Color3.fromRGB(240, 240, 245)
                TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = originalColor}):Play()
            end
        end)
    end)
    return Btn
end

function CreateCardFrame(parent, height)
    local Card = Instance.new("Frame")
    Card.Size = UDim2.new(1, 0, 0, height or 90)
    Card.BackgroundColor3 = _G.BeyondConfig.CardColor
    Card.BorderSizePixel = 0
    Card.Parent = parent
    Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 10)

    local CStroke = Instance.new("UIStroke")
    CStroke.Thickness = 1
    CStroke.Color = _G.BeyondConfig.Styles.BorderStrokeColor
    CStroke.Parent = Card
    return Card
end

function CreateStatDisplayLabel(parent, nameTag, yPosition)
    local DisplayLabel = Instance.new("TextLabel")
    DisplayLabel.Size = UDim2.new(1, -28, 0, 28)
    DisplayLabel.Position = UDim2.new(0, 18, 0, yPosition)
    DisplayLabel.BackgroundTransparency = 1
    DisplayLabel.Text = nameTag .. ": <font color='#00FF8C'>Загрузка...</font>"
    DisplayLabel.RichText = true
    DisplayLabel.TextColor3 = Color3.fromRGB(215, 215, 225)
    DisplayLabel.Font = _G.BeyondConfig.Styles.FontsList.Semibold
    DisplayLabel.TextSize = 14
    DisplayLabel.TextXAlignment = Enum.TextXAlignment.Left
    DisplayLabel.Parent = parent
    return DisplayLabel
end

-- ====================================================================
-- [10] ALL UTILITIES
-- ====================================================================
local BeyondAudioChannel = SoundService:FindFirstChild("Beyond_Interface_Audio")
if not BeyondAudioChannel then
    BeyondAudioChannel = Instance.new("Folder")
    BeyondAudioChannel.Name = "Beyond_Interface_Audio"
    BeyondAudioChannel.Parent = SoundService
end

function PlayInterfaceSound(assetId, volumeMultiplier)
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

function HookSoundToUIElement(instanceElement, isSlider)
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

function FireLegalChatMessage(textString)
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

function ToggleEnvironmentOptimization(enableOptimization)
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
        end
    end)
end

-- ====================================================================
-- [11] HIGHLIGHT CORE (с distance-check) + CROSSHAIR CORE
-- ====================================================================
function ApplyHighlight(player)
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

-- Crosshair
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

function RecalibrateCrosshairGeometry()
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

_G.BeyondConfig._RecalibrateCrosshair = RecalibrateCrosshairGeometry

-- Telemetry data (объявлена заранее — используется в объединённом цикле)
local TelemetryData = {
    CurrentFps = 60, CurrentPing = 0, CurrentMemory = 0,
    FrameCount = 0,  TimeCounter = 0,
    LowFpsCounter = 0
}

-- ====================================================================
-- [12] ЕДИНЫЙ ОБЪЕДИНЁННЫЙ RENDER LOOP (было 4 -> стало 1)
-- ====================================================================
RunService.RenderStepped:Connect(function(deltaTime)
    if not ScriptActive or not _G.BeyondConfig then return end

    -- (1) Обновление фазы RGB-перелива
    _G.BeyondConfig.GlowPhase = (_G.BeyondConfig.GlowPhase
        + (deltaTime * (_G.BeyondConfig.Visuals.GlowSpeed / 10))) % 1
    local dynamicRainbowColor = Color3.fromHSV(_G.BeyondConfig.GlowPhase, 0.85, 1)

    -- (2) RGB-перелив интерфейса
    if _G.BeyondConfig.Visuals.RainbowGlow then
        Stroke.Color = dynamicRainbowColor
        HeaderLine.BackgroundColor3 = dynamicRainbowColor
        Container.ScrollBarImageColor3 = dynamicRainbowColor
    end

    -- (3) Счётчик FPS
    TelemetryData.FrameCount  = TelemetryData.FrameCount + 1
    TelemetryData.TimeCounter = TelemetryData.TimeCounter + deltaTime
    if TelemetryData.TimeCounter >= 1.0 then
        TelemetryData.CurrentFps = math.round(TelemetryData.FrameCount / TelemetryData.TimeCounter)
        TelemetryData.FrameCount  = 0
        TelemetryData.TimeCounter = 0

        -- Автоотключение ESP при низком FPS
        if _G.BeyondConfig.Visuals.FpsAutoDisable and _G.BeyondConfig.Visuals.HighlightESP then
            if TelemetryData.CurrentFps < _G.BeyondConfig.Visuals.FpsThreshold then
                TelemetryData.LowFpsCounter = TelemetryData.LowFpsCounter + 1
                if TelemetryData.LowFpsCounter >= 3 then
                    -- Отключаем ESP
                    for _, player in ipairs(Players:GetPlayers()) do
                        local char = player.Character
                        local hl = char and char:FindFirstChild("Beyond_Highlight")
                        if hl then hl.Enabled = false end
                    end
                    TelemetryData.LowFpsCounter = 0
                end
            else
                TelemetryData.LowFpsCounter = 0
            end
        end
    end

    -- (4) ESP с distance-check
    if _G.BeyondConfig.Visuals.HighlightESP then
        local myChar = LocalPlayer.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        local myPos  = myRoot and myRoot.Position
        local maxDist = _G.BeyondConfig.Visuals.MaxDistance

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local char = player.Character
                local hl = char and char:FindFirstChild("Beyond_Highlight")
                if hl and hl:IsA("Highlight") then
                    local theirRoot = char:FindFirstChild("HumanoidRootPart")
                    local theirPos  = theirRoot and theirRoot.Position
                    local dist = (myPos and theirPos) and (myPos - theirPos).Magnitude or 0

                    if dist <= maxDist then
                        hl.Enabled = true
                        hl.FillColor = dynamicRainbowColor
                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                        hl.FillTransparency = _G.BeyondConfig.Visuals.EspFillTransparency
                        hl.OutlineTransparency = _G.BeyondConfig.Visuals.EspOutlineTransparency
                    else
                        hl.Enabled = false
                    end
                end
            end
        end
    end

    -- (5) Цвет прицела
    if _G.BeyondConfig.Crosshair.Enabled then
        local syncColor = _G.BeyondConfig.Visuals.RainbowGlow and dynamicRainbowColor
            or _G.BeyondConfig.Crosshair.Color
        for _, line in ipairs(linesArray) do
            line.BackgroundColor3 = syncColor
        end
    end
end)

-- ====================================================================
-- [13] TAB SYSTEM
-- ====================================================================
function CreateTabButton(name, layoutOrder)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Name = "Tab_" .. name
    TabBtn.Size = UDim2.new(0, 112, 0, 32)
    TabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    TabBtn.Text = name
    TabBtn.TextColor3 = Color3.fromRGB(200, 200, 215)
    TabBtn.Font = Enum.Font.GothamSemibold
    TabBtn.TextSize = 13
    TabBtn.LayoutOrder = layoutOrder
    TabBtn.Parent = TabBar
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 8)
    return TabBtn
end

function CreateTabPage(name)
    local Page = Instance.new("Frame")
    Page.Name = "Page_" .. name
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = (name == ActiveTabName)
    Page.Parent = Container

    local PageLayout = Instance.new("UIListLayout")
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    PageLayout.Padding = UDim.new(0, 12)
    PageLayout.Parent = Page

    PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        if ScriptActive and Container and Page.Visible then
            Container.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 24)
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

function SwitchTab(name)
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
    Container.CanvasSize = UDim2.new(0, 0, 0, Tabs[name].Layout.AbsoluteContentSize.Y + 24)
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
-- [14] TAB VISUAL
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

CreateMobileSlider(visualPage, "Дистанция ESP (studs)", 50, 500, _G.BeyondConfig.Visuals.MaxDistance, function(val)
    _G.BeyondConfig.Visuals.MaxDistance = val
end)

CreateMobileToggle(visualPage, "Авто-отключение при FPS < 20", _G.BeyondConfig.Visuals.FpsAutoDisable, function(state)
    _G.BeyondConfig.Visuals.FpsAutoDisable = state
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
    RecalibrateCrosshairGeometry()
end)

CreateMobileToggle(visualPage, "Центральная точка", _G.BeyondConfig.Crosshair.CenterDot, function(state)
    _G.BeyondConfig.Crosshair.CenterDot = state
    RecalibrateCrosshairGeometry()
end)

CreateMobileSlider(visualPage, "Длина линий", 6, 50, _G.BeyondConfig.Crosshair.Size, function(val)
    _G.BeyondConfig.Crosshair.Size = val
    RecalibrateCrosshairGeometry()
end)

CreateMobileSlider(visualPage, "Толщина линий", 1, 10, _G.BeyondConfig.Crosshair.Thickness, function(val)
    _G.BeyondConfig.Crosshair.Thickness = val
    RecalibrateCrosshairGeometry()
end)

CreateMobileSlider(visualPage, "Зазор (Gap)", 0, 30, _G.BeyondConfig.Crosshair.Gap, function(val)
    _G.BeyondConfig.Crosshair.Gap = val
    RecalibrateCrosshairGeometry()
end)

CreateSectionLabel(visualPage, "ПРЕСЕТЫ ТЕМ")

local StylePresetFrame = CreateCardFrame(visualPage, 106)

local StyleLabel = Instance.new("TextLabel")
StyleLabel.Size = UDim2.new(1, -28, 0, 30)
StyleLabel.Position = UDim2.new(0, 18, 0, 4)
StyleLabel.Text = "Тема: <font color='#FF2B5A'>" .. _G.BeyondConfig.Styles.CurrentThemePreset .. "</font>"
StyleLabel.RichText = true
StyleLabel.TextColor3 = Color3.fromRGB(225, 225, 235)
StyleLabel.Font = _G.BeyondConfig.Styles.FontsList.Semibold
StyleLabel.TextSize = 14
StyleLabel.TextXAlignment = Enum.TextXAlignment.Left
StyleLabel.BackgroundTransparency = 1
StyleLabel.Parent = StylePresetFrame

function InitializeThemeButton(themeName, xOffset, primeColor)
    local ThemeBtn = Instance.new("TextButton")
    ThemeBtn.Size = UDim2.new(0.28, 0, 0, 46)
    ThemeBtn.Position = UDim2.new(0, xOffset, 0, 44)
    ThemeBtn.BackgroundColor3 = Color3.fromRGB(34, 34, 46)
    ThemeBtn.Text = themeName
    ThemeBtn.TextColor3 = Color3.fromRGB(245, 245, 250)
    ThemeBtn.Font = _G.BeyondConfig.Styles.FontsList.Bold
    ThemeBtn.TextSize = 12
    ThemeBtn.Parent = StylePresetFrame
    Instance.new("UICorner", ThemeBtn).CornerRadius = UDim.new(0, 8)

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

InitializeThemeButton("Zero Two",  20,  Color3.fromRGB(255, 43, 90))
InitializeThemeButton("Киберпанк", 200, Color3.fromRGB(0, 255, 240))
InitializeThemeButton("Токсик",    380, Color3.fromRGB(170, 255, 0))

-- ====================================================================
-- [15] TAB MOVEMENT
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

local flyBodyVelocity, flyBodyGyro, flyConnection

function StartFly()
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
            if moveDir.Magnitude > 0 then moveDir = moveDir.Unit * _G.BeyondConfig.FlySpeed end
            flyBodyVelocity.Velocity = moveDir
            flyBodyGyro.CFrame = cam.CFrame
        end)
    end)
end

function StopFly()
    pcall(function()
        if flyBodyVelocity then flyBodyVelocity:Destroy() end
        if flyBodyGyro then flyBodyGyro:Destroy() end
        if flyConnection then flyConnection:Disconnect() end
        flyBodyVelocity = nil
        flyBodyGyro = nil
        flyConnection = nil
    end)
end

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
-- [16] TAB AUTO
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
                    end
                end)
                pcall(function()
                    if FooterText and FooterText.Parent then
                        FooterText.Text = "Status: Operational // Clicks: "
                            .. tostring(_G.BeyondConfig.Automation.TotalClicksSimulated)
                    end
                end)
                task.wait(calculatedDelay)
            end
        end)
    else
        pcall(function()
            if FooterText and FooterText.Parent then
                FooterText.Text = "Status: Operational // Adaptive Mode ON"
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
    {Name = "Приветствие",    Phrase = "Привет всем! Beyond Client v6.2 запущен."},
    {Name = "Предупреждение", Phrase = "Внимание, тактическая активность!"},
    {Name = "Проверка лагов", Phrase = "Пинг стабилен на HONOR Play5."},
    {Name = "GG",             Phrase = "GG WP всем!"}
}

for _, macroInfo in ipairs(ChatMacroData) do
    local MacroFrame = CreateCardFrame(autoPage, 74)

    local MacroNameLabel = Instance.new("TextLabel")
    MacroNameLabel.Size = UDim2.new(0.6, 0, 0, 26)
    MacroNameLabel.Position = UDim2.new(0, 18, 0, 8)
    MacroNameLabel.Text = macroInfo.Name
    MacroNameLabel.TextColor3 = Color3.fromRGB(240, 240, 245)
    MacroNameLabel.Font = _G.BeyondConfig.Styles.FontsList.Bold
    MacroNameLabel.TextSize = 14
    MacroNameLabel.TextXAlignment = Enum.TextXAlignment.Left
    MacroNameLabel.BackgroundTransparency = 1
    MacroNameLabel.Parent = MacroFrame

    local MacroPhraseLabel = Instance.new("TextLabel")
    MacroPhraseLabel.Size = UDim2.new(0.6, 0, 0, 32)
    MacroPhraseLabel.Position = UDim2.new(0, 18, 0, 34)
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
    SendBtn.Size = UDim2.new(0, 116, 0, 42)
    SendBtn.Position = UDim2.new(1, -134, 0.5, -21)
    SendBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
    SendBtn.Text = "ОТПРАВИТЬ"
    SendBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    SendBtn.Font = _G.BeyondConfig.Styles.FontsList.Bold
    SendBtn.TextSize = 12
    SendBtn.Parent = MacroFrame
    Instance.new("UICorner", SendBtn).CornerRadius = UDim.new(0, 8)

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
-- [17] TAB CONFIG
-- ====================================================================
local configPage = TabPages["Config"]

CreateSectionLabel(configPage, "УПРАВЛЕНИЕ СЛОТАМИ")

local ConfigCardFrame = CreateCardFrame(configPage, 190)

local ConfigStatusLabel = Instance.new("TextLabel")
ConfigStatusLabel.Size = UDim2.new(1, -28, 0, 30)
ConfigStatusLabel.Position = UDim2.new(0, 18, 0, 6)
ConfigStatusLabel.Text = "Система: <font color='#00FF8C'>Готова к сериализации</font>"
ConfigStatusLabel.RichText = true
ConfigStatusLabel.TextColor3 = Color3.fromRGB(225, 225, 235)
ConfigStatusLabel.Font = _G.BeyondConfig.Styles.FontsList.Semibold
ConfigStatusLabel.TextSize = 14
ConfigStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
ConfigStatusLabel.BackgroundTransparency = 1
ConfigStatusLabel.Parent = ConfigCardFrame

local ActiveSlotLabel = Instance.new("TextLabel")
ActiveSlotLabel.Size = UDim2.new(1, -28, 0, 24)
ActiveSlotLabel.Position = UDim2.new(0, 18, 0, 38)
ActiveSlotLabel.Text = "Активный слот: <font color='#FF2B5A'>" .. _G.BeyondConfig.ConfigSlots.ActiveSlot .. "</font> / "
    .. _G.BeyondConfig.ConfigSlots.SlotCount
ActiveSlotLabel.RichText = true
ActiveSlotLabel.TextColor3 = Color3.fromRGB(215, 215, 225)
ActiveSlotLabel.Font = _G.BeyondConfig.Styles.FontsList.Regular
ActiveSlotLabel.TextSize = 13
ActiveSlotLabel.TextXAlignment = Enum.TextXAlignment.Left
ActiveSlotLabel.BackgroundTransparency = 1
ActiveSlotLabel.Parent = ConfigCardFrame

function PushConfigStatusUpdate(htmlText)
    if ConfigStatusLabel and ConfigStatusLabel.Parent then
        ConfigStatusLabel.Text = "Система: " .. htmlText
    end
end

function UpdateActiveSlotLabel()
    if ActiveSlotLabel and ActiveSlotLabel.Parent then
        ActiveSlotLabel.Text = "Активный слот: <font color='#FF2B5A'>"
            .. _G.BeyondConfig.ConfigSlots.ActiveSlot .. "</font> / "
            .. _G.BeyondConfig.ConfigSlots.SlotCount
    end
end

function SerializeConfig()
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
        MaxDistance            = _G.BeyondConfig.Visuals.MaxDistance,
        RainbowGlow            = _G.BeyondConfig.Visuals.RainbowGlow,
        GlowSpeed              = _G.BeyondConfig.Visuals.GlowSpeed,
        AutoClickEnabled       = _G.BeyondConfig.Automation.AutoClickEnabled,
        ClickInterval          = _G.BeyondConfig.Automation.ClickInterval,
        CurrentThemePreset     = _G.BeyondConfig.Styles.CurrentThemePreset
    }
end

function SaveConfigToSlot()
    local FS = _G.BeyondFS or FileSystemAPI
    if not FS or not FS.Write then
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
    local okWrite = pcall(function() FS.Write(fileName, encoded) end)
    if okWrite then
        PushConfigStatusUpdate("<font color='#00FF8C'>Слот " .. slot .. " сохранён!</font>")
        PushNotification("Config", "Профиль сохранён в слот " .. slot, "success")
    else
        PushConfigStatusUpdate("<font color='#FF2B5A'>Ошибка записи</font>")
    end
end

function LoadConfigFromSlot()
    local FS = _G.BeyondFS or FileSystemAPI
    if not FS or not FS.Read or not FS.Check then
        PushConfigStatusUpdate("<font color='#FF2B5A'>ReadFile недоступен</font>")
        return
    end
    local slot = _G.BeyondConfig.ConfigSlots.ActiveSlot
    local fileName = BEYOND_CONFIG_BASE .. tostring(slot) .. ".json"
    if not FS.Check(fileName) then
        PushConfigStatusUpdate("<font color='#FFBB00'>Слот " .. slot .. " пуст</font>")
        return
    end
    local okRead, fileRaw = pcall(function() return FS.Read(fileName) end)
    if not (okRead and fileRaw) then
        PushConfigStatusUpdate("<font color='#FF2B5A'>Ошибка чтения</font>")
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
        if decoded.MaxDistance            then _G.BeyondConfig.Visuals.MaxDistance = decoded.MaxDistance end
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
SlotRow.Size = UDim2.new(1, -28, 0, 40)
SlotRow.Position = UDim2.new(0, 14, 0, 68)
SlotRow.BackgroundTransparency = 1
SlotRow.Parent = ConfigCardFrame

local SlotBtnLayout = Instance.new("UIListLayout")
SlotBtnLayout.FillDirection = Enum.FillDirection.Horizontal
SlotBtnLayout.Padding = UDim.new(0, 8)
SlotBtnLayout.Parent = SlotRow

for i = 1, _G.BeyondConfig.ConfigSlots.SlotCount do
    local SlotBtn = Instance.new("TextButton")
    SlotBtn.Size = UDim2.new(0, 58, 0, 36)
    SlotBtn.BackgroundColor3 = (i == _G.BeyondConfig.ConfigSlots.ActiveSlot)
        and _G.BeyondConfig.ThemeColor or Color3.fromRGB(34, 34, 46)
    SlotBtn.Text = "S" .. i
    SlotBtn.TextColor3 = Color3.fromRGB(245, 245, 250)
    SlotBtn.Font = _G.BeyondConfig.Styles.FontsList.Bold
    SlotBtn.TextSize = 13
    SlotBtn.LayoutOrder = i
    SlotBtn.Parent = SlotRow
    Instance.new("UICorner", SlotBtn).CornerRadius = UDim.new(0, 6)

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
SaveRow.Size = UDim2.new(1, -28, 0, 46)
SaveRow.Position = UDim2.new(0, 14, 0, 118)
SaveRow.BackgroundTransparency = 1
SaveRow.Parent = ConfigCardFrame

local SaveBtn = Instance.new("TextButton")
SaveBtn.Size = UDim2.new(0.48, 0, 1, 0)
SaveBtn.Position = UDim2.new(0, 0, 0, 0)
SaveBtn.BackgroundColor3 = Color3.fromRGB(34, 46, 38)
SaveBtn.Text = "СОХРАНИТЬ"
SaveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SaveBtn.Font = _G.BeyondConfig.Styles.FontsList.Bold
SaveBtn.TextSize = 13
SaveBtn.Parent = SaveRow
Instance.new("UICorner", SaveBtn).CornerRadius = UDim.new(0, 8)
SaveBtn.MouseButton1Click:Connect(function()
    if not ScriptActive then return end
    SaveBtn.Text = "⏳ Сохранение..."
    task.spawn(function()
        SaveConfigToSlot()
        task.wait(0.4)
        if SaveBtn and SaveBtn.Parent then SaveBtn.Text = "СОХРАНИТЬ" end
    end)
end)

local LoadBtn = Instance.new("TextButton")
LoadBtn.Size = UDim2.new(0.48, 0, 1, 0)
LoadBtn.Position = UDim2.new(0.52, 0, 0, 0)
LoadBtn.BackgroundColor3 = Color3.fromRGB(34, 38, 46)
LoadBtn.Text = "ЗАГРУЗИТЬ"
LoadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
LoadBtn.Font = _G.BeyondConfig.Styles.FontsList.Bold
LoadBtn.TextSize = 13
LoadBtn.Parent = SaveRow
Instance.new("UICorner", LoadBtn).CornerRadius = UDim.new(0, 8)
LoadBtn.MouseButton1Click:Connect(function()
    if not ScriptActive then return end
    LoadBtn.Text = "⏳ Загрузка..."
    task.spawn(function()
        LoadConfigFromSlot()
        task.wait(0.4)
        if LoadBtn and LoadBtn.Parent then LoadBtn.Text = "ЗАГРУЗИТЬ" end
    end)
end)

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

-- ====================================================================
-- [18] TAB DEBUG
-- ====================================================================
local debugPage = TabPages["Debug"]

CreateSectionLabel(debugPage, "ТЕЛЕМЕТРИЯ")

local StatsCardFrame = CreateCardFrame(debugPage, 130)

local FpsDisplay  = CreateStatDisplayLabel(StatsCardFrame, "FPS",    12)
local PingDisplay = CreateStatDisplayLabel(StatsCardFrame, "Ping",   44)
local MemDisplay  = CreateStatDisplayLabel(StatsCardFrame, "Memory", 76)
local ResDisplay  = CreateStatDisplayLabel(StatsCardFrame, "Разрешение", 108)

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
            local vp = Camera.ViewportSize
            ResDisplay.Text  = "Разрешение: <font color='#C0C0D0'>" .. vp.X .. "x" .. vp.Y
                .. " (Scale x" .. string.format("%.2f", _G.BeyondConfig.UIScale) .. ")</font>"
        end)
    end
end)

CreateSectionLabel(debugPage, "ОПТИМИЗАЦИЯ ГРАФИКИ")

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
ConsoleBoxFrame.Size = UDim2.new(1, 0, 0, 190)
ConsoleBoxFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
ConsoleBoxFrame.BorderSizePixel = 0
ConsoleBoxFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ConsoleBoxFrame.ScrollBarThickness = 4
ConsoleBoxFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 90)
ConsoleBoxFrame.Parent = debugPage
Instance.new("UICorner", ConsoleBoxFrame).CornerRadius = UDim.new(0, 10)

local ConsoleStroke = Instance.new("UIStroke")
ConsoleStroke.Thickness = 1
ConsoleStroke.Color = _G.BeyondConfig.Styles.BorderStrokeColor
ConsoleStroke.Parent = ConsoleBoxFrame

local ConsoleListLayout = Instance.new("UIListLayout")
ConsoleListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ConsoleListLayout.Padding = UDim.new(0, 4)
ConsoleListLayout.Parent = ConsoleBoxFrame

local ConsolePadding = Instance.new("UIPadding")
ConsolePadding.PaddingLeft = UDim.new(0, 12)
ConsolePadding.PaddingRight = UDim.new(0, 12)
ConsolePadding.PaddingTop = UDim.new(0, 8)
ConsolePadding.PaddingBottom = UDim.new(0, 8)
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
    LogLineLabel.Size = UDim2.new(1, 0, 0, 18)
    LogLineLabel.BackgroundTransparency = 1
    LogLineLabel.Text = string.format("[%s] %s", systemTime, logText)
    LogLineLabel.TextColor3 = textColor
    LogLineLabel.Font = _G.BeyondConfig.Styles.FontsList.Monospace
    LogLineLabel.TextSize = 12
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

    ConsoleBoxFrame.CanvasSize = UDim2.new(0, 0, 0, ConsoleListLayout.AbsoluteContentSize.Y + 16)
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
-- [19] BOOT
-- ====================================================================
task.spawn(function()
    task.wait(0.8)
    PrintToBeyondConsole("BeyondClient v6.2 (Adaptive) скомпилирован!", "success")
    PrintToBeyondConsole("Адаптация под HONOR Play5 / 2400x1080 / DPI 440.", "info")
    PrintToBeyondConsole("UIScale: x" .. string.format("%.2f", _G.BeyondConfig.UIScale), "info")
    PushNotification("Beyond", "v6.2 Adaptive Mode запущен", "success")
end)

-- Стартовая анимация
MainFrame.Size = UDim2.new(0, 640, 0, 0)
MainFrame.ClipsDescendants = true
MainFrame.Visible = true

local finalBootTween = TweenService:Create(
    MainFrame,
    TweenInfo.new(0.7, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    {Size = UDim2.new(0, 640, 0, 560)}
)
finalBootTween:Play()
finalBootTween.Completed:Connect(function()
    if MainFrame then MainFrame.ClipsDescendants = false end
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if not ScriptActive or not _G.BeyondConfig then return end
    if input.KeyCode == _G.BeyondConfig.Keybinds.PanicKey then
        if _G.BeyondClient_SelfDestruct then _G.BeyondClient_SelfDestruct() end
    end
end)

-- Обновление UIScale при повороте экрана
Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    if not ScriptActive or not _G.BeyondConfig then return end
    local newScale = CalculateAdaptiveScale()
    _G.BeyondConfig.UIScale = newScale
    if MainUIScale then MainUIScale.Scale = newScale end
    if MobileButtonScale then MobileButtonScale.Scale = newScale end
end)

print("[BeyondClient v6.2 Adaptive]: Сборка успешно развёрнута.")
