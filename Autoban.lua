local Players    = game:GetService("Players")
local LP         = Players.LocalPlayer
local RS         = game:GetService("ReplicatedStorage")

local UIPromptEvent = RS:WaitForChild("Managers"):WaitForChild("UIManager"):WaitForChild("UIPromptEvent")
local PlayerInspect = RS:WaitForChild("Remotes"):WaitForChild("PlayerInspect")

local AutoBanEnabled   = false
local AutoLeaveEnabled = false
local Whitelist        = {}

getgenv().TotalBanned = getgenv().TotalBanned or 0

local ModKeywords = {
    "mod","admin","staff","dev","developer",
    "moderator","helper","support","official"
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
            if type(UIManager.ClosePrompt)=="function" then UIManager:ClosePrompt() end
            if type(UIManager.ShowHUD)=="function"     then UIManager:ShowHUD() end
            if type(UIManager.ShowUI)=="function"      then UIManager:ShowUI() end
        end
        for _, g in pairs(LP.PlayerGui:GetDescendants()) do
            if g:IsA("Frame") and g.Name:lower():find("prompt") then g.Visible=false end
        end
    end)
end

local function BanPlayer(player)
    if player == LP then return end
    for _, name in ipairs(Whitelist) do
        if player.Name:lower() == name:lower() then
            print("[AutoBan] Skip whitelist:", player.Name); return
        end
    end
    print("[AutoBan] Banning:", player.Name)
    local ok1 = pcall(function() PlayerInspect:FireServer(player) end)
    print("[AutoBan] Inspect fired:", ok1)
    task.wait(0.5)
    local banOk = pcall(function()
        UIPromptEvent:FireServer({ButtonAction="ban", Inputs={}})
    end)
    print("[AutoBan] Ban fired:", banOk)
    if not banOk then
        pcall(function() UIPromptEvent:FireServer("ban", player) end)
    end
    task.wait(0.3)
    ForceRestoreUI()
    task.wait(0.2)
    getgenv().TotalBanned = getgenv().TotalBanned + 1
    Rayfield:Notify({Title="Auto Ban", Content="Banned: @"..player.Name, Duration=4})
end

local function IsModOrAdmin(player)
    local nl = player.Name:lower()
    local dl = player.DisplayName:lower()
    for _, kw in ipairs(ModKeywords) do
        if nl:find(kw) or dl:find(kw) then return true, kw end
    end
    return false, nil
end

local function LeaveGame()
    print("[AutoLeave] Mod terdeteksi! Keluar...")
    Rayfield:Notify({Title="AutoLeave", Content="Mod terdeteksi! Keluar...", Duration=3})
    task.wait(1)
    pcall(function() game:GetService("TeleportService"):Teleport(game.PlaceId) end)
end

-- ============================================================
-- MONITOR PLAYER
-- ============================================================
Players.PlayerAdded:Connect(function(player)
    task.wait(5)
    if AutoLeaveEnabled then
        local isMod, kw = IsModOrAdmin(player)
        if isMod then
            print("[AutoLeave] Mod:", player.Name, kw)
            LeaveGame(); return
        end
    end
    if AutoBanEnabled then
        BanPlayer(player)
    end
    ForceRestoreUI()
end)

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

