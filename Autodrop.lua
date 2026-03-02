-- ============================================================
-- Auto Drop Seed - Untuk RaihjnDev Loader
-- ============================================================

-- Cari tab yang tersedia (prioritas: AutoFarm, lalu Misc)
local tab = getgenv().RaihjnAutoFarmTab or getgenv().RaihjnMiscTab
if not tab then
    warn("[AutoDrop] Tidak menemukan tab AutoFarm atau Misc, buat tab baru...")
    tab = Rayfield:CreateTab("AutoDrop", nil)
end

local Rayfield = getgenv().Rayfield
if not Rayfield then
    warn("[AutoDrop] Rayfield tidak ditemukan! Pastikan loader dijalankan.")
    return
end

-- ============================================================
-- SERVICES & MODULES
-- ============================================================
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Load InventoryMod dan UIManager (dengan pcall agar aman)
local InventoryMod
pcall(function() InventoryMod = require(RS:WaitForChild("Modules"):WaitForChild("Inventory")) end)

local UIManager
pcall(function() UIManager = require(RS:WaitForChild("Managers"):WaitForChild("UIManager")) end)

-- ============================================================
-- FUNGSI INVENTORY (diadaptasi dari script pabrik)
-- ============================================================
local function GetAllItems()
    local results = {}
    local stacks = nil

    if InventoryMod then
        for _, key in ipairs({"Stacks", "Items", "stacks", "items"}) do
            if type(InventoryMod[key]) == "table" then
                stacks = InventoryMod[key]
                break
            end
        end
        if not stacks then
            for _, m in ipairs({"GetStacks", "GetItems", "GetInventory"}) do
                if type(InventoryMod[m]) == "function" then
                    local ok, d = pcall(function() return InventoryMod[m](InventoryMod) end)
                    if ok and type(d) == "table" then
                        stacks = d
                        break
                    end
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

    -- Backpack fallback
    local bp = LP:FindFirstChildOfClass("Backpack")
    if bp then
        for _, tool in pairs(bp:GetChildren()) do
            if tool:IsA("Tool") then
                local id = tostring(tool:GetAttribute("Id") or tool:GetAttribute("ID") or tool:GetAttribute("ItemId") or tool.Name)
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

-- ============================================================
-- FUNGSI DROP (sama seperti di pabrik)
-- ============================================================
local function DropItemLogic(targetID, dropAmount)
    local slot = GetSlotByItemID(targetID)
    if not slot then return false end

    local dropR = RS:WaitForChild("Remotes"):FindFirstChild("PlayerDrop") or RS:WaitForChild("Remotes"):FindFirstChild("PlayerDropItem")
    local promptR = RS:WaitForChild("Managers"):WaitForChild("UIManager"):FindFirstChild("UIPromptEvent")

    if dropR and promptR then
        pcall(function() dropR:FireServer(slot) end)
        task.wait(0.2)
        pcall(function() promptR:FireServer({ButtonAction = "drp", Inputs = {amt = tostring(dropAmount)}}) end)
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
-- FUNGSI FORCE RESTORE UI
-- ============================================================
local function ForceRestoreUI()
    pcall(function()
        if UIManager then
            if type(UIManager.ClosePrompt) == "function" then UIManager:ClosePrompt() end
            if type(UIManager.ShowHUD) == "function" then UIManager:ShowHUD() end
            if type(UIManager.ShowUI) == "function" then UIManager:ShowUI() end
        end
        if LP and LP.PlayerGui then
            for _, g in pairs(LP.PlayerGui:GetDescendants()) do
                if g:IsA("Frame") and g.Name:lower():find("prompt") then
                    g.Visible = false
                end
            end
        end
    end)
end

-- ============================================================
-- FUNGSI MENGHASILKAN DAFTAR ITEM UNIK UNTUK DROPDOWN
-- ============================================================
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
    return list
end

-- ============================================================
-- UI
-- ============================================================

local DropTab = getgenv().RaihjnAutoDropTab
if not DropTab then
    warn("DropTab not found")
    return
end

local Rayfield = getgenv().Rayfield
if not Rayfield then
    warn("Rayfield not found")
    return
end

tab:CreateSection("Auto Drop Seed")

-- Dropdown pilih seed
local seedOptions = GetUniqueItemList()
local selectedSeed = seedOptions[1] or ""
local seedDropdown = tab:CreateDropdown({
    Name = "Pilih Seed",
    Options = seedOptions,
    CurrentOption = selectedSeed,
    Flag = "AutoDropSeedDropdown",
    Callback = function(opt)
        selectedSeed = opt
        print("[AutoDrop] Seed dipilih:", selectedSeed)
    end
})

-- Slider jumlah drop
local dropAmount = 1
local amountSlider = tab:CreateSlider({
    Name = "Jumlah Drop",
    Range = {1, 200},
    Increment = 1,
    Suffix = "item",
    CurrentValue = 1,
    Flag = "AutoDropAmountSlider",
    Callback = function(val)
        dropAmount = val
    end
})

-- Tombol Drop
tab:CreateButton({
    Name = "Drop Seed Sekarang",
    Callback = function()
        if not selectedSeed or selectedSeed == "" then
            Rayfield:Notify({Title = "AutoDrop", Content = "Pilih seed terlebih dahulu!", Duration = 3})
            return
        end

        local slot = GetSlotByItemID(selectedSeed)
        if not slot then
            Rayfield:Notify({Title = "AutoDrop", Content = "Seed tidak ditemukan di inventory!", Duration = 3})
            return
        end

        local tersedia = GetItemAmountByID(selectedSeed)
        if tersedia < dropAmount then
            Rayfield:Notify({Title = "AutoDrop", Content = string.format("Stok tidak cukup! Tersedia: %d", tersedia), Duration = 3})
            return
        end

        local ok = DropItemLogic(selectedSeed, dropAmount)
        if ok then
            Rayfield:Notify({Title = "AutoDrop", Content = string.format("Berhasil drop %d %s", dropAmount, selectedSeed), Duration = 3})
        else
            Rayfield:Notify({Title = "AutoDrop", Content = "Gagal drop! Cek remote atau inventory.", Duration = 3})
        end
        ForceRestoreUI()
    end
})

-- Tombol Refresh Inventory
tab:CreateButton({
    Name = "🔄 Refresh Daftar Seed",
    Callback = function()
        local newOptions = GetUniqueItemList()
        seedDropdown:Refresh(newOptions, newOptions[1] or "")
        selectedSeed = newOptions[1] or ""
        Rayfield:Notify({Title = "AutoDrop", Content = "Inventory diperbarui", Duration = 2})
    end
})

-- Tombol Test (untuk debug, optional)
tab:CreateButton({
    Name = "Test ForceRestoreUI",
    Callback = function()
        ForceRestoreUI()
        Rayfield:Notify({Title = "AutoDrop", Content = "ForceRestoreUI dijalankan", Duration = 2})
    end
})

print("[AutoDrop] Script berhasil dimuat.")
