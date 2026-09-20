--[[
    BeyondClient v6.5.2 - Zero Two Edition [Enhanced UI + TabIndicator Fix]
    Target: HONOR Play5 (2400x1080 / DPI 440 / Dimensity 800U)
    Developer: UserBeyond-dev

    v6.5.2:
      [FIX] MouseBehavior -> MouseMovement
      [FIX] TabIndicator: UIScale-ratio positioning (был промах ~1.46x)
      [FIX] TabIndicator: child of MainFrame вместо TabBar
            (UIListLayout перезаписывал Position -> дёргание)
      [+] Recompute indicator on ViewportSize change
      [+] Отложенный первый SwitchTab (await layout pass)
      [SAFE] CreateStatDisplayLabel: assert(parent)
]]

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
    return math.clamp(math.min(vp.X / 1600, vp.Y / 720), 0.75, 1.5)
end

_G.BeyondConfig = {
    Version    = "6.5.2-ZeroTwo-Enhanced",
    Developer  = "UserBeyond-dev",
    DeviceTarget = "HONOR Play5 / 2400x1080 / DPI 440",

    SpeedValue = 16, JumpPower = 50,
    InfiniteJump = false, Noclip = false,
    FlyEnabled = false, FlySpeed = 60,
    AntiAFK = true, AntiStun = false,

    ThemeColor  = Color3.fromRGB(255, 43, 90),
    BgColor     = Color3.fromRGB(13, 13, 18),
    CardColor   = Color3.fromRGB(22, 22, 30),
    HeaderColor = Color3.fromRGB(26, 24, 34),

    IsMenuOpened = true, GlowPhase = 0, ActiveTab = "Visual",
    UIScale = 1, CrosshairRemoved = false,

    Visuals = {
        HighlightESP = false, EspOutlineTransparency = 0,
        EspFillTransparency = 0.5, MaxDistance = 300,
        FpsAutoDisable = true, FpsThreshold = 20,
        RainbowGlow = false, GlowSpeed = 50, ShowWatermark = true
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

    Notifications = { Enabled = true, Duration = 3.5 },

    Styles = {
        CurrentThemePreset = "Розовый Zero Two",
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
local BEYOND_CONFIG_BASE = "BeyondClient_V65_slot"

-- ====================================================================
-- [4] UX MODULE
-- ====================================================================
local UX = {}

function UX.ApplyCorner(obj, r)
    local c = Instance.new("UICorner", obj)
    c.CornerRadius = UDim.new(0, r or 8)
    return c
end

function UX.ApplyStroke(obj, color, thick, trans)
    local s = Instance.new("UIStroke", obj)
    s.Color = color or Color3.fromRGB(60, 60, 75)
    s.Thickness = thick or 1
    s.Transparency = trans or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    return s
end

function UX.SetBaseColor(btn, color)
    btn:SetAttribute("UX_BaseColor", color)
    btn.BackgroundColor3 = color
end

function UX.AttachRipple(btn, rippleColor)
    btn.ClipsDescendants = true
    rippleColor = rippleColor or Color3.fromRGB(255, 255, 255)
    local cooldown = 0

    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
           or input.UserInputType == Enum.UserInputType.Touch then
            if tick() - cooldown < 0.08 then return end
            cooldown = tick()
            local rx = input.Position.X - btn.AbsolutePosition.X
            local ry = input.Position.Y - btn.AbsolutePosition.Y
            local rip = Instance.new("Frame")
            rip.BackgroundColor3 = rippleColor
            rip.BackgroundTransparency = 0.65
            rip.BorderSizePixel = 0
            rip.AnchorPoint = Vector2.new(0.5, 0.5)
            rip.Position = UDim2.new(0, rx, 0, ry)
            rip.Size = UDim2.new(0, 0, 0, 0)
            rip.ZIndex = (btn.ZIndex or 1) + 1
            rip.Parent = btn
            UX.ApplyCorner(rip, 999)
            local maxSize = math.max(btn.AbsoluteSize.X, btn.AbsoluteSize.Y) * 2
            TweenService:Create(rip, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, maxSize, 0, maxSize),
                BackgroundTransparency = 1
            }):Play()
            task.delay(0.55, function() if rip and rip.Parent then rip:Destroy() end end)
        end
    end)
end

function UX.AttachHoverPress(btn, hoverMul, pressMul)
    hoverMul = hoverMul or 1.15
    pressMul = pressMul or 0.9

    local function multiplyColor(col, mul)
        return Color3.new(
            math.clamp(col.R * mul, 0, 1),
            math.clamp(col.G * mul, 0, 1),
            math.clamp(col.B * mul, 0, 1)
        )
    end

    local function getBase()
        return btn:GetAttribute("UX_BaseColor") or btn.BackgroundColor3
    end

    btn.MouseEnter:Connect(function()
        local base = getBase()
        TweenService:Create(btn, TweenInfo.new(0.15), {
            BackgroundColor3 = multiplyColor(base, hoverMul)
        }):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {
            BackgroundColor3 = getBase()
        }):Play()
    end)
    btn.MouseButton1Down:Connect(function()
        local base = getBase()
        TweenService:Create(btn, TweenInfo.new(0.08), {
            BackgroundColor3 = multiplyColor(base, pressMul)
        }):Play()
    end)
    btn.MouseButton1Up:Connect(function()
        local base = getBase()
        TweenService:Create(btn, TweenInfo.new(0.15), {
            BackgroundColor3 = multiplyColor(base, hoverMul)
        }):Play()
    end)
end

function UX.AttachPressScale(btn, scaleDown)
    scaleDown = scaleDown or 0.95
    local sc = Instance.new("UIScale")
    sc.Scale = 1
    sc.Parent = btn
    btn.MouseButton1Down:Connect(function()
        TweenService:Create(sc, TweenInfo.new(0.08), {Scale = scaleDown}):Play()
    end)
    btn.MouseButton1Up:Connect(function()
        TweenService:Create(sc, TweenInfo.new(0.15, Enum.EasingStyle.Back), {Scale = 1}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(sc, TweenInfo.new(0.15), {Scale = 1}):Play()
    end)
end

function UX.AttachFull(btn, opts)
    opts = opts or {}
    if opts.baseColor then UX.SetBaseColor(btn, opts.baseColor) end
    UX.AttachRipple(btn, opts.rippleColor)
    UX.AttachHoverPress(btn, opts.hoverMul, opts.pressMul)
    if opts.pressScale ~= false then UX.AttachPressScale(btn, opts.scaleDown) end
end

-- ====================================================================
-- [5] UI SCAFFOLDING
-- ====================================================================
local BeyondScreenGui = Instance.new("ScreenGui")
BeyondScreenGui.Name = "Beyond_" .. HttpService:GenerateGUID(false):sub(1, 8)
BeyondScreenGui.ResetOnSpawn = false
BeyondScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
local okParent = pcall(function() BeyondScreenGui.Parent = CoreGui end)
if not okParent then BeyondScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainPanel"
MainFrame.Size = UDim2.new(0, 520, 0, 440)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.BackgroundColor3 = _G.BeyondConfig.BgColor
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = BeyondScreenGui
UX.ApplyCorner(MainFrame, 14)

local MainUIScale = Instance.new("UIScale")
MainUIScale.Scale = CalculateAdaptiveScale()
MainUIScale.Parent = MainFrame
_G.BeyondConfig.UIScale = MainUIScale.Scale

local Stroke = UX.ApplyStroke(MainFrame, _G.BeyondConfig.ThemeColor, 2)

-- HEADER
local Header = Instance.new("Frame")
Header.Name = "HeaderZone"
Header.Size = UDim2.new(1, 0, 0, 52)
Header.BackgroundColor3 = _G.BeyondConfig.HeaderColor
Header.BorderSizePixel = 0
Header.Parent = MainFrame
UX.ApplyCorner(Header, 14)

local HeaderGrad = Instance.new("UIGradient")
HeaderGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(38, 34, 48)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 18, 28))
})
HeaderGrad.Rotation = 90
HeaderGrad.Parent = Header

local HeaderLine = Instance.new("Frame")
HeaderLine.Size = UDim2.new(1, 0, 0, 2)
HeaderLine.Position = UDim2.new(0, 0, 1, -2)
HeaderLine.BackgroundColor3 = _G.BeyondConfig.ThemeColor
HeaderLine.BorderSizePixel = 0
HeaderLine.Parent = Header

local TopDragHint = Instance.new("Frame")
TopDragHint.Size = UDim2.new(0, 60, 0, 4)
TopDragHint.Position = UDim2.new(0.5, -30, 0, 5)
TopDragHint.BackgroundColor3 = Color3.fromRGB(120, 120, 140)
TopDragHint.BorderSizePixel = 0
TopDragHint.Parent = Header
UX.ApplyCorner(TopDragHint, 999)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -220, 1, 0)
Title.Position = UDim2.new(0, 18, 0, 0)
Title.Text = "BEYOND <font color='#FF2B5A'>CLIENT</font> <font color='#A0A0A5'>v6.5.2</font>"
Title.RichText = true
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 15
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
Title.Parent = Header

local WatermarkHolder = Instance.new("Frame")
WatermarkHolder.Name = "WatermarkHolder"
WatermarkHolder.Size = UDim2.new(0, 36, 0, 36)
WatermarkHolder.Position = UDim2.new(1, -140, 0.5, -18)
WatermarkHolder.BackgroundTransparency = 1
WatermarkHolder.ZIndex = 5
WatermarkHolder.Parent = Header

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
UX.ApplyCorner(MinimizeBtn, 8)
UX.AttachFull(MinimizeBtn, {baseColor = Color3.fromRGB(38, 38, 50), hoverMul = 1.3})

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
UX.ApplyCorner(CloseBtn, 8)
UX.AttachFull(CloseBtn, {baseColor = Color3.fromRGB(255, 43, 90), hoverMul = 1.2})

-- TABBAR
local TabBar = Instance.new("Frame")
TabBar.Name = "TabBar"
TabBar.Size = UDim2.new(1, -20, 0, 40)
TabBar.Position = UDim2.new(0, 10, 0, 60)
TabBar.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
TabBar.BorderSizePixel = 0
TabBar.ClipsDescendants = false
TabBar.Parent = MainFrame
UX.ApplyCorner(TabBar, 10)

local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.Padding = UDim.new(0, 4)
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabLayout.Parent = TabBar

local TabPadding = Instance.new("UIPadding")
TabPadding.PaddingLeft = UDim.new(0, 4)
TabPadding.PaddingTop = UDim.new(0, 4)
TabPadding.Parent = TabBar

-- ★ TabIndicator: child of MainFrame (НЕ TabBar! у TabBar UIListLayout)
local TabIndicator = Instance.new("Frame")
TabIndicator.Name = "TabIndicator"
TabIndicator.Size = UDim2.new(0, 70, 0, 3)
TabIndicator.AnchorPoint = Vector2.new(0.5, 0.5)
TabIndicator.Position = UDim2.new(0, 0, 0, 0)
TabIndicator.BackgroundColor3 = _G.BeyondConfig.ThemeColor
TabIndicator.BorderSizePixel = 0
TabIndicator.ZIndex = 20
TabIndicator.Parent = MainFrame
UX.ApplyCorner(TabIndicator, 999)

-- CONTAINER
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

-- FOOTER
local Footer = Instance.new("Frame")
Footer.Name = "Footer"
Footer.Size = UDim2.new(1, 0, 0, 38)
Footer.Position = UDim2.new(0, 0, 1, -38)
Footer.BackgroundColor3 = Color3.fromRGB(22, 20, 28)
Footer.BorderSizePixel = 0
Footer.Parent = MainFrame
UX.ApplyCorner(Footer, 14)

