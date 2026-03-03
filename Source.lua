--[[
    ╔═══════════════════════════════════════════════════╗
    ║           RemingtonHub  UI Library                ║
    ║              by  RaihjnDev  v2.1                  ║
    ║                                                   ║
    ║   Frosted Glass  ·  Ocean Ink  ·  Personal        ║
    ╚═══════════════════════════════════════════════════╝

    CARA PAKAI (loadstring):
    ─────────────────────────────────────────────────────
    local RHub = loadstring(game:HttpGet("RAW_URL_DISINI"))()

    local Win = RHub:Window({
        Title    = "RemingtonHub",
        SubTitle = "by RaihjnDev",
        Theme    = "Ocean",   -- "Ocean" | "Void" | "Rose"
        Key      = false,     -- atau string kunci e.g. "abc123"
    })

    local Tab = Win:Tab("Auto Farm", "🌾")

    Tab:Toggle("Auto Farm", "Aktifkan auto farm", false, function(v) end)
    Tab:Slider("Walk Speed", "", 16, 300, 16, " ws", function(v) end)
    Tab:Button("Teleport Spawn", "Kembali ke titik spawn", function() end)
    Tab:Input("NPC Target", "Nama NPC...", function(v) end)
    Tab:Label("Versi 2.1 — RaihjnDev")
    Tab:Separator("Section Title")
    ─────────────────────────────────────────────────────
]]

local RHub = {}
RHub.__index = RHub

-- ─────────────────────────────────────────────────────
--  SERVICES
-- ─────────────────────────────────────────────────────
local TweenService  = game:GetService("TweenService")
local UserInput     = game:GetService("UserInputService")
local RunService    = game:GetService("RunService")
local Players       = game:GetService("Players")
local CoreGui       = game:GetService("CoreGui")
local LP            = Players.LocalPlayer

-- ─────────────────────────────────────────────────────
--  TEMA
-- ─────────────────────────────────────────────────────
local Themes = {
    Ocean = {
        -- glass panels
        Glass       = Color3.fromRGB(8,  18,  36),
        GlassAlpha  = 0.18,   -- transparansi panel utama
        Sidebar     = Color3.fromRGB(6,  14,  28),
        SideAlpha   = 0.25,
        Card        = Color3.fromRGB(12, 24,  50),
        CardAlpha   = 0.45,
        CardHover   = Color3.fromRGB(16, 32,  64),
        -- accents
        Accent      = Color3.fromRGB(0,  175, 235),
        AccentB     = Color3.fromRGB(0,  100, 170),
        Glow        = Color3.fromRGB(90, 215, 255),
        -- borders
        Border      = Color3.fromRGB(0,  80,  140),
        BorderBright= Color3.fromRGB(0,  160, 220),
        -- text
        Text        = Color3.fromRGB(215, 235, 255),
        TextSub     = Color3.fromRGB(110, 155, 200),
        TextDim     = Color3.fromRGB(55,  90,  135),
        -- status
        Green       = Color3.fromRGB(55,  220, 140),
        White       = Color3.fromRGB(255, 255, 255),
    },
    Void = {
        Glass       = Color3.fromRGB(10, 8,   22),
        GlassAlpha  = 0.18,
        Sidebar     = Color3.fromRGB(7,  6,   16),
        SideAlpha   = 0.25,
        Card        = Color3.fromRGB(18, 14,  42),
        CardAlpha   = 0.45,
        CardHover   = Color3.fromRGB(24, 18,  56),
        Accent      = Color3.fromRGB(140, 90, 255),
        AccentB     = Color3.fromRGB(80,  50, 180),
        Glow        = Color3.fromRGB(190, 150,255),
        Border      = Color3.fromRGB(70,  40, 140),
        BorderBright= Color3.fromRGB(140, 90, 255),
        Text        = Color3.fromRGB(220, 215, 255),
        TextSub     = Color3.fromRGB(140, 120, 200),
        TextDim     = Color3.fromRGB(80,  65,  140),
        Green       = Color3.fromRGB(55,  220, 140),
        White       = Color3.fromRGB(255, 255, 255),
    },
    Rose = {
        Glass       = Color3.fromRGB(24, 8,   18),
        GlassAlpha  = 0.18,
        Sidebar     = Color3.fromRGB(18, 6,   14),
        SideAlpha   = 0.25,
        Card        = Color3.fromRGB(42, 14,  28),
        CardAlpha   = 0.45,
        CardHover   = Color3.fromRGB(55, 18,  36),
        Accent      = Color3.fromRGB(235, 70, 130),
        AccentB     = Color3.fromRGB(160, 40,  90),
        Glow        = Color3.fromRGB(255, 130, 180),
        Border      = Color3.fromRGB(140, 40,  80),
        BorderBright= Color3.fromRGB(235, 70, 130),
        Text        = Color3.fromRGB(255, 220, 235),
        TextSub     = Color3.fromRGB(200, 140, 170),
        TextDim     = Color3.fromRGB(130, 75,  105),
        Green       = Color3.fromRGB(55,  220, 140),
        White       = Color3.fromRGB(255, 255, 255),
    },
}

