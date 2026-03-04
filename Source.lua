--[[
╔══════════════════════════════════════════════════════════╗
║              RemingtonHub  UI  Library                   ║
║                  by  RaihjnDev  v3.0                     ║
║                                                          ║
║  Ocean Ink  ·  Frosted  ·  Personal Branding             ║
╚══════════════════════════════════════════════════════════╝

  USAGE:
  local RemingtonHub = loadstring(game:HttpGet("RAW_URL"))()
  local Win = RemingtonHub:CreateWindow({ ... })
  local Tab = Win:CreateTab("Tab", icon)
  Tab:CreateToggle({ Name, CurrentValue, Flag, Callback })
  Tab:CreateSlider({ Name, Range, Increment, Suffix, CurrentValue, Flag, Callback })
  Tab:CreateInput({ Name, CurrentValue, PlaceholderText, RemoveTextAfterFocusLost, Flag, Callback })
  Tab:CreateDropdown({ Name, Options, CurrentOption, MultipleOptions, Flag, Callback })
  Tab:CreateColorPicker({ Name, Color, Flag, Callback })
  Tab:CreateButton({ Name, Callback })
  Tab:CreateLabel(text, icon, color, bold)
  Tab:CreateParagraph({ Title, Content })
  Tab:CreateSection(title)
  RemingtonHub:Notify({ Title, Content, Duration, Image })
]]

-- ──────────────────────────────────────────────────────────
--  SERVICES
-- ──────────────────────────────────────────────────────────
local TweenService  = game:GetService("TweenService")
local UserInput     = game:GetService("UserInputService")
local RunService    = game:GetService("RunService")
local Players       = game:GetService("Players")
local CoreGui       = game:GetService("CoreGui")
local LP            = Players.LocalPlayer

-- ──────────────────────────────────────────────────────────
--  TEMA
-- ──────────────────────────────────────────────────────────
local Themes = {
    default = {
        WinBG       = Color3.fromRGB(12, 20, 40),
        WinAlpha    = 0.06,
        Sidebar     = Color3.fromRGB(8,  15, 32),
        SideAlpha   = 0.04,
        Card        = Color3.fromRGB(16, 28, 58),
        CardAlpha   = 0.05,
        CardHover   = Color3.fromRGB(20, 36, 72),
        CardHAlpha  = 0.0,
        TitleBar    = Color3.fromRGB(8,  15, 32),
        TitleAlpha  = 0.04,
        Accent      = Color3.fromRGB(0,  175, 235),
        AccentDark  = Color3.fromRGB(0,  100, 165),
        Glow        = Color3.fromRGB(95, 215, 255),
        Border      = Color3.fromRGB(0,  80,  145),
        BorderBright= Color3.fromRGB(0,  165, 225),
        Text        = Color3.fromRGB(218, 236, 255),
        TextSub     = Color3.fromRGB(115, 158, 205),
        TextDim     = Color3.fromRGB(58,  95,  145),
        Green       = Color3.fromRGB(55,  218, 138),
        Red         = Color3.fromRGB(225, 65,  75),
        White       = Color3.fromRGB(255, 255, 255),
        TglOn       = Color3.fromRGB(0,   165, 225),
        TglOff      = Color3.fromRGB(28,  52,  95),
        SliderBg    = Color3.fromRGB(10,  20,  42),
        InputBg     = Color3.fromRGB(7,   14,  30),
        DropBg      = Color3.fromRGB(10,  18,  40),
    },
    ocean = "default",
    void = {
        WinBG=Color3.fromRGB(10,8,22),WinAlpha=0.06,
        Sidebar=Color3.fromRGB(7,6,16),SideAlpha=0.04,
        Card=Color3.fromRGB(18,14,42),CardAlpha=0.05,
        CardHover=Color3.fromRGB(24,18,56),CardHAlpha=0.0,
        TitleBar=Color3.fromRGB(7,6,16),TitleAlpha=0.04,
        Accent=Color3.fromRGB(145,92,255),AccentDark=Color3.fromRGB(82,50,185),
        Glow=Color3.fromRGB(195,155,255),Border=Color3.fromRGB(72,42,145),
        BorderBright=Color3.fromRGB(145,92,255),Text=Color3.fromRGB(222,216,255),
        TextSub=Color3.fromRGB(142,122,202),TextDim=Color3.fromRGB(82,66,142),
        Green=Color3.fromRGB(55,218,138),Red=Color3.fromRGB(225,65,75),
        White=Color3.fromRGB(255,255,255),TglOn=Color3.fromRGB(140,88,252),
        TglOff=Color3.fromRGB(30,22,68),SliderBg=Color3.fromRGB(12,10,28),
        InputBg=Color3.fromRGB(8,6,20),DropBg=Color3.fromRGB(12,10,30),
    },
    rose = {
        WinBG=Color3.fromRGB(24,8,18),WinAlpha=0.06,
        Sidebar=Color3.fromRGB(18,6,14),SideAlpha=0.04,
        Card=Color3.fromRGB(42,14,28),CardAlpha=0.05,
        CardHover=Color3.fromRGB(55,18,36),CardHAlpha=0.0,
        TitleBar=Color3.fromRGB(18,6,14),TitleAlpha=0.04,
        Accent=Color3.fromRGB(238,72,132),AccentDark=Color3.fromRGB(162,42,92),
        Glow=Color3.fromRGB(255,132,182),Border=Color3.fromRGB(142,42,82),
        BorderBright=Color3.fromRGB(238,72,132),Text=Color3.fromRGB(255,222,236),
        TextSub=Color3.fromRGB(202,142,172),TextDim=Color3.fromRGB(132,76,108),
        Green=Color3.fromRGB(55,218,138),Red=Color3.fromRGB(225,65,75),
        White=Color3.fromRGB(255,255,255),TglOn=Color3.fromRGB(235,68,128),
        TglOff=Color3.fromRGB(58,18,36),SliderBg=Color3.fromRGB(18,8,14),
        InputBg=Color3.fromRGB(14,5,10),DropBg=Color3.fromRGB(18,8,16),
    },
}

-- ──────────────────────────────────────────────────────────
--  FLAGS / CONFIG
-- ──────────────────────────────────────────────────────────
local Flags = {}

-- ──────────────────────────────────────────────────────────
--  HELPERS
-- ──────────────────────────────────────────────────────────
local function tw(o, p, t, es, ed)
    if not o or not o.Parent then return end
    TweenService:Create(o, TweenInfo.new(t or .18, es or Enum.EasingStyle.Quad, ed or Enum.EasingDirection.Out), p):Play()
end

local function mk(class, parent, props)
    local o = Instance.new(class)
    if props then
        for k,v in pairs(props) do
            if k ~= "Parent" then pcall(function() o[k] = v end) end
        end
    end
    o.Parent = parent
    return o
end

local function rnd(p, r)   mk("UICorner",  p, {CornerRadius=UDim.new(0, r or 8)}) end
local function bdr(p,c,th,tr) return mk("UIStroke",p,{Color=c,Thickness=th or 1,Transparency=tr or 0}) end
local function pdg(p,t,b,l,r) mk("UIPadding",p,{PaddingTop=UDim.new(0,t or 6),PaddingBottom=UDim.new(0,b or 6),PaddingLeft=UDim.new(0,l or 8),PaddingRight=UDim.new(0,r or 8)}) end

local function ll(p, gap, dir)
    return mk("UIListLayout",p,{
        SortOrder=Enum.SortOrder.LayoutOrder,
        Padding=UDim.new(0,gap or 4),
        FillDirection=dir or Enum.FillDirection.Vertical,
    })
