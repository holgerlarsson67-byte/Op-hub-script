--==============================
-- SERVICES
--==============================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local PlaceId = game.PlaceId

--==============================
-- REMOTES
--==============================
local Remotes = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Client")
local SkewerHit = Remotes:WaitForChild("SkewerHit")
local EatSkewer = Remotes:WaitForChild("EatSkewer")

--==============================
-- STATE
--==============================
local KillauraEnabled = false
local SpeedEnabled = false
local SpeedValue = 16
local StarsEnabled = false
local AntiVotekickEnabled = false
local Rejoining = false

--==============================
-- SCREEN GUI
--==============================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ControlGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

--==============================
-- DRAG FUNCTION
--==============================
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
			frame.Position = startPos + UDim2.fromOffset(delta.X, delta.Y)
		end
	end)

	UserInputService.InputEnded:Connect(function()
		dragging = false
	end)
end

--==============================
-- TOP BAR
--==============================
local TopBar = Instance.new("Frame", ScreenGui)
TopBar.Size = UDim2.new(1,0,0,32)
TopBar.BackgroundColor3 = Color3.fromRGB(0,0,0)

local function topButton(text, x)
	local b = Instance.new("TextButton", TopBar)
	b.Size = UDim2.new(0,80,1,0)
	b.Position = UDim2.new(0,x,0,0)
	b.Text = text
	b.TextScaled = true
	b.BackgroundColor3 = Color3.fromRGB(30,30,30)
	b.TextColor3 = Color3.new(1,1,1)
	return b
end

--==============================
-- PANEL FUNCTION
--==============================
local function panel(size, pos)
	local f = Instance.new("Frame", ScreenGui)
	f.Size = size
	f.Position = pos
	f.BackgroundColor3 = Color3.fromRGB(0,0,0)
	f.Visible = false
	makeDraggable(f)
	return f
end

--==============================
-- AURA
--==============================
local AuraFrame = panel(UDim2.new(0,120,0,70), UDim2.new(0.05,0,0.15,0))
local AuraBtn = Instance.new("TextButton", AuraFrame)
AuraBtn.Size = UDim2.new(1,-10,1,-10)
AuraBtn.Position = UDim2.new(0,5,0,5)
AuraBtn.TextScaled = true
AuraBtn.Text = "AURA OFF"
AuraBtn.BackgroundColor3 = Color3.fromRGB(170,0,0)
AuraBtn.TextColor3 = Color3.new(1,1,1)

AuraBtn.MouseButton1Click:Connect(function()
	KillauraEnabled = not KillauraEnabled
	AuraBtn.Text = KillauraEnabled and "AURA ON" or "AURA OFF"
	AuraBtn.BackgroundColor3 = KillauraEnabled and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
end)

--==============================
-- SPEED
--==============================
local SpeedFrame = panel(UDim2.new(0,200,0,100), UDim2.new(0.2,0,0.15,0))
local SpeedBox = Instance.new("TextBox", SpeedFrame)
SpeedBox.Size = UDim2.new(1,-10,0,30)
SpeedBox.Position = UDim2.new(0,5,0,5)
SpeedBox.Text = "16"
SpeedBox.TextScaled = true

local SpeedBtn = Instance.new("TextButton", SpeedFrame)
SpeedBtn.Size = UDim2.new(1,-10,0,30)
SpeedBtn.Position = UDim2.new(0,5,0,45)
SpeedBtn.TextScaled = true
SpeedBtn.Text = "SPEED OFF"
SpeedBtn.BackgroundColor3 = Color3.fromRGB(170,0,0)

SpeedBtn.MouseButton1Click:Connect(function()
	SpeedEnabled = not SpeedEnabled
	SpeedBtn.Text = SpeedEnabled and "SPEED ON" or "SPEED OFF"
	SpeedBtn.BackgroundColor3 = SpeedEnabled and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
end)

SpeedBox.FocusLost:Connect(function()
	local v = tonumber(SpeedBox.Text)
	if v then
		SpeedValue = math.clamp(v,16,1000)
		SpeedBox.Text = tostring(SpeedValue)
	end
end)

--------------------------------------------------
-- ANTI VOTEKICK (JOBID REJOIN)
--------------------------------------------------
local TeleportService = game:GetService("TeleportService")

local PlaceId = game.PlaceId
local JobId = game.JobId

local Rejoining = false

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

	-- STRICT MATCH ONLY
	if msg == ("/votekick " .. myName) then
		rejoinSameServer()
	end
end

-- connect existing players
for _, player in ipairs(Players:GetPlayers()) do
	if player ~= LocalPlayer then
		player.Chatted:Connect(onChat)
	end
end

-- connect new players
Players.PlayerAdded:Connect(function(player)
	if player ~= LocalPlayer then
		player.Chatted:Connect(onChat)
	end
end)
--==============================
-- TOP BUTTONS
--==============================
topButton("AURA",5).MouseButton1Click:Connect(function()
	AuraFrame.Visible = not AuraFrame.Visible
end)

topButton("SPEED",90).MouseButton1Click:Connect(function()
	SpeedFrame.Visible = not SpeedFrame.Visible
end)

topButton("AV",175).MouseButton1Click:Connect(function()
	AVFrame.Visible = not AVFrame.Visible
end)

--==============================
-- LOOPS
--==============================
task.spawn(function()
	while true do
		if KillauraEnabled then
			for _,p in ipairs(Players:GetPlayers()) do
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
			if hum then hum.WalkSpeed = SpeedValue end
		end
		task.wait(0.05)
	end
end)
