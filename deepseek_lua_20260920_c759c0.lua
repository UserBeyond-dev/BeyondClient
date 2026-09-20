--[[═══════════════════════════════════════════════════════════════════════════════
   ███████╗███████╗██████╗  ██████╗    ████████╗██╗    ██╗ ██████╗ 
   ╚══███╔╝██╔════╝██╔══██╗██╔═══██╗   ╚══██╔══╝██║    ██║██╔═══██╗
     ███╔╝ █████╗  ██████╔╝██║   ██║      ██║   ██║ █╗ ██║██║   ██║
    ███╔╝  ██╔══╝  ██╔══██╗██║   ██║      ██║   ██║███╗██║██║   ██║
   ███████╗███████╗██║  ██║╚██████╔╝      ██║   ╚███╔███╔╝╚██████╔╝
   ╚══════╝╚══════╝╚═╝  ╚═╝ ╚═════╝       ╚═╝    ╚══╝╚══╝  ╚═════╝ 
═══════════════════════════════════════════════════════════════════════════════
   ZERO TWO ULTIMATE EDITION v4.0
   Duel Warriors · Mobile Full Version · Delta Executor
   Target: HONOR Play5 / Dimensity 800U / 2400x1080 / Android 10
   Contains: Aim · ESP · Move · Protect · Graphics · Network · Art · Chat
═══════════════════════════════════════════════════════════════════════════════]]

-- ═══════════════════════════════════════════════════════════════════════════
-- [01/30] ПОДКЛЮЧЕНИЕ СЕРВИСОВ
-- ═══════════════════════════════════════════════════════════════════════════
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
local TeleportService   = game:GetService("TeleportService")
local HapticService     = game:GetService("HapticService")
local VirtualUser       = game:GetService("VirtualUser")
local Workspace         = workspace

local LocalPlayer = Players.LocalPlayer
local Camera      = Workspace.CurrentCamera or Workspace:WaitForChild("Camera")
local IS_MOBILE   = UserInputService.TouchEnabled and not UserInputService.MouseEnabled
local NetworkStats = StatsService:FindFirstChild("Network")
local Terrain      = Workspace:FindFirstChildOfClass("Terrain")

-- Безопасная очистка предыдущего запуска
if _G.DW_Exit then pcall(_G.DW_Exit) end
if _G.DW_VoiceExit then pcall(_G.DW_VoiceExit) end

-- ═══════════════════════════════════════════════════════════════════════════
-- [02/30] ГЛОБАЛЬНАЯ КОНФИГУРАЦИЯ
-- ═══════════════════════════════════════════════════════════════════════════
_G.DW = {
    Version  = "4.0.0-ULTIMATE",
    Developer = "Zero Two Studio",
    
    -- Цветовая схема
    Theme    = Color3.fromRGB(255, 43, 90),      -- Основной (розовый)
    Accent   = Color3.fromRGB(0, 200, 255),      -- Дополнительный (голубой)
    Success  = Color3.fromRGB(0, 220, 130),
    Warning  = Color3.fromRGB(255, 185, 0),
    Error    = Color3.fromRGB(255, 60, 80),
    Bg       = Color3.fromRGB(13, 13, 18),
    Card     = Color3.fromRGB(22, 22, 30),
    Header   = Color3.fromRGB(26, 24, 34),
    Border   = Color3.fromRGB(35, 35, 45),
    Text     = Color3.fromRGB(220, 220, 230),
    SubText  = Color3.fromRGB(140, 140, 160),
    
    -- Аймбот
    Aim = {
        on = false,
        mode = "Camera",             -- Camera | Instant | Smooth | Prediction
        targetPart = "Head",         -- Head | HumanoidRootPart | UpperTorso | Torso
        fov = 150,
        smooth = 0.35,
        maxDist = 500,
        teamCheck = true,
        wallCheck = true,
        onlyVisible = true,
        ignoreNPC = true,
        prediction = 0.15,
        priority = "Distance",       -- Distance | FOV | Health
        autoFire = false,
        autoFireDelay = 0.15,
        showFOVCircle = true,
        showTargetLine = true,
        lockTime = 0.5,              -- Время "удержания" цели (сек)
        targetLock = true,           -- Не прыгать между целями
    },
    
    -- ESP
    ESP = {
        on = false,
        fill = 0.5,
        outline = 0,
        maxDist = 500,
        rgb = false,
        teamColor = false,
        showHealth = false,
        showName = false,
        showDistance = false,
        onlyVisible = false,
    },
    
    -- Движение
    Move = {
        ws = 16, jp = 50, fs = 60,
        flyOn = false, infJump = false, noclip = false,
        grav = 196.2, gravOn = false,
        spdOn = false,
        antiAnchor = false,
    },
    
    -- Защита
    Guard = {
        antiAFK = true,
        antiStun = false,
        antiFling = false,
        antiVoid = false,
        antiDamage = false,
        antiFlash = false,
        antiBlind = false,
        safeZone = false,
    },
    
    -- Графика
    Gfx = {
        fullbright = false,
        noShadows = false,
        noFog = false,
        noBloom = false,
        noParticles = false,
        noWater = false,
        simpleTerrain = false,
        noAtmosphere = false,
        fovOn = false,
        fov = 70,
        origFov = 70,
        renderDist = 1000,
        origRenderDist = 1000,
        lodBias = 1,
        origLod = 1,
    },
    
    -- HUD
    HUD = {
        wm = true,
        coords = false,
        netStats = false,
        fps = true,
        ping = true,
        memory = false,
        speed = false,
        showAimTarget = true,
    },
    
    -- Кроссхэир
    Cross = {
        on = false,
        size = 18,
        thick = 3,
        gap = 6,
        dot = false,
        color = Color3.fromRGB(255, 43, 90),
        style = "Cross",             -- Cross | Circle | Dot | Crosshair4
    },
    
    -- Автоматизация
    Auto = {
        click = false,
        clickMs = 100,
        jump = false,
        jumpMs = 300,
        spamChat = false,
        spamMs = 5000,
        spamText = "GG WP всем!",
    },
    
    -- Сеть
    Net = {
        optimizer = false,
        bufferMode = false,
        lagShield = false,
        packetGuard = false,
        pingLimit = 200,
        autoReconnect = false,
    },
    
    -- Интерфейс
    UI = {
        activeTab = "Aim",
        minimized = true,
        collapsed = false,
        scale = 1,
        character = "ZeroTwo",       -- ZeroTwo | Nezuko | Marin
        showPulse = true,
        showBlobs = true,
    },
    
    -- Аудио
    Audio = {
        mute = false,
        vol = 0.5,
    },
    
    -- Конфиги
    Slots = { active = 1, total = 5 },
    
    -- Оригинальные значения
    orig = {
        shadows  = Lighting.GlobalShadows,
        fog      = Lighting.FogEnd,
        amb      = Lighting.Ambient,
        outAmb   = Lighting.OutdoorAmbient,
        bright   = Lighting.Brightness,
        grav     = Workspace.Gravity,
        clock    = Lighting.ClockTime,
    },
    
    -- Статистика
    Fps = 60,
    Ping = 0,
    Memory = 0,
    PacketLoss = 0,
}
local CFG = _G.DW
local Alive = true

-- ═══════════════════════════════════════════════════════════════════════════
-- [03/30] ФАЙЛОВАЯ СИСТЕМА
-- ═══════════════════════════════════════════════════════════════════════════
local FS = {
    W = writefile or (syn and syn.writefile),
    R = readfile or (syn and syn.readfile),
    C = isfile or (syn and syn.isfile),
    D = delfile or (syn and syn.delfile),
}
local FILE_BTN   = "DW4_button_pos.json"
local FILE_CFG   = "DW4_config_slot_"
local FILE_THEME = "DW4_theme.json"

-- ═══════════════════════════════════════════════════════════════════════════
-- [04/30] UX УТИЛИТЫ
-- ═══════════════════════════════════════════════════════════════════════════
local UX = {}

function UX.corner(obj, radius)
    local c = Instance.new("UICorner", obj)
    c.CornerRadius = UDim.new(0, radius or 8)
    return c
end

function UX.stroke(obj, color, thickness, transparency)
    local s = Instance.new("UIStroke", obj)
    s.Color = color or Color3.fromRGB(60, 60, 75)
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    return s
end

function UX.mulColor(c, k)
    return Color3.new(
        math.clamp(c.R * k, 0, 1),
        math.clamp(c.G * k, 0, 1),
        math.clamp(c.B * k, 0, 1)
    )
end

function UX.hover(btn, base, multiplier)
    multiplier = multiplier or 1.2
    btn:SetAttribute("UX_Base", base)
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {
            BackgroundColor3 = UX.mulColor(base, multiplier)
        }):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {
            BackgroundColor3 = base
        }):Play()
    end)
end

function UX.press(btn, scaleDown)
    scaleDown = scaleDown or 0.95
    local sc = Instance.new("UIScale", btn)
    sc.Scale = 1
    btn.MouseButton1Down:Connect(function()
        TweenService:Create(sc, TweenInfo.new(0.08), {Scale = scaleDown}):Play()
    end)
    btn.MouseButton1Up:Connect(function()
        TweenService:Create(sc, TweenInfo.new(0.15, Enum.EasingStyle.Back), {Scale = 1}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(sc, TweenInfo.new(0.15, Enum.EasingStyle.Back), {Scale = 1}):Play()
    end)
end

function UX.ripple(btn, color)
    btn.ClipsDescendants = true
    color = color or Color3.fromRGB(255, 255, 255)
    local cooldown = 0
    btn.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1
           and input.UserInputType ~= Enum.UserInputType.Touch then return end
        if tick() - cooldown < 0.08 then return end
        cooldown = tick()
        local ripple = Instance.new("Frame")
        ripple.BackgroundColor3 = color
        ripple.BackgroundTransparency = 0.6
        ripple.BorderSizePixel = 0
        ripple.AnchorPoint = Vector2.new(0.5, 0.5)
        ripple.Position = UDim2.new(
            0, input.Position.X - btn.AbsolutePosition.X,
            0, input.Position.Y - btn.AbsolutePosition.Y
        )
        ripple.Size = UDim2.new(0, 0, 0, 0)
        ripple.ZIndex = (btn.ZIndex or 1) + 1
        ripple.Parent = btn
        UX.corner(ripple, 999)
        local maxSize = math.max(btn.AbsoluteSize.X, btn.AbsoluteSize.Y) * 2.2
        TweenService:Create(ripple, TweenInfo.new(0.6, Enum.EasingStyle.Quart), {
            Size = UDim2.new(0, maxSize, 0, maxSize),
            BackgroundTransparency = 1
        }):Play()
        task.delay(0.65, function()
            if ripple and ripple.Parent then ripple:Destroy() end
        end)
    end)
end

function UX.full(btn, opts)
    opts = opts or {}
    if opts.base then UX.hover(btn, opts.base, opts.hoverMul) end
    UX.ripple(btn, opts.rippleColor)
    if opts.pressScale ~= false then UX.press(btn, opts.pressMul) end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- [05/30] ВИБРАЦИЯ И ЗВУК
-- ═══════════════════════════════════════════════════════════════════════════
local function Vibrate(power, duration)
    if not IS_MOBILE then return end
    pcall(function()
        if HapticService:IsVibrationSupported(Enum.UserInputType.Touch) then
            HapticService:SetMotor(Enum.UserInputType.Touch, Enum.VibrationMotor.Small, power or 0.5)
            task.delay(duration or 0.08, function()
                HapticService:SetMotor(Enum.UserInputType.Touch, Enum.VibrationMotor.Small, 0)
            end)
        end
    end)
end

local AudioFolder = SoundService:FindFirstChild("DW_Audio") or Instance.new("Folder")
AudioFolder.Name = "DW_Audio"
AudioFolder.Parent = SoundService

function PlayClick(volumeMul)
    if not Alive or CFG.Audio.mute then return end
    Vibrate(0.4)
    task.spawn(function()
        pcall(function()
            local snd = Instance.new("Sound")
            snd.SoundId = "rbxassetid://6140381534"
            snd.Volume = CFG.Audio.vol * (volumeMul or 1)
            snd.PlayOnRemove = true
            snd.Parent = AudioFolder
            snd:Destroy()
        end)
    end)
end

function PlaySuccess()
    if not Alive or CFG.Audio.mute then return end
    Vibrate(0.7, 0.15)
    task.spawn(function()
        pcall(function()
            local snd = Instance.new("Sound")
            snd.SoundId = "rbxassetid://6042053626"
            snd.Volume = CFG.Audio.vol * 0.7
            snd.PlayOnRemove = true
            snd.Parent = AudioFolder
            snd:Destroy()
        end)
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════
-- [06/30] УВЕДОМЛЕНИЯ
-- ═══════════════════════════════════════════════════════════════════════════
local NotifySG = Instance.new("ScreenGui")
NotifySG.Name = "DW_Notifications"
NotifySG.ResetOnSpawn = false
NotifySG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
if not pcall(function() NotifySG.Parent = CoreGui end) then
    NotifySG.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local NotifyStack = {}

local function removeNotify(nf)
    for i, n in ipairs(NotifyStack) do
        if n == nf then table.remove(NotifyStack, i); break end
    end
    if nf and nf.Parent then
        TweenService:Create(nf, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 300, 0, 0),
            BackgroundTransparency = 0.5
        }):Play()
        task.wait(0.32)
        pcall(function() nf:Destroy() end)
    end
end

