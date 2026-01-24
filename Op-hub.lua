-- SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- REMOTES
local Remotes = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Client")
local SkewerHit = Remotes:WaitForChild("SkewerHit")
local EatSkewer = Remotes:WaitForChild("EatSkewer")
local VoteRemote = Remotes:WaitForChild("CastVotekickVote")

-- STATE
local VotingInProgress = false
local KillauraEnabled = false
local SpeedEnabled = false
local SpeedValue = 16
local StarsEnabled = false
local AntiVotekickEnabled = false

--------------------------------------------------
-- SCREEN GUI
--------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ControlGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

--------------------------------------------------
-- DRAG (PC + MOBILE)
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
TopBar.BackgroundColor3 = Color3.fromRGB(0,0,0)
TopBar.Parent = ScreenGui

local function topButton(text, x)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0, 80, 1, 0)
	b.Position = UDim2.new(0, x, 0, 0)
	b.Text = text
	b.TextScaled = true
	b.BackgroundColor3 = Color3.fromRGB(30,30,30)
	b.TextColor3 = Color3.new(1,1,1)
	b.Parent = TopBar
	return b
end

--------------------------------------------------
-- PANELS
--------------------------------------------------
local function panel(size, pos)
	local f = Instance.new("Frame")
	f.Size = size
	f.Position = pos
	f.BackgroundColor3 = Color3.fromRGB(0,0,0)
	f.Visible = false
	f.Parent = ScreenGui
	makeDraggable(f)
	return f
end

-- KILLAURA
local AuraFrame = panel(UDim2.new(0,120,0,70), UDim2.new(0.05,0,0.15,0))
local AuraBtnUI = Instance.new("TextButton", AuraFrame)
AuraBtnUI.Size = UDim2.new(1,-10,1,-10)
AuraBtnUI.Position = UDim2.new(0,5,0,5)
AuraBtnUI.Text = "AURA OFF"
AuraBtnUI.TextScaled = true
AuraBtnUI.BackgroundColor3 = Color3.fromRGB(170,0,0)
AuraBtnUI.TextColor3 = Color3.new(1,1,1)

AuraBtnUI.MouseButton1Click:Connect(function()
	KillauraEnabled = not KillauraEnabled
	AuraBtnUI.Text = KillauraEnabled and "AURA ON" or "AURA OFF"
	AuraBtnUI.BackgroundColor3 = KillauraEnabled and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
end)

-- SPEED
local SpeedFrame = panel(UDim2.new(0,200,0,100), UDim2.new(0.2,0,0.15,0))
local SpeedBox = Instance.new("TextBox", SpeedFrame)
SpeedBox.Size = UDim2.new(1,-10,0,30)
SpeedBox.Position = UDim2.new(0,5,0,5)
SpeedBox.Text = "16"
SpeedBox.TextScaled = true
SpeedBox.BackgroundColor3 = Color3.fromRGB(60,60,60)
SpeedBox.TextColor3 = Color3.new(1,1,1)

local SpeedBtnUI = Instance.new("TextButton", SpeedFrame)
SpeedBtnUI.Size = UDim2.new(1,-10,0,30)
SpeedBtnUI.Position = UDim2.new(0,5,0,45)
SpeedBtnUI.Text = "SPEED OFF"
SpeedBtnUI.TextScaled = true
SpeedBtnUI.BackgroundColor3 = Color3.fromRGB(170,0,0)
SpeedBtnUI.TextColor3 = Color3.new(1,1,1)

SpeedBox.FocusLost:Connect(function()
	local v = tonumber(SpeedBox.Text)
	if v then
		SpeedValue = math.clamp(v,16,1000)
		SpeedBox.Text = tostring(SpeedValue)
	end
end)

SpeedBtnUI.MouseButton1Click:Connect(function()
	SpeedEnabled = not SpeedEnabled
	SpeedBtnUI.Text = SpeedEnabled and "SPEED ON" or "SPEED OFF"
	SpeedBtnUI.BackgroundColor3 = SpeedEnabled and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
end)

-- STARS
local StarsFrame = panel(UDim2.new(0,120,0,60), UDim2.new(0.4,0,0.15,0))
local StarsBtnUI = Instance.new("TextButton", StarsFrame)
StarsBtnUI.Size = UDim2.new(1,-10,1,-10)
StarsBtnUI.Position = UDim2.new(0,5,0,5)
StarsBtnUI.Text = "STARS OFF"
StarsBtnUI.TextScaled = true
StarsBtnUI.BackgroundColor3 = Color3.fromRGB(170,0,0)
StarsBtnUI.TextColor3 = Color3.new(1,1,1)

StarsBtnUI.MouseButton1Click:Connect(function()
	StarsEnabled = not StarsEnabled
	StarsBtnUI.Text = StarsEnabled and "STARS ON" or "STARS OFF"
	StarsBtnUI.BackgroundColor3 = StarsEnabled and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
end)

-- TP
local TpFrame = panel(UDim2.new(0,200,0,150), UDim2.new(0.6,0,0.15,0))
local TpTitle = Instance.new("TextLabel", TpFrame)
TpTitle.Size = UDim2.new(1,0,0,25)
TpTitle.Position = UDim2.new(0,0,0,0)
TpTitle.Text = "TP"
TpTitle.TextScaled = true
TpTitle.BackgroundTransparency = 1
TpTitle.TextColor3 = Color3.new(1,1,1)

