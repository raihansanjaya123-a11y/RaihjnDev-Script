local Players    = game:GetService("Players")
local LP         = Players.LocalPlayer
local RS         = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Remotes
local UIPromptEvent    = RS:WaitForChild("Managers"):WaitForChild("UIManager"):WaitForChild("UIPromptEvent")
local PlayerInspect    = RS:WaitForChild("Remotes"):WaitForChild("PlayerInspectPlayer")

-- ============================================================
-- CONFIG
-- ============================================================
local AutoBanEnabled   = false
local AutoLeaveEnabled = false
local Whitelist        = {}  -- username yang tidak di-ban

-- Daftar keyword nama mod/admin (tambah sendiri)
local ModKeywords = {
    "mod", "admin", "staff", "dev", "developer",
    "moderator", "helper", "support", "official"
}

-- ============================================================
-- FUNGSI BAN
-- ============================================================
local function BanPlayer(player)
    if player == LP then return end  -- jangan ban diri sendiri
    
    -- Cek whitelist
    for _, name in ipairs(Whitelist) do
        if player.Name:lower() == name:lower() then
            print("[AutoBan] Skip (whitelist):", player.Name)
            return
        end
    end

    print("[AutoBan] Banning:", player.Name)
    
    -- Step 1: Open player inspect (set target)
    pcall(function() PlayerInspect:FireServer(player) end)
    task.wait(0.3)
    
    -- Step 2: Fire ban
    pcall(function()
        UIPromptEvent:FireServer({
            ButtonAction = "ban",
            Inputs       = {}
        })
    end)
    
    task.wait(0.5)
    Rayfield:Notify({
        Title   = "Auto Ban",
        Content = "Banned: @"..player.Name,
        Duration = 4,
    })
end

-- ============================================================
-- FUNGSI CEK MOD
-- ============================================================
local function IsModOrAdmin(player)
    local nameLower = player.Name:lower()
    for _, keyword in ipairs(ModKeywords) do
        if nameLower:find(keyword) then return true, keyword end
    end
    -- Cek badge/rank dari DisplayName juga
    local displayLower = player.DisplayName:lower()
    for _, keyword in ipairs(ModKeywords) do
        if displayLower:find(keyword) then return true, keyword end
    end
    return false, nil
end

local function LeaveGame()
    print("[AutoLeave] Mod/Admin terdeteksi! Keluar...")
    Rayfield:Notify({
        Title   = "AutoLeave",
        Content = "Mod terdeteksi! Keluar dari world...",
        Duration = 3,
    })
    task.wait(1)
    -- Teleport ke menu / leave server
    local TeleportService = game:GetService("TeleportService")
    pcall(function()
        TeleportService:Teleport(game.PlaceId)
    end)
end

-- ============================================================
-- MONITOR PLAYER MASUK
-- ============================================================
Players.PlayerAdded:Connect(function(player)
    task.wait(5)  -- tunggu player fully loaded
    
    -- Cek mod dulu
    if AutoLeaveEnabled then
        local isMod, keyword = IsModOrAdmin(player)
        if isMod then
            print("[AutoLeave] Mod detected:", player.Name, "(keyword:", keyword..")")
            LeaveGame()
            return
        end
    end
    
    -- Auto ban
    if AutoBanEnabled then
        print("[AutoBan] Player masuk:", player.Name)
        BanPlayer(player)
    end
end)

-- Cek player yang sudah ada di server saat script load
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LP then
        if AutoLeaveEnabled then
            local isMod = IsModOrAdmin(player)
            if isMod then LeaveGame(); break end
        end
    end
end

-- ============================================================
-- UI
-- ============================================================
local MiscTab = getgenv().RaihjnTab

MiscTab:CreateSection("Auto Ban")

MiscTab:CreateToggle({
    Name         = "Auto Ban (ban semua yang masuk)",
    CurrentValue = false,
    Flag         = "AutoBanToggle",
    Callback     = function(v)
        AutoBanEnabled = v
        print("[Config] AutoBan =", v)
    end,
})

MiscTab:CreateButton({
    Name     = "Ban Semua Sekarang",
    Callback = function()
        local count = 0
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LP then
                BanPlayer(player)
                task.wait(0.8)
                count = count + 1
            end
        end
        Rayfield:Notify({Title="Ban Selesai", Content="Banned "..count.." player", Duration=4})
    end,
})

MiscTab:CreateInput({
    Name                     = "Whitelist (username, pisah koma)",
    PlaceholderText          = "Contoh: friend1,friend2",
    RemoveTextAfterFocusLost = false,
    Callback                 = function(text)
        Whitelist = {}
        for name in text:gmatch("[^,]+") do
            local trimmed = name:match("^%s*(.-)%s*$")
            if trimmed ~= "" then
                table.insert(Whitelist, trimmed)
                print("[Whitelist] Added:", trimmed)
            end
        end
        Rayfield:Notify({Title="Whitelist", Content=#Whitelist.." player di-whitelist", Duration=3})
    end,
})

MiscTab:CreateSection("Auto Mod Detector")

MiscTab:CreateToggle({
    Name         = "Auto Leave jika Mod Masuk",
    CurrentValue = false,
    Flag         = "AutoLeaveToggle",
    Callback     = function(v)
        AutoLeaveEnabled = v
        print("[Config] AutoLeave =", v)
    end,
})

MiscTab:CreateButton({
    Name     = "Cek Player Di Server Sekarang",
    Callback = function()
        local list = ""
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LP then
                local isMod, kw = IsModOrAdmin(p)
                list = list .. "@"..p.Name..(isMod and " [MOD:"..kw.."]" or "").."\n"
            end
        end
        if list == "" then list = "Tidak ada player lain" end
        print("[PlayerList]\n"..list)
        Rayfield:Notify({Title="Player Di Server", Content=list, Duration=8})
    end,
})