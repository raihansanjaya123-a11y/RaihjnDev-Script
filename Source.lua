--[[

    RaihjnDev Interface Suite
    API kompatibel dengan Rayfield
    by RaihjnDev (dikembangkan dari awal)

]]

local RaihjnDev = {}
RaihjnDev.Flags = {}
RaihjnDev.Windows = {}
RaihjnDev.Themes = {
    Default = {
        TextColor = Color3.fromRGB(240, 240, 240),
        Background = Color3.fromRGB(25, 25, 25),
        Topbar = Color3.fromRGB(34, 34, 34),
        Shadow = Color3.fromRGB(20, 20, 20),
        NotificationBackground = Color3.fromRGB(20, 20, 20),
        NotificationActionsBackground = Color3.fromRGB(230, 230, 230),
        TabBackground = Color3.fromRGB(80, 80, 80),
        TabStroke = Color3.fromRGB(85, 85, 85),
        TabBackgroundSelected = Color3.fromRGB(210, 210, 210),
        TabTextColor = Color3.fromRGB(240, 240, 240),
        SelectedTabTextColor = Color3.fromRGB(50, 50, 50),
        ElementBackground = Color3.fromRGB(35, 35, 35),
        ElementBackgroundHover = Color3.fromRGB(40, 40, 40),
        SecondaryElementBackground = Color3.fromRGB(25, 25, 25),
        ElementStroke = Color3.fromRGB(50, 50, 50),
        SecondaryElementStroke = Color3.fromRGB(40, 40, 40),
        SliderBackground = Color3.fromRGB(50, 138, 220),
        SliderProgress = Color3.fromRGB(50, 138, 220),
        SliderStroke = Color3.fromRGB(58, 163, 255),
        ToggleBackground = Color3.fromRGB(30, 30, 30),
        ToggleEnabled = Color3.fromRGB(0, 146, 214),
        ToggleDisabled = Color3.fromRGB(100, 100, 100),
        ToggleEnabledStroke = Color3.fromRGB(0, 170, 255),
        ToggleDisabledStroke = Color3.fromRGB(125, 125, 125),
        ToggleEnabledOuterStroke = Color3.fromRGB(100, 100, 100),
        ToggleDisabledOuterStroke = Color3.fromRGB(65, 65, 65),
        DropdownSelected = Color3.fromRGB(40, 40, 40),
        DropdownUnselected = Color3.fromRGB(30, 30, 30),
        InputBackground = Color3.fromRGB(30, 30, 30),
        InputStroke = Color3.fromRGB(65, 65, 65),
        PlaceholderColor = Color3.fromRGB(178, 178, 178)
    },
    Ocean = {
        TextColor = Color3.fromRGB(230, 240, 240),
        Background = Color3.fromRGB(20, 30, 30),
        Topbar = Color3.fromRGB(25, 40, 40),
        Shadow = Color3.fromRGB(15, 20, 20),
        NotificationBackground = Color3.fromRGB(25, 35, 35),
        NotificationActionsBackground = Color3.fromRGB(230, 240, 240),
        TabBackground = Color3.fromRGB(40, 60, 60),
        TabStroke = Color3.fromRGB(50, 70, 70),
        TabBackgroundSelected = Color3.fromRGB(100, 180, 180),
        TabTextColor = Color3.fromRGB(210, 230, 230),
        SelectedTabTextColor = Color3.fromRGB(20, 50, 50),
        ElementBackground = Color3.fromRGB(30, 50, 50),
        ElementBackgroundHover = Color3.fromRGB(40, 60, 60),
        SecondaryElementBackground = Color3.fromRGB(30, 45, 45),
        ElementStroke = Color3.fromRGB(45, 70, 70),
        SecondaryElementStroke = Color3.fromRGB(40, 65, 65),
        SliderBackground = Color3.fromRGB(0, 110, 110),
        SliderProgress = Color3.fromRGB(0, 140, 140),
        SliderStroke = Color3.fromRGB(0, 160, 160),
        ToggleBackground = Color3.fromRGB(30, 50, 50),
        ToggleEnabled = Color3.fromRGB(0, 130, 130),
        ToggleDisabled = Color3.fromRGB(70, 90, 90),
        ToggleEnabledStroke = Color3.fromRGB(0, 160, 160),
        ToggleDisabledStroke = Color3.fromRGB(85, 105, 105),
        ToggleEnabledOuterStroke = Color3.fromRGB(50, 100, 100),
        ToggleDisabledOuterStroke = Color3.fromRGB(45, 65, 65),
        DropdownSelected = Color3.fromRGB(40, 70, 70),
        DropdownUnselected = Color3.fromRGB(30, 55, 55),
        InputBackground = Color3.fromRGB(30, 55, 55),
        InputStroke = Color3.fromRGB(45, 80, 80),
        PlaceholderColor = Color3.fromRGB(150, 170, 170)
    },
    AmberGlow = {
        TextColor = Color3.fromRGB(250, 240, 230),
        Background = Color3.fromRGB(30, 20, 15),
        Topbar = Color3.fromRGB(45, 30, 20),
        Shadow = Color3.fromRGB(20, 15, 10),
        NotificationBackground = Color3.fromRGB(40, 30, 25),
        NotificationActionsBackground = Color3.fromRGB(240, 220, 200),
        TabBackground = Color3.fromRGB(80, 60, 40),
        TabStroke = Color3.fromRGB(100, 70, 50),
        TabBackgroundSelected = Color3.fromRGB(220, 160, 100),
        TabTextColor = Color3.fromRGB(250, 240, 220),
        SelectedTabTextColor = Color3.fromRGB(40, 25, 15),
        ElementBackground = Color3.fromRGB(50, 35, 25),
        ElementBackgroundHover = Color3.fromRGB(65, 45, 30),
        SecondaryElementBackground = Color3.fromRGB(40, 28, 20),
        ElementStroke = Color3.fromRGB(80, 55, 40),
        SecondaryElementStroke = Color3.fromRGB(70, 48, 35),
        SliderBackground = Color3.fromRGB(200, 120, 40),
        SliderProgress = Color3.fromRGB(220, 140, 50),
        SliderStroke = Color3.fromRGB(240, 160, 60),
        ToggleBackground = Color3.fromRGB(50, 35, 25),
        ToggleEnabled = Color3.fromRGB(200, 120, 40),
        ToggleDisabled = Color3.fromRGB(100, 70, 50),
        ToggleEnabledStroke = Color3.fromRGB(240, 140, 40),
        ToggleDisabledStroke = Color3.fromRGB(120, 85, 60),
        ToggleEnabledOuterStroke = Color3.fromRGB(150, 90, 30),
        ToggleDisabledOuterStroke = Color3.fromRGB(80, 60, 45),
        DropdownSelected = Color3.fromRGB(70, 45, 30),
        DropdownUnselected = Color3.fromRGB(50, 35, 25),
        InputBackground = Color3.fromRGB(40, 28, 20),
        InputStroke = Color3.fromRGB(80, 55, 40),
        PlaceholderColor = Color3.fromRGB(180, 150, 120)
    }
}

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Environment check
local isStudio = RunService:IsStudio()
local fileFunctions = (writefile and readfile and isfolder and makefolder and delfile and listfiles)

