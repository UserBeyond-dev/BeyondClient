--[[═══════════════════════════════════════════════════════════════════════════════
   ██████╗ ██╗   ██╗███████╗██╗         ██╗    ██╗ █████╗ ██████╗ ██████╗ 
   ██╔══██╗██║   ██║██╔════╝██║         ██║    ██║██╔══██╗██╔══██╗██╔══██╗
   ██║  ██║██║   ██║█████╗  ██║         ██║ █╗ ██║███████║██████╔╝██║  ██║
   ██║  ██║██║   ██║██╔══╝  ██║         ██║███╗██║██╔══██║██╔══██╗██║  ██║
   ██████╔╝╚██████╔╝███████╗███████╗    ╚███╔███╔╝██║  ██║██║  ██║██████╔╝
   ╚═════╝  ╚═════╝ ╚══════╝╚══════╝     ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝ 
   
   ███████╗██╗     ██╗████████╗███████╗
   ██╔════╝██║     ██║╚══██╔══╝██╔════╝
   █████╗  ██║     ██║   ██║   █████╗  
   ██╔══╝  ██║     ██║   ██║   ██╔══╝  
   ███████╗███████╗██║   ██║   ███████╗
   ╚══════╝╚══════╝╚═╝   ╚═╝   ╚══════╝
═══════════════════════════════════════════════════════════════════════════════
   DUEL WARRIORS · SHADOW ELITE EDITION v7.0
   Часть 1/2 · Mobile Ultimate · Delta Executor · HONOR Play5
═══════════════════════════════════════════════════════════════════════════════]]

-- ═══════════════════════════════════════════════════════════════════════════
-- [01/32] ИНИЦИАЛИЗАЦИЯ СЕРВИСОВ
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

local LocalPlayer       = Players.LocalPlayer
local Camera            = Workspace.CurrentCamera or Workspace:WaitForChild("Camera")
local IS_MOBILE         = UserInputService.TouchEnabled and not UserInputService.MouseEnabled
local IS_DELTA          = false
pcall(function()
    local id = (identifyexecutor and identifyexecutor()) or ""
    IS_DELTA = string.find(string.lower(id), "delta") ~= nil
end)

local NetworkStats = StatsService:FindFirstChild("Network")
local Terrain      = Workspace:FindFirstChildOfClass("Terrain")

-- Безопасная выгрузка предыдущей версии
if _G.DW_Exit then pcall(_G.DW_Exit) end
if _G.DW_Cleanup then pcall(_G.DW_Cleanup) end

-- ═══════════════════════════════════════════════════════════════════════════
-- [02/32] ФАЙЛОВАЯ СИСТЕМА
-- ═══════════════════════════════════════════════════════════════════════════
local FS = {
    W = writefile or (syn and syn.writefile),
    R = readfile or (syn and syn.readfile),
    C = isfile or (syn and syn.isfile),
    D = delfile or (syn and syn.delfile),
    A = appendfile or (syn and syn.appendfile),
    L = listfiles or (syn and syn.listfiles),
}

local FILES = {
    settings = "DW7_settings.json",
    button   = "DW7_button.json",
    config   = "DW7_slot_",
    tracker  = "DW7_tracker.json",
    stats    = "DW7_stats.json",
    backup   = "DW7_backup_",
    music    = "DW7_music.json",
}

-- ═══════════════════════════════════════════════════════════════════════════
-- [03/32] ГЛОБАЛЬНЫЙ КОНФИГ (монохром)
-- ═══════════════════════════════════════════════════════════════════════════
_G.DW = {
    Version   = "7.0.0-SHADOW-ELITE",
    BuildDate = "2026",
    Developer = "Zero Two Studio",
    
    -- МОНОХРОМНАЯ ПАЛИТРА
    Theme     = Color3.fromRGB(255, 255, 255),
    Accent    = Color3.fromRGB(200, 200, 200),
    Bg        = Color3.fromRGB(8, 8, 8),
    Card      = Color3.fromRGB(18, 18, 18),
    CardHover = Color3.fromRGB(24, 24, 24),
    Header    = Color3.fromRGB(14, 14, 14),
    Border    = Color3.fromRGB(40, 40, 40),
    BorderHi  = Color3.fromRGB(80, 80, 80),
    Text      = Color3.fromRGB(230, 230, 230),
    TextDim   = Color3.fromRGB(140, 140, 140),
    SubText   = Color3.fromRGB(100, 100, 100),
    Off       = Color3.fromRGB(35, 35, 35),
    Success   = Color3.fromRGB(255, 255, 255),
    Warning   = Color3.fromRGB(180, 180, 180),
    Error     = Color3.fromRGB(120, 120, 120),
    
    -- АУДИО (исходники — чтобы PlayClick не падал)
    Audio = {
        mute = false,
        vol  = 0.5,
    },
    
    -- NET (используется в Части 2)
    Net = {
        optimizer = false,
        bufferMode = false,
        lagShield = false,
        packetGuard = false,
        pingLimit = 200,
        autoReconnect = false,
    },
    
    -- НАСТРОЙКИ МЕНЮ (сохраняются)
    Menu = {
        buttonSize    = 55,
        menuW         = 340,
        menuH         = 430,
        opacity       = 1,
        textSize      = 12,
        pulseSpeed    = 2,
        showPulse     = true,
        showBlobs     = true,
        animationSpeed = 1,
        soundPack     = "Default",
        autoSaveOnExit = true,
        showTooltips  = true,
    },
    
    -- АЙМБОТ
    Aim = {
        on = false, mode = "Camera", targetPart = "Head",
        fov = 150, smooth = 0.35, maxDist = 500,
        teamCheck = true, wallCheck = true, onlyVisible = true,
        priority = "Distance", prediction = 0.15,
        autoFire = false, autoFireDelay = 0.15,
        hitboxExpand = false, hitboxSize = 2.0,
        targetLock = true, lockTime = 0.5,
        showFOVCircle = true, showTargetLine = true,
    },
    
    -- ESP
    ESP = {
        on = false, fill = 0.5, outline = 0, maxDist = 500,
        items = false, chests = false,
        teamColors = false, showHealth = false,
        showName = false, showDistance = false, rgb = false,
    },
    
    -- ДВИЖЕНИЕ
    Move = {
        ws = 16, jp = 50, fs = 60,
        flyOn = false, infJump = false, noclip = false,
        grav = 196.2, gravOn = false, antiAnchor = false,
    },
    
    -- ЗАЩИТА
    Guard = {
        antiAFK = true, antiStun = false, antiFling = false,
        antiVoid = false, antiDamage = false, antiFlash = false,
        autoHeal = false, healThreshold = 50, healDelay = 1,
    },
    
    -- ГРАФИКА
    Gfx = {
        fullbright = false, noShadows = false, noFog = false,
        noBloom = false, noParticles = false, noWater = false,
        simpleTerrain = false, noAtmosphere = false,
        fovOn = false, fov = 70, origFov = 70,
        renderDist = 1000, lodBias = 1,
    },
    
    -- HUD
    HUD = {
        wm = true, coords = false, memory = false, speed = false,
        showAimTarget = true, showTracker = false, showCombo = true,
    },
    
    -- АВТОМАТИЗАЦИЯ
    Auto = {
        click = false, clickMs = 100,
        jump = false, jumpMs = 300,
        spamChat = false, spamMs = 5000,
        spamText = "GG WP всем!", spamRandom = true,
        autoQuest = false,
    },
    
    -- KILL AURA
    KillAura = {
        on = false, radius = 15, delay = 0.1,
        onlyVisible = true, teamCheck = true,
    },
    
    -- ТРЕКЕР
    Tracker = { on = false, maxHistory = 100, data = {}, showHUD = false },
    
    -- КОМБО
    Combo = {
        on = true, sequence = {}, comboTimer = 0,
        lastComboTime = 0, comboDisplay = {},
    },
    
    -- МУЗЫКА
    Music = {
        on = false, currentTrack = nil, volume = 0.5,
        playlist = {
            {name = "Ambient", id = "rbxassetid://1838496966"},
            {name = "Focus",   id = "rbxassetid://1837879082"},
            {name = "Chill",   id = "rbxassetid://1836318199"},
            {name = "Epic",    id = "rbxassetid://1837872135"},
        },
    },
    
    -- СТАТИСТИКА
    Stats = {
        sessionStart = os.time(),
        totalKills = 0, totalDeaths = 0, totalActions = 0,
        aimbotHits = 0, espActivations = 0, flyDistance = 0,
        lastReset = os.time(),
    },
    
    -- СЛОТЫ
    Slots = { active = 1, total = 5 },
    
    -- ОРИГИНАЛЬНЫЕ ЗНАЧЕНИЯ
    orig = {
        shadows = Lighting.GlobalShadows,
        fog     = Lighting.FogEnd,
        amb     = Lighting.Ambient,
        outAmb  = Lighting.OutdoorAmbient,
        bright  = Lighting.Brightness,
        grav    = Workspace.Gravity,
        clock   = Lighting.ClockTime,
    },
    
    Fps = 60, Ping = 0, Memory = 0, PacketLoss = 0,
}
local CFG = _G.DW
local Alive = true