function PushNotify(title, msg, kind)
    if not Alive then return end
    
    local accent = CFG.Theme
    local icon = "●"
    if kind == "warn" then accent = CFG.Warning; icon = "⚠"
    elseif kind == "error" then accent = CFG.Error; icon = "✕"
    elseif kind == "success" then accent = CFG.Success; icon = "✔" end
    
    local duration = 3.5
    
    local nf = Instance.new("Frame")
    nf.Size = UDim2.new(0, 300, 0, 0)
    nf.Position = IS_MOBILE and UDim2.new(0.5, -150, 0, 20) or UDim2.new(1, -320, 0, 100)
    nf.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
    nf.BorderSizePixel = 0
    nf.ClipsDescendants = true
    nf.Parent = NotifySG
    UX.corner(nf, 12)
    local ns = Instance.new("UIScale", nf)
    ns.Scale = 1
    UX.stroke(nf, accent, 2)
    
    local grad = Instance.new("UIGradient", nf)
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(28, 26, 34)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(16, 16, 22))
    })
    grad.Rotation = 90
    
    local bar = Instance.new("Frame", nf)
    bar.Size = UDim2.new(0, 4, 1, 0)
    bar.BackgroundColor3 = accent
    bar.BorderSizePixel = 0
    bar.ZIndex = 3
    
    local ic = Instance.new("Frame", nf)
    ic.Size = UDim2.new(0, 26, 0, 26)
    ic.Position = UDim2.new(0, 14, 0, 10)
    ic.BackgroundColor3 = accent
    ic.BackgroundTransparency = 0.85
    ic.BorderSizePixel = 0
    ic.ZIndex = 3
    ic.Parent = nf
    UX.corner(ic, 999)
    UX.stroke(ic, accent, 1)
    
    local icl = Instance.new("TextLabel", ic)
    icl.Size = UDim2.new(1, 0, 1, 0)
    icl.BackgroundTransparency = 1
    icl.Text = icon
    icl.TextColor3 = accent
    icl.Font = Enum.Font.GothamBold
    icl.TextSize = 14
    icl.ZIndex = 4
    
    local tl = Instance.new("TextLabel", nf)
    tl.Size = UDim2.new(1, -80, 0, 20)
    tl.Position = UDim2.new(0, 48, 0, 12)
    tl.BackgroundTransparency = 1
    tl.Text = title or "DW"
    tl.TextColor3 = Color3.fromRGB(245, 245, 250)
    tl.Font = Enum.Font.GothamBold
    tl.TextSize = 13
    tl.TextXAlignment = Enum.TextXAlignment.Left
    tl.ZIndex = 3
    
    local bl = Instance.new("TextLabel", nf)
    bl.Size = UDim2.new(1, -20, 0, 30)
    bl.Position = UDim2.new(0, 14, 0, 38)
    bl.BackgroundTransparency = 1
    bl.Text = msg or ""
    bl.TextColor3 = Color3.fromRGB(180, 180, 195)
    bl.Font = Enum.Font.Gotham
    bl.TextSize = 11
    bl.TextWrapped = true
    bl.TextXAlignment = Enum.TextXAlignment.Left
    bl.TextYAlignment = Enum.TextYAlignment.Top
    bl.ZIndex = 3
    
    local xbtn = Instance.new("TextButton", nf)
    xbtn.Size = UDim2.new(0, 22, 0, 22)
    xbtn.Position = UDim2.new(1, -30, 0, 12)
    xbtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    xbtn.BackgroundTransparency = 0.4
    xbtn.Text = "✕"
    xbtn.TextColor3 = Color3.fromRGB(200, 200, 215)
    xbtn.Font = Enum.Font.GothamBold
    xbtn.TextSize = 12
    xbtn.ZIndex = 5
    UX.corner(xbtn, 6)
    
    local pbg = Instance.new("Frame", nf)
    pbg.Size = UDim2.new(1, 0, 0, 3)
    pbg.Position = UDim2.new(0, 0, 1, -3)
    pbg.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    pbg.BorderSizePixel = 0
    pbg.ZIndex = 3
    
    local pbar = Instance.new("Frame", pbg)
    pbar.Size = UDim2.new(1, 0, 1, 0)
    pbar.BackgroundColor3 = accent
    pbar.BorderSizePixel = 0
    pbar.ZIndex = 4
    
    for _, n in ipairs(NotifyStack) do
        if n and n.Parent then
            local cp = n.Position
            TweenService:Create(n, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
                Position = UDim2.new(cp.X.Scale, cp.X.Offset, cp.Y.Scale, cp.Y.Offset + 76)
            }):Play()
        end
    end
    table.insert(NotifyStack, nf)
    
    TweenService:Create(nf, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 300, 0, 72)
    }):Play()
    TweenService:Create(pbar, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
        Size = UDim2.new(0, 0, 1, 0)
    }):Play()
    
    local closed = false
    xbtn.MouseButton1Click:Connect(function()
        if closed then return end
        closed = true
        task.spawn(function() removeNotify(nf) end)
    end)
    task.spawn(function()
        task.wait(duration)
        if closed then return end
        closed = true
        removeNotify(nf)
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════
-- [07/30] ГЛАВНЫЙ SCREENGUI
-- ═══════════════════════════════════════════════════════════════════════════
local SG = Instance.new("ScreenGui")
SG.Name = "DW_" .. HttpService:GenerateGUID(false):sub(1, 8)
SG.ResetOnSpawn = false
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
if not pcall(function() SG.Parent = CoreGui end) then
    SG.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- ═══════════════════════════════════════════════════════════════════════════
-- [08/30] ПЛАВАЮЩАЯ АНИМЕ-КНОПКА (с 3 персонажами)
-- ═══════════════════════════════════════════════════════════════════════════

-- Матрицы пиксель-арта (24×24) для трёх персонажей
local CHIBI_DATA = {
    ZeroTwo = {
        name = "Zero Two",
        colors = {
            H = Color3.fromRGB(255, 122, 168),  -- Основной цвет волос
            R = Color3.fromRGB(230, 40, 74),    -- Рожки
            r = Color3.fromRGB(156, 18, 48),    -- Тень рожек
            W = Color3.fromRGB(255, 255, 255),  -- Белки
            S = Color3.fromRGB(255, 228, 210),  -- Кожа
            B = Color3.fromRGB(255, 125, 165),  -- Румянец
            M = Color3.fromRGB(215, 60, 100),   -- Рот
            C = Color3.fromRGB(255, 200, 80),   -- Корона
            E = Color3.fromRGB(120, 210, 195),  -- Глаза
            e = Color3.fromRGB(45, 115, 105),   -- Зрачок
        },
        idle = {
            ".....RR..........RR.....",
            "....RRRR........RRRR....",
            "....rRRR........RRRr....",
            ".....rRR........RRr.....",
            ".....HHH..WWWW..HHH.....",
            "...HHHHH.WWWWWW.HHHHH...",
            "..HHHHHHWWWWWWWWHHHHHH..",
            ".HHHHHHHHHHHHHHHHHHHHHH.",
            ".HHHHHHHHHHHHHHHHHHHHHH.",
            ".HHHHHSSSSSSSSSSSSHHHHH.",
            ".HHHHSSSSSSSSSSSSSSHHHH.",
            ".HHHHSEEEESSSEEEESHHHH..",
            ".HHHHSESeeESSSESeeESHHH.",
            ".HHHHSEEEESSSEEEESHHHH..",
            ".HHHHSSSSSSSSSSSSSHHHH..",
            ".HHHHSBSSSSSSSSSSBSSHH..",
            ".HHHHSBBSSSSSSSSBBSSHH..",
            ".HHHHSSSSMMMMMSSSSHHHH..",
            ".HHHHSSSMMWWWMMSSSHHHH..",
            ".HHHHSSSSMMMMMSSSSHHHH..",
            ".HHHHHSSSSSSSSSSHHHHH...",
            "..HHHHHHHHHHHHHHHHHH....",
            "...HHHHHCCCCCHHHHH......",
            "....HHHHCCCHHHH.........",
        },
        blink = {
            ".....RR..........RR.....",
            "....RRRR........RRRR....",
            "....rRRR........RRRr....",
            ".....rRR........RRr.....",
            ".....HHH..WWWW..HHH.....",
            "...HHHHH.WWWWWW.HHHHH...",
            "..HHHHHHWWWWWWWWHHHHHH..",
            ".HHHHHHHHHHHHHHHHHHHHHH.",
            ".HHHHHHHHHHHHHHHHHHHHHH.",
            ".HHHHHSSSSSSSSSSSSHHHHH.",
            ".HHHHSSSSSSSSSSSSSSHHHH.",
            ".HHHHSSeeeSSSeeeeSHHHH..",
            ".HHHHSESeeESSSESeeESHHH.",
            ".HHHHSSeeeSSSeeeeSHHHH..",
            ".HHHHSSSSSSSSSSSSSHHHH..",
            ".HHHHSBSSSSSSSSSSBSSHH..",
            ".HHHHSBBSSSSSSSSBBSSHH..",
            ".HHHHSSSSMMMMMSSSSHHHH..",
            ".HHHHSSSMMWWWMMSSSHHHH..",
            ".HHHHSSSSMMMMMSSSSHHHH..",
            ".HHHHHSSSSSSSSSSHHHHH...",
            "..HHHHHHHHHHHHHHHHHH....",
            "...HHHHHCCCCCHHHHH......",
            "....HHHHCCCHHHH.........",
        },
        smile = {
            ".....RR..........RR.....",
            "....RRRR........RRRR....",
            "....rRRR........RRRr....",
            ".....rRR........RRr.....",
            ".....HHH..WWWW..HHH.....",
            "...HHHHH.WWWWWW.HHHHH...",
            "..HHHHHHWWWWWWWWHHHHHH..",
            ".HHHHHHHHHHHHHHHHHHHHHH.",
            ".HHHHHHHHHHHHHHHHHHHHHH.",
            ".HHHHHSSSSSSSSSSSSHHHHH.",
            ".HHHHSSSSSSSSSSSSSSHHHH.",
            ".HHHHSEEEESSSEEEESHHHH..",
            ".HHHHSESeeESSSESeeESHHH.",
            ".HHHHSEEEESSSEEEESHHHH..",
            ".HHHHSSSSSSSSSSSSSHHHH..",
            ".HHHHSBSSSSSSSSSSBSSHH..",
            ".HHHHSBBSSSSSSSSBBSSHH..",
            ".HHHHSSSSMMMMMSSSSHHHH..",
            ".HHHHSSSMMMMMMMSSSHHHH..",
            ".HHHHSSSSMMMMMSSSSHHHH..",
            ".HHHHHSSSSSSSSSSHHHHH...",
            "..HHHHHHHHHHHHHHHHHH....",
            "...HHHHHCCCCCHHHHH......",
            "....HHHHCCCHHHH.........",
        },
    },
    Nezuko = {
        name = "Nezuko",
        colors = {
            H = Color3.fromRGB(45, 30, 25),     -- Тёмные волосы
            R = Color3.fromRGB(255, 105, 180),  -- Бамбук в цвете
            r = Color3.fromRGB(200, 60, 130),   -- Тень
            W = Color3.fromRGB(255, 255, 255),
            S = Color3.fromRGB(255, 235, 220),
            B = Color3.fromRGB(255, 155, 155),
            M = Color3.fromRGB(200, 80, 80),
            C = Color3.fromRGB(255, 165, 200),
            E = Color3.fromRGB(255, 100, 150),
            e = Color3.fromRGB(180, 60, 90),
        },
        idle = {
            "........................",
            "........HHHHHHHH........",
            "......HHHHHHHHHHHH......",
            ".....HHHHHHHHHHHHHH.....",
            "....HHHHHHHHHHHHHHHH....",
            "...HHHHHHHHHHHHHHHHHH...",
            "..HHHHHHHHHHHHHHHHHHHH..",
            "..HHHHHHHHHHHHHHHHHHHH..",
            "..HHHHHSSSSSSSSSSHHHHH..",
            "..HHHSSSSSSSSSSSSSSHHH..",
            "..HHSSSSSSSSSSSSSSSSHH..",
            "..HHSSSEEESSSSEEESSSHH..",
            "..HHSSESeeESSSESeeESSH..",
            "..HHSSSEEESSSSEEESSSHH..",
            "..HHHSSSSSSSSSSSSSSHH...",
            "..HHHSSBSSSSSSSSBSSHH...",
            "..HHHHSSSSSSSSSSSSHH....",
            "...HHHHSSMMMMMMSSHH.....",
            "....HHHSSMMMMMMSSH......",
            "....HHHHRRRRRRRRHH......",
            "....HHHHRRRRRRRRHH......",
            "....HHHHRRRRRRRRHH......",
            ".....HHHRRRRRRHHH.......",
            "......HHHHHHHHHH........",
        },
        blink = {
            "........................",
            "........HHHHHHHH........",
            "......HHHHHHHHHHHH......",
            ".....HHHHHHHHHHHHHH.....",
            "....HHHHHHHHHHHHHHHH....",
            "...HHHHHHHHHHHHHHHHHH...",
            "..HHHHHHHHHHHHHHHHHHHH..",
            "..HHHHHHHHHHHHHHHHHHHH..",
            "..HHHHHSSSSSSSSSSHHHHH..",
            "..HHHSSSSSSSSSSSSSSHHH..",
            "..HHSSSSSSSSSSSSSSSSHH..",
            "..HHSSSeeeeSSSeeeeSSHH..",
            "..HHSSSeeeeSSSeeeeSSH...",
            "..HHSSSeeeeSSSeeeeSSHH..",
            "..HHHSSSSSSSSSSSSSSHH...",
            "..HHHSSBSSSSSSSSBSSHH...",
            "..HHHHSSSSSSSSSSSSHH....",
            "...HHHHSSMMMMMMSSHH.....",
            "....HHHSSMMMMMMSSH......",
            "....HHHHRRRRRRRRHH......",
            "....HHHHRRRRRRRRHH......",
            "....HHHHRRRRRRRRHH......",
            ".....HHHRRRRRRHHH.......",
            "......HHHHHHHHHH........",
        },
        smile = {
            "........................",
            "........HHHHHHHH........",
            "......HHHHHHHHHHHH......",
            ".....HHHHHHHHHHHHHH.....",
            "....HHHHHHHHHHHHHHHH....",
            "...HHHHHHHHHHHHHHHHHH...",
            "..HHHHHHHHHHHHHHHHHHHH..",
            "..HHHHHHHHHHHHHHHHHHHH..",
            "..HHHHHSSSSSSSSSSHHHHH..",
            "..HHHSSSSSSSSSSSSSSHHH..",
            "..HHSSSSSSSSSSSSSSSSHH..",
            "..HHSSSEEESSSSEEESSSHH..",
            "..HHSSESeeESSSESeeESSH..",
            "..HHSSSEEESSSSEEESSSHH..",
            "..HHHSSSSSSSSSSSSSSHH...",
            "..HHHSSBSSSSSSSSBSSHH...",
            "..HHHHSSSSSSSSSSSSHH....",
            "...HHHHSSMMMMMMSSHH.....",
            "....HHHSSMMMMMMSSH......",
            "....HHHHRRRRRRRRHH......",
            "....HHHHRRRRRRRRHH......",
            "....HHHHRRRRRRRRHH......",
            ".....HHHRRRRRRHHH.......",
            "......HHHHHHHHHH........",
        },
    },
    Marin = {
        name = "Marin",
        colors = {
            H = Color3.fromRGB(255, 220, 100),  -- Блондинистые волосы
            R = Color3.fromRGB(255, 100, 150),  -- Розовые пряди
            r = Color3.fromRGB(200, 70, 120),
            W = Color3.fromRGB(255, 255, 255),
            S = Color3.fromRGB(255, 230, 210),
            B = Color3.fromRGB(255, 160, 180),
            M = Color3.fromRGB(220, 90, 110),
            C = Color3.fromRGB(255, 200, 220),
            E = Color3.fromRGB(100, 180, 220),
            e = Color3.fromRGB(40, 100, 150),
        },
        idle = {
            ".......HHHHHHHHHH.......",
            "......HHHHHHHHHHHH......",
            ".....HHHHHHHHHHHHHH.....",
            "....HHHHHHHHHHHHHHHH....",
            "...HHHHHHHHHHHHHHHHHH...",
            "..HHHRRRRRRRRRRRRRRRHH..",
            "..HRRRRRRRRRRRRRRRRRRH..",
            "..HRRRRRSSSSSSSSRRRRRH..",
            "..HRRRRSSSSSSSSSSRRRRH..",
            "..HRRRSSSSSSSSSSSSRRRH..",
            "..HRRSSSSSSSSSSSSSSRRH..",
            "..HHRSSSEEESSSSEEESSHH..",
            "..HHSESeeeESSSESeeeESSH..",
            "..HHSESeeeESSSESeeeESSH..",
            "..HHRSSSEEESSSSEEESSHH..",
            "..HRRSSSSSSSSSSSSSSRRH..",
            "..HRRSSBSSSSSSSSBSSRRH..",
            "..HRRRSSSSMMMMSSSSRRRH..",
            "..HRRRSSSSMMMMSSSSRRRH..",
            "..HHRRRRSSSSSSSSRRRRHH..",
            "...HHHRRRRRRRRRRRRHHH...",
            "....HHHHHHHHHHHHHHHH....",
            "......HHHHHHHHHHHH......",
            ".......HHHHHHHHHH.......",
        },
        blink = {
            ".......HHHHHHHHHH.......",
            "......HHHHHHHHHHHH......",
            ".....HHHHHHHHHHHHHH.....",
            "....HHHHHHHHHHHHHHHH....",
            "...HHHHHHHHHHHHHHHHHH...",
            "..HHHRRRRRRRRRRRRRRRHH..",
            "..HRRRRRRRRRRRRRRRRRRH..",
            "..HRRRRRSSSSSSSSRRRRRH..",
            "..HRRRRSSSSSSSSSSRRRRH..",
            "..HRRRSSSSSSSSSSSSRRRH..",
            "..HRRSSSSSSSSSSSSSSRRH..",
            "..HHRSSSeeeeSSSeeeeSHH..",
            "..HHSESeeeESSSESeeeESSH..",
            "..HHSESeeeESSSESeeeESSH..",
            "..HHRSSSeeeeSSSeeeeSHH..",
            "..HRRSSSSSSSSSSSSSSRRH..",
            "..HRRSSBSSSSSSSSBSSRRH..",
            "..HRRRSSSSMMMMSSSSRRRH..",
            "..HRRRSSSSMMMMSSSSRRRH..",
            "..HHRRRRSSSSSSSSRRRRHH..",
            "...HHHRRRRRRRRRRRRHHH...",
            "....HHHHHHHHHHHHHHHH....",
            "......HHHHHHHHHHHH......",
            ".......HHHHHHHHHH.......",
        },
        smile = {
            ".......HHHHHHHHHH.......",
            "......HHHHHHHHHHHH......",
            ".....HHHHHHHHHHHHHH.....",
            "....HHHHHHHHHHHHHHHH....",
            "...HHHHHHHHHHHHHHHHHH...",
            "..HHHRRRRRRRRRRRRRRRHH..",
            "..HRRRRRRRRRRRRRRRRRRH..",
            "..HRRRRRSSSSSSSSRRRRRH..",
            "..HRRRRSSSSSSSSSSRRRRH..",
            "..HRRRSSSSSSSSSSSSRRRH..",
            "..HRRSSSSSSSSSSSSSSRRH..",
            "..HHRSSSEEESSSSEEESSHH..",
            "..HHSESeeeESSSESeeeESSH..",
            "..HHSESeeeESSSESeeeESSH..",
            "..HHRSSSEEESSSSEEESSHH..",
            "..HRRSSSSSSSSSSSSSSRRH..",
            "..HRRSSBSSSSSSSSBSSRRH..",
            "..HRRRSSSMMMMMMSSSRRRH..",
            "..HRRRSSSSMMMMSSSSRRRH..",
            "..HHRRRRSSSSSSSSRRRRHH..",
            "...HHHRRRRRRRRRRRRHHH...",
            "....HHHHHHHHHHHHHHHH....",
            "......HHHHHHHHHHHH......",
            ".......HHHHHHHHHH.......",
        },
    },
}

-- Получаем данные текущего персонажа
local function GetCurrentCharacter()
    return CHIBI_DATA[CFG.UI.character] or CHIBI_DATA.ZeroTwo
end

-- Плавающая кнопка
local FB = Instance.new("ImageButton", SG)
FB.Name = "DW_ChibiButton"
FB.Size = UDim2.new(0, 130, 0, 130)
FB.AnchorPoint = Vector2.new(0.5, 1)
FB.Position = UDim2.new(0.5, 0, 1, -20)
FB.BackgroundColor3 = Color3.fromRGB(255, 245, 250)
FB.BorderSizePixel = 0
FB.Image = ""
FB.ImageTransparency = 1
FB.AutoButtonColor = false
FB.ClipsDescendants = false
FB.ZIndex = 50
FB.Active = true
FB.Visible = true
UX.corner(FB, 999)
local FBS = UX.stroke(FB, CFG.Theme, 4)

-- Пульсирующее кольцо
local PulseRing = Instance.new("Frame", FB)
PulseRing.Size = UDim2.new(1, 10, 1, 10)
PulseRing.AnchorPoint = Vector2.new(0.5, 0.5)
PulseRing.Position = UDim2.new(0.5, 0, 0.5, 0)
PulseRing.BackgroundTransparency = 1
PulseRing.ZIndex = 1
UX.corner(PulseRing, 999)
local PulseStroke = UX.stroke(PulseRing, CFG.Theme, 3, 0.4)

-- Второе кольцо (эхо)
local PulseRing2 = Instance.new("Frame", FB)
PulseRing2.Size = UDim2.new(1, 10, 1, 10)
PulseRing2.AnchorPoint = Vector2.new(0.5, 0.5)
PulseRing2.Position = UDim2.new(0.5, 0, 0.5, 0)
PulseRing2.BackgroundTransparency = 1
PulseRing2.ZIndex = 1
UX.corner(PulseRing2, 999)
local PulseStroke2 = UX.stroke(PulseRing2, CFG.Theme, 2, 0.6)

task.spawn(function()
    local t = 0
    while Alive and FB.Visible do
        local dt = RunService.Heartbeat:Wait()
        t = t + dt
        -- Кольцо 1
        if t % 1.5 < 0.05 then
            local sc1 = PulseRing:FindFirstChildOfClass("UIScale") or Instance.new("UIScale", PulseRing)
            sc1.Scale = 1
            TweenService:Create(sc1, TweenInfo.new(1.5, Enum.EasingStyle.Quart), {Scale = 1.6}):Play()
            TweenService:Create(PulseStroke, TweenInfo.new(1.5, Enum.EasingStyle.Quart), {Transparency = 1}):Play()
        end
        -- Кольцо 2 (отставание)
        if (t + 0.75) % 1.5 < 0.05 then
            local sc2 = PulseRing2:FindFirstChildOfClass("UIScale") or Instance.new("UIScale", PulseRing2)
            sc2.Scale = 1
            TweenService:Create(sc2, TweenInfo.new(1.5, Enum.EasingStyle.Quart), {Scale = 1.5}):Play()
            TweenService:Create(PulseStroke2, TweenInfo.new(1.5, Enum.EasingStyle.Quart), {Transparency = 1}):Play()
        end
    end
end)

-- Контейнер чиби
local ChibiRoot = Instance.new("Frame", FB)
ChibiRoot.Size = UDim2.new(0.85, 0, 0.85, 0)
ChibiRoot.AnchorPoint = Vector2.new(0.5, 0.5)
ChibiRoot.Position = UDim2.new(0.5, 0, 0.5, 0)
ChibiRoot.BackgroundTransparency = 1
ChibiRoot.ClipsDescendants = true
ChibiRoot.ZIndex = 3

local Pixels = {}
local currentCharacter = CFG.UI.character

local function CreateChibiGrid()
    -- Очистить старое
    for _, p in pairs(Pixels) do
        for _, px in pairs(p) do
            if px and px.Parent then px:Destroy() end
        end
    end
    Pixels = {}
    
    local charData = GetCurrentCharacter()
    local rows = #charData.idle
    local cols = #charData.idle[1]
    local cellW = 1 / cols
    local cellH = 1 / rows
    
    for y = 1, rows do
        Pixels[y] = {}
        for x = 1, cols do
            local px = Instance.new("Frame", ChibiRoot)
            px.Size = UDim2.new(cellW, 0, cellH, 0)
            px.Position = UDim2.new((x-1)*cellW, 0, (y-1)*cellH, 0)
            px.BorderSizePixel = 0
            px.BackgroundTransparency = 1
            px.ZIndex = 3
            Pixels[y][x] = px
        end
    end
end

local function RenderChibiFrame(frameName)
    local charData = GetCurrentCharacter()
    local frame = charData[frameName] or charData.idle
    local colors = charData.colors
    for y = 1, #frame do
        local row = frame[y]
        for x = 1, #row do
            local ch = string.sub(row, x, x)
            local col = colors[ch]
            local px = Pixels[y] and Pixels[y][x]
            if px then
                if col then
                    px.BackgroundColor3 = col
                    px.BackgroundTransparency = 0
                else
                    px.BackgroundTransparency = 1
                end
            end
        end
    end
end

CreateChibiGrid()
RenderChibiFrame("idle")

-- ═══════════════════════════════════════════════════════════════════════════
-- [09/30] АНИМАЦИИ ЧИБИ
-- ═══════════════════════════════════════════════════════════════════════════
task.spawn(function()
    local breathT = 0
    local blinkTimer = 0
    local blinkDuration = 0.15
    local isBlinking = false
    local nextBlink = math.random(20, 40) / 10
    local smileTimer = 0
    local isSmiling = false
    local nextSmile = math.random(50, 100) / 10
    
    while Alive do
        local dt = RunService.Heartbeat:Wait()
        if not FB.Visible then continue end
        
        breathT = breathT + dt * 2
        blinkTimer = blinkTimer + dt
        smileTimer = smileTimer + dt
        
        -- Дыхание
        local breathScale = 1 + math.sin(breathT) * 0.04
        ChibiRoot.Size = UDim2.new(0.85 * breathScale, 0, 0.85 * breathScale, 0)
        
        -- Покачивание
        local sway = math.sin(breathT * 0.7) * 2
        local bob = math.sin(breathT) * -2
        ChibiRoot.Position = UDim2.new(0.5, sway, 0.5, bob)
        
        -- Моргание
        if not isBlinking and not isSmiling and blinkTimer > nextBlink then
            isBlinking = true
            RenderChibiFrame("blink")
            blinkTimer = 0
        elseif isBlinking and blinkTimer > blinkDuration then
            isBlinking = false
            RenderChibiFrame("idle")
            blinkTimer = 0
            nextBlink = math.random(20, 50) / 10
        end
        
        -- Улыбка (иногда)
        if not isSmiling and not isBlinking and smileTimer > nextSmile then
            isSmiling = true
            RenderChibiFrame("smile")
            smileTimer = 0
        elseif isSmiling and smileTimer > 1.2 then
            isSmiling = false
            RenderChibiFrame("idle")
            smileTimer = 0
            nextSmile = math.random(50, 100) / 10
        end
    end
end)

-- Пульсация размера кнопки
task.spawn(function()
    local t = 0
    while Alive do
        local dt = RunService.Heartbeat:Wait()
        if not FB.Visible then continue end
        t = t + dt
        local scale = 1.1 + math.sin(t * 2) * 0.05
        FB.Size = UDim2.new(0, 130 * scale, 0, 130 * scale)
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- [10/30] ГЛАВНОЕ МЕНЮ (с градиентами и бликами)
-- ═══════════════════════════════════════════════════════════════════════════
local M = Instance.new("Frame", SG)
M.Name = "MainPanel"
if IS_MOBILE then
    M.Size = UDim2.new(1, -20, 1, -100)
    M.AnchorPoint = Vector2.new(0.5, 0.5)
    M.Position = UDim2.new(0.5, 0, 0.5, -10)
else
    M.Size = UDim2.new(0, 620, 0, 520)
    M.AnchorPoint = Vector2.new(0.5, 0.5)
    M.Position = UDim2.new(0.5, 0, 0.5, 0)
end
M.BackgroundColor3 = CFG.Bg
M.BorderSizePixel = 0
M.Active = true
M.Visible = false
M.ClipsDescendants = false
UX.corner(M, 18)
local MainStroke = UX.stroke(M, CFG.Theme, 2.5)

local MUIScale = Instance.new("UIScale", M)
MUIScale.Scale = 1

-- Градиент
local MG = Instance.new("UIGradient", M)
MG.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 16, 26)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(13, 13, 18)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(24, 14, 22)),
})
MG.Rotation = 45

