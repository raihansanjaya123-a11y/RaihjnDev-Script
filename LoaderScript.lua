local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
getgenv().Rayfield = Rayfield

-- ============================================================
-- WEBHOOK URL (diisi di sini atau via UI tab Webhook)
-- ============================================================
getgenv().WebhookURL = getgenv().WebhookURL or ""

-- ============================================================
-- LOAD SCRIPT HELPER (dengan error handling lebih baik)
-- ============================================================
local function LoadScriptFromUrl(url, scriptName)
    local success, result = pcall(function()
        print("[Loader] Mengambil script:", scriptName)
        local content = game:HttpGet(url)
        
        -- Cek apakah HTML (error 404)
        if content:sub(1, 5) == "<html" then
            error("URL mengembalikan HTML (mungkin 404). Cek URL: " .. url)
        end
        
        -- Kompilasi
        local func, err = loadstring(content)
        if not func then
            error("Gagal kompilasi: " .. tostring(err))
        end
        
        -- Jalankan
        print("[Loader] Menjalankan script:", scriptName)
        local execSuccess, execErr = pcall(func)
        if not execSuccess then
            error("Error saat menjalankan script: " .. tostring(execErr))
        end
        
        print("[Loader] ✅ Sukses:", scriptName)
    end)
    
    if not success then
        warn("❌ Loader error [" .. scriptName .. "]: " .. tostring(result))
    end
end

-- ============================================================
-- SERVICES (TETAP)
-- ============================================================
local RS      = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LP      = Players.LocalPlayer

local UIManager
pcall(function()
    UIManager = require(RS:WaitForChild("Managers"):WaitForChild("UIManager"))
end)

