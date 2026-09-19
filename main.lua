--[[
    BeyondClient v6.3 - Mini Edition
    Target: HONOR Play5 (HJC-AN90 / Dimensity 800U / 8GB / 2400x1080 / DPI 440)
    Developer: UserBeyond-dev

    v6.3 CHANGELOG:
      [FIX] CreateStatDisplayLabel — используется parent, а не StatsCardFrame
      [+] Меню уменьшено до 520x440
      [+] Верхний drag-индикатор в шапке
      [+] Две нижние drag-ручки (⋮⋮) по краям меню
      [+] Кнопка полного удаления прицела
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
-- [2] ADAPTIVE SCALE + CONFIG
-- ====================================================================
local function CalculateAdaptiveScale()
    local vp = Camera.ViewportSize
    local sw = vp.X / 1600
    local sh = vp.Y / 720
    return math.clamp(math.min(sw, sh), 0.75, 1.5)
end

_G.BeyondConfig = {
    Version    = "6.3-Mini",
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
    BgColor     = Color3.fromRGB(15, 15, 20),
    CardColor   = Color3.fromRGB(22, 22, 30),
    HeaderColor = Color3.fromRGB(28, 26, 36),

    IsMenuOpened = true,
    GlowPhase    = 0,
    ActiveTab    = "Visual",
    UIScale      = 1,
    CrosshairRemoved = false,   -- НОВОЕ: если true — прицел удалён навсегда

    Visuals = {
        HighlightESP           = false,
        EspOutlineTransparency = 0,
        EspFillTransparency    = 0.5,
        MaxDistance            = 300,
        FpsAutoDisable         = true,
        FpsThreshold           = 20,
        RainbowGlow            = false,
        GlowSpeed              = 50
    },

    Movement = { WalkSpeed = 16, JumpPower = 50, FlySpeed = 60 },

    Automation = {
        AutoClickEnabled = false, ClickInterval = 100,
        TotalClicksSimulated = 0,
        AutoJumpEnabled = false, AutoJumpInterval = 300
    },

    Crosshair = {
        Enabled = false, Size = 18, Thickness = 3, Gap = 6,
        CenterDot = false, Color = Color3.fromRGB(255, 43, 90)
    },

    Audio = {
        MuteAll = false, MasterVolume = 0.5,
        AssetClickId = "rbxassetid://6140381534",
        AssetHoverId = "rbxassetid://6895079633"
    },

    Logger = { MaxLinesStored = 80, LogCount = 0 },

    PerformanceBoost = {
        OptimizerActive = false,
        OriginalShadows = Lighting.GlobalShadows,
        OriginalFogEnd  = Lighting.FogEnd
    },

    Notifications = { Enabled = true, Duration = 3 },

    Styles = {
        CurrentThemePreset  = "Розовый Zero Two",
        CardBackgroundColor = Color3.fromRGB(20, 20, 28),
        BorderStrokeColor   = Color3.fromRGB(35, 35, 45),
        FontsList = {
            Bold = Enum.Font.GothamBold, Semibold = Enum.Font.GothamSemibold,
            Regular = Enum.Font.Gotham, Monospace = Enum.Font.Code,
            Black = Enum.Font.GothamBlack
        }
    },

    ConfigSlots = { ActiveSlot = 1, SlotCount = 5 },
    Keybinds = { PanicKey = Enum.KeyCode.End }
}

local ScriptActive = true
_G.BeyondScriptActive = true

-- ====================================================================
-- [3] FILE SYSTEM API
-- ====================================================================
local FileSystemAPI = {
    Write  = writefile or (syn and syn.writefile) or (getgenv and getgenv().writefile),
    Read   = readfile  or (syn and syn.readfile)  or (getgenv and getgenv().readfile),
    Check  = isfile    or (syn and syn.isfile)    or (getgenv and getgenv().isfile),
    Delete = delfile   or (syn and syn.delfile)   or (getgenv and getgenv().delfile),
    List   = listfiles or (syn and syn.listfiles) or (getgenv and getgenv().listfiles)
}
_G.BeyondFS = FileSystemAPI
local BEYOND_CONFIG_BASE = "BeyondClient_V63_slot"

-- ====================================================================
-- [4] UI SCAFFOLDING — МЕНЮ УМЕНЬШЕНО ДО 520x440
-- ====================================================================
local BeyondScreenGui = Instance.new("ScreenGui")
BeyondScreenGui.Name = "Beyond_" .. HttpService:GenerateGUID(false):sub(1, 8)
BeyondScreenGui.ResetOnSpawn = false
BeyondScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
local okParent = pcall(function() BeyondScreenGui.Parent = CoreGui end)
if not okParent then BeyondScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- === MAINFRAME 520x440 (было 640x560) ===
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainPanel"
MainFrame.Size = UDim2.new(0, 520, 0, 440)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -220)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = _G.BeyondConfig.BgColor
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = BeyondScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 14)

local MainUIScale = Instance.new("UIScale")
MainUIScale.Scale = CalculateAdaptiveScale()
MainUIScale.Parent = MainFrame
_G.BeyondConfig.UIScale = MainUIScale.Scale

local Stroke = Instance.new("UIStroke")
Stroke.Thickness = 2
Stroke.Color = _G.BeyondConfig.ThemeColor
Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
Stroke.Parent = MainFrame

-- === HEADER 52px ===
local Header = Instance.new("Frame")
Header.Name = "HeaderZone"
Header.Size = UDim2.new(1, 0, 0, 52)
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

-- Верхний drag-индикатор (полоска по центру)
local TopDragHint = Instance.new("Frame")
TopDragHint.Name = "TopDragHint"
TopDragHint.Size = UDim2.new(0, 60, 0, 4)
TopDragHint.Position = UDim2.new(0.5, -30, 0, 5)
TopDragHint.BackgroundColor3 = Color3.fromRGB(120, 120, 140)
TopDragHint.BorderSizePixel = 0
TopDragHint.Parent = Header
Instance.new("UICorner", TopDragHint).CornerRadius = UDim.new(1, 0)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -180, 1, 0)
Title.Position = UDim2.new(0, 18, 0, 0)
Title.Text = "BEYOND <font color='#FF2B5A'>CLIENT</font> <font color='#A0A0A5'>v6.3</font>"
Title.RichText = true
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 15
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
Title.Parent = Header

-- Плавающая кнопка вызова (56x56)
local MobileToggleButton = Instance.new("ImageButton")
MobileToggleButton.Name = "BeyondMobileCall"
MobileToggleButton.Size = UDim2.new(0, 56, 0, 56)
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

-- Minimize (44x44)
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Name = "Minimize"
MinimizeBtn.Size = UDim2.new(0, 40, 0, 40)
MinimizeBtn.Position = UDim2.new(1, -92, 0.5, -20)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(38, 38, 50)
MinimizeBtn.Text = "—"
MinimizeBtn.TextColor3 = Color3.fromRGB(220, 220, 235)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 16
MinimizeBtn.Parent = Header
Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 8)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "Close"
CloseBtn.Size = UDim2.new(0, 40, 0, 40)
CloseBtn.Position = UDim2.new(1, -48, 0.5, -20)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 43, 90)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 15
CloseBtn.Parent = Header
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)

-- === TABBAR ===
local TabBar = Instance.new("Frame")
TabBar.Name = "TabBar"
TabBar.Size = UDim2.new(1, -20, 0, 40)
TabBar.Position = UDim2.new(0, 10, 0, 60)
TabBar.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
TabBar.BorderSizePixel = 0
TabBar.Parent = MainFrame
Instance.new("UICorner", TabBar).CornerRadius = UDim.new(0, 10)

local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.Padding = UDim.new(0, 4)
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabLayout.Parent = TabBar

local TabPadding = Instance.new("UIPadding")
TabPadding.PaddingLeft = UDim.new(0, 4)
TabPadding.PaddingTop = UDim.new(0, 4)
TabPadding.Parent = TabBar

-- === CONTAINER ===
local Container = Instance.new("ScrollingFrame")
Container.Name = "ModuleContainer"
Container.Size = UDim2.new(1, -20, 1, -168)
Container.Position = UDim2.new(0, 10, 0, 108)
Container.BackgroundTransparency = 1
Container.BorderSizePixel = 0
Container.CanvasSize = UDim2.new(0, 0, 0, 700)
Container.ScrollBarThickness = 4
Container.ScrollBarImageColor3 = _G.BeyondConfig.ThemeColor
Container.Parent = MainFrame

-- === FOOTER + ДВЕ НИЖНИЕ DRAG-РУЧКИ ===
local Footer = Instance.new("Frame")
Footer.Name = "Footer"
Footer.Size = UDim2.new(1, 0, 0, 38)
Footer.Position = UDim2.new(0, 0, 1, -38)
Footer.BackgroundColor3 = Color3.fromRGB(22, 20, 28)
Footer.BorderSizePixel = 0
Footer.Parent = MainFrame
Instance.new("UICorner", Footer).CornerRadius = UDim.new(0, 14)

