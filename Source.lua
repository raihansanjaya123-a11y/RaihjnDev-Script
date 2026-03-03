--// Calm macOS Utility Panel - RemingtonHub

local TweenService = game:GetService("TweenService")

--// ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RemingtonHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

--// Window
local Window = Instance.new("Frame")
Window.Size = UDim2.new(0,780,0,480)
Window.Position = UDim2.new(0.5,-390,0.5,-240)
Window.BackgroundColor3 = Color3.fromRGB(22,24,29) -- #16181D
Window.BorderSizePixel = 0
Window.Parent = ScreenGui

local WindowCorner = Instance.new("UICorner")
WindowCorner.CornerRadius = UDim.new(0,18)
WindowCorner.Parent = Window

--// Soft Shadow Feel
Window.BackgroundTransparency = 0

--// Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0,200,1,0)
Sidebar.BackgroundColor3 = Color3.fromRGB(28,31,38) -- #1C1F26
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Window

local SidebarPadding = Instance.new("UIPadding")
SidebarPadding.PaddingTop = UDim.new(0,24)
SidebarPadding.PaddingLeft = UDim.new(0,24)
SidebarPadding.PaddingRight = UDim.new(0,24)
Sidebar.Parent = Sidebar

--// App Title
local AppTitle = Instance.new("TextLabel")
AppTitle.Size = UDim2.new(1,0,0,24)
AppTitle.BackgroundTransparency = 1
AppTitle.Text = "RemingtonHub"
AppTitle.Font = Enum.Font.GothamBold
AppTitle.TextSize = 16
AppTitle.TextXAlignment = Enum.TextXAlignment.Left
AppTitle.TextColor3 = Color3.fromRGB(255,255,255)
AppTitle.Parent = Sidebar

--// Tab Container
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1,0,1,-60)
TabContainer.Position = UDim2.new(0,0,0,40)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = Sidebar

local TabList = Instance.new("UIListLayout")
TabList.Padding = UDim.new(0,8)
TabList.Parent = TabContainer

--// Accent Color
local Accent = Color3.fromRGB(59,164,247)

local function CreateTab(text)
	local Tab = Instance.new("TextButton")
	Tab.Size = UDim2.new(1,0,0,36)
	Tab.BackgroundColor3 = Color3.fromRGB(28,31,38)
	Tab.BackgroundTransparency = 1
	Tab.Text = ""
	Tab.AutoButtonColor = false
	Tab.Parent = TabContainer
	
	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0,10)
	Corner.Parent = Tab
	
	-- Icon Placeholder
	local Icon = Instance.new("TextLabel")
	Icon.Size = UDim2.new(0,20,0,20)
	Icon.Position = UDim2.new(0,0,0.5,-10)
	Icon.BackgroundTransparency = 1
	Icon.Text = "●"
	Icon.Font = Enum.Font.GothamBold
	Icon.TextSize = 12
	Icon.TextColor3 = Color3.fromRGB(111,119,130)
	Icon.Parent = Tab
	
	-- Label
	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(1,-30,1,0)
	Label.Position = UDim2.new(0,30,0,0)
	Label.BackgroundTransparency = 1
	Label.Text = text
	Label.Font = Enum.Font.GothamMedium
	Label.TextSize = 14
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.TextColor3 = Color3.fromRGB(111,119,130)
	Label.Parent = Tab
	
	-- Hover
	Tab.MouseEnter:Connect(function()
		TweenService:Create(Tab,TweenInfo.new(0.18,Enum.EasingStyle.Quint),{
			BackgroundTransparency = 0.9
		}):Play()
	end)
	
	Tab.MouseLeave:Connect(function()
		TweenService:Create(Tab,TweenInfo.new(0.18,Enum.EasingStyle.Quint),{
			BackgroundTransparency = 1
		}):Play()
	end)
	
	-- Active State
	Tab.MouseButton1Click:Connect(function()
		for _,v in pairs(TabContainer:GetChildren()) do
			if v:IsA("TextButton") then
				v.BackgroundTransparency = 1
				for _,child in pairs(v:GetChildren()) do
					if child:IsA("TextLabel") then
						child.TextColor3 = Color3.fromRGB(111,119,130)
					end
				end
			end
		end
		
		TweenService:Create(Tab,TweenInfo.new(0.22,Enum.EasingStyle.Quint),{
			BackgroundColor3 = Color3.fromRGB(32,36,44),
			BackgroundTransparency = 0
		}):Play()
		
		Label.TextColor3 = Color3.fromRGB(255,255,255)
		Icon.TextColor3 = Accent
	end)
end

CreateTab("Dashboard")
CreateTab("Player")
CreateTab("Visual")
CreateTab("Settings")

--// Content Area
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1,-200,1,0)
Content.Position = UDim2.new(0,200,0,0)
Content.BackgroundColor3 = Color3.fromRGB(32,36,44)
Content.BorderSizePixel = 0
Content.Parent = Window

local ContentPadding = Instance.new("UIPadding")
ContentPadding.PaddingTop = UDim.new(0,32)
ContentPadding.PaddingLeft = UDim.new(0,40)
ContentPadding.PaddingRight = UDim.new(0,40)
Content.Parent = Content

--// Header
local Header = Instance.new("TextLabel")
Header.Size = UDim2.new(1,0,0,30)
Header.BackgroundTransparency = 1
Header.Text = "Dashboard"
Header.Font = Enum.Font.GothamBold
Header.TextSize = 22
Header.TextColor3 = Color3.fromRGB(255,255,255)
Header.TextXAlignment = Enum.TextXAlignment.Left
Header.Parent = Content

local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(1,0,0,20)
Subtitle.Position = UDim2.new(0,0,0,30)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "System controls and overview"
Subtitle.Font = Enum.Font.Gotham
Subtitle.TextSize = 13
Subtitle.TextColor3 = Color3.fromRGB(168,176,188)
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.Parent = Content
