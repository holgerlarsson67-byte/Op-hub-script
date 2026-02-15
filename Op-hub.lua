

-- SERVICES (FIXED ORDER)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local TextChatService = game:GetService("TextChatService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")



-- CONFIG ADD
local HttpService = game:GetService("HttpService")
local CONFIG_FOLDER = "Workspace/MyScript"
local CONFIG_FILE = CONFIG_FOLDER .. "/config.json"

pcall(function()
	if not isfolder(CONFIG_FOLDER) then
		makefolder(CONFIG_FOLDER)
	end
end)




-- REMOTES
local Remotes = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Client")
local SkewerHit = Remotes:WaitForChild("SkewerHit")
local EatSkewer = Remotes:WaitForChild("EatSkewer")

-- STATE
local TpAllEnabled = false
local KillauraEnabled = false
local SpeedEnabled = false
local SpeedValue = 16
local StarsEnabled = false
local AntiVotekickEnabled = false
local Rejoining = false
local AutoExecute = false
local AntiRagdollEnabled = false

local function disableRagdollRemotes()
	local serverRemotes = ReplicatedStorage:FindFirstChild("Remotes")
		and ReplicatedStorage.Remotes:FindFirstChild("Server")

	if not serverRemotes then return end

	for _,name in pairs({"RagdollPlayer","UnragdollPlayer","ChangeRootVelocity"}) do
		local r = serverRemotes:FindFirstChild(name)
		if r and r:IsA("RemoteEvent") then
			for _,c in pairs(getconnections(r.OnClientEvent)) do
				c:Disable()
			end
		end
	end
end

local DashPadsFolder = workspace:WaitForChild("DashPads")

local function isTouchingDashPad()
	local character = LocalPlayer.Character
	if not character then return false end

	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end

	for _, part in ipairs(hrp:GetTouchingParts()) do
		if part:IsDescendantOf(DashPadsFolder) then
			return true
		end
	end

	return false
end

local function EnableRagdollRemotes()
	local serverRemotes = ReplicatedStorage:FindFirstChild("Remotes")
		and ReplicatedStorage.Remotes:FindFirstChild("Server")

	if not serverRemotes then return end

	for _,name in pairs({"RagdollPlayer","UnragdollPlayer","ChangeRootVelocity"}) do
		local r = serverRemotes:FindFirstChild(name)
		if r and r:IsA("RemoteEvent") then
			for _,c in pairs(getconnections(r.OnClientEvent)) do
				c:Enable()
			end
		end
	end
end
LocalPlayer.CharacterAdded:Connect(function()
	task.wait(1)
	if AntiRagdollEnabled then
		disableRagdollRemotes()
	end
end)

-- CONFIG ADD
local function saveConfig()
	local data = {
		KillauraEnabled = KillauraEnabled,
		SpeedEnabled = SpeedEnabled,
		SpeedValue = SpeedValue,
		StarsEnabled = StarsEnabled,
		AntiVotekickEnabled = AntiVotekickEnabled,
		TpAllEnabled = TpAllEnabled,
		AutoExecute = AutoExecute,
		AntiRagdollEnabled = AntiRagdollEnabled,

	}

	writefile(CONFIG_FILE, HttpService:JSONEncode(data))
end

local function loadConfig()
	if not isfile(CONFIG_FILE) then return end

	local success, data = pcall(function()
		return HttpService:JSONDecode(readfile(CONFIG_FILE))
	end)
	if not success then return end

	KillauraEnabled = data.KillauraEnabled or false
	SpeedEnabled = data.SpeedEnabled or false
	SpeedValue = data.SpeedValue or 16
	StarsEnabled = data.StarsEnabled or false
	AntiVotekickEnabled = data.AntiVotekickEnabled or false
	TpAllEnabled = data.TpAllEnabled or false
	AutoExecute = data.AutoExecute or false
	AntiRagdollEnabled = data.AntiRagdollEnabled or false
end

-- KILLAURA BLACKLIST
local KillauraBlacklist = {
	["pyttecan11"] = true,
	["ezwin1411"] = true,
	["vikingerik14"] = true,
	["ggogogogo18"] = true
}


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