-- ═══════════════════════════════════════════════════════════════════════════
-- [04/32] ЗАГРУЗКА / СОХРАНЕНИЕ НАСТРОЕК
-- ═══════════════════════════════════════════════════════════════════════════
local function LoadSettings()
    if not FS.R or not FS.C then return end
    if not FS.C(FILES.settings) then return end
    pcall(function()
        local data = HttpService:JSONDecode(FS.R(FILES.settings))
        if type(data) ~= "table" then return end
        if data.Menu then
            for k, v in pairs(data.Menu) do
                if k ~= "mute" and k ~= "vol" then
                    CFG.Menu[k] = v
                end
            end
        end
        if data.Audio then
            for k, v in pairs(data.Audio) do CFG.Audio[k] = v end
        end
        if data.Theme and type(data.Theme) == "table" and data.Theme.R then
            CFG.Theme = Color3.new(data.Theme.R, data.Theme.G, data.Theme.B)
        end
    end)
end

local function SaveSettings()
    if not FS.W then return end
    pcall(function()
        FS.W(FILES.settings, HttpService:JSONEncode({
            Menu  = CFG.Menu,
            Audio = CFG.Audio,
            Theme = {R = CFG.Theme.R, G = CFG.Theme.G, B = CFG.Theme.B},
        }))
    end)
end

local function LoadStats()
    if not FS.R or not FS.C then return end
    if not FS.C(FILES.stats) then return end
    pcall(function()
        local data = HttpService:JSONDecode(FS.R(FILES.stats))
        if type(data) == "table" then
            for k, v in pairs(data) do CFG.Stats[k] = v end
        end
    end)
end

local function SaveStats()
    if not FS.W then return end
    pcall(function()
        FS.W(FILES.stats, HttpService:JSONEncode(CFG.Stats))
    end)
end

LoadSettings()
LoadStats()

-- ═══════════════════════════════════════════════════════════════════════════
-- [05/32] UX УТИЛИТЫ
-- ═══════════════════════════════════════════════════════════════════════════
local UX = {}

function UX.corner(obj, radius)
    local c = Instance.new("UICorner", obj)
    c.CornerRadius = UDim.new(0, radius or 6)
    return c
end

function UX.stroke(obj, color, thickness, transparency)
    local s = Instance.new("UIStroke", obj)
    s.Color = color or CFG.Border
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    return s
end

function UX.gradient(obj, color1, color2, rotation)
    local g = Instance.new("UIGradient", obj)
    g.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, color1),
        ColorSequenceKeypoint.new(1, color2),
    })
    g.Rotation = rotation or 90
    return g
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
        TweenService:Create(btn, TweenInfo.new(0.18, Enum.EasingStyle.Quart), {
            BackgroundColor3 = UX.mulColor(base, multiplier)
        }):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.18, Enum.EasingStyle.Quart), {
            BackgroundColor3 = base
        }):Play()
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