local FooterText = Instance.new("TextLabel")
FooterText.Name = "FooterText"
FooterText.Size = UDim2.new(1, -160, 1, 0)
FooterText.Position = UDim2.new(0, 80, 0, 0)
FooterText.BackgroundTransparency = 1
FooterText.Text = "Zero Two Edition // Adaptive v6.5.2"
FooterText.TextColor3 = Color3.fromRGB(150, 150, 165)
FooterText.Font = Enum.Font.Code
FooterText.TextSize = 11
FooterText.TextXAlignment = Enum.TextXAlignment.Center
FooterText.Parent = Footer

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
UX.ApplyCorner(BottomLeftDrag, 8)
local BottomLeftStroke = UX.ApplyStroke(BottomLeftDrag, _G.BeyondConfig.ThemeColor, 1, 0.5)

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
UX.ApplyCorner(BottomRightDrag, 8)
local BottomRightStroke = UX.ApplyStroke(BottomRightDrag, _G.BeyondConfig.ThemeColor, 1, 0.5)

local Tabs = {}
local TabPages = {}
local ActiveTabName = "Visual"

-- ====================================================================
-- [6] ПЛАВАЮЩАЯ КНОПКА
-- ====================================================================
local MobileToggleButton = Instance.new("ImageButton")
MobileToggleButton.Name = "BeyondMobileCall"
MobileToggleButton.Size = UDim2.new(0, 56, 0, 56)
MobileToggleButton.AnchorPoint = Vector2.new(0.5, 0.5)
MobileToggleButton.Position = UDim2.new(0, 50, 0.25, 0)
MobileToggleButton.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
MobileToggleButton.BorderSizePixel = 0
MobileToggleButton.Image = "rbxassetid://16024021200"
MobileToggleButton.ImageColor3 = _G.BeyondConfig.ThemeColor
MobileToggleButton.ZIndex = 15
MobileToggleButton.Visible = false
MobileToggleButton.Parent = BeyondScreenGui
UX.ApplyCorner(MobileToggleButton, 999)
local ButtonStroke = UX.ApplyStroke(MobileToggleButton, _G.BeyondConfig.ThemeColor, 3)

local MobileButtonScale = Instance.new("UIScale")
MobileButtonScale.Scale = CalculateAdaptiveScale()
MobileButtonScale.Parent = MobileToggleButton

local FloatScale = Instance.new("UIScale")
FloatScale.Scale = 1
FloatScale.Parent = MobileToggleButton

MobileToggleButton.MouseEnter:Connect(function()
    TweenService:Create(FloatScale, TweenInfo.new(0.2), {Scale = 1.1}):Play()
end)
MobileToggleButton.MouseLeave:Connect(function()
    TweenService:Create(FloatScale, TweenInfo.new(0.2), {Scale = 1}):Play()
end)

function EnableFloatingDrag(btn)
    local dragging, dragStart, startPos = false, nil, nil
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
           or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = btn.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    local vp = Camera.ViewportSize
                    local absX = btn.AbsolutePosition.X + btn.AbsoluteSize.X / 2
                    local halfW = btn.AbsoluteSize.X / 2
                    local leftX  = halfW + 12
                    local rightX = vp.X - halfW - 12
                    local targetX
                    if (absX - leftX) < (rightX - absX) then targetX = leftX else targetX = rightX end
                    TweenService:Create(btn, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                        Position = UDim2.new(0, targetX, btn.Position.Y.Scale, btn.Position.Y.Offset)
                    }):Play()
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if not dragging or not ScriptActive then return end
        if input.UserInputType ~= Enum.UserInputType.Touch
           and input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
        local delta = input.Position - dragStart
        local newX = startPos.X.Offset + delta.X
        local newY = startPos.Y.Offset + delta.Y
        btn.Position = UDim2.new(startPos.X.Scale, newX, startPos.Y.Scale, newY)
    end)
end

-- ====================================================================
-- [7] NOTIFICATIONS
-- ====================================================================
local NotifyFolder = Instance.new("ScreenGui")
NotifyFolder.Name = "Beyond_Notifications"
NotifyFolder.ResetOnSpawn = false
NotifyFolder.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
local okN = pcall(function() NotifyFolder.Parent = CoreGui end)
if not okN then NotifyFolder.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local NotifyStack = {}

local function RemoveNotification(nf)
    for i, n in ipairs(NotifyStack) do
        if n == nf then table.remove(NotifyStack, i) break end
    end
    if nf and nf.Parent then
        TweenService:Create(nf, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
            {Size = UDim2.new(0, 300, 0, 0), BackgroundTransparency = 0.5}):Play()
        task.wait(0.32)
        pcall(function() nf:Destroy() end)
    end
end

function PushNotification(title, message, notifType)
    if not ScriptActive or not _G.BeyondConfig then return end
    if not _G.BeyondConfig.Notifications.Enabled then return end

    local accentColor = _G.BeyondConfig.ThemeColor
    local iconText = "●"
    if notifType == "warn" then accentColor = Color3.fromRGB(255, 185, 0); iconText = "⚠"
    elseif notifType == "error" then accentColor = Color3.fromRGB(255, 60, 80); iconText = "✕"
    elseif notifType == "success" then accentColor = Color3.fromRGB(0, 220, 130); iconText = "✔" end

    local duration = _G.BeyondConfig.Notifications.Duration or 3.5

    local nf = Instance.new("Frame")
    nf.Size = UDim2.new(0, 300, 0, 0)
    nf.Position = UDim2.new(1, -320, 0, 100)
    nf.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
    nf.BorderSizePixel = 0
    nf.ClipsDescendants = true
    nf.Parent = NotifyFolder
    UX.ApplyCorner(nf, 12)

    local ns = Instance.new("UIScale")
    ns.Scale = CalculateAdaptiveScale()
    ns.Parent = nf

    UX.ApplyStroke(nf, accentColor, 2)

    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(28, 26, 34)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(16, 16, 22))
    })
    grad.Rotation = 90
    grad.Parent = nf

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 4, 1, 0)
    bar.BackgroundColor3 = accentColor
    bar.BorderSizePixel = 0
    bar.ZIndex = 3
    bar.Parent = nf

    local iconCircle = Instance.new("Frame")
    iconCircle.Size = UDim2.new(0, 26, 0, 26)
    iconCircle.Position = UDim2.new(0, 14, 0, 10)
    iconCircle.BackgroundColor3 = accentColor
    iconCircle.BackgroundTransparency = 0.85
    iconCircle.BorderSizePixel = 0
    iconCircle.ZIndex = 3
    iconCircle.Parent = nf
    UX.ApplyCorner(iconCircle, 999)
    UX.ApplyStroke(iconCircle, accentColor, 1)

    local iconLbl = Instance.new("TextLabel")
    iconLbl.Size = UDim2.new(1, 0, 1, 0)
    iconLbl.BackgroundTransparency = 1
    iconLbl.Text = iconText
    iconLbl.TextColor3 = accentColor
    iconLbl.Font = Enum.Font.GothamBold
    iconLbl.TextSize = 14
    iconLbl.ZIndex = 4
    iconLbl.Parent = iconCircle

    local tLbl = Instance.new("TextLabel")
    tLbl.Size = UDim2.new(1, -80, 0, 20)
    tLbl.Position = UDim2.new(0, 48, 0, 12)
    tLbl.BackgroundTransparency = 1
    tLbl.Text = title or "Beyond"
    tLbl.TextColor3 = Color3.fromRGB(245, 245, 250)
    tLbl.Font = Enum.Font.GothamBold
    tLbl.TextSize = 13
    tLbl.TextXAlignment = Enum.TextXAlignment.Left
    tLbl.ZIndex = 3
    tLbl.Parent = nf

    local bLbl = Instance.new("TextLabel")
    bLbl.Size = UDim2.new(1, -20, 0, 30)
    bLbl.Position = UDim2.new(0, 14, 0, 38)
    bLbl.BackgroundTransparency = 1
    bLbl.Text = message or ""
    bLbl.TextColor3 = Color3.fromRGB(180, 180, 195)
    bLbl.Font = Enum.Font.Gotham
    bLbl.TextSize = 11
    bLbl.TextWrapped = true
    bLbl.TextXAlignment = Enum.TextXAlignment.Left
    bLbl.TextYAlignment = Enum.TextYAlignment.Top
    bLbl.ZIndex = 3
    bLbl.Parent = nf

    local closeNotif = Instance.new("TextButton")
    closeNotif.Size = UDim2.new(0, 22, 0, 22)
    closeNotif.Position = UDim2.new(1, -30, 0, 12)
    closeNotif.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    closeNotif.BackgroundTransparency = 0.4
    closeNotif.Text = "✕"
    closeNotif.TextColor3 = Color3.fromRGB(200, 200, 215)
    closeNotif.Font = Enum.Font.GothamBold
    closeNotif.TextSize = 12
    closeNotif.ZIndex = 5
    closeNotif.Parent = nf
    UX.ApplyCorner(closeNotif, 6)

    local progressBg = Instance.new("Frame")
    progressBg.Size = UDim2.new(1, 0, 0, 3)
    progressBg.Position = UDim2.new(0, 0, 1, -3)
    progressBg.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    progressBg.BorderSizePixel = 0
    progressBg.ZIndex = 3
    progressBg.Parent = nf

    local progressBar = Instance.new("Frame")
    progressBar.Size = UDim2.new(1, 0, 1, 0)
    progressBar.BackgroundColor3 = accentColor
    progressBar.BorderSizePixel = 0
    progressBar.ZIndex = 4
    progressBar.Parent = progressBg

    for _, n in ipairs(NotifyStack) do
        if n and n.Parent then
            local cp = n.Position
            TweenService:Create(n, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
                Position = UDim2.new(cp.X.Scale, cp.X.Offset, cp.Y.Scale, cp.Y.Offset + 76)
            }):Play()
        end
    end
    table.insert(NotifyStack, nf)

    TweenService:Create(nf, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Size = UDim2.new(0, 300, 0, 72)}):Play()

    TweenService:Create(progressBar, TweenInfo.new(duration, Enum.EasingStyle.Linear),
        {Size = UDim2.new(0, 0, 1, 0)}):Play()

    local closed = false
    closeNotif.MouseButton1Click:Connect(function()
        if closed then return end
        closed = true
        task.spawn(function() RemoveNotification(nf) end)
    end)

    task.spawn(function()
        task.wait(duration)
        if closed then return end
        closed = true
        RemoveNotification(nf)
    end)
end

-- ====================================================================
-- [8] LOADING SCREEN
-- ====================================================================
local LoadingScreen = Instance.new("ScreenGui")
LoadingScreen.Name = "Beyond_Loading"
LoadingScreen.ResetOnSpawn = false
LoadingScreen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
local okL = pcall(function() LoadingScreen.Parent = CoreGui end)
if not okL then LoadingScreen.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local lBg = Instance.new("Frame")
lBg.Size = UDim2.new(1, 0, 1, 0)
lBg.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
lBg.BorderSizePixel = 0
lBg.Parent = LoadingScreen

local lScale = Instance.new("UIScale")
lScale.Scale = CalculateAdaptiveScale()
lScale.Parent = lBg

local lTitle = Instance.new("TextLabel")
lTitle.Size = UDim2.new(1, 0, 0, 44)
lTitle.Position = UDim2.new(0, 0, 0.4, -44)
lTitle.BackgroundTransparency = 1
lTitle.Text = "BEYOND <font color='#FF2B5A'>CLIENT</font> v6.5.2"
lTitle.RichText = true
lTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
lTitle.Font = Enum.Font.GothamBlack
lTitle.TextSize = 28
lTitle.Parent = lBg

local lSub = Instance.new("TextLabel")
lSub.Size = UDim2.new(1, 0, 0, 22)
lSub.Position = UDim2.new(0, 0, 0.4, 6)
lSub.BackgroundTransparency = 1
lSub.Text = "Zero Two Edition · Enhanced UI"
lSub.TextColor3 = Color3.fromRGB(255, 100, 150)
lSub.Font = Enum.Font.Code
lSub.TextSize = 14
lSub.Parent = lBg

local lBarBg = Instance.new("Frame")
lBarBg.Size = UDim2.new(0, 340, 0, 7)
lBarBg.Position = UDim2.new(0.5, -170, 0.4, 42)
lBarBg.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
lBarBg.BorderSizePixel = 0
lBarBg.Parent = lBg
UX.ApplyCorner(lBarBg, 999)

