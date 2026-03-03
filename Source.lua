--// RaihjnDev UI Library

local RHub = {}
RHub.__index = RHub

-- Create Window
function RHub:CreateWindow(config)
    local player = game.Players.LocalPlayer
    local gui = Instance.new("ScreenGui")
    gui.Name = "RaihjnDevUI"
    gui.Parent = player:WaitForChild("PlayerGui")

    local main = Instance.new("Frame", gui)
    main.Size = UDim2.new(0, 500, 0, 400)
    main.Position = UDim2.new(0.5, -250, 0.5, -200)
    main.BackgroundColor3 = Color3.fromRGB(30,30,30)
    main.BorderSizePixel = 0

    local corner = Instance.new("UICorner", main)
    corner.CornerRadius = UDim.new(0,12)

    local title = Instance.new("TextLabel", main)
    title.Size = UDim2.new(1,0,0,40)
    title.BackgroundTransparency = 1
    title.Text = config.Title or "RaihjnDev"
    title.TextColor3 = Color3.new(1,1,1)
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold

    local tabHolder = Instance.new("Frame", main)
    tabHolder.Size = UDim2.new(0,120,1,-40)
    tabHolder.Position = UDim2.new(0,0,0,40)
    tabHolder.BackgroundColor3 = Color3.fromRGB(25,25,25)

    local pageHolder = Instance.new("Frame", main)
    pageHolder.Size = UDim2.new(1,-120,1,-40)
    pageHolder.Position = UDim2.new(0,120,0,40)
    pageHolder.BackgroundTransparency = 1

    local layoutTabs = Instance.new("UIListLayout", tabHolder)
    layoutTabs.Padding = UDim.new(0,5)

    local window = {}
    window.Tabs = {}

    function window:CreateTab(tabName)
        local tabButton = Instance.new("TextButton", tabHolder)
        tabButton.Size = UDim2.new(1,0,0,40)
        tabButton.Text = tabName
        tabButton.BackgroundColor3 = Color3.fromRGB(40,40,40)
        tabButton.TextColor3 = Color3.new(1,1,1)
        tabButton.Font = Enum.Font.Gotham
        tabButton.TextSize = 14

        local page = Instance.new("ScrollingFrame", pageHolder)
        page.Size = UDim2.new(1,0,1,0)
        page.CanvasSize = UDim2.new(0,0,0,0)
        page.ScrollBarImageTransparency = 0.5
        page.Visible = false
        page.BackgroundTransparency = 1

        local layout = Instance.new("UIListLayout", page)
        layout.Padding = UDim.new(0,8)

        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            page.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y+10)
        end)

        tabButton.MouseButton1Click:Connect(function()
            for _,v in pairs(pageHolder:GetChildren()) do
                if v:IsA("ScrollingFrame") then
                    v.Visible = false
                end
            end
            page.Visible = true
        end)

        local tab = {}

        function tab:CreateButton(text, callback)
            local btn = Instance.new("TextButton", page)
            btn.Size = UDim2.new(1,-10,0,40)
            btn.Text = text
            btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
            btn.TextColor3 = Color3.new(1,1,1)
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 14

            btn.MouseButton1Click:Connect(function()
                if callback then callback() end
            end)
        end

        function tab:CreateToggle(text, callback)
            local toggle = Instance.new("TextButton", page)
            toggle.Size = UDim2.new(1,-10,0,40)
            toggle.Text = text.." : OFF"
            toggle.BackgroundColor3 = Color3.fromRGB(50,50,50)
            toggle.TextColor3 = Color3.new(1,1,1)
            toggle.Font = Enum.Font.Gotham
            toggle.TextSize = 14

            local state = false

            toggle.MouseButton1Click:Connect(function()
                state = not state
                toggle.Text = text.." : "..(state and "ON" or "OFF")
                if callback then callback(state) end
            end)
        end

        function tab:CreateSlider(text, min, max, callback)
            local slider = Instance.new("TextLabel", page)
            slider.Size = UDim2.new(1,-10,0,50)
            slider.BackgroundColor3 = Color3.fromRGB(50,50,50)
            slider.Text = text..": "..min
            slider.TextColor3 = Color3.new(1,1,1)
            slider.Font = Enum.Font.Gotham
            slider.TextSize = 14

            local value = min

            slider.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    value = math.random(min,max)
                    slider.Text = text..": "..value
                    if callback then callback(value) end
                end
            end)
        end

        function tab:CreateDropdown(text, options, callback)
            local drop = Instance.new("TextButton", page)
            drop.Size = UDim2.new(1,-10,0,40)
            drop.Text = text
            drop.BackgroundColor3 = Color3.fromRGB(50,50,50)
            drop.TextColor3 = Color3.new(1,1,1)
            drop.Font = Enum.Font.Gotham
            drop.TextSize = 14

            drop.MouseButton1Click:Connect(function()
                local choice = options[math.random(1,#options)]
                drop.Text = text..": "..choice
                if callback then callback(choice) end
            end)
        end

        table.insert(window.Tabs, tab)
        return tab
    end

    return window
end

return RHub