-- Плавающие розовые блики
local Blob1 = Instance.new("Frame", M)
Blob1.Size = UDim2.new(0, 220, 0, 220)
Blob1.Position = UDim2.new(0, -70, 0, -50)
Blob1.BackgroundColor3 = CFG.Theme
Blob1.BackgroundTransparency = 0.88
Blob1.BorderSizePixel = 0
Blob1.ZIndex = 1
UX.corner(Blob1, 999)

local Blob2 = Instance.new("Frame", M)
Blob2.Size = UDim2.new(0, 200, 0, 200)
Blob2.Position = UDim2.new(1, -130, 1, -90)
Blob2.BackgroundColor3 = CFG.Accent
Blob2.BackgroundTransparency = 0.9
Blob2.BorderSizePixel = 0
Blob2.ZIndex = 1
UX.corner(Blob2, 999)

local Blob3 = Instance.new("Frame", M)
Blob3.Size = UDim2.new(0, 140, 0, 140)
Blob3.Position = UDim2.new(0.5, -70, 0.5, -70)
Blob3.BackgroundColor3 = Color3.fromRGB(180, 100, 255)
Blob3.BackgroundTransparency = 0.93
Blob3.BorderSizePixel = 0
Blob3.ZIndex = 1
UX.corner(Blob3, 999)

task.spawn(function()
    local t = 0
    while Alive do
        local dt = RunService.Heartbeat:Wait()
        if not M.Visible then continue end
        t = t + dt
        Blob1.Position = UDim2.new(0, -70 + math.sin(t*0.4)*25, 0, -50 + math.cos(t*0.6)*20)
        Blob2.Position = UDim2.new(1, -130 + math.cos(t*0.5)*25, 1, -90 + math.sin(t*0.4)*20)
        Blob3.Position = UDim2.new(0.5, -70 + math.sin(t*0.3)*30, 0.5, -70 + math.cos(t*0.5)*25)
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- [11/30] HEADER (верхняя ручка для драга)
-- ═══════════════════════════════════════════════════════════════════════════
local H = Instance.new("Frame", M)
H.Name = "HeaderDrag"
H.Size = UDim2.new(1, 0, 0, IS_MOBILE and 62 or 58)
H.BackgroundColor3 = CFG.Header
H.BackgroundTransparency = 0.05
H.BorderSizePixel = 0
H.ZIndex = 10
UX.corner(H, 18)

local HG = Instance.new("UIGradient", H)
HG.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(42, 32, 48)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(30, 24, 36)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(24, 20, 32)),
})
HG.Rotation = 90

local HLine = Instance.new("Frame", H)
HLine.Size = UDim2.new(1, -40, 0, 2)
HLine.Position = UDim2.new(0, 20, 1, -2)
HLine.BackgroundColor3 = CFG.Theme
HLine.BorderSizePixel = 0
HLine.ZIndex = 10
UX.corner(HLine, 999)

-- Индикатор драга сверху
local DragHintTop = Instance.new("Frame", H)
DragHintTop.Size = UDim2.new(0, 50, 0, 5)
DragHintTop.Position = UDim2.new(0.5, -25, 0, 8)
DragHintTop.BackgroundColor3 = Color3.fromRGB(130, 130, 150)
DragHintTop.BackgroundTransparency = 0.3
DragHintTop.BorderSizePixel = 0
DragHintTop.ZIndex = 15
UX.corner(DragHintTop, 999)

-- Логотип слева
local Logo = Instance.new("TextLabel", H)
Logo.Size = UDim2.new(0, 30, 0, 30)
Logo.Position = UDim2.new(0, 18, 0.5, -15)
Logo.BackgroundTransparency = 1
Logo.Text = "🎀"
Logo.TextColor3 = CFG.Theme
Logo.Font = Enum.Font.GothamBold
Logo.TextSize = 22
Logo.ZIndex = 11

local Title = Instance.new("TextLabel", H)
Title.Size = UDim2.new(1, -220, 1, 0)
Title.Position = UDim2.new(0, 54, 0, 0)
Title.Text = "ZERO <font color='#FF2B5A'>TWO</font> <font color='#A0A0A5'>v4.0</font>"
Title.RichText = true
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = IS_MOBILE and 17 or 15
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
Title.ZIndex = 11

-- Кнопка "−" (свернуть в header)
local MinBtn = Instance.new("TextButton", H)
MinBtn.Size = UDim2.new(0, IS_MOBILE and 48 or 42, 0, IS_MOBILE and 48 or 42)
MinBtn.Position = UDim2.new(1, IS_MOBILE and -160 or -142, 0.5, IS_MOBILE and -24 or -21)
MinBtn.BackgroundColor3 = Color3.fromRGB(48, 48, 62)
MinBtn.Text = "−"
MinBtn.TextColor3 = Color3.fromRGB(230, 230, 240)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = IS_MOBILE and 24 or 20
MinBtn.ZIndex = 12
UX.corner(MinBtn, 12)
UX.ripple(MinBtn)

-- Кнопка "▼" (скрыть в аниме-тянку)
local HideBtn = Instance.new("TextButton", H)
HideBtn.Size = UDim2.new(0, IS_MOBILE and 48 or 42, 0, IS_MOBILE and 48 or 42)
HideBtn.Position = UDim2.new(1, IS_MOBILE and -108 or -94, 0.5, IS_MOBILE and -24 or -21)
HideBtn.BackgroundColor3 = Color3.fromRGB(48, 48, 62)
HideBtn.Text = "▼"
HideBtn.TextColor3 = Color3.fromRGB(230, 230, 240)
HideBtn.Font = Enum.Font.GothamBold
HideBtn.TextSize = IS_MOBILE and 18 or 15
HideBtn.ZIndex = 12
UX.corner(HideBtn, 12)
UX.ripple(HideBtn)

-- Кнопка "✕"
local CloseBtn = Instance.new("TextButton", H)
CloseBtn.Size = UDim2.new(0, IS_MOBILE and 48 or 42, 0, IS_MOBILE and 48 or 42)
CloseBtn.Position = UDim2.new(1, IS_MOBILE and -56 or -48, 0.5, IS_MOBILE and -24 or -21)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 43, 90)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = IS_MOBILE and 20 or 16
CloseBtn.ZIndex = 12
UX.corner(CloseBtn, 12)
UX.ripple(CloseBtn)

-- ═══════════════════════════════════════════════════════════════════════════
-- [12/30] ПАНЕЛЬ ВКЛАДОК
-- ═══════════════════════════════════════════════════════════════════════════
local TBScroll = Instance.new("ScrollingFrame", M)
TBScroll.Name = "TabBar"
TBScroll.Size = UDim2.new(1, -20, 0, IS_MOBILE and 54 or 44)
TBScroll.Position = UDim2.new(0, 10, 0, IS_MOBILE and 72 or 66)
TBScroll.BackgroundColor3 = Color3.fromRGB(20, 18, 26)
TBScroll.BorderSizePixel = 0
TBScroll.ScrollBarThickness = 0
TBScroll.ScrollingDirection = Enum.ScrollingDirection.X
TBScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
TBScroll.AutomaticCanvasSize = Enum.AutomaticSize.X
TBScroll.ScrollBarImageTransparency = 1
TBScroll.ZIndex = 5
UX.corner(TBScroll, 12)

local TB = Instance.new("Frame", TBScroll)
TB.Size = UDim2.new(0, 0, 1, 0)
TB.BackgroundTransparency = 1
TB.AutomaticSize = Enum.AutomaticSize.X

local TL = Instance.new("UIListLayout", TB)
TL.FillDirection = Enum.FillDirection.Horizontal
TL.Padding = UDim.new(0, 6)
TL.SortOrder = Enum.SortOrder.LayoutOrder
TL.VerticalAlignment = Enum.VerticalAlignment.Center

local TPad = Instance.new("UIPadding", TB)
TPad.PaddingLeft = UDim.new(0, 6)
TPad.PaddingRight = UDim.new(0, 6)