local FooterText = Instance.new("TextLabel")
FooterText.Name = "FooterText"
FooterText.Size = UDim2.new(1, -160, 1, 0)
FooterText.Position = UDim2.new(0, 80, 0, 0)
FooterText.BackgroundTransparency = 1
FooterText.Text = "Adaptive Mode ON"
FooterText.TextColor3 = Color3.fromRGB(150, 150, 165)
FooterText.Font = Enum.Font.Code
FooterText.TextSize = 11
FooterText.TextXAlignment = Enum.TextXAlignment.Center
FooterText.Parent = Footer

-- Левая нижняя drag-ручка
local BottomLeftDrag = Instance.new("TextButton")
BottomLeftDrag.Name = "BottomLeftDrag"
BottomLeftDrag.Size = UDim2.new(0, 66, 0, 30)
BottomLeftDrag.Position = UDim2.new(0, 6, 1, -34)
BottomLeftDrag.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
BottomLeftDrag.Text = "⋮⋮"
BottomLeftDrag.TextColor3 = Color3.fromRGB(140, 140, 160)
BottomLeftDrag.Font = Enum.Font.GothamBold
BottomLeftDrag.TextSize = 16
BottomLeftDrag.ZIndex = 12
BottomLeftDrag.Parent = MainFrame
Instance.new("UICorner", BottomLeftDrag).CornerRadius = UDim.new(0, 8)

local BottomLeftStroke = Instance.new("UIStroke", BottomLeftDrag)
BottomLeftStroke.Thickness = 1
BottomLeftStroke.Color = _G.BeyondConfig.ThemeColor
BottomLeftStroke.Transparency = 0.5

-- Правая нижняя drag-ручка
local BottomRightDrag = Instance.new("TextButton")
BottomRightDrag.Name = "BottomRightDrag"
BottomRightDrag.Size = UDim2.new(0, 66, 0, 30)
BottomRightDrag.Position = UDim2.new(1, -72, 1, -34)
BottomRightDrag.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
BottomRightDrag.Text = "⋮⋮"
BottomRightDrag.TextColor3 = Color3.fromRGB(140, 140, 160)
BottomRightDrag.Font = Enum.Font.GothamBold
BottomRightDrag.TextSize = 16
BottomRightDrag.ZIndex = 12
BottomRightDrag.Parent = MainFrame
Instance.new("UICorner", BottomRightDrag).CornerRadius = UDim.new(0, 8)

local BottomRightStroke = Instance.new("UIStroke", BottomRightDrag)
BottomRightStroke.Thickness = 1
BottomRightStroke.Color = _G.BeyondConfig.ThemeColor
BottomRightStroke.Transparency = 0.5

-- Tab storage
local Tabs = {}
local TabPages = {}
local ActiveTabName = "Visual"

-- ====================================================================
-- [5] NOTIFICATIONS
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
    notifFrame.Size = UDim2.new(0, 280, 0, 0)
    notifFrame.Position = UDim2.new(1, -300, 0, 100)
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
    accentBar.Size = UDim2.new(0, 4, 1, 0)
    accentBar.BackgroundColor3 = accentColor
    accentBar.BorderSizePixel = 0
    accentBar.Parent = notifFrame

    local notifTitle = Instance.new("TextLabel")
    notifTitle.Size = UDim2.new(1, -20, 0, 22)
    notifTitle.Position = UDim2.new(0, 14, 0, 8)
    notifTitle.BackgroundTransparency = 1
    notifTitle.Text = title or "Beyond"
    notifTitle.TextColor3 = Color3.fromRGB(245, 245, 250)
    notifTitle.Font = Enum.Font.GothamBold
    notifTitle.TextSize = 13
    notifTitle.TextXAlignment = Enum.TextXAlignment.Left
    notifTitle.Parent = notifFrame

    local notifBody = Instance.new("TextLabel")
    notifBody.Size = UDim2.new(1, -20, 0, 30)
    notifBody.Position = UDim2.new(0, 14, 0, 30)
    notifBody.BackgroundTransparency = 1
    notifBody.Text = message or ""
    notifBody.TextColor3 = Color3.fromRGB(180, 180, 195)
    notifBody.Font = Enum.Font.Gotham
    notifBody.TextSize = 11
    notifBody.TextWrapped = true
    notifBody.TextXAlignment = Enum.TextXAlignment.Left
    notifBody.TextYAlignment = Enum.TextYAlignment.Top
    notifBody.Parent = notifFrame

    for _, n in ipairs(NotifyStack) do
        if n and n.Parent then
            local cp = n.Position
            TweenService:Create(n, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
                Position = UDim2.new(cp.X.Scale, cp.X.Offset, cp.Y.Scale, cp.Y.Offset + 68)
            }):Play()
        end
    end
    table.insert(NotifyStack, notifFrame)

    TweenService:Create(notifFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        {Size = UDim2.new(0, 280, 0, 64)}):Play()

    task.spawn(function()
        task.wait(_G.BeyondConfig.Notifications.Duration or 3)
        if notifFrame and notifFrame.Parent then
            for i, n in ipairs(NotifyStack) do
                if n == notifFrame then table.remove(NotifyStack, i) break end
            end
            TweenService:Create(notifFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
                {Size = UDim2.new(0, 280, 0, 0), BackgroundTransparency = 1}):Play()
            task.wait(0.35)
            pcall(function() notifFrame:Destroy() end)
        end
    end)
end

-- ====================================================================
-- [6] LOADING SCREEN
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

local loadingScale = Instance.new("UIScale")
loadingScale.Scale = CalculateAdaptiveScale()
loadingScale.Parent = loadingBg

local loadingTitle = Instance.new("TextLabel")
loadingTitle.Size = UDim2.new(1, 0, 0, 44)
loadingTitle.Position = UDim2.new(0, 0, 0.4, -44)
loadingTitle.BackgroundTransparency = 1
loadingTitle.Text = "BEYOND <font color='#FF2B5A'>CLIENT</font> v6.3"
loadingTitle.RichText = true
loadingTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
loadingTitle.Font = Enum.Font.GothamBlack
loadingTitle.TextSize = 28
loadingTitle.Parent = loadingBg

local loadingSub = Instance.new("TextLabel")
loadingSub.Size = UDim2.new(1, 0, 0, 22)
loadingSub.Position = UDim2.new(0, 0, 0.4, 6)
loadingSub.BackgroundTransparency = 1
loadingSub.Text = "Mini Mode · HONOR Play5"
loadingSub.TextColor3 = Color3.fromRGB(140, 140, 155)
loadingSub.Font = Enum.Font.Code
loadingSub.TextSize = 14
loadingSub.Parent = loadingBg

local loadingBarBg = Instance.new("Frame")
loadingBarBg.Size = UDim2.new(0, 340, 0, 7)
loadingBarBg.Position = UDim2.new(0.5, -170, 0.4, 42)
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

