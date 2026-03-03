-- GridSelector.lua
local UIS = game:GetService("UserInputService")

local function CreateGridSelectorUI()
    local success, err = pcall(function()
        if getgenv().AFGridGui then
            pcall(function() getgenv().AFGridGui:Destroy() end)
        end

        -- == Colour tokens matching Rayfield ==
        local C_BG      = Color3.fromRGB(12,  12,  14)
        local C_SURF    = Color3.fromRGB(20,  20,  24)
        local C_TOP     = Color3.fromRGB(17,  17,  20)
        local C_ACC     = Color3.fromRGB(77,  120, 204)
        local C_ACC2    = Color3.fromRGB(50,  85,  160)
        local C_SEL     = Color3.fromRGB(46,  160, 90)
        local C_SEL2    = Color3.fromRGB(28,  110, 58)
        local C_TXT     = Color3.fromRGB(230, 230, 235)
        local C_SUB     = Color3.fromRGB(140, 140, 155)
        local C_CELL    = Color3.fromRGB(25,  25,  32)
        local C_CELLHOV = Color3.fromRGB(34,  34,  44)
        local C_BOR     = Color3.fromRGB(38,  38,  50)
        local C_SEP     = Color3.fromRGB(30,  30,  40)

        local W, H = 314, 398

        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "AutoFarmGridSelector"
        screenGui.ResetOnSpawn = false
        screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        screenGui.DisplayOrder = 999

        if gethui then
            screenGui.Parent = gethui()
        elseif syn and syn.protect_gui then
            syn.protect_gui(screenGui)
            screenGui.Parent = game:GetService("CoreGui")
        else
            screenGui.Parent = game:GetService("CoreGui")
        end

        getgenv().AFGridGui = screenGui

        local mainFrame = Instance.new("Frame")
        mainFrame.Name = "GridContainer"
        mainFrame.Size = UDim2.new(0, W, 0, H)
        mainFrame.Position = UDim2.new(0.5, -W/2, 0.5, -H/2)
        mainFrame.BackgroundColor3 = C_BG
        mainFrame.BorderSizePixel = 0
        mainFrame.Parent = screenGui
        Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)
        local wStroke = Instance.new("UIStroke", mainFrame)
        wStroke.Color = C_BOR; wStroke.Thickness = 1.2

        -- Title bar (dengan drag)
        local titleBar = Instance.new("Frame", mainFrame)
        titleBar.Name = "TitleBar"
        titleBar.Size = UDim2.new(1, 0, 0, 44)
        titleBar.BackgroundColor3 = C_TOP
        titleBar.BorderSizePixel = 0
        Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 10)

        local titleLabel = Instance.new("TextLabel", titleBar)
        titleLabel.Text = "Grid Selector"
        titleLabel.Size = UDim2.new(1, -80, 1, 0)
        titleLabel.Position = UDim2.new(0, 24, 0, 0)
        titleLabel.BackgroundTransparency = 1
        titleLabel.TextColor3 = C_TXT
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.TextSize = 14
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left

        local closeBtn = Instance.new("TextButton", titleBar)
        closeBtn.Text = "✖"
        closeBtn.Size = UDim2.new(0, 28, 0, 28)
        closeBtn.Position = UDim2.new(1, -36, 0.5, -14)
        closeBtn.BackgroundColor3 = Color3.fromRGB(190, 48, 48)
        closeBtn.TextColor3 = C_TXT
        closeBtn.Font = Enum.Font.GothamBold
        closeBtn.TextSize = 12
        closeBtn.BorderSizePixel = 0
        Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
        closeBtn.MouseButton1Click:Connect(function() mainFrame.Visible = false end)

        -- Drag functionality
        local dragging, dragStart, startPos
        titleBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = mainFrame.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then dragging = false end
                end)
            end
        end)
        titleBar.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                dragInput = input
            end
        end)
        UIS.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                local delta = input.Position - dragStart
                mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                               startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)

        -- Badge info
        local badge = Instance.new("Frame", mainFrame)
        badge.Size = UDim2.new(1, -20, 0, 28)
        badge.Position = UDim2.new(0, 10, 0, 52)
        badge.BackgroundColor3 = C_SURF
        Instance.new("UICorner", badge).CornerRadius = UDim.new(0, 6)

        local infoLabel = Instance.new("TextLabel", badge)
        infoLabel.Name = "InfoLabel"
        infoLabel.Text = "Mendeteksi..."
        infoLabel.Size = UDim2.new(1, -10, 1, 0)
        infoLabel.Position = UDim2.new(0, 10, 0, 0)
        infoLabel.BackgroundTransparency = 1
        infoLabel.TextColor3 = C_SUB
        infoLabel.Font = Enum.Font.GothamMedium
        infoLabel.TextSize = 12
        infoLabel.TextXAlignment = Enum.TextXAlignment.Left

        task.spawn(function()
            while getgenv().AFGridGui and getgenv().AFGridGui.Parent do
                local held = getgenv().GetHeldItemID and getgenv().GetHeldItemID()
                if held then
                    infoLabel.Text = "Block: " .. held
                    infoLabel.TextColor3 = Color3.fromRGB(90, 210, 115)
                else
                    infoLabel.Text = "Tidak ada block dipegang"
                    infoLabel.TextColor3 = Color3.fromRGB(210, 80, 80)
                end
                task.wait(1)
            end
        end)

        -- Grid 5x5
        local CELL = 44; local PAD = 4
        local GSIZE = 5*CELL + 4*PAD

        local gridPanel = Instance.new("Frame", mainFrame)
        gridPanel.Size = UDim2.new(0, GSIZE+16, 0, GSIZE+16)
        gridPanel.Position = UDim2.new(0.5, -(GSIZE+16)/2, 0, 88)
        gridPanel.BackgroundColor3 = C_SURF
        Instance.new("UICorner", gridPanel).CornerRadius = UDim.new(0, 8)

        local gridFrame = Instance.new("Frame", gridPanel)
        gridFrame.Name = "Grid"
        gridFrame.Size = UDim2.new(0, GSIZE, 0, GSIZE)
        gridFrame.Position = UDim2.new(0, 8, 0, 8)
        gridFrame.BackgroundTransparency = 1

        -- Buat grid 5x5
        for uiRow = 0, 4 do
            for uiCol = 0, 4 do
                local ox = uiCol - 2
                local oy = 2 - uiRow
                local key = tostring(ox) .. "," .. tostring(oy)
                local isCenter = (ox == 0 and oy == 0)

                local cell = Instance.new("TextButton", gridFrame)
                cell.Name = "Cell_" .. key
                cell.Size = UDim2.new(0, CELL, 0, CELL)
                cell.Position = UDim2.new(0, uiCol*(CELL+PAD), 0, uiRow*(CELL+PAD))
                cell.BorderSizePixel = 0
                cell.Font = Enum.Font.GothamBold
                Instance.new("UICorner", cell).CornerRadius = UDim.new(0, 6)

                if isCenter then
                    cell.BackgroundColor3 = C_ACC2
                    cell.TextColor3 = C_TXT
                    cell.TextSize = 18
                    cell.Text = "🙆‍♂️"
                else
                    local function UpdateCell()
                        if getgenv().AFB_SelectedGrids[key] then
                            cell.BackgroundColor3 = C_SEL
                            cell.TextColor3 = C_TXT
                            cell.TextSize = 16
                            cell.Text = "✓"
                        else
                            cell.BackgroundColor3 = C_CELL
                            cell.TextColor3 = C_SUB
                            cell.TextSize = 10
                            cell.Text = ox..","..oy
                        end
                    end
                    UpdateCell()

                    cell.MouseButton1Click:Connect(function()
                        getgenv().AFB_SelectedGrids[key] = not getgenv().AFB_SelectedGrids[key]
                        UpdateCell()
                    end)
                end
            end
        end

        -- Tombol preset
        local btnRow = Instance.new("Frame", mainFrame)
        btnRow.Size = UDim2.new(1, -20, 0, 36)
        btnRow.Position = UDim2.new(0, 10, 0, H - 48)
        btnRow.BackgroundTransparency = 1

        local function MakeBtn(txt, col, callback)
            local btn = Instance.new("TextButton", btnRow)
            btn.Text = txt
            btn.Size = UDim2.new(1/3, -3, 1, 0)
            btn.BackgroundColor3 = col
            btn.TextColor3 = C_TXT
            btn.Font = Enum.Font.GothamSemibold
            btn.TextSize = 12
            btn.BorderSizePixel = 0
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
            btn.MouseButton1Click:Connect(callback)
        end

        MakeBtn("✔ Semua", C_ACC, function()
            for r=0,4 do for c=0,4 do
                local k = tostring(c-2)..","..tostring(2-r)
                if not (c==2 and r==2) then
                    getgenv().AFB_SelectedGrids[k] = true
                end
            end end
            -- Refresh tampilan (dengan re-create sederhana)
            mainFrame.Visible = false
            task.wait()
            mainFrame.Visible = true
        end)

        MakeBtn("✖ Hapus", Color3.fromRGB(175,48,48), function()
            for k in pairs(getgenv().AFB_SelectedGrids) do
                getgenv().AFB_SelectedGrids[k] = false
            end
            mainFrame.Visible = false
            task.wait()
            mainFrame.Visible = true
        end)

        MakeBtn("⬆ Atas", Color3.fromRGB(95,68,185), function()
            for k in pairs(getgenv().AFB_SelectedGrids) do
                getgenv().AFB_SelectedGrids[k] = false
            end
            for ox=-2,2 do for oy=1,2 do
                getgenv().AFB_SelectedGrids[tostring(ox)..","..tostring(oy)] = true
            end end
            mainFrame.Visible = false
            task.wait()
            mainFrame.Visible = true
        end)

        return mainFrame
    end)
    if not success then
        warn("❌ Error di CreateGridSelectorUI:", err)
    end
end

getgenv().CreateGridSelectorUI = CreateGridSelectorUI