--------------------------------------------------
-- KILLAURA
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
	saveConfig()
end)


--------------------------------------------------
-- SPEED
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
		SpeedValue = math.clamp(v,16,1000)
		SpeedBox.Text = tostring(SpeedValue)
		saveConfig()
	end
end)


local function touchingSpawn()
	local char = LocalPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end

	for _, part in ipairs(workspace:GetPartsInPart(hrp)) do
		if part.Name == "SpawnArea" then
			return true
		end
	end
	return false
end

SpeedBtn.MouseButton1Click:Connect(function()
	SpeedEnabled = not SpeedEnabled
	SpeedBtn.Text = SpeedEnabled and "SPEED ON" or "SPEED OFF"
	SpeedBtn.BackgroundColor3 = SpeedEnabled and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
	saveConfig()

	if not SpeedEnabled then
		local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
		if hum then
			hum.WalkSpeed = touchingSpawn() and 45 or 16
		end
	end
end)


--------------------------------------------------
-- STARS
--------------------------------------------------
local StarsFrame = panel(UDim2.new(0,120,0,60), UDim2.new(0.4,0,0.15,0))
local StarsBtn = Instance.new("TextButton", StarsFrame)
StarsBtn.Size = UDim2.new(1,-10,1,-10)
StarsBtn.Position = UDim2.new(0,5,0,5)
StarsBtn.Text = "STARS OFF"
StarsBtn.TextScaled = true
StarsBtn.BackgroundColor3 = Color3.fromRGB(170,0,0)
StarsBtn.TextColor3 = Color3.new(1,1,1)

StarsBtn.MouseButton1Click:Connect(function()
	StarsEnabled = not StarsEnabled
	StarsBtn.Text = StarsEnabled and "STARS ON" or "STARS OFF"
	StarsBtn.BackgroundColor3 = StarsEnabled and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
	saveConfig()
end)

--------------------------------------------------
-- TP
--------------------------------------------------
local TpFrame = panel(UDim2.new(0,200,0,180), UDim2.new(0.6,0,0.15,0))

local TpTitle = Instance.new("TextLabel", TpFrame)
TpTitle.Size = UDim2.new(1,0,0,25)
TpTitle.Text = "TP"
TpTitle.TextScaled = true
TpTitle.BackgroundTransparency = 1
TpTitle.TextColor3 = Color3.new(1,1,1)

local TpScroll = Instance.new("ScrollingFrame", TpFrame)
TpScroll.Position = UDim2.new(0,0,0,25)
TpScroll.Size = UDim2.new(1,0,1,-25)
TpScroll.CanvasSize = UDim2.new(0,0,0,0)
TpScroll.ScrollBarImageTransparency = 0
TpScroll.BackgroundTransparency = 1
TpScroll.ScrollingDirection = Enum.ScrollingDirection.Y

local TpLayout = Instance.new("UIListLayout", TpScroll)
TpLayout.Padding = UDim.new(0,5)

local function updateTpCanvas()
	TpScroll.CanvasSize = UDim2.new(0,0,0,TpLayout.AbsoluteContentSize.Y + 10)
end
TpLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateTpCanvas)

local function refreshTP()
	for _,v in ipairs(TpScroll:GetChildren()) do
		if v:IsA("TextButton") then v:Destroy() end
	end

	for _,p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer then
			local b = Instance.new("TextButton")
			b.Size = UDim2.new(1,-10,0,28)
			b.Text = p.Name
			b.TextScaled = true
			b.BackgroundColor3 = Color3.fromRGB(20,20,20)
			b.TextColor3 = Color3.new(1,1,1)
			b.Parent = TpScroll

			b.MouseButton1Click:Connect(function()
				local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
				local theirHRP = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
				if myHRP and theirHRP then
					myHRP.CFrame = theirHRP.CFrame * CFrame.new(0,0,-2)
				end
			end)
		end
	end

	updateTpCanvas()
end

Players.PlayerAdded:Connect(refreshTP)
Players.PlayerRemoving:Connect(refreshTP)
refreshTP()

