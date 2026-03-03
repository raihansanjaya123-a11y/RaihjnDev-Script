-- GridSelector.lua
-- Fungsi grid selector untuk AutoFarm

local function GetSelectedOffsets() -- mungkin sudah ada di autofarm, tapi kita definisikan ulang? Sebaiknya tidak perlu, karena grid selector hanya butuh AFB_SelectedGrids.
    -- Sebenarnya fungsi ini tidak dipakai di grid selector, hanya untuk sorting, jadi bisa diabaikan.
end

local function CreateGridSelectorUI()
    if getgenv().AFGridGui then
        pcall(function() getgenv().AFGridGui:Destroy() end)
    end

    local Rayfield = getgenv().Rayfield
    if not Rayfield then
        warn("Rayfield not found")
        return
    end

    -- == Colour tokens matching Rayfield ==
    local C_BG      = Color3.fromRGB(12,  12,  14)   -- main window bg
    local C_SURF    = Color3.fromRGB(20,  20,  24)   -- inner surface panels
    local C_TOP     = Color3.fromRGB(17,  17,  20)   -- title bar
    local C_ACC     = Color3.fromRGB(77,  120, 204)  -- blue accent
    local C_ACC2    = Color3.fromRGB(50,  85,  160)  -- darker blue accent
    local C_SEL     = Color3.fromRGB(46,  160, 90)   -- selected green
    local C_SEL2    = Color3.fromRGB(28,  110, 58)   -- selected green border
    local C_TXT     = Color3.fromRGB(230, 230, 235)
    local C_SUB     = Color3.fromRGB(140, 140, 155)
    local C_CELL    = Color3.fromRGB(25,  25,  32)
    local C_CELLHOV = Color3.fromRGB(34,  34,  44)
    local C_BOR     = Color3.fromRGB(38,  38,  50)
    local C_SEP     = Color3.fromRGB(30,  30,  40)

    local W, H = 314, 398

    -- ScreenGui
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

    -- ── Window ──
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

    -- ── Draggable via title bar ──
    local dragging, dragInput, dragStart, startPos

    -- ── Title bar ──
    local titleBar = Instance.new("Frame", mainFrame)
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 44)
    titleBar.BackgroundColor3 = C_TOP
    titleBar.BorderSizePixel = 0
    Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 10)
    -- flatten bottom corners
    local tbFix = Instance.new("Frame", titleBar)
    tbFix.Size = UDim2.new(1, 0, 0, 10)
    tbFix.Position = UDim2.new(0, 0, 1, -10)
    tbFix.BackgroundColor3 = C_TOP; tbFix.BorderSizePixel = 0

    -- left accent stripe
    local stripe = Instance.new("Frame", titleBar)
    stripe.Size = UDim2.new(0, 3, 0, 22)
    stripe.Position = UDim2.new(0, 12, 0.5, -11)
    stripe.BackgroundColor3 = C_ACC; stripe.BorderSizePixel = 0
    Instance.new("UICorner", stripe).CornerRadius = UDim.new(1, 0)

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
    closeBtn.BackgroundTransparency = 0.35
    closeBtn.TextColor3 = C_TXT
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 12
    closeBtn.BorderSizePixel = 0
    closeBtn.AutoButtonColor = false
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
    closeBtn.MouseButton1Click:Connect(function() mainFrame.Visible = false end)
    closeBtn.MouseEnter:Connect(function() closeBtn.BackgroundTransparency = 0.1 end)
    closeBtn.MouseLeave:Connect(function() closeBtn.BackgroundTransparency = 0.35 end)

    -- drag
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    titleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local d = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
                                           startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)

    -- ── Separator ──
    local sep1 = Instance.new("Frame", mainFrame)
    sep1.Size = UDim2.new(1, 0, 0, 1)
    sep1.Position = UDim2.new(0, 0, 0, 44)
    sep1.BackgroundColor3 = C_SEP; sep1.BorderSizePixel = 0

    -- ── Held-item badge ──
    local badge = Instance.new("Frame", mainFrame)
    badge.Size = UDim2.new(1, -20, 0, 28)
    badge.Position = UDim2.new(0, 10, 0, 52)
    badge.BackgroundColor3 = C_SURF; badge.BorderSizePixel = 0
    Instance.new("UICorner", badge).CornerRadius = UDim.new(0, 6)
    local bStroke = Instance.new("UIStroke", badge); bStroke.Color = C_BOR; bStroke.Thickness = 1

    local bIcon = Instance.new("TextLabel", badge)
    bIcon.Text = "🧱"; bIcon.Size = UDim2.new(0, 24, 1, 0)
    bIcon.Position = UDim2.new(0, 6, 0, 0); bIcon.BackgroundTransparency = 1
    bIcon.TextSize = 14; bIcon.Font = Enum.Font.GothamBold; bIcon.TextColor3 = C_TXT

    local infoLabel = Instance.new("TextLabel", badge)
    infoLabel.Name = "InfoLabel"
    infoLabel.Text = "Mendeteksi..."
    infoLabel.Size = UDim2.new(1, -34, 1, 0)
    infoLabel.Position = UDim2.new(0, 32, 0, 0)
    infoLabel.BackgroundTransparency = 1
    infoLabel.TextColor3 = C_SUB; infoLabel.Font = Enum.Font.GothamMedium
    infoLabel.TextSize = 12; infoLabel.TextXAlignment = Enum.TextXAlignment.Left
    infoLabel.TextTruncate = Enum.TextTruncate.AtEnd

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

    -- ── Grid outer panel ──
    local CELL = 44; local PAD = 4
    local GSIZE = 5*CELL + 4*PAD  -- 236

    local gridPanel = Instance.new("Frame", mainFrame)
    gridPanel.Size = UDim2.new(0, GSIZE+16, 0, GSIZE+16)
    gridPanel.Position = UDim2.new(0.5, -(GSIZE+16)/2, 0, 88)
    gridPanel.BackgroundColor3 = C_SURF; gridPanel.BorderSizePixel = 0
    Instance.new("UICorner", gridPanel).CornerRadius = UDim.new(0, 8)
    local gpStroke = Instance.new("UIStroke", gridPanel); gpStroke.Color = C_BOR; gpStroke.Thickness = 1

    local gridFrame = Instance.new("Frame", gridPanel)
    gridFrame.Name = "Grid"
    gridFrame.Size = UDim2.new(0, GSIZE, 0, GSIZE)
    gridFrame.Position = UDim2.new(0, 8, 0, 8)
    gridFrame.BackgroundTransparency = 1

    local gridButtons = {}

    -- direction labels
    local dirs = {
        {"↑", UDim2.new(0.5,0,0,-15), Vector2.new(0.5,1)},
        {"↓", UDim2.new(0.5,0,1,15),  Vector2.new(0.5,0)},
        {"←", UDim2.new(0,-3,0.5,0), Vector2.new(1,0.5)},
        {"→", UDim2.new(1,3,0.5,0),  Vector2.new(0,0.5)},
    }
    for _, d in ipairs(dirs) do
        local lbl = Instance.new("TextLabel", gridFrame)
        lbl.Text = d[1]; lbl.Size = UDim2.new(0,14,0,14)
        lbl.Position = d[2]; lbl.AnchorPoint = d[3]
        lbl.BackgroundTransparency = 1; lbl.TextColor3 = C_SUB
        lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 11
    end

    -- 5×5 cells
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
            cell.BorderSizePixel = 0; cell.AutoButtonColor = false
            cell.Font = Enum.Font.GothamBold
            Instance.new("UICorner", cell).CornerRadius = UDim.new(0, 6)
            local cs = Instance.new("UIStroke", cell); cs.Thickness = 1

            if isCenter then
                cell.BackgroundColor3 = C_ACC2
                cell.TextColor3 = C_TXT; cell.TextSize = 18; cell.Text = "🙆‍♂️"
                cs.Color = C_ACC
            else
                local function UpdateCell()
                    if getgenv().AFB_SelectedGrids[key] then
                        cell.BackgroundColor3 = C_SEL; cell.TextColor3 = C_TXT
                        cell.TextSize = 16; cell.Text = "✓"
                        cs.Color = C_SEL2; cs.Thickness = 1.5
                    else
                        cell.BackgroundColor3 = C_CELL; cell.TextColor3 = C_SUB
                        cell.TextSize = 10; cell.Text = ox..","..oy
                        cs.Color = C_BOR; cs.Thickness = 1
                    end
                end
                UpdateCell()

                cell.MouseButton1Click:Connect(function()
                    getgenv().AFB_SelectedGrids[key] = not getgenv().AFB_SelectedGrids[key]
                    UpdateCell()
                    local n = 0
                    for _,v in pairs(getgenv().AFB_SelectedGrids) do if v then n = n+1 end end
                    print("[GridSelector] Grid toggled:", key, "| Total:", n)
                end)
                cell.MouseEnter:Connect(function()
                    if getgenv().AFB_SelectedGrids[key] then
                        cell.BackgroundColor3 = Color3.fromRGB(55,185,105)
                    else
                        cell.BackgroundColor3 = C_CELLHOV
                    end
                end)
                cell.MouseLeave:Connect(function() UpdateCell() end)
                gridButtons[key] = {cell=cell, update=UpdateCell}
            end
        end
    end

    -- ── Separator above buttons ──
    local sep2 = Instance.new("Frame", mainFrame)
    sep2.Size = UDim2.new(1, -20, 0, 1)
    sep2.Position = UDim2.new(0, 10, 0, H - 58)
    sep2.BackgroundColor3 = C_SEP; sep2.BorderSizePixel = 0

    -- ── Quick-select buttons ──
    local function MakeBtn(txt, col)
        local b = Instance.new("TextButton")
        b.BackgroundColor3 = col; b.TextColor3 = C_TXT
        b.Font = Enum.Font.GothamSemibold; b.TextSize = 12
        b.BorderSizePixel = 0; b.AutoButtonColor = false
        b.Text = txt
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
        b.MouseEnter:Connect(function()
            b.BackgroundColor3 = b.BackgroundColor3:Lerp(Color3.new(1,1,1),0.14)
        end)
        b.MouseLeave:Connect(function() b.BackgroundColor3 = col end)
        return b
    end

    local btnRow = Instance.new("Frame", mainFrame)
    btnRow.Size = UDim2.new(1, -20, 0, 36)
    btnRow.Position = UDim2.new(0, 10, 0, H - 48)
    btnRow.BackgroundTransparency = 1

    local btnAll = MakeBtn("✔ Semua", C_ACC)
    btnAll.Size = UDim2.new(1/3, -3, 1, 0); btnAll.Position = UDim2.new(0, 0, 0, 0)
    btnAll.Parent = btnRow

    local btnClr = MakeBtn("✖ Hapus", Color3.fromRGB(175, 48, 48))
    btnClr.Size = UDim2.new(1/3, -3, 1, 0); btnClr.Position = UDim2.new(1/3, 2, 0, 0)
    btnClr.Parent = btnRow

    local btnAtas = MakeBtn("⬆ Atas", Color3.fromRGB(95, 68, 185))
    btnAtas.Size = UDim2.new(1/3, -1, 1, 0); btnAtas.Position = UDim2.new(2/3, 2, 0, 0)
    btnAtas.Parent = btnRow

    btnAll.MouseButton1Click:Connect(function()
        for r=0,4 do for c=0,4 do
            local k = tostring(c-2)..","..tostring(2-r)
            if not (c==2 and r==2) then
                getgenv().AFB_SelectedGrids[k] = true
                if gridButtons[k] then gridButtons[k].update() end
            end
        end end
    end)

    btnClr.MouseButton1Click:Connect(function()
        for k in pairs(getgenv().AFB_SelectedGrids) do
            getgenv().AFB_SelectedGrids[k] = false
            if gridButtons[k] then gridButtons[k].update() end
        end
    end)

    btnAtas.MouseButton1Click:Connect(function()
        for k in pairs(getgenv().AFB_SelectedGrids) do
            getgenv().AFB_SelectedGrids[k] = false
            if gridButtons[k] then gridButtons[k].update() end
        end
        for r=0,4 do for c=0,4 do
            local ox = c-2; local oy = 2-r
            if oy > 0 then
                local k = tostring(ox)..","..tostring(oy)
                getgenv().AFB_SelectedGrids[k] = true
                if gridButtons[k] then gridButtons[k].update() end
            end
        end end
    end)

    return mainFrame
end

-- Ekspor fungsi ke global
getgenv().CreateGridSelectorUI = CreateGridSelectorUI

-- Buat instance awal (opsional, bisa dilakukan nanti)
-- local gridFrame = CreateGridSelectorUI()
-- getgenv().AFGridGui = gridFrame.Parent  (sudah disimpan di dalam fungsi)