function UX.press(btn, scaleDown)
    scaleDown = scaleDown or 0.95
    local sc = Instance.new("UIScale", btn)
    sc.Scale = 1
    btn.MouseButton1Down:Connect(function()
        TweenService:Create(sc, TweenInfo.new(0.08), {Scale = scaleDown}):Play()
    end)
    btn.MouseButton1Up:Connect(function()
        TweenService:Create(sc, TweenInfo.new(0.18, Enum.EasingStyle.Back), {Scale = 1}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(sc, TweenInfo.new(0.18, Enum.EasingStyle.Back), {Scale = 1}):Play()
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════
-- [06/32] ВИБРАЦИЯ + ЗВУК
-- ═══════════════════════════════════════════════════════════════════════════
local function Vibrate(power, duration)
    if not IS_MOBILE then return end
    pcall(function()
        if HapticService:IsVibrationSupported(Enum.UserInputType.Touch) then
            HapticService:SetMotor(Enum.UserInputType.Touch, Enum.VibrationMotor.Small, power or 0.4)
            task.delay(duration or 0.08, function()
                HapticService:SetMotor(Enum.UserInputType.Touch, Enum.VibrationMotor.Small, 0)
            end)
        end
    end)
end

AudioFolder = SoundService:FindFirstChild("DW_Audio")
if not AudioFolder then
    AudioFolder = Instance.new("Folder")
    AudioFolder.Name = "DW_Audio"
    AudioFolder.Parent = SoundService
end

local SOUND_PACKS = {
    Default = {click = "rbxassetid://6140381534", success = "rbxassetid://6042053626"},
    Soft    = {click = "rbxassetid://5657703586", success = "rbxassetid://5657703586"},
    Sharp   = {click = "rbxassetid://5657721723", success = "rbxassetid://5657721723"},
    Silent  = {click = "", success = ""},
}

function PlayClick()
    if not Alive or CFG.Audio.mute then return end
    Vibrate(0.4)
    local pack = SOUND_PACKS[CFG.Menu.soundPack] or SOUND_PACKS.Default
    if pack.click == "" then return end
    task.spawn(function()
        pcall(function()
            local s = Instance.new("Sound")
            s.SoundId = pack.click
            s.Volume = CFG.Audio.vol * 0.6
            s.PlayOnRemove = true
            s.Parent = AudioFolder
            s:Destroy()
        end)
    end)
end

function PlaySuccess()
    if not Alive or CFG.Audio.mute then return end
    Vibrate(0.7, 0.15)
    local pack = SOUND_PACKS[CFG.Menu.soundPack] or SOUND_PACKS.Default
    if pack.success == "" then return end
    task.spawn(function()
        pcall(function()
            local s = Instance.new("Sound")
            s.SoundId = pack.success
            s.Volume = CFG.Audio.vol * 0.5
            s.PlayOnRemove = true
            s.Parent = AudioFolder
            s:Destroy()
        end)
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════
-- [07/32] СИСТЕМА УВЕДОМЛЕНИЙ
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
            Size = UDim2.new(0, 280, 0, 0),
            BackgroundTransparency = 1
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
    
    local duration = 3.2
    
    local nf = Instance.new("Frame")
    nf.Size = UDim2.new(0, 280, 0, 0)
    nf.Position = IS_MOBILE and UDim2.new(0.5, -140, 0, 20) or UDim2.new(1, -300, 0, 100)
    nf.BackgroundColor3 = CFG.Card
    nf.BackgroundTransparency = 1 - CFG.Menu.opacity
    nf.BorderSizePixel = 0
    nf.ClipsDescendants = true
    nf.Parent = NotifySG
    UX.corner(nf, 10)
    UX.stroke(nf, accent, 1.5)
    
    local bar = Instance.new("Frame", nf)
    bar.Size = UDim2.new(0, 3, 1, 0)
    bar.BackgroundColor3 = accent
    bar.BorderSizePixel = 0
    bar.ZIndex = 3
    
    local ic = Instance.new("Frame", nf)
    ic.Size = UDim2.new(0, 22, 0, 22)
    ic.Position = UDim2.new(0, 12, 0, 10)
    ic.BackgroundColor3 = accent
    ic.BackgroundTransparency = 0.85
    ic.BorderSizePixel = 0
    ic.ZIndex = 3
    UX.corner(ic, 999)
    UX.stroke(ic, accent, 1)
    
    local icl = Instance.new("TextLabel", ic)
    icl.Size = UDim2.new(1, 0, 1, 0)
    icl.BackgroundTransparency = 1
    icl.Text = icon
    icl.TextColor3 = accent
    icl.Font = Enum.Font.GothamBold
    icl.TextSize = 12
    icl.ZIndex = 4
    
    local tl = Instance.new("TextLabel", nf)
    tl.Size = UDim2.new(1, -50, 0, 18)
    tl.Position = UDim2.new(0, 42, 0, 10)
    tl.BackgroundTransparency = 1
    tl.Text = title or "DW"
    tl.TextColor3 = Color3.fromRGB(245, 245, 250)
    tl.Font = Enum.Font.GothamBold
    tl.TextSize = 12
    tl.TextXAlignment = Enum.TextXAlignment.Left
    tl.ZIndex = 3
    
    local bl = Instance.new("TextLabel", nf)
    bl.Size = UDim2.new(1, -20, 0, 22)
    bl.Position = UDim2.new(0, 12, 0, 32)
    bl.BackgroundTransparency = 1
    bl.Text = msg or ""
    bl.TextColor3 = CFG.SubText
    bl.Font = Enum.Font.Gotham
    bl.TextSize = 10
    bl.TextWrapped = true
    bl.TextXAlignment = Enum.TextXAlignment.Left
    bl.TextYAlignment = Enum.TextYAlignment.Top
    bl.ZIndex = 3
    
    local pbg = Instance.new("Frame", nf)
    pbg.Size = UDim2.new(1, 0, 0, 2)
    pbg.Position = UDim2.new(0, 0, 1, -2)
    pbg.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
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
            TweenService:Create(n, TweenInfo.new(0.25), {
                Position = UDim2.new(cp.X.Scale, cp.X.Offset, cp.Y.Scale, cp.Y.Offset + 66)
            }):Play()
        end
    end
    table.insert(NotifyStack, nf)
    
    TweenService:Create(nf, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 280, 0, 62)
    }):Play()
    TweenService:Create(pbar, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
        Size = UDim2.new(0, 0, 1, 0)
    }):Play()
    
    task.spawn(function()
        task.wait(duration)
        removeNotify(nf)
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════
-- [08/32] ГЛАВНЫЙ SCREENGUI
-- ═══════════════════════════════════════════════════════════════════════════
local SG = Instance.new("ScreenGui")
SG.Name = "DW_" .. HttpService:GenerateGUID(false):sub(1, 8)
SG.ResetOnSpawn = false
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
if not pcall(function() SG.Parent = CoreGui end) then
    SG.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- ═══════════════════════════════════════════════════════════════════════════
-- [09/32] КНОПКА АССАСИНА
-- ═══════════════════════════════════════════════════════════════════════════
local FB = Instance.new("ImageButton", SG)
FB.Name = "DW_AssassinButton"
FB.Size = UDim2.new(0, CFG.Menu.buttonSize, 0, CFG.Menu.buttonSize)
FB.AnchorPoint = Vector2.new(0.5, 1)
FB.Position = UDim2.new(0.5, 0, 1, -18)
FB.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
FB.BorderSizePixel = 0
FB.Image = ""
FB.ImageTransparency = 1
FB.AutoButtonColor = false
FB.ClipsDescendants = false
FB.ZIndex = 50
FB.Active = true
FB.Visible = true
UX.corner(FB, 999)
local FBS = UX.stroke(FB, Color3.fromRGB(255, 255, 255), 2)

local AssassinRoot = Instance.new("Frame", FB)
AssassinRoot.Size = UDim2.new(0.75, 0, 0.75, 0)
AssassinRoot.AnchorPoint = Vector2.new(0.5, 0.5)
AssassinRoot.Position = UDim2.new(0.5, 0, 0.5, 0)
AssassinRoot.BackgroundTransparency = 1
AssassinRoot.ClipsDescendants = true
AssassinRoot.ZIndex = 3

local ASSASSIN_MATRIX = {
    "________BBBBBBBB________",
    "______BBWWWWWWWWBB______",
    "_____BWWWWWWWWWWWWB_____",
    "____BWWWWWWWWWWWWWWB____",
    "___BWWWWWWWWWWWWWWWWB___",
    "___BWWWWWWWWWWWWWWWWB___",
    "__BWWWWWWWWWWWWWWWWWWB__",
    "__BWWWWWWWWWWWWWWWWWWB__",
    "__BWWWWBBBBBBBBWWWWWWB__",
    "__BWWWBBGGGGGGBBWWWWWB__",
    "__BWWBBGBBBBBBGBBWWWWB__",
    "__BWWBGGBWWWWBGGBWWWWB__",
    "__BWWBGGBWWWWBGGBWWWWB__",
    "__BWWBBGBBBBBBGBBWWWWB__",
    "__BWWWBBGGGGGGBBWWWWWB__",
    "__BWWWWBBBBBBBBWWWWWWB__",
    "__BWWWWWWWWWWWWWWWWWWB__",
    "___BWWWWWWWWWWWWWWWWB___",
    "___BBWWWWWWWWWWWWWWBB___",
    "____BBWWWWWWWWWWWWBB____",
    "_____BBWWWWWWWWWWBB_____",
    "______BBWWWWWWWWBB______",
    "_______BBBBBBBBBB_______",
    "________BBBBBBBB________",
}

local Pixels = {}
local function CreateAssassinIcon()
    for _, row in pairs(Pixels) do
        for _, px in pairs(row) do
            if px and px.Parent then px:Destroy() end
        end
    end
    Pixels = {}
    local rows = #ASSASSIN_MATRIX
    local cell = 1 / rows
    local colors = {
        W = Color3.fromRGB(240, 240, 240),
        B = Color3.fromRGB(20, 20, 20),
        G = Color3.fromRGB(80, 80, 80),
    }
    for y = 1, rows do
        Pixels[y] = {}
        local rowStr = ASSASSIN_MATRIX[y]
        for x = 1, #rowStr do
            local ch = string.sub(rowStr, x, x)
            if ch ~= "_" then
                local px = Instance.new("Frame", AssassinRoot)
                px.Size = UDim2.new(cell, 0, cell, 0)
                px.Position = UDim2.new((x-1)*cell, 0, (y-1)*cell, 0)
                px.BackgroundColor3 = colors[ch] or colors.B
                px.BorderSizePixel = 0
                px.ZIndex = 3
                Pixels[y][x] = px
            end
        end
    end
end
CreateAssassinIcon()

-- Пульсация кнопки
task.spawn(function()
    local t = 0
    while Alive do
        local dt = RunService.Heartbeat:Wait()
        if not FB.Visible then continue end
        if CFG.Menu.showPulse then
            t = t + dt * CFG.Menu.pulseSpeed
            FBS.Transparency = 0.3 + math.sin(t) * 0.3
        end
    end
end)

-- Загрузка позиции кнопки
task.spawn(function()
    if FS.R and FS.C and FS.C(FILES.button) then
        pcall(function()
            local d = HttpService:JSONDecode(FS.R(FILES.button))
            if d then
                FB.AnchorPoint = Vector2.new(0.5, 0.5)
                FB.Position = UDim2.new(
                    tonumber(d.xs) or 0.5, tonumber(d.xo) or 0,
                    tonumber(d.ys) or 1, tonumber(d.yo) or -18
                )
            end
        end)
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- [10/32] ГЛАВНОЕ МЕНЮ
-- ═══════════════════════════════════════════════════════════════════════════
local M = Instance.new("Frame", SG)
M.Name = "MainPanel"
if IS_MOBILE then
    M.Size = UDim2.new(0, CFG.Menu.menuW, 0, CFG.Menu.menuH)
    M.AnchorPoint = Vector2.new(0.5, 0.5)
    M.Position = UDim2.new(0.5, 0, 0.5, -20)
else
    M.Size = UDim2.new(0, 420, 0, CFG.Menu.menuH)
    M.AnchorPoint = Vector2.new(0.5, 0.5)
    M.Position = UDim2.new(0.5, 0, 0.5, 0)
end
M.BackgroundColor3 = CFG.Bg
M.BackgroundTransparency = 1 - CFG.Menu.opacity
M.BorderSizePixel = 0
M.Active = true
M.Visible = false
M.ClipsDescendants = false
UX.corner(M, 12)
local MainStroke = UX.stroke(M, Color3.fromRGB(255, 255, 255), 1.5)

local MUIScale = Instance.new("UIScale", M)
MUIScale.Scale = 1

local MG = Instance.new("UIGradient", M)
MG.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(12, 12, 12)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(8, 8, 8)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 15)),
})
MG.Rotation = 45

-- Плавающие блики
local Blob1 = Instance.new("Frame", M)
Blob1.Size = UDim2.new(0, 200, 0, 200)
Blob1.Position = UDim2.new(0, -60, 0, -40)
Blob1.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
Blob1.BackgroundTransparency = 0.92
Blob1.BorderSizePixel = 0
Blob1.ZIndex = 1
UX.corner(Blob1, 999)

local Blob2 = Instance.new("Frame", M)
Blob2.Size = UDim2.new(0, 180, 0, 180)
Blob2.Position = UDim2.new(1, -120, 1, -80)
Blob2.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
Blob2.BackgroundTransparency = 0.94
Blob2.BorderSizePixel = 0
Blob2.ZIndex = 1
UX.corner(Blob2, 999)

task.spawn(function()
    local t = 0
    while Alive do
        local dt = RunService.Heartbeat:Wait()
        if not M.Visible or not CFG.Menu.showBlobs then continue end
        t = t + dt
        Blob1.Position = UDim2.new(0, -60 + math.sin(t*0.4)*20, 0, -40 + math.cos(t*0.6)*15)
        Blob2.Position = UDim2.new(1, -120 + math.cos(t*0.5)*20, 1, -80 + math.sin(t*0.4)*15)
    end
end)

-- HEADER
local H = Instance.new("Frame", M)
H.Name = "HeaderDrag"
H.Size = UDim2.new(1, 0, 0, 40)
H.BackgroundColor3 = CFG.Header
H.BackgroundTransparency = 1 - CFG.Menu.opacity
H.BorderSizePixel = 0
H.ZIndex = 10
UX.corner(H, 12)

local HG = Instance.new("UIGradient", H)
HG.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(24, 24, 24)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(14, 14, 14)),
})
HG.Rotation = 90

