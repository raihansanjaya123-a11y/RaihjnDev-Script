local RHub = {}
RHub.__index = RHub

-- SERVICES
local UIS = game:GetService("UserInputService")

-- CREATE WINDOW
function RHub:CreateWindow(config)
    local Window = {}
    Window.Tabs = {}

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "RHubUI"
    ScreenGui.Parent = game.CoreGui

    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 500, 0, 350)
    Main.Position = UDim2.new(0.5, -250, 0.5, -175)
    Main.BackgroundColor3 = Color3.fromRGB(25,25,25)
    Main.Parent = ScreenGui
    Main.Active = true
    Main.Draggable = true

    -- TITLE
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1,0,0,40)
    Title.BackgroundTransparency = 1
    Title.Text = config.Title or "RHub"
    Title.TextColor3 = Color3.new(1,1,1)
    Title.Parent = Main

    -- TAB HOLDER
    local TabHolder = Instance.new("Frame")
    TabHolder.Size = UDim2.new(1,0,0,30)
    TabHolder.Position = UDim2.new(0,0,0,40)
    TabHolder.BackgroundTransparency = 1
    TabHolder.Parent = Main

    -- CONTENT
    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1,0,1,-70)
    Content.Position = UDim2.new(0,0,0,70)
    Content.BackgroundTransparency = 1
    Content.Parent = Main

    -- TOGGLE UI
    local toggleKey = config.ToggleUIKeybind or "RightControl"

    UIS.InputBegan:Connect(function(input)
        if input.KeyCode.Name == toggleKey then
            Main.Visible = not Main.Visible
        end
    end)

    function Window:CreateTab(name)
        local Tab = {}
        Tab.Elements = {}

        local TabButton = Instance.new("TextButton")
        TabButton.Size = UDim2.new(0,100,1,0)
        TabButton.Text = name
        TabButton.Parent = TabHolder
        TabButton.BackgroundColor3 = Color3.fromRGB(40,40,40)
        TabButton.TextColor3 = Color3.new(1,1,1)

        local TabFrame = Instance.new("Frame")
        TabFrame.Size = UDim2.new(1,0,1,0)
        TabFrame.BackgroundTransparency = 1
        TabFrame.Visible = false
        TabFrame.Parent = Content

        local Layout = Instance.new("UIListLayout")
        Layout.Padding = UDim.new(0,5)
        Layout.Parent = TabFrame

        TabButton.MouseButton1Click:Connect(function()
            for _,v in pairs(Content:GetChildren()) do
                if v:IsA("Frame") then
                    v.Visible = false
                end
            end
            TabFrame.Visible = true
        end)

        function Tab:CreateButton(text, callback)
            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1,-10,0,30)
            Btn.Text = text
            Btn.Parent = TabFrame
            Btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
            Btn.TextColor3 = Color3.new(1,1,1)

            Btn.MouseButton1Click:Connect(function()
                callback()
            end)
        end

        function Tab:CreateToggle(text, default, callback)
            local State = default

            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1,-10,0,30)
            Btn.Text = text .. " : " .. tostring(State)
            Btn.Parent = TabFrame
            Btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
            Btn.TextColor3 = Color3.new(1,1,1)

            Btn.MouseButton1Click:Connect(function()
                State = not State
                Btn.Text = text .. " : " .. tostring(State)
                callback(State)
            end)
        end

        function Tab:CreateSlider(text,min,max,default,callback)
            local Value = default

            local Slider = Instance.new("TextButton")
            Slider.Size = UDim2.new(1,-10,0,30)
            Slider.Text = text.." : "..Value
            Slider.Parent = TabFrame
            Slider.BackgroundColor3 = Color3.fromRGB(50,50,50)
            Slider.TextColor3 = Color3.new(1,1,1)

            Slider.MouseButton1Click:Connect(function()
                Value = math.clamp(Value+1,min,max)
                Slider.Text = text.." : "..Value
                callback(Value)
            end)
        end

        function Tab:CreateDropdown(text,options,callback)
            local DropFrame = Instance.new("Frame")
            DropFrame.Size = UDim2.new(1,-10,0,30)
            DropFrame.BackgroundColor3 = Color3.fromRGB(50,50,50)
            DropFrame.Parent = TabFrame

            local Label = Instance.new("TextButton")
            Label.Size = UDim2.new(1,0,1,0)
            Label.Text = text
            Label.Parent = DropFrame
            Label.BackgroundTransparency = 1
            Label.TextColor3 = Color3.new(1,1,1)

            local Open = false

            Label.MouseButton1Click:Connect(function()
                Open = not Open
                DropFrame.Size = UDim2.new(1,-10,0,Open and (#options*30+30) or 30)
            end)

            for _,v in pairs(options) do
                local Opt = Instance.new("TextButton")
                Opt.Size = UDim2.new(1,0,0,30)
                Opt.Position = UDim2.new(0,0,0,30)
                Opt.Text = v
                Opt.Parent = DropFrame
                Opt.Visible = false
                Opt.BackgroundColor3 = Color3.fromRGB(60,60,60)
                Opt.TextColor3 = Color3.new(1,1,1)

                Label.MouseButton1Click:Connect(function()
                    Opt.Visible = Open
                end)

                Opt.MouseButton1Click:Connect(function()
                    Label.Text = text.." : "..v
                    callback(v)
                end)
            end
        end

        table.insert(Window.Tabs, Tab)
        return Tab
    end

    return Window
end

return RHub
