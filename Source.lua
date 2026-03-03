--// RaihjnDev Ocean Premium UI

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local RHub = {}
RHub.__index = RHub

--// CONFIG
local WINDOW_SIZE = Vector2.new(780,480)
local SIDEBAR_WIDTH = 190
local RADIUS = 14

local COLORS = {
    Background = Color3.fromRGB(15,18,24),
    Glass = Color3.fromRGB(25,30,40),
    Accent1 = Color3.fromRGB(64,182,255),
    Accent2 = Color3.fromRGB(0,140,220),
    Text = Color3.fromRGB(235,240,255),
    SubText = Color3.fromRGB(170,185,210)
}

--// Utility
local function Tween(obj,props,time)
    TweenService:Create(obj,TweenInfo.new(time,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),props):Play()
end

local function Corner(obj,r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0,r)
    c.Parent = obj
end

local function Stroke(obj,thickness,color,transparency)
    local s = Instance.new("UIStroke")
    s.Thickness = thickness
    s.Color = color
    s.Transparency = transparency
    s.Parent = obj
end

--// Create Window
function RHub:CreateWindow(cfg)
    local player = Players.LocalPlayer
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "RaihjnDevOcean"
    gui.ResetOnSpawn = false
    gui.Parent = player:WaitForChild("PlayerGui")
    
    -- MAIN
    local Main = Instance.new("Frame",gui)
    Main.Size = UDim2.fromOffset(WINDOW_SIZE.X,WINDOW_SIZE.Y)
    Main.Position = UDim2.new(0.5,-WINDOW_SIZE.X/2,0.5,-WINDOW_SIZE.Y/2)
    Main.BackgroundColor3 = COLORS.Background
    Main.BackgroundTransparency = 0.05
    Corner(Main,RADIUS)
    Stroke(Main,1,COLORS.Accent1,0.6)
    
    -- Glow layer
    local Glow = Instance.new("Frame",Main)
    Glow.Size = UDim2.new(1,20,1,20)
    Glow.Position = UDim2.new(0,-10,0,-10)
    Glow.BackgroundColor3 = COLORS.Accent1
    Glow.BackgroundTransparency = 0.85
    Glow.ZIndex = 0
    Corner(Glow,RADIUS+4)
    
    -- Gradient overlay
    local Gradient = Instance.new("UIGradient",Main)
    Gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0,COLORS.Glass),
        ColorSequenceKeypoint.new(1,COLORS.Background)
    }
    
    -- Drag system
    local dragging, dragInput, dragStart, startPos
    
    Main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    -- Sidebar
    local Sidebar = Instance.new("Frame",Main)
    Sidebar.Size = UDim2.new(0,SIDEBAR_WIDTH,1,0)
    Sidebar.BackgroundColor3 = COLORS.Glass
    Sidebar.BackgroundTransparency = 0.1
    Corner(Sidebar,RADIUS)
    
    local SBGradient = Instance.new("UIGradient",Sidebar)
    SBGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0,Color3.fromRGB(25,30,40)),
        ColorSequenceKeypoint.new(1,Color3.fromRGB(18,22,30))
    }
    
    local TabList = Instance.new("UIListLayout",Sidebar)
    TabList.Padding = UDim.new(0,10)
    TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabList.VerticalAlignment = Enum.VerticalAlignment.Top
    
    -- Content
    local Content = Instance.new("Frame",Main)
    Content.Position = UDim2.new(0,SIDEBAR_WIDTH+15,0,15)
    Content.Size = UDim2.new(1,-(SIDEBAR_WIDTH+30),1,-30)
    Content.BackgroundTransparency = 1
    
    -- Window API
    local Window = {}
    local CurrentPage
    
    function Window:CreateTab(name,icon)
        local TabButton = Instance.new("TextButton",Sidebar)
        TabButton.Size = UDim2.new(0,SIDEBAR_WIDTH-20,0,45)
        TabButton.Text = name
        TabButton.TextColor3 = COLORS.Text
        TabButton.Font = Enum.Font.GothamSemibold
        TabButton.TextSize = 14
        TabButton.BackgroundColor3 = Color3.fromRGB(30,36,46)
        TabButton.BackgroundTransparency = 0.3
        Corner(TabButton,12)
        
        local Icon = Instance.new("ImageLabel",TabButton)
        Icon.Size = UDim2.fromOffset(18,18)
        Icon.Position = UDim2.new(0,12,0.5,-9)
        Icon.BackgroundTransparency = 1
        Icon.Image = icon or ""
        
        TabButton.TextXAlignment = Enum.TextXAlignment.Center
        
        local Page = Instance.new("ScrollingFrame",Content)
        Page.Size = UDim2.new(1,0,1,0)
        Page.CanvasSize = UDim2.new(0,0,0,0)
        Page.ScrollBarImageTransparency = 0.7
        Page.Visible = false
        Page.BackgroundTransparency = 1
        
        local Layout = Instance.new("UIListLayout",Page)
        Layout.Padding = UDim.new(0,12)
        
        Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0,0,0,Layout.AbsoluteContentSize.Y+10)
        end)
        
        TabButton.MouseButton1Click:Connect(function()
            if CurrentPage then
                Tween(CurrentPage,{BackgroundTransparency=1},0.2)
                CurrentPage.Visible = false
            end
            
            Page.Visible = true
            Page.BackgroundTransparency = 1
            Tween(Page,{BackgroundTransparency=0},0.3)
            
            CurrentPage = Page
        end)
        
        local Tab = {}
        
        function Tab:CreateButton(text,callback)
            local Btn = Instance.new("TextButton",Page)
            Btn.Size = UDim2.new(1,-10,0,45)
            Btn.Text = text
            Btn.Font = Enum.Font.Gotham
            Btn.TextSize = 14
            Btn.TextColor3 = COLORS.Text
            Btn.BackgroundColor3 = Color3.fromRGB(30,36,46)
            Corner(Btn,12)
            Stroke(Btn,1,COLORS.Accent1,0.7)
            
            Btn.MouseEnter:Connect(function()
                Tween(Btn,{BackgroundColor3=Color3.fromRGB(40,50,65)},0.2)
            end)
            Btn.MouseLeave:Connect(function()
                Tween(Btn,{BackgroundColor3=Color3.fromRGB(30,36,46)},0.2)
            end)
            
            Btn.MouseButton1Click:Connect(function()
                if callback then callback() end
            end)
        end
        
        function Tab:CreateToggle(text,callback)
            local Holder = Instance.new("Frame",Page)
            Holder.Size = UDim2.new(1,-10,0,45)
            Holder.BackgroundColor3 = Color3.fromRGB(30,36,46)
            Corner(Holder,12)
            Stroke(Holder,1,COLORS.Accent1,0.7)
            
            local Label = Instance.new("TextLabel",Holder)
            Label.Size = UDim2.new(0.7,0,1,0)
            Label.BackgroundTransparency = 1
            Label.Text = text
            Label.TextColor3 = COLORS.Text
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 14
            
            local ToggleBtn = Instance.new("Frame",Holder)
            ToggleBtn.Size = UDim2.fromOffset(50,24)
            ToggleBtn.Position = UDim2.new(1,-70,0.5,-12)
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(20,25,35)
            Corner(ToggleBtn,12)
            
            local Circle = Instance.new("Frame",ToggleBtn)
            Circle.Size = UDim2.fromOffset(20,20)
            Circle.Position = UDim2.new(0,2,0.5,-10)
            Circle.BackgroundColor3 = COLORS.SubText
            Corner(Circle,10)
            
            local State = false
            
            Holder.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    State = not State
                    if State then
                        Tween(Circle,{Position=UDim2.new(1,-22,0.5,-10),BackgroundColor3=COLORS.Accent1},0.25)
                    else
                        Tween(Circle,{Position=UDim2.new(0,2,0.5,-10),BackgroundColor3=COLORS.SubText},0.25)
                    end
                    if callback then callback(State) end
                end
            end)
        end
        
        return Tab
    end
    
    return Window
end

return RHub