local Scroll = Instance.new("ScrollingFrame", TpFrame)
Scroll.Position = UDim2.new(0,0,0,25)
Scroll.Size = UDim2.new(1,0,1,-25)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarImageTransparency = 0

local Layout = Instance.new("UIListLayout", Scroll)
Layout.Padding = UDim.new(0,5)

local function refreshPlayers()
	for _, v in ipairs(Scroll:GetChildren()) do
		if v:IsA("TextButton") then
			v:Destroy()
		end
	end

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(1,-10,0,25)
			btn.Position = UDim2.new(0,5,0,0)
			btn.Text = player.Name
			btn.TextScaled = true
			btn.BackgroundColor3 = Color3.fromRGB(20,20,20)
			btn.TextColor3 = Color3.new(1,1,1)
			btn.Parent = Scroll

			btn.MouseButton1Click:Connect(function()
				if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
					if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
						LocalPlayer.Character.HumanoidRootPart.CFrame =
							player.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,-2)
					end
				end
			end)
		end
	end
end

Players.PlayerAdded:Connect(refreshPlayers)
Players.PlayerRemoving:Connect(refreshPlayers)
refreshPlayers()

--------------------------------------------------
-- ANTI VOTEKICK (GUI + LOGIC)
--------------------------------------------------
local AVFrame = panel(UDim2.new(0, 160, 0, 70), UDim2.new(0.8, 0, 0.15, 0))
local AVBtnUI = Instance.new("TextButton", AVFrame)
AVBtnUI.Size = UDim2.new(1, -10, 1, -10)
AVBtnUI.Position = UDim2.new(0, 5, 0, 5)
AVBtnUI.Text = "AV OFF"
AVBtnUI.TextScaled = true
AVBtnUI.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
AVBtnUI.TextColor3 = Color3.new(1, 1, 1)

AVBtnUI.MouseButton1Click:Connect(function()
    AntiVotekickEnabled = not AntiVotekickEnabled
    AVBtnUI.Text = AntiVotekickEnabled and "AV ON" or "AV OFF"
    AVBtnUI.BackgroundColor3 = AntiVotekickEnabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
end)

local function spamNoVote()
    if VotingInProgress then return end
    VotingInProgress = true

    local startTime = os.clock()
    while os.clock() - startTime < 10 do
        if not AntiVotekickEnabled then break end
        VoteRemote:FireServer("No")
        task.wait(0.15)
    end

    VotingInProgress = false
end

local function handleChat(msg)
    if not AntiVotekickEnabled then return end

    local myName = LocalPlayer.Name:lower()
    msg = msg:lower()

    if msg:find("/votekick " .. myName) then
        spamNoVote()
    end
end

local function connectPlayer(p)
    p.Chatted:Connect(handleChat)
end

for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
        connectPlayer(p)
    end
end

Players.PlayerAdded:Connect(function(p)
    if p ~= LocalPlayer then
        connectPlayer(p)
    end
end)

--------------------------------------------------
-- TOP BUTTONS
--------------------------------------------------
local AuraTop = topButton("AURA",5)
local SpeedTop = topButton("SPEED",90)
local StarsTop = topButton("STARS",175)
local TpTop = topButton("TP",260)
local AVTop = topButton("AV",345)

AuraTop.MouseButton1Click:Connect(function()
	AuraFrame.Visible = not AuraFrame.Visible
end)

SpeedTop.MouseButton1Click:Connect(function()
	SpeedFrame.Visible = not SpeedFrame.Visible
end)

StarsTop.MouseButton1Click:Connect(function()
	StarsFrame.Visible = not StarsFrame.Visible
end)

TpTop.MouseButton1Click:Connect(function()
	TpFrame.Visible = not TpFrame.Visible
end)

AVTop.MouseButton1Click:Connect(function()
	AVFrame.Visible = not AVFrame.Visible
end)

--------------------------------------------------
-- LOOPS
--------------------------------------------------
-- KILLAURA
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

-- SPEED
task.spawn(function()
	while true do
		if SpeedEnabled and LocalPlayer.Character then
			local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
			if hum then hum.WalkSpeed = SpeedValue end
		end
		task.wait(0.05)
	end
end)

-- STARS
task.spawn(function()
	while true do
		if StarsEnabled then
			local folder = workspace:FindFirstChild("ActiveStars")
			local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
			if folder and hrp then
				for _,star in ipairs(folder:GetChildren()) do
					if not StarsEnabled then break end
					local part =
						star:IsA("BasePart") and star
						or star:IsA("Model") and (star.PrimaryPart or star:FindFirstChildWhichIsA("BasePart"))
					if part then
						hrp.CFrame = part.CFrame * CFrame.new(0,4,0)
					end
					task.wait(0.1)
				end
			end

			local chest = workspace:FindFirstChild("Chest")
			if chest and hrp then
				hrp.CFrame = chest.CFrame * CFrame.new(0,4,0)
			end
		end
		task.wait(0.1)
	end
end)
