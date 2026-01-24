--------------------------------------------------
-- SERVICES
--------------------------------------------------
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--------------------------------------------------
-- REMOTES
--------------------------------------------------
local Remotes = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Client")
local SkewerHit = Remotes:WaitForChild("SkewerHit")
local EatSkewer = Remotes:WaitForChild("EatSkewer")

--------------------------------------------------
-- STATE
--------------------------------------------------
local KillauraEnabled = false
local SpeedEnabled = false
local SpeedValue = 16
local StarsEnabled = false
local AntiVotekickEnabled = false
local Rejoining = false

--------------------------------------------------
-- GUI SETUP
--------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ControlGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

--------------------------------------------------
-- DRAG FUNCTION
--------------------------------------------------
local function makeDraggable(frame)
	frame.Active = true
	local dragging, dragStart, startPos

	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)

	UserInputService.InputEnded:Connect(function()
		dragging = false
	end)
end

--------------------------------------------------
-- TOP BAR
--------------------------------------------------
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 32)
TopBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
TopBar.Parent = ScreenGui

local function topButton(text, x)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0, 80, 1, 0)
	b.Position = UDim2.new(0, x, 0, 0)
	b.Text = text
	b.TextScaled = true
	b.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	b.TextColor3 = Color3.new(1, 1, 1)
	b.Parent = TopBar
	return b
end

--------------------------------------------------
-- PANEL FUNCTION
--------------------------------------------------
local function panel(size, pos)
	local f = Instance.new("Frame")
	f.Size = size
	f.Position = pos
	f.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	f.Visible = false
	f.Parent = ScreenGui
	makeDraggable(f)
	return f
end

--------------------------------------------------
-- KILLAURA PANEL
--------------------------------------------------
local AuraFrame = panel(UDim2.new(0,120,0,70), UDim2.new(0.05,0,0.15,0))
local AuraBtn = Instance.new("TextButton", AuraFrame)
AuraBtn.Size = UDim2.new(1,-10,1,-10)
AuraBtn.Position = UDim2.new(0,5,0,5)
AuraBtn.Text = "AURA OFF"
AuraBtn.TextScaled = true
AuraBtn.BackgroundColor3 = Color3.fromRGB(170,0,0)
AuraBtn.TextColor3 = Color3.new(1,1,1)

AuraBtn.MouseButton1Click:Connect(function()
	KillauraEnabled = not KillauraEnabled
	AuraBtn.Text = KillauraEnabled and "AURA ON" or "AURA OFF"
	AuraBtn.BackgroundColor3 = KillauraEnabled and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
end)

--------------------------------------------------
-- SPEED PANEL
--------------------------------------------------
local SpeedFrame = panel(UDim2.new(0,200,0,100), UDim2.new(0.2,0,0.15,0))

local SpeedBox = Instance.new("TextBox", SpeedFrame)
SpeedBox.Size = UDim2.new(1,-10,0,30)
SpeedBox.Position = UDim2.new(0,5,0,5)
SpeedBox.Text = "16"
SpeedBox.TextScaled = true
SpeedBox.BackgroundColor3 = Color3.fromRGB(60,60,60)
SpeedBox.TextColor3 = Color3.new(1,1,1)

local SpeedBtn = Instance.new("TextButton", SpeedFrame)
SpeedBtn.Size = UDim2.new(1,-10,0,30)
SpeedBtn.Position = UDim2.new(0,5,0,45)
SpeedBtn.Text = "SPEED OFF"
SpeedBtn.TextScaled = true
SpeedBtn.BackgroundColor3 = Color3.fromRGB(170,0,0)
SpeedBtn.TextColor3 = Color3.new(1,1,1)

SpeedBox.FocusLost:Connect(function()
	local v = tonumber(SpeedBox.Text)
	if v then
		SpeedValue = math.clamp(v, 16, 1000)
		SpeedBox.Text = tostring(SpeedValue)
	end
end)

SpeedBtn.MouseButton1Click:Connect(function()
	SpeedEnabled = not SpeedEnabled
	SpeedBtn.Text = SpeedEnabled and "SPEED ON" or "SPEED OFF"
	SpeedBtn.BackgroundColor3 = SpeedEnabled and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
end)

--------------------------------------------------
-- ANTI VOTEKICK PANEL
--------------------------------------------------
local AVFrame = panel(UDim2.new(0,160,0,70), UDim2.new(0.6,0,0.15,0))
local AVBtn = Instance.new("TextButton", AVFrame)
AVBtn.Size = UDim2.new(1,-10,1,-10)
AVBtn.Position = UDim2.new(0,5,0,5)
AVBtn.Text = "AV OFF"
AVBtn.TextScaled = true
AVBtn.BackgroundColor3 = Color3.fromRGB(170,0,0)
AVBtn.TextColor3 = Color3.new(1,1,1)

AVBtn.MouseButton1Click:Connect(function()
	AntiVotekickEnabled = not AntiVotekickEnabled
	AVBtn.Text = AntiVotekickEnabled and "AV ON" or "AV OFF"
	AVBtn.BackgroundColor3 = AntiVotekickEnabled and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
end)

--------------------------------------------------
-- TOP BUTTONS
--------------------------------------------------
local AuraTop = topButton("AURA", 5)
local SpeedTop = topButton("SPEED", 90)
local AVTop = topButton("AV", 175)

AuraTop.MouseButton1Click:Connect(function()
	AuraFrame.Visible = not AuraFrame.Visible
end)

SpeedTop.MouseButton1Click:Connect(function()
	SpeedFrame.Visible = not SpeedFrame.Visible
end)

AVTop.MouseButton1Click:Connect(function()
	AVFrame.Visible = not AVFrame.Visible
end)

--------------------------------------------------
-- LOOPS
--------------------------------------------------
task.spawn(function()
	while true do
		if KillauraEnabled then
			for _, p in ipairs(Players:GetPlayers()) do
				if p ~= LocalPlayer then
					SkewerHit:FireServer(p)
					EatSkewer:FireServer(p)
				end
			end
		end
		task.wait(0.05)
	end
end)

task.spawn(function()
	while true do
		if SpeedEnabled and LocalPlayer.Character then
			local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
			if hum then
				hum.WalkSpeed = SpeedValue
			end
		end
		task.wait(0.05)
	end
end)

--------------------------------------------------
-- ANTI VOTEKICK CHAT DETECTION (JOBID REJOIN)
--------------------------------------------------
local PlaceId = game.PlaceId
local JobId = game.JobId

local function rejoinSameServer()
	if Rejoining then return end
	Rejoining = true
	task.wait(0.2)

	pcall(function()
		TeleportService:TeleportToPlaceInstance(
			PlaceId,
			JobId,
			LocalPlayer
		)
	end)
end

local function onChat(msg)
	if not AntiVotekickEnabled then return end

	msg = msg:lower()
	local myName = LocalPlayer.Name:lower()

	if msg == ("/votekick " .. myName) then
		rejoinSameServer()
	end
end

for _, p in ipairs(Players:GetPlayers()) do
	if p ~= LocalPlayer then
		p.Chatted:Connect(onChat)
	end
end

Players.PlayerAdded:Connect(function(p)
	if p ~= LocalPlayer then
		p.Chatted:Connect(onChat)
	end
end)