local HLine = Instance.new("Frame", H)
HLine.Size = UDim2.new(1, -20, 0, 1)
HLine.Position = UDim2.new(0, 10, 1, -1)
HLine.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
HLine.BorderSizePixel = 0
HLine.ZIndex = 10

local DragHintTop = Instance.new("Frame", H)
DragHintTop.Size = UDim2.new(0, 40, 0, 3)
DragHintTop.Position = UDim2.new(0.5, -20, 0, 6)
DragHintTop.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
DragHintTop.BackgroundTransparency = 0.4
DragHintTop.BorderSizePixel = 0
DragHintTop.ZIndex = 15
UX.corner(DragHintTop, 999)

local Logo = Instance.new("TextLabel", H)
Logo.Size = UDim2.new(0, 24, 0, 24)
Logo.Position = UDim2.new(0, 14, 0.5, -12)
Logo.BackgroundTransparency = 1
Logo.Text = "🗡"
Logo.TextColor3 = CFG.Theme
Logo.Font = Enum.Font.GothamBold
Logo.TextSize = 16
Logo.ZIndex = 11

local Title = Instance.new("TextLabel", H)
Title.Size = UDim2.new(1, -180, 1, 0)
Title.Position = UDim2.new(0, 42, 0, 0)
Title.Text = "DW · SHADOW ELITE"
Title.TextColor3 = CFG.Text
Title.Font = Enum.Font.GothamBold
Title.TextSize = CFG.Menu.textSize
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
Title.ZIndex = 11

local function MakeHeaderBtn(text, xOffset)
    local b = Instance.new("TextButton", H)
    b.Size = UDim2.new(0, 28, 0, 28)
    b.Position = UDim2.new(1, xOffset, 0.5, -14)
    b.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    b.Text = text
    b.TextColor3 = Color3.fromRGB(220, 220, 220)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 13
    b.ZIndex = 12
    UX.corner(b, 6)
    return b
end

local MinBtn = MakeHeaderBtn("−", -94)
local HideBtn = MakeHeaderBtn("▼", -62)
local CloseBtn = MakeHeaderBtn("✕", -30)

-- ПАНЕЛЬ ВКЛАДОК
local TBScroll = Instance.new("ScrollingFrame", M)
TBScroll.Name = "TabBar"
TBScroll.Size = UDim2.new(1, -16, 0, 34)
TBScroll.Position = UDim2.new(0, 8, 0, 48)
TBScroll.BackgroundColor3 = CFG.Card
TBScroll.BackgroundTransparency = 1 - CFG.Menu.opacity
TBScroll.BorderSizePixel = 0
TBScroll.ScrollBarThickness = 0
TBScroll.ScrollingDirection = Enum.ScrollingDirection.X
TBScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
TBScroll.AutomaticCanvasSize = Enum.AutomaticSize.X
TBScroll.ScrollBarImageTransparency = 1
TBScroll.ZIndex = 5
UX.corner(TBScroll, 8)

local TB = Instance.new("Frame", TBScroll)
TB.Size = UDim2.new(0, 0, 1, 0)
TB.BackgroundTransparency = 1
TB.AutomaticSize = Enum.AutomaticSize.X

local TL = Instance.new("UIListLayout", TB)
TL.FillDirection = Enum.FillDirection.Horizontal
TL.Padding = UDim.new(0, 4)
TL.SortOrder = Enum.SortOrder.LayoutOrder
TL.VerticalAlignment = Enum.VerticalAlignment.Center

local TPad = Instance.new("UIPadding", TB)
TPad.PaddingLeft = UDim.new(0, 5); TPad.PaddingRight = UDim.new(0, 5)

-- КОНТЕЙНЕР СТРАНИЦ
local Cont = Instance.new("ScrollingFrame", M)
Cont.Name = "Content"
Cont.Size = UDim2.new(1, -16, 1, -140)
Cont.Position = UDim2.new(0, 8, 0, 90)
Cont.BackgroundTransparency = 1
Cont.BorderSizePixel = 0
Cont.CanvasSize = UDim2.new(0, 0, 0, 700)
Cont.ScrollBarThickness = 3
Cont.ScrollBarImageColor3 = Color3.fromRGB(180, 180, 180)
Cont.ScrollingDirection = Enum.ScrollingDirection.Y
Cont.ZIndex = 5

-- FOOTER
local Foot = Instance.new("Frame", M)
Foot.Name = "FooterDrag"
Foot.Size = UDim2.new(1, 0, 0, 26)
Foot.Position = UDim2.new(0, 0, 1, -26)
Foot.BackgroundColor3 = CFG.Header
Foot.BackgroundTransparency = 1 - CFG.Menu.opacity
Foot.BorderSizePixel = 0
Foot.ZIndex = 10
UX.corner(Foot, 12)

local DragHint = Instance.new("Frame", Foot)
DragHint.Size = UDim2.new(0, 40, 0, 3)
DragHint.Position = UDim2.new(0.5, -20, 1, -6)
DragHint.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
DragHint.BackgroundTransparency = 0.4
DragHint.BorderSizePixel = 0
DragHint.ZIndex = 11
UX.corner(DragHint, 999)

local FText = Instance.new("TextLabel", Foot)
FText.Size = UDim2.new(1, 0, 1, -6)
FText.BackgroundTransparency = 1
FText.Text = "DW Shadow Elite v7.0 · Mobile Ultimate"
FText.TextColor3 = CFG.SubText
FText.Font = Enum.Font.Gotham
FText.TextSize = 9
FText.TextXAlignment = Enum.TextXAlignment.Center
FText.ZIndex = 11

-- ═══════════════════════════════════════════════════════════════════════════
-- [11/32] СИСТЕМА ДРАГА
-- ═══════════════════════════════════════════════════════════════════════════
local function EnableDrag(zone)
    local dragging, dragStart, startPos = false, nil, nil
    zone.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch
           or i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = i.Position
            startPos = M.Position
            Vibrate(0.2)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if not dragging or not Alive then return end
        if i.UserInputType == Enum.UserInputType.Touch
           or i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position - dragStart
            M.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y
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

local function EnableButtonDrag(btn)
    local dragging, dragStart, startPos = false, nil, nil
    local moved = 0
    btn.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch
           or i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = i.Position
            startPos = btn.Position
            moved = 0
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if not dragging or not Alive then return end
        if i.UserInputType == Enum.UserInputType.Touch
           or i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position - dragStart
            moved = math.max(moved, d.Magnitude)
            if moved > 8 then
                btn.AnchorPoint = Vector2.new(0.5, 0.5)
                btn.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + d.X,
                    startPos.Y.Scale, startPos.Y.Offset + d.Y
                )
            end
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if not dragging then return end
        if i.UserInputType == Enum.UserInputType.Touch
           or i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            if moved > 8 then
                if FS.W then
                    pcall(function()
                        FS.W(FILES.button, HttpService:JSONEncode({
                            xs = FB.Position.X.Scale, xo = FB.Position.X.Offset,
                            ys = FB.Position.Y.Scale, yo = FB.Position.Y.Offset,
                        }))
                    end)
                end
            end
        end
    end)
end
EnableButtonDrag(FB)

-- ═══════════════════════════════════════════════════════════════════════════
-- [12/32] ФАБРИКИ UI ЭЛЕМЕНТОВ
-- ═══════════════════════════════════════════════════════════════════════════

function CreateToggle(parent, text, default, cb)
    local F = Instance.new("Frame", parent)
    F.Size = UDim2.new(1, 0, 0, 40)
    F.BackgroundColor3 = CFG.Card
    F.BackgroundTransparency = 1 - CFG.Menu.opacity
    F.BorderSizePixel = 0
    F.ZIndex = 6
    UX.corner(F, 8)
    UX.stroke(F, CFG.Border, 1)
    
    local L = Instance.new("TextLabel", F)
    L.Size = UDim2.new(0.65, 0, 1, 0)
    L.Position = UDim2.new(0, 12, 0, 0)
    L.Text = text
    L.TextColor3 = CFG.Text
    L.Font = Enum.Font.Gotham
    L.TextSize = CFG.Menu.textSize
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.TextWrapped = true
    L.BackgroundTransparency = 1
    L.ZIndex = 7
    
    local C = Instance.new("TextButton", F)
    C.Size = UDim2.new(0, 40, 0, 22)
    C.Position = UDim2.new(1, -52, 0.5, -11)
    C.BackgroundColor3 = default and CFG.Theme or CFG.Off
    C.Text = ""
    C.ZIndex = 7
    UX.corner(C, 999)
    local cS = UX.stroke(C, default and CFG.Theme or CFG.Off, 1, default and 0 or 1)
    
    local Ind = Instance.new("Frame", C)
    Ind.Size = UDim2.new(0, 16, 0, 16)
    Ind.Position = default and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
    Ind.BackgroundColor3 = default and Color3.fromRGB(20, 20, 20) or Color3.fromRGB(180, 180, 180)
    Ind.ZIndex = 8
    UX.corner(Ind, 999)
    
    local state = default
    C.MouseButton1Click:Connect(function()
        if not Alive then return end
        PlayClick()
        CFG.Stats.totalActions = (CFG.Stats.totalActions or 0) + 1
        state = not state
        local tc = state and CFG.Theme or CFG.Off
        local tp = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        local ic = state and Color3.fromRGB(20, 20, 20) or Color3.fromRGB(180, 180, 180)
        TweenService:Create(C, TweenInfo.new(0.22, Enum.EasingStyle.Quart), {BackgroundColor3 = tc}):Play()
        TweenService:Create(cS, TweenInfo.new(0.22), {Color = tc, Transparency = state and 0 or 1}):Play()
        TweenService:Create(Ind, TweenInfo.new(0.25, Enum.EasingStyle.Back), {
            Position = tp, BackgroundColor3 = ic
        }):Play()
        cb(state)
    end)
    UX.ripple(C)
    return C