TweenService:Create(loadingBar, TweenInfo.new(1.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    {Size = UDim2.new(1, 0, 1, 0)}):Play()

task.spawn(function()
    task.wait(1.4)
    TweenService:Create(loadingBg, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
    TweenService:Create(loadingTitle, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
    TweenService:Create(loadingSub, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
    TweenService:Create(loadingBarBg, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
    TweenService:Create(loadingBar, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
    task.wait(0.5)
    pcall(function() LoadingScreen:Destroy() end)
end)

-- ====================================================================
-- [7] DRAG + SELF-DESTRUCT + MINIMIZE
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
            local s = _G.BeyondConfig.UIScale or 1
            targetFrame.Position = UDim2.new(
                startPosition.X.Scale, startPosition.X.Offset + delta.X / s,
                startPosition.Y.Scale, startPosition.Y.Offset + delta.Y / s
            )
        end
    end)
end

-- ПОДКЛЮЧАЕМ DRAG КО ВСЕМ ТРЁМ ЗОНАМ:
EnableTouchDrag(Header, MainFrame)              -- верх
EnableTouchDrag(BottomLeftDrag, MainFrame)      -- низ-лево
EnableTouchDrag(BottomRightDrag, MainFrame)     -- низ-право

function _G.BeyondClient_SelfDestruct()
    ScriptActive = false
    _G.BeyondScriptActive = false
    pcall(function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = 16; hum.JumpPower = 50 end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = true end
        end
    end)
    pcall(function() BeyondScreenGui:Destroy() end)
    pcall(function() NotifyFolder:Destroy() end)
    pcall(function() if LoadingScreen then LoadingScreen:Destroy() end end)
    _G.BeyondConfig = nil
    _G.BeyondClient_SelfDestruct = nil
    print("[BeyondClient v6.3]: Следы стерты.")
end

CloseBtn.MouseButton1Click:Connect(function()
    if _G.BeyondClient_SelfDestruct then _G.BeyondClient_SelfDestruct() end
end)

MinimizeBtn.MouseButton1Click:Connect(function()
    if not ScriptActive then return end
    _G.BeyondConfig.IsMenuOpened = false
    TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
        {Size = UDim2.new(0, 520, 0, 0)}):Play()
    task.wait(0.25)
    MainFrame.Visible = false
    MobileToggleButton.Visible = true
    MobileToggleButton.Size = UDim2.new(0, 0, 0, 0)
    TweenService:Create(MobileToggleButton, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Size = UDim2.new(0, 56, 0, 56)}):Play()
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
        {Size = UDim2.new(0, 520, 0, 440)}):Play()
end)

-- ====================================================================
-- [8] UI FACTORIES (все объявлены ДО использования)
-- ====================================================================
function CreateMobileToggle(parent, text, default, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 50)
    ToggleFrame.BackgroundColor3 = _G.BeyondConfig.CardColor
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.Parent = parent
    Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 10)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.66, 0, 1, 0)
    Label.Position = UDim2.new(0, 16, 0, 0)
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(215, 215, 225)
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.TextWrapped = true
    Label.BackgroundTransparency = 1
    Label.Parent = ToggleFrame

    local CheckBox = Instance.new("TextButton")
    CheckBox.Size = UDim2.new(0, 50, 0, 28)
    CheckBox.Position = UDim2.new(1, -66, 0.5, -14)
    CheckBox.BackgroundColor3 = default and _G.BeyondConfig.ThemeColor or Color3.fromRGB(45, 45, 60)
    CheckBox.Text = ""
    CheckBox.Parent = ToggleFrame
    Instance.new("UICorner", CheckBox).CornerRadius = UDim.new(1, 0)

    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.new(0, 22, 0, 22)
    Indicator.Position = default and UDim2.new(1, -25, 0.5, -11) or UDim2.new(0, 3, 0.5, -11)
    Indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Indicator.Parent = CheckBox
    Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1, 0)

    local state = default
    CheckBox.MouseButton1Click:Connect(function()
        if not ScriptActive or not _G.BeyondConfig then return end
        state = not state
        local tc = state and _G.BeyondConfig.ThemeColor or Color3.fromRGB(45, 45, 60)
        local tp = state and UDim2.new(1, -25, 0.5, -11) or UDim2.new(0, 3, 0.5, -11)
        TweenService:Create(CheckBox, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {BackgroundColor3 = tc}):Play()
        TweenService:Create(Indicator, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {Position = tp}):Play()
        callback(state)
    end)
    return CheckBox
end

function CreateMobileSlider(parent, text, min, max, default, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, 0, 0, 64)
    SliderFrame.BackgroundColor3 = _G.BeyondConfig.CardColor
    SliderFrame.BorderSizePixel = 0
    SliderFrame.Parent = parent
    Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(0, 10)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.9, 0, 0, 28)
    Label.Position = UDim2.new(0, 16, 0, 4)
    Label.Text = text .. ": <font color='#FF2B5A'>" .. tostring(default) .. "</font>"
    Label.RichText = true
    Label.TextColor3 = Color3.fromRGB(220, 220, 230)
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1
    Label.Parent = SliderFrame

    local Track = Instance.new("Frame")
    Track.Size = UDim2.new(1, -32, 0, 8)
    Track.Position = UDim2.new(0, 16, 0, 42)
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

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 24, 0, 24)
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
        local x = math.clamp(input.Position.X - Track.AbsolutePosition.X, 0, totalSize)
        local ratio = x / totalSize
        local val = math.round(min + (ratio * (max - min)))
        Fill.Size = UDim2.new(ratio, 0, 1, 0)
        Knob.Position = UDim2.new(ratio, 0, 0.5, 0)
        Label.Text = text .. ": <font color='#FF2B5A'>" .. tostring(val) .. "</font>"
        callback(val)
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
    Lbl.Size = UDim2.new(1, 0, 0, 26)
    Lbl.BackgroundTransparency = 1
    Lbl.Text = "--- [ " .. titleText .. " ] ---"
    Lbl.TextColor3 = Color3.fromRGB(160, 160, 175)
    Lbl.Font = _G.BeyondConfig.Styles.FontsList.Bold
    Lbl.TextSize = 12
    Lbl.TextStrokeTransparency = 0.8
    Lbl.Parent = parent
    return Lbl
end

function CreateActionButton(parent, textTitle, bgColor, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 42)
    Btn.BackgroundColor3 = bgColor or Color3.fromRGB(34, 34, 46)
    Btn.Text = textTitle
    Btn.TextColor3 = Color3.fromRGB(240, 240, 245)
    Btn.Font = _G.BeyondConfig.Styles.FontsList.Bold
    Btn.TextSize = 12
    Btn.Parent = parent
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)

    local BStroke = Instance.new("UIStroke")
    BStroke.Thickness = 1
    BStroke.Color = _G.BeyondConfig.Styles.BorderStrokeColor
    BStroke.Parent = Btn

    local origText = textTitle
    local origColor = bgColor or Color3.fromRGB(34, 34, 46)

    Btn.MouseButton1Click:Connect(function()
        if not ScriptActive then return end
        Btn.Text = "⏳ ..."
        Btn.TextColor3 = Color3.fromRGB(255, 200, 100)
        TweenService:Create(Btn, TweenInfo.new(0.08), {BackgroundColor3 = _G.BeyondConfig.ThemeColor}):Play()
        task.spawn(function()
            pcall(callback)
            task.wait(0.4)
            if Btn and Btn.Parent then
                Btn.Text = origText
                Btn.TextColor3 = Color3.fromRGB(240, 240, 245)
                TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = origColor}):Play()
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

-- === ИСПРАВЛЕНО: используем parent, а не StatsCardFrame ===
function CreateStatDisplayLabel(parent, nameTag, yPosition)
    local DisplayLabel = Instance.new("TextLabel")
    DisplayLabel.Size = UDim2.new(1, -28, 0, 26)
    DisplayLabel.Position = UDim2.new(0, 16, 0, yPosition)
    DisplayLabel.BackgroundTransparency = 1
    DisplayLabel.Text = nameTag .. ": <font color='#00FF8C'>Загрузка...</font>"
    DisplayLabel.RichText = true
    DisplayLabel.TextColor3 = Color3.fromRGB(215, 215, 225)
    DisplayLabel.Font = _G.BeyondConfig.Styles.FontsList.Semibold
    DisplayLabel.TextSize = 13
    DisplayLabel.TextXAlignment = Enum.TextXAlignment.Left
    DisplayLabel.Parent = parent     -- ✅ теперь корректно
    return DisplayLabel
end

-- ====================================================================
-- [9] UTILITIES
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

function HookSoundToUIElement(el, isSlider)
    if not el or not el:IsA("GuiButton") then return end
    el.InputBegan:Connect(function(input)
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
            local tc = TextChatService:FindFirstChild("TextChannels")
            local gc = tc and tc:FindFirstChild("RBXGeneral")
            if gc and gc:IsA("TextChannel") then gc:SendAsync(textString) return end
        end
        local legacy = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
        local smr = legacy and legacy:FindFirstChild("SayMessageRequest")
        if smr and smr:IsA("RemoteEvent") then smr:FireServer(textString, "All") end
    end)
end