local lBar = Instance.new("Frame")
lBar.Size = UDim2.new(0, 0, 1, 0)
lBar.BackgroundColor3 = _G.BeyondConfig.ThemeColor
lBar.BorderSizePixel = 0
lBar.Parent = lBarBg
UX.ApplyCorner(lBar, 999)

TweenService:Create(lBar, TweenInfo.new(1.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    {Size = UDim2.new(1, 0, 1, 0)}):Play()

task.spawn(function()
    task.wait(1.5)
    TweenService:Create(lBg, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
    TweenService:Create(lTitle, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
    TweenService:Create(lSub, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
    TweenService:Create(lBarBg, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
    TweenService:Create(lBar, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
    task.wait(0.5)
    pcall(function() LoadingScreen:Destroy() end)
end)

-- ====================================================================
-- [9] UI FACTORIES
-- ====================================================================
function CreateMobileToggle(parent, text, default, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 50)
    ToggleFrame.BackgroundColor3 = _G.BeyondConfig.CardColor
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.Parent = parent
    UX.ApplyCorner(ToggleFrame, 10)
    UX.ApplyStroke(ToggleFrame, _G.BeyondConfig.Styles.BorderStrokeColor, 1)

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

    local CB = Instance.new("TextButton")
    CB.Size = UDim2.new(0, 50, 0, 28)
    CB.Position = UDim2.new(1, -66, 0.5, -14)
    CB.BackgroundColor3 = default and _G.BeyondConfig.ThemeColor or Color3.fromRGB(45, 45, 60)
    CB.Text = ""
    CB.Parent = ToggleFrame
    UX.ApplyCorner(CB, 999)
    local cbStroke = UX.ApplyStroke(CB, default and _G.BeyondConfig.ThemeColor or Color3.fromRGB(45, 45, 60), 1, default and 0 or 1)

    local Ind = Instance.new("Frame")
    Ind.Size = UDim2.new(0, 22, 0, 22)
    Ind.Position = default and UDim2.new(1, -25, 0.5, -11) or UDim2.new(0, 3, 0.5, -11)
    Ind.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Ind.Parent = CB
    UX.ApplyCorner(Ind, 999)

    local st = default
    CB.MouseButton1Click:Connect(function()
        if not ScriptActive or not _G.BeyondConfig then return end
        st = not st
        local tc = st and _G.BeyondConfig.ThemeColor or Color3.fromRGB(45, 45, 60)
        local tp = st and UDim2.new(1, -25, 0.5, -11) or UDim2.new(0, 3, 0.5, -11)
        TweenService:Create(CB, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {BackgroundColor3 = tc}):Play()
        TweenService:Create(cbStroke, TweenInfo.new(0.25), {
            Color = tc, Transparency = st and 0 or 1
        }):Play()
        TweenService:Create(Ind, TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {Position = tp}):Play()
        callback(st)
    end)
    UX.AttachRipple(CB, Color3.fromRGB(255, 255, 255))
    return CB
end

function CreateMobileSlider(parent, text, min, max, default, callback)
    local SF = Instance.new("Frame")
    SF.Size = UDim2.new(1, 0, 0, 64)
    SF.BackgroundColor3 = _G.BeyondConfig.CardColor
    SF.BorderSizePixel = 0
    SF.Parent = parent
    UX.ApplyCorner(SF, 10)
    UX.ApplyStroke(SF, _G.BeyondConfig.Styles.BorderStrokeColor, 1)

    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(0.9, 0, 0, 28)
    Lbl.Position = UDim2.new(0, 16, 0, 4)
    Lbl.Text = text .. ": <font color='#FF2B5A'>" .. tostring(default) .. "</font>"
    Lbl.RichText = true
    Lbl.TextColor3 = Color3.fromRGB(220, 220, 230)
    Lbl.Font = Enum.Font.GothamSemibold
    Lbl.TextSize = 13
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.BackgroundTransparency = 1
    Lbl.Parent = SF

    local Track = Instance.new("Frame")
    Track.Size = UDim2.new(1, -32, 0, 8)
    Track.Position = UDim2.new(0, 16, 0, 42)
    Track.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    Track.BorderSizePixel = 0
    Track.Parent = SF
    UX.ApplyCorner(Track, 999)

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((default - min) / math.max(1, (max - min)), 0, 1, 0)
    Fill.BackgroundColor3 = _G.BeyondConfig.ThemeColor
    Fill.BorderSizePixel = 0
    Fill.Parent = Track
    UX.ApplyCorner(Fill, 999)

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 24, 0, 24)
    Knob.AnchorPoint = Vector2.new(0.5, 0.5)
    Knob.Position = UDim2.new(Fill.Size.X.Scale, 0, 0.5, 0)
    Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Knob.BorderSizePixel = 0
    Knob.Parent = Track
    UX.ApplyCorner(Knob, 999)
    UX.ApplyStroke(Knob, _G.BeyondConfig.ThemeColor, 2)

    local Bubble = Instance.new("Frame")
    Bubble.Size = UDim2.new(0, 42, 0, 22)
    Bubble.AnchorPoint = Vector2.new(0.5, 1)
    Bubble.Position = UDim2.new(Fill.Size.X.Scale, 0, 0, -8)
    Bubble.BackgroundColor3 = _G.BeyondConfig.ThemeColor
    Bubble.BorderSizePixel = 0
    Bubble.Visible = false
    Bubble.ZIndex = 30
    Bubble.Parent = Track
    UX.ApplyCorner(Bubble, 6)

    local BubbleLbl = Instance.new("TextLabel")
    BubbleLbl.Size = UDim2.new(1, 0, 1, 0)
    BubbleLbl.BackgroundTransparency = 1
    BubbleLbl.Text = tostring(default)
    BubbleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    BubbleLbl.Font = Enum.Font.GothamBold
    BubbleLbl.TextSize = 11
    BubbleLbl.Parent = Bubble

    local TB = Instance.new("TextButton")
    TB.Size = UDim2.new(1, 0, 1, 0)
    TB.BackgroundTransparency = 1
    TB.Text = ""
    TB.Parent = Track

    local sliding = false
    local function proc(input)
        local ts = Track.AbsoluteSize.X
        if ts == 0 then return end
        local x = math.clamp(input.Position.X - Track.AbsolutePosition.X, 0, ts)
        local r = x / ts
        local v = math.round(min + (r * (max - min)))
        Fill.Size = UDim2.new(r, 0, 1, 0)
        Knob.Position = UDim2.new(r, 0, 0.5, 0)
        Bubble.Position = UDim2.new(r, 0, 0, -8)
        BubbleLbl.Text = tostring(v)
        Lbl.Text = text .. ": <font color='#FF2B5A'>" .. tostring(v) .. "</font>"
        callback(v)
    end

    TB.InputBegan:Connect(function(input)
        if not ScriptActive then return end
        if input.UserInputType == Enum.UserInputType.Touch
           or input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliding = true; proc(input)
            Bubble.Visible = true
            TweenService:Create(Knob, TweenInfo.new(0.15), {Size = UDim2.new(0, 28, 0, 28)}):Play()
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if sliding and ScriptActive and
           (input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseMovement) then
            proc(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
           or input.UserInputType == Enum.UserInputType.MouseButton1 then
            if sliding then
                sliding = false
                Bubble.Visible = false
                TweenService:Create(Knob, TweenInfo.new(0.15), {Size = UDim2.new(0, 24, 0, 24)}):Play()
            end
        end
    end)
end

function CreateSectionLabel(parent, titleText)
    local Holder = Instance.new("Frame")
    Holder.Size = UDim2.new(1, 0, 0, 26)
    Holder.BackgroundTransparency = 1
    Holder.Parent = parent

    local L = Instance.new("TextLabel")
    L.Size = UDim2.new(1, 0, 1, 0)
    L.BackgroundTransparency = 1
    L.Text = "— " .. titleText .. " —"
    L.TextColor3 = Color3.fromRGB(255, 130, 170)
    L.Font = _G.BeyondConfig.Styles.FontsList.Bold
    L.TextSize = 12
    L.TextStrokeTransparency = 0.85
    L.TextStrokeColor3 = Color3.fromRGB(60, 20, 40)
    L.Parent = Holder
    return Holder
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
    UX.ApplyCorner(Btn, 8)
    UX.ApplyStroke(Btn, _G.BeyondConfig.Styles.BorderStrokeColor, 1)
    UX.AttachFull(Btn, {
        baseColor = bgColor or Color3.fromRGB(34, 34, 46),
        hoverMul = 1.25
    })

    local ot = textTitle
    local oc = bgColor or Color3.fromRGB(34, 34, 46)

    Btn.MouseButton1Click:Connect(function()
        if not ScriptActive then return end
        Btn.Text = "⏳..."
        Btn.TextColor3 = Color3.fromRGB(255, 200, 100)
        TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = _G.BeyondConfig.ThemeColor}):Play()
        task.spawn(function()
            pcall(callback)
            task.wait(0.4)
            if Btn and Btn.Parent then
                Btn.Text = ot
                Btn.TextColor3 = Color3.fromRGB(240, 240, 245)
                TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = oc}):Play()
                Btn:SetAttribute("UX_BaseColor", oc)
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
    UX.ApplyCorner(Card, 10)
    UX.ApplyStroke(Card, _G.BeyondConfig.Styles.BorderStrokeColor, 1)
    return Card
end

function CreateStatDisplayLabel(parent, nameTag, yPosition)
    assert(parent ~= nil, "[CreateStatDisplayLabel] parent is nil for '" .. tostring(nameTag) .. "'")
    assert(typeof(parent) == "Instance", "[CreateStatDisplayLabel] parent must be Instance")
    assert(parent:IsA("GuiObject"), "[CreateStatDisplayLabel] parent must be GuiObject")

    local DL = Instance.new("TextLabel")
    DL.Size = UDim2.new(1, -28, 0, 26)
    DL.Position = UDim2.new(0, 16, 0, yPosition)
    DL.BackgroundTransparency = 1
    DL.Text = nameTag .. ": <font color='#808090'>—</font>"
    DL.RichText = true
    DL.TextColor3 = Color3.fromRGB(215, 215, 225)
    DL.Font = _G.BeyondConfig.Styles.FontsList.Semibold
    DL.TextSize = 13
    DL.TextXAlignment = Enum.TextXAlignment.Left
    DL.Parent = parent
    return DL
end

-- ====================================================================
-- [10] UTILITIES
-- ====================================================================
local BeyondAudioChannel = SoundService:FindFirstChild("Beyond_Interface_Audio")
if not BeyondAudioChannel then
    BeyondAudioChannel = Instance.new("Folder")
    BeyondAudioChannel.Name = "Beyond_Interface_Audio"
    BeyondAudioChannel.Parent = SoundService
end

function PlayInterfaceSound(assetId, vm)
    if not ScriptActive or not _G.BeyondConfig or _G.BeyondConfig.Audio.MuteAll then return end
    task.spawn(function()
        local ok, s = pcall(function()
            local snd = Instance.new("Sound")
            snd.SoundId = assetId
            snd.Volume = _G.BeyondConfig.Audio.MasterVolume * (vm or 1)
            snd.PlayOnRemove = true
            snd.Parent = BeyondAudioChannel
            return snd
        end)
        if ok and s then s:Destroy() end
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

function FireLegalChatMessage(txt)
    if not ScriptActive then return end
    pcall(function()
        if TextChatService and TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
            local tc = TextChatService:FindFirstChild("TextChannels")
            local gc = tc and tc:FindFirstChild("RBXGeneral")
            if gc and gc:IsA("TextChannel") then gc:SendAsync(txt) return end
        end
        local lg = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
        local smr = lg and lg:FindFirstChild("SayMessageRequest")
        if smr and smr:IsA("RemoteEvent") then smr:FireServer(txt, "All") end
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
-- [11] ZERO TWO CHIBI
-- ====================================================================
local function NewShape(parent, w, h, px, py, color, z, transp, cornerScale)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(0, w, 0, h)
    f.Position = UDim2.new(0, px, 0, py)
    f.BackgroundColor3 = color
    f.BackgroundTransparency = transp or 0
    f.BorderSizePixel = 0
    f.ZIndex = z or 1
    f.Parent = parent
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(cornerScale or 1, 0)
    c.Parent = f
    return f
end

local function Rotate(frame, deg) frame.Rotation = deg; return frame end

local function AddStroke(frame, color, thick)
    local s = Instance.new("UIStroke")
    s.Color = color
    s.Thickness = thick or 2
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = frame
    return s
end

function DrawZeroTwoChibi(parent, scaleFactor)
    scaleFactor = scaleFactor or 1
    local W, H = 360 * scaleFactor, 440 * scaleFactor
    local S = scaleFactor

    local root = Instance.new("Frame")
    root.Name = "ZeroTwo_Chibi"
    root.Size = UDim2.new(0, W, 0, H)
    root.AnchorPoint = Vector2.new(0.5, 0.5)
    root.Position = UDim2.new(0.5, 0, 0.5, 0)
    root.BackgroundTransparency = 1
    root.ClipsDescendants = false
    root.Parent = parent

    local PINK_HAIR_DARK  = Color3.fromRGB(220, 90, 130)
    local PINK_HAIR       = Color3.fromRGB(255, 155, 185)
    local PINK_HAIR_LIGHT = Color3.fromRGB(255, 195, 215)
    local SKIN            = Color3.fromRGB(255, 225, 205)
    local SKIN_SHADOW     = Color3.fromRGB(245, 200, 180)
    local HORN_RED        = Color3.fromRGB(220, 40, 70)
    local HORN_DARK       = Color3.fromRGB(160, 20, 45)
    local EYE_DARK        = Color3.fromRGB(45, 70, 100)
    local EYE_TEAL        = Color3.fromRGB(80, 180, 190)
    local EYE_HILITE      = Color3.fromRGB(255, 255, 255)
    local BLUSH           = Color3.fromRGB(255, 140, 170)
    local MOUTH_DARK      = Color3.fromRGB(160, 40, 60)
    local MOUTH_INNER     = Color3.fromRGB(220, 80, 110)
    local OUTLINE         = Color3.fromRGB(60, 30, 50)

    local hairBack = NewShape(root, W - 20*S, H - 40*S, 10*S, 20*S, PINK_HAIR_DARK, 1, 0, 0.55)
    AddStroke(hairBack, OUTLINE, 3*S)
    NewShape(root, 60*S, 130*S, 230*S, 40*S, PINK_HAIR_LIGHT, 2, 0.35, 0.5)
    local face = NewShape(root, 200*S, 240*S, 80*S, 130*S, SKIN, 5, 0, 0.5)
    AddStroke(face, OUTLINE, 3*S)
    NewShape(root, 60*S, 140*S, 220*S, 180*S, SKIN_SHADOW, 6, 0.6, 0.5)

    local hornL1 = NewShape(root, 42*S, 70*S, 105*S, 20*S, HORN_RED, 4, 0, 0.5)
    Rotate(hornL1, -20); AddStroke(hornL1, HORN_DARK, 2*S)
    local hornL2 = NewShape(root, 15*S, 40*S, 112*S, 30*S, Color3.fromRGB(255, 180, 200), 5, 0.5, 0.5)
    Rotate(hornL2, -20)
    local hornR1 = NewShape(root, 42*S, 70*S, 213*S, 20*S, HORN_RED, 4, 0, 0.5)
    Rotate(hornR1, 20); AddStroke(hornR1, HORN_DARK, 2*S)
    local hornR2 = NewShape(root, 15*S, 40*S, 233*S, 30*S, Color3.fromRGB(255, 180, 200), 5, 0.5, 0.5)
    Rotate(hornR2, 20)

    local headband = NewShape(root, 180*S, 14*S, 90*S, 118*S, Color3.fromRGB(255, 255, 255), 7, 0, 0.5)
    AddStroke(headband, OUTLINE, 2*S)

    local fringeColors = {PINK_HAIR, PINK_HAIR_DARK, PINK_HAIR_LIGHT}
    local fringeX = {70, 115, 155, 195, 235, 270}
    local fringeH = {80, 100, 110, 100, 90, 75}
    for i = 1, 6 do
        local c = fringeColors[(i % 3) + 1]
        local fr = NewShape(root, 45*S, fringeH[i]*S, fringeX[i]*S, 105*S, c, 6, 0, 0.5)
        AddStroke(fr, OUTLINE, 2*S)
    end

    NewShape(root, 42*S, 55*S, 105*S, 205*S, Color3.fromRGB(255, 255, 255), 8, 0, 0.6)
    NewShape(root, 34*S, 48*S, 109*S, 208*S, EYE_TEAL, 9, 0, 0.6)
    NewShape(root, 16*S, 38*S, 118*S, 213*S, EYE_DARK, 10, 0, 0.5)
    NewShape(root, 12*S, 12*S, 112*S, 212*S, EYE_HILITE, 11, 0, 1)
    NewShape(root, 6*S, 6*S, 132*S, 240*S, EYE_HILITE, 11, 0.2, 1)
    local lashL = NewShape(root, 48*S, 10*S, 102*S, 196*S, OUTLINE, 12, 0, 0.5)
    Rotate(lashL, -8)

    NewShape(root, 42*S, 55*S, 213*S, 205*S, Color3.fromRGB(255, 255, 255), 8, 0, 0.6)
    NewShape(root, 34*S, 48*S, 217*S, 208*S, EYE_TEAL, 9, 0, 0.6)
    NewShape(root, 16*S, 38*S, 226*S, 213*S, EYE_DARK, 10, 0, 0.5)
    NewShape(root, 12*S, 12*S, 220*S, 212*S, EYE_HILITE, 11, 0, 1)
    NewShape(root, 6*S, 6*S, 240*S, 240*S, EYE_HILITE, 11, 0.2, 1)
    local lashR = NewShape(root, 48*S, 10*S, 210*S, 196*S, OUTLINE, 12, 0, 0.5)
    Rotate(lashR, 8)

    NewShape(root, 36*S, 18*S, 82*S, 258*S, BLUSH, 7, 0.35, 0.5)
    NewShape(root, 36*S, 18*S, 242*S, 258*S, BLUSH, 7, 0.35, 0.5)
    NewShape(root, 6*S, 6*S, 177*S, 250*S, SKIN_SHADOW, 8, 0.3, 1)
    NewShape(root, 46*S, 34*S, 157*S, 268*S, MOUTH_DARK, 8, 0, 0.5)
    NewShape(root, 34*S, 18*S, 163*S, 278*S, MOUTH_INNER, 9, 0, 0.5)
    NewShape(root, 48*S, 6*S, 156*S, 266*S, OUTLINE, 10, 0, 0.5)
    NewShape(root, 8*S, 14*S, 178*S, 264*S, Color3.fromRGB(255, 255, 255), 10, 0, 0.3)

    local sideL = NewShape(root, 55*S, 200*S, 22*S, 130*S, PINK_HAIR, 3, 0, 0.5)
    AddStroke(sideL, OUTLINE, 2*S)
    local sideR = NewShape(root, 55*S, 200*S, 283*S, 130*S, PINK_HAIR, 3, 0, 0.5)
    AddStroke(sideR, OUTLINE, 2*S)
    NewShape(root, 30*S, 60*S, 55*S, 155*S, PINK_HAIR_LIGHT, 8, 0, 0.5)
    NewShape(root, 30*S, 60*S, 275*S, 155*S, PINK_HAIR_LIGHT, 8, 0, 0.5)
    NewShape(root, 90*S, 12*S, 130*S, 130*S, Color3.fromRGB(255, 230, 240), 9, 0.35, 0.5)

    return root
end

-- ====================================================================
-- [12] ANTI-STUN
-- ====================================================================
local StunBlacklist = {
    "hypno", "hypnosis", "stun", "stunned", "freeze", "frozen",
    "charm", "mindcontrol", "confuse", "sleep", "trance", "stunanim",
    "zombie", "ice", "petrified", "locked"
}

local function IsStunAnimation(name)
    if not name then return false end
    local lower = string.lower(name)
    for _, key in ipairs(StunBlacklist) do
        if string.find(lower, key, 1, true) then return true end
    end
    return false
end

local function PurgeStunAnimations(char)
    if not char or not ScriptActive or not _G.BeyondConfig or not _G.BeyondConfig.AntiStun then return end
    pcall(function()
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        local animator = hum:FindFirstChildOfClass("Animator")
        if not animator then return end
        for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
            local animName = ""
            pcall(function() if track.Animation then animName = track.Animation.Name or "" end end)
            if IsStunAnimation(animName) or IsStunAnimation(track.Name) then
                pcall(function() track:Stop(0) end)
                pcall(function() track:Destroy() end)
            end
        end
    end)
end

local function UnstunState(hum)
    if not hum or not ScriptActive or not _G.BeyondConfig or not _G.BeyondConfig.AntiStun then return end
    pcall(function()
        local state = hum:GetState()
        if state == Enum.HumanoidStateType.PlatformStanding
           or state == Enum.HumanoidStateType.FallingDown
           or state == Enum.HumanoidStateType.Physics then
            hum:ChangeState(Enum.HumanoidStateType.Running)
        end
        hum.PlatformStand = false
        hum.AutoRotate = true
        if hum.WalkSpeed < 1 then hum.WalkSpeed = _G.BeyondConfig.Movement.WalkSpeed end
        if hum.UseJumpPower and hum.JumpPower < 1 then hum.JumpPower = _G.BeyondConfig.Movement.JumpPower end
    end)
end

task.spawn(function()
    while ScriptActive and task.wait(0.1) do
        if _G.BeyondConfig and _G.BeyondConfig.AntiStun then
            pcall(function()
                local char = LocalPlayer.Character
                if char then
                    PurgeStunAnimations(char)
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then UnstunState(hum) end
                end
            end)
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    if not _G.BeyondConfig or not _G.BeyondConfig.AntiStun then return end
    task.wait(0.3)
    pcall(function()
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        local animator = hum:FindFirstChildOfClass("Animator")
        if animator then
            animator.AnimationPlayed:Connect(function(track)
                if not _G.BeyondConfig.AntiStun then return end
                local n = ""
                pcall(function() if track.Animation then n = track.Animation.Name or "" end end)
                if IsStunAnimation(n) or IsStunAnimation(track.Name) then
                    pcall(function() track:Stop(0) end)
                end
            end)
        end
    end)
end)

-- ====================================================================
-- [13] HIGHLIGHT + CROSSHAIR
-- ====================================================================
function ApplyHighlight(player)
    if player == LocalPlayer then return end
    local function setup(char)
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
    if player.Character then setup(player.Character) end
    player.CharacterAdded:Connect(setup)
end
for _, p in ipairs(Players:GetPlayers()) do ApplyHighlight(p) end
Players.PlayerAdded:Connect(ApplyHighlight)

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
for _, l in ipairs(linesArray) do
    l.BorderSizePixel = 0
    l.BackgroundColor3 = _G.BeyondConfig.ThemeColor
    l.Parent = CrosshairContainer
end

function RecalibrateCrosshairGeometry()
    if not _G.BeyondConfig or not _G.BeyondConfig.Crosshair then return end
    if _G.BeyondConfig.CrosshairRemoved then CrosshairContainer.Visible = false; return end
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

function DestroyCrosshair()
    if not _G.BeyondConfig then return end
    _G.BeyondConfig.Crosshair.Enabled = false
    _G.BeyondConfig.CrosshairRemoved = true
    if CrosshairContainer and CrosshairContainer.Parent then
        pcall(function() CrosshairContainer:Destroy() end)
    end
    PushNotification("Crosshair", "Прицел удалён", "warn")
end

local TelemetryData = {
    CurrentFps = 60, CurrentPing = 0, CurrentMemory = 0,
    FrameCount = 0, TimeCounter = 0, LowFpsCounter = 0
}

-- ====================================================================
-- [14] RENDER LOOP
-- ====================================================================
RunService.RenderStepped:Connect(function(dt)
    if not ScriptActive or not _G.BeyondConfig then return end
    _G.BeyondConfig.GlowPhase = (_G.BeyondConfig.GlowPhase
        + (dt * (_G.BeyondConfig.Visuals.GlowSpeed / 10))) % 1
    local rainbow = Color3.fromHSV(_G.BeyondConfig.GlowPhase, 0.85, 1)
    if _G.BeyondConfig.Visuals.RainbowGlow then
        Stroke.Color = rainbow
        HeaderLine.BackgroundColor3 = rainbow
        Container.ScrollBarImageColor3 = rainbow
        TabIndicator.BackgroundColor3 = rainbow
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
        local mc = LocalPlayer.Character
        local mr = mc and mc:FindFirstChild("HumanoidRootPart")
        local mp = mr and mr.Position
        local md = _G.BeyondConfig.Visuals.MaxDistance
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                local c = p.Character
                local hl = c and c:FindFirstChild("Beyond_Highlight")
                if hl and hl:IsA("Highlight") then
                    local tr = c:FindFirstChild("HumanoidRootPart")
                    local tp = tr and tr.Position
                    local dist = (mp and tp) and (mp - tp).Magnitude or 0
                    if dist <= md then
                        hl.Enabled = true
                        hl.FillColor = rainbow
                        hl.FillTransparency = _G.BeyondConfig.Visuals.EspFillTransparency
                        hl.OutlineTransparency = _G.BeyondConfig.Visuals.EspOutlineTransparency
                    else
                        hl.Enabled = false
                    end
                end
            end
        end
    end

    if not _G.BeyondConfig.CrosshairRemoved
       and _G.BeyondConfig.Crosshair.Enabled
       and CrosshairContainer and CrosshairContainer.Parent then
        local sc = _G.BeyondConfig.Visuals.RainbowGlow and rainbow or _G.BeyondConfig.Crosshair.Color
        for _, l in ipairs(linesArray) do
            if l and l.Parent then l.BackgroundColor3 = sc end
        end
    end
end)

-- ====================================================================
-- [15] DRAG
-- ====================================================================
function EnableTouchDrag(zone, target)
    local toggle, dIn, dSt, sPos = false, nil, nil, nil
    zone.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
           or input.UserInputType == Enum.UserInputType.MouseButton1 then
            toggle = true
            dSt = input.Position
            sPos = target.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then toggle = false end
            end)
        end
    end)
    zone.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
           or input.UserInputType == Enum.UserInputType.MouseMovement then
            dIn = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dIn and toggle and ScriptActive then
            local d = input.Position - dSt
            local s = _G.BeyondConfig.UIScale or 1
            target.Position = UDim2.new(
                sPos.X.Scale, sPos.X.Offset + d.X / s,
                sPos.Y.Scale, sPos.Y.Offset + d.Y / s
            )
        end
    end)
end

EnableTouchDrag(Header, MainFrame)
EnableTouchDrag(BottomLeftDrag, MainFrame)
EnableTouchDrag(BottomRightDrag, MainFrame)
EnableFloatingDrag(MobileToggleButton)

-- ====================================================================
-- [16] SELF-DESTRUCT + MINIMIZE
-- ====================================================================
function _G.BeyondClient_SelfDestruct()
    ScriptActive = false
    _G.BeyondScriptActive = false
    pcall(function()
        local c = LocalPlayer.Character
        local h = c and c:FindFirstChildOfClass("Humanoid")
        if h then h.WalkSpeed = 16; h.JumpPower = 50 end
        for _, p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = true end
        end
    end)
    pcall(function() BeyondScreenGui:Destroy() end)
    pcall(function() NotifyFolder:Destroy() end)
    pcall(function() if LoadingScreen then LoadingScreen:Destroy() end end)
    _G.BeyondConfig = nil
    _G.BeyondClient_SelfDestruct = nil
    print("[BeyondClient v6.5.2]: Следы стёрты.")
end

CloseBtn.MouseButton1Click:Connect(function()
    if _G.BeyondClient_SelfDestruct then _G.BeyondClient_SelfDestruct() end
end)

MinimizeBtn.MouseButton1Click:Connect(function()
    if not ScriptActive then return end
    _G.BeyondConfig.IsMenuOpened = false
    TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
        {Size = UDim2.new(0, 520, 0, 0), BackgroundTransparency = 0.2}):Play()
    task.wait(0.28)
    MainFrame.Visible = false
    MainFrame.BackgroundTransparency = 0
    MobileToggleButton.Visible = true
    MobileToggleButton.Size = UDim2.new(0, 0, 0, 0)
    TweenService:Create(MobileToggleButton, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Size = UDim2.new(0, 56, 0, 56)}):Play()
end)

local mobileBtnClickGuard = false
MobileToggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
       or input.UserInputType == Enum.UserInputType.MouseButton1 then
        mobileBtnClickGuard = tick()
    end
end)
MobileToggleButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
       or input.UserInputType == Enum.UserInputType.MouseButton1 then
        if mobileBtnClickGuard and (tick() - mobileBtnClickGuard) < 0.35 then
            if not ScriptActive then return end
            _G.BeyondConfig.IsMenuOpened = true
            TweenService:Create(MobileToggleButton, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
                {Size = UDim2.new(0, 0, 0, 0)}):Play()
            task.wait(0.18)
            MobileToggleButton.Visible = false
            MainFrame.Visible = true
            MainFrame.Size = UDim2.new(0, 520, 0, 0)
            TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
                {Size = UDim2.new(0, 520, 0, 440)}):Play()
        end
        mobileBtnClickGuard = false
    end
