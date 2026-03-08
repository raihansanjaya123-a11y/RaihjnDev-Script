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
-- UI: WORLD SCAN
-- ============================================================
local function ScanWorldDrops()
    local found, seen = {}, {}
    local scanFolders = {"Drops","Gems","Items","WorldDrops","Pickups","Collectibles"}
    for _, fname in ipairs(scanFolders) do
        local folder = workspace:FindFirstChild(fname)
        if folder then
            for _, obj in pairs(folder:GetChildren()) do
                local id = nil
                for _, attrKey in ipairs({"Id","ID","ItemId","item_id","Type"}) do
                    local v = obj:GetAttribute(attrKey)
                    if v and tostring(v) ~= "" then id = tostring(v); break end
                end
                if not id then
                    for _, c in ipairs(obj:GetDescendants()) do
                        if c:IsA("StringValue") and c.Name:lower():find("id") and c.Value ~= "" then
                            id = c.Value; break
                        end
                    end
                end
                if not id then id = obj.Name end
                if id and id ~= "" and not seen[id] then
                    seen[id] = true
                    local count = 0
                    for _, o2 in pairs(folder:GetChildren()) do
                        local oid = o2:GetAttribute("Id") or o2:GetAttribute("ID") or o2:GetAttribute("ItemId") or o2.Name
                        if tostring(oid) == id then count = count + 1 end
                    end
                    table.insert(found, {Id=id, Count=count, Folder=fname})
                end
            end
        end
    end
    table.sort(found, function(a,b) return a.Count > b.Count end)
    return found
end

MiscTab:CreateSection("World Scan")

MiscTab:CreateButton({
    Name="🔍 Scan World Drops Sekarang",
    Callback=function()
        local drops = ScanWorldDrops()
        if #drops == 0 then
            Rayfield:Notify({Title="World Scan", Content="Tidak ada drop ditemukan di world!", Duration=3})
            return
        end
        print("========= WORLD DROPS =========")
        for _, d in ipairs(drops) do
            print(string.format("[%s] %s — %dx", d.Folder, d.Id, d.Count))
        end
        print("Total: "..#drops.." item unik")
        print("================================")
        local msg = ""
        for i = 1, math.min(5, #drops) do
            msg = msg..drops[i].Id.." ×"..drops[i].Count.."\n"
        end
        if #drops > 5 then msg = msg.."(+"..( #drops-5).." lainnya — cek console)" end
        Rayfield:Notify({Title="World Drops ("..#drops.." item)", Content=msg, Duration=8})
    end,
})

MiscTab:CreateButton({
    Name="📤 Kirim World Drops ke Discord",
    Callback=function()
        if not getgenv().WebhookURL or getgenv().WebhookURL == "" then
            Rayfield:Notify({Title="Webhook", Content="Isi URL dulu di tab Webhook!", Duration=3}); return
        end
        local drops = ScanWorldDrops()
        if #drops == 0 then
            Rayfield:Notify({Title="World Scan", Content="Tidak ada drop ditemukan!", Duration=3}); return
        end
        task.spawn(function()
            local msg = "🌍 **WORLD DROPS SCAN**\n"..
                        "👤 `"..LP.Name.."`  |  🎮 `"..game.Name.."`\n\n"
            for i, d in ipairs(drops) do
                msg = msg.."[`"..d.Folder.."`] `"..d.Id.."` — **"..d.Count.."x**\n"
                if i >= 20 then msg = msg.."... dan "..(#drops-20).." item lainnya\n"; break end
            end
            if getgenv().SendWebhook then getgenv().SendWebhook(msg) end
        end)
        Rayfield:Notify({Title="World Scan", Content="Dikirim ke Discord!", Duration=3})
    end,
})

local autoScanMiscEnabled = false
local autoScanMiscLoop    = nil

MiscTab:CreateToggle({
    Name="Auto Scan Tiap 60 Detik",
    CurrentValue=false,
    Flag="AutoWorldScanMiscToggle",
    Callback=function(v)
        autoScanMiscEnabled = v
        if v then
            autoScanMiscLoop = task.spawn(function()
                while autoScanMiscEnabled do
                    task.wait(60)
                    if not autoScanMiscEnabled then break end
                    local drops = ScanWorldDrops()
                    if #drops > 0 and getgenv().WebhookURL and getgenv().WebhookURL ~= "" then
                        local msg = "⏱️ **AUTO SCAN WORLD DROPS**\n"..
                                    "👤 `"..LP.Name.."`\n\n"
                        for i, d in ipairs(drops) do
                            msg = msg.."`"..d.Id.."` — **"..d.Count.."x**\n"
                            if i >= 15 then break end
                        end
                        if getgenv().SendWebhook then getgenv().SendWebhook(msg) end
                    end
                    print("[AutoScan] Scan selesai, "..#drops.." item ditemukan")
                end
            end)
        else
            if autoScanMiscLoop then
                pcall(function() task.cancel(autoScanMiscLoop) end)
                autoScanMiscLoop = nil
            end
        end
    end,
})
