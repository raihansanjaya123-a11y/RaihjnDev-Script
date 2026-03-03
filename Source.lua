--// Ocean Glass Sidebar UI - RemingtonHub

local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

--// ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RemingtonHub"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

--// Main Window
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0,780,0,480)
Main.Position = UDim2.new(0.5,-390,0.5,-240)
Main.BackgroundColor3 = Color3.fromRGB(15,32,39)
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner",Main)
MainCorner.CornerRadius = UDim.new(0,16)

local MainStroke = Instance.new("UIStroke",Main)
MainStroke.Color = Color3.fromRGB(255,255,255)
MainStroke.Transparency = 0.9
MainStroke.Thickness = 1

-- Shadow feel
Main.BackgroundTransparency = 0.05

--// Sidebar (Glassy)
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0,190,1,0)
Sidebar.BackgroundColor3 = Color3.fromRGB(20,47,59)
Sidebar.BackgroundTransparency = 0.15
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Main

local SideCorner = Instance.new("UICorner",Sidebar)
SideCorner.CornerRadius = UDim.new(0,16)

--// Logo
local Logo = Instance.new("TextLabel")
Logo.Text = "RemingtonHub"
Logo.Font = Enum.Font.GothamBold
Logo.TextSize = 16
Logo.TextColor3 = Color3.fromRGB(255,255,255)
Logo.BackgroundTransparency = 1
Logo.Size = UDim2.new(1,0,0,60)
Logo.Parent = Sidebar

--// Tab Container
local TabContainer = Instance.new("Frame")
TabContainer.Position = UDim2.new(0,0,0,70)
TabContainer.Size = UDim2.new(1,0,1,-90)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = Sidebar

local UIList = Instance.new("UIListLayout",TabContainer)
UIList.Padding = UDim.new(0,8)

-- Cyan Accent
local AccentColor = Color3.fromRGB(56,189,248)

local function CreateTabButton(text)
	local Button = Instance.new("TextButton")
	Button.Size = UDim2.new(1,-20,0,42)
	Button.Position = UDim2.new(0,10,0,0)
	Button.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Button.BackgroundTransparency = 0.95
	Button.Text = text
	Button.Font = Enum.Font.GothamSemibold
	Button.TextSize = 14
	Button.TextColor3 = Color3.fromRGB(220,230,235)
	Button.AutoButtonColor = false
	Button.Parent = TabContainer
	
	local Corner = Instance.new("UICorner",Button)
	Corner.CornerRadius = UDim.new(0,12)
	
	-- Active Indicator
	local Indicator = Instance.new("Frame")
	Indicator.Size = UDim2.new(0,3,0.7,0)
	Indicator.Position = UDim2.new(0,0,0.15,0)
	Indicator.BackgroundColor3 = AccentColor
	Indicator.Visible = false
	Indicator.BorderSizePixel = 0
	Indicator.Parent = Button
	
	local IndCorner = Instance.new("UICorner",Indicator)
	IndCorner.CornerRadius = UDim.new(1,0)

	-- Hover animation
	Button.MouseEnter:Connect(function()
		TweenService:Create(Button,TweenInfo.new(0.15),{
			BackgroundTransparency = 0.9
		}):Play()
	end)
	
	Button.MouseLeave:Connect(function()
		if not Indicator.Visible then
			TweenService:Create(Button,TweenInfo.new(0.15),{
				BackgroundTransparency = 0.95
			}):Play()
		end
	end)
	
	Button.MouseButton1Click:Connect(function()
		for _,v in pairs(TabContainer:GetChildren()) do
			if v:IsA("TextButton") then
				v.BackgroundTransparency = 0.95
				if v:FindFirstChildOfClass("Frame") then
					v:FindFirstChildOfClass("Frame").Visible = false
				end
			end
		end
		
		Indicator.Visible = true
		
		TweenService:Create(Button,TweenInfo.new(0.2,Enum.EasingStyle.Quad),{
			BackgroundTransparency = 0.88
		}):Play()
	end)
end

CreateTabButton("Main")
CreateTabButton("Player")
CreateTabButton("Visual")
CreateTabButton("Settings")

--// Content Area
local Content = Instance.new("Frame")
Content.Position = UDim2.new(0,190,0,0)
Content.Size = UDim2.new(1,-190,1,0)
Content.BackgroundTransparency = 1
Content.Parent = Main

-- Header
local Header = Instance.new("TextLabel")
Header.Text = "Dashboard"
Header.Font = Enum.Font.GothamBold
Header.TextSize = 22
Header.TextColor3 = Color3.fromRGB(255,255,255)
Header.BackgroundTransparency = 1
Header.Position = UDim2.new(0,30,0,30)
Header.Size = UDim2.new(0,300,0,30)
Header.Parent = Content

-- Card
local Card = Instance.new("Frame")
Card.Position = UDim2.new(0,30,0,80)
Card.Size = UDim2.new(1,-60,0,250)
Card.BackgroundColor3 = Color3.fromRGB(255,255,255)
Card.BackgroundTransparency = 0.9
Card.BorderSizePixel = 0
Card.Parent = Content

local CardCorner = Instance.new("UICorner",Card)
CardCorner.CornerRadius = UDim.new(0,14)

local CardStroke = Instance.new("UIStroke",Card)
CardStroke.Transparency = 0.85
CardStroke.Color = Color3.fromRGB(255,255,255)
CardStroke.Thickness = 1