end)

-- ====================================================================
-- [17] TAB SYSTEM
-- ====================================================================
function CreateTabButton(name, order)
    local TB = Instance.new("TextButton")
    TB.Name = "Tab_" .. name
    TB.Size = UDim2.new(0, 78, 0, 30)
    TB.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    TB.Text = name
    TB.TextColor3 = Color3.fromRGB(200, 200, 215)
    TB.Font = Enum.Font.GothamSemibold
    TB.TextSize = 11
    TB.LayoutOrder = order
    TB.Parent = TabBar
    UX.ApplyCorner(TB, 7)
    UX.AttachRipple(TB, Color3.fromRGB(255, 255, 255))
    return TB
end

function CreateTabPage(name)
    local P = Instance.new("Frame")
    P.Name = "Page_" .. name
    P.Size = UDim2.new(1, 0, 1, 0)
    P.BackgroundTransparency = 1
    P.Visible = (name == ActiveTabName)
    P.Parent = Container

    local PL = Instance.new("UIListLayout")
    PL.SortOrder = Enum.SortOrder.LayoutOrder
    PL.Padding = UDim.new(0, 10)
    PL.Parent = P

    PL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        if ScriptActive and Container and P.Visible then
            Container.CanvasSize = UDim2.new(0, 0, 0, PL.AbsoluteContentSize.Y + 20)
        end
    end)
    return P, PL