local function ForceRestoreUI()
    pcall(function()
        if UIManager and type(UIManager.ClosePrompt) == "function" then UIManager:ClosePrompt() end
        for _, gui in pairs(LP.PlayerGui:GetDescendants()) do
            if gui:IsA("Frame") and string.find(string.lower(gui.Name), "prompt") then gui.Visible = false end
        end
    end)
    task.wait(0.1)
    pcall(function()
        if UIManager then
            if type(UIManager.ShowHUD) == "function" then UIManager:ShowHUD() end
            if type(UIManager.ShowUI)  == "function" then UIManager:ShowUI() end
        end
    end)
    pcall(function()
        local targetUIs = {"topbar","gems","playerui","hotbar","crosshair","mainhud","stats","inventory","backpack","menu","bottombar","buttons"}
        for _, gui in pairs(LP.PlayerGui:GetDescendants()) do
            if gui:IsA("Frame") or gui:IsA("ScreenGui") or gui:IsA("ImageLabel") then
                local gName = string.lower(gui.Name)
                for _, tName in ipairs(targetUIs) do
                    if string.find(gName, tName) and not string.find(gName, "prompt") then
                        if gui:IsA("ScreenGui") then gui.Enabled = true else gui.Visible = true end
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
end

-- ============================================================
-- WEBHOOK SENDER (TETAP SAMA PERSIS)
-- ============================================================
local HttpService
pcall(function() HttpService = game:GetService("HttpService") end)

local function GetPlayerName()
    local ok, name = pcall(function()
        return game:GetService("Players").LocalPlayer.Name
    end)
    return ok and name or "Unknown"
end

-- Reset queue setiap inject supaya tidak numpuk
local webhookQueue   = {}
local webhookRunning = false
getgenv()._webhookQueue   = webhookQueue
getgenv()._webhookRunning = false

local function ProcessQueue()
    if getgenv()._webhookRunning then return end
    getgenv()._webhookRunning = true
    task.spawn(function()
        while #webhookQueue > 0 do
            local payload = table.remove(webhookQueue, 1)
            local url = getgenv().WebhookURL
            if url and url ~= "" and HttpService then
                pcall(function()
                    local body = HttpService:JSONEncode(payload)
                    local ok1 = pcall(function()
                        if syn and syn.request then
                            syn.request({
                                Url     = url,
                                Method  = "POST",
                                Headers = {["Content-Type"] = "application/json"},
                                Body    = body,
                            })
                        else error("no syn") end
                    end)
                    if not ok1 then
                        pcall(function()
                            local fn = http and http.request or request
                            fn({
                                Url     = url,
                                Method  = "POST",
                                Headers = {["Content-Type"] = "application/json"},
                                Body    = body,
                            })
                        end)
                    end
                end)
            end
            task.wait(1.5) -- jeda antar pesan, hindari rate limit Discord
        end
        getgenv()._webhookRunning = false
    end)
end

getgenv().SendWebhook = function(data)
    if not HttpService then return end
    if not getgenv().WebhookURL or getgenv().WebhookURL == "" then return end

    local payload = {}

    if type(data) == "string" then
        payload = {
            content  = data,
            username = "CAW | " .. GetPlayerName(),
        }
    elseif type(data) == "table" then
        local embed = {
            title       = data.title or "",
            description = data.description or nil,
            color       = data.color or 0x5865F2,
            fields      = data.fields or {},
            footer      = data.footer and {text = data.footer} or nil,
        }
        -- Hapus key nil supaya JSON bersih
        if not embed.description then embed.description = nil end
        if not embed.footer      then embed.footer      = nil end

        payload = {
            content  = data.content or nil,
            embeds   = {embed},
            username = data.username or ("CAW | " .. GetPlayerName()),
        }
    end

    table.insert(webhookQueue, payload)
    ProcessQueue()
end

-- ============================================================
-- WINDOW (TETAP)
-- ============================================================
local Window = Rayfield:CreateWindow({
    Name             = "Craft A World",
    Icon             = 0,
    LoadingTitle     = "RaihjnDev",
    LoadingSubtitle  = "by RaihjnDev | Rayfield UI",
    ShowText         = "RaihjnDev",
    Theme            = "Ocean",
    ToggleUIKeybind  = "K",
    DisableRayfieldPrompts  = true,
    DisableBuildWarnings    = false,
    ConfigurationSaving = {
        Enabled    = false,
        FolderName = nil,
        FileName   = "RaihjnDev Index"
    },
    Discord = {
        Enabled      = true,
        Invite       = "Me7FKdQdSp",
        RememberJoins = true
    },
    KeySystem = false,
    KeySettings = {
        Title    = "RaihjnDev",
        Subtitle = "by RaihjnDev",
        Note     = "Join Discord to get key",
        FileName = "RaihjnDev | Key",
        SaveKey  = false,
        GrabKeyFromSite = true,
        Key = {"https://raw.githubusercontent.com/raihansanjaya123-a11y/RaihjnDev-Script/refs/heads/main/Key"}
    }
})

-- ============================================================
-- TAB: PABRIK
-- ============================================================
local MainTab = Window:CreateTab("Pabrik", nil)
getgenv().RaihjnTab = MainTab

LoadScriptFromUrl(
    'https://raw.githubusercontent.com/raihansanjaya123-a11y/RaihjnDev-Script/main/PabrikRaihjn.lua',
    'PabrikRaihjn'
)

-- ============================================================
-- TAB: AUTO FARM
-- ============================================================
local AutoFarmTab = Window:CreateTab("AutoFarm", nil)
getgenv().RaihjnAutoFarmTab = AutoFarmTab

LoadScriptFromUrl(
    'https://raw.githubusercontent.com/raihansanjaya123-a11y/RaihjnDev-Script/main/AutoFarm.lua',
    'AutoFarm'
)

-- ============================================================
-- TAB: MISC
-- ============================================================
local MiscTab = Window:CreateTab("Misc", nil)
getgenv().RaihjnMiscTab = MiscTab

LoadScriptFromUrl(
    'https://raw.githubusercontent.com/raihansanjaya123-a11y/RaihjnDev-Script/main/Autoban.lua',
    'AutoBan'
)

-- ============================================================
-- TAB: WEBHOOK (TETAP SAMA)
-- ============================================================
local WebhookTab = Window:CreateTab("Webhook", nil)
getgenv().RaihjnWebhookTab = WebhookTab

WebhookTab:CreateSection("Discord Webhook")

WebhookTab:CreateInput({
    Name                     = "Webhook URL",
    PlaceholderText          = "https://discord.com/api/webhooks/...",
    RemoveTextAfterFocusLost = false,
    Callback = function(t)
        t = t:gsub("%s+", "")  -- hapus spasi
        if t ~= "" then
            getgenv().WebhookURL = t
            Rayfield:Notify({Title="Webhook", Content="URL tersimpan!", Duration=3})
            print("[Webhook] URL set:", t:sub(1, 40).."...")
        end
    end,
})

WebhookTab:CreateButton({
    Name     = "🔔 Test Webhook",
    Callback = function()
        local url = getgenv().WebhookURL
        if not url or url == "" then
            Rayfield:Notify({Title="Webhook", Content="Isi URL dulu!", Duration=3})
            return
        end
        task.spawn(function()
            getgenv().SendWebhook({
                title       = "✅ Test Webhook Berhasil!",
                color       = 0x5865F2,  -- biru discord
                description = "Koneksi webhook dari script kamu berjalan dengan baik.",
                fields      = {
                    {name="👤 Player", value=LP.Name,    inline=true},
                    {name="🎮 Game",   value=game.Name,  inline=true},
                },
                footer = "RaihjnDev • CAW Script",
            })
        end)
        Rayfield:Notify({Title="Webhook", Content="Test dikirim ke Discord!", Duration=3})
    end,
})

WebhookTab:CreateSection("Stats Pabrik")

WebhookTab:CreateButton({
    Name     = "📊 Lihat Stats Pabrik",
    Callback = function()
        local cycle = getgenv().CycleCount or 0
        local total = getgenv().TotalDropAllTime or 0
        local seed  = getgenv().SelectedSeed or "?"
        local msg   = "Cycle: "..cycle.."\nTotal Drop: "..total.."\nSeed: "..seed
        Rayfield:Notify({Title="Stats Pabrik", Content=msg, Duration=6})
        print("[Stats]", msg)
    end,
})

WebhookTab:CreateButton({
    Name     = "📤 Kirim Stats ke Discord",
    Callback = function()
        local url = getgenv().WebhookURL
        if not url or url == "" then
            Rayfield:Notify({Title="Webhook", Content="Isi URL dulu!", Duration=3}); return
        end
        task.spawn(function()
            getgenv().SendWebhook({
                title       = "📊 Stats Manual Report",
                color       = 0xEB459E,  -- pink
                fields      = {
                    {name="👤 Player",              value=LP.Name,                                        inline=true},
                    {name="🎮 Game",                value=game.Name,                                      inline=true},
                    {name="\u200b",                 value="\u200b",                                       inline=false},
                    {name="🏭 Pabrik — Cycle",      value=tostring(getgenv().CycleCount or 0),            inline=true},
                    {name="📦 Pabrik — Total Drop",  value=tostring(getgenv().TotalDropAllTime or 0).."x", inline=true},
                    {name="🌿 Pabrik — Seed",        value=tostring(getgenv().SelectedSeed or "?"),        inline=true},
                    {name="\u200b",                 value="\u200b",                                       inline=false},
                    {name="⛏️ AutoFarm — Cycle",    value=tostring(getgenv().AFB_CycleCount or 0),        inline=true},
                    {name="🧱 AutoFarm — Broken",   value=tostring(getgenv().AFB_TotalBroken or 0),       inline=true},
                },
                footer = "RaihjnDev • CAW Script",
            })
        end)
        Rayfield:Notify({Title="Webhook", Content="Stats dikirim!", Duration=3})
    end,
})

WebhookTab:CreateButton({
    Name     = "🔁 Reset Stats Pabrik",
    Callback = function()
        getgenv().TotalDropAllTime = 0
        getgenv().CycleCount       = 0
        Rayfield:Notify({Title="Stats", Content="Reset!", Duration=2})
    end,
})

-- ============================================================
-- CLEANUP (TETAP)
-- ============================================================
local function CleanupAll()
    -- Stop Pabrik
    getgenv().EnablePabrik    = false
    getgenv().PabrikIsRunning = false

    -- Hentikan heartbeat pabrik
    if getgenv().RaihjnHeartbeatPabrik then
        pcall(function() getgenv().RaihjnHeartbeatPabrik:Disconnect() end)
        getgenv().RaihjnHeartbeatPabrik = nil
    end

    -- Stop AutoFarm
    getgenv().AFB_Enabled = false

    if getgenv().AFBlockHeartbeat then
        pcall(function() getgenv().AFBlockHeartbeat:Disconnect() end)
        getgenv().AFBlockHeartbeat = nil
    end
    if getgenv().AFBlockLoop then
        pcall(function() task.cancel(getgenv().AFBlockLoop) end)
        getgenv().AFBlockLoop = nil
    end

    -- Stop ghosting
    getgenv().IsGhosting     = false
    getgenv().HoldCFrame     = nil
    getgenv().AFB_IsGhosting = false
    getgenv().AFB_HoldCFrame = nil

    -- Unanchor karakter kalau masih ke-anchor
    pcall(function()
        local char = LP.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.Anchored = false end
        end
    end)

    -- Destroy GUI sisa (GridSelector dll)
    if getgenv().AFGridGui then
        pcall(function() getgenv().AFGridGui:Destroy() end)
        getgenv().AFGridGui = nil
    end

    print("[Exit] Semua script dihentikan.")
end

-- ============================================================
-- TAB: SETTINGS
-- ============================================================
local SettingsTab = Window:CreateTab("Settings", nil)
getgenv().RaihjnSettingsTab = SettingsTab

SettingsTab:CreateButton({
    Name     = "Reset UI",
    Callback = function()
        ForceRestoreUI()
        Rayfield:Notify({Title="Reset UI", Content="UI reset successfully", Duration=3})
    end,
})

SettingsTab:CreateButton({
    Name     = "🛑 Exit & Stop Semua Script",
    Callback = function()
        CleanupAll()
        pcall(function() Rayfield:Destroy() end)
    end, 
})