function ToggleEnvironmentOptimization(enable)
    if not ScriptActive or not _G.BeyondConfig then return end
    pcall(function()
        if enable then
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 100000
            if Terrain then
                Terrain.WaterWaveSize = 0; Terrain.WaterWaveSpeed = 0
                Terrain.WaterReflectance = 0; Terrain.WaterTransparency = 0
            end
            for _, e in ipairs(Lighting:GetChildren()) do
                if e:IsA("PostEffect") or e:IsA("BloomEffect")
                   or e:IsA("SunRaysEffect") or e:IsA("Atmosphere") then
                    if e.Name ~= "Beyond_Interface_Blur" then e.Enabled = false end
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
                Terrain.WaterWaveSize = 0.15; Terrain.WaterWaveSpeed = 1
                Terrain.WaterReflectance = 1; Terrain.WaterTransparency = 1
            end
            for _, e in ipairs(Lighting:GetChildren()) do
                if e:IsA("PostEffect") or e:IsA("BloomEffect")
                   or e:IsA("SunRaysEffect") or e:IsA("Atmosphere") then
                    if e.Name ~= "Beyond_Interface_Blur" then e.Enabled = true end
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
-- [10] HIGHLIGHT + CROSSHAIR + UNIFIED RENDER LOOP
-- ====================================================================
function ApplyHighlight(player)
    if player == LocalPlayer then return end
    local function setupCharacter(char)
        if not ScriptActive or not _G.BeyondConfig then return end
        local oldHl = char:FindFirstChild("Beyond_Highlight")
        if oldHl then oldHl:Destroy() end
        local hl = Instance.new("Highlight")
        hl.Name = "Beyond_Highlight"
        hl.FillColor = _G.BeyondConfig.ThemeColor
        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
        hl.FillTransparency = _G.BeyondConfig.Visuals.EspFillTransparency
        hl.OutlineTransparency = _G.BeyondConfig.Visuals.EspOutlineTransparency
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Enabled = _G.BeyondConfig.Visuals.HighlightESP
        hl.Parent = char
    end
    if player.Character then setupCharacter(player.Character) end
    player.CharacterAdded:Connect(setupCharacter)
end

for _, player in ipairs(Players:GetPlayers()) do ApplyHighlight(player) end
Players.PlayerAdded:Connect(ApplyHighlight)

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

function RecalibrateCrosshairGeometry()
    if not _G.BeyondConfig or not _G.BeyondConfig.Crosshair then return end
    if _G.BeyondConfig.CrosshairRemoved then
        CrosshairContainer.Visible = false
        return
    end
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

-- ФУНКЦИЯ УДАЛЕНИЯ ПРИЦЕЛА
function DestroyCrosshair()
    if not _G.BeyondConfig then return end
    _G.BeyondConfig.Crosshair.Enabled = false
    _G.BeyondConfig.CrosshairRemoved = true
    if CrosshairContainer and CrosshairContainer.Parent then
        pcall(function() CrosshairContainer:Destroy() end)
    end
    PushNotification("Crosshair", "Прицел полностью удалён из меню", "warn")
end

-- Telemetry
local TelemetryData = {
    CurrentFps = 60, CurrentPing = 0, CurrentMemory = 0,
    FrameCount = 0, TimeCounter = 0, LowFpsCounter = 0
}

-- UNIFIED RENDER LOOP
RunService.RenderStepped:Connect(function(dt)
    if not ScriptActive or not _G.BeyondConfig then return end

    _G.BeyondConfig.GlowPhase = (_G.BeyondConfig.GlowPhase
        + (dt * (_G.BeyondConfig.Visuals.GlowSpeed / 10))) % 1
    local rainbow = Color3.fromHSV(_G.BeyondConfig.GlowPhase, 0.85, 1)

    if _G.BeyondConfig.Visuals.RainbowGlow then
        Stroke.Color = rainbow
        HeaderLine.BackgroundColor3 = rainbow
        Container.ScrollBarImageColor3 = rainbow
    end

    TelemetryData.FrameCount = TelemetryData.FrameCount + 1
    TelemetryData.TimeCounter = TelemetryData.TimeCounter + dt
    if TelemetryData.TimeCounter >= 1.0 then
        TelemetryData.CurrentFps = math.round(TelemetryData.FrameCount / TelemetryData.TimeCounter)
        TelemetryData.FrameCount = 0
        TelemetryData.TimeCounter = 0
        if _G.BeyondConfig.Visuals.FpsAutoDisable and _G.BeyondConfig.Visuals.HighlightESP then
            if TelemetryData.CurrentFps < _G.BeyondConfig.Visuals.FpsThreshold then
                TelemetryData.LowFpsCounter = TelemetryData.LowFpsCounter + 1
                if TelemetryData.LowFpsCounter >= 3 then
                    for _, p in ipairs(Players:GetPlayers()) do
                        local c = p.Character
                        local h = c and c:FindFirstChild("Beyond_Highlight")
                        if h then h.Enabled = false end
                    end
                    TelemetryData.LowFpsCounter = 0
                end
            else
                TelemetryData.LowFpsCounter = 0
            end
        end
    end

    if _G.BeyondConfig.Visuals.HighlightESP then
        local myChar = LocalPlayer.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        local myPos = myRoot and myRoot.Position
        local maxD = _G.BeyondConfig.Visuals.MaxDistance
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                local c = p.Character
                local hl = c and c:FindFirstChild("Beyond_Highlight")
                if hl and hl:IsA("Highlight") then
                    local theirRoot = c:FindFirstChild("HumanoidRootPart")
                    local theirPos = theirRoot and theirRoot.Position
                    local dist = (myPos and theirPos) and (myPos - theirPos).Magnitude or 0
                    if dist <= maxD then
                        hl.Enabled = true
                        hl.FillColor = rainbow
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

    -- Crosshair render (только если не удалён)
    if not _G.BeyondConfig.CrosshairRemoved
       and _G.BeyondConfig.Crosshair.Enabled
       and CrosshairContainer and CrosshairContainer.Parent then
        local sc = _G.BeyondConfig.Visuals.RainbowGlow and rainbow
            or _G.BeyondConfig.Crosshair.Color
        for _, line in ipairs(linesArray) do
            if line and line.Parent then line.BackgroundColor3 = sc end
        end
    end
end)

-- ====================================================================
-- [11] TAB SYSTEM
-- ====================================================================
function CreateTabButton(name, layoutOrder)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Name = "Tab_" .. name
    TabBtn.Size = UDim2.new(0, 92, 0, 30)
    TabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    TabBtn.Text = name
    TabBtn.TextColor3 = Color3.fromRGB(200, 200, 215)
    TabBtn.Font = Enum.Font.GothamSemibold
    TabBtn.TextSize = 12
    TabBtn.LayoutOrder = layoutOrder
    TabBtn.Parent = TabBar
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 7)
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
    PageLayout.Padding = UDim.new(0, 10)
    PageLayout.Parent = Page

    PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        if ScriptActive and Container and Page.Visible then
            Container.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 20)
        end
    end)
    return Page, PageLayout
end

for _, tabName in ipairs({"Visual", "Move", "Auto", "Config", "Debug"}) do
    local btn = CreateTabButton(tabName, #Tabs + 1)
    local page, layout = CreateTabPage(tabName)
    Tabs[tabName] = {Button = btn, Page = page, Layout = layout}
    TabPages[tabName] = page
end

function SwitchTab(name)
    if not Tabs[name] then return end
    for tName, tData in pairs(Tabs) do
        local isActive = (tName == name)
        tData.Page.Visible = isActive
        TweenService:Create(tData.Button, TweenInfo.new(0.2),
            {BackgroundColor3 = isActive and _G.BeyondConfig.ThemeColor or Color3.fromRGB(30, 30, 40)}):Play()
        tData.Button.TextColor3 = isActive and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 215)
    end
    ActiveTabName = name
    _G.BeyondConfig.ActiveTab = name
    Container.CanvasSize = UDim2.new(0, 0, 0, Tabs[name].Layout.AbsoluteContentSize.Y + 20)
    Container.CanvasPosition = Vector2.new(0, 0)
end

for tName, tData in pairs(Tabs) do
    tData.Button.MouseButton1Click:Connect(function()
        if not ScriptActive then return end
        SwitchTab(tName)
    end)
end
SwitchTab("Visual")

-- ====================================================================
-- [12] TAB VISUAL
-- ====================================================================
local visualPage = TabPages["Visual"]

CreateSectionLabel(visualPage, "ПОДСВЕТКА (ESP)")

CreateMobileToggle(visualPage, "Подсветка игроков", _G.BeyondConfig.Visuals.HighlightESP, function(state)
    _G.BeyondConfig.Visuals.HighlightESP = state
    PushNotification("Visuals", state and "Highlight ON" or "Highlight OFF", state and "success" or "warn")
    if not state then
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character then
                local hl = p.Character:FindFirstChild("Beyond_Highlight")
                if hl then hl.Enabled = false end
            end
        end
    end
end)

CreateMobileSlider(visualPage, "Прозрачность силуэта (%)", 0, 100, 50, function(v)
    _G.BeyondConfig.Visuals.EspFillTransparency = v / 100
end)

CreateMobileSlider(visualPage, "Прозрачность обводки (%)", 0, 100, 0, function(v)
    _G.BeyondConfig.Visuals.EspOutlineTransparency = v / 100
end)

CreateMobileSlider(visualPage, "Дистанция ESP (studs)", 50, 500, _G.BeyondConfig.Visuals.MaxDistance, function(v)
    _G.BeyondConfig.Visuals.MaxDistance = v
end)

CreateMobileToggle(visualPage, "Авто-выкл при FPS < 20", _G.BeyondConfig.Visuals.FpsAutoDisable, function(state)
    _G.BeyondConfig.Visuals.FpsAutoDisable = state
end)

