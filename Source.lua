-- Source.lua
-- RemingtonHub (API compat untuk panggilan pengguna)
-- By: RaihjnDev (adapted)
-- Features: CreateWindow/CreateTab/CreateSection/Controls/Config/Save/Notify

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local LP = Players.LocalPlayer

local RHub = {}
RHub.__index = RHub

-- THEME (default)
local ThemePresets = {
    default = {
        Glass  = Color3.fromRGB(18,22,40),
        Card   = Color3.fromRGB(24,28,50),
        Accent = Color3.fromRGB(0,180,255),
        Accent2= Color3.fromRGB(0,120,255),
        Text   = Color3.fromRGB(230,235,255),
        Sub    = Color3.fromRGB(120,150,210),
    }
}

-- Small util
local function clamp(n, a, b) return math.max(a, math.min(b, n)) end

-- Safe file ops (pcall wrappers for executors)
local function safe_isfolder(name)
    local ok,res = pcall(function() return isfolder and isfolder(name) end)
    return ok and res
end
local function safe_makefolder(name)
    pcall(function() if makefolder and not isfolder(name) then makefolder(name) end end)
end
local function safe_writefile(path, data)
    pcall(function() if writefile then writefile(path, data) end end)
end
local function safe_isfile(path)
    local ok,res = pcall(function() return isfile and isfile(path) end)
    return ok and res
end
local function safe_readfile(path)
    local ok,res = pcall(function() return readfile and readfile(path) end)
    if ok then return res end
    return nil
end

-- Centralized lightweight spring manager (re-usable)
local Spring = {}
Spring.__index = Spring
function Spring.new(initial, speed, damper)
    return setmetatable({
        Value = initial or 0,
        Target = initial or 0,
        Velocity = 0,
        Speed = speed or 18,
        Damper = damper or 0.8,
    }, Spring)
end
function Spring:SetTarget(t) self.Target = t end
function Spring:Get() return self.Value end
function Spring:Update(dt)
    local force = (self.Target - self.Value) * self.Speed
    self.Velocity = (self.Velocity + force * dt) * self.Damper
    self.Value = self.Value + self.Velocity * dt
    return self.Value
end