--------------------------------------------------
-- ANTI VOTEKICK
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
	saveConfig()
end)

local function rejoinServer()
	if Rejoining then return end
	Rejoining = true
	TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
end

local function hookChat(p)
	p.Chatted:Connect(function(msg)
		if AntiVotekickEnabled and msg:lower():find("/votekick "..LocalPlayer.Name:lower()) then
			rejoinServer()
		end
	end)
end

for _,p in ipairs(Players:GetPlayers()) do
	if p ~= LocalPlayer then hookChat(p) end
end
Players.PlayerAdded:Connect(hookChat)




	




-- TP ALL
local TpAllFrame = panel(UDim2.new(0,160,0,70), UDim2.new(0.65,0,0.35,0))

local TpAllBtn = Instance.new("TextButton", TpAllFrame)
TpAllBtn.Size = UDim2.new(1,-10,1,-10)
TpAllBtn.Position = UDim2.new(0,5,0,5)
TpAllBtn.Text = "TP ALL OFF"
TpAllBtn.TextScaled = true
TpAllBtn.BackgroundColor3 = Color3.fromRGB(170,0,0)
TpAllBtn.TextColor3 = Color3.new(1,1,1)

TpAllBtn.MouseButton1Click:Connect(function()
	TpAllEnabled = not TpAllEnabled
	TpAllBtn.Text = TpAllEnabled and "TP ALL ON" or "TP ALL OFF"
	TpAllBtn.BackgroundColor3 =
		TpAllEnabled and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
	saveConfig()
end)

--------------------------------------------------
-- Anti Ragdoll (AR)
--------------------------------------------------
local ARFrame = panel(UDim2.new(0,120,0,70), UDim2.new(0.75,0,0.15,0))

local ARBtn = Instance.new("TextButton", ARFrame)
ARBtn.Size = UDim2.new(1,-10,1,-10)
ARBtn.Position = UDim2.new(0,5,0,5)
ARBtn.Text = "AR OFF"
ARBtn.TextScaled = true
ARBtn.BackgroundColor3 = Color3.fromRGB(170,0,0)
ARBtn.TextColor3 = Color3.new(1,1,1)

ARBtn.MouseButton1Click:Connect(function()
	AntiRagdollEnabled = not AntiRagdollEnabled

	ARBtn.Text = AntiRagdollEnabled and "AR ON" or "AR OFF"
	ARBtn.BackgroundColor3 =
		AntiRagdollEnabled and Color3.fromRGB(0,170,0)
		or Color3.fromRGB(170,0,0)

	if AntiRagdollEnabled then
		disableRagdollRemotes()
	    else
        EnableRagdollRemotes()
	end
		
	saveConfig()
end)

--------------------------------------------------
-- TOP BUTTONS
--------------------------------------------------
local AuraTop = topButton("AURA",5)
local SpeedTop = topButton("SPEED",90)
local StarsTop = topButton("STARS",175)
local AVTop = topButton("AV",345)
local TpTop = topButton("TP",260)
local TpAllTop = topButton("TPALL", 430)
local ARTop = topButton("AR", 515)

ARTop.MouseButton1Click:Connect(function()
	ARFrame.Visible = not ARFrame.Visible
end)

TpAllTop.MouseButton1Click:Connect(function()
	TpAllFrame.Visible = not TpAllFrame.Visible
end)


TpTop.MouseButton1Click:Connect(function()
	TpFrame.Visible = not TpFrame.Visible
end)

AuraTop.MouseButton1Click:Connect(function() AuraFrame.Visible = not AuraFrame.Visible end)

SpeedTop.MouseButton1Click:Connect(function() SpeedFrame.Visible = not SpeedFrame.Visible end)

StarsTop.MouseButton1Click:Connect(function() StarsFrame.Visible = not StarsFrame.Visible end)

AVTop.MouseButton1Click:Connect(function() AVFrame.Visible = not AVFrame.Visible end)

