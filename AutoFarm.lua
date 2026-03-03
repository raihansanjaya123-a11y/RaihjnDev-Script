-- ============================================================
-- AUTO FARM + AUTO DROP - CAW (EFISIEN: PLACE/BREAK DARI POSISI)
-- ============================================================

-- CLEANUP (hapus instance sebelumnya)
if getgenv().AFBlockWindow then
    pcall(function() getgenv().AFBlockWindow:Destroy() end)
    getgenv().AFBlockWindow = nil
end
if getgenv().AFBlockHeartbeat then
    getgenv().AFBlockHeartbeat:Disconnect()
    getgenv().AFBlockHeartbeat = nil
end
if getgenv().AFBlockLoop then
    pcall(function() task.cancel(getgenv().AFBlockLoop) end)
    getgenv().AFBlockLoop = nil
end
if getgenv().AFGridGui then
    pcall(function() getgenv().AFGridGui:Destroy() end)
    getgenv().AFGridGui = nil
end

-- ============================================================
-- SERVICES
-- ============================================================
local Players      = game:GetService("Players")
local LP           = Players.LocalPlayer
local RS           = game:GetService("ReplicatedStorage")
local RunService   = game:GetService("RunService")
local VirtualUser  = game:GetService("VirtualUser")
local UIS          = game:GetService("UserInputService")

-- ============================================================
-- LOAD GRID SELECTOR EKSTERNAL
-- ============================================================
local function LoadGridSelector()
    local success, result = pcall(function()
        local content = game:HttpGet('https://raw.githubusercontent.com/raihansanjaya123-a11y/RaihjnDev-Script/main/GridAF.lua')
        local func = loadstring(content)
        if func then
            func()
            print("✅ Grid Selector loaded")
        else
            warn("❌ Gagal mengkompilasi GridSelector")
        end
    end)
    if not success then
        warn("❌ Error memuat GridSelector:", result)
    end
end
LoadGridSelector()

-- ============================================================
-- ANTI-AFK
-- ============================================================
LP.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- ============================================================
-- CONFIG
-- ============================================================
getgenv().AFB_GridSize     = 4.5
getgenv().AFB_Enabled      = false
getgenv().AFB_SelectedGrids = {}

getgenv().AFB_HitCount      = 3
getgenv().AFB_BreakDelay    = 0.15
getgenv().AFB_StepDelay     = 0.1
getgenv().AFB_PlaceDelay    = 0.15
getgenv().AFB_PlaceHitCount = 1
getgenv().AFB_AutoCollect   = true
getgenv().AFB_SeedOnly      = false
getgenv().AFB_LockedItem    = nil
getgenv().AFB_LockedSlot    = nil
getgenv().AFB_CycleDelay    = 0.3
getgenv().AFB_CycleCount    = 0
getgenv().AFB_TotalBroken   = 0
getgenv().AFB_IsGhosting    = false
getgenv().AFB_HoldCFrame    = nil
getgenv().AFB_DropKeepAmount = 0

-- ============================================================
-- MODULES
-- ============================================================
local PlayerMovement
pcall(function() PlayerMovement = require(LP.PlayerScripts:WaitForChild("PlayerMovement")) end)

local InventoryMod
pcall(function() InventoryMod = require(RS:WaitForChild("Modules"):WaitForChild("Inventory")) end)

local UIManager
pcall(function() UIManager = require(RS:WaitForChild("Managers"):WaitForChild("UIManager")) end)

-- ============================================================
-- REMOTES
-- ============================================================
local RemoteBreak = RS:WaitForChild("Remotes"):WaitForChild("PlayerFist")
local RemotePlace = RS:WaitForChild("Remotes"):WaitForChild("PlayerPlaceItem")
local RemoteDrop  = RS:WaitForChild("Remotes"):FindFirstChild("PlayerDrop") or RS:WaitForChild("Remotes"):FindFirstChild("PlayerDropItem")
local RemotePrompt = RS:WaitForChild("Managers"):WaitForChild("UIManager"):FindFirstChild("UIPromptEvent")