MiscTab:CreateButton({
    Name="🔧 Debug — Cek Drop Objects",
    Callback=function()
        print("========= KEYWORD SCAN =========")
        local keywords = {"wooden","frame","gem","seed","drop","item",
            "sapling","fruit","harvest","crop","loot","pickup","ore","log","stone"}
        local found = 0
        for _, obj in ipairs(workspace:GetDescendants()) do
            local nameLow = obj.Name:lower()
            local matched = false
            for _, kw in ipairs(keywords) do
                if nameLow:find(kw) then matched=true; break end
            end
            if not matched then
                for k, v in pairs(obj:GetAttributes()) do
                    local kl = tostring(k):lower()
                    local vl = tostring(v):lower()
                    for _, kw in ipairs(keywords) do
                        if kl:find(kw) or vl:find(kw) then matched=true; break end
                    end
                    if matched then break end
                end
            end
            if matched then
                print(string.format("[%d] %s | Class=%s | Parent=%s",
                    found, obj.Name, obj.ClassName,
                    obj.Parent and obj.Parent.Name or "?"))
                for k,v in pairs(obj:GetAttributes()) do
                    print("  attr:", k, "=", tostring(v))
                end
                found = found + 1
                if found >= 20 then print("...stop di 20"); break end
            end
        end
        if found == 0 then
            print("Tidak ada! Semua workspace children:")
            for _, obj in ipairs(workspace:GetChildren()) do
                print(" -", obj.Name, obj.ClassName)
            end
        end
        -- Extra: print isi folder Gems secara langsung
        print("--- Folder Gems ---")
        local gemsFolder = workspace:FindFirstChild("Gems")
        if gemsFolder then
            print("Gems children count:", #gemsFolder:GetChildren())
            for i, obj in ipairs(gemsFolder:GetChildren()) do
                print(string.format("  [%d] Name=%s Class=%s", i, obj.Name, obj.ClassName))
                for k,v in pairs(obj:GetAttributes()) do
                    print("    attr:", k, "=", tostring(v))
                end
                for _, c in ipairs(obj:GetChildren()) do
                    print("    child:", c.Name, c.ClassName)
                    for k2,v2 in pairs(c:GetAttributes()) do
                        print("      attr:", k2, "=", tostring(v2))
                    end
                    if c:IsA("StringValue") or c:IsA("IntValue") or c:IsA("NumberValue") then
                        print("      value:", c.Value)
                    end
                end
                if i >= 3 then print("  ...stop di 3"); break end
            end
        else
            print("Folder Gems tidak ada!")
            -- Coba cari folder lain
            for _, obj in ipairs(workspace:GetChildren()) do
                if obj:IsA("Folder") or obj:IsA("Model") then
                    print("Folder/Model:", obj.Name, "#children:", #obj:GetChildren())
                end
            end
        end
        print("Total found:", found)
        print("================================")
        Rayfield:Notify({Title="Debug", Content=found.." object ditemukan!", Duration=4})
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
-- UI: WORLD SCAN
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
    end
    return nil
end

local function GetAmount(obj)
    for _, key in ipairs({"Amount","Amt","Count","Stack","Quantity"}) do
        local v = obj:GetAttribute(key)
        if v then return tonumber(v) or 1 end
    end
    for _, c in ipairs(obj:GetDescendants()) do
        if c:IsA("TextLabel") and tonumber(c.Text) then
            return tonumber(c.Text)
        end
    end
    return 1
end

local function IsSkippable(obj)
    local skipClass = {Terrain=true,Camera=true,Script=true,LocalScript=true,ModuleScript=true,Humanoid=true,Animator=true}
    local skipName  = {Baseplate=true,SpawnLocation=true,HumanoidRootPart=true,Head=true,Torso=true}
    if skipClass[obj.ClassName] then return true end
    if skipName[obj.Name] then return true end
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character and obj:IsDescendantOf(p.Character) then return true end
    end
    return false
end

local function ScanAll()
    local found = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if not IsSkippable(obj) then
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
            for id, data in pairs(result) do
                detectedDrops[id] = data
            end
            task.wait(2)
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
            Rayfield:Notify({Title="World Scan", Content="Belum ada drop.\nAktifkan detector dulu!", Duration=4})
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
            msg = msg..list[i].Id.." x"..list[i].Count.."\n"
        end
        if #list > 5 then msg = msg.."(+"..( #list-5).." lainnya)" end
        Rayfield:Notify({Title="Detected ("..#list..")", Content=msg, Duration=8})
    end,
})

MiscTab:CreateButton({
    Name="🗑️ Reset Hasil Detect",
    Callback=function()
        detectedDrops = {}
        Rayfield:Notify({Title="World Scan", Content="Reset!", Duration=2})
    end,
})

MiscTab:CreateButton({
    Name="📤 Kirim Hasil ke Discord",
    Callback=function()
        if not getgenv().WebhookURL or getgenv().WebhookURL == "" then
            Rayfield:Notify({Title="Webhook", Content="Isi URL dulu!", Duration=3}); return
        end
        local list = GetDetectedList()
        if #list == 0 then
            Rayfield:Notify({Title="World Scan", Content="Belum ada drop!", Duration=3}); return
        end
        task.spawn(function()
            local msg = "🌍 **WORLD DROP SCAN**\n👤 `"..LP.Name.."`  |  🎮 `"..game.Name.."`\n\n"
            for i, d in ipairs(list) do
                msg = msg.."[`"..d.Parent.."`] `"..d.Id.."` — **"..d.Count.."x**\n"
                if i >= 20 then msg = msg.."... dan "..(#list-20).." lainnya\n"; break end
            end
            if getgenv().SendWebhook then getgenv().SendWebhook(msg) end
        end)
        Rayfield:Notify({Title="World Scan", Content="Dikirim!", Duration=3})
    end,
})
