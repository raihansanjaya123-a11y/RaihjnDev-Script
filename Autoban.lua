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

    -- Step 1: Buka inspect player
    local ok1 = pcall(function() PlayerInspect:FireServer(player) end)
    print("[AutoBan] PlayerInspect fired:", ok1)
    task.wait(0.5)

    -- Step 2: Coba berbagai format ban
    local banOk = false

    -- Format 1: ButtonAction ban
    banOk = pcall(function()
        UIPromptEvent:FireServer({ButtonAction="ban", Inputs={}})
    end)
    print("[AutoBan] Format1 ban:", banOk)
    task.wait(0.3)

    -- Format 2: action ban langsung
    if not banOk then
        banOk = pcall(function()
            UIPromptEvent:FireServer("ban", player)
        end)
        print("[AutoBan] Format2 ban:", banOk)
        task.wait(0.3)
    end

    -- Format 3: nested Inputs
    if not banOk then
        banOk = pcall(function()
            UIPromptEvent:FireServer({action="ban", target=player})
        end)
        print("[AutoBan] Format3 ban:", banOk)
        task.wait(0.3)
    end

    ForceRestoreUI()
    task.wait(0.3)
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

-- DEBUG: cek remote dulu
MiscTab:CreateButton({
    Name="🔧 Debug — Cek Drop Objects",
    Callback=function()
        print("========= SCAN BILLBOARD/DROP =========")
        local count = 0
        for _, obj in ipairs(workspace:GetDescendants()) do
            -- Cari object yang punya BillboardGui (item drop punya angka di atasnya)
            if obj:IsA("BillboardGui") then
                print("[BillboardGui]", obj:GetFullName(), "| Parent:", obj.Parent and obj.Parent.ClassName or "?")
                -- Print semua text di dalamnya
                for _, c in ipairs(obj:GetDescendants()) do
                    if c:IsA("TextLabel") then
                        print("  TextLabel:", c.Text)
                    end
                end
                -- Print attribute parent
                if obj.Parent then
                    for k, v in pairs(obj.Parent:GetAttributes()) do
                        print("  Attr:", k, "=", v)
                    end
                    print("  ParentName:", obj.Parent.Name)
                    print("  ParentClass:", obj.Parent.ClassName)
                end
                count = count + 1
                if count >= 10 then print("... (lebih dari 10, stop)"); break end
            end
        end
        if count == 0 then
            print("Tidak ada BillboardGui ditemukan!")
            -- Fallback: print semua children workspace
            print("--- workspace children ---")
            for _, obj in ipairs(workspace:GetChildren()) do
                print(obj.Name, obj.ClassName)
            end
        end
        print("=======================================")
        Rayfield:Notify({Title="Debug Drop", Content="Cek console! ("..count.." billboard)", Duration=4})
    end,
})
    Callback=function()
        print("========= REMOTES =========")
        -- Cek RS.Remotes
        local remotes = RS:FindFirstChild("Remotes")
        if remotes then
            for _, r in pairs(remotes:GetChildren()) do
                print("[Remotes]", r.Name, r.ClassName)
            end
        end
        -- Cek RS.Managers
        local managers = RS:FindFirstChild("Managers")
        if managers then
            for _, m in pairs(managers:GetDescendants()) do
                if m:IsA("RemoteEvent") or m:IsA("RemoteFunction") then
                    print("[Managers]", m:GetFullName(), m.ClassName)
                end
            end
        end
        -- Print semua remote di RS
        for _, obj in pairs(RS:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                print("[RS]", obj:GetFullName())
            end
        end
        print("===========================")
        Rayfield:Notify({Title="Debug", Content="Cek console untuk list remotes!", Duration=4})
    end,
})

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
-- UI: WORLD SCAN (Polling — detect object yang sudah ada di workspace)
-- ============================================================

local detectedDrops  = {}
local scanLoopThread = nil
local scanActive     = false

local function GetItemId(obj)
    for _, key in ipairs({"Id","ID","ItemId","item_id","Type","ItemName","ItemType"}) do
        local v = obj:GetAttribute(key)
        if v and tostring(v) ~= "" then return tostring(v) end
    end
    for _, c in ipairs(obj:GetChildren()) do
        if c:IsA("StringValue") and c.Value ~= "" then return c.Value end
        if c:IsA("IntValue") or c:IsA("NumberValue") then
            -- Kemungkinan amount
        end
    end
    return nil
end

local function GetAmount(obj)
    for _, key in ipairs({"Amount","Amt","Count","Stack","Quantity"}) do
        local v = obj:GetAttribute(key)
        if v then return tonumber(v) or 1 end
    end
    -- Cek BillboardGui dengan angka (seperti yang keliatan di screenshot)
    for _, c in ipairs(obj:GetDescendants()) do
        if c:IsA("TextLabel") and tonumber(c.Text) then
            return tonumber(c.Text)
        end
    end
    return 1
end

local skipClasses = {
    Terrain=true, Camera=true, Script=true, LocalScript=true,
    ModuleScript=true, Sky=true, Atmosphere=true, Lighting=true,
}
local skipNames = {
    Baseplate=true, SpawnLocation=true, HumanoidRootPart=true,
    Head=true, Torso=true, LeftArm=true, RightArm=true,
    LeftLeg=true, RightLeg=true, ["Left Arm"]=true, ["Right Arm"]=true,
    ["Left Leg"]=true, ["Right Leg"]=true,
}

local function ScanAll()
    local found = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if skipClasses[obj.ClassName] then continue end
        if skipNames[obj.Name] then continue end
        -- Skip kalau parent adalah karakter player
        local parentIsChar = false
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character and obj:IsDescendantOf(p.Character) then
                parentIsChar = true; break
            end
        end
        if parentIsChar then continue end

        local id = GetItemId(obj)
        if id then
            local amt = GetAmount(obj)
            local parent = obj.Parent and obj.Parent.Name or "workspace"
            if not found[id] then
                found[id] = {Id=id, Count=0, Parent=parent}
            end
            found[id].Count = found[id].Count + amt
        end
    end
    return found
end

local function StartScan()
    if scanLoopThread then return end
    scanActive = true
    detectedDrops = {}
    print("[WorldScan] Polling aktif...")

    scanLoopThread = task.spawn(function()
        while scanActive do
            local result = ScanAll()
            -- Merge ke detectedDrops
            for id, data in pairs(result) do
                detectedDrops[id] = data
            end
            task.wait(2) -- scan tiap 2 detik
        end
    end)
end

local function StopScan()
    scanActive = false
    if scanLoopThread then
        pcall(function() task.cancel(scanLoopThread) end)
        scanLoopThread = nil
    end
    print("[WorldScan] Polling dimatikan.")
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
            StartScan()
            Rayfield:Notify({Title="World Scan", Content="Polling aktif! Scan tiap 2 detik.", Duration=4})
        else
            StopScan()
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
        Rayfield:Notify({Title="Detected ("..#list.." item)", Content=msg, Duration=8})
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
            local msg = "🌍 **WORLD DROP SCAN**\n"..
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