end

for _, n in ipairs({"Visual", "Move", "Auto", "Art", "Config", "Debug"}) do
    local b = CreateTabButton(n, #Tabs + 1)
    local pg, ly = CreateTabPage(n)
    Tabs[n] = {Button = b, Page = pg, Layout = ly}
    TabPages[n] = pg
end

-- ★ Индикатор: пересчёт через относительные доли MainFrame
--   (screen-пиксели / размер MainFrame = ratio 0..1, независимо от UIScale)
local function UpdateTabIndicator(name)
    if not Tabs[name] then return end
    local btn = Tabs[name].Button
    local mAX = MainFrame.AbsolutePosition.X
    local mAY = MainFrame.AbsolutePosition.Y
    local mW  = MainFrame.AbsoluteSize.X
    local mH  = MainFrame.AbsoluteSize.Y
    if mW <= 0 or mH <= 0 then return end

    local bAX = btn.AbsolutePosition.X
    local bW  = btn.AbsoluteSize.X
    local barY = TabBar.AbsolutePosition.Y
    local barH = TabBar.AbsoluteSize.Y

    -- ratio центра кнопки относительно MainFrame (0..1)
    local relCenterX = (bAX + bW / 2 - mAX) / mW
    -- ratio ширины: (ширина кнопки - 12 экранных px) / ширина MainFrame
    local relWidth = math.max(0, (bW - 12)) / mW
    -- ratio Y нижней кромки TabBar относительно MainFrame
    local relBottomY = (barY + barH - mAY) / mH

    TweenService:Create(TabIndicator, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Position = UDim2.new(relCenterX, 0, relBottomY, 0),
        Size = UDim2.new(relWidth, 0, 0, 3)
    }):Play()
end

function SwitchTab(name)
    if not Tabs[name] then return end
    for tn, td in pairs(Tabs) do
        local isA = (tn == name)
        td.Page.Visible = isA
        TweenService:Create(td.Button, TweenInfo.new(0.22, Enum.EasingStyle.Quart),
            {BackgroundColor3 = isA and _G.BeyondConfig.ThemeColor or Color3.fromRGB(30, 30, 40)}):Play()
        td.Button.TextColor3 = isA and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 215)
    end
    ActiveTabName = name
    _G.BeyondConfig.ActiveTab = name

    UpdateTabIndicator(name)

    Container.CanvasSize = UDim2.new(0, 0, 0, Tabs[name].Layout.AbsoluteContentSize.Y + 20)
    Container.CanvasPosition = Vector2.new(0, 0)
end

for tn, td in pairs(Tabs) do
    td.Button.MouseButton1Click:Connect(function()
        if ScriptActive then SwitchTab(tn) end
    end)
end

-- Отложенный первый SwitchTab — ждём, пока Roblox посчитает AbsolutePosition
task.spawn(function()
    RunService.RenderStepped:Wait()
    RunService.RenderStepped:Wait()
    SwitchTab("Visual")
end)

-- ====================================================================
-- [18] TAB VISUAL
-- ====================================================================
local vP = TabPages["Visual"]

CreateSectionLabel(vP, "ПОДСВЕТКА (ESP)")
CreateMobileToggle(vP, "Подсветка игроков", _G.BeyondConfig.Visuals.HighlightESP, function(s)
    _G.BeyondConfig.Visuals.HighlightESP = s
    PushNotification("Visuals", s and "ESP ON" or "ESP OFF", s and "success" or "warn")
    if not s then
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character then
                local hl = p.Character:FindFirstChild("Beyond_Highlight")
                if hl then hl.Enabled = false end
            end
        end
    end
end)
CreateMobileSlider(vP, "Прозрачность силуэта (%)", 0, 100, 50, function(v) _G.BeyondConfig.Visuals.EspFillTransparency = v / 100 end)
CreateMobileSlider(vP, "Прозрачность обводки (%)", 0, 100, 0, function(v) _G.BeyondConfig.Visuals.EspOutlineTransparency = v / 100 end)
CreateMobileSlider(vP, "Дистанция ESP (studs)", 50, 500, _G.BeyondConfig.Visuals.MaxDistance, function(v) _G.BeyondConfig.Visuals.MaxDistance = v end)
CreateMobileToggle(vP, "Авто-выкл при FPS < 20", _G.BeyondConfig.Visuals.FpsAutoDisable, function(s) _G.BeyondConfig.Visuals.FpsAutoDisable = s end)
CreateMobileToggle(vP, "RGB переливание UI", _G.BeyondConfig.Visuals.RainbowGlow, function(s)
    _G.BeyondConfig.Visuals.RainbowGlow = s
    if not s then
        Stroke.Color = _G.BeyondConfig.ThemeColor
        HeaderLine.BackgroundColor3 = _G.BeyondConfig.ThemeColor
        Container.ScrollBarImageColor3 = _G.BeyondConfig.ThemeColor
        TabIndicator.BackgroundColor3 = _G.BeyondConfig.ThemeColor
    end
end)