-- ============================================================
-- FUNGSI INVENTORY
-- ============================================================
local function GetAllItems()
    local results = {}
    local stacks  = nil
    if InventoryMod then
        for _, key in ipairs({"Stacks", "Items", "stacks", "items"}) do
            if type(InventoryMod[key]) == "table" then
                stacks = InventoryMod[key]; break
            end
        end
        if not stacks then
            for _, m in ipairs({"GetStacks", "GetItems", "GetInventory"}) do
                if type(InventoryMod[m]) == "function" then
                    local ok, d = pcall(function() return InventoryMod[m](InventoryMod) end)
                    if ok and type(d) == "table" then stacks = d; break end
                end
            end
        end
    end
    if stacks then
        for slotIndex, data in pairs(stacks) do
            if type(data) == "table" then
                local id = data.Id or data.ItemId or data.item_id or data.ID
                if id then
                    local amt = tonumber(data.Amount or data.Amt or data.Count or 1) or 1
                    table.insert(results, {Slot = slotIndex, Id = tostring(id), Amount = amt})
                end
            end
        end
    end
    local bp = LP:FindFirstChildOfClass("Backpack")
    if bp then
        for _, tool in pairs(bp:GetChildren()) do
            if tool:IsA("Tool") then
                local id  = tostring(tool:GetAttribute("Id") or tool:GetAttribute("ID") or tool:GetAttribute("ItemId") or tool.Name)
                local amt = tonumber(tool:GetAttribute("Amount") or 1) or 1
                table.insert(results, {Slot = tool.Name, Id = id, Amount = amt})
            end
        end
    end
    return results
end

local function GetSlotByItemID(targetID)
    if not targetID or targetID == "" then return nil end
    targetID = tostring(targetID)
    for _, item in ipairs(GetAllItems()) do
        if item.Id == targetID and item.Amount > 0 then
            return item.Slot
        end
    end
    return nil
end

local function GetItemAmountByID(targetID)
    if not targetID or targetID == "" then return 0 end
    targetID = tostring(targetID)
    local total = 0
    for _, item in ipairs(GetAllItems()) do
        if item.Id == targetID then
            total = total + item.Amount
        end
    end
    return total
end

local function GetUniqueItemList()
    local items = GetAllItems()
    local seen = {}
    local list = {}
    for _, item in ipairs(items) do
        if not seen[item.Id] then
            seen[item.Id] = true
            table.insert(list, item.Id)
        end
    end
    table.sort(list)
    if #list == 0 then list = {"Kosong"} end
    return list
end

-- ============================================================
-- FUNGSI DROP
-- ============================================================
local function DropItemLogic(targetID, dropAmt)
    local slot = GetSlotByItemID(targetID)
    if not slot then return false end
    if RemoteDrop and RemotePrompt then
        pcall(function() RemoteDrop:FireServer(slot) end)
        task.wait(0.2)
        pcall(function() RemotePrompt:FireServer({ButtonAction = "drp", Inputs = {amt = tostring(dropAmt)}}) end)
        task.wait(0.1)
        pcall(function()
            for _, g in pairs(LP.PlayerGui:GetDescendants()) do
                if g:IsA("Frame") and g.Name:lower():find("prompt") then
                    g.Visible = false
                end
            end
        end)
        return true
    end
    return false
end

-- ============================================================
-- FORCE RESTORE UI
-- ============================================================
local function ForceRestoreUI()
    pcall(function()
        if UIManager and type(UIManager.ClosePrompt) == "function" then UIManager:ClosePrompt() end
        for _, gui in pairs(LP.PlayerGui:GetDescendants()) do
            if gui:IsA("Frame") and string.find(string.lower(gui.Name), "prompt") then
                gui.Visible = false
            end
        end
    end)
    task.wait(0.1)
    pcall(function()
        if UIManager then
            if type(UIManager.ShowHUD) == "function" then UIManager:ShowHUD() end
            if type(UIManager.ShowUI) == "function" then UIManager:ShowUI() end
        end
    end)
    pcall(function()
        local targetUIs = { "topbar", "gems", "playerui", "hotbar", "crosshair", "mainhud", "stats", "inventory", "backpack", "menu", "bottombar", "buttons" }
        for _, gui in pairs(LP.PlayerGui:GetDescendants()) do
            if gui:IsA("Frame") or gui:IsA("ScreenGui") or gui:IsA("ImageLabel") then
                local gName = string.lower(gui.Name)
                for _, tName in ipairs(targetUIs) do
                    if string.find(gName, tName) and not string.find(gName, "prompt") then
                        if gui:IsA("ScreenGui") then
                            gui.Enabled = true
                        else
                            gui.Visible = true
                        end
                    end
                end
            end
        end
    end)
    pcall(function()
        for _, gui in pairs(LP.PlayerGui:GetDescendants()) do
            if gui:IsA("TextButton") and string.find(string.lower(gui.Text), "drop") then
                if gui.Parent then gui.Parent.Visible = true end
            end
        end
    end)
    print("✅ ForceRestoreUI selesai")