CreateMobileToggle(visualPage, "RGB переливание UI", _G.BeyondConfig.Visuals.RainbowGlow, function(state)
    _G.BeyondConfig.Visuals.RainbowGlow = state
    if not state then
        Stroke.Color = _G.BeyondConfig.ThemeColor
        HeaderLine.BackgroundColor3 = _G.BeyondConfig.ThemeColor
        Container.ScrollBarImageColor3 = _G.BeyondConfig.ThemeColor
    end
end)

CreateSectionLabel(visualPage, "ПРИЦЕЛ")

CreateMobileToggle(visualPage, "Отображать прицел", _G.BeyondConfig.Crosshair.Enabled, function(state)
    if _G.BeyondConfig.CrosshairRemoved then
        PushNotification("Crosshair", "Прицел удалён из меню", "error")
        return
    end
    _G.BeyondConfig.Crosshair.Enabled = state
    RecalibrateCrosshairGeometry()
end)

CreateMobileToggle(visualPage, "Центральная точка", _G.BeyondConfig.Crosshair.CenterDot, function(state)
    if _G.BeyondConfig.CrosshairRemoved then return end
    _G.BeyondConfig.Crosshair.CenterDot = state
    RecalibrateCrosshairGeometry()
end)

CreateMobileSlider(visualPage, "Длина линий", 6, 50, _G.BeyondConfig.Crosshair.Size, function(v)
    if _G.BeyondConfig.CrosshairRemoved then return end
    _G.BeyondConfig.Crosshair.Size = v
    RecalibrateCrosshairGeometry()
end)

CreateMobileSlider(visualPage, "Толщина линий", 1, 10, _G.BeyondConfig.Crosshair.Thickness, function(v)
    if _G.BeyondConfig.CrosshairRemoved then return end
    _G.BeyondConfig.Crosshair.Thickness = v
    RecalibrateCrosshairGeometry()
end)

CreateMobileSlider(visualPage, "Зазор (Gap)", 0, 30, _G.BeyondConfig.Crosshair.Gap, function(v)
    if _G.BeyondConfig.CrosshairRemoved then return end
    _G.BeyondConfig.Crosshair.Gap = v
    RecalibrateCrosshairGeometry()
end)

-- === НОВАЯ КНОПКА УДАЛЕНИЯ ПРИЦЕЛА ===
CreateActionButton(visualPage, "🗑  УДАЛИТЬ ПРИЦЕЛ ИЗ МЕНЮ", Color3.fromRGB(60, 30, 34), function()
    DestroyCrosshair()
end)

CreateSectionLabel(visualPage, "ТЕМЫ")

local StylePresetFrame = CreateCardFrame(visualPage, 96)

local StyleLabel = Instance.new("TextLabel")
StyleLabel.Size = UDim2.new(1, -24, 0, 26)
StyleLabel.Position = UDim2.new(0, 16, 0, 4)
StyleLabel.Text = "Тема: <font color='#FF2B5A'>" .. _G.BeyondConfig.Styles.CurrentThemePreset .. "</font>"
StyleLabel.RichText = true
StyleLabel.TextColor3 = Color3.fromRGB(225, 225, 235)
StyleLabel.Font = _G.BeyondConfig.Styles.FontsList.Semibold
StyleLabel.TextSize = 13
StyleLabel.TextXAlignment = Enum.TextXAlignment.Left
StyleLabel.BackgroundTransparency = 1
StyleLabel.Parent = StylePresetFrame

function InitializeThemeButton(themeName, xOffset, primeColor)
    local TB = Instance.new("TextButton")
    TB.Size = UDim2.new(0.28, 0, 0, 40)
    TB.Position = UDim2.new(0, xOffset, 0, 42)
    TB.BackgroundColor3 = Color3.fromRGB(34, 34, 46)
    TB.Text = themeName
    TB.TextColor3 = Color3.fromRGB(245, 245, 250)
    TB.Font = _G.BeyondConfig.Styles.FontsList.Bold
    TB.TextSize = 11
    TB.Parent = StylePresetFrame
    Instance.new("UICorner", TB).CornerRadius = UDim.new(0, 7)

    TB.MouseButton1Click:Connect(function()
        if not ScriptActive or not _G.BeyondConfig then return end
        if _G.BeyondConfig.Visuals.RainbowGlow then
            PushNotification("Theme", "Выключите RGB перед сменой темы", "warn")
            return
        end
        _G.BeyondConfig.Styles.CurrentThemePreset = themeName
        _G.BeyondConfig.ThemeColor = primeColor
        _G.BeyondConfig.Crosshair.Color = primeColor
        StyleLabel.Text = "Тема: <font color='#FF2B5A'>" .. themeName .. "</font>"
        local ti = TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
        TweenService:Create(Stroke, ti, {Color = primeColor}):Play()
        TweenService:Create(HeaderLine, ti, {BackgroundColor3 = primeColor}):Play()
        TweenService:Create(Container, ti, {ScrollBarImageColor3 = primeColor}):Play()
        TweenService:Create(MobileToggleButton, ti, {ImageColor3 = primeColor}):Play()
        TweenService:Create(ButtonStroke, ti, {Color = primeColor}):Play()
        TweenService:Create(BottomLeftStroke, ti, {Color = primeColor}):Play()
        TweenService:Create(BottomRightStroke, ti, {Color = primeColor}):Play()
        PushNotification("Theme", "Тема: " .. themeName, "success")
    end)
end

InitializeThemeButton("Zero Two",  16,  Color3.fromRGB(255, 43, 90))
InitializeThemeButton("Кибер",     170, Color3.fromRGB(0, 255, 240))
InitializeThemeButton("Токсик",    324, Color3.fromRGB(170, 255, 0))

-- ====================================================================
-- [13] TAB MOVE
-- ====================================================================
local movePage = TabPages["Move"]

CreateSectionLabel(movePage, "СКОРОСТЬ И ПРЫЖОК")

CreateMobileSlider(movePage, "WalkSpeed", 16, 250, _G.BeyondConfig.Movement.WalkSpeed, function(v)
    _G.BeyondConfig.Movement.WalkSpeed = v
    pcall(function()
        local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if h then h.WalkSpeed = v end
    end)
end)

CreateMobileSlider(movePage, "JumpPower", 50, 500, _G.BeyondConfig.Movement.JumpPower, function(v)
    _G.BeyondConfig.Movement.JumpPower = v
    pcall(function()
        local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if h then h.UseJumpPower = true; h.JumpPower = v end
    end)
end)

CreateMobileToggle(movePage, "Бесконечный прыжок", false, function(state)
    _G.BeyondConfig.InfiniteJump = state
    PushNotification("Move", state and "Inf Jump ON" or "Inf Jump OFF", state and "success" or "warn")
end)

CreateMobileToggle(movePage, "Noclip", false, function(state)
    _G.BeyondConfig.Noclip = state
    PushNotification("Move", state and "Noclip ON" or "Noclip OFF", state and "success" or "warn")
end)

CreateSectionLabel(movePage, "ПОЛЁТ (FLY)")

CreateMobileToggle(movePage, "Включить Fly", false, function(state)
    _G.BeyondConfig.FlyEnabled = state
    PushNotification("Move", state and "Fly ON" or "Fly OFF", state and "success" or "warn")
end)

CreateMobileSlider(movePage, "FlySpeed", 20, 300, _G.BeyondConfig.Movement.FlySpeed, function(v)
    _G.BeyondConfig.FlySpeed = v
end)

CreateSectionLabel(movePage, "АВТОМАТИКА")

CreateMobileToggle(movePage, "Anti-AFK", true, function(state)
    _G.BeyondConfig.AntiAFK = state
end)

UserInputService.JumpRequest:Connect(function()
    if not ScriptActive or not _G.BeyondConfig then return end
    if _G.BeyondConfig.InfiniteJump then
        pcall(function()
            local c = LocalPlayer.Character
            local h = c and c:FindFirstChildOfClass("Humanoid")
            if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    end
end)

RunService.Stepped:Connect(function()
    if not ScriptActive or not _G.BeyondConfig then return end
    if _G.BeyondConfig.Noclip then
        pcall(function()
            local c = LocalPlayer.Character
            if c then
                for _, part in ipairs(c:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
                end
            end
        end)
    end
end)

local flyBodyVelocity, flyBodyGyro, flyConnection

function StartFly()
    if flyConnection then return end
    pcall(function()
        local c = LocalPlayer.Character
        local hrp = c and c:FindFirstChild("HumanoidRootPart")
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
                flyBodyVelocity = nil; flyBodyGyro = nil; flyConnection = nil
                return
            end
            local ch = LocalPlayer.Character
            local root = ch and ch:FindFirstChild("HumanoidRootPart")
            if not root then return end
            local cam = workspace.CurrentCamera
            local md = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then md = md + cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then md = md - cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then md = md - cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then md = md + cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then md = md + Vector3.new(0, 1, 0) end
            if md.Magnitude > 0 then md = md.Unit * _G.BeyondConfig.FlySpeed end
            flyBodyVelocity.Velocity = md
            flyBodyGyro.CFrame = cam.CFrame
        end)
    end)
end

function StopFly()
    pcall(function()
        if flyBodyVelocity then flyBodyVelocity:Destroy() end
        if flyBodyGyro then flyBodyGyro:Destroy() end
        if flyConnection then flyConnection:Disconnect() end
        flyBodyVelocity = nil; flyBodyGyro = nil; flyConnection = nil
    end)
end

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    if not _G.BeyondConfig then return end
    pcall(function()
        local h = char:FindFirstChildOfClass("Humanoid")
        if h then
            h.WalkSpeed = _G.BeyondConfig.Movement.WalkSpeed
            h.UseJumpPower = true
            h.JumpPower = _G.BeyondConfig.Movement.JumpPower
        end
    end)
    if _G.BeyondConfig.FlyEnabled then StartFly() end
end)