end

function CreateSlider(parent, text, min, max, default, cb)
    local F = Instance.new("Frame", parent)
    F.Size = UDim2.new(1, 0, 0, 56)
    F.BackgroundColor3 = CFG.Card
    F.BackgroundTransparency = 1 - CFG.Menu.opacity
    F.BorderSizePixel = 0
    F.ZIndex = 6
    UX.corner(F, 8)
    UX.stroke(F, CFG.Border, 1)
    
    local L = Instance.new("TextLabel", F)
    L.Size = UDim2.new(0.9, 0, 0, 18)
    L.Position = UDim2.new(0, 12, 0, 5)
    L.Text = text .. ": " .. tostring(default)
    L.TextColor3 = CFG.Text
    L.Font = Enum.Font.Gotham
    L.TextSize = CFG.Menu.textSize
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.BackgroundTransparency = 1
    L.ZIndex = 7
    
    local T = Instance.new("Frame", F)
    T.Size = UDim2.new(1, -24, 0, 8)
    T.Position = UDim2.new(0, 12, 0, 36)
    T.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    T.BorderSizePixel = 0
    T.ZIndex = 7
    UX.corner(T, 999)
    
    local Fill = Instance.new("Frame", T)
    Fill.Size = UDim2.new((default - min) / math.max(1, (max - min)), 0, 1, 0)
    Fill.BackgroundColor3 = CFG.Theme
    Fill.BorderSizePixel = 0
    Fill.ZIndex = 8
    UX.corner(Fill, 999)
    
    local KnobSize = 18
    local Knob = Instance.new("Frame", T)
    Knob.Size = UDim2.new(0, KnobSize, 0, KnobSize)
    Knob.AnchorPoint = Vector2.new(0.5, 0.5)
    Knob.Position = UDim2.new(Fill.Size.X.Scale, 0, 0.5, 0)
    Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Knob.BorderSizePixel = 0
    Knob.ZIndex = 9
    UX.corner(Knob, 999)
    UX.stroke(Knob, Color3.fromRGB(80, 80, 80), 1)
    
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
        L.Text = text .. ": " .. tostring(value)
        cb(value)
    end
    
    TBtn.InputBegan:Connect(function(input)
        if not Alive then return end
        if input.UserInputType == Enum.UserInputType.Touch
           or input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliding = true
            proc(input)
            Vibrate(0.2)
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
            sliding = false
        end
    end)
end

function CreateSection(parent, title)
    local F = Instance.new("Frame", parent)
    F.Size = UDim2.new(1, 0, 0, 20)
    F.BackgroundTransparency = 1
    F.ZIndex = 6
    
    local L = Instance.new("TextLabel", F)
    L.Size = UDim2.new(1, -10, 1, 0)
    L.Position = UDim2.new(0, 6, 0, 0)
    L.BackgroundTransparency = 1
    L.Text = "— " .. title
    L.TextColor3 = CFG.TextDim
    L.Font = Enum.Font.GothamBold
    L.TextSize = CFG.Menu.textSize - 1
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.ZIndex = 7
    return F
end

function CreateBtn(parent, text, bg, cb)
    local B = Instance.new("TextButton", parent)
    B.Size = UDim2.new(1, 0, 0, 36)
    B.BackgroundColor3 = bg or CFG.Card
    B.Text = text
    B.TextColor3 = CFG.Text
    B.Font = Enum.Font.GothamBold
    B.TextSize = CFG.Menu.textSize - 1
    B.ZIndex = 6
    UX.corner(B, 8)
    UX.stroke(B, CFG.Border, 1)
    UX.hover(B, bg or CFG.Card, 1.3)
    UX.ripple(B)
    
    local ot = text
    local oc = bg or CFG.Card
    B.MouseButton1Click:Connect(function()
        if not Alive then return end
        PlayClick()
        CFG.Stats.totalActions = (CFG.Stats.totalActions or 0) + 1
        B.Text = "⏳ ..."
        B.TextColor3 = Color3.fromRGB(255, 200, 100)
        TweenService:Create(B, TweenInfo.new(0.1), {BackgroundColor3 = CFG.Theme}):Play()
        task.spawn(function()
            pcall(cb)
            task.wait(0.35)
            if B and B.Parent then
                B.Text = ot
                B.TextColor3 = CFG.Text
                TweenService:Create(B, TweenInfo.new(0.2), {BackgroundColor3 = oc}):Play()
            end
        end)
    end)
    return B
end

function CreateCard(parent, h)
    local C = Instance.new("Frame", parent)
    C.Size = UDim2.new(1, 0, 0, h or 60)
    C.BackgroundColor3 = CFG.Card
    C.BackgroundTransparency = 1 - CFG.Menu.opacity
    C.BorderSizePixel = 0
    C.ZIndex = 6
    UX.corner(C, 8)
    UX.stroke(C, CFG.Border, 1)
    return C
end

function CreateLabel(parent, text, yPos, rich)
    local L = Instance.new("TextLabel", parent)
    L.Size = UDim2.new(1, -24, 0, 20)
    L.Position = UDim2.new(0, 12, 0, yPos)
    L.BackgroundTransparency = 1
    L.Text = text
    L.RichText = rich ~= false
    L.TextColor3 = CFG.Text
    L.Font = Enum.Font.Gotham
    L.TextSize = CFG.Menu.textSize
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.ZIndex = 7
    return L
end

function CreateDropdown(parent, text, options, default, cb)
    local F = Instance.new("Frame", parent)
    F.Size = UDim2.new(1, 0, 0, 40)
    F.BackgroundColor3 = CFG.Card
    F.BackgroundTransparency = 1 - CFG.Menu.opacity
    F.BorderSizePixel = 0
    F.ClipsDescendants = false
    F.ZIndex = 6
    UX.corner(F, 8)
    UX.stroke(F, CFG.Border, 1)
    
    local L = Instance.new("TextLabel", F)
    L.Size = UDim2.new(0.5, 0, 1, 0)
    L.Position = UDim2.new(0, 12, 0, 0)
    L.Text = text
    L.TextColor3 = CFG.Text
    L.Font = Enum.Font.Gotham
    L.TextSize = CFG.Menu.textSize
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.BackgroundTransparency = 1
    L.ZIndex = 7
    
    local Cur = Instance.new("TextButton", F)
    Cur.Size = UDim2.new(0, 100, 0, 26)
    Cur.Position = UDim2.new(1, -112, 0.5, -13)
    Cur.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Cur.Text = tostring(default)
    Cur.TextColor3 = Color3.fromRGB(220, 220, 220)
    Cur.Font = Enum.Font.GothamBold
    Cur.TextSize = CFG.Menu.textSize - 1
    Cur.ZIndex = 8
    UX.corner(Cur, 6)
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
            listFrame.Size = UDim2.new(0, 100, 0, #options * 24 + 8)
            listFrame.Position = UDim2.new(1, -112, 1, 4)
            listFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
            listFrame.BorderSizePixel = 0
            listFrame.ZIndex = 100
            UX.corner(listFrame, 6)
            UX.stroke(listFrame, CFG.BorderHi, 1)
            
            for i, opt in ipairs(options) do
                local OBtn = Instance.new("TextButton", listFrame)
                OBtn.Size = UDim2.new(1, -8, 0, 22)
                OBtn.Position = UDim2.new(0, 4, 0, 4 + (i-1) * 24)
                OBtn.BackgroundColor3 = (tostring(opt) == tostring(default)) and CFG.BorderHi or Color3.fromRGB(30, 30, 30)
                OBtn.Text = tostring(opt)
                OBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                OBtn.Font = Enum.Font.Gotham
                OBtn.TextSize = CFG.Menu.textSize - 2
                OBtn.ZIndex = 101
                UX.corner(OBtn, 4)
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
-- [13/32] СИСТЕМА ВКЛАДОК (11 вкладок)
-- ═══════════════════════════════════════════════════════════════════════════
local TAB_NAMES = {
    Aim      = "🎯",
    Combat   = "⚔",
    Move     = "🏃",
    Visual   = "👁",
    Graphics = "🎨",
    Network  = "📡",
    Special  = "🛡",
    Tracker  = "👥",
    Combo    = "⚡",
    Chat     = "💬",
    Settings = "⚙",
}

local Tabs = {}
local Pages = {}
local ActiveTabName = "Aim"

local function CreateTabBtn(name, order)
    local TBtn = Instance.new("TextButton")
    TBtn.Size = UDim2.new(0, 40, 0, 28)
    TBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
    TBtn.Text = TAB_NAMES[name] or name
    TBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
    TBtn.Font = Enum.Font.GothamBold
    TBtn.TextSize = 13
    TBtn.LayoutOrder = order
    TBtn.Parent = TB
    UX.corner(TBtn, 6)
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
    PL.Padding = UDim.new(0, 5)
    PL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        if Alive and Cont and P.Visible then
            Cont.CanvasSize = UDim2.new(0, 0, 0, PL.AbsoluteContentSize.Y + 15)
        end
    end)
    return P, PL
