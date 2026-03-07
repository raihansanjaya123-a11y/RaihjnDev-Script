local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
getgenv().Rayfield = Rayfield

-- ============================================================
-- WEBHOOK LOGIC (sederhana, tanpa embed)
-- ============================================================
local HttpService
pcall(function() HttpService = game:GetService("HttpService") end)

getgenv().WebhookURL = getgenv().WebhookURL or ""

local webhookQueue = {}
local webhookRunning = false

local function ProcessWebhookQueue()
    if webhookRunning then return end
    webhookRunning = true
    task.spawn(function()
        while #webhookQueue > 0 do
            local payload = table.remove(webhookQueue, 1)
            local url = getgenv().WebhookURL
            if url and url ~= "" and HttpService then
                pcall(function()
                    local body = HttpService:JSONEncode(payload)
                    local requestFunc = syn and syn.request or http and http.request or request
                    if requestFunc then
                        requestFunc({
                            Url = url,
                            Method = "POST",
                            Headers = {["Content-Type"] = "application/json"},
                            Body = body,
                        })
                    end
                end)
            end
            task.wait(1.5) -- jeda antar pengiriman
        end
        webhookRunning = false
    end)
end

getgenv().SendWebhook = function(message)
    if not HttpService or not getgenv().WebhookURL or getgenv().WebhookURL == "" then return end
    local payload = {
        content = message,
        username = "RaihjnDev Bot",
    }
    table.insert(webhookQueue, payload)
    ProcessWebhookQueue()
end

local function LoadScriptFromUrl(url, scriptName)
    local success, result = pcall(function()
        local content = game:HttpGet(url)
        if content:sub(1, 5) == "<html" then
            error("URL mengembalikan HTML, bukan script. Periksa URL.")
        end
        local func = loadstring(content)
        if func then
            func()
            print("Berhasil memuat script: " .. scriptName)
        else
            warn("Gagal mengkompilasi script: " .. scriptName)
            print("Cuplikan konten (200 karakter pertama):")
            print(content:sub(1, 200))
        end
    end)
    if not success then
        warn("Error memuat script: " .. scriptName .. " - " .. tostring(result))
    end
end

local RS = game:GetService("ReplicatedStorage")
local Players   = game:GetService("Players")
local LP        = Players.LocalPlayer
local UIManager 
local success, err = pcall(function() 
    UIManager = require(RS:WaitForChild("Managers"):WaitForChild("UIManager")) 
end)
if success then
    print("UIManager loaded successfully")
else
    warn("Error loading UIManager: " .. tostring(err))
end

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

local Window = Rayfield:CreateWindow({
   Name = "Craft A World",
   Icon = 0,
   LoadingTitle = "RaihjnDev",
   LoadingSubtitle = "by RaihjnDev | Rayfield UI",
   ShowText = "RaihjnDev",
   Theme = "Ocean",
   ToggleUIKeybind = "K",
   DisableRayfieldPrompts = true,
   DisableBuildWarnings = false,
   ConfigurationSaving = {
      Enabled = false,
      FolderName = nil,
      FileName = "RaihjnDev Index"
   },
   Discord = {
      Enabled = true,
      Invite = "Me7FKdQdSp",
      RememberJoins = true
   },
   KeySystem = false,
   KeySettings = {
      Title = "RaihjnDev",
      Subtitle = "by RaihjnDev",
      Note = "Join Discord to get key",
      FileName = "RaihjnDev | Key",
      SaveKey = false,
      GrabKeyFromSite = true,
      Key = {"https://raw.githubusercontent.com/raihansanjaya123-a11y/RaihjnDev-Script/refs/heads/main/Key"}
   }
})

-- ============================================================
-- TAB: PABRIK
-- ============================================================
local MainTab = Window:CreateTab("Pabrik", nil)
getgenv().RaihjnTab = MainTab

local scriptPabrik = {
    {Name = "PabrikRaihjn", url = 'https://raw.githubusercontent.com/raihansanjaya123-a11y/RaihjnDev-Script/main/PabrikRaihjn.lua'}
}
for i,v in pairs(scriptPabrik) do
    LoadScriptFromUrl(v.url, v.Name)
end

-- ============================================================
-- TAB: AUTO FARM
-- ============================================================
local AutoFarmTab = Window:CreateTab("AutoFarm", nil)
getgenv().RaihjnAutoFarmTab = AutoFarmTab

local scriptAutoFarm = {
    {Name = "AutoFarm", url = 'https://raw.githubusercontent.com/raihansanjaya123-a11y/RaihjnDev-Script/main/AutoFarm.lua'}
}
for i,v in pairs(scriptAutoFarm) do
    LoadScriptFromUrl(v.url, v.Name)
end

-- ============================================================
-- TAB: MISC
-- ============================================================
local MiscTab = Window:CreateTab("Misc", nil)
getgenv().RaihjnMiscTab = MiscTab

local scriptMisc = {
    {Name = "AutoBan", url = 'https://raw.githubusercontent.com/raihansanjaya123-a11y/RaihjnDev-Script/main/Autoban.lua'}
}
for i,v in pairs(scriptMisc) do
    LoadScriptFromUrl(v.url, v.Name)
end

-- ============================================================
-- TAB: WEBHOOK
-- ============================================================
local WebhookTab = Window:CreateTab("Webhook", nil)
getgenv().RaihjnWebhookTab = WebhookTab

WebhookTab:CreateSection("Discord Webhook Settings")

WebhookTab:CreateInput({
    Name = "Webhook URL",
    PlaceholderText = "https://discord.com/api/webhooks/...",
    RemoveTextAfterFocusLost = false,
    Callback = function(t)
        t = t:gsub("%s+", "") -- hapus spasi
        if t ~= "" then
            getgenv().WebhookURL = t
            Rayfield:Notify({Title="Webhook", Content="URL tersimpan!", Duration=3})
        end
    end,
})

WebhookTab:CreateButton({
    Name = "Test Webhook",
    Callback = function()
        if not getgenv().WebhookURL or getgenv().WebhookURL == "" then
            Rayfield:Notify({Title="Webhook", Content="Isi URL dulu!", Duration=3})
            return
        end
        getgenv().SendWebhook("Test webhook dari RaihjnDev loader!")
        Rayfield:Notify({Title="Webhook", Content="Pesan test dikirim!", Duration=3})
    end,
})

-- ============================================================
-- TAB: SETTINGS
-- ============================================================
local SettingsTab = Window:CreateTab("Settings", nil)
getgenv().RaihjnSettingsTab = SettingsTab

SettingsTab:CreateButton({
    Name = "Reset UI",
    Callback = function()
        ForceRestoreUI()
        Rayfield:Notify({
            Title = "Reset UI",
            Content = "UI reset successfully",
            Duration = 3,
        })
    end,
})

SettingsTab:CreateButton({
    Name = "Exit",
    Callback = function()
        Rayfield:Destroy()
    end,
})