task.spawn(function()
    while ScriptActive and task.wait(0.2) do
        if not _G.BeyondConfig then break end
        if _G.BeyondConfig.FlyEnabled and not flyConnection then StartFly()
        elseif not _G.BeyondConfig.FlyEnabled and flyConnection then StopFly() end
    end
end)

pcall(function()
    LocalPlayer.Idled:Connect(function()
        if not ScriptActive or not _G.BeyondConfig or not _G.BeyondConfig.AntiAFK then return end
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(0, 0))
        end)
    end)
end)

-- ====================================================================
-- [14] TAB AUTO
-- ====================================================================
local autoPage = TabPages["Auto"]

CreateSectionLabel(autoPage, "АВТОКЛИКЕР")

CreateMobileToggle(autoPage, "Активировать автокликер", _G.BeyondConfig.Automation.AutoClickEnabled, function(state)
    _G.BeyondConfig.Automation.AutoClickEnabled = state
    PushNotification("Auto", state and "AutoClick ON" or "AutoClick OFF", state and "success" or "warn")
    if state then
        task.spawn(function()
            while _G.BeyondConfig and _G.BeyondConfig.Automation.AutoClickEnabled and ScriptActive do
                local d = math.clamp(_G.BeyondConfig.Automation.ClickInterval / 1000, 0.01, 1.0)
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
                        FooterText.Text = "Clicks: " .. tostring(_G.BeyondConfig.Automation.TotalClicksSimulated)
                    end
                end)
                task.wait(d)
            end
        end)
    else
        pcall(function()
            if FooterText and FooterText.Parent then FooterText.Text = "Adaptive Mode ON" end
        end)
    end
end)

CreateMobileSlider(autoPage, "Интервал клика (мс)", 10, 1000, _G.BeyondConfig.Automation.ClickInterval, function(v)
    _G.BeyondConfig.Automation.ClickInterval = v
end)

CreateSectionLabel(autoPage, "АВТОПРЫЖОК")

CreateMobileToggle(autoPage, "Автопрыжок", false, function(state)
    _G.BeyondConfig.Automation.AutoJumpEnabled = state
    if state then
        task.spawn(function()
            while _G.BeyondConfig and _G.BeyondConfig.Automation.AutoJumpEnabled and ScriptActive do
                pcall(function()
                    local c = LocalPlayer.Character
                    local h = c and c:FindFirstChildOfClass("Humanoid")
                    if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
                end)
                task.wait(_G.BeyondConfig.Automation.AutoJumpInterval / 1000)
            end
        end)
    end
end)

CreateMobileSlider(autoPage, "Интервал прыжка (мс)", 100, 2000, 300, function(v)
    _G.BeyondConfig.Automation.AutoJumpInterval = v
end)

CreateSectionLabel(autoPage, "ЧАТ-МАКРОСЫ")

local ChatMacroData = {
    {Name = "Приветствие", Phrase = "Привет всем! Beyond v6.3 Mini."},
    {Name = "Внимание",    Phrase = "Тактическая активность!"},
    {Name = "GG",          Phrase = "GG WP всем!"}
}

for _, mi in ipairs(ChatMacroData) do
    local MF = CreateCardFrame(autoPage, 68)
    local MNL = Instance.new("TextLabel")
    MNL.Size = UDim2.new(0.6, 0, 0, 22)
    MNL.Position = UDim2.new(0, 16, 0, 6)
    MNL.Text = mi.Name
    MNL.TextColor3 = Color3.fromRGB(240, 240, 245)
    MNL.Font = _G.BeyondConfig.Styles.FontsList.Bold
    MNL.TextSize = 13
    MNL.TextXAlignment = Enum.TextXAlignment.Left
    MNL.BackgroundTransparency = 1
    MNL.Parent = MF

    local MPL = Instance.new("TextLabel")
    MPL.Size = UDim2.new(0.6, 0, 0, 30)
    MPL.Position = UDim2.new(0, 16, 0, 30)
    MPL.Text = mi.Phrase
    MPL.TextColor3 = Color3.fromRGB(130, 130, 145)
    MPL.Font = _G.BeyondConfig.Styles.FontsList.Regular
    MPL.TextSize = 10
    MPL.TextWrapped = true
    MPL.TextXAlignment = Enum.TextXAlignment.Left
    MPL.TextYAlignment = Enum.TextYAlignment.Top
    MPL.BackgroundTransparency = 1
    MPL.Parent = MF

    local SB = Instance.new("TextButton")
    SB.Size = UDim2.new(0, 106, 0, 40)
    SB.Position = UDim2.new(1, -122, 0.5, -20)
    SB.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
    SB.Text = "ОТПРАВИТЬ"
    SB.TextColor3 = Color3.fromRGB(255, 255, 255)
    SB.Font = _G.BeyondConfig.Styles.FontsList.Bold
    SB.TextSize = 11
    SB.Parent = MF
    Instance.new("UICorner", SB).CornerRadius = UDim.new(0, 8)

    SB.MouseButton1Click:Connect(function()
        if not ScriptActive or not _G.BeyondConfig then return end
        TweenService:Create(SB, TweenInfo.new(0.1), {BackgroundColor3 = _G.BeyondConfig.ThemeColor}):Play()
        task.spawn(function()
            FireLegalChatMessage(mi.Phrase)
            task.wait(0.2)
            if _G.BeyondConfig then
                TweenService:Create(SB, TweenInfo.new(0.2),
                    {BackgroundColor3 = Color3.fromRGB(35, 35, 48)}):Play()
            end
        end)
    end)
end

-- ====================================================================
-- [15] TAB CONFIG
-- ====================================================================
local configPage = TabPages["Config"]

CreateSectionLabel(configPage, "СЛОТЫ ПРОФИЛЕЙ")

local ConfigCardFrame = CreateCardFrame(configPage, 180)

local ConfigStatusLabel = Instance.new("TextLabel")
ConfigStatusLabel.Size = UDim2.new(1, -24, 0, 26)
ConfigStatusLabel.Position = UDim2.new(0, 16, 0, 6)
ConfigStatusLabel.Text = "Система: <font color='#00FF8C'>Готова</font>"
ConfigStatusLabel.RichText = true
ConfigStatusLabel.TextColor3 = Color3.fromRGB(225, 225, 235)
ConfigStatusLabel.Font = _G.BeyondConfig.Styles.FontsList.Semibold
ConfigStatusLabel.TextSize = 13
ConfigStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
ConfigStatusLabel.BackgroundTransparency = 1
ConfigStatusLabel.Parent = ConfigCardFrame

local ActiveSlotLabel = Instance.new("TextLabel")
ActiveSlotLabel.Size = UDim2.new(1, -24, 0, 22)
ActiveSlotLabel.Position = UDim2.new(0, 16, 0, 36)
ActiveSlotLabel.Text = "Активный слот: <font color='#FF2B5A'>" .. _G.BeyondConfig.ConfigSlots.ActiveSlot
    .. "</font> / " .. _G.BeyondConfig.ConfigSlots.SlotCount
ActiveSlotLabel.RichText = true
ActiveSlotLabel.TextColor3 = Color3.fromRGB(215, 215, 225)
ActiveSlotLabel.Font = _G.BeyondConfig.Styles.FontsList.Regular
ActiveSlotLabel.TextSize = 12
ActiveSlotLabel.TextXAlignment = Enum.TextXAlignment.Left
ActiveSlotLabel.BackgroundTransparency = 1
ActiveSlotLabel.Parent = ConfigCardFrame

