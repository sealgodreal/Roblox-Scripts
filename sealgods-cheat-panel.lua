local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")
local originalWalkSpeed = Humanoid.WalkSpeed

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SealgodsCheatPanel"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 330)
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -140)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local dragging = false
local dragInput
local dragStart
local startPos

local function updateInput(input)
	if dragging then
		local delta = input.Position - dragStart
		MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end

MainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = MainFrame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then dragging = false end
		end)
	end
end)

MainFrame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput then updateInput(input) end
end)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Title.Text = "sealgods cheat panel"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

RunService.RenderStepped:Connect(function()
	local hue = (tick() * 0.2) % 1
	Title.TextColor3 = Color3.fromHSV(hue, 1, 1)
end)

local FlyToggle = Instance.new("TextButton")
FlyToggle.Size = UDim2.new(1, -20, 0, 45)
FlyToggle.Position = UDim2.new(0, 10, 0, 60)
FlyToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
FlyToggle.Text = "fly"
FlyToggle.TextColor3 = Color3.new(1,1,1)
FlyToggle.TextScaled = true
FlyToggle.Font = Enum.Font.Gotham
FlyToggle.Parent = MainFrame

local ESPToggle = Instance.new("TextButton")
ESPToggle.Size = UDim2.new(1, -20, 0, 45)
ESPToggle.Position = UDim2.new(0, 10, 0, 115)
ESPToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ESPToggle.Text = "esp"
ESPToggle.TextColor3 = Color3.new(1,1,1)
ESPToggle.TextScaled = true
ESPToggle.Font = Enum.Font.Gotham
ESPToggle.Parent = MainFrame

local NoclipToggle = Instance.new("TextButton")
NoclipToggle.Size = UDim2.new(1, -20, 0, 45)
NoclipToggle.Position = UDim2.new(0, 10, 0, 170)
NoclipToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
NoclipToggle.Text = "noclip"
NoclipToggle.TextColor3 = Color3.new(1,1,1)
NoclipToggle.TextScaled = true
NoclipToggle.Font = Enum.Font.Gotham
NoclipToggle.Parent = MainFrame

local SpeedToggle = Instance.new("TextButton")
SpeedToggle.Size = UDim2.new(1, -20, 0, 45)
SpeedToggle.Position = UDim2.new(0, 10, 0, 225)
SpeedToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SpeedToggle.Text = "speed boost"
SpeedToggle.TextColor3 = Color3.new(1,1,1)
SpeedToggle.TextScaled = true
SpeedToggle.Font = Enum.Font.Gotham
SpeedToggle.Parent = MainFrame

local flying = false
local espEnabled = false
local noclipEnabled = false
local speedBoostEnabled = false
local flySpeed = 70
local connections = {}
local espObjects = {}
local rainbowHue = 0
local bodyVelocity, bodyGyro

local function startFly()
	if flying then return end
	flying = true
	FlyToggle.BackgroundColor3 = Color3.fromRGB(0, 170, 0)

	bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	bodyVelocity.Velocity = Vector3.zero
	bodyVelocity.Parent = RootPart

	bodyGyro = Instance.new("BodyGyro")
	bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
	bodyGyro.P = 12500
	bodyGyro.CFrame = Camera.CFrame
	bodyGyro.Parent = RootPart

	Humanoid.PlatformStand = true

	table.insert(connections, RunService.RenderStepped:Connect(function()
		if not flying or not RootPart then return end

		local cam = Camera.CFrame
		local moveDir = Humanoid.MoveDirection
		local velocity = Vector3.zero

		if moveDir.Magnitude > 0 then
			local flatLook = Vector3.new(cam.LookVector.X, 0, cam.LookVector.Z)
			local flatRight = Vector3.new(cam.RightVector.X, 0, cam.RightVector.Z)

			if flatLook.Magnitude > 0 then flatLook = flatLook.Unit end
			if flatRight.Magnitude > 0 then flatRight = flatRight.Unit end

			local forwardAmount = moveDir:Dot(flatLook)
			local rightAmount = moveDir:Dot(flatRight)

			velocity = (cam.LookVector * forwardAmount) + (cam.RightVector * rightAmount)

			if velocity.Magnitude > 0 then
				velocity = velocity.Unit * flySpeed
			end
		end

		bodyVelocity.Velocity = velocity
		bodyGyro.CFrame = cam
	end))