end

for _, n in ipairs({"Aim","Combat","Move","Visual","Graphics","Network",
                    "Special","Tracker","Combo","Chat","Settings"}) do
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
        TweenService:Create(td.Button, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {
            BackgroundColor3 = isA and CFG.Theme or Color3.fromRGB(24, 24, 24)
        }):Play()
        td.Button.TextColor3 = isA and Color3.fromRGB(20, 20, 20) or Color3.fromRGB(150, 150, 150)
    end
    ActiveTabName = name
    Cont.CanvasSize = UDim2.new(0, 0, 0, Tabs[name].Layout.AbsoluteContentSize.Y + 15)
    Cont.CanvasPosition = Vector2.new(0, 0)
end

for tn, td in pairs(Tabs) do
    td.Button.MouseButton1Click:Connect(function()
        if Alive then PlayClick(); SwitchTab(tn) end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════
-- [14/32] АЙМБОТ (логика)
-- ═══════════════════════════════════════════════════════════════════════════
local AimBot = {currentTarget = nil, lastFireTime = 0, targetLockTime = 0, hits = 0}

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
                local skipTeam = false
                if CFG.Aim.teamCheck and p.Team and LocalPlayer.Team and p.Team == LocalPlayer.Team then
                    skipTeam = true
                end
                if not skipTeam then
                    local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local dist = (myPos - hrp.Position).Magnitude
                        if dist <= CFG.Aim.maxDist then
                            local part = p.Character:FindFirstChild(CFG.Aim.targetPart)
                            if part then
                                local skip = false
                                if CFG.Aim.wallCheck or CFG.Aim.onlyVisible then
                                    local ok, vis = pcall(function()
                                        local ray = Ray.new(cam.CFrame.Position,
                                            (part.Position - cam.CFrame.Position).Unit * 500)
                                        local hit = Workspace:FindPartOnRay(ray, LocalPlayer.Character)
                                        return hit and (hit == part or hit:IsDescendantOf(p.Character))
                                    end)
                                    if ok and not vis then skip = true end
                                end
                                if not skip then
                                    local sp, onScreen = cam:WorldToViewportPoint(part.Position)
                                    if onScreen then
                                        local fovDist = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                                        if fovDist <= CFG.Aim.fov then
                                            local score = fovDist
                                            if CFG.Aim.priority == "Distance" then
                                                score = dist
                                            elseif CFG.Aim.priority == "Health" then
                                                score = hum.Health
                                            end
                                            if score < bestScore then
                                                bestScore = score
                                                best = {
                                                    part = part, player = p, dist = dist,
                                                    screenPos = Vector2.new(sp.X, sp.Y),
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
local AimFOVStroke = UX.stroke(AimFOVCircle, CFG.Theme, 1, 0.6)

local AimTargetLine = Instance.new("Frame", SG)
AimTargetLine.Size = UDim2.new(0, 100, 0, 1)
AimTargetLine.Position = UDim2.new(0.5, 0, 0.5, 0)
AimTargetLine.BackgroundColor3 = CFG.Theme
AimTargetLine.BorderSizePixel = 0
AimTargetLine.AnchorPoint = Vector2.new(0, 0.5)
AimTargetLine.Visible = false
AimTargetLine.ZIndex = 4

RunService.RenderStepped:Connect(function()
    if not Alive then return end
    
    if CFG.Aim.on and CFG.Aim.showFOVCircle then
        AimFOVCircle.Visible = true
        AimFOVCircle.Size = UDim2.new(0, CFG.Aim.fov * 2, 0, CFG.Aim.fov * 2)
        AimFOVStroke.Transparency = 0.4 + math.sin(tick() * 3) * 0.2
        if AimBot.currentTarget then
            AimFOVStroke.Color = CFG.Theme
            AimFOVStroke.Transparency = 0.2
        else
            AimFOVStroke.Color = CFG.TextDim
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
    
    local target = nil
    if CFG.Aim.targetLock and AimBot.currentTarget and (tick() - AimBot.targetLockTime) < CFG.Aim.lockTime then
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
    end
    
    AimBot.currentTarget = target
    if not target then
        AimTargetLine.Visible = false
        return
    end
    
    local targetPos = target.part.Position
    if CFG.Aim.prediction > 0 then
        targetPos = targetPos + target.velocity * CFG.Aim.prediction
    end
    
    if CFG.Aim.mode == "Camera" then
        cam.CFrame = cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position, targetPos), CFG.Aim.smooth)
    elseif CFG.Aim.mode == "Instant" then
        cam.CFrame = CFrame.new(cam.CFrame.Position, targetPos)
    end
    
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
    else
        AimTargetLine.Visible = false
    end
    
    if CFG.Aim.autoFire then
        local now = tick()
        if now - AimBot.lastFireTime >= CFG.Aim.autoFireDelay then
            AimBot.lastFireTime = now
            AimBot.hits = AimBot.hits + 1
            CFG.Stats.aimbotHits = (CFG.Stats.aimbotHits or 0) + 1
            pcall(function()
                if VirtualUser then
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton1(Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2))
                end
            end)
        end
    end
end)