function PushConfigStatusUpdate(html)
    if ConfigStatusLabel and ConfigStatusLabel.Parent then
        ConfigStatusLabel.Text = "Система: " .. html
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
        SpeedValue = _G.BeyondConfig.Movement.WalkSpeed,
        JumpPower = _G.BeyondConfig.Movement.JumpPower,
        FlySpeed = _G.BeyondConfig.Movement.FlySpeed,
        InfiniteJump = _G.BeyondConfig.InfiniteJump,
        Noclip = _G.BeyondConfig.Noclip,
        FlyEnabled = _G.BeyondConfig.FlyEnabled,
        AntiAFK = _G.BeyondConfig.AntiAFK,
        ThemeColor = {_G.BeyondConfig.ThemeColor.R, _G.BeyondConfig.ThemeColor.G, _G.BeyondConfig.ThemeColor.B},
        HighlightESP = _G.BeyondConfig.Visuals.HighlightESP,
        EspFillTransparency = _G.BeyondConfig.Visuals.EspFillTransparency,
        EspOutlineTransparency = _G.BeyondConfig.Visuals.EspOutlineTransparency,
        MaxDistance = _G.BeyondConfig.Visuals.MaxDistance,
        RainbowGlow = _G.BeyondConfig.Visuals.RainbowGlow,
        GlowSpeed = _G.BeyondConfig.Visuals.GlowSpeed,
        AutoClickEnabled = _G.BeyondConfig.Automation.AutoClickEnabled,
        ClickInterval = _G.BeyondConfig.Automation.ClickInterval,
        CurrentThemePreset = _G.BeyondConfig.Styles.CurrentThemePreset
    }
end

function SaveConfigToSlot()
    local FS = _G.BeyondFS or FileSystemAPI
    if not FS or not FS.Write then
        PushConfigStatusUpdate("<font color='#FF2B5A'>WriteFile недоступен</font>")
        return
    end
    local slot = _G.BeyondConfig.ConfigSlots.ActiveSlot
    local fn = BEYOND_CONFIG_BASE .. tostring(slot) .. ".json"
    local okSer, encoded = pcall(function() return HttpService:JSONEncode(SerializeConfig()) end)
    if not (okSer and encoded) then
        PushConfigStatusUpdate("<font color='#FF2B5A'>Ошибка сериализации</font>")
        return
    end
    local okW = pcall(function() FS.Write(fn, encoded) end)
    if okW then
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
    local fn = BEYOND_CONFIG_BASE .. tostring(slot) .. ".json"
    if not FS.Check(fn) then
        PushConfigStatusUpdate("<font color='#FFBB00'>Слот " .. slot .. " пуст</font>")
        return
    end
    local okR, raw = pcall(function() return FS.Read(fn) end)
    if not (okR and raw) then
        PushConfigStatusUpdate("<font color='#FF2B5A'>Ошибка чтения</font>")
        return
    end
    local okD, dec = pcall(function() return HttpService:JSONDecode(raw) end)
    if not (okD and dec) then
        PushConfigStatusUpdate("<font color='#FF2B5A'>Ошибка JSON</font>")
        return
    end
    pcall(function()
        if dec.SpeedValue then _G.BeyondConfig.Movement.WalkSpeed = dec.SpeedValue end
        if dec.JumpPower then _G.BeyondConfig.Movement.JumpPower = dec.JumpPower end
        if dec.FlySpeed then _G.BeyondConfig.Movement.FlySpeed = dec.FlySpeed end
        if dec.InfiniteJump then _G.BeyondConfig.InfiniteJump = dec.InfiniteJump end
        if dec.Noclip then _G.BeyondConfig.Noclip = dec.Noclip end
        if dec.FlyEnabled then _G.BeyondConfig.FlyEnabled = dec.FlyEnabled end
        if dec.AntiAFK then _G.BeyondConfig.AntiAFK = dec.AntiAFK end
        if dec.HighlightESP then _G.BeyondConfig.Visuals.HighlightESP = dec.HighlightESP end
        if dec.EspFillTransparency then _G.BeyondConfig.Visuals.EspFillTransparency = dec.EspFillTransparency end
        if dec.EspOutlineTransparency then _G.BeyondConfig.Visuals.EspOutlineTransparency = dec.EspOutlineTransparency end
        if dec.MaxDistance then _G.BeyondConfig.Visuals.MaxDistance = dec.MaxDistance end
        if dec.RainbowGlow then _G.BeyondConfig.Visuals.RainbowGlow = dec.RainbowGlow end
        if dec.GlowSpeed then _G.BeyondConfig.Visuals.GlowSpeed = dec.GlowSpeed end
        if dec.AutoClickEnabled then _G.BeyondConfig.Automation.AutoClickEnabled = dec.AutoClickEnabled end
        if dec.ClickInterval then _G.BeyondConfig.Automation.ClickInterval = dec.ClickInterval end
        if dec.CurrentThemePreset then _G.BeyondConfig.Styles.CurrentThemePreset = dec.CurrentThemePreset end
        if dec.ThemeColor then
            _G.BeyondConfig.ThemeColor = Color3.new(dec.ThemeColor[1], dec.ThemeColor[2], dec.ThemeColor[3])
        end
    end)
    PushConfigStatusUpdate("<font color='#00FF8C'>Слот " .. slot .. " применён!</font>")
    PushNotification("Config", "Загружен слот " .. slot, "success")
end

local SlotRow = Instance.new("Frame")
SlotRow.Size = UDim2.new(1, -24, 0, 38)
SlotRow.Position = UDim2.new(0, 12, 0, 66)
SlotRow.BackgroundTransparency = 1
SlotRow.Parent = ConfigCardFrame

local SlotBtnLayout = Instance.new("UIListLayout")
SlotBtnLayout.FillDirection = Enum.FillDirection.Horizontal
SlotBtnLayout.Padding = UDim.new(0, 7)
SlotBtnLayout.Parent = SlotRow

for i = 1, _G.BeyondConfig.ConfigSlots.SlotCount do
    local SB = Instance.new("TextButton")
    SB.Size = UDim2.new(0, 52, 0, 34)
    SB.BackgroundColor3 = (i == _G.BeyondConfig.ConfigSlots.ActiveSlot)
        and _G.BeyondConfig.ThemeColor or Color3.fromRGB(34, 34, 46)
    SB.Text = "S" .. i
    SB.TextColor3 = Color3.fromRGB(245, 245, 250)
    SB.Font = _G.BeyondConfig.Styles.FontsList.Bold
    SB.TextSize = 12
    SB.LayoutOrder = i
    SB.Parent = SlotRow
    Instance.new("UICorner", SB).CornerRadius = UDim.new(0, 6)

    SB.MouseButton1Click:Connect(function()
        if not ScriptActive then return end
        _G.BeyondConfig.ConfigSlots.ActiveSlot = i
        for _, ch in ipairs(SlotRow:GetChildren()) do
            if ch:IsA("TextButton") then
                local idx = tonumber(ch.Text:sub(2))
                TweenService:Create(ch, TweenInfo.new(0.2), {
                    BackgroundColor3 = (idx == i) and _G.BeyondConfig.ThemeColor or Color3.fromRGB(34, 34, 46)
                }):Play()
            end
        end
        UpdateActiveSlotLabel()
    end)
end

local SaveRow = Instance.new("Frame")
SaveRow.Size = UDim2.new(1, -24, 0, 42)
SaveRow.Position = UDim2.new(0, 12, 0, 112)
SaveRow.BackgroundTransparency = 1
SaveRow.Parent = ConfigCardFrame