end

local function autoCanvas(sf)
    local layout = sf:FindFirstChildOfClass("UIListLayout")
    if not layout then return end
    local function upd() sf.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 20) end
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(upd)
    task.defer(upd)
end

-- ──────────────────────────────────────────────────────────
--  LIBRARY OBJECT
-- ──────────────────────────────────────────────────────────
local Library = {}
Library.__index = Library
Library.Flags = Flags

local _notifHolder = nil
local _T           = nil   -- active theme table

-- ──────────────────────────────────────────────────────────
--  NOTIFY
-- ──────────────────────────────────────────────────────────
function Library:Notify(cfg)
    if not _notifHolder then return end
    cfg = cfg or {}
    local title   = cfg.Title    or "RemingtonHub"
    local content = cfg.Content  or ""
    local dur     = cfg.Duration or 4
    local col     = _T and _T.Accent or Color3.fromRGB(0,175,235)

    local NF = mk("Frame", _notifHolder, {
        Size=UDim2.new(1,0,0,0),
        BackgroundColor3=Color3.fromRGB(12,20,40),
        BackgroundTransparency=0.04,
        BorderSizePixel=0,
        ClipsDescendants=true,
        LayoutOrder=tick(),
    })
    rnd(NF,10)
    bdr(NF, col, 1.2, 0.18)

    -- colored left bar
    local lb=mk("Frame",NF,{Size=UDim2.new(0,3,1,0),BackgroundColor3=col,BorderSizePixel=0})
    rnd(lb,2)

    mk("TextLabel",NF,{
        Size=UDim2.new(1,-16,0,17),Position=UDim2.new(0,14,0,8),
        BackgroundTransparency=1,Text=title,
        TextColor3=Color3.fromRGB(218,236,255),Font=Enum.Font.GothamBold,
        TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,
    })
    mk("TextLabel",NF,{
        Size=UDim2.new(1,-16,0,30),Position=UDim2.new(0,14,0,27),
        BackgroundTransparency=1,Text=content,
        TextColor3=Color3.fromRGB(115,158,205),Font=Enum.Font.Gotham,
        TextSize=10,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,
    })

    tw(NF,{Size=UDim2.new(1,0,0,62)},.3,Enum.EasingStyle.Back,Enum.EasingDirection.Out)
    task.delay(dur, function()
        tw(NF,{Size=UDim2.new(1,0,0,0),BackgroundTransparency=1},.25)
        task.wait(.3) pcall(function() NF:Destroy() end)
    end)
end