end

-- ============================================================
-- RESOLVE OPTION (UNTUK DROPDOWN)
-- ============================================================
local function ResolveOption(opt)
    if type(opt) == "string" then return opt end
    if type(opt) == "table" then
        if type(opt[1]) == "string" and opt[1] ~= "" then return opt[1] end
        for _, k in ipairs({"Id","Name","Value","name","value","id"}) do
            if type(opt[k]) == "string" and opt[k] ~= "" then return opt[k] end
        end
        for _, v in pairs(opt) do
            if type(v) == "string" and v ~= "" then return v end
        end
    end
    return tostring(opt)
end

-- ============================================================
-- GET HELD ITEM ID (UNTUK GRID SELECTOR)
-- ============================================================
local function GetHeldItemID()
    if not InventoryMod then return nil end
    if type(InventoryMod.GetSelectedHotbarItem) == "function" then
        local ok, result = pcall(function() return InventoryMod:GetSelectedHotbarItem() end)
        if ok and result ~= nil then
            if type(result) == "table" then
                local id = result.Id or result.ItemId or result.item_id or result.ID or result.id
                if id then return tostring(id) end
            elseif type(result) == "string" then
                return result
            end
        end
    end
    -- Fallback sederhana
    local char = LP.Character
    if char then
        for _, child in pairs(char:GetChildren()) do
            if child:IsA("Tool") then
                local id = child:GetAttribute("Id") or child:GetAttribute("ID") or child:GetAttribute("ItemId")
                if id then return tostring(id) end
                return child.Name
            end
        end
    end
    return nil
end
getgenv().GetHeldItemID = GetHeldItemID

-- ============================================================
-- HITBOX & MOVEMENT
-- ============================================================
local function GetMyHitbox()
    local h = workspace:FindFirstChild("Hitbox")
    return h and h:FindFirstChild(LP.Name)
end

local function GetMyPosition()
    local h = GetMyHitbox()
    if not h then return 0, 0 end
    return math.floor(h.Position.X / getgenv().AFB_GridSize + 0.5),
           math.floor(h.Position.Y / getgenv().AFB_GridSize + 0.5)
end

local function SetHitBoxPos(x, y)
    local h = GetMyHitbox()
    if not h then return end
    local pos = Vector3.new(x * getgenv().AFB_GridSize, y * getgenv().AFB_GridSize, h.Position.Z)
    h.CFrame = CFrame.new(pos)
    if PlayerMovement then
        pcall(function()
            PlayerMovement.Position    = pos
            PlayerMovement.OldPosition = pos
            PlayerMovement.VelocityX   = 0
            PlayerMovement.VelocityY   = 0
            PlayerMovement.VelocityZ   = 0
            PlayerMovement.Grounded    = true
        end)
    end
end

local function WalkToGrid(targetX, targetY)
    local cx, cy = GetMyPosition()
    while cx ~= targetX or cy ~= targetY do
        if not getgenv().AFB_Enabled then break end
        if cx ~= targetX then
            cx = cx + (targetX > cx and 1 or -1)
        else
            cy = cy + (targetY > cy and 1 or -1)
        end
        SetHitBoxPos(cx, cy)
        task.wait(getgenv().AFB_StepDelay)
    end
    SetHitBoxPos(targetX, targetY)
end