local SaveBtn = Instance.new("TextButton")
SaveBtn.Size = UDim2.new(0.48, 0, 1, 0)
SaveBtn.Position = UDim2.new(0, 0, 0, 0)
SaveBtn.BackgroundColor3 = Color3.fromRGB(34, 46, 38)
SaveBtn.Text = "СОХРАНИТЬ"
SaveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SaveBtn.Font = _G.BeyondConfig.Styles.FontsList.Bold
SaveBtn.TextSize = 12
SaveBtn.Parent = SaveRow
Instance.new("UICorner", SaveBtn).CornerRadius = UDim.new(0, 8)
SaveBtn.MouseButton1Click:Connect(function()
    if not ScriptActive then return end
    SaveBtn.Text = "⏳..."
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
LoadBtn.TextSize = 12
LoadBtn.Parent = SaveRow
Instance.new("UICorner", LoadBtn).CornerRadius = UDim.new(0, 8)
LoadBtn.MouseButton1Click:Connect(function()
    if not ScriptActive then return end
    LoadBtn.Text = "⏳..."
    task.spawn(function()
        LoadConfigFromSlot()
        task.wait(0.4)
        if LoadBtn and LoadBtn.Parent then LoadBtn.Text = "ЗАГРУЗИТЬ" end
    end)
end)

CreateSectionLabel(configPage, "УТИЛИТЫ")

CreateActionButton(configPage, "СБРОС НАСТРОЕК", Color3.fromRGB(60, 30, 34), function()
    pcall(function()
        _G.BeyondConfig.Movement.WalkSpeed = 16
        _G.BeyondConfig.Movement.JumpPower = 50
        _G.BeyondConfig.Movement.FlySpeed = 60
        _G.BeyondConfig.InfiniteJump = false
        _G.BeyondConfig.Noclip = false
        _G.BeyondConfig.FlyEnabled = false
        _G.BeyondConfig.Visuals.HighlightESP = false
        _G.BeyondConfig.Visuals.RainbowGlow = false
    end)
    PushNotification("Config", "Настройки сброшены", "warn")
end)

-- ====================================================================
-- [16] TAB DEBUG
-- ====================================================================
local debugPage = TabPages["Debug"]

CreateSectionLabel(debugPage, "ТЕЛЕМЕТРИЯ")

local StatsCardFrame = CreateCardFrame(debugPage, 130)

-- ✅ ИСПРАВЛЕНО: parent = StatsCardFrame передаётся корректно
local FpsDisplay  = CreateStatDisplayLabel(StatsCardFrame, "FPS", 12)
local PingDisplay = CreateStatDisplayLabel(StatsCardFrame, "Ping", 42)
local MemDisplay  = CreateStatDisplayLabel(StatsCardFrame, "Memory", 72)
local ResDisplay  = CreateStatDisplayLabel(StatsCardFrame, "Разрешение", 102)

task.spawn(function()
    while ScriptActive and _G.BeyondConfig and task.wait(0.5) do
        pcall(function()
            if NetworkStats then
                TelemetryData.CurrentPing = math.round(NetworkStats.ServerPing)
            end
            TelemetryData.CurrentMemory = math.round(StatsService:GetTotalMemoryUsageMb())
            local fc = TelemetryData.CurrentFps >= 45 and "#00FF8C" or (TelemetryData.CurrentFps >= 25 and "#FFBB00" or "#FF2B5A")
            local pc = TelemetryData.CurrentPing <= 90 and "#00FF8C" or (TelemetryData.CurrentPing <= 200 and "#FFBB00" or "#FF2B5A")
            FpsDisplay.Text  = "FPS: <font color='" .. fc .. "'>" .. tostring(TelemetryData.CurrentFps) .. "</font>"
            PingDisplay.Text = "Ping: <font color='" .. pc .. "'>" .. tostring(TelemetryData.CurrentPing) .. " ms</font>"
            MemDisplay.Text  = "Memory: <font color='#00BFFF'>" .. tostring(TelemetryData.CurrentMemory) .. " MB</font>"
            local vp = Camera.ViewportSize
            ResDisplay.Text  = "Разрешение: <font color='#C0C0D0'>" .. vp.X .. "x" .. vp.Y
                .. " (x" .. string.format("%.2f", _G.BeyondConfig.UIScale) .. ")</font>"
        end)
    end
end)

CreateSectionLabel(debugPage, "ОПТИМИЗАЦИЯ")

CreateMobileToggle(debugPage, "FPS Boost (оптимизация рендера)",
    _G.BeyondConfig.PerformanceBoost.OptimizerActive,
    function(state)
        _G.BeyondConfig.PerformanceBoost.OptimizerActive = state
        ToggleEnvironmentOptimization(state)
        PushNotification("Graphics", state and "FPS Boost ON" or "FPS Boost OFF",
            state and "success" or "warn")
    end)

CreateSectionLabel(debugPage, "КОНСОЛЬ")

local ConsoleBoxFrame = Instance.new("ScrollingFrame")
ConsoleBoxFrame.Size = UDim2.new(1, 0, 0, 170)
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
ConsolePadding.PaddingLeft = UDim.new(0, 10)
ConsolePadding.PaddingRight = UDim.new(0, 10)
ConsolePadding.PaddingTop = UDim.new(0, 6)
ConsolePadding.PaddingBottom = UDim.new(0, 6)
ConsolePadding.Parent = ConsoleBoxFrame

function PrintToBeyondConsole(logText, logType)
    if not ScriptActive or not _G.BeyondConfig then return end
    _G.BeyondConfig.Logger.LogCount = _G.BeyondConfig.Logger.LogCount + 1
    local tc = Color3.fromRGB(240, 240, 245)
    if logType == "warn" then tc = Color3.fromRGB(255, 185, 0)
    elseif logType == "error" then tc = Color3.fromRGB(255, 43, 90)
    elseif logType == "success" then tc = Color3.fromRGB(0, 255, 140) end
    local time = os.date("%H:%M:%S")
    local LL = Instance.new("TextLabel")
    LL.Size = UDim2.new(1, 0, 0, 17)
    LL.BackgroundTransparency = 1
    LL.Text = string.format("[%s] %s", time, logText)
    LL.TextColor3 = tc
    LL.Font = _G.BeyondConfig.Styles.FontsList.Monospace
    LL.TextSize = 11
    LL.TextXAlignment = Enum.TextXAlignment.Left
    LL.LayoutOrder = _G.BeyondConfig.Logger.LogCount
    LL.Parent = ConsoleBoxFrame

    local labels = {}
    for _, it in ipairs(ConsoleBoxFrame:GetChildren()) do
        if it:IsA("TextLabel") then table.insert(labels, it) end
    end
    if #labels > _G.BeyondConfig.Logger.MaxLinesStored then labels[1]:Destroy() end

    ConsoleBoxFrame.CanvasSize = UDim2.new(0, 0, 0, ConsoleListLayout.AbsoluteContentSize.Y + 14)
    ConsoleBoxFrame.CanvasPosition = Vector2.new(0, ConsoleListLayout.AbsoluteContentSize.Y)
end

CreateActionButton(debugPage, "ОЧИСТИТЬ КОНСОЛЬ", Color3.fromRGB(28, 28, 38), function()
    for _, it in ipairs(ConsoleBoxFrame:GetChildren()) do
        if it:IsA("TextLabel") then it:Destroy() end
    end
    ConsoleBoxFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    PrintToBeyondConsole("Консоль очищена.", "warn")
end)

CreateSectionLabel(debugPage, "АУДИО")

CreateMobileToggle(debugPage, "Беззвучный режим", _G.BeyondConfig.Audio.MuteAll, function(state)
    _G.BeyondConfig.Audio.MuteAll = state
end)

CreateMobileSlider(debugPage, "Громкость UI (%)", 0, 100,
    math.round(_G.BeyondConfig.Audio.MasterVolume * 100),
    function(v) _G.BeyondConfig.Audio.MasterVolume = v / 100 end)

task.spawn(function()
    while ScriptActive and task.wait(0.5) do
        pcall(function()
            for _, desc in ipairs(Container:GetDescendants()) do
                if desc:IsA("TextButton") and not desc:GetAttribute("AudioHooked") then
                    desc:SetAttribute("AudioHooked", true)
                    local isS = desc.Parent and desc.Parent.Name == "Track"
                    HookSoundToUIElement(desc, isS)
                end
            end
        end)
    end
end)

-- ====================================================================
-- [17] BOOT
-- ====================================================================
task.spawn(function()
    task.wait(0.8)
    PrintToBeyondConsole("BeyondClient v6.3 (Mini) скомпилирован!", "success")
    PrintToBeyondConsole("Адаптация: HONOR Play5 / 2400x1080 / DPI 440", "info")
    PrintToBeyondConsole("UIScale: x" .. string.format("%.2f", _G.BeyondConfig.UIScale), "info")
    PrintToBeyondConsole("Drag: Header + BottomLeft + BottomRight", "info")
    PushNotification("Beyond", "v6.3 Mini Mode запущен", "success")
end)

MainFrame.Size = UDim2.new(0, 520, 0, 0)
MainFrame.ClipsDescendants = true
MainFrame.Visible = true

local bootTween = TweenService:Create(
    MainFrame,
    TweenInfo.new(0.7, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    {Size = UDim2.new(0, 520, 0, 440)}
)
bootTween:Play()
bootTween.Completed:Connect(function()
    if MainFrame then MainFrame.ClipsDescendants = false end
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if not ScriptActive or not _G.BeyondConfig then return end
    if input.KeyCode == _G.BeyondConfig.Keybinds.PanicKey then
        if _G.BeyondClient_SelfDestruct then _G.BeyondClient_SelfDestruct() end
    end
end)

Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    if not ScriptActive or not _G.BeyondConfig then return end
    local ns = CalculateAdaptiveScale()
    _G.BeyondConfig.UIScale = ns
    if MainUIScale then MainUIScale.Scale = ns end
    if MobileButtonScale then MobileButtonScale.Scale = ns end
end)

print("[BeyondClient v6.3 Mini]: Сборка успешно развёрнута.")