CreateSectionLabel(vP, "ПРИЦЕЛ")
CreateMobileToggle(vP, "Отображать прицел", _G.BeyondConfig.Crosshair.Enabled, function(s)
    if _G.BeyondConfig.CrosshairRemoved then
        PushNotification("Crosshair", "Прицел удалён", "error"); return
    end
    _G.BeyondConfig.Crosshair.Enabled = s
    RecalibrateCrosshairGeometry()
end)
CreateMobileToggle(vP, "Центральная точка", _G.BeyondConfig.Crosshair.CenterDot, function(s)
    if _G.BeyondConfig.CrosshairRemoved then return end
    _G.BeyondConfig.Crosshair.CenterDot = s
    RecalibrateCrosshairGeometry()
end)
CreateMobileSlider(vP, "Длина линий", 6, 50, _G.BeyondConfig.Crosshair.Size, function(v)
    if _G.BeyondConfig.CrosshairRemoved then return end
    _G.BeyondConfig.Crosshair.Size = v; RecalibrateCrosshairGeometry()
end)
CreateMobileSlider(vP, "Толщина линий", 1, 10, _G.BeyondConfig.Crosshair.Thickness, function(v)
    if _G.BeyondConfig.CrosshairRemoved then return end
    _G.BeyondConfig.Crosshair.Thickness = v; RecalibrateCrosshairGeometry()
end)
CreateMobileSlider(vP, "Зазор (Gap)", 0, 30, _G.BeyondConfig.Crosshair.Gap, function(v)
    if _G.BeyondConfig.CrosshairRemoved then return end
    _G.BeyondConfig.Crosshair.Gap = v; RecalibrateCrosshairGeometry()
end)
CreateActionButton(vP, "🗑 УДАЛИТЬ ПРИЦЕЛ ИЗ МЕНЮ", Color3.fromRGB(60, 30, 34), DestroyCrosshair)

CreateSectionLabel(vP, "ТЕМЫ")
local SPF = CreateCardFrame(vP, 96)
local SLL = Instance.new("TextLabel")
SLL.Size = UDim2.new(1, -24, 0, 26)
SLL.Position = UDim2.new(0, 16, 0, 4)
SLL.Text = "Тема: <font color='#FF2B5A'>" .. _G.BeyondConfig.Styles.CurrentThemePreset .. "</font>"
SLL.RichText = true
SLL.TextColor3 = Color3.fromRGB(225, 225, 235)
SLL.Font = _G.BeyondConfig.Styles.FontsList.Semibold
SLL.TextSize = 13
SLL.TextXAlignment = Enum.TextXAlignment.Left
SLL.BackgroundTransparency = 1
SLL.Parent = SPF

function InitializeThemeButton(themeName, xOffset, primeColor)
    local TB = Instance.new("TextButton")
    TB.Size = UDim2.new(0.28, 0, 0, 40)
    TB.Position = UDim2.new(0, xOffset, 0, 42)
    TB.BackgroundColor3 = Color3.fromRGB(34, 34, 46)
    TB.Text = themeName
    TB.TextColor3 = Color3.fromRGB(245, 245, 250)
    TB.Font = _G.BeyondConfig.Styles.FontsList.Bold
    TB.TextSize = 11
    TB.Parent = SPF
    UX.ApplyCorner(TB, 7)
    UX.AttachFull(TB, {baseColor = Color3.fromRGB(34, 34, 46), hoverMul = 1.3})
    TB.MouseButton1Click:Connect(function()
        if not ScriptActive or not _G.BeyondConfig then return end
        if _G.BeyondConfig.Visuals.RainbowGlow then
            PushNotification("Theme", "Выключите RGB", "warn"); return
        end
        _G.BeyondConfig.Styles.CurrentThemePreset = themeName
        _G.BeyondConfig.ThemeColor = primeColor
        _G.BeyondConfig.Crosshair.Color = primeColor
        SLL.Text = "Тема: <font color='#FF2B5A'>" .. themeName .. "</font>"
        local ti = TweenInfo.new(0.3, Enum.EasingStyle.Cubic)
        TweenService:Create(Stroke, ti, {Color = primeColor}):Play()
        TweenService:Create(HeaderLine, ti, {BackgroundColor3 = primeColor}):Play()
        TweenService:Create(Container, ti, {ScrollBarImageColor3 = primeColor}):Play()
        TweenService:Create(MobileToggleButton, ti, {ImageColor3 = primeColor}):Play()
        TweenService:Create(ButtonStroke, ti, {Color = primeColor}):Play()
        TweenService:Create(BottomLeftStroke, ti, {Color = primeColor}):Play()
        TweenService:Create(BottomRightStroke, ti, {Color = primeColor}):Play()
        TweenService:Create(TabIndicator, ti, {BackgroundColor3 = primeColor}):Play()
        PushNotification("Theme", themeName, "success")
    end)
end
InitializeThemeButton("Zero Two", 16, Color3.fromRGB(255, 43, 90))
InitializeThemeButton("Кибер", 170, Color3.fromRGB(0, 255, 240))
InitializeThemeButton("Токсик", 324, Color3.fromRGB(170, 255, 0))

-- ====================================================================
-- [19] TAB MOVE
-- ====================================================================
local mP = TabPages["Move"]

CreateSectionLabel(mP, "СКОРОСТЬ И ПРЫЖОК")
CreateMobileSlider(mP, "WalkSpeed", 16, 250, _G.BeyondConfig.Movement.WalkSpeed, function(v)
    _G.BeyondConfig.Movement.WalkSpeed = v
    pcall(function()
        local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if h then h.WalkSpeed = v end
    end)
end)
CreateMobileSlider(mP, "JumpPower", 50, 500, _G.BeyondConfig.Movement.JumpPower, function(v)
    _G.BeyondConfig.Movement.JumpPower = v
    pcall(function()
        local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if h then h.UseJumpPower = true; h.JumpPower = v end
    end)
end)
CreateMobileToggle(mP, "Бесконечный прыжок", false, function(s)
    _G.BeyondConfig.InfiniteJump = s
    PushNotification("Move", s and "Inf Jump ON" or "OFF", s and "success" or "warn")
end)
CreateMobileToggle(mP, "Noclip", false, function(s)
    _G.BeyondConfig.Noclip = s
    PushNotification("Move", s and "Noclip ON" or "OFF", s and "success" or "warn")
end)

CreateSectionLabel(mP, "ПОЛЁТ (FLY)")
CreateMobileToggle(mP, "Включить Fly", false, function(s)
    _G.BeyondConfig.FlyEnabled = s
    PushNotification("Move", s and "Fly ON" or "OFF", s and "success" or "warn")
end)
CreateMobileSlider(mP, "FlySpeed", 20, 300, _G.BeyondConfig.Movement.FlySpeed, function(v) _G.BeyondConfig.FlySpeed = v end)

CreateSectionLabel(mP, "🛡 ANTI-STUN")
CreateMobileToggle(mP, "Включить Anti-Stun", _G.BeyondConfig.AntiStun, function(s)
    _G.BeyondConfig.AntiStun = s
    PushNotification("Anti-Stun", s and "Защита ВКЛ" or "Anti-Stun ВЫКЛ", s and "success" or "warn")
end)

CreateActionButton(mP, "🔄 ОЧИСТИТЬ АНИМАЦИИ СРАЗУ", Color3.fromRGB(40, 40, 60), function()
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        local animator = hum:FindFirstChildOfClass("Animator")
        if not animator then return end
        local count = 0
        for _, t in ipairs(animator:GetPlayingAnimationTracks()) do
            local n = ""
            pcall(function() if t.Animation then n = t.Animation.Name or "" end end)
            if IsStunAnimation(n) or IsStunAnimation(t.Name) then
                pcall(function() t:Stop(0) end); count = count + 1
            end
        end
        hum.PlatformStand = false
        hum.AutoRotate = true
        if hum.WalkSpeed < 1 then hum.WalkSpeed = _G.BeyondConfig.Movement.WalkSpeed end
        PushNotification("Anti-Stun", "Очищено анимаций: " .. count, "success")
    end)
end)

CreateSectionLabel(mP, "АВТОМАТИКА")
CreateMobileToggle(mP, "Anti-AFK", true, function(s) _G.BeyondConfig.AntiAFK = s end)

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
                for _, p in ipairs(c:GetDescendants()) do
                    if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
                end
            end
        end)
    end
end)

local flyBV, flyBG, flyConn
function StartFly()
    if flyConn then return end
    pcall(function()
        local c = LocalPlayer.Character
        local hrp = c and c:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        flyBV = Instance.new("BodyVelocity")
        flyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        flyBV.Velocity = Vector3.zero
        flyBV.Parent = hrp
        flyBG = Instance.new("BodyGyro")
        flyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        flyBG.P = 9e4
        flyBG.CFrame = hrp.CFrame
        flyBG.Parent = hrp
        flyConn = RunService.Heartbeat:Connect(function()
            if not ScriptActive or not _G.BeyondConfig or not _G.BeyondConfig.FlyEnabled then
                if flyBV then flyBV:Destroy() end
                if flyBG then flyBG:Destroy() end
                if flyConn then flyConn:Disconnect() end
                flyBV, flyBG, flyConn = nil, nil, nil
                return
            end
            local ch = LocalPlayer.Character
            local r = ch and ch:FindFirstChild("HumanoidRootPart")
            if not r then return end
            local cam = workspace.CurrentCamera
            local md = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then md = md + cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then md = md - cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then md = md - cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then md = md + cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then md = md + Vector3.new(0,1,0) end
            if md.Magnitude > 0 then md = md.Unit * _G.BeyondConfig.FlySpeed end
            flyBV.Velocity = md
            flyBG.CFrame = cam.CFrame
        end)
    end)
end
function StopFly()
    pcall(function()
        if flyBV then flyBV:Destroy() end
        if flyBG then flyBG:Destroy() end
        if flyConn then flyConn:Disconnect() end
        flyBV, flyBG, flyConn = nil, nil, nil
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
        if _G.BeyondConfig.FlyEnabled and not flyConn then StartFly()
        elseif not _G.BeyondConfig.FlyEnabled and flyConn then StopFly() end
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
-- [20] TAB AUTO
-- ====================================================================
local aP = TabPages["Auto"]
CreateSectionLabel(aP, "АВТОКЛИКЕР")
CreateMobileToggle(aP, "Активировать автокликер", _G.BeyondConfig.Automation.AutoClickEnabled, function(s)
    _G.BeyondConfig.Automation.AutoClickEnabled = s
    PushNotification("Auto", s and "AutoClick ON" or "OFF", s and "success" or "warn")
    if s then
        task.spawn(function()
            while _G.BeyondConfig and _G.BeyondConfig.Automation.AutoClickEnabled and ScriptActive do
                local d = math.clamp(_G.BeyondConfig.Automation.ClickInterval / 1000, 0.01, 1.0)
                pcall(function()
                    if VirtualUser then
                        VirtualUser:CaptureController()
                        VirtualUser:ClickButton1(Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2))
                        _G.BeyondConfig.Automation.TotalClicksSimulated = _G.BeyondConfig.Automation.TotalClicksSimulated + 1
                    end
                end)
                task.wait(d)
            end
        end)
    end
end)
CreateMobileSlider(aP, "Интервал клика (мс)", 10, 1000, _G.BeyondConfig.Automation.ClickInterval, function(v)
    _G.BeyondConfig.Automation.ClickInterval = v
end)