-- ═══════════════════════════════════════════════════════════════════════════
-- [13/30] КОНТЕЙНЕР СТРАНИЦ
-- ═══════════════════════════════════════════════════════════════════════════
local Cont = Instance.new("ScrollingFrame", M)
Cont.Name = "Content"
Cont.Size = UDim2.new(1, -20, 1, IS_MOBILE and -230 or -200)
Cont.Position = UDim2.new(0, 10, 0, IS_MOBILE and 132 or 118)
Cont.BackgroundTransparency = 1
Cont.BorderSizePixel = 0
Cont.CanvasSize = UDim2.new(0, 0, 0, 700)
Cont.ScrollBarThickness = IS_MOBILE and 6 or 4
Cont.ScrollBarImageColor3 = CFG.Theme
Cont.ScrollingDirection = Enum.ScrollingDirection.Y
Cont.ZIndex = 5

-- ═══════════════════════════════════════════════════════════════════════════
-- [14/30] FOOTER (нижняя ручка для драга)
-- ═══════════════════════════════════════════════════════════════════════════
local Foot = Instance.new("Frame", M)
Foot.Name = "FooterDrag"
Foot.Size = UDim2.new(1, 0, 0, 44)
Foot.Position = UDim2.new(0, 0, 1, -44)
Foot.BackgroundColor3 = Color3.fromRGB(24, 20, 30)
Foot.BackgroundTransparency = 0.1
Foot.BorderSizePixel = 0
Foot.ZIndex = 10
UX.corner(Foot, 18)

local DragHintBot = Instance.new("Frame", Foot)
DragHintBot.Size = UDim2.new(0, 60, 0, 5)
DragHintBot.Position = UDim2.new(0.5, -30, 1, -10)
DragHintBot.BackgroundColor3 = Color3.fromRGB(130, 130, 150)
DragHintBot.BackgroundTransparency = 0.3
DragHintBot.BorderSizePixel = 0
DragHintBot.ZIndex = 15
UX.corner(DragHintBot, 999)

local FText = Instance.new("TextLabel", Foot)
FText.Size = UDim2.new(1, 0, 1, -12)
FText.Position = UDim2.new(0, 0, 0, 0)
FText.BackgroundTransparency = 1
FText.Text = "🎀 Zero Two Ultimate · v4.0 · Mobile"
FText.TextColor3 = Color3.fromRGB(180, 150, 180)
FText.Font = Enum.Font.Gotham
FText.TextSize = 11
FText.TextXAlignment = Enum.TextXAlignment.Center
FText.ZIndex = 11

-- ═══════════════════════════════════════════════════════════════════════════
-- [15/30] ДРАГ СИСТЕМА (за header и footer)
-- ═══════════════════════════════════════════════════════════════════════════
local function EnableDrag(zone)
    local dragging, dragStart, startPos = false, nil, nil
    zone.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch
           or i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = i.Position
            startPos = M.Position
            Vibrate(0.3)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if not dragging or not Alive then return end
        if i.UserInputType == Enum.UserInputType.Touch
           or i.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = i.Position - dragStart
            M.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch
           or i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

EnableDrag(H)
EnableDrag(Foot)

-- ═══════════════════════════════════════════════════════════════════════════
-- [16/30] ФАБРИКИ UI
-- ═══════════════════════════════════════════════════════════════════════════

-- Кнопка-тумблер
function CreateToggle(parent, text, default, cb)
    local F = Instance.new("Frame", parent)
    F.Size = UDim2.new(1, 0, 0, IS_MOBILE and 58 or 52)
    F.BackgroundColor3 = CFG.Card
    F.BorderSizePixel = 0
    F.ZIndex = 6
    UX.corner(F, 12)
    UX.stroke(F, CFG.Border, 1)
    
    local L = Instance.new("TextLabel", F)
    L.Size = UDim2.new(0.62, 0, 1, 0)
    L.Position = UDim2.new(0, 18, 0, 0)
    L.Text = text
    L.TextColor3 = CFG.Text
    L.Font = Enum.Font.GothamSemibold
    L.TextSize = IS_MOBILE and 14 or 13
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.TextWrapped = true
    L.BackgroundTransparency = 1
    L.ZIndex = 7
    
    local C = Instance.new("TextButton", F)
    C.Size = UDim2.new(0, IS_MOBILE and 62 or 52, 0, IS_MOBILE and 34 or 30)
    C.Position = UDim2.new(1, IS_MOBILE and -78 or -68, 0.5, IS_MOBILE and -17 or -15)
    C.BackgroundColor3 = default and CFG.Theme or Color3.fromRGB(45, 45, 60)
    C.Text = ""
    C.ZIndex = 7
    UX.corner(C, 999)
    local cStroke = UX.stroke(C, default and CFG.Theme or Color3.fromRGB(45, 45, 60), 1, default and 0 or 1)
    
    local Ind = Instance.new("Frame", C)
    Ind.Size = UDim2.new(0, IS_MOBILE and 26 or 24, 0, IS_MOBILE and 26 or 24)
    Ind.Position = default and UDim2.new(1, IS_MOBILE and -29 or -27, 0.5, IS_MOBILE and -13 or -12)
                        or UDim2.new(0, 4, 0.5, IS_MOBILE and -13 or -12)
    Ind.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Ind.ZIndex = 8
    UX.corner(Ind, 999)
    
    local state = default
    C.MouseButton1Click:Connect(function()
        if not Alive then return end
        PlayClick()
        state = not state
        local tc = state and CFG.Theme or Color3.fromRGB(45, 45, 60)
        local tp = state and UDim2.new(1, IS_MOBILE and -29 or -27, 0.5, IS_MOBILE and -13 or -12)
                        or UDim2.new(0, 4, 0.5, IS_MOBILE and -13 or -12)
        TweenService:Create(C, TweenInfo.new(0.25), {BackgroundColor3 = tc}):Play()
        TweenService:Create(cStroke, TweenInfo.new(0.25), {Color = tc, Transparency = state and 0 or 1}):Play()
        TweenService:Create(Ind, TweenInfo.new(0.28, Enum.EasingStyle.Back), {Position = tp}):Play()
        cb(state)
    end)
    UX.ripple(C)
    return C
end

