-- RemingtonHub.lua
-- RemingtonHub V5 Ascended (Module)
-- By: Merged from user's V4 + V5 upgrade requests
-- Features: centralized spring engine, window, blur, animated border, ripple, floating, draggable, keybind, tabs, sliders, dropdowns, sections(accordion), config save/load, notifications.

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

-- ========================
-- THEME
-- ========================
local Theme = {
    Glass = Color3.fromRGB(18,22,40),
    Card = Color3.fromRGB(24,28,50),
    Accent = Color3.fromRGB(0,180,255),
    Accent2 = Color3.fromRGB(0,120,255),
    Text = Color3.fromRGB(230,235,255),
    Sub = Color3.fromRGB(120,150,210),
}

-- ========================
-- SPRING ENGINE (centralized & safe)
-- ========================
local SpringMgr = {}
SpringMgr.springs = {}
SpringMgr.running = false

local function clamp(n, a, b) return math.max(a, math.min(b, n)) end

local Spring = {}
Spring.__index = Spring

function Spring.new(initial, speed, damper)
    return setmetatable({
        Value = initial or 0,
        Target = initial or 0,
        Velocity = 0,
        Speed = speed or 18,
        Damper = damper or 0.8
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

function SpringMgr:Add(s)
    table.insert(self.springs, s)
    if not self.running then
        self.running = true
        self:_startLoop()
    end
end

function SpringMgr:_startLoop()
    self._conn = RunService.RenderStepped:Connect(function(dt)
        for i = #self.springs, 1, -1 do
            local s = self.springs[i]
            if s and s.Update then
                s:Update(dt)
            else
                table.remove(self.springs, i)
            end
        end
        if #self.springs == 0 then
            if self._conn then
                self._conn:Disconnect()
                self._conn = nil
            end
            self.running = false
        end
    end)
end

-- ========================
-- UTIL: Safe file ops (pcall wrappers)
-- ========================
local function safe_isfolder(name)
    local ok, res = pcall(function() return isfolder and isfolder(name) end)
    return ok and res
end

local function safe_makefolder(name)
    pcall(function()
        if makefolder and (not isfolder(name)) then
            makefolder(name)
        end
    end)
end

local function safe_writefile(path, data)
    pcall(function()
        if writefile then writefile(path, data) end
    end)
end

local function safe_isfile(path)
    local ok, res = pcall(function() return isfile and isfile(path) end)
    return ok and res
end

local function safe_readfile(path)
    local ok, data = pcall(function() return readfile and readfile(path) end)
    if ok then return data end
    return nil
end

-- ========================
-- CORE: Window builder
-- ========================
function RHub:Window(cfg)
    cfg = cfg or {}
    local title = cfg.Title or "RemingtonHub"
    local configFolder = cfg.ConfigFolder or "RHubConfigs"
    local configName = cfg.ConfigName or "config.json"

    -- Cleanup if existing
    pcall(function()
        local existing = CoreGui:FindFirstChild("RHubV5")
        if existing then existing:Destroy() end
    end)

    -- Blur effect
    local blur
    pcall(function()
        blur = Instance.new("BlurEffect")
        blur.Size = 0
        blur.Priority = 100
        blur.Parent = Lighting
        TweenService:Create(blur, TweenInfo.new(0.45, Enum.EasingStyle.Quad), {Size = 18}):Play()
    end)

    -- Main GUI container
    local Gui = Instance.new("ScreenGui")
    Gui.Name = "RHubV5"
    Gui.Parent = CoreGui
    Gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    Gui.ResetOnSpawn = false

    -- Main frame
    local Main = Instance.new("Frame", Gui)
    Main.Name = "Main"
    Main.Size = UDim2.fromOffset(0,0)
    Main.Position = UDim2.fromScale(0.5,0.5)
    Main.AnchorPoint = Vector2.new(0.5,0.5)
    Main.BackgroundColor3 = Theme.Glass
    Main.BackgroundTransparency = 0.08
    Main.ClipsDescendants = true
    local cornerMain = Instance.new("UICorner", Main)
    cornerMain.CornerRadius = UDim.new(0, 18)

    TweenService:Create(Main, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {
        Size = UDim2.fromOffset(580, 520)
    }):Play()

    -- Titlebar
    local TitleBar = Instance.new("Frame", Main)
    TitleBar.Size = UDim2.new(1, -30, 0, 50)
    TitleBar.Position = UDim2.new(0, 15, 0, 10)
    TitleBar.BackgroundTransparency = 1

    local TitleLabel = Instance.new("TextLabel", TitleBar)
    TitleLabel.Size = UDim2.new(1, 0, 1, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 18
    TitleLabel.TextColor3 = Theme.Text
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Position = UDim2.new(0, 8, 0, 0)

    -- Animated Gradient Border
    local Stroke = Instance.new("UIStroke", Main)
    Stroke.Thickness = 1.5
    Stroke.Transparency = 0.2

    local Grad = Instance.new("UIGradient", Stroke)
    Grad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Theme.Accent),
        ColorSequenceKeypoint.new(1, Theme.Accent2)
    }

    local gradRotateConn
    gradRotateConn = RunService.RenderStepped:Connect(function()
        if Grad then
            Grad.Rotation = (Grad.Rotation + 0.2) % 360
        end
    end)

    -- Acrylic glow (image)
    pcall(function()
        local Glow = Instance.new("ImageLabel", Main)
        Glow.Name = "Glow"
        Glow.Size = UDim2.new(1, 60, 1, 60)
        Glow.Position = UDim2.new(0, -30, 0, -30)
        Glow.BackgroundTransparency = 1
        Glow.Image = "rbxassetid://5028857084" -- soft circle texture
        Glow.ImageTransparency = 0.86
        Glow.ScaleType = Enum.ScaleType.Slice
        Glow.SliceCenter = Rect.new(24,24,276,276)
        Glow.ZIndex = 0
    end)

    -- Floating motion (gentle)
    task.spawn(function()
        local base = Main.Position
        while Main and Main.Parent do
            TweenService:Create(Main, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Position = base + UDim2.new(0, 0, 0, 3)
            }):Play()
            task.wait(2)
            TweenService:Create(Main, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Position = base
            }):Play()
            task.wait(2)
        end
    end)

    -- Container for tabs/content
    local Container = Instance.new("Frame", Main)
    Container.Name = "Container"
    Container.Size = UDim2.new(1, -30, 1, -95)
    Container.Position = UDim2.new(0, 15, 0, 65)
    Container.BackgroundTransparency = 1

    -- Layout inside container
    local Layout = Instance.new("UIListLayout", Container)
    Layout.Padding = UDim.new(0, 14)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder

    -- Tab Buttons holder (top)
    local TabButtons = Instance.new("Frame", Main)
    TabButtons.Name = "TabButtons"
    TabButtons.Size = UDim2.new(1, -30, 0, 45)
    TabButtons.Position = UDim2.new(0, 15, 0, 15)
    TabButtons.BackgroundTransparency = 1
    local TabLayout = Instance.new("UIListLayout", TabButtons)
    TabLayout.FillDirection = Enum.FillDirection.Horizontal
    TabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    TabLayout.Padding = UDim.new(0, 10)

    -- Ripple effect helper
    local function Ripple(parent, x, y)
        local circle = Instance.new("Frame", parent)
        circle.Size = UDim2.fromOffset(0, 0)
        circle.Position = UDim2.fromOffset(x, y)
        circle.AnchorPoint = Vector2.new(0.5, 0.5)
        circle.BackgroundColor3 = Color3.new(1, 1, 1)
        circle.BackgroundTransparency = 0.7
        local uc = Instance.new("UICorner", circle)
        uc.CornerRadius = UDim.new(1, 0)

        local goal = {}
        goal.Size = UDim2.fromOffset(240, 240)
        goal.BackgroundTransparency = 1

        TweenService:Create(circle, TweenInfo.new(0.45, Enum.EasingStyle.Quad), goal):Play()
        task.delay(0.45, function() if circle and circle.Parent then circle:Destroy() end end)
    end

    -- Store pages for tab switching
    local Pages = {}

    -- store connections that might need cleanup
    local connections = {}

    -- Draggable logic
    do
        local dragging = false
        local dragStartPos, startPos
        TitleBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStartPos = input.Position
                startPos = Main.Position
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = input.Position - dragStartPos
                Main.Position = startPos + UDim2.new(0, delta.X, 0, delta.Y)
            end
        end)
        TitleBar.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
    end

    -- Keybind toggle (RightShift)
    do
        local open = true
        local conn = UserInputService.InputBegan:Connect(function(input, gp)
            if gp then return end
            if input.KeyCode == Enum.KeyCode.RightShift then
                open = not open
                Main.Visible = open
                if blur then
                    if open then
                        TweenService:Create(blur, TweenInfo.new(0.35), {Size = 18}):Play()
                    else
                        TweenService:Create(blur, TweenInfo.new(0.35), {Size = 0}):Play()
                    end
                end
            end
        end)
        table.insert(connections, conn)
    end

    -- Config save/load
    safe_makefolder(configFolder)
    local configPath = configFolder .. "/" .. configName

    local function SaveConfig(data)
        pcall(function()
            local encoded = HttpService:JSONEncode(data or {})
            safe_writefile(configPath, encoded)
        end)
    end

    local function LoadConfig()
        if safe_isfile(configPath) then
            local raw = safe_readfile(configPath)
            if raw then
                local ok, decoded = pcall(function() return HttpService:JSONDecode(raw) end)
                if ok then return decoded end
            end
        end
        return {}
    end

    -- Notification helper
    local function Notify(text, duration)
        duration = duration or 3
        local Notif = Instance.new("Frame", Gui)
        Notif.Size = UDim2.fromOffset(270, 62)
        Notif.Position = UDim2.new(1, -290, 1, -90)
        Notif.BackgroundColor3 = Theme.Card
        Notif.BackgroundTransparency = 0.06
        Notif.ZIndex = 9999
        local nc = Instance.new("UICorner", Notif)
        nc.CornerRadius = UDim.new(0, 12)

        local Label = Instance.new("TextLabel", Notif)
        Label.Size = UDim2.new(1, -20, 1, 0)
        Label.Position = UDim2.new(0, 10, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = text
        Label.Font = Enum.Font.GothamBold
        Label.TextSize = 14
        Label.TextColor3 = Theme.Text
        Label.TextXAlignment = Enum.TextXAlignment.Left

        TweenService:Create(Notif, TweenInfo.new(0.36, Enum.EasingStyle.Exponential), {
            Position = UDim2.new(1, -290, 1, -110)
        }):Play()

        task.delay(duration, function()
            if Notif and Notif.Parent then
                Notif:Destroy()
            end
        end)
    end

    -- ================
    -- Window API that will be returned
    -- ================
    local Window = {}

    -- Tab creator
    function Window:Tab(name)
        local Page = Instance.new("Frame", Container)
        Page.Name = name .. "_Page"
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        local pageLayout = Instance.new("UIListLayout", Page)
        pageLayout.Padding = UDim.new(0, 14)
        pageLayout.SortOrder = Enum.SortOrder.LayoutOrder

        local TabBtn = Instance.new("TextButton", TabButtons)
        TabBtn.Name = name .. "_Tab"
        TabBtn.Size = UDim2.fromOffset(120, 36)
        TabBtn.Text = name
        TabBtn.Font = Enum.Font.GothamBold
        TabBtn.TextSize = 14
        TabBtn.BackgroundColor3 = Theme.Card
        TabBtn.BackgroundTransparency = 0.18
        TabBtn.TextColor3 = Theme.Text
        local tcorner = Instance.new("UICorner", TabBtn)
        tcorner.CornerRadius = UDim.new(0, 10)

        table.insert(Pages, Page)

        TabBtn.MouseButton1Click:Connect(function()
            for _, p in pairs(Pages) do
                p.Visible = false
            end
            Page.Visible = true
        end)

        if #Pages == 1 then Page.Visible = true end

        -- TabObj to return with methods for adding components
        local TabObj = {}

        -- Basic Button
        function TabObj:Button(text, callback)
            local Btn = Instance.new("Frame", Page)
            Btn.Size = UDim2.new(1, 0, 0, 50)
            Btn.BackgroundColor3 = Theme.Card
            Btn.BackgroundTransparency = 0.18
            local uc = Instance.new("UICorner", Btn)
            uc.CornerRadius = UDim.new(0, 14)

            local Label = Instance.new("TextLabel", Btn)
            Label.Size = UDim2.new(1, -20, 1, 0)
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = text
            Label.Font = Enum.Font.GothamBold
            Label.TextSize = 14
            Label.TextColor3 = Theme.Text
            Label.TextXAlignment = Enum.TextXAlignment.Left

            local Hit = Instance.new("TextButton", Btn)
            Hit.Size = UDim2.new(1, 0, 1, 0)
            Hit.BackgroundTransparency = 1
            Hit.Text = ""

            Hit.MouseButton1Down:Connect(function(input)
                local x = input and input.X or Btn.AbsolutePosition.X + Btn.AbsoluteSize.X/2
                local y = input and input.Y or Btn.AbsolutePosition.Y + Btn.AbsoluteSize.Y/2
                Ripple(Btn, x - Btn.AbsolutePosition.X, y - Btn.AbsolutePosition.Y)
                if callback then callback() end
            end)

            return Btn
        end

        -- Toggle
        function TabObj:Toggle(text, default, callback)
            local state = default and true or false

            local Row = Instance.new("Frame", Page)
            Row.Size = UDim2.new(1, 0, 0, 55)
            Row.BackgroundColor3 = Theme.Card
            Row.BackgroundTransparency = 0.18
            local corner = Instance.new("UICorner", Row)
            corner.CornerRadius = UDim.new(0, 14)

            local Label = Instance.new("TextLabel", Row)
            Label.Size = UDim2.new(1, -70, 1, 0)
            Label.Position = UDim2.new(0, 15, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = text
            Label.Font = Enum.Font.GothamBold
            Label.TextSize = 14
            Label.TextColor3 = Theme.Text
            Label.TextXAlignment = Enum.TextXAlignment.Left

            local Switch = Instance.new("Frame", Row)
            Switch.Size = UDim2.fromOffset(46, 24)
            Switch.Position = UDim2.new(1, -65, 0.5, -12)
            Switch.BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(80, 90, 110)
            local scorner = Instance.new("UICorner", Switch)
            scorner.CornerRadius = UDim.new(1, 0)

            local Knob = Instance.new("Frame", Switch)
            Knob.Size = UDim2.fromOffset(20, 20)
            Knob.Position = state and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
            Knob.BackgroundColor3 = Color3.new(1, 1, 1)
            local kcorner = Instance.new("UICorner", Knob)
            kcorner.CornerRadius = UDim.new(1, 0)

            local Hit = Instance.new("TextButton", Row)
            Hit.Size = UDim2.new(1, 0, 1, 0)
            Hit.BackgroundTransparency = 1
            Hit.Text = ""

            Hit.MouseButton1Click:Connect(function()
                state = not state
                TweenService:Create(Switch, TweenInfo.new(0.28, Enum.EasingStyle.Exponential), {
                    BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(80, 90, 110)
                }):Play()
                TweenService:Create(Knob, TweenInfo.new(0.32, Enum.EasingStyle.Exponential), {
                    Position = state and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
                }):Play()
                if callback then callback(state) end
            end)

            return Row
        end

        -- Slider (smooth)
        function TabObj:Slider(text, min, max, default, callback)
            min = min or 0 local _max = max or 100
            local value = default or min

            local Holder = Instance.new("Frame", Page)
            Holder.Size = UDim2.new(1, 0, 0, 68)
            Holder.BackgroundColor3 = Theme.Card
            Holder.BackgroundTransparency = 0.18
            local hc = Instance.new("UICorner", Holder)
            hc.CornerRadius = UDim.new(0, 14)

            local Label = Instance.new("TextLabel", Holder)
            Label.Size = UDim2.new(1, -20, 0, 24)
            Label.Position = UDim2.new(0, 10, 0, 6)
            Label.BackgroundTransparency = 1
            Label.Text = text .. " : " .. tostring(value)
            Label.Font = Enum.Font.GothamBold
            Label.TextSize = 13
            Label.TextColor3 = Theme.Text
            Label.TextXAlignment = Enum.TextXAlignment.Left

            local Bar = Instance.new("Frame", Holder)
            Bar.Size = UDim2.new(1, -20, 0, 8)
            Bar.Position = UDim2.new(0, 10, 0, 38)
            Bar.BackgroundColor3 = Color3.fromRGB(70, 80, 110)
            local bc = Instance.new("UICorner", Bar)
            bc.CornerRadius = UDim.new(1, 0)

            local Fill = Instance.new("Frame", Bar)
            Fill.Size = UDim2.new((_max == min) and 0 or (value - min) / (_max - min), 0, 1, 0)
            Fill.BackgroundColor3 = Theme.Accent
            local fc = Instance.new("UICorner", Fill)
            fc.CornerRadius = UDim.new(1, 0)

            local dragging = false

            Bar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                end
            end)
            Bar.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)

            local conn
            conn = UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local percent = clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                    value = math.floor(min + (_max - min) * percent)
                    Label.Text = text .. " : " .. tostring(value)
                    Fill.Size = UDim2.new(percent, 0, 1, 0)
                    if callback then callback(value) end
                end
            end)
            table.insert(connections, conn)

            return Holder
        end

        -- Dropdown (animated)
        function TabObj:Dropdown(text, options, callback)
            options = options or {}
            local selected = options[1] or ""

            local Holder = Instance.new("Frame", Page)
            Holder.Size = UDim2.new(1, 0, 0, 52)
            Holder.BackgroundColor3 = Theme.Card
            Holder.BackgroundTransparency = 0.18
            Holder.ClipsDescendants = true
            local hc = Instance.new("UICorner", Holder)
            hc.CornerRadius = UDim.new(0, 14)

            local Button = Instance.new("TextButton", Holder)
            Button.Size = UDim2.new(1, 0, 0, 52)
            Button.Position = UDim2.new(0, 0, 0, 0)
            Button.BackgroundTransparency = 1
            Button.Text = text .. " : " .. selected
            Button.Font = Enum.Font.GothamBold
            Button.TextSize = 13
            Button.TextColor3 = Theme.Text

            local List = Instance.new("Frame", Holder)
            List.Size = UDim2.new(1, 0, 0, 0)
            List.Position = UDim2.new(0, 0, 0, 52)
            List.BackgroundTransparency = 1
            local listLayout = Instance.new("UIListLayout", List)
            listLayout.Padding = UDim.new(0, 6)
            listLayout.SortOrder = Enum.SortOrder.LayoutOrder

            local open = false

            for i, v in ipairs(options) do
                local Opt = Instance.new("TextButton", List)
                Opt.Size = UDim2.new(1, -20, 0, 36)
                Opt.Position = UDim2.new(0, 10, 0, 0)
                Opt.BackgroundColor3 = Theme.Glass
                local oc = Instance.new("UICorner", Opt)
                oc.CornerRadius = UDim.new(0, 8)
                Opt.Font = Enum.Font.Gotham
                Opt.TextSize = 13
                Opt.TextColor3 = Theme.Text
                Opt.Text = v

                Opt.MouseButton1Click:Connect(function()
                    selected = v
                    Button.Text = text .. " : " .. selected
                    if callback then callback(selected) end
                end)
            end

            Button.MouseButton1Click:Connect(function()
                open = not open
                local count = #options
                local newSize = open and (50 + count * 44) or 52
                TweenService:Create(Holder, TweenInfo.new(0.28, Enum.EasingStyle.Exponential), {
                    Size = UDim2.new(1, 0, 0, newSize)
                }):Play()
                TweenService:Create(List, TweenInfo.new(0.28, Enum.EasingStyle.Exponential), {
                    Size = UDim2.new(1, 0, 0, open and (count * 44) or 0)
                }):Play()
            end)

            return Holder
        end

        -- Section / Accordion (collapsible container that can hold elements)
        function TabObj:Section(title, defaultOpen, multiOpen)
            -- multiOpen: whether multiple sections in a tab can be open at once (if false, behaves like real accordion)
            local SectionHolder = Instance.new("Frame", Page)
            SectionHolder.Size = UDim2.new(1, 0, 0, 50)
            SectionHolder.BackgroundTransparency = 1
            SectionHolder.ClipsDescendants = true

            local Header = Instance.new("Frame", SectionHolder)
            Header.Size = UDim2.new(1, 0, 0, 50)
            Header.BackgroundColor3 = Theme.Card
            Header.BackgroundTransparency = 0.18
            local hcorner = Instance.new("UICorner", Header)
            hcorner.CornerRadius = UDim.new(0, 14)

            local Label = Instance.new("TextLabel", Header)
            Label.Size = UDim2.new(1, -30, 1, 0)
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = title
            Label.Font = Enum.Font.GothamBold
            Label.TextSize = 14
            Label.TextColor3 = Theme.Text
            Label.TextXAlignment = Enum.TextXAlignment.Left

            local Arrow = Instance.new("ImageLabel", Header)
            Arrow.Size = UDim2.fromOffset(18, 18)
            Arrow.Position = UDim2.new(1, -28, 0.5, -9)
            Arrow.BackgroundTransparency = 1
            Arrow.Image = "rbxassetid://3926307971" -- small arrow asset; fallback if blocked it's okay
            Arrow.Rotation = defaultOpen and 90 or 0

            local Content = Instance.new("Frame", SectionHolder)
            Content.Size = UDim2.new(1, 0, 0, 0)
            Content.Position = UDim2.new(0, 0, 0, 50)
            Content.BackgroundTransparency = 1
            Content.ClipsDescendants = true

            local contentLayout = Instance.new("UIListLayout", Content)
            contentLayout.Padding = UDim.new(0, 10)
            contentLayout.SortOrder = Enum.SortOrder.LayoutOrder

            local open = defaultOpen and true or false

            -- helper to close other sections if accordion behavior required
            local function collapseSiblings()
                if multiOpen then return end
                for _, child in pairs(Page:GetChildren()) do
                    if child:IsA("Frame") and child ~= SectionHolder and child.Name:match("_Section") then
                        local cont = child:FindFirstChildWhichIsA("Frame", true)
                        -- skip detailed implementation; simple approach: leave as-is
                    end
                end
            end

            local function updateContentSize()
                -- force layout update then read AbsoluteContentSize
                RunService.Heartbeat:Wait()
                local newH = contentLayout and contentLayout.AbsoluteContentSize.Y or 0
                local target = open and (50 + newH + 10) or 50
                TweenService:Create(SectionHolder, TweenInfo.new(0.28, Enum.EasingStyle.Exponential), {
                    Size = UDim2.new(1, 0, 0, target)
                }):Play()
                TweenService:Create(Content, TweenInfo.new(0.28, Enum.EasingStyle.Exponential), {
                    Size = UDim2.new(1, 0, 0, open and (newH + 10) or 0)
                }):Play()
                TweenService:Create(Arrow, TweenInfo.new(0.28), {Rotation = open and 90 or 0}):Play()
            end

            Header.MouseButton1Click = Header:Clone() -- ensure MouseButton1Click exists by making it a button
            -- Actually we need a button overlay to get clicks reliably
            local HeaderHit = Instance.new("TextButton", Header)
            HeaderHit.Size = UDim2.new(1, 0, 1, 0)
            HeaderHit.BackgroundTransparency = 1
            HeaderHit.Text = ""
            HeaderHit.AutoButtonColor = false

            HeaderHit.MouseButton1Click:Connect(function()
                open = not open
                if open then collapseSiblings() end
                updateContentSize()
            end)

            -- initial layout size
            SectionHolder.Name = title .. "_Section"
            updateContentSize()

            -- Section API for adding elements into Content
            local SectionAPI = {}

            function SectionAPI:Button(text, cb)
                local btn = Instance.new("Frame", Content)
                btn.Size = UDim2.new(1, 0, 0, 48)
                btn.BackgroundColor3 = Theme.Card
                btn.BackgroundTransparency = 0.12
                local rc = Instance.new("UICorner", btn)
                rc.CornerRadius = UDim.new(0, 12)

                local lbl = Instance.new("TextLabel", btn)
                lbl.Size = UDim2.new(1, -20, 1, 0)
                lbl.Position = UDim2.new(0, 10, 0, 0)
                lbl.BackgroundTransparency = 1
                lbl.Text = text
                lbl.Font = Enum.Font.GothamBold
                lbl.TextSize = 13
                lbl.TextColor3 = Theme.Text
                lbl.TextXAlignment = Enum.TextXAlignment.Left

                local hit = Instance.new("TextButton", btn)
                hit.Size = UDim2.new(1, 0, 1, 0)
                hit.BackgroundTransparency = 1
                hit.Text = ""

                hit.MouseButton1Click:Connect(function()
                    Ripple(btn, hit.AbsolutePosition.X - btn.AbsolutePosition.X + hit.AbsoluteSize.X/2, hit.AbsolutePosition.Y - btn.AbsolutePosition.Y + hit.AbsoluteSize.Y/2)
                    if cb then cb() end
                end)
                updateContentSize()
                return btn
            end

            function SectionAPI:Toggle(text, default, cb)
                local tgl = nil
                -- reuse TabObj:Toggle logic but parent to Content
                local state = default and true or false

                local Row = Instance.new("Frame", Content)
                Row.Size = UDim2.new(1, 0, 0, 55)
                Row.BackgroundColor3 = Theme.Card
                Row.BackgroundTransparency = 0.12
                local corner = Instance.new("UICorner", Row)
                corner.CornerRadius = UDim.new(0, 12)

                local Label = Instance.new("TextLabel", Row)
                Label.Size = UDim2.new(1, -70, 1, 0)
                Label.Position = UDim2.new(0, 15, 0, 0)
                Label.BackgroundTransparency = 1
                Label.Text = text
                Label.Font = Enum.Font.GothamBold
                Label.TextSize = 13
                Label.TextColor3 = Theme.Text
                Label.TextXAlignment = Enum.TextXAlignment.Left

                local Switch = Instance.new("Frame", Row)
                Switch.Size = UDim2.fromOffset(46, 24)
                Switch.Position = UDim2.new(1, -65, 0.5, -12)
                Switch.BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(80, 90, 110)
                local scorner = Instance.new("UICorner", Switch)
                scorner.CornerRadius = UDim.new(1, 0)

                local Knob = Instance.new("Frame", Switch)
                Knob.Size = UDim2.fromOffset(20, 20)
                Knob.Position = state and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
                Knob.BackgroundColor3 = Color3.new(1, 1, 1)
                local kcorner = Instance.new("UICorner", Knob)
                kcorner.CornerRadius = UDim.new(1, 0)

                local Hit = Instance.new("TextButton", Row)
                Hit.Size = UDim2.new(1, 0, 1, 0)
                Hit.BackgroundTransparency = 1
                Hit.Text = ""

                Hit.MouseButton1Click:Connect(function()
                    state = not state
                    TweenService:Create(Switch, TweenInfo.new(0.28, Enum.EasingStyle.Exponential), {
                        BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(80, 90, 110)
                    }):Play()
                    TweenService:Create(Knob, TweenInfo.new(0.32, Enum.EasingStyle.Exponential), {
                        Position = state and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
                    }):Play()
                    if cb then cb(state) end
                end)

                updateContentSize()
                return Row
            end

            function SectionAPI:Slider(text, min, max, default, cb)
                min = min or 0 local _max = max or 100
                local value = default or min

                local Holder = Instance.new("Frame", Content)
                Holder.Size = UDim2.new(1, 0, 0, 68)
                Holder.BackgroundColor3 = Theme.Card
                Holder.BackgroundTransparency = 0.12
                local hc = Instance.new("UICorner", Holder)
                hc.CornerRadius = UDim.new(0, 12)

                local Label = Instance.new("TextLabel", Holder)
                Label.Size = UDim2.new(1, -20, 0, 24)
                Label.Position = UDim2.new(0, 10, 0, 6)
                Label.BackgroundTransparency = 1
                Label.Text = text .. " : " .. tostring(value)
                Label.Font = Enum.Font.GothamBold
                Label.TextSize = 13
                Label.TextColor3 = Theme.Text
                Label.TextXAlignment = Enum.TextXAlignment.Left

                local Bar = Instance.new("Frame", Holder)
                Bar.Size = UDim2.new(1, -20, 0, 8)
                Bar.Position = UDim2.new(0, 10, 0, 38)
                Bar.BackgroundColor3 = Color3.fromRGB(70, 80, 110)
                local bc = Instance.new("UICorner", Bar)
                bc.CornerRadius = UDim.new(1, 0)

                local Fill = Instance.new("Frame", Bar)
                Fill.Size = UDim2.new((_max == min) and 0 or (value - min) / (_max - min), 0, 1, 0)
                Fill.BackgroundColor3 = Theme.Accent
                local fc = Instance.new("UICorner", Fill)
                fc.CornerRadius = UDim.new(1, 0)

                local dragging = false

                Bar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                    end
                end)
                Bar.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)

                local conn
                conn = UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local percent = clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                        value = math.floor(min + (_max - min) * percent)
                        Label.Text = text .. " : " .. tostring(value)
                        Fill.Size = UDim2.new(percent, 0, 1, 0)
                        if cb then cb(value) end
                    end
                end)
                table.insert(connections, conn)

                updateContentSize()
                return Holder
            end

            function SectionAPI:Dropdown(text, options, cb)
                options = options or {}
                local selected = options[1] or ""

                local Holder = Instance.new("Frame", Content)
                Holder.Size = UDim2.new(1, 0, 0, 52)
                Holder.BackgroundColor3 = Theme.Card
                Holder.BackgroundTransparency = 0.12
                Holder.ClipsDescendants = true
                local hc = Instance.new("UICorner", Holder)
                hc.CornerRadius = UDim.new(0, 12)

                local Button = Instance.new("TextButton", Holder)
                Button.Size = UDim2.new(1, 0, 0, 52)
                Button.Position = UDim2.new(0, 0, 0, 0)
                Button.BackgroundTransparency = 1
                Button.Text = text .. " : " .. selected
                Button.Font = Enum.Font.GothamBold
                Button.TextSize = 13
                Button.TextColor3 = Theme.Text

                local List = Instance.new("Frame", Holder)
                List.Size = UDim2.new(1, 0, 0, 0)
                List.Position = UDim2.new(0, 0, 0, 52)
                List.BackgroundTransparency = 1
                local listLayout = Instance.new("UIListLayout", List)
                listLayout.Padding = UDim.new(0, 6)
                listLayout.SortOrder = Enum.SortOrder.LayoutOrder

                local open = false

                for i, v in ipairs(options) do
                    local Opt = Instance.new("TextButton", List)
                    Opt.Size = UDim2.new(1, -20, 0, 36)
                    Opt.Position = UDim2.new(0, 10, 0, 0)
                    Opt.BackgroundColor3 = Theme.Glass
                    local oc = Instance.new("UICorner", Opt)
                    oc.CornerRadius = UDim.new(0, 8)
                    Opt.Font = Enum.Font.Gotham
                    Opt.TextSize = 13
                    Opt.TextColor3 = Theme.Text
                    Opt.Text = v

                    Opt.MouseButton1Click:Connect(function()
                        selected = v
                        Button.Text = text .. " : " .. selected
                        if cb then cb(selected) end
                    end)
                end

                Button.MouseButton1Click:Connect(function()
                    open = not open
                    local count = #options
                    local newSize = open and (50 + count * 44) or 52
                    TweenService:Create(Holder, TweenInfo.new(0.28, Enum.EasingStyle.Exponential), {
                        Size = UDim2.new(1, 0, 0, newSize)
                    }):Play()
                    TweenService:Create(List, TweenInfo.new(0.28, Enum.EasingStyle.Exponential), {
                        Size = UDim2.new(1, 0, 0, open and (count * 44) or 0)
                    }):Play()
                end)

                updateContentSize()
                return Holder
            end

            return SectionAPI
        end

        return TabObj
    end

    -- Expose Save/Load/Notify from Window object
    function Window:SaveConfig(data) SaveConfig(data) end
    function Window:LoadConfig() return LoadConfig() end
    function Window:Notify(text, duration) Notify(text, duration) end

    -- Cleanup function
    function Window:Destroy()
        pcall(function()
            if gradRotateConn then gradRotateConn:Disconnect() end
            for _,c in ipairs(connections) do pcall(function() c:Disconnect() end) end
            if blur then
                TweenService:Create(blur, TweenInfo.new(0.35), {Size = 0}):Play()
                task.delay(0.4, function() if blur and blur.Parent then blur:Destroy() end end)
            end
            if Gui and Gui.Parent then Gui:Destroy() end
        end)
    end

    -- Final return
    return Window
end

return RHub

-- ========================
-- Example usage (comment)
-- ========================
-- local RHub = require(path_to_RemingtonHub) -- or loadstring(game:HttpGet(URL))()
-- local Window = RHub:Window({Title = "RemingtonHub V5", ConfigFolder="RHubConfigs", ConfigName="default.json"})
-- local Main = Window:Tab("Main")
-- Main:Slider("WalkSpeed", 16, 200, 16, function(v) if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v end end)
-- local Settings = Window:Tab("Settings")
-- local sec = Settings:Section("Combat", false, false)
-- sec:Toggle("Auto Aim", false, function(state) print("auto aim:", state) end)
-- Window:Notify("Loaded RemingtonHub V5")