-- Configuration paths
local configFolder = "RaihjnDev"
local configExtension = ".rfld"  -- Mirip Rayfield

-- Helper functions
local function safeCall(func, ...)
    if func then
        local success, result = pcall(func, ...)
        if not success then
            warn("RaihjnDev | Error:", result)
            return nil
        end
        return result
    end
end

local function ensureFolder(path)
    if fileFunctions and not safeCall(isfolder, path) then
        safeCall(makefolder, path)
    end
end

local function loadConfig(fileName)
    if not fileFunctions then return {} end
    local path = configFolder .. "/" .. fileName .. configExtension
    if safeCall(isfile, path) then
        local content = safeCall(readfile, path)
        if content then
            local success, data = pcall(HttpService.JSONDecode, HttpService, content)
            if success then return data end
        end
    end
    return {}
end

local function saveConfig(fileName, data)
    if not fileFunctions then return end
    ensureFolder(configFolder)
    local path = configFolder .. "/" .. fileName .. configExtension
    local success, json = pcall(HttpService.JSONEncode, HttpService, data)
    if success then
        safeCall(writefile, path, json)
    end
end

-- UI Helper Functions
local function createCorner(frame, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = frame
    return corner
end

local function createStroke(frame, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Color3.fromRGB(50, 50, 50)
    stroke.Thickness = thickness or 1
    stroke.Parent = frame
    return stroke
end

local function makeDraggable(frame, dragArea)
    dragArea = dragArea or frame
    local dragging = false
    local dragStart, startPos

    dragArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragArea.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Main Window Creation
function RaihjnDev:CreateWindow(config)
    config = config or {}
    local windowName = config.Name or "RaihjnDev Hub"
    local loadingTitle = config.LoadingTitle or "RaihjnDev"
    local loadingSubtitle = config.LoadingSubtitle or "Loading..."
    local themeName = config.Theme or "Default"
    local theme = (type(themeName) == "string" and RaihjnDev.Themes[themeName]) or (type(themeName) == "table" and themeName) or RaihjnDev.Themes.Default
    local keySystem = config.KeySystem or false
    local keySettings = config.KeySettings or {}
    local configSaving = config.ConfigurationSaving or {Enable = false, FolderName = nil, FileName = "Config"}
    local discord = config.Discord or {Enable = false, Invite = "", RememberJoins = true}
    local disablePrompts = config.DisableRayfieldPrompts or false

    -- Key system handling (simplified, tapi bisa diimplementasi lebih lanjut)
    local keyValid = not keySystem  -- Jika key system dimatikan, langsung valid
    if keySystem then
        -- Di sini seharusnya tampilkan prompt key, tapi untuk contoh kita anggap selalu valid dulu
        keyValid = true
        -- Untuk production, Anda perlu implementasi input key dan validasi
    end

    -- Create main GUI
    local gui = Instance.new("ScreenGui")
    gui.Name = "RaihjnDev_" .. windowName:gsub("%s+", "")
    gui.Parent = (not isStudio and CoreGui) or LocalPlayer:WaitForChild("PlayerGui")
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Window object
    local window = {}
    window.Name = windowName
    window.Theme = theme
    window.Flags = {}
    window.Gui = gui
    window.Tabs = {}
    window.CurrentTab = nil
    window.ConfigSaving = configSaving
    window.ConfigData = configSaving.Enable and loadConfig(configSaving.FileName) or {}
    window.Destroyed = false

    -- Main frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Parent = gui
    mainFrame.Size = UDim2.new(0, 600, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
    mainFrame.BackgroundColor3 = theme.Background
    mainFrame.BorderSizePixel = 0
    createCorner(mainFrame, 8)
    createStroke(mainFrame, theme.Shadow, 1)

    -- Loading screen (optional, bisa diaktifkan)
    if loadingTitle and not disablePrompts then
        local loadingFrame = Instance.new("Frame")
        loadingFrame.Parent = gui
        loadingFrame.Size = UDim2.new(1, 0, 1, 0)
        loadingFrame.BackgroundColor3 = theme.Background
        loadingFrame.ZIndex = 10

        local loadingTitleLabel = Instance.new("TextLabel")
        loadingTitleLabel.Parent = loadingFrame
        loadingTitleLabel.Size = UDim2.new(1, 0, 0, 50)
        loadingTitleLabel.Position = UDim2.new(0, 0, 0.5, -60)
        loadingTitleLabel.BackgroundTransparency = 1
        loadingTitleLabel.Text = loadingTitle
        loadingTitleLabel.TextColor3 = theme.TextColor
        loadingTitleLabel.Font = Enum.Font.GothamBold
        loadingTitleLabel.TextSize = 30

        local loadingSubLabel = Instance.new("TextLabel")
        loadingSubLabel.Parent = loadingFrame
        loadingSubLabel.Size = UDim2.new(1, 0, 0, 30)
        loadingSubLabel.Position = UDim2.new(0, 0, 0.5, -10)
        loadingSubLabel.BackgroundTransparency = 1
        loadingSubLabel.Text = loadingSubtitle
        loadingSubLabel.TextColor3 = theme.TextColor
        loadingSubLabel.Font = Enum.Font.Gotham
        loadingSubLabel.TextSize = 18

        task.wait(2)  -- Simulasi loading
        loadingFrame:Destroy()
    end

    -- Topbar
    local topbar = Instance.new("Frame")
    topbar.Parent = mainFrame
    topbar.Size = UDim2.new(1, 0, 0, 40)
    topbar.BackgroundColor3 = theme.Topbar
    topbar.BorderSizePixel = 0
    createCorner(topbar, 8)
    createStroke(topbar, theme.Shadow, 1)

    local title = Instance.new("TextLabel")
    title.Parent = topbar
    title.Size = UDim2.new(1, -50, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = windowName
    title.TextColor3 = theme.TextColor
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left

    local closeBtn = Instance.new("TextButton")
    closeBtn.Parent = topbar
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -40, 0.5, -15)
    closeBtn.BackgroundColor3 = theme.TabBackgroundSelected  -- Warna aksen
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.new(1,1,1)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 18
    createCorner(closeBtn, 6)
    closeBtn.MouseButton1Click:Connect(function()
        gui:Destroy()
        window.Destroyed = true
        if window.ConfigSaving.Enable then
            window:SaveConfig()
        end
    end)

    makeDraggable(mainFrame, topbar)

    -- Tab bar
    local tabBar = Instance.new("Frame")
    tabBar.Parent = mainFrame
    tabBar.Size = UDim2.new(1, -20, 0, 40)
    tabBar.Position = UDim2.new(0, 10, 0, 45)
    tabBar.BackgroundTransparency = 1

    local tabList = Instance.new("Frame")
    tabList.Parent = tabBar
    tabList.Size = UDim2.new(1, 0, 1, 0)
    tabList.BackgroundTransparency = 1

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.Parent = tabList
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Padding = UDim.new(0, 5)

    -- Content area
    local contentFrame = Instance.new("Frame")
    contentFrame.Parent = mainFrame
    contentFrame.Size = UDim2.new(1, -20, 1, -100)
    contentFrame.Position = UDim2.new(0, 10, 0, 90)
    contentFrame.BackgroundTransparency = 1

    -- Tab creation method
    function window:CreateTab(name, icon)
        local tab = {}
        tab.Name = name
        tab.Icon = icon
        tab.Elements = {}

        -- Tab content frame (ScrollingFrame)
        local tabFrame = Instance.new("ScrollingFrame")
        tabFrame.Parent = contentFrame
        tabFrame.Size = UDim2.new(1, 0, 1, 0)
        tabFrame.BackgroundTransparency = 1
        tabFrame.BorderSizePixel = 0
        tabFrame.ScrollBarThickness = 6
        tabFrame.ScrollBarImageColor3 = theme.SliderBackground
        tabFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
        tabFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        tabFrame.Visible = false

        local tabLayoutList = Instance.new("UIListLayout")
        tabLayoutList.Parent = tabFrame
        tabLayoutList.HorizontalAlignment = Enum.HorizontalAlignment.Center
        tabLayoutList.SortOrder = Enum.SortOrder.LayoutOrder
        tabLayoutList.Padding = UDim.new(0, 5)

        tabLayoutList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            tabFrame.CanvasSize = UDim2.new(0, 0, 0, tabLayoutList.AbsoluteContentSize.Y + 20)
        end)

        -- Tab button
        local tabBtn = Instance.new("TextButton")
        tabBtn.Parent = tabList
        tabBtn.Size = UDim2.new(0, 100, 1, -10)
        tabBtn.Position = UDim2.new(0, 0, 0, 5)
        tabBtn.BackgroundColor3 = theme.TabBackground
        tabBtn.Text = name
        tabBtn.TextColor3 = theme.TabTextColor
        tabBtn.Font = Enum.Font.GothamSemibold
        tabBtn.TextSize = 14
        createCorner(tabBtn, 6)
        createStroke(tabBtn, theme.TabStroke, 1)

        tabBtn.MouseButton1Click:Connect(function()
            if window.CurrentTab then
                window.CurrentTab.Frame.Visible = false
                window.CurrentTab.Button.BackgroundColor3 = theme.TabBackground
                window.CurrentTab.Button.TextColor3 = theme.TabTextColor
            end
            tabFrame.Visible = true
            tabBtn.BackgroundColor3 = theme.TabBackgroundSelected
            tabBtn.TextColor3 = theme.SelectedTabTextColor
            window.CurrentTab = tab
        end)

        tab.Button = tabBtn
        tab.Frame = tabFrame

        -- Section creation method
        function tab:CreateSection(sectionName)
            local section = {}
            section.Name = sectionName
            section.Elements = {}

            local sectionFrame = Instance.new("Frame")
            sectionFrame.Parent = tabFrame
            sectionFrame.Size = UDim2.new(1, -10, 0, 0)
            sectionFrame.BackgroundColor3 = theme.SecondaryElementBackground
            sectionFrame.BorderSizePixel = 0
            sectionFrame.AutomaticSize = Enum.AutomaticSize.Y
            createCorner(sectionFrame, 8)
            createStroke(sectionFrame, theme.SecondaryElementStroke, 1)

            local sectionTitle = Instance.new("TextLabel")
            sectionTitle.Parent = sectionFrame
            sectionTitle.Size = UDim2.new(1, -10, 0, 30)
            sectionTitle.Position = UDim2.new(0, 5, 0, 5)
            sectionTitle.BackgroundTransparency = 1
            sectionTitle.Text = sectionName
            sectionTitle.TextColor3 = theme.TextColor
            sectionTitle.Font = Enum.Font.GothamBold
            sectionTitle.TextSize = 16
            sectionTitle.TextXAlignment = Enum.TextXAlignment.Left

            local sectionLayout = Instance.new("UIListLayout")
            sectionLayout.Parent = sectionFrame
            sectionLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            sectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
            sectionLayout.Padding = UDim.new(0, 5)

            sectionLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                sectionFrame.Size = UDim2.new(1, -10, 0, sectionLayout.AbsoluteContentSize.Y + 40)
            end)

            -- Element creation methods
            function section:CreateButton(btnConfig)
                local btnFrame = Instance.new("Frame")
                btnFrame.Parent = sectionFrame
                btnFrame.Size = UDim2.new(1, -10, 0, 35)
                btnFrame.BackgroundColor3 = theme.ElementBackground
                btnFrame.BorderSizePixel = 0
                createCorner(btnFrame, 6)
                createStroke(btnFrame, theme.ElementStroke, 1)

                local btn = Instance.new("TextButton")
                btn.Parent = btnFrame
                btn.Size = UDim2.new(1, 0, 1, 0)
                btn.BackgroundTransparency = 1
                btn.Text = btnConfig.Name or "Button"
                btn.TextColor3 = theme.TextColor
                btn.Font = Enum.Font.GothamSemibold
                btn.TextSize = 14
                btn.MouseButton1Click:Connect(btnConfig.Callback or function() end)

                btn.MouseEnter:Connect(function()
                    btnFrame.BackgroundColor3 = theme.ElementBackgroundHover
                end)
                btn.MouseLeave:Connect(function()
                    btnFrame.BackgroundColor3 = theme.ElementBackground
                end)

                return btn
            end

            function section:CreateToggle(togConfig)
                local togFrame = Instance.new("Frame")
                togFrame.Parent = sectionFrame
                togFrame.Size = UDim2.new(1, -10, 0, 35)
                togFrame.BackgroundColor3 = theme.ElementBackground
                togFrame.BorderSizePixel = 0
                createCorner(togFrame, 6)
                createStroke(togFrame, theme.ElementStroke, 1)

                local label = Instance.new("TextLabel")
                label.Parent = togFrame
                label.Size = UDim2.new(1, -50, 1, 0)
                label.Position = UDim2.new(0, 10, 0, 0)
                label.BackgroundTransparency = 1
                label.Text = togConfig.Name or "Toggle"
                label.TextColor3 = theme.TextColor
                label.Font = Enum.Font.GothamSemibold
                label.TextSize = 14
                label.TextXAlignment = Enum.TextXAlignment.Left

                local toggleBtn = Instance.new("TextButton")
                toggleBtn.Parent = togFrame
                toggleBtn.Size = UDim2.new(0, 40, 0, 20)
                toggleBtn.Position = UDim2.new(1, -50, 0.5, -10)
                toggleBtn.BackgroundColor3 = theme.ToggleDisabled
                toggleBtn.Text = ""
                createCorner(toggleBtn, 10)
                createStroke(toggleBtn, theme.ToggleDisabledStroke, 1)

                local state = togConfig.Default or false
                if state then
                    toggleBtn.BackgroundColor3 = theme.ToggleEnabled
                    createStroke(toggleBtn, theme.ToggleEnabledStroke, 1)
                end

                toggleBtn.MouseButton1Click:Connect(function()
                    state = not state
                    if state then
                        toggleBtn.BackgroundColor3 = theme.ToggleEnabled
                        createStroke(toggleBtn, theme.ToggleEnabledStroke, 1)
                    else
                        toggleBtn.BackgroundColor3 = theme.ToggleDisabled
                        createStroke(toggleBtn, theme.ToggleDisabledStroke, 1)
                    end
                    if togConfig.Callback then
                        togConfig.Callback(state)
                    end
                    if togConfig.Flag then
                        RaihjnDev.Flags[togConfig.Flag] = state
                        window.Flags[togConfig.Flag] = state
                    end
                end)

                -- Load from config
                if togConfig.Flag and window.ConfigData[togConfig.Flag] ~= nil then
                    state = window.ConfigData[togConfig.Flag]
                    if state then
                        toggleBtn.BackgroundColor3 = theme.ToggleEnabled
                        createStroke(toggleBtn, theme.ToggleEnabledStroke, 1)
                    else
                        toggleBtn.BackgroundColor3 = theme.ToggleDisabled
                        createStroke(toggleBtn, theme.ToggleDisabledStroke, 1)
                    end
                end

                return toggleBtn
            end

            function section:CreateSlider(sliConfig)
                local sliFrame = Instance.new("Frame")
                sliFrame.Parent = sectionFrame
                sliFrame.Size = UDim2.new(1, -10, 0, 45)
                sliFrame.BackgroundColor3 = theme.ElementBackground
                sliFrame.BorderSizePixel = 0
                createCorner(sliFrame, 6)
                createStroke(sliFrame, theme.ElementStroke, 1)

                local label = Instance.new("TextLabel")
                label.Parent = sliFrame
                label.Size = UDim2.new(1, -20, 0, 20)
                label.Position = UDim2.new(0, 10, 0, 5)
                label.BackgroundTransparency = 1
                label.Text = sliConfig.Name or "Slider"
                label.TextColor3 = theme.TextColor
                label.Font = Enum.Font.GothamSemibold
                label.TextSize = 14
                label.TextXAlignment = Enum.TextXAlignment.Left

                local valueLabel = Instance.new("TextLabel")
                valueLabel.Parent = sliFrame
                valueLabel.Size = UDim2.new(0, 40, 0, 20)
                valueLabel.Position = UDim2.new(1, -50, 0, 5)
                valueLabel.BackgroundTransparency = 1
                valueLabel.Text = tostring(sliConfig.Default or sliConfig.Min or 0)
                valueLabel.TextColor3 = theme.SliderProgress
                valueLabel.Font = Enum.Font.GothamBold
                valueLabel.TextSize = 14

                local sliderBg = Instance.new("Frame")
                sliderBg.Parent = sliFrame
                sliderBg.Size = UDim2.new(1, -20, 0, 10)
                sliderBg.Position = UDim2.new(0, 10, 0, 30)
                sliderBg.BackgroundColor3 = theme.SliderBackground
                sliderBg.BorderSizePixel = 0
                createCorner(sliderBg, 5)
                createStroke(sliderBg, theme.SliderStroke, 1)

                local sliderFill = Instance.new("Frame")
                sliderFill.Parent = sliderBg
                sliderFill.Size = UDim2.new(0, 0, 1, 0)
                sliderFill.BackgroundColor3 = theme.SliderProgress
                sliderFill.BorderSizePixel = 0
                createCorner(sliderFill, 5)

                local min = sliConfig.Min or 0
                local max = sliConfig.Max or 100
                local precise = sliConfig.Precise or false
                local current = sliConfig.Default or min
                local function updateSlider(pos)
                    local relativeX = math.clamp((pos.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
                    local value = min + (max - min) * relativeX
                    if not precise then
                        value = math.floor(value + 0.5)
                    end
                    current = value
                    sliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
                    valueLabel.Text = tostring(current)
                end

                sliderBg.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        updateSlider(input.Position)
                        local conn
                        conn = RunService.RenderStepped:Connect(function()
                            if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                                updateSlider(Mouse)
                            else
                                conn:Disconnect()
                                if sliConfig.Callback then
                                    sliConfig.Callback(current)
                                end
                                if sliConfig.Flag then
                                    RaihjnDev.Flags[sliConfig.Flag] = current
                                    window.Flags[sliConfig.Flag] = current
                                end
                            end
                        end)
                    end
                end)

                -- Load from config
                if sliConfig.Flag and window.ConfigData[sliConfig.Flag] ~= nil then
                    current = window.ConfigData[sliConfig.Flag]
                    local relativeX = (current - min) / (max - min)
                    sliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
                    valueLabel.Text = tostring(current)
                end

                return sliderFill
            end

            function section:CreateDropdown(drpConfig)
                local drpFrame = Instance.new("Frame")
                drpFrame.Parent = sectionFrame
                drpFrame.Size = UDim2.new(1, -10, 0, 35)
                drpFrame.BackgroundColor3 = theme.ElementBackground
                drpFrame.BorderSizePixel = 0
                drpFrame.ClipsDescendants = true
                createCorner(drpFrame, 6)
                createStroke(drpFrame, theme.ElementStroke, 1)

                local label = Instance.new("TextLabel")
                label.Parent = drpFrame
                label.Size = UDim2.new(0.6, -10, 1, 0)
                label.Position = UDim2.new(0, 10, 0, 0)
                label.BackgroundTransparency = 1
                label.Text = drpConfig.Name or "Dropdown"
                label.TextColor3 = theme.TextColor
                label.Font = Enum.Font.GothamSemibold
                label.TextSize = 14
                label.TextXAlignment = Enum.TextXAlignment.Left

                local currentLabel = Instance.new("TextLabel")
                currentLabel.Parent = drpFrame
                currentLabel.Size = UDim2.new(0.4, -20, 1, 0)
                currentLabel.Position = UDim2.new(0.6, 5, 0, 0)
                currentLabel.BackgroundTransparency = 1
                currentLabel.Text = drpConfig.Options and drpConfig.Options[1] or "Select"
                currentLabel.TextColor3 = theme.SliderProgress
                currentLabel.Font = Enum.Font.GothamSemibold
                currentLabel.TextSize = 14
                currentLabel.TextXAlignment = Enum.TextXAlignment.Right

                local arrow = Instance.new("TextLabel")
                arrow.Parent = drpFrame
                arrow.Size = UDim2.new(0, 20, 1, 0)
                arrow.Position = UDim2.new(1, -25, 0, 0)
                arrow.BackgroundTransparency = 1
                arrow.Text = "▼"
                arrow.TextColor3 = theme.SliderProgress
                arrow.Font = Enum.Font.GothamBold
                arrow.TextSize = 14

                local dropdownList = Instance.new("ScrollingFrame")
                dropdownList.Parent = drpFrame
                dropdownList.Size = UDim2.new(1, 0, 0, 0)
                dropdownList.Position = UDim2.new(0, 0, 1, 0)
                dropdownList.BackgroundColor3 = theme.DropdownUnselected
                dropdownList.BorderSizePixel = 0
                dropdownList.ScrollBarThickness = 4
                dropdownList.ScrollBarImageColor3 = theme.SliderBackground
                dropdownList.Visible = false
                createCorner(dropdownList, 6)
                createStroke(dropdownList, theme.ElementStroke, 1)

                local listLayout = Instance.new("UIListLayout")
                listLayout.Parent = dropdownList
                listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
                listLayout.SortOrder = Enum.SortOrder.LayoutOrder
                listLayout.Padding = UDim.new(0, 2)

                local options = drpConfig.Options or {}
                local selected = drpConfig.Default or options[1]

                local function updateDropdown()
                    for _, child in ipairs(dropdownList:GetChildren()) do
                        if child:IsA("TextButton") then child:Destroy() end
                    end
                    for _, opt in ipairs(options) do
                        local optBtn = Instance.new("TextButton")
                        optBtn.Parent = dropdownList
                        optBtn.Size = UDim2.new(1, -4, 0, 25)
                        optBtn.BackgroundColor3 = (opt == selected) and theme.DropdownSelected or theme.DropdownUnselected
                        optBtn.Text = tostring(opt)
                        optBtn.TextColor3 = theme.TextColor
                        optBtn.Font = Enum.Font.Gotham
                        optBtn.TextSize = 13
                        optBtn.BorderSizePixel = 0
                        createCorner(optBtn, 4)
                        optBtn.MouseButton1Click:Connect(function()
                            selected = opt
                            currentLabel.Text = tostring(opt)
                            dropdownList.Visible = false
                            drpFrame.Size = UDim2.new(1, -10, 0, 35)
                            arrow.Text = "▼"
                            if drpConfig.Callback then
                                drpConfig.Callback(opt)
                            end
                            if drpConfig.Flag then
                                RaihjnDev.Flags[drpConfig.Flag] = opt
                                window.Flags[drpConfig.Flag] = opt
                            end
                            updateDropdown()
                        end)
                    end
                    dropdownList.CanvasSize = UDim2.new(0, 0, 0, #options * 27 + 5)
                end

                updateDropdown()

                drpFrame.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        if dropdownList.Visible then
                            dropdownList.Visible = false
                            drpFrame.Size = UDim2.new(1, -10, 0, 35)
                            arrow.Text = "▼"
                        else
                            local height = math.min(150, #options * 27 + 5)
                            dropdownList.Size = UDim2.new(1, 0, 0, height)
                            dropdownList.Visible = true
                            drpFrame.Size = UDim2.new(1, -10, 0, 35 + height)
                            arrow.Text = "▲"
                        end
                    end
                end)

                -- Load from config
                if drpConfig.Flag and window.ConfigData[drpConfig.Flag] ~= nil then
                    selected = window.ConfigData[drpConfig.Flag]
                    currentLabel.Text = tostring(selected)
                    updateDropdown()
                end

                return drpFrame
            end

            function section:CreateTextBox(txtConfig)
                local txtFrame = Instance.new("Frame")
                txtFrame.Parent = sectionFrame
                txtFrame.Size = UDim2.new(1, -10, 0, 35)
                txtFrame.BackgroundColor3 = theme.ElementBackground
                txtFrame.BorderSizePixel = 0
                createCorner(txtFrame, 6)
                createStroke(txtFrame, theme.ElementStroke, 1)

                local label = Instance.new("TextLabel")
                label.Parent = txtFrame
                label.Size = UDim2.new(0.4, -10, 1, 0)
                label.Position = UDim2.new(0, 10, 0, 0)
                label.BackgroundTransparency = 1
                label.Text = txtConfig.Name or "Input"
                label.TextColor3 = theme.TextColor
                label.Font = Enum.Font.GothamSemibold
                label.TextSize = 14
                label.TextXAlignment = Enum.TextXAlignment.Left

                local box = Instance.new("TextBox")
                box.Parent = txtFrame
                box.Size = UDim2.new(0.6, -20, 1, -10)
                box.Position = UDim2.new(0.4, 5, 0.5, -12)
                box.BackgroundColor3 = theme.InputBackground
                box.TextColor3 = theme.TextColor
                box.PlaceholderColor3 = theme.PlaceholderColor
                box.PlaceholderText = txtConfig.Placeholder or ""
                box.Text = tostring(txtConfig.Default or "")
                box.Font = Enum.Font.Gotham
                box.TextSize = 14
                box.ClearTextOnFocus = false
                createCorner(box, 4)
                createStroke(box, theme.InputStroke, 1)

                box.FocusLost:Connect(function(enterPressed)
                    if txtConfig.Callback then
                        txtConfig.Callback(box.Text)
                    end
                    if txtConfig.Flag then
                        RaihjnDev.Flags[txtConfig.Flag] = box.Text
                        window.Flags[txtConfig.Flag] = box.Text
                    end
                end)

                -- Load from config
                if txtConfig.Flag and window.ConfigData[txtConfig.Flag] ~= nil then
                    box.Text = tostring(window.ConfigData[txtConfig.Flag])
                end

                return box
            end

            function section:CreateKeybind(keyConfig)
                local keyFrame = Instance.new("Frame")
                keyFrame.Parent = sectionFrame
                keyFrame.Size = UDim2.new(1, -10, 0, 35)
                keyFrame.BackgroundColor3 = theme.ElementBackground
                keyFrame.BorderSizePixel = 0
                createCorner(keyFrame, 6)
                createStroke(keyFrame, theme.ElementStroke, 1)

                local label = Instance.new("TextLabel")
                label.Parent = keyFrame
                label.Size = UDim2.new(0.6, -10, 1, 0)
                label.Position = UDim2.new(0, 10, 0, 0)
                label.BackgroundTransparency = 1
                label.Text = keyConfig.Name or "Keybind"
                label.TextColor3 = theme.TextColor
                label.Font = Enum.Font.GothamSemibold
                label.TextSize = 14
                label.TextXAlignment = Enum.TextXAlignment.Left

                local keyBtn = Instance.new("TextButton")
                keyBtn.Parent = keyFrame
                keyBtn.Size = UDim2.new(0.4, -20, 1, -10)
                keyBtn.Position = UDim2.new(0.6, 5, 0.5, -12)
                keyBtn.BackgroundColor3 = theme.InputBackground
                keyBtn.Text = keyConfig.Default or "K"
                keyBtn.TextColor3 = theme.TextColor
                keyBtn.Font = Enum.Font.Gotham
                keyBtn.TextSize = 14
                createCorner(keyBtn, 4)
                createStroke(keyBtn, theme.InputStroke, 1)

                local binding = false
                local currentKey = keyConfig.Default or "K"

                keyBtn.MouseButton1Click:Connect(function()
                    binding = true
                    keyBtn.Text = "..."
                end)

                UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if binding and not gameProcessed then
                        if input.KeyCode ~= Enum.KeyCode.Unknown then
                            currentKey = input.KeyCode.Name
                            keyBtn.Text = currentKey
                            binding = false
                            if keyConfig.Callback then
                                keyConfig.Callback(currentKey)
                            end
                            if keyConfig.Flag then
                                RaihjnDev.Flags[keyConfig.Flag] = currentKey
                                window.Flags[keyConfig.Flag] = currentKey
                            end
                        end
                    end
                end)

                -- Load from config
                if keyConfig.Flag and window.ConfigData[keyConfig.Flag] ~= nil then
                    currentKey = window.ConfigData[keyConfig.Flag]
                    keyBtn.Text = currentKey
                end

                return keyBtn
            end

            function section:CreateLabel(lblConfig)
                local lblFrame = Instance.new("Frame")
                lblFrame.Parent = sectionFrame
                lblFrame.Size = UDim2.new(1, -10, 0, 30)
                lblFrame.BackgroundColor3 = theme.ElementBackground
                lblFrame.BorderSizePixel = 0
                createCorner(lblFrame, 6)
                createStroke(lblFrame, theme.ElementStroke, 1)

                local label = Instance.new("TextLabel")
                label.Parent = lblFrame
                label.Size = UDim2.new(1, -10, 1, 0)
                label.Position = UDim2.new(0, 5, 0, 0)
                label.BackgroundTransparency = 1
                label.Text = lblConfig.Text or "Label"
                label.TextColor3 = theme.TextColor
                label.Font = Enum.Font.Gotham
                label.TextSize = 14
                label.TextWrapped = true

                return label
            end

            function section:CreateParagraph(parConfig)
                local parFrame = Instance.new("Frame")
                parFrame.Parent = sectionFrame
                parFrame.Size = UDim2.new(1, -10, 0, 60)
                parFrame.BackgroundColor3 = theme.ElementBackground
                parFrame.BorderSizePixel = 0
                createCorner(parFrame, 6)
                createStroke(parFrame, theme.ElementStroke, 1)

                local title = Instance.new("TextLabel")
                title.Parent = parFrame
                title.Size = UDim2.new(1, -10, 0, 20)
                title.Position = UDim2.new(0, 5, 0, 5)
                title.BackgroundTransparency = 1
                title.Text = parConfig.Title or "Title"
                title.TextColor3 = theme.SliderProgress
                title.Font = Enum.Font.GothamBold
                title.TextSize = 16
                title.TextXAlignment = Enum.TextXAlignment.Left

                local content = Instance.new("TextLabel")
                content.Parent = parFrame
                content.Size = UDim2.new(1, -10, 0, 30)
                content.Position = UDim2.new(0, 5, 0, 25)
                content.BackgroundTransparency = 1
                content.Text = parConfig.Content or "Content"
                content.TextColor3 = theme.TextColor
                content.Font = Enum.Font.Gotham
                content.TextSize = 14
                content.TextWrapped = true
                content.TextYAlignment = Enum.TextYAlignment.Top

                return content
            end

            return section
        end

        table.insert(window.Tabs, tab)
        if #window.Tabs == 1 then
            window.CurrentTab = tab
            tabFrame.Visible = true
            tabBtn.BackgroundColor3 = theme.TabBackgroundSelected
            tabBtn.TextColor3 = theme.SelectedTabTextColor
        end
        return tab
    end

    -- Save configuration
    function window:SaveConfig()
        if not self.ConfigSaving.Enable then return end
        local data = {}
        for flag, value in pairs(self.Flags) do
            data[flag] = value
        end
        saveConfig(self.ConfigSaving.FileName, data)
    end

    -- Load configuration
    function window:LoadConfig()
        if not self.ConfigSaving.Enable then return end
        self.ConfigData = loadConfig(self.ConfigSaving.FileName)
        for flag, value in pairs(self.ConfigData) do
            self.Flags[flag] = value
            RaihjnDev.Flags[flag] = value
        end
    end

    -- Auto-save on close
    gui.Destroying:Connect(function()
        if window.ConfigSaving.Enable then
            window:SaveConfig()
        end
    end)

    -- Load config initially
    if configSaving.Enable then
        window:LoadConfig()
    end

    -- Discord integration (placeholder)
    if discord.Enable and discord.Invite ~= "" then
        print("Join Discord: discord.gg/" .. discord.Invite)
        -- Bisa tambahkan prompt join di sini
    end

    table.insert(RaihjnDev.Windows, window)
    return window
end

-- Notify function (mirip Rayfield)
function RaihjnDev:Notify(config)
    config = config or {}
    local title = config.Title or "Notification"
    local content = config.Content or ""
    local duration = config.Duration or 5
    local image = config.Image  -- Tidak digunakan, hanya untuk kompatibilitas
    local actions = config.Actions or {}

    -- Simple notification using a popup
    local gui = Instance.new("ScreenGui")
    gui.Parent = (not isStudio and CoreGui) or LocalPlayer:WaitForChild("PlayerGui")
    gui.Name = "RaihjnDevNotification"
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local frame = Instance.new("Frame")
    frame.Parent = gui
    frame.Size = UDim2.new(0, 300, 0, 100)
    frame.Position = UDim2.new(1, -310, 1, -110)
    frame.BackgroundColor3 = RaihjnDev.Themes.Default.NotificationBackground  -- Pakai tema default
    frame.BorderSizePixel = 0
    createCorner(frame, 8)
    createStroke(frame, RaihjnDev.Themes.Default.Shadow, 1)

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Parent = frame
    titleLabel.Size = UDim2.new(1, -20, 0, 25)
    titleLabel.Position = UDim2.new(0, 10, 0, 5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = RaihjnDev.Themes.Default.SliderProgress
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 16
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local contentLabel = Instance.new("TextLabel")
    contentLabel.Parent = frame
    contentLabel.Size = UDim2.new(1, -20, 0, 40)
    contentLabel.Position = UDim2.new(0, 10, 0, 30)
    contentLabel.BackgroundTransparency = 1
    contentLabel.Text = content
    contentLabel.TextColor3 = RaihjnDev.Themes.Default.TextColor
    contentLabel.Font = Enum.Font.Gotham
    contentLabel.TextSize = 14
    contentLabel.TextWrapped = true
    contentLabel.TextYAlignment = Enum.TextYAlignment.Top

    local closeBtn = Instance.new("TextButton")
    closeBtn.Parent = frame
    closeBtn.Size = UDim2.new(0, 60, 0, 25)
    closeBtn.Position = UDim2.new(1, -70, 1, -30)
    closeBtn.BackgroundColor3 = RaihjnDev.Themes.Default.SliderProgress
    closeBtn.Text = "OK"
    closeBtn.TextColor3 = Color3.new(1,1,1)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14
    createCorner(closeBtn, 4)
    closeBtn.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)

    -- Actions (implementasi sederhana)
    for actionName, actionData in pairs(actions) do
        -- Bisa ditambahkan tombol aksi
    end

    task.delay(duration, function()
        if gui and gui.Parent then
            gui:Destroy()
        end
    end)

    return gui
end

return RaihjnDev