-- Слайдер
function CreateSlider(parent, text, min, max, default, cb)
    local F = Instance.new("Frame", parent)
    F.Size = UDim2.new(1, 0, 0, IS_MOBILE and 80 or 68)
    F.BackgroundColor3 = CFG.Card
    F.BorderSizePixel = 0
    F.ZIndex = 6
    UX.corner(F, 12)
    UX.stroke(F, CFG.Border, 1)
    
    local L = Instance.new("TextLabel", F)
    L.Size = UDim2.new(0.9, 0, 0, 30)
    L.Position = UDim2.new(0, 18, 0, 6)
    L.Text = text .. ": <font color='#FF2B5A'>" .. tostring(default) .. "</font>"
    L.RichText = true
    L.TextColor3 = CFG.Text
    L.Font = Enum.Font.GothamSemibold
    L.TextSize = IS_MOBILE and 14 or 13
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.BackgroundTransparency = 1
    L.ZIndex = 7
    
    local T = Instance.new("Frame", F)
    T.Size = UDim2.new(1, -36, 0, IS_MOBILE and 14 or 10)
    T.Position = UDim2.new(0, 18, 0, IS_MOBILE and 54 or 46)
    T.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    T.BorderSizePixel = 0
    T.ZIndex = 7
    UX.corner(T, 999)
    
    local Fill = Instance.new("Frame", T)
    Fill.Size = UDim2.new((default - min) / math.max(1, (max - min)), 0, 1, 0)
    Fill.BackgroundColor3 = CFG.Theme
    Fill.BorderSizePixel = 0
    Fill.ZIndex = 8
    UX.corner(Fill, 999)
    
    local FillG = Instance.new("UIGradient", Fill)
    FillG.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, CFG.Theme),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 100, 180)),
    })
    
    local KnobSize = IS_MOBILE and 32 or 26
    local Knob = Instance.new("Frame", T)
    Knob.Size = UDim2.new(0, KnobSize, 0, KnobSize)
    Knob.AnchorPoint = Vector2.new(0.5, 0.5)
    Knob.Position = UDim2.new(Fill.Size.X.Scale, 0, 0.5, 0)
    Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Knob.BorderSizePixel = 0
    Knob.ZIndex = 9
    UX.corner(Knob, 999)
    UX.stroke(Knob, CFG.Theme, 2)
    
    local TBtn = Instance.new("TextButton", T)
    TBtn.Size = UDim2.new(1, 0, 3, 0)
    TBtn.Position = UDim2.new(0, 0, -1, 0)
    TBtn.BackgroundTransparency = 1
    TBtn.Text = ""
    TBtn.ZIndex = 10
    
    local sliding = false
    local function proc(input)
        local ts = T.AbsoluteSize.X
        if ts == 0 then return end
        local x = math.clamp(input.Position.X - T.AbsolutePosition.X, 0, ts)
        local ratio = x / ts
        local value = math.round(min + (ratio * (max - min)))
        Fill.Size = UDim2.new(ratio, 0, 1, 0)
        Knob.Position = UDim2.new(ratio, 0, 0.5, 0)
        L.Text = text .. ": <font color='#FF2B5A'>" .. tostring(value) .. "</font>"
        cb(value)
    end
    
    TBtn.InputBegan:Connect(function(input)
        if not Alive then return end
        if input.UserInputType == Enum.UserInputType.Touch
           or input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliding = true
            proc(input)
            TweenService:Create(Knob, TweenInfo.new(0.15), {
                Size = UDim2.new(0, KnobSize + 6, 0, KnobSize + 6)
            }):Play()
            Vibrate(0.3)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if sliding and Alive and (input.UserInputType == Enum.UserInputType.Touch
           or input.UserInputType == Enum.UserInputType.MouseMovement) then
            proc(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
           or input.UserInputType == Enum.UserInputType.MouseButton1 then
            if sliding then
                sliding = false
                TweenService:Create(Knob, TweenInfo.new(0.15), {
                    Size = UDim2.new(0, KnobSize, 0, KnobSize)
                }):Play()
            end
        end
    end)
end

-- Заголовок секции
function CreateSection(parent, titleText)
    local Holder = Instance.new("Frame", parent)
    Holder.Size = UDim2.new(1, 0, 0, IS_MOBILE and 34 or 28)
    Holder.BackgroundTransparency = 1
    Holder.ZIndex = 6
    
    local Accent = Instance.new("Frame", Holder)
    Accent.Size = UDim2.new(0, 3, 0, 16)
    Accent.Position = UDim2.new(0, 4, 0.5, -8)
    Accent.BackgroundColor3 = CFG.Theme
    Accent.BorderSizePixel = 0
    Accent.ZIndex = 7
    UX.corner(Accent, 999)
    
    local L = Instance.new("TextLabel", Holder)
    L.Size = UDim2.new(1, -20, 1, 0)
    L.Position = UDim2.new(0, 16, 0, 0)
    L.BackgroundTransparency = 1
    L.Text = titleText
    L.TextColor3 = Color3.fromRGB(255, 130, 170)
    L.Font = Enum.Font.GothamBold
    L.TextSize = IS_MOBILE and 14 or 13
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.TextStrokeTransparency = 0.85
    L.TextStrokeColor3 = Color3.fromRGB(60, 20, 40)
    L.ZIndex = 7
    return Holder
end

-- Кнопка действия
function CreateBtn(parent, text, bg, cb)
    local B = Instance.new("TextButton", parent)
    B.Size = UDim2.new(1, 0, 0, IS_MOBILE and 52 or 44)
    B.BackgroundColor3 = bg or Color3.fromRGB(34, 34, 46)
    B.Text = text
    B.TextColor3 = Color3.fromRGB(240, 240, 245)
    B.Font = Enum.Font.GothamBold
    B.TextSize = IS_MOBILE and 13 or 12
    B.ZIndex = 6
    UX.corner(B, 12)
    UX.stroke(B, CFG.Border, 1)
    UX.ripple(B)
    
    local ot = text
    local oc = bg or Color3.fromRGB(34, 34, 46)
    B.MouseButton1Click:Connect(function()
        if not Alive then return end
        PlayClick()
        B.Text = "⏳ Выполняется..."
        B.TextColor3 = Color3.fromRGB(255, 200, 100)
        TweenService:Create(B, TweenInfo.new(0.1), {BackgroundColor3 = CFG.Theme}):Play()
        task.spawn(function()
            pcall(cb)
            task.wait(0.4)
            if B and B.Parent then
                B.Text = ot
                B.TextColor3 = Color3.fromRGB(240, 240, 245)
                TweenService:Create(B, TweenInfo.new(0.2), {BackgroundColor3 = oc}):Play()
            end
        end)
    end)
    return B
end

-- Карточка
function CreateCard(parent, h)
    local C = Instance.new("Frame", parent)
    C.Size = UDim2.new(1, 0, 0, h or 90)
    C.BackgroundColor3 = CFG.Card
    C.BorderSizePixel = 0
    C.ZIndex = 6
    UX.corner(C, 12)
    UX.stroke(C, CFG.Border, 1)
    return C
end

-- Метка
function CreateLabel(parent, text, yPos, rich)
    local L = Instance.new("TextLabel", parent)
    L.Size = UDim2.new(1, -28, 0, 28)
    L.Position = UDim2.new(0, 16, 0, yPos)
    L.BackgroundTransparency = 1
    L.Text = text
    L.RichText = rich ~= false
    L.TextColor3 = CFG.Text
    L.Font = Enum.Font.GothamSemibold
    L.TextSize = IS_MOBILE and 14 or 13
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.ZIndex = 7
    return L
end

-- Выпадающий список
function CreateDropdown(parent, text, options, default, cb)
    local F = Instance.new("Frame", parent)
    F.Size = UDim2.new(1, 0, 0, IS_MOBILE and 58 or 52)
    F.BackgroundColor3 = CFG.Card
    F.BorderSizePixel = 0
    F.ClipsDescendants = false
    F.ZIndex = 6
    UX.corner(F, 12)
    UX.stroke(F, CFG.Border, 1)
    
    local L = Instance.new("TextLabel", F)
    L.Size = UDim2.new(0.55, 0, 1, 0)
    L.Position = UDim2.new(0, 18, 0, 0)
    L.Text = text
    L.TextColor3 = CFG.Text
    L.Font = Enum.Font.GothamSemibold
    L.TextSize = IS_MOBILE and 14 or 13
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.BackgroundTransparency = 1
    L.ZIndex = 7
    
    local Cur = Instance.new("TextButton", F)
    Cur.Size = UDim2.new(0, 140, 0, IS_MOBILE and 36 or 32)
    Cur.Position = UDim2.new(1, -158, 0.5, IS_MOBILE and -18 or -16)
    Cur.BackgroundColor3 = Color3.fromRGB(38, 38, 52)
    Cur.Text = default
    Cur.TextColor3 = Color3.fromRGB(255, 200, 220)
    Cur.Font = Enum.Font.GothamBold
    Cur.TextSize = IS_MOBILE and 12 or 11
    Cur.ZIndex = 8
    UX.corner(Cur, 8)
    UX.ripple(Cur)
    
    local Open = false
    local listFrame
    
    Cur.MouseButton1Click:Connect(function()
        if not Alive then return end
        PlayClick()
        Open = not Open
        if Open then
            if listFrame then listFrame:Destroy() end
            listFrame = Instance.new("Frame", F)
            listFrame.Size = UDim2.new(0, 140, 0, #options * 32 + 8)
            listFrame.Position = UDim2.new(1, -158, 1, 4)
            listFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
            listFrame.BorderSizePixel = 0
            listFrame.ZIndex = 100
            UX.corner(listFrame, 8)
            UX.stroke(listFrame, CFG.Theme, 1)
            
            for i, opt in ipairs(options) do
                local OBtn = Instance.new("TextButton", listFrame)
                OBtn.Size = UDim2.new(1, -8, 0, 30)
                OBtn.Position = UDim2.new(0, 4, 0, 4 + (i-1) * 32)
                OBtn.BackgroundColor3 = (opt == default) and CFG.Theme or Color3.fromRGB(38, 38, 52)
                OBtn.Text = tostring(opt)
                OBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                OBtn.Font = Enum.Font.Gotham
                OBtn.TextSize = 11
                OBtn.ZIndex = 101
                UX.corner(OBtn, 6)
                OBtn.MouseButton1Click:Connect(function()
                    PlayClick()
                    Cur.Text = tostring(opt)
                    if listFrame then listFrame:Destroy(); listFrame = nil end
                    Open = false
                    cb(opt)
                end)
            end
        else
            if listFrame then listFrame:Destroy(); listFrame = nil end
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════
-- [17/30] СИСТЕМА ВКЛАДОК
-- ═══════════════════════════════════════════════════════════════════════════
local TAB_NAMES = {
    Aim     = "🎯 Аймбот",
    Combat  = "⚔ Бой",
    Move    = "🏃 Движение",
    Visual  = "👁 Визуал",
    Graphics= "🎨 Графика",
    Network = "📡 Сеть",
    Protect = "🛡 Защита",
    Chat    = "💬 Чат",
    Settings= "⚙️ Настройки",
}
local Tabs = {}
local Pages = {}
local ActiveTabName = "Aim"

local function CreateTabBtn(name, order)
    local TBtn = Instance.new("TextButton")
    TBtn.Size = UDim2.new(0, IS_MOBILE and 115 or 90, 0, IS_MOBILE and 44 or 34)
    TBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    TBtn.Text = TAB_NAMES[name] or name
    TBtn.TextColor3 = Color3.fromRGB(200, 200, 215)
    TBtn.Font = Enum.Font.GothamSemibold
    TBtn.TextSize = IS_MOBILE and 13 or 11
    TBtn.LayoutOrder = order
    TBtn.Parent = TB
    UX.corner(TBtn, 10)
    UX.ripple(TBtn)
    return TBtn
end

local function CreateTabPage(name)
    local P = Instance.new("Frame", Cont)
    P.Name = "Page_" .. name
    P.Size = UDim2.new(1, 0, 1, 0)
    P.BackgroundTransparency = 1
    P.Visible = (name == ActiveTabName)
    P.ZIndex = 6
    local PL = Instance.new("UIListLayout", P)
    PL.SortOrder = Enum.SortOrder.LayoutOrder
    PL.Padding = UDim.new(0, 10)
    PL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        if Alive and Cont and P.Visible then
            Cont.CanvasSize = UDim2.new(0, 0, 0, PL.AbsoluteContentSize.Y + 20)
        end
    end)
    return P, PL
end

for _, n in ipairs({"Aim","Combat","Move","Visual","Graphics","Network","Protect","Chat","Settings"}) do
    local b = CreateTabBtn(n, #Tabs + 1)
    local pg, ly = CreateTabPage(n)
    Tabs[n] = {Button = b, Page = pg, Layout = ly}
    Pages[n] = pg
end

function SwitchTab(name)
    if not Tabs[name] then return end
    for tn, td in pairs(Tabs) do
        local isA = (tn == name)
        td.Page.Visible = isA
        TweenService:Create(td.Button, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
            BackgroundColor3 = isA and CFG.Theme or Color3.fromRGB(30, 30, 40)
        }):Play()
        td.Button.TextColor3 = isA and Color3.fromRGB(255, 255, 255)
                                    or Color3.fromRGB(200, 200, 215)
    end
    ActiveTabName = name
    CFG.UI.activeTab = name
    Cont.CanvasSize = UDim2.new(0, 0, 0, Tabs[name].Layout.AbsoluteContentSize.Y + 20)
    Cont.CanvasPosition = Vector2.new(0, 0)
end

for tn, td in pairs(Tabs) do
    td.Button.MouseButton1Click:Connect(function()
        if Alive then PlayClick(); SwitchTab(tn) end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════
-- [18/30] 🎯 АЙМБОТ (полный, настраиваемый)
-- ═══════════════════════════════════════════════════════════════════════════
local AimBot = { currentTarget = nil, lastFireTime = 0, targetLockTime = 0 }

local function GetAimTarget()
    if not CFG.Aim.on then return nil end
    local cam = Workspace.CurrentCamera
    if not cam then return nil end
    local mr = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not mr then return nil end
    local myPos = mr.Position
    local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    
    local best, bestScore = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                -- Проверка команды
                if CFG.Aim.teamCheck and p.Team and LocalPlayer.Team and p.Team == LocalPlayer.Team then
                    continue
                end
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local dist = (myPos - hrp.Position).Magnitude
                    if dist <= CFG.Aim.maxDist then
                        local part = p.Character:FindFirstChild(CFG.Aim.targetPart)
                        if part then
                            local skip = false
                            -- Проверка стен
                            if CFG.Aim.wallCheck or CFG.Aim.onlyVisible then
                                local ok, visible = pcall(function()
                                    local ray = Ray.new(cam.CFrame.Position,
                                        (part.Position - cam.CFrame.Position).Unit * 500)
                                    local hit = Workspace:FindPartOnRay(ray, LocalPlayer.Character)
                                    return hit and (hit == part or hit:IsDescendantOf(p.Character))
                                end)
                                if ok and not visible then skip = true end
                            end
                            if not skip then
                                local screenPos, onScreen = cam:WorldToViewportPoint(part.Position)
                                if onScreen then
                                    local fovDist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                                    if fovDist <= CFG.Aim.fov then
                                        local score = fovDist
                                        if CFG.Aim.priority == "Distance" then score = dist
                                        elseif CFG.Aim.priority == "Health" then score = hum.Health
                                        end
                                        if score < bestScore then
                                            bestScore = score
                                            best = {
                                                part = part,
                                                player = p,
                                                dist = dist,
                                                screenPos = Vector2.new(screenPos.X, screenPos.Y),
                                                velocity = hrp.AssemblyLinearVelocity,
                                                health = hum.Health,
                                            }
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return best
end

-- FOV круг
local AimFOVCircle = Instance.new("Frame", SG)
AimFOVCircle.Size = UDim2.new(0, 300, 0, 300)
AimFOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
AimFOVCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
AimFOVCircle.BackgroundTransparency = 1
AimFOVCircle.Visible = false
AimFOVCircle.ZIndex = 4
UX.corner(AimFOVCircle, 999)
local AimFOVStroke = UX.stroke(AimFOVCircle, CFG.Theme, 1.5, 0.5)

-- Линия к цели
local AimTargetLine = Instance.new("Frame", SG)
AimTargetLine.Size = UDim2.new(0, 100, 0, 1)
AimTargetLine.Position = UDim2.new(0.5, 0, 0.5, 0)
AimTargetLine.BackgroundColor3 = CFG.Success
AimTargetLine.BorderSizePixel = 0
AimTargetLine.AnchorPoint = Vector2.new(0, 0.5)
AimTargetLine.Visible = false
AimTargetLine.ZIndex = 4

-- Основной цикл аймбота
RunService.RenderStepped:Connect(function()
    if not Alive then return end
    
    -- FOV круг
    if CFG.Aim.on and CFG.Aim.showFOVCircle then
        AimFOVCircle.Visible = true
        AimFOVCircle.Size = UDim2.new(0, CFG.Aim.fov * 2, 0, CFG.Aim.fov * 2)
        AimFOVStroke.Transparency = 0.4 + math.sin(tick() * 3) * 0.2
        if AimBot.currentTarget then
            AimFOVStroke.Color = CFG.Success
        else
            AimFOVStroke.Color = CFG.Theme
        end
    else
        AimFOVCircle.Visible = false
    end
    
    if not CFG.Aim.on then 
        AimTargetLine.Visible = false
        AimBot.currentTarget = nil
        return 
    end
    
    local cam = Workspace.CurrentCamera
    if not cam then return end
    
    -- Target Lock (не переключаться между целями слишком быстро)
    local target = nil
    if CFG.Aim.targetLock and AimBot.currentTarget and (tick() - AimBot.targetLockTime) < CFG.Aim.lockTime then
        -- Проверяем, что предыдущая цель ещё жива
        if AimBot.currentTarget.player.Character then
            local hum = AimBot.currentTarget.player.Character:FindFirstChildOfClass("Humanoid")
            local part = AimBot.currentTarget.player.Character:FindFirstChild(CFG.Aim.targetPart)
            if hum and hum.Health > 0 and part then
                target = AimBot.currentTarget
            end
        end
    end
    
    if not target then
        target = GetAimTarget()
        if target then
            AimBot.currentTarget = target
            AimBot.targetLockTime = tick()
        end
    else
        -- Обновляем данные о текущей цели
        target = GetAimTarget() or AimBot.currentTarget
    end
    
    AimBot.currentTarget = target
    if not target then
        AimTargetLine.Visible = false
        return
    end
    
    -- Предсказание
    local targetPos = target.part.Position
    if CFG.Aim.prediction > 0 then
        targetPos = targetPos + target.velocity * CFG.Aim.prediction
    end
    
    -- Режимы наведения
    if CFG.Aim.mode == "Camera" then
        local goal = CFrame.new(cam.CFrame.Position, targetPos)
        cam.CFrame = cam.CFrame:Lerp(goal, CFG.Aim.smooth)
    elseif CFG.Aim.mode == "Instant" then
        cam.CFrame = CFrame.new(cam.CFrame.Position, targetPos)
    elseif CFG.Aim.mode == "Smooth" then
        local goal = CFrame.new(cam.CFrame.Position, targetPos)
        cam.CFrame = cam.CFrame:Lerp(goal, CFG.Aim.smooth * 0.5)
    elseif CFG.Aim.mode == "Prediction" then
        -- Усиленное предсказание
        targetPos = target.part.Position + target.velocity * (CFG.Aim.prediction * 2)
        local goal = CFrame.new(cam.CFrame.Position, targetPos)
        cam.CFrame = cam.CFrame:Lerp(goal, CFG.Aim.smooth)
    end
    
    -- Линия к цели
    if CFG.Aim.showTargetLine then
        AimTargetLine.Visible = true
        local sp = target.screenPos
        local screenCenter = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
        local diff = sp - screenCenter
        local dist = diff.Magnitude
        local angle = math.atan2(diff.Y, diff.X)
        AimTargetLine.Size = UDim2.new(0, dist, 0, 1)
        AimTargetLine.Position = UDim2.new(0.5, 0, 0.5, 0)
        AimTargetLine.Rotation = math.deg(angle)
        AimTargetLine.BackgroundColor3 = CFG.Success
    else
        AimTargetLine.Visible = false
    end
    
    -- Авто-выстрел
    if CFG.Aim.autoFire then
        local now = tick()
        if now - AimBot.lastFireTime >= CFG.Aim.autoFireDelay then
            AimBot.lastFireTime = now
            pcall(function()
                if VirtualUser then
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton1(Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2))
                end
            end)
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- [19/30] UI: АЙМБОТ
-- ═══════════════════════════════════════════════════════════════════════════
local aP = Pages["Aim"]
CreateSection(aP, "🎯 ОСНОВНЫЕ НАСТРОЙКИ")
CreateToggle(aP, "Включить Аймбот", false, function(s)
    CFG.Aim.on = s
    PushNotify("Аймбот", s and "Активирован" or "Отключён",
        s and "success" or "warn")
end)
CreateDropdown(aP, "Режим работы", {"Camera", "Instant", "Smooth", "Prediction"},
    CFG.Aim.mode, function(v)
        CFG.Aim.mode = v
        PushNotify("Аймбот", "Режим: " .. v, "success")
    end)
CreateDropdown(aP, "Целевая часть", {"Head", "HumanoidRootPart", "UpperTorso"},
    CFG.Aim.targetPart, function(v) CFG.Aim.targetPart = v end)
CreateDropdown(aP, "Приоритет цели", {"Distance", "FOV", "Health"},
    CFG.Aim.priority, function(v) CFG.Aim.priority = v end)

CreateSection(aP, "⚙ ТОЧНАЯ НАСТРОЙКА")
CreateSlider(aP, "FOV (радиус захвата)", 30, 600, 150, function(v) CFG.Aim.fov = v end)
CreateSlider(aP, "Сглаживание × 100", 10, 100, 35, function(v) CFG.Aim.smooth = v / 100 end)
CreateSlider(aP, "Макс. дистанция", 50, 1500, 500, function(v) CFG.Aim.maxDist = v end)
CreateSlider(aP, "Предсказание × 100", 0, 50, 15, function(v) CFG.Aim.prediction = v / 100 end)
CreateSlider(aP, "Время удержания цели (сек)", 0, 3, 5, function(v) CFG.Aim.lockTime = v / 10 end)

CreateSection(aP, "🔒 ФИЛЬТРЫ")
CreateToggle(aP, "Проверка команды", true, function(s) CFG.Aim.teamCheck = s end)
CreateToggle(aP, "Проверка стен", true, function(s) CFG.Aim.wallCheck = s end)
CreateToggle(aP, "Только видимые цели", true, function(s) CFG.Aim.onlyVisible = s end)
CreateToggle(aP, "Игнорировать NPC", true, function(s) CFG.Aim.ignoreNPC = s end)
CreateToggle(aP, "Удержание цели (не прыгать)", true, function(s) CFG.Aim.targetLock = s end)

CreateSection(aP, "🎨 ВИЗУАЛЬНАЯ ЧАСТЬ")
CreateToggle(aP, "Показывать FOV круг", true, function(s) CFG.Aim.showFOVCircle = s end)
CreateToggle(aP, "Показывать линию к цели", true, function(s) CFG.Aim.showTargetLine = s end)

CreateSection(aP, "🔫 АВТО-ВЫСТРЕЛ")
CreateToggle(aP, "Авто-выстрел при наведении", false, function(s)
    CFG.Aim.autoFire = s
    PushNotify("Аймбот", s and "Авто-выстрел ВКЛ" or "ВЫКЛ", s and "success" or "warn")
end)
CreateSlider(aP, "Задержка выстрела (мс)", 30, 500, 150, function(v)
    CFG.Aim.autoFireDelay = v / 1000
end)

CreateSection(aP, "📊 СТАТУС АЙМБОТА")
local aimCard = CreateCard(aP, 90)
local aimStatus = CreateLabel(aimCard, "Цель: <font color='#808090'>не найдена</font>", 8)
local aimInfo = CreateLabel(aimCard, "Режим: Camera · FOV: 150", 38)
local aimStats = CreateLabel(aimCard, "Дист: — · HP: —", 62)

task.spawn(function()
    while Alive do
        task.wait(0.2)
        if CFG.Aim.on then
            if AimBot.currentTarget then
                aimStatus.Text = "Цель: <font color='#00FF8C'>" ..
                    AimBot.currentTarget.player.Name .. "</font>"
                aimInfo.Text = string.format(
                    "Режим: <font color='#00BFFF'>%s</font> · FOV: <font color='#FF2B5A'>%d</font>",
                    CFG.Aim.mode, CFG.Aim.fov)
                aimStats.Text = string.format(
                    "Дист: <font color='#FFBB00'>%d</font> · HP: <font color='#00FF8C'>%d</font>",
                    math.floor(AimBot.currentTarget.dist),
                    math.floor(AimBot.currentTarget.health))
            else
                aimStatus.Text = "Цель: <font color='#808090'>не найдена</font>"
                aimInfo.Text = "Режим: " .. CFG.Aim.mode .. " · FOV: " .. CFG.Aim.fov
                aimStats.Text = "Дист: — · HP: —"
            end
        else
            aimStatus.Text = "Цель: <font color='#808090'>Аймбот выключен</font>"
            aimInfo.Text = "Режим: — · FOV: —"
            aimStats.Text = "Дист: — · HP: —"
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- [20/30] UI: БОЙ
-- ═══════════════════════════════════════════════════════════════════════════
local cP = Pages["Combat"]
CreateSection(cP, "🎯 ESP — ПОДСВЕТКА ИГРОКОВ")
CreateToggle(cP, "Включить ESP", false, function(s)
    CFG.ESP.on = s
    PushNotify("ESP", s and "Включён" or "Отключён", s and "success" or "warn")
end)
CreateSlider(cP, "Прозрачность силуэта (%)", 0, 100, 50, function(v) CFG.ESP.fill = v / 100 end)
CreateSlider(cP, "Прозрачность обводки (%)", 0, 100, 0, function(v) CFG.ESP.outline = v / 100 end)
CreateSlider(cP, "Дистанция ESP (студы)", 50, 2000, 500, function(v) CFG.ESP.maxDist = v end)
CreateToggle(cP, "RGB-переливание", false, function(s) CFG.ESP.rgb = s end)
CreateToggle(cP, "Показывать только видимых", false, function(s) CFG.ESP.onlyVisible = s end)

CreateSection(cP, "🖱 АВТОКЛИКЕР")
CreateToggle(cP, "Автоматический удар", false, function(s)
    CFG.Auto.click = s
    PushNotify("Автокликер", s and "Включён" or "Отключён", s and "success" or "warn")
end)
CreateSlider(cP, "Интервал (мс)", 20, 500, 100, function(v) CFG.Auto.clickMs = v end)

CreateSection(cP, "🦘 АВТОПРЫЖОК")
CreateToggle(cP, "Автопрыжок", false, function(s)
    CFG.Auto.jump = s
    PushNotify("Автопрыжок", s and "Включён" or "Отключён", s and "success" or "warn")
end)
CreateSlider(cP, "Интервал (мс)", 100, 2000, 300, function(v) CFG.Auto.jumpMs = v end)

-- Логика автокликера
task.spawn(function()
    while Alive do
        task.wait(0.05)
        if CFG.Auto.click then
            pcall(function()
                if VirtualUser then
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton1(Vector2.new(
                        Workspace.CurrentCamera.ViewportSize.X / 2,
                        Workspace.CurrentCamera.ViewportSize.Y / 2
                    ))
                end
            end)
            task.wait(math.clamp(CFG.Auto.clickMs / 1000, 0.01, 1))
        end
    end
end)

-- Логика автопрыжка
task.spawn(function()
    while Alive do
        task.wait(0.05)
        if CFG.Auto.jump then
            pcall(function()
                local h = LocalPlayer.Character and
                    LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
            end)
            task.wait(CFG.Auto.jumpMs / 1000)
        end
    end
end)

-- ESP логика
task.spawn(function()
    while Alive do
        task.wait(0.2)
        if CFG.ESP.on then
            local mc = LocalPlayer.Character
            local mr = mc and mc:FindFirstChild("HumanoidRootPart")
            local mp = mr and mr.Position
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local hl = p.Character:FindFirstChild("DW_HL")
                    if not hl then
                        hl = Instance.new("Highlight")
                        hl.Name = "DW_HL"
                        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        hl.Parent = p.Character
                    end
                    hl.FillColor = CFG.Theme
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    hl.FillTransparency = CFG.ESP.fill
                    hl.OutlineTransparency = CFG.ESP.outline
                    local tr = p.Character:FindFirstChild("HumanoidRootPart")
                    local tp = tr and tr.Position
                    local d = (mp and tp) and (mp - tp).Magnitude or 0
                    hl.Enabled = (d <= CFG.ESP.maxDist)
                end
            end
        else
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Character then
                    local hl = p.Character:FindFirstChild("DW_HL")
                    if hl then hl.Enabled = false end
                end
            end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- [21/30] UI: ДВИЖЕНИЕ
-- ═══════════════════════════════════════════════════════════════════════════
local mP = Pages["Move"]
CreateSection(mP, "🏃 СКОРОСТЬ И ПРЫЖОК")
CreateSlider(mP, "Скорость ходьбы", 16, 500, 16, function(v)
    CFG.Move.ws = v
    pcall(function()
        local h = LocalPlayer.Character and
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if h then h.WalkSpeed = v end
    end)
end)
CreateSlider(mP, "Сила прыжка", 50, 500, 50, function(v)
    CFG.Move.jp = v
    pcall(function()
        local h = LocalPlayer.Character and
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if h then
            h.UseJumpPower = true
            h.JumpPower = v
        end
    end)
end)
CreateToggle(mP, "Бесконечный прыжок", false, function(s) CFG.Move.infJump = s end)
CreateToggle(mP, "Noclip (сквозь стены)", false, function(s)
    CFG.Move.noclip = s
    PushNotify("Noclip", s and "Включён" or "Отключён", s and "success" or "warn")
end)

CreateSection(mP, "✈️ ПОЛЁТ")
CreateToggle(mP, "Включить полёт", false, function(s)
    CFG.Move.flyOn = s
    PushNotify("Полёт", s and "Взлёт!" or "Посадка", s and "success" or "warn")
end)
CreateSlider(mP, "Скорость полёта", 20, 500, 60, function(v) CFG.Move.fs = v end)

CreateSection(mP, "🌍 ГРАВИТАЦИЯ")
CreateToggle(mP, "Своя гравитация", false, function(s)
    CFG.Move.gravOn = s
    PushNotify("Гравитация", s and ("Значение: " .. CFG.Move.grav) or "Стандарт",
        s and "success" or "warn")
end)
CreateSlider(mP, "Значение гравитации", 0, 300, 196, function(v) CFG.Move.grav = v end)

-- Система полёта
local flyBV, flyBG, flyConn
local function StartFly()
    if flyConn then return end
    pcall(function()
        local hrp = LocalPlayer.Character and
            LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
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
            if not Alive or not CFG.Move.flyOn then
                if flyBV then flyBV:Destroy() end
                if flyBG then flyBG:Destroy() end
                if flyConn then flyConn:Disconnect() end
                flyBV, flyBG, flyConn = nil, nil, nil
                return
            end
            local r = LocalPlayer.Character and
                LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not r then return end
            local cam = Workspace.CurrentCamera
            local md = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then md = md + cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then md = md - cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then md = md - cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then md = md + cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then md = md + Vector3.new(0,1,0) end
            if md.Magnitude > 0 then md = md.Unit * CFG.Move.fs end
            flyBV.Velocity = md
            flyBG.CFrame = cam.CFrame
        end)
    end)
end

local function StopFly()
    pcall(function()
        if flyBV then flyBV:Destroy() end
        if flyBG then flyBG:Destroy() end
        if flyConn then flyConn:Disconnect() end
        flyBV, flyBG, flyConn = nil, nil, nil
    end)
end

task.spawn(function()
    while Alive and task.wait(0.2) do
        if CFG.Move.flyOn and not flyConn then StartFly()
        elseif not CFG.Move.flyOn and flyConn then StopFly() end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if not Alive or not CFG.Move.infJump then return end
    pcall(function()
        local h = LocalPlayer.Character and
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end)
end)

RunService.Stepped:Connect(function()
    if not Alive or not CFG.Move.noclip then return end
    pcall(function()
        local c = LocalPlayer.Character
        if c then
            for _, p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") and p.CanCollide then
                    p.CanCollide = false
                end
            end
        end
    end)
end)

task.spawn(function()
    while Alive and task.wait(0.3) do
        if CFG.Move.gravOn then
            if Workspace.Gravity ~= CFG.Move.grav then
                pcall(function() Workspace.Gravity = CFG.Move.grav end)
            end
        elseif Workspace.Gravity ~= CFG.orig.grav then
            pcall(function() Workspace.Gravity = CFG.orig.grav end)
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- [22/30] UI: ВИЗУАЛ (с HUD и прицелом)
-- ═══════════════════════════════════════════════════════════════════════════
local vP = Pages["Visual"]
CreateSection(vP, "➕ ПРИЦЕЛ")

local CH = Instance.new("Frame", SG)
CH.Size = UDim2.new(0, 100, 0, 100)
CH.Position = UDim2.new(0.5, -50, 0.5, -50)
CH.BackgroundTransparency = 1
CH.Visible = false
CH.ZIndex = 8

local CLines = {}
for i = 1, 5 do
    local f = Instance.new("Frame", CH)
    f.BorderSizePixel = 0
    f.BackgroundColor3 = CFG.Cross.color
    table.insert(CLines, f)
end

function RecalcCrosshair()
    local c = CFG.Cross
    CH.Visible = c.on
    if not c.on then return end
    local T, B, L, R, D = CLines[1], CLines[2], CLines[3], CLines[4], CLines[5]
    D.Visible = c.dot
    D.Size = UDim2.new(0, c.thick, 0, c.thick)
    D.Position = UDim2.new(0.5, -c.thick/2, 0.5, -c.thick/2)
    T.Size = UDim2.new(0, c.thick, 0, c.size)
    T.Position = UDim2.new(0.5, -c.thick/2, 0.5, -c.gap - c.size)
    B.Size = UDim2.new(0, c.thick, 0, c.size)
    B.Position = UDim2.new(0.5, -c.thick/2, 0.5, c.gap)
    L.Size = UDim2.new(0, c.size, 0, c.thick)
    L.Position = UDim2.new(0.5, -c.gap - c.size, 0.5, -c.thick/2)
    R.Size = UDim2.new(0, c.size, 0, c.thick)
    R.Position = UDim2.new(0.5, c.gap, 0.5, -c.thick/2)
end

CreateToggle(vP, "Включить прицел", false, function(s)
    CFG.Cross.on = s
    RecalcCrosshair()
end)
CreateToggle(vP, "Центральная точка", false, function(s)
    CFG.Cross.dot = s
    RecalcCrosshair()
end)
CreateSlider(vP, "Длина линий", 6, 60, 18, function(v)
    CFG.Cross.size = v
    RecalcCrosshair()
end)
CreateSlider(vP, "Толщина линий", 1, 10, 3, function(v)
    CFG.Cross.thick = v
    RecalcCrosshair()
end)
CreateSlider(vP, "Зазор", 0, 30, 6, function(v)
    CFG.Cross.gap = v
    RecalcCrosshair()
end)

CreateSection(vP, "📺 HUD — ОВЕРЛЕИ")
CreateToggle(vP, "Показывать FPS и Пинг", true, function(s)
    CFG.HUD.wm = s
    WM.Visible = s
end)
CreateToggle(vP, "Показывать координаты", false, function(s)
    CFG.HUD.coords = s
    CoordHUD.Visible = s
end)
CreateToggle(vP, "Показывать память", false, function(s) CFG.HUD.memory = s end)
CreateToggle(vP, "Показывать скорость", false, function(s) CFG.HUD.speed = s end)
CreateToggle(vP, "Показывать цель аймбота", true, function(s) CFG.HUD.showAimTarget = s end)

-- HUD координаты
local CoordHUD = Instance.new("TextLabel", SG)
CoordHUD.Size = UDim2.new(0, 260, 0, 32)
CoordHUD.Position = UDim2.new(0.5, -130, 0, 4)
CoordHUD.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
CoordHUD.BackgroundTransparency = 0.25
CoordHUD.TextColor3 = Color3.fromRGB(255, 200, 220)
CoordHUD.Font = Enum.Font.Code
CoordHUD.TextSize = IS_MOBILE and 14 or 12
CoordHUD.RichText = true
CoordHUD.Text = "X: 0 Y: 0 Z: 0"
CoordHUD.Visible = false
CoordHUD.ZIndex = 25
UX.corner(CoordHUD, 8)
UX.stroke(CoordHUD, CFG.Theme, 1, 0.4)

-- Watermark
local WM = Instance.new("Frame", SG)
WM.Size = UDim2.new(0, 280, 0, 90)
WM.Position = UDim2.new(1, -290, 0, 4)
WM.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
WM.BackgroundTransparency = 0.15
WM.BorderSizePixel = 0
WM.Visible = true
WM.ZIndex = 25
UX.corner(WM, 10)
UX.stroke(WM, CFG.Theme, 1, 0.3)

local WMTitle = Instance.new("TextLabel", WM)
WMTitle.Size = UDim2.new(1, -20, 0, 24)
WMTitle.Position = UDim2.new(0, 12, 0, 4)
WMTitle.BackgroundTransparency = 1
WMTitle.RichText = true
WMTitle.Text = "🎀 <font color='#FF2B5A'>ZERO TWO</font> <font color='#A0A0A5'>v4.0</font>"
WMTitle.TextColor3 = Color3.fromRGB(240, 240, 245)
WMTitle.Font = Enum.Font.GothamBold
WMTitle.TextSize = 13
WMTitle.TextXAlignment = Enum.TextXAlignment.Left

local WMStats = Instance.new("TextLabel", WM)
WMStats.Size = UDim2.new(1, -20, 0, 60)
WMStats.Position = UDim2.new(0, 12, 0, 28)
WMStats.BackgroundTransparency = 1
WMStats.RichText = true
WMStats.Text = "FPS: — | Пинг: —"
WMStats.TextColor3 = Color3.fromRGB(180, 180, 195)
WMStats.Font = Enum.Font.Code
WMStats.TextSize = 11
WMStats.TextXAlignment = Enum.TextXAlignment.Left
WMStats.TextYAlignment = Enum.TextYAlignment.Top

-- HUD цель аймбота
local AimTargetHUD = Instance.new("TextLabel", SG)
AimTargetHUD.Size = UDim2.new(0, 260, 0, 26)
AimTargetHUD.Position = UDim2.new(0.5, -130, 0, 40)
AimTargetHUD.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
AimTargetHUD.BackgroundTransparency = 0.3
AimTargetHUD.TextColor3 = Color3.fromRGB(0, 255, 130)
AimTargetHUD.Font = Enum.Font.Code
AimTargetHUD.TextSize = 12
AimTargetHUD.RichText = true
AimTargetHUD.Text = ""
AimTargetHUD.Visible = false
AimTargetHUD.ZIndex = 25
UX.corner(AimTargetHUD, 8)
UX.stroke(AimTargetHUD, CFG.Success, 1, 0.5)

-- ═══════════════════════════════════════════════════════════════════════════
-- [23/30] UI: ГРАФИКА
-- ═══════════════════════════════════════════════════════════════════════════
local gP = Pages["Graphics"]
CreateSection(gP, "🎨 ПРОДВИНУТАЯ ГРАФИКА")
CreateToggle(gP, "Fullbright (максимальная яркость)", false, function(s)
    CFG.Gfx.fullbright = s
    pcall(function()
        if s then
            Lighting.Ambient = Color3.fromRGB(178, 178, 178)
            Lighting.OutdoorAmbient = Color3.fromRGB(178, 178, 178)
            Lighting.Brightness = 3
            Lighting.ClockTime = 14
        else
            Lighting.Ambient = CFG.orig.amb
            Lighting.OutdoorAmbient = CFG.orig.outAmb
            Lighting.Brightness = CFG.orig.bright
            Lighting.ClockTime = CFG.orig.clock
        end
    end)
    PushNotify("Графика", s and "Fullbright ВКЛ" or "ВЫКЛ", s and "success" or "warn")
end)
CreateToggle(gP, "Отключить тени", false, function(s)
    CFG.Gfx.noShadows = s
    pcall(function()
        Lighting.GlobalShadows = not s
        Lighting.ShadowSoftness = s and 0 or 0.5
    end)
end)
CreateToggle(gP, "Отключить туман", false, function(s)
    CFG.Gfx.noFog = s
    pcall(function()
        Lighting.FogEnd = s and 100000 or CFG.orig.fog
        Lighting.FogStart = s and 100000 or 0
    end)
end)
CreateToggle(gP, "Отключить Bloom / Blur", false, function(s)
    CFG.Gfx.noBloom = s
    pcall(function()
        for _, e in ipairs(Lighting:GetChildren()) do
            if e:IsA("BloomEffect") or e:IsA("BlurEffect")
               or e:IsA("SunRaysEffect") or e:IsA("ColorCorrectionEffect") then
                e.Enabled = not s
            end
        end
    end)
end)
CreateToggle(gP, "Отключить частицы", false, function(s)
    CFG.Gfx.noParticles = s
    pcall(function()
        for _, d in ipairs(Workspace:GetDescendants()) do
            if d:IsA("ParticleEmitter") or d:IsA("Smoke")
               or d:IsA("Fire") or d:IsA("Sparkles") then
                d.Enabled = not s
            end
        end
    end)
end)
CreateToggle(gP, "Отключить воду (Terrain)", false, function(s)
    CFG.Gfx.noWater = s
    pcall(function()
        if Terrain then
            Terrain.WaterWaveSize = s and 0 or 1
            Terrain.WaterWaveSpeed = s and 0 or 1
            Terrain.WaterReflectance = s and 0 or 1
            Terrain.WaterTransparency = s and 1 or 0
        end
    end)
end)
CreateToggle(gP, "Отключить атмосферу", false, function(s)
    CFG.Gfx.noAtmosphere = s
    pcall(function()
        for _, e in ipairs(Lighting:GetChildren()) do
            if e:IsA("Atmosphere") then
                e.Density = s and 0 or 0.3
            end
        end
    end)
end)

CreateSection(gP, "🎯 ПОЛЕ ЗРЕНИЯ (FOV)")
CreateToggle(gP, "Своё поле зрения", false, function(s)
    CFG.Gfx.fovOn = s
    PushNotify("FOV", s and ("Значение: " .. CFG.Gfx.fov) or "Стандарт",
        s and "success" or "warn")
end)
CreateSlider(gP, "Значение FOV", 40, 120, 70, function(v) CFG.Gfx.fov = v end)

task.spawn(function()
    while Alive and task.wait(0.2) do
        local cam = Workspace.CurrentCamera
        if cam then
            if CFG.Gfx.fovOn and cam.FieldOfView ~= CFG.Gfx.fov then
                pcall(function() cam.FieldOfView = CFG.Gfx.fov end)
            elseif not CFG.Gfx.fovOn and cam.FieldOfView ~= CFG.Gfx.origFov then
                pcall(function() cam.FieldOfView = CFG.Gfx.origFov end)
            end
        end
    end
end)

CreateSection(gP, "📏 ЗНАЧЕНИЯ НИЖЕ СТАНДАРТА")
CreateSlider(gP, "Рендер-дистанция", 100, 2000, 1000, function(v)
    CFG.Gfx.renderDist = v
    pcall(function()
        if Workspace.CurrentCamera then
            Workspace.CurrentCamera.Focus = CFrame.new(
                Workspace.CurrentCamera.CFrame.Position
            )
        end
    end)
end)
CreateSlider(gP, "LOD Bias (детализация)", 1, 10, 1, function(v) CFG.Gfx.lodBias = v end)

CreateBtn(gP, "♻️ Сбросить все настройки графики", Color3.fromRGB(50, 40, 45), function()
    CFG.Gfx.fullbright = false
    CFG.Gfx.noShadows = false
    CFG.Gfx.noFog = false
    CFG.Gfx.noBloom = false
    CFG.Gfx.noParticles = false
    CFG.Gfx.noWater = false
    CFG.Gfx.noAtmosphere = false
    pcall(function()
        Lighting.GlobalShadows = CFG.orig.shadows
        Lighting.FogEnd = CFG.orig.fog
        Lighting.Ambient = CFG.orig.amb
        Lighting.OutdoorAmbient = CFG.orig.outAmb
        Lighting.Brightness = CFG.orig.bright
        Lighting.ClockTime = CFG.orig.clock
        for _, e in ipairs(Lighting:GetChildren()) do
            if e:IsA("PostEffect") then e.Enabled = true end
        end
    end)
    PushNotify("Графика", "Все настройки сброшены", "success")
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- [24/30] UI: СЕТЬ
-- ═══════════════════════════════════════════════════════════════════════════
local nP = Pages["Network"]

local Net = {
    history = {},
    maxHistory = 30,
    avgPing = 0,
    minPing = math.huge,
    maxPing = 0,
    spikeCount = 0,
    lastPing = 0,
    lastSpike = 0,
}

local function UpdateNetStats()
    if not NetworkStats then return end
    pcall(function()
        local ping = math.round(NetworkStats.ServerPing)
        Net.lastPing = ping
        table.insert(Net.history, ping)
        if #Net.history > Net.maxHistory then
            table.remove(Net.history, 1)
        end
        local sum = 0
        for _, v in ipairs(Net.history) do sum = sum + v end
        Net.avgPing = math.round(sum / #Net.history)
        Net.minPing = math.min(Net.minPing, ping)
        Net.maxPing = math.max(Net.maxPing, ping)
        
        -- Спайк
        if #Net.history >= 5 then
            local prev = Net.history[#Net.history - 1]
            if ping - prev > 100 then
                Net.spikeCount = Net.spikeCount + 1
                Net.lastSpike = tick()
                if CFG.Net.lagShield then
                    pcall(function()
                        local hrp = LocalPlayer.Character and
                            LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                            hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                        end
                    end)
                end
            end
        end
    end)
end

task.spawn(function()
    while Alive do
        task.wait(0.5)
        UpdateNetStats()
    end
end)

-- Lag Shield
local lastPosition = Vector3.new()
local lastPositionTime = 0

RunService.Heartbeat:Connect(function()
    if not Alive or not CFG.Net.lagShield then return end
    pcall(function()
        local hrp = LocalPlayer.Character and
            LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local now = tick()
        local currentPos = hrp.Position
        if lastPositionTime > 0 then
            local delta = (currentPos - lastPosition).Magnitude
            local dt = now - lastPositionTime
            local speed = delta / math.max(dt, 0.01)
            if Net.lastPing > 300 and speed > 200 then
                hrp.CFrame = CFrame.new(lastPosition)
                hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            end
        end
        lastPosition = currentPos
        lastPositionTime = now
    end)
end)

CreateSection(nP, "📡 ОПТИМИЗАТОР СЕТИ")

local netCard = CreateCard(nP, 140)
local netInfo = Instance.new("TextLabel", netCard)
netInfo.Size = UDim2.new(1, -24, 1, -16)
netInfo.Position = UDim2.new(0, 12, 0, 8)
netInfo.BackgroundTransparency = 1
netInfo.Text = "Загрузка..."
netInfo.TextColor3 = Color3.fromRGB(220, 220, 230)
netInfo.Font = Enum.Font.Code
netInfo.TextSize = IS_MOBILE and 12 or 11
netInfo.TextXAlignment = Enum.TextXAlignment.Left
netInfo.TextYAlignment = Enum.TextYAlignment.Top
netInfo.RichText = true

task.spawn(function()
    while Alive and task.wait(1) do
        local avgC = Net.avgPing <= 100 and "#00FF8C" or (Net.avgPing <= 200 and "#FFBB00" or "#FF2B5A")
        local curC = Net.lastPing <= 100 and "#00FF8C" or (Net.lastPing <= 200 and "#FFBB00" or "#FF2B5A")
        netInfo.Text = string.format(
            "📊 Текущий пинг: <font color='%s'>%d мс</font>\n" ..
            "📈 Средний пинг: <font color='%s'>%d мс</font>\n" ..
            "⬇️ Мин / Макс: <font color='#00BFFF'>%d / %d</font>\n" ..
            "⚡ Спайки: <font color='#FFBB00'>%d</font>\n" ..
            "🛡 Статус: <font color='%s'>%s</font>",
            curC, Net.lastPing, avgC, Net.avgPing,
            Net.minPing == math.huge and 0 or Net.minPing, Net.maxPing,
            Net.spikeCount,
            CFG.Net.optimizer and "#00FF8C" or "#808090",
            CFG.Net.optimizer and "Активен" or "Выключен"
        )
    end
end)

CreateSection(nP, "⚡ АВТОМАТИЗАЦИЯ СЕТИ")
CreateToggle(nP, "Оптимизатор сети", false, function(s)
    CFG.Net.optimizer = s
    PushNotify("Сеть", s and "Оптимизатор ВКЛ" or "ВЫКЛ",
        s and "success" or "warn")
end)
CreateToggle(nP, "Буферизация пакетов", false, function(s)
    CFG.Net.bufferMode = s
    PushNotify("Сеть", s and "Буфер ВКЛ (сглаживание)" or "ВЫКЛ",
        s and "success" or "warn")
end)
CreateToggle(nP, "Lag Shield (защита от спайков)", false, function(s)
    CFG.Net.lagShield = s
    PushNotify("Сеть", s and "Lag Shield ВКЛ" or "ВЫКЛ",
        s and "success" or "warn")
end)
CreateToggle(nP, "Packet Guard (контроль соединения)", false, function(s)
    CFG.Net.packetGuard = s
    PushNotify("Сеть", s and "Packet Guard ВКЛ" or "ВЫКЛ",
        s and "success" or "warn")
end)

CreateSection(nP, "🔧 ДОПОЛНИТЕЛЬНО")
CreateSlider(nP, "Лимит пинга (мс)", 50, 500, 200, function(v) CFG.Net.pingLimit = v end)
CreateToggle(nP, "Авто-реконнект при спайке", false, function(s)
    CFG.Net.autoReconnect = s
end)

CreateBtn(nP, "🔄 Сбросить статистику сети", Color3.fromRGB(50, 40, 55), function()
    Net.history = {}
    Net.minPing = math.huge
    Net.maxPing = 0
    Net.spikeCount = 0
    PushNotify("Сеть", "Статистика сброшена", "success")
end)
CreateBtn(nP, "📊 Тест пинга (5 секунд)", Color3.fromRGB(35, 45, 55), function()
    PushNotify("Сеть", "Тест начат, ждём 5 сек...", "success")
    task.spawn(function()
        local samples = {}
        for i = 1, 10 do
            if not Alive then break end
            task.wait(0.5)
            if NetworkStats then
                table.insert(samples, math.round(NetworkStats.ServerPing))
            end
        end
        local sum = 0
        for _, v in ipairs(samples) do sum = sum + v end
        local avg = #samples > 0 and math.round(sum / #samples) or 0
        PushNotify("Сеть", "Средний пинг: " .. avg .. " мс", "success")
    end)
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- [25/30] UI: ЗАЩИТА
-- ═══════════════════════════════════════════════════════════════════════════
local prP = Pages["Protect"]
CreateSection(prP, "🛡 ЗАЩИТА ПЕРСОНАЖА")
CreateToggle(prP, "Anti-Stun (снять оглушение)", false, function(s)
    CFG.Guard.antiStun = s
    PushNotify("Защита", s and "Anti-Stun ВКЛ" or "ВЫКЛ", s and "success" or "warn")
end)
CreateToggle(prP, "Anti-Damage (не получать урон)", false, function(s)
    CFG.Guard.antiDamage = s
    PushNotify("Защита", s and "Anti-Damage ВКЛ" or "ВЫКЛ", s and "warn" or "warn")
end)
CreateToggle(prP, "Anti-Fling (без отбрасывания)", false, function(s)
    CFG.Guard.antiFling = s
    PushNotify("Защита", s and "Anti-Fling ВКЛ" or "ВЫКЛ", s and "success" or "warn")
end)
CreateToggle(prP, "Anti-Void (возврат из бездны)", false, function(s)
    CFG.Guard.antiVoid = s
    PushNotify("Защита", s and "Anti-Void ВКЛ" or "ВЫКЛ", s and "success" or "warn")
end)
CreateToggle(prP, "Anti-Flash (защита от вспышек)", false, function(s)
    CFG.Guard.antiFlash = s
    pcall(function()
        for _, e in ipairs(Lighting:GetChildren()) do
            if e:IsA("ColorCorrectionEffect") then
                if s then
                    e.Brightness = 0
                    e.Contrast = 0
                end
            end
        end
    end)
end)
CreateToggle(prP, "Anti-Blind (защита от ослепления)", false, function(s)
    CFG.Guard.antiBlind = s
    pcall(function()
        for _, e in ipairs(Lighting:GetChildren()) do
            if e:IsA("ColorCorrectionEffect") then
                if s then
                    e.Brightness = 0
                end
            end
        end
    end)
end)
CreateToggle(prP, "Anti-AFK (не выкидывать)", true, function(s)
    CFG.Guard.antiAFK = s
end)
CreateToggle(prP, "Safe Zone (авто-возврат при падении)", false, function(s)
    CFG.Guard.safeZone = s
end)

-- Anti-Stun логика
local StunKeys = {
    "hypno", "hypnosis", "stun", "stunned", "freeze", "frozen",
    "charm", "confuse", "sleep", "trance", "zombie", "ice", "petrified",
}
local function IsStunName(n)
    if not n then return false end
    n = string.lower(n)
    for _, k in ipairs(StunKeys) do
        if string.find(n, k, 1, true) then return true end
    end
    return false
end

task.spawn(function()
    while Alive and task.wait(0.1) do
        if CFG.Guard.antiStun then
            pcall(function()
                local c = LocalPlayer.Character
                local h = c and c:FindFirstChildOfClass("Humanoid")
                local a = h and h:FindFirstChildOfClass("Animator")
                if a then
                    for _, t in ipairs(a:GetPlayingAnimationTracks()) do
                        local n = ""
                        pcall(function()
                            if t.Animation then n = t.Animation.Name or "" end
                        end)
                        if IsStunName(n) or IsStunName(t.Name) then
                            pcall(function() t:Stop(0) end)
                        end
                    end
                end
                if h then
                    h.PlatformStand = false
                    h.AutoRotate = true
                end
            end)
        end
        if CFG.Guard.antiDamage then
            pcall(function()
                local h = LocalPlayer.Character and
                    LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if h and h.Health < h.MaxHealth then
                    h.Health = h.MaxHealth
                end
            end)
        end
    end
end)

-- Anti-Fling + Anti-Void + Safe Zone
local LastSafePos = Vector3.new(0, 50, 0)
RunService.Stepped:Connect(function()
    if not Alive then return end
    local c = LocalPlayer.Character
    local hrp = c and c:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    if CFG.Guard.antiFling then
        pcall(function()
            if hrp.AssemblyLinearVelocity.Magnitude > 250 then
                hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            end
        end)
    end
    
    if CFG.Guard.antiVoid or CFG.Guard.safeZone then
        pcall(function()
            local py = hrp.Position.Y
            if py > -80 and py < 10000 then
                LastSafePos = hrp.Position
            elseif py <= -80 then
                hrp.CFrame = CFrame.new(LastSafePos + Vector3.new(0, 5, 0))
                hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            end
        end)
    end
end)

-- Anti-AFK
pcall(function()
    LocalPlayer.Idled:Connect(function()
        if not Alive or not CFG.Guard.antiAFK then return end
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(0, 0))
        end)
    end)
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- [26/30] UI: ЧАТ
-- ═══════════════════════════════════════════════════════════════════════════
local chtP = Pages["Chat"]
CreateSection(chtP, "💬 ЧАТ-МАКРОСЫ")

local function SendChat(txt)
    pcall(function()
        if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
            local tc = TextChatService:FindFirstChild("TextChannels")
            local gc = tc and tc:FindFirstChild("RBXGeneral")
            if gc and gc:IsA("TextChannel") then
                gc:SendAsync(txt)
                return
            end
        end
        local lg = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
        local smr = lg and lg:FindFirstChild("SayMessageRequest")
        if smr and smr:IsA("RemoteEvent") then
            smr:FireServer(txt, "All")
        end
    end)
end

local CHAT_MACROS = {
    {category = "👋 Приветствия", phrases = {
        {n = "Привет всем", p = "Привет всем! Zero Two v4.0 на связи."},
        {n = "Ку", p = "Ку, народ!"},
        {n = "Йо", p = "Йо, всем привет!"},
        {n = "Здарова", p = "Здарова, братва!"},
        {n = "Доброе утро", p = "Доброе утро, всем!"},
        {n = "Добрый вечер", p = "Добрый вечер, друзья!"},
    }},
    {category = "🎮 Игровые", phrases = {
        {n = "GG", p = "GG WP всем!"},
        {n = "GG WP", p = "Хорошая игра, всем GG WP!"},
        {n = "Го", p = "Го-го-го!"},
        {n = "Плюсую", p = "+1, полностью согласен."},
        {n = "Респект", p = "Респект тебе, братишка!"},
        {n = "Красиво", p = "Красиво сыграно!"},
    }},
    {category = "🎯 Тактика", phrases = {
        {n = "Слева", p = "Враг слева!"},
        {n = "Справа", p = "Враг справа!"},
        {n = "Сзади", p = "Осторожно, враг сзади!"},
        {n = "Отходим", p = "Отходим, слишком много врагов!"},
        {n = "Наступаем", p = "Все вперёд, наступаем!"},
        {n = "Прикрывай", p = "Прикрывай меня!"},
    }},
    {category = "😎 Мемы", phrases = {
        {n = "Изи", p = "Изи катка, изи."},
        {n = "Кек", p = "Кек, ну ты даёшь."},
        {n = "Лол", p = "Лол, что происходит?"},
        {n = "Ору", p = "Ору в голосину!"},
        {n = "Жиза", p = "Жиза, понимаю."},
        {n = "Топ", p = "Ты топ, братан!"},
    }},
    {category = "🛡 Поддержка", phrases = {
        {n = "Молодец", p = "Молодец, отличная работа!"},
        {n = "С тобой", p = "Я с тобой до конца!"},
        {n = "Помогаю", p = "Иду на помощь!"},
        {n = "Держись", p = "Держись, я на подходе!"},
        {n = "Всем удачи", p = "Всем удачи в следующем раунде!"},
    }},
}

for _, cat in ipairs(CHAT_MACROS) do
    local catLbl = Instance.new("TextLabel", chtP)
    catLbl.Size = UDim2.new(1, 0, 0, 26)
    catLbl.BackgroundTransparency = 1
    catLbl.Text = cat.category
    catLbl.TextColor3 = Color3.fromRGB(255, 160, 190)
    catLbl.Font = Enum.Font.GothamBold
    catLbl.TextSize = IS_MOBILE and 14 or 12
    catLbl.TextXAlignment = Enum.TextXAlignment.Left
    catLbl.ZIndex = 7
    
    for _, phrase in ipairs(cat.phrases) do
        local MF = CreateCard(chtP, 48)
        local MNL = Instance.new("TextLabel", MF)
        MNL.Size = UDim2.new(0.55, 0, 1, 0)
        MNL.Position = UDim2.new(0, 16, 0, 0)
        MNL.Text = phrase.n
        MNL.TextColor3 = Color3.fromRGB(240, 240, 245)
        MNL.Font = Enum.Font.GothamSemibold
        MNL.TextSize = IS_MOBILE and 13 or 12
        MNL.TextXAlignment = Enum.TextXAlignment.Left
        MNL.BackgroundTransparency = 1
        MNL.ZIndex = 7
        
        local SB = Instance.new("TextButton", MF)
        SB.Size = UDim2.new(0, 90, 0, 34)
        SB.Position = UDim2.new(1, -104, 0.5, -17)
        SB.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
        SB.Text = "ОТПРАВИТЬ"
        SB.TextColor3 = Color3.fromRGB(255, 255, 255)
        SB.Font = Enum.Font.GothamBold
        SB.TextSize = IS_MOBILE and 11 or 10
        SB.ZIndex = 8
        UX.corner(SB, 8)
        UX.ripple(SB)
        
        SB.MouseButton1Click:Connect(function()
            if not Alive then return end
            PlayClick()
            SendChat(phrase.p)
            PushNotify("Чат", "Отправлено: " .. phrase.n, "success")
        end)
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- [27/30] UI: НАСТРОЙКИ (с конфигами)
-- ═══════════════════════════════════════════════════════════════════════════
local stP = Pages["Settings"]

CreateSection(stP, "🎀 ПЕРСОНАЖ НА КНОПКЕ")
CreateDropdown(stP, "Выбор аниме-тянки",
    {"ZeroTwo", "Nezuko", "Marin"}, CFG.UI.character, function(v)
        CFG.UI.character = v
        currentCharacter = v
        CreateChibiGrid()
        RenderChibiFrame("idle")
        PushNotify("Персонаж", "Выбрана: " .. v, "success")
        PlaySuccess()
    end)

CreateSection(stP, "🎨 ТЕМЫ")
CreateBtn(stP, "💗 Zero Two Pink", Color3.fromRGB(255, 43, 90), function()
    CFG.Theme = Color3.fromRGB(255, 43, 90)
    MainStroke.Color = CFG.Theme
    FBS.Color = CFG.Theme
    Cont.ScrollBarImageColor3 = CFG.Theme
    AimFOVStroke.Color = CFG.Theme
    PushNotify("Тема", "Zero Two Pink", "success")
end)
CreateBtn(stP, "💙 Cyber Blue", Color3.fromRGB(0, 180, 255), function()
    CFG.Theme = Color3.fromRGB(0, 180, 255)
    MainStroke.Color = CFG.Theme
    FBS.Color = CFG.Theme
    Cont.ScrollBarImageColor3 = CFG.Theme
    AimFOVStroke.Color = CFG.Theme
    PushNotify("Тема", "Cyber Blue", "success")
end)
CreateBtn(stP, "💚 Toxic Green", Color3.fromRGB(170, 255, 0), function()
    CFG.Theme = Color3.fromRGB(170, 255, 0)
    MainStroke.Color = CFG.Theme
    FBS.Color = CFG.Theme
    Cont.ScrollBarImageColor3 = CFG.Theme
    AimFOVStroke.Color = CFG.Theme
    PushNotify("Тема", "Toxic Green", "success")
end)
CreateBtn(stP, "💜 Purple Haze", Color3.fromRGB(180, 100, 255), function()
    CFG.Theme = Color3.fromRGB(180, 100, 255)
    MainStroke.Color = CFG.Theme
    FBS.Color = CFG.Theme
    Cont.ScrollBarImageColor3 = CFG.Theme
    AimFOVStroke.Color = CFG.Theme
    PushNotify("Тема", "Purple Haze", "success")
end)
CreateBtn(stP, "🧡 Sunset Orange", Color3.fromRGB(255, 140, 60), function()
    CFG.Theme = Color3.fromRGB(255, 140, 60)
    MainStroke.Color = CFG.Theme
    FBS.Color = CFG.Theme
    Cont.ScrollBarImageColor3 = CFG.Theme
    AimFOVStroke.Color = CFG.Theme
    PushNotify("Тема", "Sunset Orange", "success")
end)

CreateSection(stP, "💾 СЛОТЫ КОНФИГА")

local slotCard = CreateCard(stP, 130)
local slotLbl = Instance.new("TextLabel", slotCard)
slotLbl.Size = UDim2.new(1, -32, 0, 30)
slotLbl.Position = UDim2.new(0, 16, 0, 8)
slotLbl.Text = "Активный слот: <font color='#FF2B5A'>1</font>"
slotLbl.RichText = true
slotLbl.TextColor3 = Color3.fromRGB(230, 230, 240)
slotLbl.Font = Enum.Font.GothamSemibold
slotLbl.TextSize = IS_MOBILE and 15 or 14
slotLbl.TextXAlignment = Enum.TextXAlignment.Left
slotLbl.BackgroundTransparency = 1
slotLbl.ZIndex = 7

for i = 1, 5 do
    local sB = Instance.new("TextButton", slotCard)
    sB.Size = UDim2.new(0, IS_MOBILE and 52 or 44, 0, IS_MOBILE and 44 or 36)
    sB.Position = UDim2.new(0, 16 + (i-1) * (IS_MOBILE and 58 or 48), 0, 56)
    sB.BackgroundColor3 = (CFG.Slots.active == i) and CFG.Theme or Color3.fromRGB(35, 35, 48)
    sB.Text = tostring(i)
    sB.TextColor3 = Color3.fromRGB(255, 255, 255)
    sB.Font = Enum.Font.GothamBold
    sB.TextSize = IS_MOBILE and 15 or 12
    sB.ZIndex = 8
    UX.corner(sB, 8)
    UX.ripple(sB)
    
    sB.MouseButton1Click:Connect(function()
        if not Alive then return end
        PlayClick()
        CFG.Slots.active = i
        slotLbl.Text = "Активный слот: <font color='#FF2B5A'>" .. i .. "</font>"
        for _, c in ipairs(slotCard:GetChildren()) do
            if c:IsA("TextButton") then
                c.BackgroundColor3 = (c.Text == tostring(i)) and CFG.Theme or Color3.fromRGB(35, 35, 48)
            end
        end
    end)
end

local function GetConfigFile(slotNum)
    return FILE_CFG .. tostring(slotNum) .. ".json"
end

local function SaveConfig()
    if not FS.W then
        PushNotify("Ошибка", "Executor не поддерживает запись файлов", "error")
        return
    end
    pcall(function()
        local data = {
            ESP = CFG.ESP,
            Move = CFG.Move,
            Guard = CFG.Guard,
            Gfx = CFG.Gfx,
            HUD = CFG.HUD,
            Cross = CFG.Cross,
            Auto = CFG.Auto,
            Aim = CFG.Aim,
            Net = CFG.Net,
            UI = CFG.UI,
            Audio = CFG.Audio,
        }
        FS.W(GetConfigFile(CFG.Slots.active), HttpService:JSONEncode(data))
        PushNotify("Конфиг", "Слот " .. CFG.Slots.active .. " сохранён!", "success")
        PlaySuccess()
    end)
end

local function LoadConfig()
    if not FS.R or not FS.C then
        PushNotify("Ошибка", "Executor не поддерживает чтение файлов", "error")
        return
    end
    local fName = GetConfigFile(CFG.Slots.active)
    if not FS.C(fName) then
        PushNotify("Конфиг", "Файл слота " .. CFG.Slots.active .. " не найден", "warn")
        return
    end
    pcall(function()
        local data = HttpService:JSONDecode(FS.R(fName))
        if data then
            for sectionName, sectionData in pairs(data) do
                if CFG[sectionName] and type(sectionData) == "table" then
                    for k, v in pairs(sectionData) do
                        CFG[sectionName][k] = v
                    end
                end
            end
            PushNotify("Конфиг", "Слот " .. CFG.Slots.active .. " загружен!", "success")
            PlaySuccess()
        end
    end)
end

CreateBtn(stP, "💾 Сохранить в текущий слот", Color3.fromRGB(34, 45, 38), SaveConfig)
CreateBtn(stP, "📂 Загрузить из текущего слота", Color3.fromRGB(34, 38, 50), LoadConfig)

CreateSection(stP, "🎵 ЗВУК")
CreateToggle(stP, "Отключить звуки интерфейса", false, function(s) CFG.Audio.mute = s end)
CreateSlider(stP, "Громкость кликов (%)", 10, 100, 50, function(v) CFG.Audio.vol = v / 100 end)

CreateSection(stP, "⚙ СИСТЕМА")
CreateBtn(stP, "🔄 Сбросить все настройки", Color3.fromRGB(60, 30, 34), function()
    CFG.ESP.on = false
    CFG.Aim.on = false
    CFG.Auto.click = false
    CFG.Auto.jump = false
    CFG.Move.flyOn = false
    CFG.Move.infJump = false
    CFG.Move.noclip = false
    CFG.Move.gravOn = false
    CFG.Guard.antiStun = false
    CFG.Guard.antiFling = false
    CFG.Guard.antiVoid = false
    CFG.Guard.antiDamage = false
    CFG.Net.optimizer = false
    CFG.Net.bufferMode = false
    CFG.Net.lagShield = false
    CFG.Net.packetGuard = false
    CFG.Gfx.fullbright = false
    CFG.Gfx.noShadows = false
    CFG.Gfx.noFog = false
    CFG.Gfx.noBloom = false
    CFG.Gfx.noParticles = false
    StopFly()
    PushNotify("Сброс", "Все функции выключены", "warn")
end)

CreateSection(stP, "ℹ О ПРОГРАММЕ")
local infoCard = CreateCard(stP, 160)
local infoLbl = Instance.new("TextLabel", infoCard)
infoLbl.Size = UDim2.new(1, -24, 1, -16)
infoLbl.Position = UDim2.new(0, 12, 0, 8)
infoLbl.BackgroundTransparency = 1
infoLbl.RichText = true
infoLbl.Text = "🎀 <b>Zero Two Ultimate v4.0</b>\n\n" ..
    "• Живая аниме-тянка (моргает, дышит, улыбается)\n" ..
    "• 3 персонажа на выбор\n" ..
    "• Полный настраиваемый аймбот\n" ..
    "• ESP, движение, защита, графика, сеть\n" ..
    "• Плавные анимации\n" ..
    "• Всё на русском языке\n\n" ..
    "<i>Made with 💗 for Mobile</i>"
infoLbl.TextColor3 = Color3.fromRGB(200, 200, 215)
infoLbl.Font = Enum.Font.Gotham
infoLbl.TextSize = IS_MOBILE and 12 or 11
infoLbl.TextXAlignment = Enum.TextXAlignment.Left
infoLbl.TextYAlignment = Enum.TextYAlignment.Top
infoLbl.ZIndex = 7

-- ═══════════════════════════════════════════════════════════════════════════
-- [28/30] ГЛАВНЫЙ ЦИКЛ ОБНОВЛЕНИЯ
-- ═══════════════════════════════════════════════════════════════════════════
local frameCounter, timeCounter = 0, 0
RunService.RenderStepped:Connect(function(dt)
    if not Alive then return end
    
    frameCounter = frameCounter + 1
    timeCounter = timeCounter + dt
    if timeCounter >= 1 then
        CFG.Fps = math.round(frameCounter / timeCounter)
        frameCounter = 0
        timeCounter = 0
    end
    
    -- Watermark
    if CFG.HUD.wm then
        WM.Visible = true
        if NetworkStats then
            pcall(function()
                CFG.Ping = math.round(NetworkStats.ServerPing)
            end)
        end
        local fc = CFG.Fps >= 45 and "#00FF8C" or (CFG.Fps >= 25 and "#FFBB00" or "#FF2B5A")
        local pc = CFG.Ping <= 90 and "#00FF8C" or (CFG.Ping <= 200 and "#FFBB00" or "#FF2B5A")
        local memText = ""
        if CFG.HUD.memory then
            pcall(function()
                local mem = StatsService:GetTotalMemoryUsageMb()
                CFG.Memory = mem
                memText = string.format("\nПамять: <font color='#FFBB00'>%.1f MB</font>", mem)
            end)
        end
        local spdText = ""
        if CFG.HUD.speed then
            pcall(function()
                local hrp = LocalPlayer.Character and
                    LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    spdText = string.format("\nСкорость: <font color='#00BFFF'>%.1f</font>",
                        hrp.AssemblyLinearVelocity.Magnitude)
                end
            end)
        end
        WMStats.Text = string.format(
            "FPS: <font color='%s'>%d</font> | Пинг: <font color='%s'>%d мс</font>%s%s",
            fc, CFG.Fps, pc, CFG.Ping, memText, spdText)
    else
        WM.Visible = false
    end
    
    -- Координаты
    if CFG.HUD.coords then
        CoordHUD.Visible = true
        local c = LocalPlayer.Character
        local h = c and c:FindFirstChild("HumanoidRootPart")
        if h then
            local p = h.Position
            CoordHUD.Text = string.format(
                "<font color='#FF2B5A'>X:</font> %d  <font color='#00FF8C'>Y:</font> %d  <font color='#00BFFF'>Z:</font> %d",
                math.floor(p.X), math.floor(p.Y), math.floor(p.Z))
        end
    else
        CoordHUD.Visible = false
    end
    
    -- Цель аймбота на HUD
    if CFG.HUD.showAimTarget and CFG.Aim.on and AimBot.currentTarget then
        AimTargetHUD.Visible = true
        AimTargetHUD.Text = string.format(
            "🎯 Цель: <b>%s</b> · Дист: %.0f",
            AimBot.currentTarget.player.Name, AimBot.currentTarget.dist)
    else
        AimTargetHUD.Visible = false
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- [29/30] УПРАВЛЕНИЕ МЕНЮ (свернуть, схлопнуть, скрыть)
-- ═══════════════════════════════════════════════════════════════════════════
local isMinimized = true
local isCollapsed = false

local function ShowMenu()
    M.Visible = true
    FB.Visible = false
    MUIScale.Scale = 0
    TweenService:Create(MUIScale, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Scale = 1
    }):Play()
    SwitchTab(CFG.UI.activeTab)
    -- Плавное появление снизу
    local origPos = M.Position
    M.Position = UDim2.new(origPos.X.Scale, origPos.X.Offset, origPos.Y.Scale, origPos.Y.Offset + 50)
    TweenService:Create(M, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = origPos
    }):Play()
end

local function HideMenu()
    TweenService:Create(MUIScale, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
        Scale = 0
    }):Play()
    task.delay(0.3, function()
        M.Visible = false
        FB.Visible = true
        -- Пересоздаём чиби (могли изменить персонажа)
        CreateChibiGrid()
        RenderChibiFrame("idle")
    end)
end

local function ToggleMenu()
    if not Alive then return end
    PlayClick()
    if M.Visible then
        HideMenu()
        isMinimized = true
    else
        ShowMenu()
        isMinimized = false
    end
end

local function ToggleCollapse()
    if not Alive then return end
    PlayClick()
    isCollapsed = not isCollapsed
    if isCollapsed then
        local targetH = H.AbsoluteSize.Y + 20
        TweenService:Create(M, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {
            Size = UDim2.new(IS_MOBILE and 1 or 0, IS_MOBILE and -20 or 620,
                              0, targetH)
        }):Play()
        TBScroll.Visible = false
        Cont.Visible = false
        Foot.Visible = false
    else
        local targetSize = IS_MOBILE and UDim2.new(1, -20, 1, -100)
                                      or UDim2.new(0, 620, 0, 520)
        TweenService:Create(M, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
            Size = targetSize
        }):Play()
        TBScroll.Visible = true
        Cont.Visible = true
        Foot.Visible = true
    end
end

MinBtn.MouseButton1Click:Connect(ToggleCollapse)
HideBtn.MouseButton1Click:Connect(ToggleMenu)
FB.MouseButton1Click:Connect(ToggleMenu)

-- Двойной тап по header — свернуть
local lastTapTime = 0
H.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch then
        local now = tick()
        if now - lastTapTime < 0.3 then
            ToggleCollapse()
        end
        lastTapTime = now
    end
end)

-- Свайп вниз по вкладкам — закрыть
TBScroll.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch then
        local y0 = i.Position.Y
        local conn
        conn = UserInputService.InputChanged:Connect(function(ch)
            if ch.UserInputType ~= Enum.UserInputType.Touch then return end
            if ch.Position.Y - y0 > 120 then
                conn:Disconnect()
                if M.Visible then ToggleMenu() end
            end
        end)
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- [30/30] ВЫХОД И СТАРТ
-- ═══════════════════════════════════════════════════════════════════════════

_G.DW_Exit = function()
    Alive = false
    StopFly()
    pcall(function() SG:Destroy() end)
    pcall(function() NotifySG:Destroy() end)
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then
            local hl = p.Character:FindFirstChild("DW_HL")
            if hl then hl:Destroy() end
        end
    end
    pcall(function()
        Lighting.GlobalShadows = CFG.orig.shadows
        Lighting.FogEnd = CFG.orig.fog
        Lighting.Ambient = CFG.orig.amb
        Lighting.OutdoorAmbient = CFG.orig.outAmb
        Lighting.Brightness = CFG.orig.bright
        Lighting.ClockTime = CFG.orig.clock
    end)
    print("[DW v4.0] Zero Two Ultimate выгружен.")
end

CloseBtn.MouseButton1Click:Connect(function()
    PlayClick()
    if _G.DW_Exit then _G.DW_Exit() end
end)

-- Проверка обновления сцены
Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    if not Alive then return end
    if IS_MOBILE then
        M.Size = UDim2.new(1, -20, 1, -100)
    end
end)

-- ═══ СТАРТ ═══
task.wait(0.5)
SwitchTab("Aim")
RenderChibiFrame("idle")
PushNotify("🎀 ZERO TWO v4.0", "Ultimate загружен! Тапни на аниме-тянку внизу 👇", "success")
PlaySuccess()
print("[DW v4.0] Zero Two Ultimate loaded.")
print("[DW v4.0] Tabs: " .. tostring(#Tabs))
print("[DW v4.0] Mobile: " .. tostring(IS_MOBILE))