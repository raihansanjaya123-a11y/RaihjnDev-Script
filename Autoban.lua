local Players    = game:GetService("Players")
local LP         = Players.LocalPlayer
local RS         = game:GetService("ReplicatedStorage")

-- ============================================================
-- REMOTES
-- ============================================================
local UIPromptEvent = RS:WaitForChild("Managers"):WaitForChild("UIManager"):WaitForChild("UIPromptEvent")
local PlayerInspect = RS:WaitForChild("Remotes"):WaitForChild("PlayerInspectPlayer")

-- ============================================================
-- CONFIG
-- ============================================================
local AutoBanEnabled   = false
local AutoLeaveEnabled = false
local Whitelist        = {}

getgenv().TotalBanned = getgenv().TotalBanned or 0

local ModKeywords = {
    "mod", "admin", "staff", "dev", "developer",
    "moderator", "helper", "support", "official"
}

local UIManager
pcall(function() UIManager = require(RS:WaitForChild("Managers"):WaitForChild("UIManager")) end)

local Rayfield = getgenv().Rayfield
if not Rayfield then warn("Rayfield not found"); return end

local MiscTab = getgenv().RaihjnMiscTab
if not MiscTab then warn("RaihjnMiscTab not found"); return end

-- ============================================================
-- FUNGSI BANTU
-- ============================================================
local function ForceRestoreUI()
    pcall(function()
        if UIManager then
            if type(UIManager.ClosePrompt) == "function" then UIManager:ClosePrompt() end
            if type(UIManager.ShowHUD)     == "function" then UIManager:ShowHUD() end
            if type(UIManager.ShowUI)      == "function" then UIManager:ShowUI() end
        end
        for _, g in pairs(LP.PlayerGui:GetDescendants()) do
            if g:IsA("Frame") and g.Name:lower():find("prompt") then g.Visible = false end
        end
    end)
end

local function BanPlayer(player)
    if player == LP then return end
    for _, name in ipairs(Whitelist) do
        if player.Name:lower() == name:lower() then
            print("[AutoBan] Skip (whitelist):", player.Name); return
        end
    end
    print("[AutoBan] Banning:", player.Name)
    pcall(function() PlayerInspect:FireServer(player) end)
    task.wait(0.3)
    pcall(function()
        UIPromptEvent:FireServer({ButtonAction="ban", Inputs={}})
        ForceRestoreUI()
    end)
    task.wait(0.5)
    getgenv().TotalBanned = getgenv().TotalBanned + 1
    Rayfield:Notify({Title="Auto Ban", Content="Banned: @"..player.Name, Duration=4})
end

local function IsModOrAdmin(player)
    local nameLower    = player.Name:lower()
    local displayLower = player.DisplayName:lower()
    for _, keyword in ipairs(ModKeywords) do
        if nameLower:find(keyword) or displayLower:find(keyword) then
            return true, keyword
        end
    end
    return false, nil
end

local function LeaveGame()
    print("[AutoLeave] Mod/Admin terdeteksi! Keluar...")
    Rayfield:Notify({Title="AutoLeave", Content="Mod terdeteksi! Keluar dari world...", Duration=3})
    task.wait(1)
    pcall(function() game:GetService("TeleportService"):Teleport(game.PlaceId) end)
end

-- ============================================================
-- MONITOR PLAYER MASUK
-- ============================================================
Players.PlayerAdded:Connect(function(player)
    task.wait(5)
    if AutoLeaveEnabled then
        local isMod, keyword = IsModOrAdmin(player)
        if isMod then
            print("[AutoLeave] Mod detected:", player.Name, "(keyword:", keyword..")")
            LeaveGame(); return
        end
    end
    if AutoBanEnabled then
        print("[AutoBan] Player masuk:", player.Name)
        BanPlayer(player)
    end
    ForceRestoreUI()
end)

-- Cek player yang sudah ada
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LP and AutoLeaveEnabled then
        local isMod = IsModOrAdmin(player)
        if isMod then LeaveGame(); break end
    end
end

