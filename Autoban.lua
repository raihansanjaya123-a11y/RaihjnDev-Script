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