-- Hitbox Expander
task.spawn(function()
    while Alive and task.wait(0.3) do
        if CFG.Aim.hitboxExpand then
            pcall(function()
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character then
                        local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                        if hrp and not hrp:GetAttribute("DW_HB_Orig") then
                            hrp:SetAttribute("DW_HB_Orig", hrp.Size.X)
                            hrp.Size = Vector3.new(CFG.Aim.hitboxSize, CFG.Aim.hitboxSize, CFG.Aim.hitboxSize)
                            hrp.Transparency = 1
                            hrp.CanCollide = false
                        end
                    end
                end
            end)
        else
            pcall(function()
                for _, p in ipairs(Players:GetPlayers()) do
                    if p.Character then
                        local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                        if hrp and hrp:GetAttribute("DW_HB_Orig") then
                            local orig = hrp:GetAttribute("DW_HB_Orig")
                            hrp.Size = Vector3.new(orig, orig, orig)
                            hrp.Transparency = 0
                            hrp.CanCollide = true
                            hrp:SetAttribute("DW_HB_Orig", nil)
                        end
                    end
                end
            end)
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- [15/32] UI АЙМБОТА
-- ═══════════════════════════════════════════════════════════════════════════
local aP = Pages["Aim"]
CreateSection(aP, "🎯 Основное")
CreateToggle(aP, "Включить Аймбот", false, function(s)
    CFG.Aim.on = s
    PushNotify("Аймбот", s and "Активирован" or "Отключён", s and "success" or "warn")
end)
CreateDropdown(aP, "Режим работы", {"Camera", "Instant"}, CFG.Aim.mode, function(v)
    CFG.Aim.mode = v
end)
CreateDropdown(aP, "Целевая часть", {"Head", "HumanoidRootPart", "UpperTorso"},
    CFG.Aim.targetPart, function(v) CFG.Aim.targetPart = v end)
CreateDropdown(aP, "Приоритет", {"Distance", "FOV", "Health"},
    CFG.Aim.priority, function(v) CFG.Aim.priority = v end)

CreateSection(aP, "⚙ Точная настройка")
CreateSlider(aP, "FOV (радиус)", 30, 600, 150, function(v) CFG.Aim.fov = v end)
CreateSlider(aP, "Сглаживание ×100", 10, 100, 35, function(v) CFG.Aim.smooth = v / 100 end)
CreateSlider(aP, "Дистанция", 50, 1500, 500, function(v) CFG.Aim.maxDist = v end)
CreateSlider(aP, "Предсказание ×100", 0, 50, 15, function(v) CFG.Aim.prediction = v / 100 end)
CreateSlider(aP, "Удержание цели ×10 сек", 0, 30, 5, function(v) CFG.Aim.lockTime = v / 10 end)

CreateSection(aP, "🔒 Фильтры")
CreateToggle(aP, "Проверка команды", true, function(s) CFG.Aim.teamCheck = s end)
CreateToggle(aP, "Проверка стен", true, function(s) CFG.Aim.wallCheck = s end)
CreateToggle(aP, "Только видимые", true, function(s) CFG.Aim.onlyVisible = s end)
CreateToggle(aP, "Удержание цели", true, function(s) CFG.Aim.targetLock = s end)

CreateSection(aP, "🎨 Визуальная часть")
CreateToggle(aP, "FOV круг", true, function(s) CFG.Aim.showFOVCircle = s end)
CreateToggle(aP, "Линия к цели", true, function(s) CFG.Aim.showTargetLine = s end)

CreateSection(aP, "📦 Hitbox Expander")
CreateToggle(aP, "Расширять хитбокс", false, function(s)
    CFG.Aim.hitboxExpand = s
    PushNotify("Hitbox", s and "ВКЛ" or "ВЫКЛ", s and "success" or "warn")
end)
CreateSlider(aP, "Размер ×10", 10, 100, 20, function(v) CFG.Aim.hitboxSize = v / 10 end)

CreateSection(aP, "🔫 Авто-выстрел")
CreateToggle(aP, "Включить", false, function(s) CFG.Aim.autoFire = s end)
CreateSlider(aP, "Задержка (мс)", 30, 500, 150, function(v) CFG.Aim.autoFireDelay = v / 1000 end)

CreateSection(aP, "📊 Статус аймбота")
local aimCard = CreateCard(aP, 90)
local aimStatusLbl = CreateLabel(aimCard, "Цель: <font color='#808090'>не найдена</font>", 8)
local aimInfoLbl = CreateLabel(aimCard, "Режим: Camera · FOV: 150", 32)
local aimStatsLbl = CreateLabel(aimCard, "Дист: — · HP: —", 56)

task.spawn(function()
    while Alive do
        task.wait(0.2)
        if CFG.Aim.on then
            if AimBot.currentTarget then
                aimStatusLbl.Text = "Цель: <font color='#FFFFFF'>" ..
                    AimBot.currentTarget.player.Name .. "</font>"
                aimInfoLbl.Text = string.format(
                    "Режим: <font color='#A0A0A0'>%s</font> · FOV: <font color='#FFFFFF'>%d</font>",
                    CFG.Aim.mode, CFG.Aim.fov)
                aimStatsLbl.Text = string.format(
                    "Дист: <font color='#A0A0A0'>%d</font> · HP: <font color='#FFFFFF'>%d</font>",
                    math.floor(AimBot.currentTarget.dist),
                    math.floor(AimBot.currentTarget.health))
            else
                aimStatusLbl.Text = "Цель: <font color='#808090'>не найдена</font>"
                aimInfoLbl.Text = "Режим: " .. CFG.Aim.mode .. " · FOV: " .. CFG.Aim.fov
                aimStatsLbl.Text = "Дист: — · HP: —"
            end
        else
            aimStatusLbl.Text = "Цель: <font color='#808090'>Аймбот выключен</font>"
            aimInfoLbl.Text = "Режим: — · FOV: —"
            aimStatsLbl.Text = "Дист: — · HP: —"
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- [16/32] UI БОЯ (ESP + Kill Aura + Auto)
-- ═══════════════════════════════════════════════════════════════════════════
local cP = Pages["Combat"]
CreateSection(cP, "🎯 ESP Игроки")
CreateToggle(cP, "Включить ESP", false, function(s)
    CFG.ESP.on = s
    if s then CFG.Stats.espActivations = (CFG.Stats.espActivations or 0) + 1 end
    PushNotify("ESP", s and "Включён" or "Отключён", s and "success" or "warn")
end)
CreateSlider(cP, "Прозрачность силуэта %", 0, 100, 50, function(v) CFG.ESP.fill = v / 100 end)
CreateSlider(cP, "Прозрачность обводки %", 0, 100, 0, function(v) CFG.ESP.outline = v / 100 end)
CreateSlider(cP, "Дистанция ESP", 50, 2000, 500, function(v) CFG.ESP.maxDist = v end)
CreateToggle(cP, "RGB-переливание", false, function(s) CFG.ESP.rgb = s end)

CreateSection(cP, "📦 ESP Предметы")
CreateToggle(cP, "Подсветка предметов", false, function(s)
    CFG.ESP.items = s
    PushNotify("Item ESP", s and "ВКЛ" or "ВЫКЛ", s and "success" or "warn")
end)
CreateToggle(cP, "Подсветка сундуков", false, function(s) CFG.ESP.chests = s end)

CreateSection(cP, "⚔ Kill Aura")
CreateToggle(cP, "Включить Kill Aura", false, function(s)
    CFG.KillAura.on = s
    PushNotify("Kill Aura", s and "ВКЛ" or "ВЫКЛ", s and "success" or "warn")
end)
CreateSlider(cP, "Радиус атаки", 5, 50, 15, function(v) CFG.KillAura.radius = v end)
CreateSlider(cP, "Задержка (мс)", 50, 1000, 100, function(v) CFG.KillAura.delay = v / 1000 end)

CreateSection(cP, "🤖 Автоматизация")
CreateToggle(cP, "Автокликер", false, function(s) CFG.Auto.click = s end)
CreateSlider(cP, "Интервал клика (мс)", 20, 500, 100, function(v) CFG.Auto.clickMs = v end)
CreateToggle(cP, "Автопрыжок", false, function(s) CFG.Auto.jump = s end)
CreateSlider(cP, "Интервал прыжка (мс)", 100, 2000, 300, function(v) CFG.Auto.jumpMs = v end)

-- Автокликер
task.spawn(function()
    while Alive do
        task.wait(0.05)
        if CFG.Auto.click then
            pcall(function()
                if VirtualUser then
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton1(Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2))
                end
            end)
            task.wait(math.clamp(CFG.Auto.clickMs / 1000, 0.01, 1))
        end
    end
end)

-- Автопрыжок
task.spawn(function()
    while Alive do
        task.wait(0.05)
        if CFG.Auto.jump then
            pcall(function()
                local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
            end)
            task.wait(CFG.Auto.jumpMs / 1000)
        end
    end
end)

-- Kill Aura
task.spawn(function()
    while Alive do
        task.wait(CFG.KillAura.delay or 0.1)
        if CFG.KillAura.on then
            pcall(function()
                local mc = LocalPlayer.Character
                local mr = mc and mc:FindFirstChild("HumanoidRootPart")
                if not mr then return end
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character then
                        local skipTeam = false
                        if CFG.KillAura.teamCheck and p.Team and LocalPlayer.Team and p.Team == LocalPlayer.Team then
                            skipTeam = true
                        end
                        if not skipTeam then
                            local hum = p.Character:FindFirstChildOfClass("Humanoid")
                            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                            if hum and hum.Health > 0 and hrp then
                                if (mr.Position - hrp.Position).Magnitude < CFG.KillAura.radius then
                                    local tool = mc:FindFirstChildOfClass("Tool")
                                    if tool then tool:Activate() end
                                    if firetouchinterest then
                                        firetouchinterest(mr, hrp, 0)
                                        task.wait()
                                        firetouchinterest(mr, hrp, 1)
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- ESP игроки
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
                    hl.FillColor = CFG.ESP.rgb and Color3.fromHSV((tick() * 0.3) % 1, 0.5, 1) or CFG.Theme
                    hl.OutlineColor = Color3.fromRGB(0, 0, 0)
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

-- Item ESP
task.spawn(function()
    while Alive and task.wait(0.5) do
        if CFG.ESP.items then
            pcall(function()
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and obj.Name ~= "Baseplate"
                       and obj.Name ~= "Terrain" and not Players:GetPlayerFromCharacter(obj.Parent) then
                        local hl = obj:FindFirstChild("DW_ItemHL")
                        if not hl then
                            hl = Instance.new("Highlight")
                            hl.Name = "DW_ItemHL"
                            hl.FillColor = CFG.Theme
                            hl.OutlineColor = Color3.fromRGB(0, 0, 0)
                            hl.FillTransparency = 0.5
                            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                            hl.Parent = obj
                        end
                        hl.Enabled = true
                    end
                end
            end)
        else
            pcall(function()
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    local hl = obj:FindFirstChild("DW_ItemHL")
                    if hl then hl:Destroy() end
                end
            end)
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- [17/32] UI ДВИЖЕНИЯ
-- ═══════════════════════════════════════════════════════════════════════════
local mP = Pages["Move"]
CreateSection(mP, "🏃 Скорость")
CreateSlider(mP, "WalkSpeed", 16, 500, 16, function(v)
    CFG.Move.ws = v
    pcall(function()
        local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if h then h.WalkSpeed = v end
    end)
end)
CreateSlider(mP, "JumpPower", 50, 500, 50, function(v)
    CFG.Move.jp = v
    pcall(function()
        local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if h then h.UseJumpPower = true; h.JumpPower = v end
    end)
end)
CreateToggle(mP, "Бесконечный прыжок", false, function(s) CFG.Move.infJump = s end)
CreateToggle(mP, "Noclip (сквозь стены)", false, function(s)
    CFG.Move.noclip = s
    PushNotify("Noclip", s and "ВКЛ" or "ВЫКЛ", s and "success" or "warn")
end)

CreateSection(mP, "✈ Полёт")
CreateToggle(mP, "Включить полёт", false, function(s)
    CFG.Move.flyOn = s
    PushNotify("Полёт", s and "Взлёт" or "Посадка", s and "success" or "warn")
end)
CreateSlider(mP, "Скорость полёта", 20, 500, 60, function(v) CFG.Move.fs = v end)

CreateSection(mP, "🌍 Гравитация")
CreateToggle(mP, "Своя гравитация", false, function(s) CFG.Move.gravOn = s end)
CreateSlider(mP, "Значение", 0, 300, 196, function(v) CFG.Move.grav = v end)

-- Полёт
local flyBV, flyBG, flyConn
local lastFlyPos = nil
local function StartFly()
    if flyConn then return end
    pcall(function()
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
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
        lastFlyPos = hrp.Position
        flyConn = RunService.Heartbeat:Connect(function()
            if not Alive or not CFG.Move.flyOn then
                if flyBV then flyBV:Destroy() end
                if flyBG then flyBG:Destroy() end
                if flyConn then flyConn:Disconnect() end
                flyBV, flyBG, flyConn = nil, nil, nil
                return
            end
            local r = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not r then return end
            if lastFlyPos then
                CFG.Stats.flyDistance = (CFG.Stats.flyDistance or 0) + (r.Position - lastFlyPos).Magnitude
                lastFlyPos = r.Position
            end
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
        local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
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
-- [18/32] UI ВИЗУАЛА (HUD + Teleport)
-- ═══════════════════════════════════════════════════════════════════════════
local vP = Pages["Visual"]
CreateSection(vP, "📺 HUD")
CreateToggle(vP, "FPS + Пинг", true, function(s)
    CFG.HUD.wm = s
    WM.Visible = s
end)
CreateToggle(vP, "Координаты", false, function(s)
    CFG.HUD.coords = s
    CoordHUD.Visible = s
end)
CreateToggle(vP, "Память", false, function(s) CFG.HUD.memory = s end)
CreateToggle(vP, "Скорость", false, function(s) CFG.HUD.speed = s end)
CreateToggle(vP, "Цель аймбота", true, function(s) CFG.HUD.showAimTarget = s end)

CreateSection(vP, "🚀 Телепорт")
local tpBox = Instance.new("TextBox", vP)
tpBox.Size = UDim2.new(1, 0, 0, 36)
tpBox.BackgroundColor3 = CFG.Card
tpBox.PlaceholderText = "Введи имя игрока..."
tpBox.Text = ""
tpBox.TextColor3 = CFG.Text
tpBox.PlaceholderColor3 = CFG.SubText
tpBox.Font = Enum.Font.Gotham
tpBox.TextSize = CFG.Menu.textSize
tpBox.ClearTextOnFocus = false
tpBox.ZIndex = 7
UX.corner(tpBox, 8)
UX.stroke(tpBox, CFG.Border, 1)

local function TPToPlayer(name)
    if name == "" then
        PushNotify("Телепорт", "Введи имя игрока", "warn")
        return
    end
    local target = Players:FindFirstChild(name)
    if not target then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and string.find(string.lower(p.Name), string.lower(name), 1, true) then
                target = p; break
            end
        end
    end
    if target and target.Character then
        local hrp = target.Character:FindFirstChild("HumanoidRootPart")
        local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp and myHrp then
            myHrp.CFrame = CFrame.new(hrp.Position + Vector3.new(0, 3, 0))
            PushNotify("Телепорт", "→ " .. target.Name, "success")
        end
    else
        PushNotify("Телепорт", "Игрок не найден", "error")
    end
end

local tpBtnRow = Instance.new("Frame", vP)
tpBtnRow.Size = UDim2.new(1, 0, 0, 36)
tpBtnRow.BackgroundTransparency = 1
tpBtnRow.ZIndex = 6

local tpBtn = Instance.new("TextButton", tpBtnRow)
tpBtn.Size = UDim2.new(0.48, 0, 1, 0)
tpBtn.BackgroundColor3 = CFG.Card
tpBtn.Text = "→ К игроку"
tpBtn.TextColor3 = CFG.Text
tpBtn.Font = Enum.Font.GothamBold
tpBtn.TextSize = CFG.Menu.textSize - 1
tpBtn.ZIndex = 7
UX.corner(tpBtn, 8)
UX.stroke(tpBtn, CFG.Border, 1)
UX.ripple(tpBtn)
tpBtn.MouseButton1Click:Connect(function()
    PlayClick()
    TPToPlayer(tpBox.Text)
end)

local tpNearest = Instance.new("TextButton", tpBtnRow)
tpNearest.Size = UDim2.new(0.48, 0, 1, 0)
tpNearest.Position = UDim2.new(0.52, 0, 0, 0)
tpNearest.BackgroundColor3 = CFG.Card
tpNearest.Text = "→ Ближайший"
tpNearest.TextColor3 = CFG.Text
tpNearest.Font = Enum.Font.GothamBold
tpNearest.TextSize = CFG.Menu.textSize - 1
tpNearest.ZIndex = 7
UX.corner(tpNearest, 8)
UX.stroke(tpNearest, CFG.Border, 1)
UX.ripple(tpNearest)
tpNearest.MouseButton1Click:Connect(function()
    PlayClick()
    local mc = LocalPlayer.Character
    local mr = mc and mc:FindFirstChild("HumanoidRootPart")
    if not mr then return end
    local best, bd = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local d = (mr.Position - hrp.Position).Magnitude
                if d < bd then bd = d; best = p end
            end
        end
    end
    if best then TPToPlayer(best.Name) end
end)

-- HUD элементы
CoordHUD = Instance.new("TextLabel", SG)
CoordHUD.Size = UDim2.new(0, 220, 0, 24)
CoordHUD.Position = UDim2.new(0.5, -110, 0, 4)
CoordHUD.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
CoordHUD.BackgroundTransparency = 0.3
CoordHUD.TextColor3 = CFG.Text
CoordHUD.Font = Enum.Font.Code
CoordHUD.TextSize = 11
CoordHUD.Text = "X: 0 Y: 0 Z: 0"
CoordHUD.Visible = false
CoordHUD.ZIndex = 25
UX.corner(CoordHUD, 6)
UX.stroke(CoordHUD, CFG.BorderHi, 1)

WM = Instance.new("Frame", SG)
WM.Size = UDim2.new(0, 200, 0, 62)
WM.Position = UDim2.new(1, -210, 0, 6)
WM.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
WM.BackgroundTransparency = 0.2
WM.BorderSizePixel = 0
WM.Visible = true
WM.ZIndex = 25
UX.corner(WM, 6)
UX.stroke(WM, CFG.BorderHi, 1)

local WMTitle = Instance.new("TextLabel", WM)
WMTitle.Size = UDim2.new(1, -14, 0, 16)
WMTitle.Position = UDim2.new(0, 7, 0, 2)
WMTitle.BackgroundTransparency = 1
WMTitle.Text = "🗡 DW · SHADOW ELITE"
WMTitle.TextColor3 = CFG.Text
WMTitle.Font = Enum.Font.GothamBold
WMTitle.TextSize = 10
WMTitle.TextXAlignment = Enum.TextXAlignment.Left

WMStats = Instance.new("TextLabel", WM)
WMStats.Size = UDim2.new(1, -14, 0, 40)
WMStats.Position = UDim2.new(0, 7, 0, 20)
WMStats.BackgroundTransparency = 1
WMStats.RichText = true
WMStats.Text = "FPS: — | Ping: —"
WMStats.TextColor3 = CFG.TextDim
WMStats.Font = Enum.Font.Code
WMStats.TextSize = 10
WMStats.TextXAlignment = Enum.TextXAlignment.Left
WMStats.TextYAlignment = Enum.TextYAlignment.Top

AimTargetHUD = Instance.new("TextLabel", SG)
AimTargetHUD.Size = UDim2.new(0, 240, 0, 22)
AimTargetHUD.Position = UDim2.new(0.5, -120, 0, 32)
AimTargetHUD.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
AimTargetHUD.BackgroundTransparency = 0.3
AimTargetHUD.TextColor3 = CFG.Text
AimTargetHUD.Font = Enum.Font.Code
AimTargetHUD.TextSize = 11
AimTargetHUD.RichText = true
AimTargetHUD.Text = ""
AimTargetHUD.Visible = false
AimTargetHUD.ZIndex = 25
UX.corner(AimTargetHUD, 6)
UX.stroke(AimTargetHUD, CFG.BorderHi, 1)

print("[DW v7.0] Часть 1/2 загружена.")
print("[DW v7.0] Вкладок создано: " .. tostring(#Tabs))
print("[DW v7.0] Напиши 'часть 2' — я дам остаток.")