end

local function stopFly()
	flying = false
	FlyToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	if bodyVelocity then bodyVelocity:Destroy() end
	if bodyGyro then bodyGyro:Destroy() end
	if Humanoid then Humanoid.PlatformStand = false end
end

local function createRainbowESP(plr)
	if plr == LocalPlayer or espObjects[plr] then return end
	local box = Drawing.new("Square")
	box.Thickness = 2
	box.Filled = true
	box.Transparency = 0.65
	espObjects[plr] = box
end

table.insert(connections, RunService.RenderStepped:Connect(function()
	if not espEnabled then return end
	rainbowHue = (rainbowHue + 0.015) % 1
	local color = Color3.fromHSV(rainbowHue, 1, 1)

	for plr, box in pairs(espObjects) do
		local char = plr.Character
		if char and char:FindFirstChild("HumanoidRootPart") then
			local root = char.HumanoidRootPart
			local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
			if onScreen then
				local top = Camera:WorldToViewportPoint(root.Position + Vector3.new(0, 3.5, 0))
				local bottom = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3.5, 0))
				
				box.Color = color
				box.Size = Vector2.new(math.max(2000 / (root.Position - Camera.CFrame.Position).Magnitude, 25), bottom.Y - top.Y)
				box.Position = Vector2.new(screenPos.X - box.Size.X/2, top.Y)
				box.Visible = true
			else
				box.Visible = false
			end
		else
			box.Visible = false
		end
	end
end))

local function enableESP()
	espEnabled = true
	ESPToggle.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
	for _, plr in ipairs(Players:GetPlayers()) do
		createRainbowESP(plr)
	end
end

local function disableESP()
	espEnabled = false
	ESPToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	for _, box in pairs(espObjects) do
		if box then box:Remove() end
	end
	espObjects = {}
end

local function enableNoclip()
	noclipEnabled = true
	NoclipToggle.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
	table.insert(connections, RunService.Stepped:Connect(function()
		if not noclipEnabled or not Character then return end
		for _, part in pairs(Character:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = false
			end
		end
	end))
end

local function disableNoclip()
	noclipEnabled = false
	NoclipToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	if Character then
		for _, part in pairs(Character:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = true
			end
		end
	end
end

local function enableSpeedBoost()
	speedBoostEnabled = true
	SpeedToggle.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
	if Humanoid then
		originalWalkSpeed = Humanoid.WalkSpeed
		Humanoid.WalkSpeed = originalWalkSpeed * 2
	end
end

local function disableSpeedBoost()
	speedBoostEnabled = false
	SpeedToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	if Humanoid then
		Humanoid.WalkSpeed = originalWalkSpeed
	end
end

FlyToggle.MouseButton1Click:Connect(function()
	if flying then stopFly() else startFly() end
end)

ESPToggle.MouseButton1Click:Connect(function()
	if espEnabled then disableESP() else enableESP() end
end)

NoclipToggle.MouseButton1Click:Connect(function()
	if noclipEnabled then disableNoclip() else enableNoclip() end
end)

SpeedToggle.MouseButton1Click:Connect(function()
	if speedBoostEnabled then disableSpeedBoost() else enableSpeedBoost() end
end)

LocalPlayer.CharacterAdded:Connect(function(newChar)
	Character = newChar
	Humanoid = newChar:WaitForChild("Humanoid")
	RootPart = newChar:WaitForChild("HumanoidRootPart")
	if flying then stopFly() end
	if speedBoostEnabled then
		Humanoid.WalkSpeed = originalWalkSpeed * 2
	end
end)

Players.PlayerAdded:Connect(function(plr)
	if espEnabled then createRainbowESP(plr) end
end)