-- ============================================================
-- UI: AUTO BAN
-- ============================================================
MiscTab:CreateSection("Auto Ban")

MiscTab:CreateToggle({
    Name="Auto Ban (ban semua yang masuk)", CurrentValue=false, Flag="AutoBanToggle",
    Callback=function(v) AutoBanEnabled=v; print("[Config] AutoBan =", v) end,
})

MiscTab:CreateButton({
    Name="Ban Semua Sekarang",
    Callback=function()
        local count = 0
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LP then
                BanPlayer(player); task.wait(0.8); count=count+1
            end
        end
        Rayfield:Notify({Title="Ban Selesai", Content="Banned "..count.." player", Duration=4})
    end,
})

MiscTab:CreateInput({
    Name="Whitelist (username, pisah koma)", PlaceholderText="Contoh: friend1,friend2",
    RemoveTextAfterFocusLost=false,
    Callback=function(text)
        Whitelist = {}
        for name in text:gmatch("[^,]+") do
            local trimmed = name:match("^%s*(.-)%s*$")
            if trimmed ~= "" then table.insert(Whitelist, trimmed) end
        end
        Rayfield:Notify({Title="Whitelist", Content=#Whitelist.." player di-whitelist", Duration=3})
    end,
})

-- ============================================================
-- UI: AUTO MOD DETECTOR
-- ============================================================
MiscTab:CreateSection("Auto Mod Detector")

MiscTab:CreateToggle({
    Name="Auto Leave jika Mod Masuk", CurrentValue=false, Flag="AutoLeaveToggle",
    Callback=function(v) AutoLeaveEnabled=v; print("[Config] AutoLeave =", v) end,
})

MiscTab:CreateButton({
    Name="Cek Player Di Server Sekarang",
    Callback=function()
        local list = ""
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LP then
                local isMod, kw = IsModOrAdmin(p)
                list = list.."@"..p.Name..(isMod and " [MOD:"..kw.."]" or "").."\n"
            end
        end
        if list == "" then list = "Tidak ada player lain" end
        print("[PlayerList]\n"..list)
        Rayfield:Notify({Title="Player Di Server", Content=list, Duration=8})
    end,
})

-- ============================================================
-- UI: WORLD SCAN (Real-time DescendantAdded detector)
-- ============================================================

-- Simpan semua drop yang kedetect
local detectedDrops = {}
local dropListener  = nil
local scanActive    = false

local function GetItemId(obj)
    -- Cek attribute
    for _, key in ipairs({"Id","ID","ItemId","item_id","Type","ItemName"}) do
        local v = obj:GetAttribute(key)
        if v and tostring(v) ~= "" then return tostring(v) end
    end
    -- Cek StringValue anak langsung
    for _, c in ipairs(obj:GetChildren()) do
        if c:IsA("StringValue") and c.Value ~= "" then
            return c.Value
        end
    end
    return nil
end

local function IsLikelyDrop(obj)
    -- Harus BasePart atau Model
    if not (obj:IsA("BasePart") or obj:IsA("Model") or obj:IsA("MeshPart")) then
        return false
    end
    -- Skip object game yang pasti bukan drop
    local skipNames = {
        "Baseplate","SpawnLocation","Terrain","Camera",
        "HumanoidRootPart","Head","Torso","LeftArm","RightArm","LeftLeg","RightLeg"
    }
    for _, n in ipairs(skipNames) do
        if obj.Name == n then return false end
    end
    -- Harus punya attribute item ATAU parent-nya folder drop
    local hasAttr = GetItemId(obj) ~= nil
    local parentIsDropFolder = false
    if obj.Parent then
        local pname = obj.Parent.Name:lower()
        for _, keyword in ipairs({"drop","gem","item","pickup","collect","loot"}) do
            if pname:find(keyword) then parentIsDropFolder = true; break end
        end
    end
    return hasAttr or parentIsDropFolder
end

local function StartDropDetector()
    if dropListener then return end
    detectedDrops = {}
    scanActive = true
    print("[WorldScan] Detector aktif, memantau workspace...")

    dropListener = workspace.DescendantAdded:Connect(function(obj)
        if not scanActive then return end
        task.wait(0.1) -- tunggu attribute ter-load

        if not IsLikelyDrop(obj) then return end

        local id = GetItemId(obj) or obj.Name
        local parent = obj.Parent and obj.Parent.Name or "workspace"

        -- Catat ke detected list
        if not detectedDrops[id] then
            detectedDrops[id] = {Id=id, Count=0, Parent=parent, LastObj=obj}
        end
        detectedDrops[id].Count = detectedDrops[id].Count + 1
        detectedDrops[id].LastObj = obj

        print(string.format("[WorldScan] DROP DETECTED: %s ×%d (parent: %s)",
            id, detectedDrops[id].Count, parent))
    end)
end

local function StopDropDetector()
    scanActive = false
    if dropListener then
        dropListener:Disconnect()
        dropListener = nil
    end
    print("[WorldScan] Detector dimatikan.")
end

local function GetDetectedList()
    local list = {}
    for _, d in pairs(detectedDrops) do
        table.insert(list, d)
    end
    table.sort(list, function(a,b) return a.Count > b.Count end)
    return list
end

MiscTab:CreateSection("World Scan")

MiscTab:CreateToggle({
    Name="🔴 Aktifkan Drop Detector",
    CurrentValue=false,
    Flag="WorldScanToggle",
    Callback=function(v)
        if v then
            StartDropDetector()
            Rayfield:Notify({Title="World Scan", Content="Detector aktif! Drop akan ter-log di console.", Duration=4})
        else
            StopDropDetector()
            Rayfield:Notify({Title="World Scan", Content="Detector dimatikan.", Duration=3})
        end
    end,
})

MiscTab:CreateButton({
    Name="📋 Lihat Hasil Detect",
    Callback=function()
        local list = GetDetectedList()
        if #list == 0 then
            Rayfield:Notify({Title="World Scan", Content="Belum ada drop terdeteksi.\nAktifkan detector dulu!", Duration=4})
            return
        end
        print("========= DETECTED DROPS =========")
        for _, d in ipairs(list) do
            print(string.format("[%s] %s — %dx", d.Parent, d.Id, d.Count))
        end
        print("Total: "..#list.." item unik")
        print("==================================")
        local msg = ""
        for i = 1, math.min(5, #list) do
            msg = msg..list[i].Id.." ×"..list[i].Count.."\n"
        end
        if #list > 5 then msg = msg.."(+"..( #list-5).." lainnya — cek console)" end
        Rayfield:Notify({Title="Detected Drops ("..#list..")", Content=msg, Duration=8})
    end,
})

MiscTab:CreateButton({
    Name="🗑️ Reset Hasil Detect",
    Callback=function()
        detectedDrops = {}
        Rayfield:Notify({Title="World Scan", Content="Hasil detect direset!", Duration=2})
    end,
})

MiscTab:CreateButton({
    Name="📤 Kirim Hasil ke Discord",
    Callback=function()
        if not getgenv().WebhookURL or getgenv().WebhookURL == "" then
            Rayfield:Notify({Title="Webhook", Content="Isi URL dulu di tab Webhook!", Duration=3}); return
        end
        local list = GetDetectedList()
        if #list == 0 then
            Rayfield:Notify({Title="World Scan", Content="Belum ada drop terdeteksi!", Duration=3}); return
        end
        task.spawn(function()
            local msg = "🌍 **WORLD DROP DETECTOR**\n"..
                        "👤 `"..LP.Name.."`  |  🎮 `"..game.Name.."`\n\n"
            for i, d in ipairs(list) do
                msg = msg.."[`"..d.Parent.."`] `"..d.Id.."` — **"..d.Count.."x**\n"
                if i >= 20 then msg = msg.."... dan "..(#list-20).." lainnya\n"; break end
            end
            if getgenv().SendWebhook then getgenv().SendWebhook(msg) end
        end)
        Rayfield:Notify({Title="World Scan", Content="Dikirim ke Discord!", Duration=3})
    end,
})