-- ──────────────────────────────────────────────────────────
--  CREATE WINDOW
-- ──────────────────────────────────────────────────────────
function Library:CreateWindow(cfg)
    cfg = cfg or {}
    local winName    = cfg.Name          or "RemingtonHub"
    local loadTitle  = cfg.LoadingTitle  or "RemingtonHub"
    local loadSub    = cfg.LoadingSubtitle or "By RaihjnDev"
    local themeName  = (cfg.Theme or "default"):lower()
    local toggleKey  = (cfg.ToggleUIKeybind or "i"):upper()
    local keySys     = cfg.KeySystem or false
    local keySettings= cfg.KeySettings or {}
    local discordCfg = cfg.Discord or {}

    -- resolve theme alias
    local themeData = Themes[themeName]
    if type(themeData) == "string" then themeData = Themes[themeData] end
    if not themeData then themeData = Themes["default"] end
    _T = themeData
    local T = themeData

    -- Cleanup old instance
    pcall(function()
        if CoreGui:FindFirstChild("RemingtonHub_GUI") then
            CoreGui:FindFirstChild("RemingtonHub_GUI"):Destroy()
        end
    end)

    -- ── SCREEN GUI ──
    local Gui = Instance.new("ScreenGui")
    Gui.Name           = "RemingtonHub_GUI"
    Gui.ResetOnSpawn   = false
    Gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    Gui.DisplayOrder   = 999
    pcall(function() Gui.Parent = CoreGui end)
    if not Gui.Parent then Gui.Parent = LP:WaitForChild("PlayerGui") end

    -- ── LOADING SCREEN ──
    local LoadScreen = mk("Frame", Gui, {
        Size=UDim2.new(1,0,1,0),
        BackgroundColor3=Color3.fromRGB(6,12,26),
        BackgroundTransparency=0,
        BorderSizePixel=0,
        ZIndex=100,
    })
    -- logo pill
    local LoadPill = mk("Frame",LoadScreen,{
        Size=UDim2.new(0,52,0,52),
        Position=UDim2.new(0.5,-26,0.5,-48),
        BackgroundColor3=T.Accent,
        BackgroundTransparency=0.05,
        BorderSizePixel=0,
        ZIndex=101,
    })
    rnd(LoadPill,14)
    mk("UIGradient",LoadPill,{Color=ColorSequence.new(T.AccentDark,T.Glow),Rotation=135})
    mk("TextLabel",LoadPill,{
        Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
        Text=string.sub(loadTitle,1,1),TextColor3=T.White,
        Font=Enum.Font.GothamBold,TextSize=24,ZIndex=102,
    })
    mk("TextLabel",LoadScreen,{
        Size=UDim2.new(0,300,0,22),Position=UDim2.new(0.5,-150,0.5,14),
        BackgroundTransparency=1,Text=loadTitle,
        TextColor3=T.Text,Font=Enum.Font.GothamBold,TextSize=18,ZIndex=101,
    })
    mk("TextLabel",LoadScreen,{
        Size=UDim2.new(0,300,0,16),Position=UDim2.new(0.5,-150,0.5,38),
        BackgroundTransparency=1,Text=loadSub,
        TextColor3=T.TextDim,Font=Enum.Font.Gotham,TextSize=12,ZIndex=101,
    })
    -- loading bar
    local LBarBg=mk("Frame",LoadScreen,{
        Size=UDim2.new(0,200,0,3),Position=UDim2.new(0.5,-100,0.5,62),
        BackgroundColor3=Color3.fromRGB(18,30,60),BackgroundTransparency=0.2,
        BorderSizePixel=0,ZIndex=101,
    })
    rnd(LBarBg,2)
    local LBarFill=mk("Frame",LBarBg,{
        Size=UDim2.new(0,0,1,0),BackgroundColor3=T.Accent,BorderSizePixel=0,ZIndex=102,
    })
    rnd(LBarFill,2)
    mk("UIGradient",LBarFill,{Color=ColorSequence.new(T.AccentDark,T.Glow)})

    -- Animasi loading bar
    task.spawn(function()
        tw(LBarFill,{Size=UDim2.new(1,0,1,0)},1.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
        task.wait(1.4)
        tw(LoadScreen,{BackgroundTransparency=1},.35)
        task.wait(.4) pcall(function() LoadScreen:Destroy() end)
    end)

    -- ── KEY SYSTEM ──
    if keySys and keySettings.Key then
        -- (implementasi key system sederhana, bisa diperluas)
        local validKey = false
        local KFrame=mk("Frame",Gui,{
            Size=UDim2.new(0,380,0,220),Position=UDim2.new(0.5,-190,0.5,-110),
            BackgroundColor3=T.WinBG,BackgroundTransparency=T.WinAlpha,
            BorderSizePixel=0,ZIndex=200,
        })
        rnd(KFrame,14)
        bdr(KFrame,T.Border,1.5,0.18)
        mk("TextLabel",KFrame,{Size=UDim2.new(1,0,0,28),Position=UDim2.new(0,0,0,18),BackgroundTransparency=1,Text=keySettings.Title or "Key System",TextColor3=T.Text,Font=Enum.Font.GothamBold,TextSize=18,ZIndex=201})
        mk("TextLabel",KFrame,{Size=UDim2.new(1,0,0,18),Position=UDim2.new(0,0,0,48),BackgroundTransparency=1,Text=keySettings.Note or "Enter your key",TextColor3=T.TextDim,Font=Enum.Font.Gotham,TextSize=11,ZIndex=201})
        local KInputBg=mk("Frame",KFrame,{Size=UDim2.new(1,-40,0,36),Position=UDim2.new(0,20,0,78),BackgroundColor3=T.InputBg,BackgroundTransparency=0.04,BorderSizePixel=0,ZIndex=201})
        rnd(KInputBg,9) bdr(KInputBg,T.Border,1,0.3)
        local KTB=mk("TextBox",KInputBg,{Size=UDim2.new(1,-16,1,0),Position=UDim2.new(0,8,0,0),BackgroundTransparency=1,PlaceholderText="Enter key here...",PlaceholderColor3=T.TextDim,TextColor3=T.Text,Font=Enum.Font.Gotham,TextSize=12,ClearTextOnFocus=false,ZIndex=202})
        local KBtn=mk("TextButton",KFrame,{Size=UDim2.new(1,-40,0,38),Position=UDim2.new(0,20,0,128),BackgroundColor3=T.Accent,BackgroundTransparency=0.08,BorderSizePixel=0,Text="Confirm",TextColor3=T.White,Font=Enum.Font.GothamBold,TextSize=14,ZIndex=201})
        rnd(KBtn,9)
        local KStatus=mk("TextLabel",KFrame,{Size=UDim2.new(1,0,0,16),Position=UDim2.new(0,0,0,176),BackgroundTransparency=1,Text="",TextColor3=T.Red,Font=Enum.Font.Gotham,TextSize=11,ZIndex=201})
        KBtn.MouseButton1Click:Connect(function()
            local entered = KTB.Text
            local keys = keySettings.Key or {}
            for _,k in ipairs(keys) do
                if entered == k then validKey=true break end
            end
            if validKey then
                tw(KFrame,{BackgroundTransparency=1,Size=UDim2.new(0,0,0,0)},.3)
                task.wait(.35) pcall(function() KFrame:Destroy() end)
            else
                KStatus.Text="❌  Key tidak valid!"
                tw(KFrame,{Position=UDim2.new(0.5,-190+6,0.5,-110)},.05)
                task.wait(.05)
                tw(KFrame,{Position=UDim2.new(0.5,-190-6,0.5,-110)},.05)
                task.wait(.05)
                tw(KFrame,{Position=UDim2.new(0.5,-190,0.5,-110)},.05)
            end
        end)
    end

    -- ── SHADOW ──
    local Shadow=mk("ImageLabel",Gui,{
        Size=UDim2.new(0,560,0,560),Position=UDim2.new(0.5,-280,0.5,-280),
        BackgroundTransparency=1,
        Image="rbxassetid://6014261963",
        ImageColor3=T.AccentDark,ImageTransparency=0.55,
        ScaleType=Enum.ScaleType.Slice,SliceCenter=Rect.new(49,49,450,450),
        ZIndex=1,
    })

    -- ── OUTER BORDER FRAME (fix corner) ──
    local Outer=mk("Frame",Gui,{
        Name="RHub_Outer",
        Size=UDim2.new(0,520,0,520),Position=UDim2.new(0.5,-260,0.5,-260),
        BackgroundColor3=T.Border,BackgroundTransparency=0.55,
        BorderSizePixel=0,ZIndex=2,
    })
    rnd(Outer,16)

    -- ── MAIN WINDOW (inside outer, clips cleanly) ──
    local Win=mk("Frame",Outer,{
        Size=UDim2.new(1,-2,1,-2),Position=UDim2.new(0,1,0,1),
        BackgroundColor3=T.WinBG,BackgroundTransparency=T.WinAlpha,
        BorderSizePixel=0,ClipsDescendants=true,ZIndex=3,
    })
    rnd(Win,15)
    bdr(Win,T.BorderBright,1,0.72)

    -- Glass noise grain
    mk("ImageLabel",Win,{
        Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
        Image="rbxassetid://9968344227",ImageTransparency=0.96,
        ZIndex=50,ScaleType=Enum.ScaleType.Tile,TileSize=UDim2.new(0,64,0,64),
    })

    -- Entry animation
    Outer.Size=UDim2.new(0,0,0,0) Outer.Position=UDim2.new(0.5,0,0.5,0)
    Shadow.Size=UDim2.new(0,0,0,0) Shadow.Position=UDim2.new(0.5,0,0.5,0)
    task.defer(function()
        tw(Outer,{Size=UDim2.new(0,520,0,520),Position=UDim2.new(0.5,-260,0.5,-260)},.44,Enum.EasingStyle.Back,Enum.EasingDirection.Out)
        tw(Shadow,{Size=UDim2.new(0,560,0,560),Position=UDim2.new(0.5,-280,0.5,-280)},.44,Enum.EasingStyle.Back,Enum.EasingDirection.Out)
    end)

    -- ── TITLEBAR ──
    local TBar=mk("Frame",Win,{
        Size=UDim2.new(1,0,0,50),
        BackgroundColor3=T.TitleBar,BackgroundTransparency=T.TitleAlpha,
        BorderSizePixel=0,ZIndex=4,
    })
    -- shimmer line
    local shimmer=mk("Frame",TBar,{
        Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),
        BackgroundColor3=T.Accent,BorderSizePixel=0,ZIndex=5,
    })
    mk("UIGradient",shimmer,{Color=ColorSequence.new({
        ColorSequenceKeypoint.new(0,Color3.fromRGB(0,0,0)),
        ColorSequenceKeypoint.new(0.35,T.Glow),
        ColorSequenceKeypoint.new(0.65,T.Glow),
        ColorSequenceKeypoint.new(1,Color3.fromRGB(0,0,0)),
    })})
    task.spawn(function()
        local g=shimmer:FindFirstChildOfClass("UIGradient")
        local x=-1.2
        while shimmer and shimmer.Parent do
            x=x+0.003 if x>1.2 then x=-1.2 end
            g.Offset=Vector2.new(x,0) task.wait()
        end
    end)

    -- Icon pill
    local IPill=mk("Frame",TBar,{
        Size=UDim2.new(0,32,0,32),Position=UDim2.new(0,12,0.5,-16),
        BackgroundColor3=T.Accent,BackgroundTransparency=0.08,BorderSizePixel=0,ZIndex=5,
    })
    rnd(IPill,10)
    mk("UIGradient",IPill,{Color=ColorSequence.new(T.AccentDark,T.Glow),Rotation=135})
    mk("TextLabel",IPill,{
        Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
        Text=string.sub(winName,1,1),TextColor3=T.White,
        Font=Enum.Font.GothamBold,TextSize=16,ZIndex=6,
    })

    mk("TextLabel",TBar,{
        Size=UDim2.new(0,210,0,18),Position=UDim2.new(0,52,0.5,-18),
        BackgroundTransparency=1,Text=winName,
        TextColor3=T.Text,Font=Enum.Font.GothamBold,TextSize=15,
        TextXAlignment=Enum.TextXAlignment.Left,ZIndex=5,
    })
    mk("TextLabel",TBar,{
        Size=UDim2.new(0,210,0,13),Position=UDim2.new(0,52,0.5,3),
        BackgroundTransparency=1,Text=loadSub,
        TextColor3=T.TextDim,Font=Enum.Font.Gotham,TextSize=10,
        TextXAlignment=Enum.TextXAlignment.Left,ZIndex=5,
    })

    -- SAFE badge
    local SBg=mk("Frame",TBar,{
        Size=UDim2.new(0,68,0,22),Position=UDim2.new(1,-128,0.5,-11),
        BackgroundColor3=Color3.fromRGB(5,28,18),BackgroundTransparency=0.2,
        BorderSizePixel=0,ZIndex=5,
    })
    rnd(SBg,11) bdr(SBg,T.Green,1,0.35)
    local SDot=mk("Frame",SBg,{Size=UDim2.new(0,6,0,6),Position=UDim2.new(0,8,0.5,-3),BackgroundColor3=T.Green,BorderSizePixel=0,ZIndex=6})
    rnd(SDot,99)
    mk("TextLabel",SBg,{Size=UDim2.new(1,-20,1,0),Position=UDim2.new(0,20,0,0),BackgroundTransparency=1,Text="AutoDetect",TextColor3=T.Green,Font=Enum.Font.GothamBold,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=6})
    task.spawn(function()
        while SDot and SDot.Parent do
            tw(SDot,{BackgroundTransparency=0.8},0.9) task.wait(0.9)
            tw(SDot,{BackgroundTransparency=0},0.9) task.wait(0.9)
        end
    end)

    -- Window buttons
    local function winBtn(xOff, txt, bgCol, bgAlpha)
        local b=mk("TextButton",TBar,{
            Size=UDim2.new(0,26,0,26),Position=UDim2.new(1,xOff,0.5,-13),
            BackgroundColor3=bgCol or T.Card,BackgroundTransparency=bgAlpha or 0.2,
            BorderSizePixel=0,Text=txt,TextColor3=T.TextSub,
            Font=Enum.Font.GothamBold,TextSize=12,ZIndex=6,
        })
        rnd(b,7) bdr(b,T.Border,1,0.4)
        b.MouseEnter:Connect(function() tw(b,{BackgroundTransparency=0.0},0.1) end)
        b.MouseLeave:Connect(function() tw(b,{BackgroundTransparency=bgAlpha or 0.2},0.1) end)
        return b
    end
    local BMin   = winBtn(-60,"➖")
    local BClose = winBtn(-30,"✖",Color3.fromRGB(192,38,50),0.0)
    BClose.TextColor3 = T.White

    -- Drag
    local dg,ds,sp=false,nil,nil
    TBar.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            dg=true ds=i.Position sp=Outer.Position
        end
    end)
    TBar.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dg=false end
    end)
    UserInput.InputChanged:Connect(function(i)
        if dg and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local d=i.Position-ds
            local np=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y)
            Outer.Position=np
            Shadow.Position=UDim2.new(np.X.Scale,np.X.Offset-20,np.Y.Scale,np.Y.Offset-20)
        end
    end)

    -- Close & minimize
    BClose.MouseButton1Click:Connect(function()
        tw(Outer,{Size=UDim2.new(0,0,0,0),Position=UDim2.new(0.5,0,0.5,0)},.3,Enum.EasingStyle.Back,Enum.EasingDirection.In)
        tw(Shadow,{ImageTransparency=1},.3) task.wait(.35) Gui:Destroy()
    end)
    local minimized=false
    BMin.MouseButton1Click:Connect(function()
        minimized=not minimized
        if minimized then
            tw(Outer,{Size=UDim2.new(0,520,0,50)},.25,Enum.EasingStyle.Quad)
            tw(Shadow,{Size=UDim2.new(0,560,0,90)},.25) BMin.Text="✖"
        else
            tw(Outer,{Size=UDim2.new(0,520,0,520)},.25,Enum.EasingStyle.Quad)
            tw(Shadow,{Size=UDim2.new(0,560,0,560)},.25) BMin.Text="➖"
        end
    end)

    -- Toggle UI visibility with keybind
    local uiVisible=true
    UserInput.InputBegan:Connect(function(i, gpe)
        if gpe then return end
        if i.KeyCode==Enum.KeyCode[toggleKey] then
            uiVisible=not uiVisible
            Outer.Visible=uiVisible Shadow.Visible=uiVisible
        end
    end)

    -- ── BODY ──
    local Body=mk("Frame",Win,{
        Size=UDim2.new(1,0,1,-50),Position=UDim2.new(0,0,0,50),
        BackgroundTransparency=1,ClipsDescendants=true,ZIndex=3,
    })

    -- ── SIDEBAR ──
    local Sidebar=mk("Frame",Body,{
        Size=UDim2.new(0,142,1,0),
        BackgroundColor3=T.Sidebar,BackgroundTransparency=T.SideAlpha,
        BorderSizePixel=0,ZIndex=4,
    })
    mk("Frame",Sidebar,{
        Size=UDim2.new(0,1,1,0),Position=UDim2.new(1,-1,0,0),
        BackgroundColor3=T.Border,BackgroundTransparency=0.45,
        BorderSizePixel=0,ZIndex=5,
    })

    local TabScroll=mk("ScrollingFrame",Sidebar,{
        Size=UDim2.new(1,0,1,-70),BackgroundTransparency=1,BorderSizePixel=0,
        ScrollBarThickness=2,ScrollBarImageColor3=T.Accent,
        ScrollingDirection=Enum.ScrollingDirection.Y,
        CanvasSize=UDim2.new(0,0,0,0),ZIndex=4,
    })
    ll(TabScroll,2) pdg(TabScroll,8,4,6,6) autoCanvas(TabScroll)

    -- Creator footer di sidebar
    local CRow=mk("Frame",Sidebar,{
        Size=UDim2.new(1,0,0,70),Position=UDim2.new(0,0,1,-70),
        BackgroundColor3=Color3.fromRGB(4,10,22),BackgroundTransparency=0.08,
        BorderSizePixel=0,ZIndex=5,
    })
    mk("Frame",CRow,{Size=UDim2.new(1,0,0,1),BackgroundColor3=T.Border,BackgroundTransparency=0.45,BorderSizePixel=0,ZIndex=6})
    local CAvBg=mk("Frame",CRow,{Size=UDim2.new(0,36,0,36),Position=UDim2.new(0,10,0.5,-18),BackgroundColor3=T.Accent,BackgroundTransparency=0.08,BorderSizePixel=0,ZIndex=6})
    rnd(CAvBg,99)
    mk("UIGradient",CAvBg,{Color=ColorSequence.new(T.AccentDark,T.Glow),Rotation=135})
    mk("TextLabel",CAvBg,{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="R",TextColor3=T.White,Font=Enum.Font.GothamBold,TextSize=16,ZIndex=7})
    mk("TextLabel",CRow,{Size=UDim2.new(0,88,0,17),Position=UDim2.new(0,54,0.5,-19),BackgroundTransparency=1,Text="RaihjnDev",TextColor3=T.Text,Font=Enum.Font.GothamBold,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=6})
    mk("TextLabel",CRow,{Size=UDim2.new(0,88,0,13),Position=UDim2.new(0,54,0.5,3),BackgroundTransparency=1,Text="Developer",TextColor3=T.TextDim,Font=Enum.Font.Gotham,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=6})

    -- ── PAGE HOLDER ──
    local PageHolder=mk("Frame",Body,{
        Size=UDim2.new(1,-142,1,0),Position=UDim2.new(0,142,0,0),
        BackgroundTransparency=1,ClipsDescendants=true,ZIndex=3,
    })

    -- ── NOTIF HOLDER ──
    _notifHolder=mk("Frame",Gui,{
        Size=UDim2.new(0,285,1,-16),Position=UDim2.new(1,-298,0,8),
        BackgroundTransparency=1,ZIndex=999,
    })
    local notifLL=ll(_notifHolder,6) pdg(_notifHolder,0,12,0,0)
    notifLL.VerticalAlignment=Enum.VerticalAlignment.Bottom

    -- ─────────────────────────────────────────────────
    --  TAB & COMPONENT SYSTEM
    -- ─────────────────────────────────────────────────
    local tabPages, tabBtns = {}, {}
    local tabOrder = 0

    local WinAPI = {}

    function WinAPI:CreateTab(tabName, _icon)
        tabOrder += 1
        local tOrd = tabOrder

        -- Button
        local TBtn=mk("TextButton",TabScroll,{
            Name=tabName,Size=UDim2.new(1,0,0,38),
            BackgroundColor3=T.Card,BackgroundTransparency=1,
            BorderSizePixel=0,Text="",LayoutOrder=tOrd,ZIndex=5,
        })
        rnd(TBtn,9)

        local TInd=mk("Frame",TBtn,{
            Size=UDim2.new(0,3,0.5,0),Position=UDim2.new(0,1,0.25,0),
            BackgroundColor3=T.Accent,BackgroundTransparency=1,
            BorderSizePixel=0,ZIndex=6,
        })
        rnd(TInd,4)

        mk("TextLabel",TBtn,{
            Size=UDim2.new(1,-14,1,0),Position=UDim2.new(0,14,0,0),
            BackgroundTransparency=1,Text=tabName,
            TextColor3=T.TextSub,Font=Enum.Font.Gotham,
            TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=6,
        })

        -- Page
        local Page=mk("ScrollingFrame",PageHolder,{
            Name=tabName,Size=UDim2.new(1,0,1,0),
            BackgroundTransparency=1,BorderSizePixel=0,
            ScrollBarThickness=3,ScrollBarImageColor3=T.Accent,
            ScrollingDirection=Enum.ScrollingDirection.Y,
            CanvasSize=UDim2.new(0,0,0,0),Visible=false,ZIndex=4,
        })
        ll(Page,5) pdg(Page,10,10,10,10) autoCanvas(Page)

        tabPages[tabName]=Page
        tabBtns[tabName]={Btn=TBtn,Ind=TInd,NLbl=TBtn:FindFirstChildOfClass("TextLabel")}

        local function activateTab()
            for k,pg in pairs(tabPages) do
                pg.Visible=false
                local tb=tabBtns[k]
                if tb then
                    tw(tb.Btn,{BackgroundTransparency=1},0.15)
                    if tb.NLbl then tw(tb.NLbl,{TextColor3=T.TextSub},0.15) tb.NLbl.Font=Enum.Font.Gotham end
                    tw(tb.Ind,{BackgroundTransparency=1},0.15)
                end
            end
            Page.Visible=true
            tw(TBtn,{BackgroundTransparency=0.5,BackgroundColor3=T.Card},0.15)
            local nl=tabBtns[tabName].NLbl
            if nl then tw(nl,{TextColor3=T.Text},0.15) nl.Font=Enum.Font.GothamBold end
            tw(TInd,{BackgroundTransparency=0},0.15)
        end

        TBtn.MouseButton1Click:Connect(activateTab)
        TBtn.MouseEnter:Connect(function()
            if not Page.Visible then tw(TBtn,{BackgroundTransparency=0.75,BackgroundColor3=T.Card},0.12) end
        end)
        TBtn.MouseLeave:Connect(function()
            if not Page.Visible then tw(TBtn,{BackgroundTransparency=1},0.12) end
        end)

        if tOrd==1 then task.defer(activateTab) end

        -- ─────────────────────────────────────
        --  ITEM COUNT
        -- ─────────────────────────────────────
        local iOrder=0
        local function nxt() iOrder+=1 return iOrder end

        -- ─────────────────────────────────────
        --  CARD HELPER
        -- ─────────────────────────────────────
        local function card(h, order)
            local R=mk("Frame",Page,{
                Size=UDim2.new(1,0,0,h),
                BackgroundColor3=T.Card,BackgroundTransparency=T.CardAlpha,
                BorderSizePixel=0,LayoutOrder=order,
            })
            rnd(R,10)
            bdr(R,T.Border,1,0.2)
            R.MouseEnter:Connect(function() tw(R,{BackgroundTransparency=T.CardAlpha-0.02},0.1) end)
            R.MouseLeave:Connect(function() tw(R,{BackgroundTransparency=T.CardAlpha},0.1) end)
            return R
        end

        -- ─────────────────────────────────────
        --  API COMPONENTS
        -- ─────────────────────────────────────
        local TabAPI = {}

        -- CREATE SECTION
        function TabAPI:CreateSection(title)
            local F=mk("Frame",Page,{
                Size=UDim2.new(1,0,0,24),BackgroundTransparency=1,LayoutOrder=nxt(),
            })
            mk("Frame",F,{Size=UDim2.new(0,16,0,1),Position=UDim2.new(0,0,0.5,0),BackgroundColor3=T.Accent,BackgroundTransparency=0.2,BorderSizePixel=0})
            mk("TextLabel",F,{
                Size=UDim2.new(1,-24,1,0),Position=UDim2.new(0,24,0,0),
                BackgroundTransparency=1,Text=title:upper(),
                TextColor3=T.Accent,Font=Enum.Font.GothamBold,TextSize=9,
                TextXAlignment=Enum.TextXAlignment.Left,
            })
            return F
        end

        -- CREATE LABEL
        function TabAPI:CreateLabel(text, _icon, color, bold)
            local L=mk("TextLabel",Page,{
                Size=UDim2.new(1,0,0,22),BackgroundTransparency=1,
                LayoutOrder=nxt(),Text=text or "",
                TextColor3=color or T.TextSub,
                Font=bold and Enum.Font.GothamBold or Enum.Font.Gotham,
                TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,
            })
            return L
        end

        -- CREATE PARAGRAPH
        function TabAPI:CreateParagraph(cfg2)
            cfg2=cfg2 or {}
            local ptitle   = cfg2.Title   or ""
            local pcontent = cfg2.Content or ""
            local H = 32 + math.max(0, math.ceil(#pcontent/52)) * 14
            local R=card(H,nxt())
            mk("TextLabel",R,{
                Size=UDim2.new(1,-24,0,17),Position=UDim2.new(0,12,0,8),
                BackgroundTransparency=1,Text=ptitle,
                TextColor3=T.Text,Font=Enum.Font.GothamBold,TextSize=12,
                TextXAlignment=Enum.TextXAlignment.Left,
            })
            mk("TextLabel",R,{
                Size=UDim2.new(1,-24,0,H-28),Position=UDim2.new(0,12,0,25),
                BackgroundTransparency=1,Text=pcontent,
                TextColor3=T.TextSub,Font=Enum.Font.Gotham,TextSize=11,
                TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,
            })
            return R
        end

        -- CREATE BUTTON
        function TabAPI:CreateButton(cfg2)
            cfg2=cfg2 or {}
            local name = cfg2.Name or "Button"
            local cb   = cfg2.Callback

            local R=card(44,nxt())
            local lp=mk("Frame",R,{Size=UDim2.new(0,3,0.46,0),Position=UDim2.new(0,0,0.27,0),BackgroundColor3=T.Accent,BorderSizePixel=0})
            rnd(lp,3)
            mk("TextLabel",R,{
                Size=UDim2.new(1,-42,1,0),Position=UDim2.new(0,14,0,0),
                BackgroundTransparency=1,Text=name,
                TextColor3=T.Text,Font=Enum.Font.GothamBold,TextSize=12,
                TextXAlignment=Enum.TextXAlignment.Left,
            })
            mk("TextLabel",R,{
                Size=UDim2.new(0,24,1,0),Position=UDim2.new(1,-28,0,0),
                BackgroundTransparency=1,Text="›",
                TextColor3=T.TextDim,Font=Enum.Font.GothamBold,TextSize=22,
            })
            local Hit=mk("TextButton",R,{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=7})
            Hit.MouseButton1Click:Connect(function()
                tw(R,{BackgroundTransparency=0.0},0.07)
                task.wait(0.12) tw(R,{BackgroundTransparency=T.CardAlpha},0.18)
                if cb then task.spawn(cb) end
            end)
            return R
        end

        -- CREATE TOGGLE
        function TabAPI:CreateToggle(cfg2)
            cfg2=cfg2 or {}
            local name  = cfg2.Name         or "Toggle"
            local val   = cfg2.CurrentValue or false
            local flag  = cfg2.Flag
            local cb    = cfg2.Callback

            if flag then Flags[flag]=val end

            local R=card(50,nxt())
            mk("TextLabel",R,{
                Size=UDim2.new(1,-62,0,18),Position=UDim2.new(0,12,0,16),
                BackgroundTransparency=1,Text=name,
                TextColor3=T.Text,Font=Enum.Font.GothamBold,TextSize=13,
                TextXAlignment=Enum.TextXAlignment.Left,
            })

            -- Track
            local Track=mk("Frame",R,{
                Size=UDim2.new(0,46,0,26),Position=UDim2.new(1,-58,0.5,-13),
                BackgroundColor3=val and T.TglOn or T.TglOff,
                BackgroundTransparency=0.0,BorderSizePixel=0,
            })
            rnd(Track,13)
            local TStr=bdr(Track,val and T.BorderBright or T.Border,1,0.22)

            local Knob=mk("Frame",Track,{
                Size=UDim2.new(0,20,0,20),
                Position=val and UDim2.new(0,24,0.5,-10) or UDim2.new(0,2,0.5,-10),
                BackgroundColor3=T.White,BackgroundTransparency=0.0,BorderSizePixel=0,
            })
            rnd(Knob,99)

            local Hit=mk("TextButton",R,{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=8})
            Hit.MouseButton1Click:Connect(function()
                val=not val
                if flag then Flags[flag]=val end
                tw(Track,{BackgroundColor3=val and T.TglOn or T.TglOff},0.2)
                tw(Knob,{Position=val and UDim2.new(0,24,0.5,-10) or UDim2.new(0,2,0.5,-10)},0.22,Enum.EasingStyle.Back)
                TStr.Color=val and T.BorderBright or T.Border
                if cb then task.spawn(cb,val) end
            end)

            local Obj={}
            function Obj:Set(newVal)
                val=newVal
                if flag then Flags[flag]=val end
                tw(Track,{BackgroundColor3=val and T.TglOn or T.TglOff},0.2)
                tw(Knob,{Position=val and UDim2.new(0,24,0.5,-10) or UDim2.new(0,2,0.5,-10)},0.22,Enum.EasingStyle.Back)
                TStr.Color=val and T.BorderBright or T.Border
                if cb then task.spawn(cb,val) end
            end
            return Obj
        end

        -- CREATE SLIDER
        function TabAPI:CreateSlider(cfg2)
            cfg2=cfg2 or {}
            local name  = cfg2.Name         or "Slider"
            local range = cfg2.Range        or {0,100}
            local inc   = cfg2.Increment    or 1
            local suf   = cfg2.Suffix       or ""
            local val   = cfg2.CurrentValue or range[1]
            local flag  = cfg2.Flag
            local cb    = cfg2.Callback
            local mn,mx = range[1],range[2]

            if flag then Flags[flag]=val end

            local R=card(58,nxt())
            mk("TextLabel",R,{
                Size=UDim2.new(0.62,0,0,18),Position=UDim2.new(0,12,0,10),
                BackgroundTransparency=1,Text=name,
                TextColor3=T.Text,Font=Enum.Font.GothamBold,TextSize=13,
                TextXAlignment=Enum.TextXAlignment.Left,
            })
            local VLbl=mk("TextLabel",R,{
                Size=UDim2.new(0.38,-14,0,18),Position=UDim2.new(0.62,0,0,10),
                BackgroundTransparency=1,Text=tostring(val).." "..suf,
                TextColor3=T.Accent,Font=Enum.Font.GothamBold,TextSize=13,
                TextXAlignment=Enum.TextXAlignment.Right,
            })

            local Track=mk("Frame",R,{
                Size=UDim2.new(1,-24,0,6),Position=UDim2.new(0,12,0,38),
                BackgroundColor3=T.SliderBg,BackgroundTransparency=0.04,BorderSizePixel=0,
            })
            rnd(Track,3) bdr(Track,T.Border,1,0.3)

            local pct=(val-mn)/(mx-mn)
            local Fill=mk("Frame",Track,{Size=UDim2.new(pct,0,1,0),BackgroundColor3=T.Accent,BorderSizePixel=0})
            rnd(Fill,3)
            mk("UIGradient",Fill,{Color=ColorSequence.new(T.AccentDark,T.Glow)})

            local SKnob=mk("Frame",Track,{
                Size=UDim2.new(0,16,0,16),Position=UDim2.new(pct,-8,0.5,-8),
                BackgroundColor3=T.White,BackgroundTransparency=0.0,BorderSizePixel=0,ZIndex=6,
            })
            rnd(SKnob,99) bdr(SKnob,T.Accent,1.5,0.15)

            local sdrg=false
            local SHit=mk("TextButton",Track,{Size=UDim2.new(1,0,0,30),Position=UDim2.new(0,0,0,-12),BackgroundTransparency=1,Text="",ZIndex=8})
            local function updSlider(inp)
                local rx=math.clamp((inp.Position.X-Track.AbsolutePosition.X)/Track.AbsoluteSize.X,0,1)
                local raw=mn+(mx-mn)*rx
                val=math.floor(raw/inc+0.5)*inc
                val=math.clamp(val,mn,mx)
                VLbl.Text=tostring(val).." "..suf
                local fp=(val-mn)/(mx-mn)
                tw(Fill,{Size=UDim2.new(fp,0,1,0)},0.05)
                tw(SKnob,{Position=UDim2.new(fp,-8,0.5,-8)},0.05)
                if flag then Flags[flag]=val end
                if cb then task.spawn(cb,val) end
            end
            SHit.InputBegan:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then sdrg=true updSlider(i) end
            end)
            UserInput.InputChanged:Connect(function(i)
                if sdrg and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then updSlider(i) end
            end)
            UserInput.InputEnded:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then sdrg=false end
            end)

            local Obj={}
            function Obj:Set(newVal)
                val=math.clamp(newVal,mn,mx)
                local fp=(val-mn)/(mx-mn)
                VLbl.Text=tostring(val).." "..suf
                tw(Fill,{Size=UDim2.new(fp,0,1,0)},0.2)
                tw(SKnob,{Position=UDim2.new(fp,-8,0.5,-8)},0.2)
                if flag then Flags[flag]=val end
                if cb then task.spawn(cb,val) end
            end
            return Obj
        end

        -- CREATE INPUT
        function TabAPI:CreateInput(cfg2)
            cfg2=cfg2 or {}
            local name   = cfg2.Name                   or "Input"
            local cur    = cfg2.CurrentValue            or ""
            local ph     = cfg2.PlaceholderText         or "Ketik di sini..."
            local rmv    = cfg2.RemoveTextAfterFocusLost or false
            local flag   = cfg2.Flag
            local cb     = cfg2.Callback

            if flag then Flags[flag]=cur end

            local R=card(58,nxt())
            mk("TextLabel",R,{
                Size=UDim2.new(1,-24,0,14),Position=UDim2.new(0,12,0,7),
                BackgroundTransparency=1,Text=name,
                TextColor3=T.TextSub,Font=Enum.Font.GothamBold,TextSize=10,
                TextXAlignment=Enum.TextXAlignment.Left,
            })
            local IBox=mk("Frame",R,{
                Size=UDim2.new(1,-24,0,28),Position=UDim2.new(0,12,0,24),
                BackgroundColor3=T.InputBg,BackgroundTransparency=0.03,BorderSizePixel=0,
            })
            rnd(IBox,8)
            local IStr=bdr(IBox,T.Border,1,0.3)
            local TB=mk("TextBox",IBox,{
                Size=UDim2.new(1,-18,1,0),Position=UDim2.new(0,9,0,0),
                BackgroundTransparency=1,Text=cur,
                PlaceholderText=ph,PlaceholderColor3=T.TextDim,
                TextColor3=T.Text,Font=Enum.Font.Gotham,TextSize=12,
                TextXAlignment=Enum.TextXAlignment.Left,ClearTextOnFocus=false,
            })
            TB.Focused:Connect(function()
                IStr.Color=T.Accent IStr.Transparency=0.1
                tw(IBox,{BackgroundTransparency=0.0},0.15)
            end)
            TB.FocusLost:Connect(function()
                IStr.Color=T.Border IStr.Transparency=0.3
                tw(IBox,{BackgroundTransparency=0.03},0.15)
                local v=TB.Text
                if flag then Flags[flag]=v end
                if cb then task.spawn(cb,v) end
                if rmv then TB.Text="" end
            end)

            local Obj={}
            function Obj:Set(t2)
                TB.Text=t2
                if flag then Flags[flag]=t2 end
            end
            return Obj
        end

        -- CREATE DROPDOWN
        function TabAPI:CreateDropdown(cfg2)
            cfg2=cfg2 or {}
            local name    = cfg2.Name           or "Dropdown"
            local options = cfg2.Options        or {}
            local current = cfg2.CurrentOption  or {}
            local multi   = cfg2.MultipleOptions or false
            local flag    = cfg2.Flag
            local cb      = cfg2.Callback

            if flag then Flags[flag]=current end

            local open=false
            local R=mk("Frame",Page,{
                Size=UDim2.new(1,0,0,48),BackgroundColor3=T.Card,
                BackgroundTransparency=T.CardAlpha,BorderSizePixel=0,LayoutOrder=nxt(),
                ClipsDescendants=false,
            })
            rnd(R,10) bdr(R,T.Border,1,0.2)
            R.MouseEnter:Connect(function() tw(R,{BackgroundTransparency=T.CardAlpha-0.02},0.1) end)
            R.MouseLeave:Connect(function() tw(R,{BackgroundTransparency=T.CardAlpha},0.1) end)

            mk("TextLabel",R,{
                Size=UDim2.new(1,-56,0,18),Position=UDim2.new(0,12,0,15),
                BackgroundTransparency=1,Text=name,
                TextColor3=T.Text,Font=Enum.Font.GothamBold,TextSize=12,
                TextXAlignment=Enum.TextXAlignment.Left,
            })

            local dispText = table.concat(current,", ")
            local DispLbl=mk("TextLabel",R,{
                Size=UDim2.new(1,-110,0,18),Position=UDim2.new(0,12,0,15),
                BackgroundTransparency=1,Text=dispText,
                TextColor3=T.Accent,Font=Enum.Font.Gotham,TextSize=11,
                TextXAlignment=Enum.TextXAlignment.Right,
            })
            mk("TextLabel",R,{
                Size=UDim2.new(0,24,1,0),Position=UDim2.new(1,-30,0,0),
                BackgroundTransparency=1,Text="⌄",
                TextColor3=T.TextDim,Font=Enum.Font.GothamBold,TextSize=16,
            })

            -- Dropdown list
            local DList=mk("Frame",R,{
                Size=UDim2.new(1,0,0,0),Position=UDim2.new(0,0,1,4),
                BackgroundColor3=T.DropBg,BackgroundTransparency=0.03,
                BorderSizePixel=0,ClipsDescendants=true,ZIndex=20,
                Visible=false,
            })
            rnd(DList,10) bdr(DList,T.Border,1,0.2)
            ll(DList,1) pdg(DList,4,4,4,4)
            local DListLL=DList:FindFirstChildOfClass("UIListLayout")

            local function refreshDisplay()
                dispText=table.concat(current,", ")
                DispLbl.Text=dispText
                if flag then Flags[flag]=current end
                if cb then task.spawn(cb,current) end
            end

            for _,opt in ipairs(options) do
                local OBtn=mk("TextButton",DList,{
                    Size=UDim2.new(1,0,0,30),BackgroundColor3=T.Card,
                    BackgroundTransparency=0.4,BorderSizePixel=0,
                    Text=opt,TextColor3=T.Text,Font=Enum.Font.Gotham,TextSize=11,
                    ZIndex=21,
                })
                rnd(OBtn,7)
                OBtn.MouseEnter:Connect(function() tw(OBtn,{BackgroundTransparency=0.1},0.1) end)
                OBtn.MouseLeave:Connect(function() tw(OBtn,{BackgroundTransparency=0.4},0.1) end)
                OBtn.MouseButton1Click:Connect(function()
                    if multi then
                        local found=false
                        for i,v in ipairs(current) do
                            if v==opt then table.remove(current,i) found=true break end
                        end
                        if not found then table.insert(current,opt) end
                    else
                        current={opt}
                        -- close after single select
                        open=false
                        tw(DList,{Size=UDim2.new(1,0,0,0)},.2,Enum.EasingStyle.Quad)
                        task.wait(.22) DList.Visible=false
                    end
                    refreshDisplay()
                end)
            end

            -- toggle dropdown
            local Hit=mk("TextButton",R,{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=10})
            Hit.MouseButton1Click:Connect(function()
                open=not open
                local targetH = #options*34+8
                if open then
                    DList.Visible=true DList.Size=UDim2.new(1,0,0,0)
                    tw(DList,{Size=UDim2.new(1,0,0,targetH)},.22,Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
                else
                    tw(DList,{Size=UDim2.new(1,0,0,0)},.18,Enum.EasingStyle.Quad)
                    task.wait(.2) DList.Visible=false
                end
            end)

            local Obj={}
            function Obj:Set(newOpt)
                current=type(newOpt)=="table" and newOpt or {newOpt}
                refreshDisplay()
            end
            function Obj:Refresh(newOptions)
                for _,c in pairs(DList:GetChildren()) do
                    if c:IsA("TextButton") then c:Destroy() end
                end
                options=newOptions
                for _,opt in ipairs(options) do
                    local OBtn=mk("TextButton",DList,{
                        Size=UDim2.new(1,0,0,30),BackgroundColor3=T.Card,
                        BackgroundTransparency=0.4,BorderSizePixel=0,
                        Text=opt,TextColor3=T.Text,Font=Enum.Font.Gotham,TextSize=11,ZIndex=21,
                    })
                    rnd(OBtn,7)
                    OBtn.MouseButton1Click:Connect(function()
                        current={opt} refreshDisplay()
                        open=false tw(DList,{Size=UDim2.new(1,0,0,0)},.2) task.wait(.22) DList.Visible=false
                    end)
                end
            end
            return Obj
        end

        -- CREATE COLOR PICKER
        function TabAPI:CreateColorPicker(cfg2)
            cfg2=cfg2 or {}
            local name = cfg2.Name  or "Color Picker"
            local col  = cfg2.Color or Color3.fromRGB(255,255,255)
            local flag = cfg2.Flag
            local cb   = cfg2.Callback

            if flag then Flags[flag]=col end

            local R=card(50,nxt())
            mk("TextLabel",R,{
                Size=UDim2.new(1,-70,0,18),Position=UDim2.new(0,12,0,16),
                BackgroundTransparency=1,Text=name,
                TextColor3=T.Text,Font=Enum.Font.GothamBold,TextSize=13,
                TextXAlignment=Enum.TextXAlignment.Left,
            })

            -- Preview swatch
            local Swatch=mk("Frame",R,{
                Size=UDim2.new(0,28,0,28),Position=UDim2.new(1,-46,0.5,-14),
                BackgroundColor3=col,BorderSizePixel=0,
            })
            rnd(Swatch,7) bdr(Swatch,T.Border,1,0.2)

            -- Simple mini color row (H slider)
            local open2=false
            local CPPanel=mk("Frame",R,{
                Size=UDim2.new(1,-24,0,0),Position=UDim2.new(0,12,1,6),
                BackgroundColor3=T.DropBg,BackgroundTransparency=0.04,
                BorderSizePixel=0,ClipsDescendants=true,ZIndex=20,Visible=false,
            })
            rnd(CPPanel,10) bdr(CPPanel,T.Border,1,0.2)

            -- Hue bar
            local HueBar=mk("Frame",CPPanel,{
                Size=UDim2.new(1,-16,0,14),Position=UDim2.new(0,8,0,10),
                BackgroundColor3=Color3.fromRGB(255,255,255),BorderSizePixel=0,ZIndex=21,
            })
            rnd(HueBar,4)
            mk("UIGradient",HueBar,{
                Color=ColorSequence.new({
                    ColorSequenceKeypoint.new(0,   Color3.fromRGB(255,0,0)),
                    ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255,255,0)),
                    ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0,255,0)),
                    ColorSequenceKeypoint.new(0.5,  Color3.fromRGB(0,255,255)),
                    ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0,0,255)),
                    ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255,0,255)),
                    ColorSequenceKeypoint.new(1,    Color3.fromRGB(255,0,0)),
                }),
            })

            local hue=0
            local HKnob=mk("Frame",HueBar,{
                Size=UDim2.new(0,12,0,18),Position=UDim2.new(0,-6,0.5,-9),
                BackgroundColor3=T.White,BorderSizePixel=0,ZIndex=22,
            })
            rnd(HKnob,3) bdr(HKnob,T.Border,1,0.1)

            -- Saturation/Value square
            local SVFrame=mk("Frame",CPPanel,{
                Size=UDim2.new(1,-16,0,80),Position=UDim2.new(0,8,0,32),
                BackgroundColor3=Color3.fromRGB(255,0,0),BorderSizePixel=0,ZIndex=21,
            })
            rnd(SVFrame,6)
            -- white gradient (left to right)
            mk("UIGradient",SVFrame,{
                Color=ColorSequence.new(Color3.fromRGB(255,255,255),Color3.fromRGB(255,0,0)),
            })
            -- black gradient overlay (top to bottom)
            local darkOverlay=mk("Frame",SVFrame,{
                Size=UDim2.new(1,0,1,0),BackgroundColor3=Color3.fromRGB(0,0,0),
                BackgroundTransparency=0.0,BorderSizePixel=0,ZIndex=22,
            })
            rnd(darkOverlay,6)
            mk("UIGradient",darkOverlay,{
                Color=ColorSequence.new(Color3.fromRGB(0,0,0),Color3.fromRGB(255,255,255)),
                Rotation=-90,
                Transparency=NumberSequence.new({
                    NumberSequenceKeypoint.new(0,0),
                    NumberSequenceKeypoint.new(1,1),
                }),
            })

            local sat,val2=1,1
            local SVKnob=mk("Frame",SVFrame,{
                Size=UDim2.new(0,12,0,12),Position=UDim2.new(1,-6,0,-6),
                BackgroundColor3=T.White,BorderSizePixel=0,ZIndex=24,
            })
            rnd(SVKnob,99) bdr(SVKnob,T.White,1.5,0.1)

            local function applyColor()
                col=Color3.fromHSV(hue,sat,val2)
                Swatch.BackgroundColor3=col
                SVFrame.BackgroundColor3=Color3.fromHSV(hue,1,1)
                if flag then Flags[flag]=col end
                if cb then task.spawn(cb,col) end
            end

            -- Hue drag
            local hdrg=false
            local HHit=mk("TextButton",HueBar,{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=25})
            HHit.InputBegan:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 then hdrg=true end
            end)
            UserInput.InputChanged:Connect(function(i)
                if hdrg and i.UserInputType==Enum.UserInputType.MouseMovement then
                    local rx=math.clamp((i.Position.X-HueBar.AbsolutePosition.X)/HueBar.AbsoluteSize.X,0,1)
                    hue=rx
                    tw(HKnob,{Position=UDim2.new(rx,-6,0.5,-9)},0.04)
                    applyColor()
                end
            end)
            UserInput.InputEnded:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 then hdrg=false end
            end)

            -- SV drag
            local svdrg=false
            local SVHit=mk("TextButton",SVFrame,{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=25})
            SVHit.InputBegan:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 then svdrg=true end
            end)
            UserInput.InputChanged:Connect(function(i)
                if svdrg and i.UserInputType==Enum.UserInputType.MouseMovement then
                    sat=math.clamp((i.Position.X-SVFrame.AbsolutePosition.X)/SVFrame.AbsoluteSize.X,0,1)
                    val2=1-math.clamp((i.Position.Y-SVFrame.AbsolutePosition.Y)/SVFrame.AbsoluteSize.Y,0,1)
                    tw(SVKnob,{Position=UDim2.new(sat,-6,1-val2,-6)},0.04)
                    applyColor()
                end
            end)
            UserInput.InputEnded:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 then svdrg=false end
            end)

            local Hit=mk("TextButton",Swatch,{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=22})
            Hit.MouseButton1Click:Connect(function()
                open2=not open2
                if open2 then
                    CPPanel.Visible=true CPPanel.Size=UDim2.new(1,-24,0,0)
                    tw(CPPanel,{Size=UDim2.new(1,-24,0,126)},.22,Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
                    tw(R,{Size=UDim2.new(1,0,0,184)},.22)
                else
                    tw(CPPanel,{Size=UDim2.new(1,-24,0,0)},.18)
                    tw(R,{Size=UDim2.new(1,0,0,50)},.18)
                    task.wait(.2) CPPanel.Visible=false
                end
            end)

            local Obj={}
            function Obj:Set(newCol)
                col=newCol Swatch.BackgroundColor3=newCol
                local h2,s2,v2=Color3.toHSV(newCol)
                hue=h2 sat=s2 val2=v2
                SVFrame.BackgroundColor3=Color3.fromHSV(h2,1,1)
                tw(HKnob,{Position=UDim2.new(h2,-6,0.5,-9)},0.1)
                tw(SVKnob,{Position=UDim2.new(s2,-6,1-v2,-6)},0.1)
                if flag then Flags[flag]=col end
                if cb then task.spawn(cb,col) end
            end
            return Obj
        end

        return TabAPI
    end

    return WinAPI
end

return Library