-- Module:CreateWindow(cfg)
-- cfg fields allowed (matching sample): Name, LoadingTitle, LoadingSubtitle, Theme, ToggleUIKeybind, DisableRemingtonPrompts, DisableBuildWarnings,
-- ConfigurationSaving = { Enable, FolderName, FileName }, Discord = {Enable, Invite, RememberJoins}, KeySystem, KeySettings
function RHub:CreateWindow(cfg)
    cfg = cfg or {}
    local windowName = cfg.Name or "RemingtonHub"
    local loadTitle = cfg.LoadingTitle or "RemingtonHub"
    local loadSub = cfg.LoadingSubtitle or "By RaihjnDev"
    local themeName = cfg.Theme or "default"
    local keybindToggle = (cfg.ToggleUIKeybind or "RightShift")
    local configSaving = cfg.ConfigurationSaving or {Enable = false, FolderName = "RHubConfigs", FileName = "config.json"}
    local discordCfg = cfg.Discord or {Enable = false, Invite = "", RememberJoins = false}
    local keySystem = cfg.KeySystem or false
    local keySettings = cfg.KeySettings or {}

    local Theme = ThemePresets[themeName] or ThemePresets["default"]

    -- cleanup existing GUI
    pcall(function()
        local existing = CoreGui:FindFirstChild("RemingtonHub_UI")
        if existing then existing:Destroy() end
    end)

    -- Blur
    local blur
    pcall(function()
        blur = Instance.new("BlurEffect")
        blur.Size = 0
        blur.Priority = 100
        blur.Parent = Lighting
        TweenService:Create(blur, TweenInfo.new(0.45, Enum.EasingStyle.Quad), {Size = 18}):Play()
    end)

    -- ScreenGui
    local Gui = Instance.new("ScreenGui")
    Gui.Name = "RemingtonHub_UI"
    Gui.Parent = CoreGui
    Gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    Gui.ResetOnSpawn = false

    -- Main Frame
    local Main = Instance.new("Frame", Gui)
    Main.Name = "MainWindow"
    Main.Size = UDim2.fromOffset(0,0)
    Main.Position = UDim2.new(0.5,0,0.5,0)
    Main.AnchorPoint = Vector2.new(0.5,0.5)
    Main.BackgroundColor3 = Theme.Glass
    Main.BackgroundTransparency = 0.08
    Main.ClipsDescendants = true
    local MainCorner = Instance.new("UICorner", Main)
    MainCorner.CornerRadius = UDim.new(0,18)

    TweenService:Create(Main, TweenInfo.new(0.55, Enum.EasingStyle.Exponential), {
        Size = UDim2.fromOffset(580,520)
    }):Play()

    -- Title Bar
    local TitleBar = Instance.new("Frame", Main)
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, -30, 0, 50)
    TitleBar.Position = UDim2.new(0,15,0,10)
    TitleBar.BackgroundTransparency = 1

    local TitleLabel = Instance.new("TextLabel", TitleBar)
    TitleLabel.Size = UDim2.new(1,0,1,0)
    TitleLabel.Position = UDim2.new(0,8,0,0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 18
    TitleLabel.TextColor3 = Theme.Text
    TitleLabel.Text = windowName
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Animated Gradient Border
    local Border = Instance.new("UIStroke", Main)
    Border.Thickness = 1.4
    Border.Transparency = 0.2
    local Grad = Instance.new("UIGradient", Border)
    Grad.Color = ColorSequence.new{ ColorSequenceKeypoint.new(0, Theme.Accent), ColorSequenceKeypoint.new(1, Theme.Accent2) }
    local gradConn = RunService.RenderStepped:Connect(function() if Grad then Grad.Rotation = (Grad.Rotation + 0.2) % 360 end end)

    -- Glow Image (mica feel)
    pcall(function()
        local glow = Instance.new("ImageLabel", Main)
        glow.Name = "Glow"
        glow.Size = UDim2.new(1,60,1,60)
        glow.Position = UDim2.new(0,-30,0,-30)
        glow.BackgroundTransparency = 1
        glow.Image = "rbxassetid://5028857084"
        glow.ImageTransparency = 0.86
        glow.ScaleType = Enum.ScaleType.Slice
        glow.SliceCenter = Rect.new(24,24,276,276)
    end)

    -- Floating gentle motion
    task.spawn(function()
        local base = Main.Position
        while Main and Main.Parent do
            TweenService:Create(Main, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Position = base + UDim2.new(0,0,0,3)}):Play()
            task.wait(2)
            TweenService:Create(Main, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Position = base}):Play()
            task.wait(2)
        end
    end)

    -- Container for pages
    local Container = Instance.new("Frame", Main)
    Container.Name = "Container"
    Container.Size = UDim2.new(1, -30, 1, -95)
    Container.Position = UDim2.new(0,15,0,65)
    Container.BackgroundTransparency = 1

    local Layout = Instance.new("UIListLayout", Container)
    Layout.Padding = UDim.new(0,14)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder

    -- Tab buttons holder
    local TabButtons = Instance.new("Frame", Main)
    TabButtons.Name = "TabButtons"
    TabButtons.Size = UDim2.new(1, -30, 0, 45)
    TabButtons.Position = UDim2.new(0,15,0,15)
    TabButtons.BackgroundTransparency = 1
    local TabLayout = Instance.new("UIListLayout", TabButtons)
    TabLayout.FillDirection = Enum.FillDirection.Horizontal
    TabLayout.Padding = UDim.new(0,10)
    TabLayout.VerticalAlignment = Enum.VerticalAlignment.Center

    local Pages = {}
    local connections = {}

    -- Ripple helper (position expects local within parent)
    local function Ripple(parent, x, y)
        local circ = Instance.new("Frame", parent)
        circ.AnchorPoint = Vector2.new(0.5, 0.5)
        circ.Size = UDim2.fromOffset(0,0)
        circ.Position = UDim2.fromOffset(x,y)
        circ.BackgroundColor3 = Color3.new(1,1,1)
        circ.BackgroundTransparency = 0.7
        local ccorner = Instance.new("UICorner", circ); ccorner.CornerRadius = UDim.new(1,0)
        TweenService:Create(circ, TweenInfo.new(0.45, Enum.EasingStyle.Quad), {Size = UDim2.fromOffset(240,240), BackgroundTransparency = 1}):Play()
        task.delay(0.45, function() pcall(function() if circ then circ:Destroy() end end) end)
    end

    -- Draggable (TitleBar)
    do
        local dragging, dragStart, startPos = false, Vector2.new(), UDim2.new()
        TitleBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = Main.Position
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = input.Position - dragStart
                Main.Position = startPos + UDim2.new(0, delta.X, 0, delta.Y)
            end
        end)
        TitleBar.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
    end

    -- Toggle UI via key specified (supports single-letter like "i" or KeyCode names)
    do
        local open = true
        local key = keybindToggle or "RightShift"
        local function matchKey(input)
            if typeof(key) == "string" then
                local lowerKey = key:lower()
                if #lowerKey == 1 then -- single char: compare KeyCode from Character
                    return input.KeyCode.Name:lower() == ("k"):gsub("k","") or false -- fallback
                end
            end
            return false
        end
        local conn = UserInputService.InputBegan:Connect(function(input, gp)
            if gp then return end
            -- Accept full KeyCode name OR single char (as Enum.KeyCode.Letter)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                local name = input.KeyCode.Name
                if (key:lower() == name:lower()) or (#key == 1 and name:lower() == ("Key"..key):lower():gsub("Key",""):lower()) then
                    open = not open
                    Main.Visible = open
                    if blur then
                        if open then TweenService:Create(blur, TweenInfo.new(0.35), {Size = 18}):Play() else TweenService:Create(blur, TweenInfo.new(0.35), {Size = 0}):Play() end
                    end
                end
            end
        end)
        table.insert(connections, conn)
    end

    -- Config save/load helpers
    safe_makefolder(configSaving.FolderName or "RHubConfigs")
    local configPath = (configSaving.FolderName or "RHubConfigs").."/"..(configSaving.FileName or "config.json")
    local function SaveConfig(data)
        if not configSaving.Enable then return end
        pcall(function()
            safe_writefile(configPath, HttpService:JSONEncode(data or {}))
        end)
    end
    local function LoadConfig()
        if not configSaving.Enable then return {} end
        if safe_isfile(configPath) then
            local raw = safe_readfile(configPath)
            if raw then
                local ok, dec = pcall(function() return HttpService:JSONDecode(raw) end)
                if ok then return dec end
            end
        end
        return {}
    end

    -- Notification API: accepts table {Title, Content, Duration, Image}
    local function Notify(opts)
        opts = opts or {}
        local title = opts.Title or "Notification"
        local content = opts.Content or ""
        local duration = opts.Duration or 3
        local image = opts.Image

        local Notif = Instance.new("Frame", Gui)
        Notif.Size = UDim2.fromOffset(300,70)
        Notif.Position = UDim2.new(1, -320, 1, -90)
        Notif.BackgroundColor3 = Theme.Card
        Notif.BackgroundTransparency = 0.06
        local ncorner = Instance.new("UICorner", Notif); ncorner.CornerRadius = UDim.new(0,12)

        local Title = Instance.new("TextLabel", Notif)
        Title.Size = UDim2.new(1,-20,0,22)
        Title.Position = UDim2.new(0,10,0,6)
        Title.BackgroundTransparency = 1
        Title.Font = Enum.Font.GothamBold
        Title.TextSize = 14
        Title.TextColor3 = Theme.Text
        Title.Text = title
        Title.TextXAlignment = Enum.TextXAlignment.Left

        local Body = Instance.new("TextLabel", Notif)
        Body.Size = UDim2.new(1,-20,0,36)
        Body.Position = UDim2.new(0,10,0,28)
        Body.BackgroundTransparency = 1
        Body.Font = Enum.Font.Gotham
        Body.TextSize = 13
        Body.TextColor3 = Theme.Sub
        Body.Text = content
        Body.TextXAlignment = Enum.TextXAlignment.Left

        TweenService:Create(Notif, TweenInfo.new(0.36, Enum.EasingStyle.Exponential), {Position = UDim2.new(1, -320, 1, -110)}):Play()
        task.delay(duration, function() pcall(function() Notif:Destroy() end) end)
    end

    -- Window object to return
    local Window = {}

    -- CreateTab API: returns Tab object
    function Window:CreateTab(title, imageId)
        local Page = Instance.new("Frame", Container)
        Page.Name = title.."_Page"
        Page.Size = UDim2.new(1,0,1,0)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        local pageLayout = Instance.new("UIListLayout", Page)
        pageLayout.Padding = UDim.new(0,14)
        pageLayout.SortOrder = Enum.SortOrder.LayoutOrder

        -- Tab Button
        local TabBtn = Instance.new("ImageButton", TabButtons)
        TabBtn.Name = title.."_Tab"
        TabBtn.Size = UDim2.fromOffset(140,36)
        TabBtn.BackgroundColor3 = Theme.Card
        TabBtn.BackgroundTransparency = 0.18
        TabBtn.AutoButtonColor = true
        TabBtn.Image = ""
        local corner = Instance.new("UICorner", TabBtn); corner.CornerRadius = UDim.new(0,10)
        local txt = Instance.new("TextLabel", TabBtn)
        txt.Size = UDim2.new(1,0,1,0)
        txt.BackgroundTransparency = 1
        txt.Font = Enum.Font.GothamBold
        txt.TextSize = 14
        txt.TextColor3 = Theme.Text
        txt.Text = title
        txt.AnchorPoint = Vector2.new(0,0)
        txt.Position = UDim2.new(0,6,0,0)
        txt.TextXAlignment = Enum.TextXAlignment.Left

        TabBtn.MouseButton1Click:Connect(function()
            for _,p in pairs(Pages) do p.Visible = false end
            Page.Visible = true
        end)

        table.insert(Pages, Page)
        if #Pages == 1 then Page.Visible = true end

        -- Tab object methods (match sample names)
        local Tab = {}

        function Tab:CreateSection(name)
            local SectionHolder = Instance.new("Frame", Page)
            SectionHolder.Name = name.."_Section"
            SectionHolder.Size = UDim2.new(1,0,0,50)
            SectionHolder.BackgroundTransparency = 1
            SectionHolder.ClipsDescendants = true

            local Header = Instance.new("Frame", SectionHolder)
            Header.Size = UDim2.new(1,0,0,50)
            Header.BackgroundColor3 = Theme.Card
            Header.BackgroundTransparency = 0.18
            local hc = Instance.new("UICorner", Header); hc.CornerRadius = UDim.new(0,14)

            local Label = Instance.new("TextLabel", Header)
            Label.Size = UDim2.new(1,-30,1,0)
            Label.Position = UDim2.new(0,10,0,0)
            Label.BackgroundTransparency = 1
            Label.Text = name
            Label.Font = Enum.Font.GothamBold
            Label.TextSize = 14
            Label.TextColor3 = Theme.Text
            Label.TextXAlignment = Enum.TextXAlignment.Left

            local Arrow = Instance.new("ImageLabel", Header)
            Arrow.Size = UDim2.fromOffset(18,18)
            Arrow.Position = UDim2.new(1,-28,0.5,-9)
            Arrow.BackgroundTransparency = 1
            Arrow.Image = "rbxassetid://3926307971"
            Arrow.Rotation = 0

            local Content = Instance.new("Frame", SectionHolder)
            Content.Size = UDim2.new(1,0,0,0)
            Content.Position = UDim2.new(0,0,0,50)
            Content.BackgroundTransparency = 1
            Content.ClipsDescendants = true
            local contentLayout = Instance.new("UIListLayout", Content)
            contentLayout.Padding = UDim.new(0,10)
            contentLayout.SortOrder = Enum.SortOrder.LayoutOrder

            local open = false
            local function updateSize()
                RunService.Heartbeat:Wait()
                local h = contentLayout and contentLayout.AbsoluteContentSize.Y or 0
                local target = open and (50 + h + 10) or 50
                TweenService:Create(SectionHolder, TweenInfo.new(0.28, Enum.EasingStyle.Exponential), {Size = UDim2.new(1,0,0,target)}):Play()
                TweenService:Create(Content, TweenInfo.new(0.28, Enum.EasingStyle.Exponential), {Size = UDim2.new(1,0,0, open and (h + 10) or 0)}):Play()
                TweenService:Create(Arrow, TweenInfo.new(0.28), {Rotation = open and 90 or 0}):Play()
            end

            local HeaderBtn = Instance.new("TextButton", Header)
            HeaderBtn.Size = UDim2.new(1,0,1,0)
            HeaderBtn.BackgroundTransparency = 1
            HeaderBtn.Text = ""
            HeaderBtn.AutoButtonColor = false
            HeaderBtn.MouseButton1Click:Connect(function()
                open = not open
                updateSize()
            end)
            updateSize()

            local SectionAPI = {}

            function SectionAPI:CreateButton(name, cb)
                local Btn = Instance.new("Frame", Content)
                Btn.Size = UDim2.new(1,0,0,48)
                Btn.BackgroundColor3 = Theme.Card
                Btn.BackgroundTransparency = 0.12
                local bcorner = Instance.new("UICorner", Btn); bcorner.CornerRadius = UDim.new(0,12)
                local lbl = Instance.new("TextLabel", Btn)
                lbl.Size = UDim2.new(1,-20,1,0)
                lbl.Position = UDim2.new(0,10,0,0)
                lbl.BackgroundTransparency = 1
                lbl.Font = Enum.Font.GothamBold
                lbl.TextSize = 13
                lbl.TextColor3 = Theme.Text
                lbl.Text = name
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                local hit = Instance.new("TextButton", Btn)
                hit.Size = UDim2.new(1,0,1,0)
                hit.BackgroundTransparency = 1
                hit.Text = ""
                hit.MouseButton1Click:Connect(function()
                    local x = hit.AbsolutePosition.X - Btn.AbsolutePosition.X + hit.AbsoluteSize.X/2
                    local y = hit.AbsolutePosition.Y - Btn.AbsolutePosition.Y + hit.AbsoluteSize.Y/2
                    Ripple(Btn, x, y)
                    if cb then cb() end
                end)
                updateSize()
                return Btn
            end

            function SectionAPI:CreateToggle(opts)
                -- opts: {Name, CurrentValue, Flag, Callback}
                opts = opts or {}
                local state = opts.CurrentValue and true or false
                local Row = Instance.new("Frame", Content)
                Row.Size = UDim2.new(1,0,0,55)
                Row.BackgroundColor3 = Theme.Card
                Row.BackgroundTransparency = 0.12
                local corner = Instance.new("UICorner", Row); corner.CornerRadius = UDim.new(0,12)
                local label = Instance.new("TextLabel", Row)
                label.Size = UDim2.new(1,-70,1,0)
                label.Position = UDim2.new(0,15,0,0)
                label.BackgroundTransparency = 1
                label.Font = Enum.Font.GothamBold
                label.TextSize = 13
                label.TextColor3 = Theme.Text
                label.Text = tostring(opts.Name or "Toggle")
                label.TextXAlignment = Enum.TextXAlignment.Left

                local sw = Instance.new("Frame", Row)
                sw.Size = UDim2.fromOffset(46,24)
                sw.Position = UDim2.new(1,-65,0.5,-12)
                sw.BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(80,90,110)
                local swc = Instance.new("UICorner", sw); swc.CornerRadius = UDim.new(1,0)
                local knob = Instance.new("Frame", sw)
                knob.Size = UDim2.fromOffset(20,20)
                knob.Position = state and UDim2.new(1,-22,0.5,-10) or UDim2.new(0,2,0.5,-10)
                knob.BackgroundColor3 = Color3.new(1,1,1)
                local kcorner = Instance.new("UICorner", knob); kcorner.CornerRadius = UDim.new(1,0)

                local hit = Instance.new("TextButton", Row)
                hit.Size = UDim2.new(1,0,1,0)
                hit.BackgroundTransparency = 1
                hit.Text = ""
                hit.MouseButton1Click:Connect(function()
                    state = not state
                    TweenService:Create(sw, TweenInfo.new(0.28, Enum.EasingStyle.Exponential), {BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(80,90,110)}):Play()
                    TweenService:Create(knob, TweenInfo.new(0.32, Enum.EasingStyle.Exponential), {Position = state and UDim2.new(1,-22,0.5,-10) or UDim2.new(0,2,0.5,-10)}):Play()
                    if opts.Callback then opts.Callback(state) end
                end)
                updateSize()
                return Row
            end

            function SectionAPI:CreateSlider(opts)
                -- opts: {Name, Range = {min,max}, Increment, Suffix, CurrentValue, Flag, Callback}
                opts = opts or {}
                local min = (opts.Range and opts.Range[1]) or 0
                local max = (opts.Range and opts.Range[2]) or 100
                local value = opts.CurrentValue or min
                local Holder = Instance.new("Frame", Content)
                Holder.Size = UDim2.new(1,0,0,68)
                Holder.BackgroundColor3 = Theme.Card
                Holder.BackgroundTransparency = 0.12
                local hc = Instance.new("UICorner", Holder); hc.CornerRadius = UDim.new(0,12)
                local Label = Instance.new("TextLabel", Holder)
                Label.Size = UDim2.new(1,-20,0,24); Label.Position = UDim2.new(0,10,0,6)
                Label.BackgroundTransparency = 1
                Label.Font = Enum.Font.GothamBold; Label.TextSize = 13; Label.TextColor3 = Theme.Text
                Label.TextXAlignment = Enum.TextXAlignment.Left
                local suffix = opts.Suffix and (" "..tostring(opts.Suffix)) or ""
                Label.Text = tostring(opts.Name or "Slider").." : "..tostring(value)..suffix

                local Bar = Instance.new("Frame", Holder)
                Bar.Size = UDim2.new(1,-20,0,8); Bar.Position = UDim2.new(0,10,0,38)
                Bar.BackgroundColor3 = Color3.fromRGB(70,80,110); local bc = Instance.new("UICorner", Bar); bc.CornerRadius = UDim.new(1,0)
                local Fill = Instance.new("Frame", Bar)
                Fill.Size = UDim2.new((max == min) and 0 or (value-min)/(max-min), 0, 1, 0)
                Fill.BackgroundColor3 = Theme.Accent; local fc = Instance.new("UICorner", Fill); fc.CornerRadius = UDim.new(1,0)

                local dragging = false
                Bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
                Bar.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
                local conn = UserInputService.InputChanged:Connect(function(i)
                    if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
                        local percent = clamp((i.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                        local rawVal = min + (max - min) * percent
                        -- apply increment
                        if opts.Increment and type(opts.Increment) == "number" and opts.Increment > 0 then
                            rawVal = math.floor(rawVal / opts.Increment + 0.5) * opts.Increment
                        end
                        value = rawVal
                        Label.Text = tostring(opts.Name or "Slider").." : "..tostring(math.floor(value))..suffix
                        Fill.Size = UDim2.new(percent,0,1,0)
                        if opts.Callback then opts.Callback(value) end
                    end
                end)
                table.insert(connections, conn)
                updateSize()
                return Holder
            end

            function SectionAPI:CreateDropdown(opts)
                -- opts: {Name, Options = {}, CurrentOption = {..}, MultipleOptions = false, Flag, Callback}
                opts = opts or {}
                local options = opts.Options or {}
                local selected = (opts.CurrentOption and opts.CurrentOption[1]) or options[1] or ""
                local Holder = Instance.new("Frame", Content)
                Holder.Size = UDim2.new(1,0,0,52); Holder.BackgroundColor3 = Theme.Card; Holder.BackgroundTransparency = 0.12
                Holder.ClipsDescendants = true; local hc = Instance.new("UICorner", Holder); hc.CornerRadius = UDim.new(0,12)
                local Button = Instance.new("TextButton", Holder)
                Button.Size = UDim2.new(1,0,0,52); Button.BackgroundTransparency = 1; Button.Text = tostring(opts.Name or "Dropdown").." : "..tostring(selected)
                Button.Font = Enum.Font.GothamBold; Button.TextSize = 13; Button.TextColor3 = Theme.Text
                local List = Instance.new("Frame", Holder)
                List.Size = UDim2.new(1,0,0,0); List.Position = UDim2.new(0,0,0,52); List.BackgroundTransparency = 1
                local ll = Instance.new("UIListLayout", List); ll.Padding = UDim.new(0,6)
                local open = false
                for i,v in ipairs(options) do
                    local optBtn = Instance.new("TextButton", List)
                    optBtn.Size = UDim2.new(1,-20,0,36); optBtn.Position = UDim2.new(0,10,0,0)
                    optBtn.BackgroundColor3 = Theme.Glass; local oc = Instance.new("UICorner", optBtn); oc.CornerRadius = UDim.new(0,8)
                    optBtn.Font = Enum.Font.Gotham; optBtn.TextSize = 13; optBtn.TextColor3 = Theme.Text; optBtn.Text = v
                    optBtn.MouseButton1Click:Connect(function()
                        selected = v
                        Button.Text = tostring(opts.Name or "Dropdown").." : "..tostring(selected)
                        if opts.Callback then opts.Callback({selected}) end
                    end)
                end
                Button.MouseButton1Click:Connect(function()
                    open = not open
                    local count = #options
                    local newSize = open and (52 + count * 44) or 52
                    TweenService:Create(Holder, TweenInfo.new(0.28, Enum.EasingStyle.Exponential), {Size = UDim2.new(1,0,0,newSize)}):Play()
                    TweenService:Create(List, TweenInfo.new(0.28, Enum.EasingStyle.Exponential), {Size = UDim2.new(1,0,0, open and (count*44) or 0)}):Play()
                end)
                updateSize()
                return Holder
            end

            function SectionAPI:CreateInput(opts)
                -- opts: {Name, CurrentValue, PlaceholderText, RemoveTextAfterFocusLost, Flag, Callback}
                opts = opts or {}
                local val = opts.CurrentValue or ""
                local Holder = Instance.new("Frame", Content)
                Holder.Size = UDim2.new(1,0,0,48); Holder.BackgroundColor3 = Theme.Card; Holder.BackgroundTransparency = 0.12
                local hc = Instance.new("UICorner", Holder); hc.CornerRadius = UDim.new(0,12)
                local txtLabel = Instance.new("TextLabel", Holder)
                txtLabel.Size = UDim2.new(0.38, -10, 1, 0); txtLabel.Position = UDim2.new(0,10,0,0)
                txtLabel.BackgroundTransparency = 1; txtLabel.Font = Enum.Font.GothamBold; txtLabel.TextSize = 13; txtLabel.TextColor3 = Theme.Text
                txtLabel.Text = tostring(opts.Name or "Input")
                txtLabel.TextXAlignment = Enum.TextXAlignment.Left

                local box = Instance.new("TextBox", Holder)
                box.Size = UDim2.new(0.6, -20, 1, -8); box.Position = UDim2.new(0.38, 10, 0, 4)
                box.BackgroundTransparency = 1; box.Text = tostring(val); box.PlaceholderText = (opts.PlaceholderText or "")
                box.Font = Enum.Font.Gotham; box.TextSize = 14; box.TextColor3 = Theme.Text

                box.FocusLost:Connect(function(enter)
                    local t = box.Text
                    if opts.RemoveTextAfterFocusLost then box.Text = "" end
                    if opts.Callback then opts.Callback(t) end
                end)
                updateSize()
                return Holder
            end

            function SectionAPI:CreateColorPicker(opts)
                -- opts: {Name, Color = Color3, Flag, Callback}
                opts = opts or {}
                local color = opts.Color or Color3.fromRGB(255,255,255)
                local Holder = Instance.new("Frame", Content)
                Holder.Size = UDim2.new(1,0,0,58); Holder.BackgroundColor3 = Theme.Card; Holder.BackgroundTransparency = 0.12
                local hc = Instance.new("UICorner", Holder); hc.CornerRadius = UDim.new(0,12)
                local label = Instance.new("TextLabel", Holder)
                label.Size = UDim2.new(0.6, -10, 0, 20); label.Position = UDim2.new(0,10,0,8)
                label.BackgroundTransparency = 1; label.Font = Enum.Font.GothamBold; label.TextSize = 13; label.TextColor3 = Theme.Text
                label.Text = tostring(opts.Name or "Color Picker")
                local preview = Instance.new("Frame", Holder)
                preview.Size = UDim2.fromOffset(30,30); preview.Position = UDim2.new(1,-50,0,12)
                preview.BackgroundColor3 = color; local pc = Instance.new("UICorner", preview); pc.CornerRadius = UDim.new(0,6)

                local button = Instance.new("TextButton", Holder)
                button.Size = UDim2.new(1,0,1,0); button.BackgroundTransparency = 1; button.Text = ""

                -- On click, open quick colorpicker with RGB sliders
                button.MouseButton1Click:Connect(function()
                    -- popup
                    local pop = Instance.new("Frame", Gui)
                    pop.Size = UDim2.fromOffset(300,160); pop.Position = UDim2.new(0.5,-150,0.5,-80)
                    pop.AnchorPoint = Vector2.new(0.5,0.5); pop.BackgroundColor3 = Theme.Card; local pcorn = Instance.new("UICorner", pop); pcorn.CornerRadius = UDim.new(0,12)
                    local title = Instance.new("TextLabel", pop); title.Size = UDim2.new(1,0,0,28); title.Position = UDim2.new(0,0,0,6); title.BackgroundTransparency = 1
                    title.Font = Enum.Font.GothamBold; title.TextSize = 14; title.TextColor3 = Theme.Text; title.Text = "Color Picker"
                    local rS,gS,bS = 255,255,255
                    local function makeSlider(y,labelText,initial, onChange)
                        local hl = Instance.new("TextLabel", pop)
                        hl.Size = UDim2.new(0.4, -10,0,22); hl.Position = UDim2.new(0,10,0,y); hl.BackgroundTransparency = 1
                        hl.Font = Enum.Font.Gotham; hl.TextSize = 13; hl.TextColor3 = Theme.Text; hl.Text = labelText
                        local hbar = Instance.new("Frame", pop)
                        hbar.Size = UDim2.new(0.58, -20,0,14); hbar.Position = UDim2.new(0.4,10,0,y+6); hbar.BackgroundColor3 = Color3.fromRGB(70,80,110)
                        local hfill = Instance.new("Frame", hbar); hfill.Size = UDim2.new((initial/255),0,1,0); hfill.BackgroundColor3 = Theme.Accent
                        local dragging = false
                        hbar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging = true end end)
                        hbar.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging = false end end)
                        local conn = UserInputService.InputChanged:Connect(function(i)
                            if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then
                                local p = clamp((i.Position.X - hbar.AbsolutePosition.X)/hbar.AbsoluteSize.X,0,1)
                                hfill.Size = UDim2.new(p,0,1,0)
                                if onChange then onChange(math.floor(255*p)) end
                            end
                        end)
                        table.insert(connections, conn)
                    end
                    -- initial color decomposition
                    rS,gS,bS = math.floor(color.R*255), math.floor(color.G*255), math.floor(color.B*255)
                    makeSlider(30,"R", rS, function(v) rS = v; preview.BackgroundColor3 = Color3.fromRGB(rS,gS,bS) end)
                    makeSlider(64,"G", gS, function(v) gS = v; preview.BackgroundColor3 = Color3.fromRGB(rS,gS,bS) end)
                    makeSlider(98,"B", bS, function(v) bS = v; preview.BackgroundColor3 = Color3.fromRGB(rS,gS,bS) end)
                    local okBtn = Instance.new("TextButton", pop)
                    okBtn.Size = UDim2.new(0.45, -10, 0, 28); okBtn.Position = UDim2.new(0.05,0,0,126); okBtn.BackgroundColor3 = Theme.Accent; local oc = Instance.new("UICorner", okBtn); oc.CornerRadius = UDim.new(0,8)
                    okBtn.Font = Enum.Font.GothamBold; okBtn.TextSize = 13; okBtn.TextColor3 = Color3.new(1,1,1); okBtn.Text = "Confirm"
                    local cancelBtn = Instance.new("TextButton", pop)
                    cancelBtn.Size = UDim2.new(0.45, -10, 0, 28); cancelBtn.Position = UDim2.new(0.52,0,0,126); cancelBtn.BackgroundColor3 = Color3.fromRGB(80,90,110); local cc = Instance.new("UICorner", cancelBtn); cc.CornerRadius = UDim.new(0,8)
                    cancelBtn.Font = Enum.Font.GothamBold; cancelBtn.TextSize = 13; cancelBtn.TextColor3 = Color3.new(1,1,1); cancelBtn.Text = "Cancel"
                    okBtn.MouseButton1Click:Connect(function()
                        color = Color3.fromRGB(rS,gS,bS)
                        preview.BackgroundColor3 = color
                        if opts.Callback then opts.Callback(color) end
                        pcall(function() pop:Destroy() end)
                    end)
                    cancelBtn.MouseButton1Click:Connect(function() pcall(function() pop:Destroy() end) end)
                end)
                updateSize()
                return Holder
            end

            return SectionAPI
        end

        function Tab:CreateLabel(text, icon, color3, ignoreTheme)
            local Holder = Instance.new("Frame", Page)
            Holder.Size = UDim2.new(1,0,0,40); Holder.BackgroundTransparency = 1
            local lbl = Instance.new("TextLabel", Holder)
            lbl.Size = UDim2.new(1,0,1,0); lbl.BackgroundTransparency = 1
            lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 14; lbl.TextColor3 = color3 or Theme.Text
            lbl.Text = tostring(text or "")
            lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Position = UDim2.new(0,8,0,0)
            return Holder
        end

        function Tab:CreateParagraph(opts)
            -- opts: {Title = "Title", Content = "body"}
            opts = opts or {}
            local Holder = Instance.new("Frame", Page)
            Holder.Size = UDim2.new(1,0,0,80); Holder.BackgroundTransparency = 1
            local title = Instance.new("TextLabel", Holder)
            title.Size = UDim2.new(1,0,0,22); title.Position = UDim2.new(0,8,0,6)
            title.BackgroundTransparency = 1; title.Font = Enum.Font.GothamBold; title.TextSize = 14; title.TextColor3 = Theme.Text; title.Text = tostring(opts.Title or "")
            local body = Instance.new("TextLabel", Holder)
            body.Size = UDim2.new(1,-20,0,44); body.Position = UDim2.new(0,10,0,30); body.BackgroundTransparency = 1
            body.Font = Enum.Font.Gotham; body.TextSize = 13; body.TextColor3 = Theme.Sub; body.Text = tostring(opts.Content or ""); body.TextWrapped = true
            return Holder
        end

        function Tab:CreateToggle(opts)
            -- opts: {Name, CurrentValue, Flag, Callback}
            opts = opts or {}
            local section = Page -- directly put into page
            local state = opts.CurrentValue and true or false
            local Row = Instance.new("Frame", section)
            Row.Size = UDim2.new(1,0,0,55); Row.BackgroundColor3 = Theme.Card; Row.BackgroundTransparency = 0.18
            local corner = Instance.new("UICorner", Row); corner.CornerRadius = UDim.new(0,14)
            local label = Instance.new("TextLabel", Row)
            label.Size = UDim2.new(1,-70,1,0); label.Position = UDim2.new(0,15,0,0); label.BackgroundTransparency = 1
            label.Font = Enum.Font.GothamBold; label.TextSize = 14; label.TextColor3 = Theme.Text; label.Text = tostring(opts.Name or "Toggle")
            label.TextXAlignment = Enum.TextXAlignment.Left
            local Switch = Instance.new("Frame", Row); Switch.Size = UDim2.fromOffset(46,24); Switch.Position = UDim2.new(1,-65,0.5,-12)
            Switch.BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(80,90,110); local sc = Instance.new("UICorner", Switch); sc.CornerRadius = UDim.new(1,0)
            local Knob = Instance.new("Frame", Switch); Knob.Size = UDim2.fromOffset(20,20); Knob.Position = state and UDim2.new(1,-22,0.5,-10) or UDim2.new(0,2,0.5,-10)
            Knob.BackgroundColor3 = Color3.new(1,1,1); local kc = Instance.new("UICorner", Knob); kc.CornerRadius = UDim.new(1,0)
            local Hit = Instance.new("TextButton", Row); Hit.Size = UDim2.new(1,0,1,0); Hit.BackgroundTransparency = 1; Hit.Text = ""
            Hit.MouseButton1Click:Connect(function()
                state = not state
                TweenService:Create(Switch, TweenInfo.new(0.28, Enum.EasingStyle.Exponential), {BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(80,90,110)}):Play()
                TweenService:Create(Knob, TweenInfo.new(0.32, Enum.EasingStyle.Exponential), {Position = state and UDim2.new(1,-22,0.5,-10) or UDim2.new(0,2,0.5,-10)}):Play()
                if opts.Callback then opts.Callback(state) end
            end)
            return Row
        end

        function Tab:CreateColorPicker(opts)
            -- wrapper to section's CreateColorPicker
            local fakeSection = Page
            local x = (Tab:CreateSection and Tab:CreateSection("ColorTemp")) -- not used; just call Section API instead:
            -- Simpler: make temporary SectionAPI via internal Section creation
            local tmp = Tab:CreateSection("ColorPickerTemp")
            local s = tmp
            -- plugin: immediately create color picker and then destroy temp header to keep page clean
            local api = s
            -- but our Section API returns SectionAPI; to keep compatibility call Section:CreateColorPicker
            -- The Tab:CreateSection implementation returns a Section object, but we did not return SectionAPI directly earlier.
            -- To keep things simple: implement inline color picker on page (similar to Section)
            opts = opts or {}
            local color = opts.Color or Color3.fromRGB(255,255,255)
            local Holder = Instance.new("Frame", Page)
            Holder.Size = UDim2.new(1,0,0,58); Holder.BackgroundColor3 = Theme.Card; Holder.BackgroundTransparency = 0.18
            local hc = Instance.new("UICorner", Holder); hc.CornerRadius = UDim.new(0,14)
            local label = Instance.new("TextLabel", Holder); label.Size = UDim2.new(0.6,-10,0,20); label.Position = UDim2.new(0,10,0,8); label.BackgroundTransparency = 1
            label.Font = Enum.Font.GothamBold; label.TextSize = 13; label.TextColor3 = Theme.Text; label.Text = tostring(opts.Name or "Color Picker")
            local preview = Instance.new("Frame", Holder); preview.Size = UDim2.fromOffset(30,30); preview.Position = UDim2.new(1,-50,0,12); preview.BackgroundColor3 = color
            local pc = Instance.new("UICorner", preview); pc.CornerRadius = UDim.new(0,6)
            local button = Instance.new("TextButton", Holder); button.Size = UDim2.new(1,0,1,0); button.BackgroundTransparency = 1; button.Text = ""
            button.MouseButton1Click:Connect(function()
                -- simple color popup (reuse earlier SectionAPI logic is complex; implement a minimal popup)
                local pop = Instance.new("Frame", Gui); pop.Size = UDim2.fromOffset(300,140); pop.Position = UDim2.new(0.5,-150,0.5,-70); pop.AnchorPoint = Vector2.new(0.5,0.5); pop.BackgroundColor3 = Theme.Card
                local pcorner = Instance.new("UICorner", pop); pcorner.CornerRadius = UDim.new(0,10)
                local t = Instance.new("TextLabel", pop); t.Size = UDim2.new(1,0,0,28); t.Position = UDim2.new(0,8,0,6); t.BackgroundTransparency = 1; t.Font = Enum.Font.GothamBold; t.TextSize = 14; t.TextColor3 = Theme.Text; t.Text = "Color Picker"
                -- 3 sliders reused (R,G,B)
                local r,g,b = math.floor(color.R*255), math.floor(color.G*255), math.floor(color.B*255)
                local function makeSlider(y, labelText, initial, onChange)
                    local hl = Instance.new("TextLabel", pop); hl.Size = UDim2.new(0.38,-10,0,22); hl.Position = UDim2.new(0,10,0,y); hl.BackgroundTransparency = 1; hl.Text = labelText; hl.Font = Enum.Font.Gotham; hl.TextSize = 13; hl.TextColor3 = Theme.Text
                    local hbar = Instance.new("Frame", pop); hbar.Size = UDim2.new(0.58,-20,0,14); hbar.Position = UDim2.new(0.4,10,0,y+6); hbar.BackgroundColor3 = Color3.fromRGB(70,80,110)
                    local hfill = Instance.new("Frame", hbar); hfill.Size = UDim2.new((initial/255),0,1,0); hfill.BackgroundColor3 = Theme.Accent
                    local dragging = false
                    hbar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging = true end end)
                    hbar.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging = false end end)
                    local conn = UserInputService.InputChanged:Connect(function(i)
                        if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then
                            local p = clamp((i.Position.X - hbar.AbsolutePosition.X)/hbar.AbsoluteSize.X,0,1)
                            hfill.Size = UDim2.new(p,0,1,0)
                            if onChange then onChange(math.floor(255*p)) end
                        end
                    end)
                    table.insert(connections, conn)
                end
                makeSlider(30,"R", r, function(v) r=v; preview.BackgroundColor3 = Color3.fromRGB(r,g,b) end)
                makeSlider(64,"G", g, function(v) g=v; preview.BackgroundColor3 = Color3.fromRGB(r,g,b) end)
                makeSlider(98,"B", b, function(v) b=v; preview.BackgroundColor3 = Color3.fromRGB(r,g,b) end)
                local ok = Instance.new("TextButton", pop); ok.Size = UDim2.new(0.45,-10,0,28); ok.Position = UDim2.new(0.05,0,0,106); ok.BackgroundColor3 = Theme.Accent; local okc = Instance.new("UICorner", ok); okc.CornerRadius = UDim.new(0,8); ok.Font = Enum.Font.GothamBold; ok.TextSize = 13; ok.TextColor3 = Color3.new(1,1,1); ok.Text = "Confirm"
                local cancel = Instance.new("TextButton", pop); cancel.Size = UDim2.new(0.45,-10,0,28); cancel.Position = UDim2.new(0.52,0,0,106); cancel.BackgroundColor3 = Color3.fromRGB(80,90,110); local cc = Instance.new("UICorner", cancel); cc.CornerRadius = UDim.new(0,8); cancel.Font = Enum.Font.GothamBold; cancel.TextSize = 13; cancel.TextColor3 = Color3.new(1,1,1); cancel.Text = "Cancel"
                ok.MouseButton1Click:Connect(function()
                    color = Color3.fromRGB(r,g,b)
                    preview.BackgroundColor3 = color
                    if opts.Callback then opts.Callback(color) end
                    pcall(function() pop:Destroy() end)
                end)
                cancel.MouseButton1Click:Connect(function() pcall(function() pop:Destroy() end) end)
            end)
            updateSize()
            return Holder
        end

        function Tab:CreateLabel(...)
            return Tab.CreateLabel(self, ...)
        end

        function Tab:CreateParagraph(...)
            return Tab.CreateParagraph(self, ...)
        end

        return Tab
    end

    -- Window-level helper methods: Save/Load/Notify/Destroy
    function Window:SaveConfiguration(tbl) SaveConfig(tbl) end
    function Window:LoadConfiguration() return LoadConfig() end
    function Window:Notify(tbl) Notify(tbl) end

    function Window:Destroy()
        pcall(function()
            if gradConn then gradConn:Disconnect() end
            for _,c in ipairs(connections) do pcall(function() c:Disconnect() end) end
            if blur then TweenService:Create(blur, TweenInfo.new(0.35), {Size = 0}):Play(); task.delay(0.35, function() pcall(function() blur:Destroy() end) end) end
            if Gui and Gui.Parent then Gui:Destroy() end
        end)
    end

    return Window
end

return RHub