-- ============================================================
-- GHOSTING
-- ============================================================
getgenv().AFBlockHeartbeat = RunService.Heartbeat:Connect(function()
    if getgenv().AFB_IsGhosting and getgenv().AFB_HoldCFrame then
        local c = LP.Character
        if c and c:FindFirstChild("HumanoidRootPart") then
            c.HumanoidRootPart.CFrame = getgenv().AFB_HoldCFrame
        end
        if PlayerMovement then
            pcall(function()
                PlayerMovement.VelocityX = 0
                PlayerMovement.VelocityY = 0
                PlayerMovement.VelocityZ = 0
                PlayerMovement.Grounded  = true
                PlayerMovement.Jumping   = false
            end)
        end
    end
end)

local function StartGhost()
    local char = LP.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    local mh   = GetMyHitbox()
    local state = {
        hrp  = hrp, hum = hum, mh = mh,
        eCF  = hrp and hrp.CFrame,
        eHCF = mh and mh.CFrame,
        ePM  = nil,
    }
    if PlayerMovement then
        pcall(function() state.ePM = PlayerMovement.Position end)
    end
    if hrp then
        hrp.Anchored = true
        getgenv().AFB_HoldCFrame = state.eCF
        getgenv().AFB_IsGhosting = true
    end
    if hum then
        local anim   = hum:FindFirstChildOfClass("Animator")
        local tracks = anim and anim:GetPlayingAnimationTracks() or hum:GetPlayingAnimationTracks()
        for _, t in ipairs(tracks) do t:Stop(0) end
    end
    return state
end

local function StopGhost(state)
    if state.hrp and state.eCF then
        state.hrp.AssemblyLinearVelocity  = Vector3.zero
        state.hrp.AssemblyAngularVelocity = Vector3.zero
        if state.mh and state.eHCF then
            state.mh.CFrame = state.eHCF
            state.mh.AssemblyLinearVelocity = Vector3.zero
        end
        state.hrp.CFrame = state.eCF
        if PlayerMovement and state.ePM then
            pcall(function()
                PlayerMovement.Position    = state.ePM
                PlayerMovement.OldPosition = state.ePM
                PlayerMovement.VelocityX   = 0
                PlayerMovement.VelocityY   = 0
                PlayerMovement.VelocityZ   = 0
                PlayerMovement.Grounded    = true
            end)
        end
        RunService.Heartbeat:Wait()
        RunService.Heartbeat:Wait()
        state.hrp.Anchored = false
    end
    getgenv().AFB_IsGhosting = false
end

-- ============================================================
-- DROP DETECTION
-- ============================================================
local function GetDropsAtGrid(gx, gy)
    local drops = {}
    for _, fname in ipairs({"Drops", "Gems"}) do
        local folder = workspace:FindFirstChild(fname)
        if folder then
            for _, obj in pairs(folder:GetChildren()) do
                local pos
                if obj:IsA("BasePart") then
                    pos = obj.Position
                elseif obj:IsA("Model") then
                    local p = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                    if p then pos = p.Position end
                end
                if pos then
                    local dx = math.floor(pos.X / getgenv().AFB_GridSize + 0.5)
                    local dy = math.floor(pos.Y / getgenv().AFB_GridSize + 0.5)
                    if dx == gx and dy == gy then
                        table.insert(drops, obj)
                    end
                end
            end
        end
    end
    return drops
end

local function HasDropsAtGrid(gx, gy)
    return #GetDropsAtGrid(gx, gy) > 0
end

local function IsSeedDrop(obj)
    local name = obj.Name:lower()
    if name:find("seed") then return true end
    for attrName, attrVal in pairs(obj:GetAttributes()) do
        local valStr = tostring(attrVal):lower()
        if valStr:find("seed") then return true end
        if tostring(attrName):lower():find("seed") then return true end
    end
    for _, c in ipairs(obj:GetDescendants()) do
        if c:IsA("StringValue") and c.Value:lower():find("seed") then return true end
        if c.Name:lower():find("seed") then return true end
    end
    return false
end

local function HasSeedDropAtGrid(gx, gy)
    local drops = GetDropsAtGrid(gx, gy)
    for _, drop in ipairs(drops) do
        if IsSeedDrop(drop) then return true end
    end
    return false
end

-- ============================================================
-- CORE: BREAK BLOCK
-- ============================================================
local function DoBreak(gx, gy)
    local v2 = Vector2.new(gx, gy)
    for _ = 1, getgenv().AFB_HitCount do
        if not getgenv().AFB_Enabled then break end
        pcall(function() RemoteBreak:FireServer(v2) end)
        task.wait(getgenv().AFB_BreakDelay)
    end