-- ─────────────────────────────────────────────────────
--  HELPERS
-- ─────────────────────────────────────────────────────
local function tw(obj, props, t, es, ed)
    TweenService:Create(obj, TweenInfo.new(t or .18, es or Enum.EasingStyle.Quad, ed or Enum.EasingDirection.Out), props):Play()
end

local function make(class, parent, props)
    local o = Instance.new(class)
    if props then
        for k,v in pairs(props) do
            if k ~= "Parent" then
                pcall(function() o[k] = v end)
            end
        end
    end
    o.Parent = parent
    return o
end

local function corner(p, r)
    make("UICorner", p, {CornerRadius = UDim.new(0, r or 8)})
end

local function stroke(p, col, thick, trans)
    return make("UIStroke", p, {
        Color        = col or Color3.fromRGB(255,255,255),
        Thickness    = thick or 1,
        Transparency = trans or 0,
    })
end

local function pad(p, t, b, l, r)
    make("UIPadding", p, {
        PaddingTop    = UDim.new(0, t or 6),
        PaddingBottom = UDim.new(0, b or 6),
        PaddingLeft   = UDim.new(0, l or 8),
        PaddingRight  = UDim.new(0, r or 8),
    })
end

local function listLayout(p, dir, pad_, align)
    return make("UIListLayout", p, {
        SortOrder         = Enum.SortOrder.LayoutOrder,
        FillDirection     = dir or Enum.FillDirection.Vertical,
        Padding           = UDim.new(0, pad_ or 4),
        HorizontalAlignment = align or Enum.HorizontalAlignment.Left,
    })
end

local function autoCanvas(frame)
    local ll = frame:FindFirstChildOfClass("UIListLayout")
    if not ll then return end
    local function upd()
        frame.CanvasSize = UDim2.new(0, 0, 0, ll.AbsoluteContentSize.Y + 20)
    end
    ll:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(upd)
    upd()
end

-- Notifikasi instance (dibuat setelah GUI terbentuk)
local _notifHolder = nil
local _notifCount  = 0