CreateSectionLabel(aP, "АВТОПРЫЖОК")
CreateMobileToggle(aP, "Автопрыжок", false, function(s)
    _G.BeyondConfig.Automation.AutoJumpEnabled = s
    if s then
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
CreateMobileSlider(aP, "Интервал прыжка (мс)", 100, 2000, 300, function(v) _G.BeyondConfig.Automation.AutoJumpInterval = v end)

CreateSectionLabel(aP, "ЧАТ-МАКРОСЫ")
local ChatMacroData = {
    {Name = "Приветствие", Phrase = "Привет всем! Beyond v6.5.2 Zero Two."},
    {Name = "Внимание",    Phrase = "Тактическая активность!"},
    {Name = "GG",          Phrase = "GG WP всем!"}
}
for _, mi in ipairs(ChatMacroData) do
    local MF = CreateCardFrame(aP, 68)
    local MNL = Instance.new("TextLabel")
    MNL.Size = UDim2.new(0.6, 0, 0, 22); MNL.Position = UDim2.new(0, 16, 0, 6)
    MNL.Text = mi.Name; MNL.TextColor3 = Color3.fromRGB(240, 240, 245)
    MNL.Font = _G.BeyondConfig.Styles.FontsList.Bold; MNL.TextSize = 13
    MNL.TextXAlignment = Enum.TextXAlignment.Left; MNL.BackgroundTransparency = 1; MNL.Parent = MF
    local MPL = Instance.new("TextLabel")
    MPL.Size = UDim2.new(0.6, 0, 0, 30); MPL.Position = UDim2.new(0, 16, 0, 30)
    MPL.Text = mi.Phrase; MPL.TextColor3 = Color3.fromRGB(130, 130, 145)
    MPL.Font = _G.BeyondConfig.Styles.FontsList.Regular; MPL.TextSize = 10
    MPL.TextWrapped = true; MPL.TextXAlignment = Enum.TextXAlignment.Left
    MPL.TextYAlignment = Enum.TextYAlignment.Top; MPL.BackgroundTransparency = 1; MPL.Parent = MF
    local SB = Instance.new("TextButton")
    SB.Size = UDim2.new(0, 106, 0, 40); SB.Position = UDim2.new(1, -122, 0.5, -20)
    SB.BackgroundColor3 = Color3.fromRGB(35, 35, 48); SB.Text = "ОТПРАВИТЬ"
    SB.TextColor3 = Color3.fromRGB(255, 255, 255)
    SB.Font = _G.BeyondConfig.Styles.FontsList.Bold; SB.TextSize = 11
    SB.Parent = MF; UX.ApplyCorner(SB, 8)
    UX.AttachFull(SB, {baseColor = Color3.fromRGB(35, 35, 48), hoverMul = 1.3})
    SB.MouseButton1Click:Connect(function()
        if not ScriptActive or not _G.BeyondConfig then return end
        TweenService:Create(SB, TweenInfo.new(0.1), {BackgroundColor3 = _G.BeyondConfig.ThemeColor}):Play()
        task.spawn(function()
            FireLegalChatMessage(mi.Phrase)
            task.wait(0.2)
            if _G.BeyondConfig then
                TweenService:Create(SB, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 48)}):Play()
                SB:SetAttribute("UX_BaseColor", Color3.fromRGB(35, 35, 48))
            end
        end)
    end)
end

-- ====================================================================
-- [21] TAB ART
-- ====================================================================
local artPage = TabPages["Art"]

CreateSectionLabel(artPage, "ZERO TWO — 4K CHIBI")

local artHolder = Instance.new("Frame")
artHolder.Size = UDim2.new(1, 0, 0, 460)
artHolder.BackgroundColor3 = Color3.fromRGB(12, 10, 18)
artHolder.BorderSizePixel = 0
artHolder.ClipsDescendants = true
artHolder.Parent = artPage
UX.ApplyCorner(artHolder, 12)
UX.ApplyStroke(artHolder, _G.BeyondConfig.ThemeColor, 2)

NewShape(artHolder, 460, 260, 10, 100, Color3.fromRGB(40, 20, 40), 1, 0.7, 1)
NewShape(artHolder, 400, 200, 30, 140, Color3.fromRGB(60, 25, 55), 1, 0.6, 1)

local ZeroTwoChibi = DrawZeroTwoChibi(artHolder, 0.92)

task.spawn(function()
    local t = 0
    while ScriptActive and ZeroTwoChibi and ZeroTwoChibi.Parent do
        t = t + task.wait(0.05)
        local breathe = 1 + math.sin(t * 1.6) * 0.015
        local sway = math.sin(t * 0.9) * 1.2
        pcall(function()
            ZeroTwoChibi.Size = UDim2.new(
                0, 360 * 0.92 * breathe,
                0, 440 * 0.92 * breathe
            )
            ZeroTwoChibi.Rotation = sway
        end)
    end
end)

CreateSectionLabel(artPage, "НАСТРОЙКИ ART")

CreateMobileToggle(artPage, "Показывать тянку в шапке (watermark)", true, function(s)
    _G.BeyondConfig.Visuals.ShowWatermark = s
    if s and not _G._BeyondWatermark then
        local wm = DrawZeroTwoChibi(WatermarkHolder, 0.1)
        _G._BeyondWatermark = wm
    elseif not s and _G._BeyondWatermark then
        pcall(function() _G._BeyondWatermark:Destroy() end)
        _G._BeyondWatermark = nil
    end
end)

CreateActionButton(artPage, "🎨 ПЕРЕРИСОВАТЬ ТЯНКУ (regen)", Color3.fromRGB(50, 30, 60), function()
    pcall(function()
        if ZeroTwoChibi then ZeroTwoChibi:Destroy() end
        ZeroTwoChibi = DrawZeroTwoChibi(artHolder, 0.92)
        PushNotification("Art", "Тянка перерисована", "success")
    end)
end)

task.spawn(function()
    task.wait(0.5)
    if _G.BeyondConfig.Visuals.ShowWatermark then
        pcall(function()
            local wm = DrawZeroTwoChibi(WatermarkHolder, 0.1)
            _G._BeyondWatermark = wm
        end)
    end
end)

-- ====================================================================
-- [22] TAB CONFIG
-- ====================================================================
local cP = TabPages["Config"]
CreateSectionLabel(cP, "СЛОТЫ ПРОФИЛЕЙ")

local ConfigCardFrame = CreateCardFrame(cP, 180)
local ConfigStatusLabel = Instance.new("TextLabel")
ConfigStatusLabel.Size = UDim2.new(1, -24, 0, 26); ConfigStatusLabel.Position = UDim2.new(0, 16, 0, 6)
ConfigStatusLabel.Text = "Система: <font color='#00FF8C'>Готова</font>"
ConfigStatusLabel.RichText = true; ConfigStatusLabel.TextColor3 = Color3.fromRGB(225, 225, 235)
ConfigStatusLabel.Font = _G.BeyondConfig.Styles.FontsList.Semibold; ConfigStatusLabel.TextSize = 13
ConfigStatusLabel.TextXAlignment = Enum.TextXAlignment.Left; ConfigStatusLabel.BackgroundTransparency = 1
ConfigStatusLabel.Parent = ConfigCardFrame

local ActiveSlotLabel = Instance.new("TextLabel")
ActiveSlotLabel.Size = UDim2.new(1, -24, 0, 22); ActiveSlotLabel.Position = UDim2.new(0, 16, 0, 36)
ActiveSlotLabel.Text = "Активный слот: <font color='#FF2B5A'>" .. _G.BeyondConfig.ConfigSlots.ActiveSlot .. "</font> / "
    .. _G.BeyondConfig.ConfigSlots.SlotCount
ActiveSlotLabel.RichText = true; ActiveSlotLabel.TextColor3 = Color3.fromRGB(215, 215, 225)
ActiveSlotLabel.Font = _G.BeyondConfig.Styles.FontsList.Regular; ActiveSlotLabel.TextSize = 12
ActiveSlotLabel.TextXAlignment = Enum.TextXAlignment.Left; ActiveSlotLabel.BackgroundTransparency = 1
ActiveSlotLabel.Parent = ConfigCardFrame

function PushConfigStatusUpdate(html)
    if ConfigStatusLabel and ConfigStatusLabel.Parent then ConfigStatusLabel.Text = "Система: " .. html end
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
        AntiStun = _G.BeyondConfig.AntiStun,
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
    if not FS or not FS.Write then PushConfigStatusUpdate("<font color='#FF2B5A'>WriteFile недоступен</font>") return end
    local slot = _G.BeyondConfig.ConfigSlots.ActiveSlot
    local fn = BEYOND_CONFIG_BASE .. tostring(slot) .. ".json"
    local ok, enc = pcall(function() return HttpService:JSONEncode(SerializeConfig()) end)
    if not (ok and enc) then PushConfigStatusUpdate("<font color='#FF2B5A'>Ошибка сериализации</font>") return end
    local okW = pcall(function() FS.Write(fn, enc) end)
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
        PushConfigStatusUpdate("<font color='#FF2B5A'>ReadFile недоступен</font>"); return
    end
    local slot = _G.BeyondConfig.ConfigSlots.ActiveSlot
    local fn = BEYOND_CONFIG_BASE .. tostring(slot) .. ".json"
    if not FS.Check(fn) then PushConfigStatusUpdate("<font color='#FFBB00'>Слот пуст</font>") return end
    local okR, raw = pcall(function() return FS.Read(fn) end)
    if not (okR and raw) then PushConfigStatusUpdate("<font color='#FF2B5A'>Ошибка чтения</font>") return end
    local okD, dec = pcall(function() return HttpService:JSONDecode(raw) end)
    if not (okD and dec) then PushConfigStatusUpdate("<font color='#FF2B5A'>Ошибка JSON</font>") return end
    pcall(function()
        if dec.SpeedValue then _G.BeyondConfig.Movement.WalkSpeed = dec.SpeedValue end
        if dec.JumpPower then _G.BeyondConfig.Movement.JumpPower = dec.JumpPower end
        if dec.FlySpeed then _G.BeyondConfig.Movement.FlySpeed = dec.FlySpeed end
        if dec.InfiniteJump then _G.BeyondConfig.InfiniteJump = dec.InfiniteJump end
        if dec.Noclip then _G.BeyondConfig.Noclip = dec.Noclip end
        if dec.FlyEnabled then _G.BeyondConfig.FlyEnabled = dec.FlyEnabled end
        if dec.AntiAFK then _G.BeyondConfig.AntiAFK = dec.AntiAFK end
        if dec.AntiStun then _G.BeyondConfig.AntiStun = dec.AntiStun end
        if dec.HighlightESP then _G.BeyondConfig.Visuals.HighlightESP = dec.HighlightESP end
        if dec.MaxDistance then _G.BeyondConfig.Visuals.MaxDistance = dec.MaxDistance end
        if dec.RainbowGlow then _G.BeyondConfig.Visuals.RainbowGlow = dec.RainbowGlow end
        if dec.ThemeColor then
            _G.BeyondConfig.ThemeColor = Color3.new(dec.ThemeColor[1], dec.ThemeColor[2], dec.ThemeColor[3])
        end
    end)
    PushConfigStatusUpdate("<font color='#00FF8C'>Слот " .. slot .. " применён!</font>")
    PushNotification("Config", "Загружен слот " .. slot, "success")
end

local SlotRow = Instance.new("Frame")
SlotRow.Size = UDim2.new(1, -24, 0, 38); SlotRow.Position = UDim2.new(0, 12, 0, 66)
SlotRow.BackgroundTransparency = 1; SlotRow.Parent = ConfigCardFrame
local SBL = Instance.new("UIListLayout")
SBL.FillDirection = Enum.FillDirection.Horizontal; SBL.Padding = UDim.new(0, 7); SBL.Parent = SlotRow

for i = 1, _G.BeyondConfig.ConfigSlots.SlotCount do
    local SB = Instance.new("TextButton")
    SB.Size = UDim2.new(0, 52, 0, 34)
    SB.BackgroundColor3 = (i == _G.BeyondConfig.ConfigSlots.ActiveSlot) and _G.BeyondConfig.ThemeColor or Color3.fromRGB(34, 34, 46)
    SB.Text = "S" .. i; SB.TextColor3 = Color3.fromRGB(245, 245, 250)
    SB.Font = _G.BeyondConfig.Styles.FontsList.Bold; SB.TextSize = 12
    SB.LayoutOrder = i; SB.Parent = SlotRow
    UX.ApplyCorner(SB, 6)
    UX.AttachFull(SB, {
        baseColor = (i == _G.BeyondConfig.ConfigSlots.ActiveSlot) and _G.BeyondConfig.ThemeColor or Color3.fromRGB(34, 34, 46),
        hoverMul = 1.25
    })
    SB.MouseButton1Click:Connect(function()
        if not ScriptActive then return end
        _G.BeyondConfig.ConfigSlots.ActiveSlot = i
        for _, ch in ipairs(SlotRow:GetChildren()) do
            if ch:IsA("TextButton") then
                local idx = tonumber(ch.Text:sub(2))
                local col = (idx == i) and _G.BeyondConfig.ThemeColor or Color3.fromRGB(34, 34, 46)
                TweenService:Create(ch, TweenInfo.new(0.2), {BackgroundColor3 = col}):Play()
                ch:SetAttribute("UX_BaseColor", col)
            end
        end
        UpdateActiveSlotLabel()
    end)
