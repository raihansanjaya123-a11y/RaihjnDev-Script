local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

getgenv().Rayfield = Rayfield

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
   Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
   LoadingTitle = "RaihjnDev",
   LoadingSubtitle = "by RaihjnDev | Rayfield UI",
   ShowText = "RaihjnDev", -- for mobile users to unhide Rayfield, change if you'd like
   Theme = "Ocean", -- Check https://docs.sirius.menu/rayfield/configuration/themes

   ToggleUIKeybind = "K", -- The keybind to toggle the UI visibility (string like "K" or Enum.KeyCode)

   DisableRayfieldPrompts = true,
   DisableBuildWarnings = false, -- Prevents Rayfield from emitting warnings when the script has a version mismatch with the interface.

   ConfigurationSaving = {
      Enabled = false,
      FolderName = nil, -- Create a custom folder for your hub/game
      FileName = "RaihjnDev Index"
   },

   Discord = {
      Enabled = true, -- Prompt the user to join your Discord server if their executor supports it
      Invite = "Me7FKdQdSp", -- The Discord invite code, do not include Discord.gg/. E.g. Discord.gg/ ABCD would be ABCD
      RememberJoins = true -- Set this to false to make them join the Discord every time they load it up
   },

   KeySystem = false, -- Set this to true to use our key system
   KeySettings = {
      Title = "RaihjnDev",
      Subtitle = "by RaihjnDev",
      Note = "Join Discord to get key", -- Use this to tell the user how to get a key
      FileName = "RaihjnDev | Key", -- It is recommended to use something unique, as other scripts using Rayfield may overwrite your key file
      SaveKey = false, -- The user's key will be saved, but if you change the key, they will be unable to use your script
      GrabKeyFromSite = true, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = {"https://raw.githubusercontent.com/raihansanjaya123-a11y/RaihjnDev-Script/refs/heads/main/Key"} -- List of keys that the system will accept, can be RAW file links (pastebin, github, etc.) or simple strings ("hello", "key22")
   }
})

local MainTab = Window:CreateTab("Pabrik", nil)
getgenv().RaihjnTab = MainTab

local scriptPabrik = {
    {Name = "PabrikRaihjn", url = 'https://raw.githubusercontent.com/raihansanjaya123-a11y/RaihjnDev-Script/main/PabrikRaihjn.lua'}
}
for i,v in pairs(scriptPabrik) do
    LoadScriptFromUrl(v.url, v.Name)
end

local AutoFarmTab = Window:CreateTab("AutoFarm", nil)
getgenv().RaihjnAutoFarmTab = AutoFarmTab

local scriptAutoFarm = {
    {Name = "AutoFarm", url = 'https://raw.githubusercontent.com/raihansanjaya123-a11y/RaihjnDev-Script/main/AutoFarm.lua'}
}
for i,v in pairs(scriptAutoFarm) do
    LoadScriptFromUrl(v.url, v.Name)
end

local MiscTab = Window:CreateTab("Misc", nil)
getgenv().RaihjnMiscTab = MiscTab

local scriptMisc = {
    {Name = "AutoBan", url = 'https://raw.githubusercontent.com/raihansanjaya123-a11y/RaihjnDev-Script/main/Autoban.lua'}
}
for i,v in pairs(scriptMisc) do
    LoadScriptFromUrl(v.url, v.Name)
end

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