end

-- ============================================================
-- CORE: PLACE BLOCK
-- ============================================================
local function DoPlace(gx, gy, slot)
    if not slot then
        print("[DoPlace] ⚠️ Slot nil, skip place di", gx, gy)
        return
    end
    local v2 = Vector2.new(gx, gy)
    for i = 1, getgenv().AFB_PlaceHitCount do
        if not getgenv().AFB_Enabled then break end
        pcall(function() RemotePlace:FireServer(v2, slot) end)
        task.wait(getgenv().AFB_PlaceDelay)
    end
end
-- ============================================================
-- GET SELECTED OFFSETS (dari AFB_SelectedGrids)
-- ============================================================
local function GetSelectedOffsets()
    local offsets = {}
    for key, v in pairs(getgenv().AFB_SelectedGrids) do
        if v then
            local ox, oy = key:match("^(-?%d+),(-?%d+)$")
            ox = tonumber(ox)
            oy = tonumber(oy)
            if ox and oy then
                table.insert(offsets, {ox = ox, oy = oy})
            end
        end
    end
    table.sort(offsets, function(a, b)
        if a.oy ~= b.oy then return a.oy > b.oy end
        return a.ox < b.ox
    end)
    return offsets
end

-- ============================================================
-- MAIN LOOP (EFISIEN: PLACE/BREAK DARI POSISI)
-- ============================================================
getgenv().AFBlockLoop = task.spawn(function()
    while true do
        task.wait(0.2)
        if not getgenv().AFB_Enabled then continue end

        local offsets = GetSelectedOffsets()
        if #offsets == 0 then
            print("[AutoFarm] Tidak ada grid yang dipilih! Buka Grid Selector.")
            task.wait(3)
            continue
        end

        local cx, cy = GetMyPosition()
        print("[AutoFarm] ⛏️ Siklus", getgenv().AFB_CycleCount + 1, "| Posisi:", cx, cy, "| Grid:", #offsets)

        -- Update slot item yang di-lock
        local heldItem = getgenv().AFB_LockedItem
        local heldSlot = nil
        if heldItem then
            heldSlot = GetSlotByItemID(heldItem)  -- update setiap siklus
            if heldSlot then
                getgenv().AFB_LockedSlot = heldSlot
                print("[AutoFarm] 🔒 Block locked:", heldItem, "| Slot:", heldSlot)
            else
                print("[AutoFarm] ⚠️ Item", heldItem, "habis, skip place")
            end
        else
            print("[AutoFarm] ⚠️ Block belum di-lock! Pilih block dari dropdown.")
        end

        local gs = StartGhost()

        -- ========== FASE 1: PLACE (TANPA BERGERAK) ==========
        if heldSlot then
            print("[AutoFarm] 🧱 FASE 1: Placing di", #offsets, "tile...")
            for _, offset in ipairs(offsets) do
                if not getgenv().AFB_Enabled then break end
                DoPlace(cx + offset.ox, cy + offset.oy, heldSlot)
            end
        else
            print("[AutoFarm] ⚠️ Tidak ada block, skip place")
        end

        -- ========== FASE 2: BREAK (TANPA BERGERAK) ==========
        print("[AutoFarm] ⛏️ FASE 2: Breaking semua tile...")
        for _, offset in ipairs(offsets) do
            if not getgenv().AFB_Enabled then break end
            DoBreak(cx + offset.ox, cy + offset.oy)
            getgenv().AFB_TotalBroken = getgenv().AFB_TotalBroken + 1
        end

        -- ========== FASE 3: COLLECT (BERJALAN KE TILE) ==========
        if getgenv().AFB_Enabled and getgenv().AFB_AutoCollect then
            print("[AutoFarm] 📦 FASE 3: Collecting drops...")
            for _, offset in ipairs(offsets) do
                if not getgenv().AFB_Enabled then break end
                local tx = cx + offset.ox
                local ty = cy + offset.oy
                local shouldCollect = getgenv().AFB_SeedOnly and HasSeedDropAtGrid(tx, ty) or HasDropsAtGrid(tx, ty)
                if shouldCollect then
                    WalkToGrid(tx, ty)  -- jalan ke tile
                    local t = 0
                    while HasDropsAtGrid(tx, ty) and t < 10 and getgenv().AFB_Enabled do
                        task.wait(0.1)
                        t = t + 1
                    end
                end
            end
            -- Sweep balik
            for i = #offsets, 1, -1 do
                if not getgenv().AFB_Enabled then break end
                local tx = cx + offsets[i].ox
                local ty = cy + offsets[i].oy
                if HasDropsAtGrid(tx, ty) then
                    WalkToGrid(tx, ty)
                    task.wait(0.1)
                end
            end
            WalkToGrid(cx, cy)  -- kembali ke posisi awal
        end

        StopGhost(gs)

        getgenv().AFB_CycleCount = getgenv().AFB_CycleCount + 1
        print("[AutoFarm] ✅ Siklus", getgenv().AFB_CycleCount, "selesai! Total broken:", getgenv().AFB_TotalBroken)

        if getgenv().AFB_Enabled and getgenv().AFB_CycleDelay > 0 then
            task.wait(getgenv().AFB_CycleDelay)
        end
    end
end)

local Rayfield = getgenv().Rayfield
if not Rayfield then
    warn("Rayfield not found")
    return
end

local FarmTab = getgenv().RaihjnAutoFarmTab
if not FarmTab then
    warn("FarmTab not found")
    return
end

FarmTab:CreateSection("Farm Delay")
FarmTab:CreateInput({Name="Hit Count", PlaceholderText="3", RemoveTextAfterFocusLost=false,
    Callback=function(t) local n=tonumber(t); if n then getgenv().AFB_HitCount=n end end})
FarmTab:CreateInput({Name="Break Delay (s)", PlaceholderText="0.15", RemoveTextAfterFocusLost=false,
    Callback=function(t) local n=tonumber(t); if n then getgenv().AFB_BreakDelay=n end end})
FarmTab:CreateInput({Name="Step Delay (s)", PlaceholderText="0.1", RemoveTextAfterFocusLost=false,
    Callback=function(t) local n=tonumber(t); if n then getgenv().AFB_StepDelay=n end end})
FarmTab:CreateInput({Name="Cycle Delay (s)", PlaceholderText="0.3", RemoveTextAfterFocusLost=false,
    Callback=function(t) local n=tonumber(t); if n then getgenv().AFB_CycleDelay=n end end})
FarmTab:CreateInput({Name="Place Delay (s)", PlaceholderText="0.15", RemoveTextAfterFocusLost=false,
    Callback=function(t) local n=tonumber(t); if n then getgenv().AFB_PlaceDelay=n end end})

FarmTab:CreateButton({
    Name = "🍀 Pilih Tile Mana Yang Mau Di Farm 🍀",
    Callback = function()
        if getgenv().CreateGridSelectorUI then
            getgenv().CreateGridSelectorUI()
        else
            warn("Grid selector tidak tersedia, coba muat ulang")
            LoadGridSelector()
            task.wait(1)
            if getgenv().CreateGridSelectorUI then
                getgenv().CreateGridSelectorUI()
            end
        end
    end,
})

FarmTab:CreateSection("Farm Utama")

local blockOptions = GetUniqueItemList()
local selectedBlock = blockOptions[1] or ""
local blockDropdown = FarmTab:CreateDropdown({
    Name = "Pilih Block / Item",
    Options = blockOptions,
    CurrentOption = selectedBlock,
    Flag = "AFB_BlockDropdown",
    Callback = function(opt)
        local id = ResolveOption(opt)
        local slot = GetSlotByItemID(id)
        if slot then
            getgenv().AFB_LockedItem = id
            getgenv().AFB_LockedSlot = slot
            print("[AutoFarm] 🔒 Block dipilih:", id, "| Slot:", slot)
            Rayfield:Notify({Title="Block Selected", Content=id, Duration=3})
        else
            warn("[AutoFarm] Slot tidak ditemukan untuk block:", id)
            Rayfield:Notify({Title="Error", Content="Block tidak tersedia", Duration=3})
        end
    end,
})

FarmTab:CreateButton({
    Name = "🔄 Refresh Daftar Block 🔄",
    Callback = function()
        local newOptions = GetUniqueItemList()
        blockDropdown:Refresh(newOptions, newOptions[1] or "")
        selectedBlock = newOptions[1] or ""
        print("[AutoFarm] Daftar block direfresh, ditemukan", #newOptions, "item")
        Rayfield:Notify({Title="Refresh", Content="Daftar block diperbarui", Duration=2})
    end,
})

FarmTab:CreateToggle({
    Name         = "Enable Auto Farm Block",
    CurrentValue = false,
    Flag         = "AFB_EnableToggle",
    Callback     = function(v)
        getgenv().AFB_Enabled = v
        print("[AutoFarm] Enabled:", v)
        Rayfield:Notify({Title="Auto Farm Block", Content=v and "⛏️ Farm AKTIF!" or "Farm NONAKTIF", Duration=3})
    end,
})

FarmTab:CreateToggle({
    Name         = "Seed Only 🌱",
    CurrentValue = false,
    Flag         = "AFB_SeedOnlyToggle",
    Callback     = function(v)
        getgenv().AFB_SeedOnly = v
        Rayfield:Notify({Title="Seed Filter", Content=v and "🌱 Hanya SEED" or "📦 Semua drops", Duration=3})
    end,
})

-- ========================
-- SECTION: AUTO DROP
-- ========================
FarmTab:CreateSection("Auto Drop")

local dropAmount = 1
FarmTab:CreateSlider({
    Name         = "Jumlah Drop",
    Range        = {1, 200},
    Increment    = 1,
    Suffix       = " item",
    CurrentValue = 1,
    Flag         = "DropAmountSlider",
    Callback     = function(val) dropAmount = val end,
})

FarmTab:CreateInput({
    Name                     = "Keep Amount (sisakan berapa)",
    PlaceholderText          = "0 = drop semua",
    RemoveTextAfterFocusLost = false,
    Callback                 = function(t)
        local n = tonumber(t)
        if n then getgenv().AFB_DropKeepAmount = n end
    end,
})

FarmTab:CreateButton({
    Name     = "💧 Drop Sekarang",
    Callback = function()
        local item = getgenv().AFB_LockedItem
        if not item or item == "" or item == "Kosong" then
            Rayfield:Notify({Title="AutoDrop", Content="Pilih item dulu!", Duration=3})
            return
        end
        local tersedia = GetItemAmountByID(item)
        local toDrop = dropAmount
        if getgenv().AFB_DropKeepAmount > 0 then
            toDrop = math.max(0, tersedia - getgenv().AFB_DropKeepAmount)
        end
        if toDrop <= 0 then
            Rayfield:Notify({Title="AutoDrop", Content="Tidak ada yang perlu di-drop", Duration=3})
            return
        end
        print("[Drop] Dropping", toDrop, "x", item)
        local ok = DropItemLogic(item, toDrop)
        if ok then
            Rayfield:Notify({Title="Drop OK", Content=toDrop.."x "..item, Duration=3})
        else
            Rayfield:Notify({Title="Drop Gagal", Content="Cek inventory/slot", Duration=3})
        end
        ForceRestoreUI()
    end,
})

FarmTab:CreateButton({
    Name     = "⬇️ Drop Sampai Sisa Keep Amount",
    Callback = function()
        local item = getgenv().AFB_LockedItem
        if not item or item == "" or item == "Kosong" then
            Rayfield:Notify({Title="AutoDrop", Content="Pilih item dulu!", Duration=3})
            return
        end
        local dropped = 0
        while true do
            local cur = GetItemAmountByID(item)
            local toDrop = cur - getgenv().AFB_DropKeepAmount
            if toDrop <= 0 then break end
            local ok = DropItemLogic(item, math.min(toDrop, 200))
            if not ok then break end
            dropped = dropped + math.min(toDrop, 200)
            task.wait(0.8)
        end
        ForceRestoreUI()
        Rayfield:Notify({Title="Selesai", Content="Total drop: "..dropped, Duration=4})
    end,
})

-- ============================================================
-- LOADED NOTIFICATION
-- ============================================================
Rayfield:Notify({Title="⛏️ Auto Farm + Auto Drop", Content="Script loaded!\n1. Pilih block/item\n2. Pilih tile\n3. Enable farm atau drop", Duration=7})
print("✅ [AutoFarm+Drop] Siap digunakan.")