end

local SaveRow = Instance.new("Frame")
SaveRow.Size = UDim2.new(1, -24, 0, 42); SaveRow.Position = UDim2.new(0, 12, 0, 112)
SaveRow.BackgroundTransparency = 1; SaveRow.Parent = ConfigCardFrame

local SaveBtn = Instance.new("TextButton")
SaveBtn.Size = UDim2.new(0.48, 0, 1, 0); SaveBtn.Position = UDim2.new(0, 0, 0, 0)
SaveBtn.BackgroundColor3 = Color3.fromRGB(34, 46, 38); SaveBtn.Text = "СОХРАНИТЬ"
SaveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SaveBtn.Font = _G.BeyondConfig.Styles.FontsList.Bold; SaveBtn.TextSize = 12
SaveBtn.Parent = SaveRow; UX.ApplyCorner(SaveBtn, 8)
UX.AttachFull(SaveBtn, {baseColor = Color3.fromRGB(34, 46, 38), hoverMul = 1.3})
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
LoadBtn.Size = UDim2.new(0.48, 0, 1, 0); LoadBtn.Position = UDim2.new(0.52, 0, 0, 0)
LoadBtn.BackgroundColor3 = Color3.fromRGB(34, 38, 46); LoadBtn.Text = "ЗАГРУЗИТЬ"
LoadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
LoadBtn.Font = _G.BeyondConfig.Styles.FontsList.Bold; LoadBtn.TextSize = 12
LoadBtn.Parent = SaveRow; UX.ApplyCorner(LoadBtn, 8)
UX.AttachFull(LoadBtn, {baseColor = Color3.fromRGB(34, 38, 46), hoverMul = 1.3})
LoadBtn.MouseButton1Click:Connect(function()
    if not ScriptActive then return end
    LoadBtn.Text = "⏳..."
    task.spawn(function()
        LoadConfigFromSlot()
        task.wait(0.4)
        if LoadBtn and LoadBtn.Parent then LoadBtn.Text = "ЗАГРУЗИТЬ" end
    end)
end)

CreateSectionLabel(cP, "УТИЛИТЫ")
CreateActionButton(cP, "СБРОС НАСТРОЕК", Color3.fromRGB(60, 30, 34), function()
    pcall(function()
        _G.BeyondConfig.Movement.WalkSpeed = 16
        _G.BeyondConfig.Movement.JumpPower = 50
        _G.BeyondConfig.Movement.FlySpeed = 60
        _G.BeyondConfig.InfiniteJump = false
        _G.BeyondConfig.Noclip = false
        _G.BeyondConfig.FlyEnabled = false
        _G.BeyondConfig.AntiStun = false
        _G.BeyondConfig.Visuals.HighlightESP = false
        _G.BeyondConfig.Visuals.RainbowGlow = false
    end)
    PushNotification("Config", "Сброшено", "warn")
end)

-- ====================================================================
-- [23] TAB DEBUG
-- ====================================================================
local dP = TabPages["Debug"]
CreateSectionLabel(dP, "ТЕЛЕМЕТРИЯ")

local StatsCardFrame = CreateCardFrame(dP, 130)
local FpsDisplay  = CreateStatDisplayLabel(StatsCardFrame, "FPS", 12)
local PingDisplay = CreateStatDisplayLabel(StatsCardFrame, "Ping", 42)
local MemDisplay  = CreateStatDisplayLabel(StatsCardFrame, "Memory", 72)
local ResDisplay  = CreateStatDisplayLabel(StatsCardFrame, "Разрешение", 102)

task.spawn(function()
    while ScriptActive and _G.BeyondConfig and task.wait(0.5) do
        pcall(function()
            if NetworkStats then TelemetryData.CurrentPing = math.round(NetworkStats.ServerPing) end
            TelemetryData.CurrentMemory = math.round(StatsService:GetTotalMemoryUsageMb())
            local fc = TelemetryData.CurrentFps >= 45 and "#00FF8C" or (TelemetryData.CurrentFps >= 25 and "#FFBB00" or "#FF2B5A")
            local pc = TelemetryData.CurrentPing <= 90 and "#00FF8C" or (TelemetryData.CurrentPing <= 200 and "#FFBB00" or "#FF2B5A")
            if FpsDisplay and FpsDisplay.Parent then
                FpsDisplay.Text  = "FPS: <font color='" .. fc .. "'>" .. tostring(TelemetryData.CurrentFps) .. "</font>"
            end
            if PingDisplay and PingDisplay.Parent then
                PingDisplay.Text = "Ping: <font color='" .. pc .. "'>" .. tostring(TelemetryData.CurrentPing) .. " ms</font>"
            end
            if MemDisplay and MemDisplay.Parent then
                MemDisplay.Text  = "Memory: <font color='#00BFFF'>" .. tostring(TelemetryData.CurrentMemory) .. " MB</font>"
            end
            if ResDisplay and ResDisplay.Parent then
                local vp = Camera.ViewportSize
                ResDisplay.Text  = "Разрешение: <font color='#C0C0D0'>" .. vp.X .. "x" .. vp.Y
                    .. " (x" .. string.format("%.2f", _G.BeyondConfig.UIScale) .. ")</font>"
            end
        end)
    end
end)

CreateSectionLabel(dP, "ОПТИМИЗАЦИЯ")
CreateMobileToggle(dP, "FPS Boost (оптимизация рендера)", _G.BeyondConfig.PerformanceBoost.OptimizerActive, function(s)
    _G.BeyondConfig.PerformanceBoost.OptimizerActive = s
    ToggleEnvironmentOptimization(s)
    PushNotification("Graphics", s and "FPS Boost ON" or "OFF", s and "success" or "warn")
end)

CreateSectionLabel(dP, "КОНСОЛЬ")
local ConsoleBoxFrame = Instance.new("ScrollingFrame")
ConsoleBoxFrame.Size = UDim2.new(1, 0, 0, 170)
ConsoleBoxFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
ConsoleBoxFrame.BorderSizePixel = 0
ConsoleBoxFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ConsoleBoxFrame.ScrollBarThickness = 4
ConsoleBoxFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 90)
ConsoleBoxFrame.Parent = dP
UX.ApplyCorner(ConsoleBoxFrame, 10)
UX.ApplyStroke(ConsoleBoxFrame, _G.BeyondConfig.Styles.BorderStrokeColor, 1)
local CLL = Instance.new("UIListLayout")
CLL.SortOrder = Enum.SortOrder.LayoutOrder; CLL.Padding = UDim.new(0, 4); CLL.Parent = ConsoleBoxFrame
local CP = Instance.new("UIPadding")
CP.PaddingLeft = UDim.new(0, 10); CP.PaddingRight = UDim.new(0, 10)
CP.PaddingTop = UDim.new(0, 6); CP.PaddingBottom = UDim.new(0, 6)
CP.Parent = ConsoleBoxFrame

function PrintToBeyondConsole(logText, logType)
    if not ScriptActive or not _G.BeyondConfig then return end
    _G.BeyondConfig.Logger.LogCount = _G.BeyondConfig.Logger.LogCount + 1
    local tc = Color3.fromRGB(240, 240, 245)
    if logType == "warn" then tc = Color3.fromRGB(255, 185, 0)
    elseif logType == "error" then tc = Color3.fromRGB(255, 43, 90)
    elseif logType == "success" then tc = Color3.fromRGB(0, 255, 140) end
    local LL = Instance.new("TextLabel")
    LL.Size = UDim2.new(1, 0, 0, 17); LL.BackgroundTransparency = 1
    LL.Text = string.format("[%s] %s", os.date("%H:%M:%S"), logText)
    LL.TextColor3 = tc; LL.Font = _G.BeyondConfig.Styles.FontsList.Monospace
    LL.TextSize = 11; LL.TextXAlignment = Enum.TextXAlignment.Left
    LL.LayoutOrder = _G.BeyondConfig.Logger.LogCount; LL.Parent = ConsoleBoxFrame
    local labels = {}
    for _, it in ipairs(ConsoleBoxFrame:GetChildren()) do
        if it:IsA("TextLabel") then table.insert(labels, it) end
    end
    if #labels > _G.BeyondConfig.Logger.MaxLinesStored then labels[1]:Destroy() end
    ConsoleBoxFrame.CanvasSize = UDim2.new(0, 0, 0, CLL.AbsoluteContentSize.Y + 14)
    ConsoleBoxFrame.CanvasPosition = Vector2.new(0, CLL.AbsoluteContentSize.Y)
end

CreateActionButton(dP, "🗑 ОЧИСТИТЬ КОНСОЛЬ", Color3.fromRGB(28, 28, 38), function()
    for _, it in ipairs(ConsoleBoxFrame:GetChildren()) do
        if it:IsA("TextLabel") then it:Destroy() end
    end
    ConsoleBoxFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    PrintToBeyondConsole("Консоль очищена.", "warn")
end)

CreateActionButton(dP, "🔄 ОБНОВИТЬ (refresh)", Color3.fromRGB(28, 38, 42), function()
    PrintToBeyondConsole("Refresh requested...", "info")
    PrintToBeyondConsole("ESP: " .. tostring(_G.BeyondConfig.Visuals.HighlightESP), "info")
    PrintToBeyondConsole("AntiStun: " .. tostring(_G.BeyondConfig.AntiStun), "info")
    PrintToBeyondConsole("Fly: " .. tostring(_G.BeyondConfig.FlyEnabled), "info")
    PrintToBeyondConsole("TabIndicator updated", "success")
end)

CreateSectionLabel(dP, "АУДИО")
CreateMobileToggle(dP, "Беззвучный режим", _G.BeyondConfig.Audio.MuteAll, function(s) _G.BeyondConfig.Audio.MuteAll = s end)
CreateMobileSlider(dP, "Громкость UI (%)", 0, 100, math.round(_G.BeyondConfig.Audio.MasterVolume * 100),
    function(v) _G.BeyondConfig.Audio.MasterVolume = v / 100 end)

task.spawn(function()
    while ScriptActive and task.wait(0.5) do
        pcall(function()
            for _, desc in ipairs(Container:GetDescendants()) do
                if desc:IsA("TextButton") and not desc:GetAttribute("AudioHooked") then
                    desc:SetAttribute("AudioHooked", true)
                    HookSoundToUIElement(desc, desc.Parent and desc.Parent.Name == "Track")
                end
            end
        end)
    end
end)

-- ====================================================================
-- [24] BOOT
-- ====================================================================
task.spawn(function()
    task.wait(0.8)
    PrintToBeyondConsole("BeyondClient v6.5.2 (TabIndicator Fixed) скомпилирован!", "success")
    PrintToBeyondConsole("Адаптация: HONOR Play5 / 2400x1080 / DPI 440", "info")
    PrintToBeyondConsole("TabIndicator: child of MainFrame + ratio positioning", "info")
    PushNotification("Beyond", "v6.5.2 запущен 💗", "success")
    task.wait(0.4)
    PushNotification("TabIndicator", "Позиционирование через ratios (без UIScale-бага)", "success")
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
    if MainFrame then
        MainFrame.ClipsDescendants = false
        MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
        MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        task.defer(function()
            if ScriptActive then UpdateTabIndicator(ActiveTabName) end
        end)
    end
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if not ScriptActive or not _G.BeyondConfig then return end
    if input.KeyCode == _G.BeyondConfig.Keybinds.PanicKey then
        if _G.BeyondClient_SelfDestruct then _G.BeyondClient_SelfDestruct() end
    end
end)

-- ★ На смену ViewportSize — пересчёт индикатора (ратио-подход к UIScale-independent)
Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    if not ScriptActive or not _G.BeyondConfig then return end
    local ns = CalculateAdaptiveScale()
    _G.BeyondConfig.UIScale = ns
    if MainUIScale then MainUIScale.Scale = ns end
    if MobileButtonScale then MobileButtonScale.Scale = ns end
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    task.defer(function()
        if ScriptActive then UpdateTabIndicator(ActiveTabName) end
    end)
end)

print("[BeyondClient v6.5.2 TabIndicator-Fixed]: Сборка успешно развёрнута.")