local function notify(T, C_, col, dur)
    if not _notifHolder then return end
    _notifCount += 1
    local nf = make("Frame", _notifHolder, {
        Size             = UDim2.new(1,0,0,0),
        BackgroundColor3 = Color3.fromRGB(8,16,32),
        BackgroundTransparency = 0.2,
        BorderSizePixel  = 0,
        ClipsDescendants = true,
        LayoutOrder      = _notifCount,
    })
    corner(nf, 10)
    stroke(nf, col or Color3.fromRGB(0,175,235), 1.2, 0.2)

    -- Left bar
    make("Frame", nf, {
        Size             = UDim2.new(0,3,1,0),
        BackgroundColor3 = col or Color3.fromRGB(0,175,235),
        BorderSizePixel  = 0,
    })
    make("TextLabel", nf, {
        Size                 = UDim2.new(1,-16,0,16),
        Position             = UDim2.new(0,14,0,8),
        BackgroundTransparency=1,
        Text                 = T,
        TextColor3           = Color3.fromRGB(215,235,255),
        Font                 = Enum.Font.GothamBold,
        TextSize             = 12,
        TextXAlignment       = Enum.TextXAlignment.Left,
    })
    make("TextLabel", nf, {
        Size                 = UDim2.new(1,-16,0,28),
        Position             = UDim2.new(0,14,0,26),
        BackgroundTransparency=1,
        Text                 = C_,
        TextColor3           = Color3.fromRGB(110,155,200),
        Font                 = Enum.Font.Gotham,
        TextSize             = 10,
        TextXAlignment       = Enum.TextXAlignment.Left,
        TextWrapped          = true,
    })

    tw(nf, {Size=UDim2.new(1,0,0,58)}, .3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    task.delay(dur or 4, function()
        tw(nf, {Size=UDim2.new(1,0,0,0), BackgroundTransparency=1}, .25)
        task.wait(.3) pcall(function() nf:Destroy() end)
    end)
end

-- ─────────────────────────────────────────────────────
--  WINDOW
-- ─────────────────────────────────────────────────────
function RHub:Window(cfg)
    cfg = cfg or {}
    local title    = cfg.Title    or "RemingtonHub"
    local subtitle = cfg.SubTitle or "by RaihjnDev"
    local themeName= cfg.Theme    or "Ocean"
    local key      = cfg.Key
    local T        = Themes[themeName] or Themes.Ocean

    -- Cleanup
    pcall(function()
        if CoreGui:FindFirstChild("RHub_"..title) then
            CoreGui:FindFirstChild("RHub_"..title):Destroy()
        end
    end)

    -- ScreenGui
    local Gui = Instance.new("ScreenGui")
    Gui.Name           = "RHub_"..title
    Gui.ResetOnSpawn   = false
    Gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    Gui.DisplayOrder   = 999
    pcall(function() Gui.Parent = CoreGui end)
    if not Gui.Parent then Gui.Parent = LP:WaitForChild("PlayerGui") end

    -- ── SHADOW ──
    local Shadow = make("ImageLabel", Gui, {
        Size               = UDim2.new(0,560,0,560),
        Position           = UDim2.new(0.5,-280,0.5,-280),
        BackgroundTransparency=1,
        Image              = "rbxassetid://6014261963",
        ImageColor3        = T.AccentB,
        ImageTransparency  = 0.6,
        ScaleType          = Enum.ScaleType.Slice,
        SliceCenter        = Rect.new(49,49,450,450),
        ZIndex             = 0,
    })

    -- ── MAIN FRAME — FROSTED GLASS ──
    -- Outer frame buat shadow/border visual
    local Outer = make("Frame", Gui, {
        Name             = "Outer",
        Size             = UDim2.new(0,520,0,520),
        Position         = UDim2.new(0.5,-260,0.5,-260),
        BackgroundColor3 = T.Border,
        BackgroundTransparency = 0.7,
        BorderSizePixel  = 0,
        ZIndex           = 2,
    })
    corner(Outer, 16)

    -- Main window — transparan glass
    local Win = make("Frame", Outer, {
        Size             = UDim2.new(1,-2,1,-2),
        Position         = UDim2.new(0,1,0,1),
        BackgroundColor3 = T.Glass,
        BackgroundTransparency = T.GlassAlpha,
        BorderSizePixel  = 0,
        ClipsDescendants = true,
        ZIndex           = 3,
    })
    corner(Win, 15)

    -- Subtle inner glow border
    stroke(Win, T.BorderBright, 1, 0.7)

    -- Noise/grain overlay untuk glass effect
    make("ImageLabel", Win, {
        Size               = UDim2.new(1,0,1,0),
        BackgroundTransparency=1,
        Image              = "rbxassetid://9968344227",
        ImageTransparency  = 0.97,
        ZIndex             = 10,
        ScaleType          = Enum.ScaleType.Tile,
        TileSize           = UDim2.new(0,64,0,64),
    })

    -- Animasi masuk
    Outer.Size     = UDim2.new(0,0,0,0)
    Outer.Position = UDim2.new(0.5,0,0.5,0)
    Shadow.Size    = UDim2.new(0,0,0,0)
    Shadow.Position= UDim2.new(0.5,0,0.5,0)
    task.defer(function()
        tw(Outer,  {Size=UDim2.new(0,520,0,520), Position=UDim2.new(0.5,-260,0.5,-260)}, .42, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        tw(Shadow, {Size=UDim2.new(0,560,0,560), Position=UDim2.new(0.5,-280,0.5,-280)}, .42, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    end)

    -- ── TITLEBAR ──
    local TBar = make("Frame", Win, {
        Size             = UDim2.new(1,0,0,50),
        BackgroundColor3 = T.Sidebar,
        BackgroundTransparency = T.SideAlpha,
        BorderSizePixel  = 0,
        ZIndex           = 4,
    })

    -- accent shimmer line
    local shimmer = make("Frame", TBar, {
        Size             = UDim2.new(1,0,0,1),
        Position         = UDim2.new(0,0,1,-1),
        BackgroundColor3 = T.Accent,
        BorderSizePixel  = 0,
        ZIndex           = 5,
    })
    make("UIGradient", shimmer, {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0,   Color3.fromRGB(0,0,0)),
            ColorSequenceKeypoint.new(0.3, T.Glow),
            ColorSequenceKeypoint.new(0.7, T.Glow),
            ColorSequenceKeypoint.new(1,   Color3.fromRGB(0,0,0)),
        }),
    })
    -- shimmer animation
    task.spawn(function()
        local g = shimmer:FindFirstChildOfClass("UIGradient")
        local x = -1
        while shimmer and shimmer.Parent do
            x = x + 0.004
            if x > 1 then x = -1 end
            g.Offset = Vector2.new(x, 0)
            task.wait()
        end
    end)

    -- Icon pill — unik: pill shape bukan kotak biasa
    local IconPill = make("Frame", TBar, {
        Size             = UDim2.new(0,32,0,32),
        Position         = UDim2.new(0,12,0.5,-16),
        BackgroundColor3 = T.Accent,
        BackgroundTransparency = 0.1,
        BorderSizePixel  = 0,
        ZIndex           = 5,
    })
    corner(IconPill, 10)
    -- Gradient dalam icon
    make("UIGradient", IconPill, {
        Color    = ColorSequence.new(T.AccentB, T.Glow),
        Rotation = 135,
    })
    make("TextLabel", IconPill, {
        Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
        Text=string.sub(title,1,1), TextColor3=T.White,
        Font=Enum.Font.GothamBold, TextSize=16, ZIndex=6,
    })

    make("TextLabel", TBar, {
        Size=UDim2.new(0,200,0,18), Position=UDim2.new(0,52,0.5,-18),
        BackgroundTransparency=1, Text=title,
        TextColor3=T.Text, Font=Enum.Font.GothamBold, TextSize=15,
        TextXAlignment=Enum.TextXAlignment.Left, ZIndex=5,
    })
    make("TextLabel", TBar, {
        Size=UDim2.new(0,200,0,13), Position=UDim2.new(0,52,0.5,2),
        BackgroundTransparency=1, Text=subtitle,
        TextColor3=T.TextDim, Font=Enum.Font.Gotham, TextSize=10,
        TextXAlignment=Enum.TextXAlignment.Left, ZIndex=5,
    })

    -- Safe badge
    local sbg = make("Frame", TBar, {
        Size=UDim2.new(0,68,0,22), Position=UDim2.new(1,-128,0.5,-11),
        BackgroundColor3=Color3.fromRGB(5,28,18), BackgroundTransparency=0.3,
        BorderSizePixel=0, ZIndex=5,
    })
    corner(sbg,11)
    stroke(sbg, T.Green, 1, 0.4)
    local sdot = make("Frame", sbg, {
        Size=UDim2.new(0,6,0,6), Position=UDim2.new(0,8,0.5,-3),
        BackgroundColor3=T.Green, BorderSizePixel=0, ZIndex=6,
    })
    corner(sdot,99)
    make("TextLabel", sbg, {
        Size=UDim2.new(1,-20,1,0), Position=UDim2.new(0,20,0,0),
        BackgroundTransparency=1, Text="SAFE",
        TextColor3=T.Green, Font=Enum.Font.GothamBold, TextSize=10,
        TextXAlignment=Enum.TextXAlignment.Left, ZIndex=6,
    })
    task.spawn(function()
        while sdot and sdot.Parent do
            tw(sdot,{BackgroundTransparency=0.8},0.9) task.wait(0.9)
            tw(sdot,{BackgroundTransparency=0  },0.9) task.wait(0.9)
        end
    end)

    -- Btn minimize & close
    local function mkBtn(xOff, txt, bg)
        local b = make("TextButton", TBar, {
            Size=UDim2.new(0,26,0,26),
            Position=UDim2.new(1,xOff,0.5,-13),
            BackgroundColor3=bg or T.Card,
            BackgroundTransparency=bg and 0 or 0.5,
            BorderSizePixel=0,
            Text=txt,
            TextColor3=T.TextSub,
            Font=Enum.Font.GothamBold,
            TextSize=12,
            ZIndex=6,
        })
        corner(b,7)
        stroke(b, T.Border, 1, 0.5)
        b.MouseEnter:Connect(function() tw(b,{BackgroundTransparency=0.2},0.12) end)
        b.MouseLeave:Connect(function() tw(b,{BackgroundTransparency=bg and 0 or 0.5},0.12) end)
        return b
    end
    local BMin   = mkBtn(-60,"—",nil)
    local BClose = mkBtn(-28,"✕",Color3.fromRGB(190,38,50))

    -- Drag
    local drag,ds,sp = false,nil,nil
    TBar.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            drag=true ds=i.Position sp=Outer.Position
        end
    end)
    TBar.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end
    end)
    UserInput.InputChanged:Connect(function(i)
        if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local d=i.Position-ds
            local np=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y)
            Outer.Position  = np
            Shadow.Position = UDim2.new(np.X.Scale,np.X.Offset-20,np.Y.Scale,np.Y.Offset-20)
        end
    end)

    -- Close / Minimize
    BClose.MouseButton1Click:Connect(function()
        tw(Outer, {Size=UDim2.new(0,0,0,0),Position=UDim2.new(0.5,0,0.5,0)}, .3, Enum.EasingStyle.Back,Enum.EasingDirection.In)
        tw(Shadow,{ImageTransparency=1},.3)
        task.wait(.35) Gui:Destroy()
    end)
    local minimized=false
    BMin.MouseButton1Click:Connect(function()
        minimized=not minimized
        if minimized then
            tw(Outer,{Size=UDim2.new(0,520,0,50)}, .25, Enum.EasingStyle.Quad)
            tw(Shadow,{Size=UDim2.new(0,560,0,90)}, .25, Enum.EasingStyle.Quad)
            BMin.Text="▲"
        else
            tw(Outer,{Size=UDim2.new(0,520,0,520)}, .25, Enum.EasingStyle.Quad)
            tw(Shadow,{Size=UDim2.new(0,560,0,560)}, .25, Enum.EasingStyle.Quad)
            BMin.Text="—"
        end
    end)

    -- ── BODY ──
    local Body = make("Frame", Win, {
        Size=UDim2.new(1,0,1,-50), Position=UDim2.new(0,0,0,50),
        BackgroundTransparency=1, ClipsDescendants=true, ZIndex=3,
    })

    -- ── SIDEBAR ──
    local Sidebar = make("Frame", Body, {
        Size=UDim2.new(0,142,1,0),
        BackgroundColor3=T.Sidebar,
        BackgroundTransparency=T.SideAlpha,
        BorderSizePixel=0, ZIndex=4,
    })
    -- right separator
    make("Frame", Sidebar, {
        Size=UDim2.new(0,1,1,0), Position=UDim2.new(1,-1,0,0),
        BackgroundColor3=T.Border, BackgroundTransparency=0.5,
        BorderSizePixel=0, ZIndex=5,
    })

    -- Tab list scroll
    local TabScroll = make("ScrollingFrame", Sidebar, {
        Size=UDim2.new(1,0,1,-68), Position=UDim2.new(0,0,0,0),
        BackgroundTransparency=1, BorderSizePixel=0,
        ScrollBarThickness=2, ScrollBarImageColor3=T.Accent,
        ScrollingDirection=Enum.ScrollingDirection.Y,
        CanvasSize=UDim2.new(0,0,0,0), ZIndex=4,
    })
    listLayout(TabScroll, nil, 2)
    pad(TabScroll,8,4,6,6)
    autoCanvas(TabScroll)

    -- Creator row
    local CRow = make("Frame", Sidebar, {
        Size=UDim2.new(1,0,0,68), Position=UDim2.new(0,0,1,-68),
        BackgroundColor3=Color3.fromRGB(4,10,22),
        BackgroundTransparency=0.3,
        BorderSizePixel=0, ZIndex=5,
    })
    make("Frame",CRow,{Size=UDim2.new(1,0,0,1),BackgroundColor3=T.Border,BackgroundTransparency=0.5,BorderSizePixel=0,ZIndex=6})
    local avBg = make("Frame",CRow,{Size=UDim2.new(0,34,0,34),Position=UDim2.new(0,10,0.5,-17),BackgroundColor3=T.Accent,BackgroundTransparency=0.1,BorderSizePixel=0,ZIndex=6})
    corner(avBg,99)
    make("UIGradient",avBg,{Color=ColorSequence.new(T.AccentB,T.Glow),Rotation=135})
    make("TextLabel",avBg,{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text=string.sub(subtitle,4,4):upper() or "R",TextColor3=T.White,Font=Enum.Font.GothamBold,TextSize=15,ZIndex=7})
    make("TextLabel",CRow,{Size=UDim2.new(0,92,0,17),Position=UDim2.new(0,52,0.5,-18),BackgroundTransparency=1,Text=subtitle:gsub("by ",""),TextColor3=T.Text,Font=Enum.Font.GothamBold,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=6})
    make("TextLabel",CRow,{Size=UDim2.new(0,92,0,13),Position=UDim2.new(0,52,0.5,2),BackgroundTransparency=1,Text="Developer",TextColor3=T.TextDim,Font=Enum.Font.Gotham,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=6})

    -- ── PAGE HOLDER ──
    local PageHolder = make("Frame", Body, {
        Size=UDim2.new(1,-142,1,0), Position=UDim2.new(0,142,0,0),
        BackgroundTransparency=1, ClipsDescendants=true, ZIndex=3,
    })

    -- ── NOTIF HOLDER ──
    _notifHolder = make("Frame", Gui, {
        Size=UDim2.new(0,280,1,-16), Position=UDim2.new(1,-292,0,8),
        BackgroundTransparency=1, ZIndex=999,
    })
    local nl = listLayout(_notifHolder, nil, 6)
    nl.VerticalAlignment = Enum.VerticalAlignment.Bottom
    pad(_notifHolder,0,10,0,0)

    -- Welcome notif
    task.delay(0.8, function()
        notify("RemingtonHub", "Halo "..LP.Name.."! Hub berhasil dimuat.", T.Accent, 5)
    end)

    -- ─────────────────────────────────────────────
    --  TAB SYSTEM
    -- ─────────────────────────────────────────────
    local tabPages  = {}
    local tabBtns   = {}
    local tabCount  = 0

    local WinObj = {}

    function WinObj:Tab(label, icon)
        tabCount += 1
        local order = tabCount

        -- Tab Button
        local Btn = make("TextButton", TabScroll, {
            Name=label, Size=UDim2.new(1,0,0,38),
            BackgroundColor3=T.Card, BackgroundTransparency=1,
            BorderSizePixel=0, Text="", LayoutOrder=order, ZIndex=5,
        })
        corner(Btn, 9)

        local Ind = make("Frame", Btn, {
            Size=UDim2.new(0,3,0.5,0), Position=UDim2.new(0,1,0.25,0),
            BackgroundColor3=T.Accent, BackgroundTransparency=1,
            BorderSizePixel=0, ZIndex=6,
        })
        corner(Ind,4)

        make("TextLabel", Btn, {
            Size=UDim2.new(0,22,1,0), Position=UDim2.new(0,10,0,0),
            BackgroundTransparency=1, Text=icon or "•",
            TextColor3=T.TextDim, Font=Enum.Font.GothamBold,
            TextSize=14, ZIndex=6,
        })
        local NLbl = make("TextLabel", Btn, {
            Size=UDim2.new(1,-36,1,0), Position=UDim2.new(0,34,0,0),
            BackgroundTransparency=1, Text=label,
            TextColor3=T.TextSub, Font=Enum.Font.Gotham,
            TextSize=12, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=6,
        })

        -- Page
        local Page = make("ScrollingFrame", PageHolder, {
            Name=label, Size=UDim2.new(1,0,1,0),
            BackgroundTransparency=1, BorderSizePixel=0,
            ScrollBarThickness=3, ScrollBarImageColor3=T.Accent,
            ScrollingDirection=Enum.ScrollingDirection.Y,
            CanvasSize=UDim2.new(0,0,0,0),
            Visible=false, ZIndex=4,
        })
        listLayout(Page)
        pad(Page,10,10,10,10)
        autoCanvas(Page)

        tabPages[label] = Page
        tabBtns[label]  = {Btn=Btn, Name=NLbl, Ind=Ind}

        local function activate()
            for k,pg in pairs(tabPages) do
                pg.Visible=false
                local tb=tabBtns[k]
                if tb then
                    tw(tb.Btn,{BackgroundTransparency=1},0.15)
                    tw(tb.Name,{TextColor3=T.TextSub},0.15)
                    tb.Name.Font=Enum.Font.Gotham
                    tw(tb.Ind,{BackgroundTransparency=1},0.15)
                end
            end
            Page.Visible=true
            tw(Btn,{BackgroundTransparency=0.55,BackgroundColor3=T.Card},0.15)
            tw(NLbl,{TextColor3=T.Text},0.15)
            NLbl.Font=Enum.Font.GothamBold
            tw(Ind,{BackgroundTransparency=0},0.15)
        end

        Btn.MouseButton1Click:Connect(activate)

        -- auto-activate tab pertama
        if tabCount == 1 then
            task.defer(activate)
        end

        -- Hover
        Btn.MouseEnter:Connect(function()
            if Page.Visible then return end
            tw(Btn,{BackgroundTransparency=0.8,BackgroundColor3=T.Card},0.12)
        end)
        Btn.MouseLeave:Connect(function()
            if Page.Visible then return end
            tw(Btn,{BackgroundTransparency=1},0.12)
        end)

        -- ─────────────────────────────────────
        --  KOMPONEN TAB
        -- ─────────────────────────────────────
        local itemCount = 0
        local TabObj = {}

        local function nextOrder()
            itemCount += 1
            return itemCount
        end

        -- SEPARATOR/SECTION
        function TabObj:Separator(title)
            local F = make("Frame", Page, {
                Size=UDim2.new(1,0,0,24),
                BackgroundTransparency=1, LayoutOrder=nextOrder(),
            })
            make("Frame",F,{Size=UDim2.new(0,18,0,1),Position=UDim2.new(0,0,0.5,0),BackgroundColor3=T.Accent,BackgroundTransparency=0.3,BorderSizePixel=0})
            make("TextLabel",F,{
                Size=UDim2.new(1,-26,1,0),Position=UDim2.new(0,26,0,0),
                BackgroundTransparency=1,Text=(title or ""):upper(),
                TextColor3=T.Accent,Font=Enum.Font.GothamBold,
                TextSize=9,TextXAlignment=Enum.TextXAlignment.Left,
            })
        end

        -- LABEL
        function TabObj:Label(text)
            make("TextLabel", Page, {
                Size=UDim2.new(1,0,0,22),
                BackgroundTransparency=1, LayoutOrder=nextOrder(),
                Text=text, TextColor3=T.TextDim,
                Font=Enum.Font.Gotham, TextSize=11,
                TextXAlignment=Enum.TextXAlignment.Left,
            })
        end

        -- TOGGLE
        function TabObj:Toggle(name, desc, default, callback)
            local on = default or false
            local H  = (desc and desc~="") and 58 or 44

            local Row = make("Frame", Page, {
                Size=UDim2.new(1,0,0,H),
                BackgroundColor3=T.Card,
                BackgroundTransparency=T.CardAlpha,
                BorderSizePixel=0, LayoutOrder=nextOrder(),
            })
            corner(Row,10)
            stroke(Row, T.Border, 1, 0.55)

            make("TextLabel",Row,{
                Size=UDim2.new(1,-58,0,17),Position=UDim2.new(0,12,0,10),
                BackgroundTransparency=1,Text=name,
                TextColor3=T.Text,Font=Enum.Font.GothamBold,TextSize=13,
                TextXAlignment=Enum.TextXAlignment.Left,
            })
            if desc and desc~="" then
                make("TextLabel",Row,{
                    Size=UDim2.new(1,-58,0,14),Position=UDim2.new(0,12,0,27),
                    BackgroundTransparency=1,Text=desc,
                    TextColor3=T.TextDim,Font=Enum.Font.Gotham,TextSize=10,
                    TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,
                })
            end

            -- Track glass
            local Track = make("Frame",Row,{
                Size=UDim2.new(0,44,0,26),Position=UDim2.new(1,-56,0.5,-13),
                BackgroundColor3=on and T.TglOn or T.TglOff,
                BackgroundTransparency=0.2, BorderSizePixel=0,
            })
            corner(Track,13)
            local TStr=stroke(Track,on and T.BorderBright or T.Border,1,0.3)
            local Knob=make("Frame",Track,{
                Size=UDim2.new(0,20,0,20),
                Position=on and UDim2.new(0,22,0.5,-10) or UDim2.new(0,2,0.5,-10),
                BackgroundColor3=T.White,BackgroundTransparency=0.05,BorderSizePixel=0,
            })
            corner(Knob,99)

            -- Knob shadow
            make("ImageLabel",Knob,{
                Size=UDim2.new(1,8,1,8),Position=UDim2.new(0,-4,0,-4),
                BackgroundTransparency=1,
                Image="rbxassetid://6014261963",
                ImageColor3=Color3.fromRGB(0,0,0),
                ImageTransparency=0.85,
                ScaleType=Enum.ScaleType.Slice,
                SliceCenter=Rect.new(49,49,450,450),
            })

            local Hit=make("TextButton",Row,{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=7})
            Hit.MouseButton1Click:Connect(function()
                on=not on
                tw(Track,{BackgroundColor3=on and T.TglOn or T.TglOff},0.2)
                tw(Knob,{Position=on and UDim2.new(0,22,0.5,-10) or UDim2.new(0,2,0.5,-10)},0.22,Enum.EasingStyle.Back)
                TStr.Color=on and T.BorderBright or T.Border
                notify(name, on and "Aktif" or "Nonaktif", on and T.Accent or T.TextDim, 2)
                if callback then task.spawn(callback, on) end
            end)
            Row.MouseEnter:Connect(function() tw(Row,{BackgroundTransparency=T.CardAlpha-0.15},0.12) end)
            Row.MouseLeave:Connect(function() tw(Row,{BackgroundTransparency=T.CardAlpha},0.12) end)
            return Row
        end

        -- SLIDER
        function TabObj:Slider(name, desc, min, max, default, suffix, callback)
            local val = default or min
            local H   = (desc and desc~="") and 68 or 56

            local Row = make("Frame",Page,{
                Size=UDim2.new(1,0,0,H),
                BackgroundColor3=T.Card,BackgroundTransparency=T.CardAlpha,
                BorderSizePixel=0,LayoutOrder=nextOrder(),
            })
            corner(Row,10)
            stroke(Row,T.Border,1,0.55)

            make("TextLabel",Row,{
                Size=UDim2.new(0.62,0,0,17),Position=UDim2.new(0,12,0,10),
                BackgroundTransparency=1,Text=name,
                TextColor3=T.Text,Font=Enum.Font.GothamBold,TextSize=13,
                TextXAlignment=Enum.TextXAlignment.Left,
            })
            local VL=make("TextLabel",Row,{
                Size=UDim2.new(0.38,-12,0,17),Position=UDim2.new(0.62,0,0,10),
                BackgroundTransparency=1,Text=tostring(val)..(suffix or ""),
                TextColor3=T.Accent,Font=Enum.Font.GothamBold,TextSize=13,
                TextXAlignment=Enum.TextXAlignment.Right,
            })
            if desc and desc~="" then
                make("TextLabel",Row,{
                    Size=UDim2.new(1,-24,0,13),Position=UDim2.new(0,12,0,28),
                    BackgroundTransparency=1,Text=desc,
                    TextColor3=T.TextDim,Font=Enum.Font.Gotham,TextSize=10,
                    TextXAlignment=Enum.TextXAlignment.Left,
                })
            end

            local TY = H-18
            local Track=make("Frame",Row,{
                Size=UDim2.new(1,-24,0,5),Position=UDim2.new(0,12,0,TY),
                BackgroundColor3=Color3.fromRGB(8,16,36),BackgroundTransparency=0.3,
                BorderSizePixel=0,ClipsDescendants=false,
            })
            corner(Track,3)
            stroke(Track,T.Border,1,0.6)

            local pct=(val-min)/(max-min)
            local Fill=make("Frame",Track,{
                Size=UDim2.new(pct,0,1,0),
                BackgroundColor3=T.Accent,BorderSizePixel=0,
            })
            corner(Fill,3)
            make("UIGradient",Fill,{Color=ColorSequence.new(T.AccentB,T.Glow)})

            local Knob2=make("Frame",Track,{
                Size=UDim2.new(0,16,0,16),
                Position=UDim2.new(pct,-8,0.5,-8),
                BackgroundColor3=T.White,BackgroundTransparency=0.05,
                BorderSizePixel=0,ZIndex=6,
            })
            corner(Knob2,99)
            stroke(Knob2,T.Accent,1.5,0.2)

            local sdrag=false
            local SHit=make("TextButton",Track,{
                Size=UDim2.new(1,0,0,28),Position=UDim2.new(0,0,0,-12),
                BackgroundTransparency=1,Text="",ZIndex=8,
            })
            local function upd(inp)
                local rx=math.clamp((inp.Position.X-Track.AbsolutePosition.X)/Track.AbsoluteSize.X,0,1)
                val=math.floor(min+(max-min)*rx)
                VL.Text=tostring(val)..(suffix or "")
                tw(Fill,{Size=UDim2.new(rx,0,1,0)},0.05)
                tw(Knob2,{Position=UDim2.new(rx,-8,0.5,-8)},0.05)
                if callback then task.spawn(callback, val) end
            end
            SHit.InputBegan:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then sdrag=true upd(i) end
            end)
            UserInput.InputChanged:Connect(function(i)
                if sdrag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then upd(i) end
            end)
            UserInput.InputEnded:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then sdrag=false end
            end)
            Row.MouseEnter:Connect(function() tw(Row,{BackgroundTransparency=T.CardAlpha-0.15},0.12) end)
            Row.MouseLeave:Connect(function() tw(Row,{BackgroundTransparency=T.CardAlpha},0.12) end)
        end

        -- BUTTON
        function TabObj:Button(name, desc, callback)
            local H=(desc and desc~="") and 52 or 44
            local Row=make("Frame",Page,{
                Size=UDim2.new(1,0,0,H),
                BackgroundColor3=T.Card,BackgroundTransparency=T.CardAlpha,
                BorderSizePixel=0,LayoutOrder=nextOrder(),
            })
            corner(Row,10)
            stroke(Row,T.Border,1,0.55)

            -- accent left pill
            local lp=make("Frame",Row,{
                Size=UDim2.new(0,3,0.46,0),Position=UDim2.new(0,0,0.27,0),
                BackgroundColor3=T.Accent,BorderSizePixel=0,
            })
            corner(lp,3)

            make("TextLabel",Row,{
                Size=UDim2.new(1,-42,0,18),Position=UDim2.new(0,14,0,8),
                BackgroundTransparency=1,Text=name,
                TextColor3=T.Text,Font=Enum.Font.GothamBold,TextSize=12,
                TextXAlignment=Enum.TextXAlignment.Left,
            })
            if desc and desc~="" then
                make("TextLabel",Row,{
                    Size=UDim2.new(1,-42,0,13),Position=UDim2.new(0,14,0,27),
                    BackgroundTransparency=1,Text=desc,
                    TextColor3=T.TextDim,Font=Enum.Font.Gotham,TextSize=10,
                    TextXAlignment=Enum.TextXAlignment.Left,
                })
            end
            make("TextLabel",Row,{
                Size=UDim2.new(0,24,1,0),Position=UDim2.new(1,-28,0,0),
                BackgroundTransparency=1,Text="›",
                TextColor3=T.TextDim,Font=Enum.Font.GothamBold,TextSize=22,
            })
            local Hit=make("TextButton",Row,{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=7})
            Hit.MouseButton1Click:Connect(function()
                tw(Row,{BackgroundTransparency=T.CardAlpha-0.25},0.08)
                task.wait(0.1)
                tw(Row,{BackgroundTransparency=T.CardAlpha},0.18)
                if callback then task.spawn(callback) end
            end)
            Row.MouseEnter:Connect(function() tw(Row,{BackgroundTransparency=T.CardAlpha-0.15},0.12) end)
            Row.MouseLeave:Connect(function() tw(Row,{BackgroundTransparency=T.CardAlpha},0.12) end)
        end

        -- INPUT
        function TabObj:Input(name, placeholder, callback)
            local Row=make("Frame",Page,{
                Size=UDim2.new(1,0,0,58),
                BackgroundColor3=T.Card,BackgroundTransparency=T.CardAlpha,
                BorderSizePixel=0,LayoutOrder=nextOrder(),
            })
            corner(Row,10)
            stroke(Row,T.Border,1,0.55)

            make("TextLabel",Row,{
                Size=UDim2.new(1,-24,0,14),Position=UDim2.new(0,12,0,7),
                BackgroundTransparency=1,Text=name,
                TextColor3=T.TextSub,Font=Enum.Font.GothamBold,TextSize=10,
                TextXAlignment=Enum.TextXAlignment.Left,
            })
            local IBox=make("Frame",Row,{
                Size=UDim2.new(1,-24,0,26),Position=UDim2.new(0,12,0,26),
                BackgroundColor3=Color3.fromRGB(6,12,26),BackgroundTransparency=0.35,
                BorderSizePixel=0,
            })
            corner(IBox,7)
            local IStr=stroke(IBox,T.Border,1,0.5)
            local TB=make("TextBox",IBox,{
                Size=UDim2.new(1,-16,1,0),Position=UDim2.new(0,8,0,0),
                BackgroundTransparency=1,Text="",
                PlaceholderText=placeholder or "Ketik di sini...",
                PlaceholderColor3=T.TextDim,TextColor3=T.Text,
                Font=Enum.Font.Gotham,TextSize=11,
                TextXAlignment=Enum.TextXAlignment.Left,
                ClearTextOnFocus=false,
            })
            TB.Focused:Connect(function()
                IStr.Color=T.Accent IStr.Transparency=0.1
                tw(IBox,{BackgroundTransparency=0.2},0.15)
            end)
            TB.FocusLost:Connect(function()
                IStr.Color=T.Border IStr.Transparency=0.5
                tw(IBox,{BackgroundTransparency=0.35},0.15)
                if callback then task.spawn(callback, TB.Text) end
            end)
            Row.MouseEnter:Connect(function() tw(Row,{BackgroundTransparency=T.CardAlpha-0.15},0.12) end)
            Row.MouseLeave:Connect(function() tw(Row,{BackgroundTransparency=T.CardAlpha},0.12) end)
        end

        -- NOTIFY (public)
        function TabObj:Notify(title, msg, dur)
            notify(title, msg, T.Accent, dur)
        end

        return TabObj
    end

    -- Notify method di level Window
    function WinObj:Notify(title, msg, dur)
        notify(title, msg, T.Accent, dur)
    end

    return WinObj
end

return RHub