--------------------------------------------------
-- LOOPS
--------------------------------------------------
task.spawn(function()
	while true do
		if KillauraEnabled then
			for _,p in ipairs(Players:GetPlayers()) do
				if p ~= LocalPlayer and not KillauraBlacklist[p.Name:lower()] then
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
		if isTouchingDashPad() and AntiRagdollEnabled then
			EnableRagdollRemotes()
			task.wait(0.5)
			disableRagdollRemotes()
		end
		task.wait(0.05)
	end
end)

task.spawn(function()
	while true do
		if StarsEnabled then
			local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
			local folder = workspace:FindFirstChild("ActiveStars")
			if hrp and folder then
				for _,star in ipairs(folder:GetChildren()) do
					local part = star:IsA("BasePart") and star or star:FindFirstChildWhichIsA("BasePart")
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

task.spawn(function()
	while true do
		if SpeedEnabled and LocalPlayer.Character then
			local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
			if hum then hum.WalkSpeed = SpeedValue end
		end
		task.wait(0.05)
	end
end)

task.spawn(function()
	while true do
		if TpAllEnabled then
			local myChar = LocalPlayer.Character
			local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")

			if myHRP then
				for _, player in ipairs(Players:GetPlayers()) do
					if player ~= LocalPlayer then
						local char = player.Character
						local hrp = char and char:FindFirstChild("HumanoidRootPart")

						if hrp then
							myHRP.CFrame = hrp.CFrame * CFrame.new(0,0,-2)
							task.wait(0.1)
						end
					end
				end
			end
		end
		print()
		task.wait(0.05)
	end
end)

-- CONFIG ADD
local function refreshUI()
	AuraBtn.Text = KillauraEnabled and "AURA ON" or "AURA OFF"
	AuraBtn.BackgroundColor3 = KillauraEnabled and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)

	SpeedBtn.Text = SpeedEnabled and "SPEED ON" or "SPEED OFF"
	SpeedBtn.BackgroundColor3 = SpeedEnabled and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
	SpeedBox.Text = tostring(SpeedValue)

	StarsBtn.Text = StarsEnabled and "STARS ON" or "STARS OFF"
	StarsBtn.BackgroundColor3 = StarsEnabled and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)

	AVBtn.Text = AntiVotekickEnabled and "AV ON" or "AV OFF"
	AVBtn.BackgroundColor3 = AntiVotekickEnabled and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)

	TpAllBtn.Text = TpAllEnabled and "TP ALL ON" or "TP ALL OFF"
	TpAllBtn.BackgroundColor3 = TpAllEnabled and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
end

loadConfig()
-- ALWAYS disable autoexec on script load



refreshUI()
if SpeedEnabled then
	LocalPlayer.CharacterAdded:Wait()
	local hum = LocalPlayer.Character:WaitForChild("Humanoid")
	hum.WalkSpeed = SpeedValue
end

ARBtn.Text = AntiRagdollEnabled and "AR ON" or "AR OFF"
ARBtn.BackgroundColor3 =
	AntiRagdollEnabled and Color3.fromRGB(0,170,0)
	or Color3.fromRGB(170,0,0)

-- AUTO RESET ONCE AFTER FULL LOAD
task.spawn(function()
	-- wait for player + first character
	local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	local hum = LocalPlayer.Character:WaitForChild("Humanoid")

	-- ensure everything is fully loaded
	task.wait(2)

	-- prevent running more than once (per execution)
	if getgenv()._DidAutoReset then return end
	getgenv()._DidAutoReset = true

	-- reset character
	hum.Health = 0
end)


saveConfig()
-- anti ragdoll 
task.spawn(function()
	while true do
		if AntiRagdollEnabled then
			applyAntiRagdoll()
		end
		task.wait(0.2)
	end
end)

-- TP ALL LOOP
task.spawn(function()
	while true do
		if TpAllEnabled then
			local myChar = LocalPlayer.Character
			local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")

			if myHRP then
				for _, player in ipairs(Players:GetPlayers()) do
					if player ~= LocalPlayer then
						local char = player.Character
						local hrp = char and char:FindFirstChild("HumanoidRootPart")

						if hrp then
							myHRP.CFrame = hrp.CFrame * CFrame.new(0,0,-2)
						end
					end
				end
			end
		end
	task.wait(0.05)
	end
end)
