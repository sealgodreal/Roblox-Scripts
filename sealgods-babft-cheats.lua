-- work in progress!!
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SealgodsBabftCheats"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 260, 0, 340)
MainFrame.Position = UDim2.new(0.5, -130, 0.5, -170)
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
Title.Text = "sealgods babft cheats"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

RunService.RenderStepped:Connect(function()
	local hue = (tick() * 0.2) % 1
	Title.TextColor3 = Color3.fromHSV(hue, 1, 1)
end)

local AntiAFKToggle = Instance.new("TextButton")
AntiAFKToggle.Size = UDim2.new(1, -20, 0, 70)
AntiAFKToggle.Position = UDim2.new(0, 10, 0, 70)
AntiAFKToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
AntiAFKToggle.Text = "anti afk kick"
AntiAFKToggle.TextColor3 = Color3.new(1,1,1)
AntiAFKToggle.TextScaled = true
AntiAFKToggle.Font = Enum.Font.Gotham
AntiAFKToggle.Parent = MainFrame

local AutoFarmToggle = Instance.new("TextButton")
AutoFarmToggle.Size = UDim2.new(1, -20, 0, 70)
AutoFarmToggle.Position = UDim2.new(0, 10, 0, 150)
AutoFarmToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
AutoFarmToggle.Text = "auto farm"
AutoFarmToggle.TextColor3 = Color3.new(1,1,1)
AutoFarmToggle.TextScaled = true
AutoFarmToggle.Font = Enum.Font.Gotham
AutoFarmToggle.Parent = MainFrame

local TeleportMenuButton = Instance.new("TextButton")
TeleportMenuButton.Size = UDim2.new(1, -20, 0, 70)
TeleportMenuButton.Position = UDim2.new(0, 10, 0, 230)
TeleportMenuButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
TeleportMenuButton.Text = "teleport menu"
TeleportMenuButton.TextColor3 = Color3.new(1,1,1)
TeleportMenuButton.TextScaled = true
TeleportMenuButton.Font = Enum.Font.Gotham
TeleportMenuButton.Parent = MainFrame

local autoFarmEnabled = false
local antiAFKEnabled = false
local allPlatforms = {}

local stagePositions = {
	Vector3.new(-56, 53, 1841), Vector3.new(-71, 47, 2493),
	Vector3.new(-56, 27, 3346), Vector3.new(-62, 41, 4204),
	Vector3.new(-80, 73, 4921), Vector3.new(-86, 54, 5558),
	Vector3.new(-73, 61, 6556), Vector3.new(-64, 19, 7172),
	Vector3.new(-81, 61, 7949), Vector3.new(-57, 28, 8686),
	Vector3.new(-54, -358, 9496)
}

local function createPlatform(pos)
	local size = 20
	local thickness = 0.5
	local platform = Instance.new("Part")
	platform.Size = Vector3.new(size, thickness, size)
	platform.Position = pos + Vector3.new(0, thickness/2 + 3, 0)
	platform.Anchored = true
	platform.Transparency = 1
	platform.Color = Color3.fromRGB(0, 170, 255)
	platform.CanCollide = true
	platform.Parent = workspace
	return {platform}
end

local function clearAllPlatforms()
	for _, platformParts in ipairs(allPlatforms) do
		for _, part in ipairs(platformParts) do
			if part and part.Parent then part:Destroy() end
		end
	end
	allPlatforms = {}
end

local function createAllPlatforms()
	clearAllPlatforms()
	for _, pos in ipairs(stagePositions) do
		table.insert(allPlatforms, createPlatform(pos))
	end
end

local function teleportToStage(stageIndex)
	if not Character or not RootPart then return end
	local targetPos = stagePositions[stageIndex]
	if targetPos then
		RootPart.CFrame = CFrame.new(targetPos + Vector3.new(0, 8, 0))
	end
end

local function killPlayer()
	if Humanoid then Humanoid.Health = 0 end
end

local function runFarmSequence()
	for i = 1, #stagePositions do
		if not autoFarmEnabled then return end
		teleportToStage(i)
		wait(3)
	end
end

local function startAutoFarm()
	autoFarmEnabled = true
	AutoFarmToggle.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
	createAllPlatforms()
	killPlayer()
	
	local respawnConn
	respawnConn = LocalPlayer.CharacterAdded:Connect(function(newChar)
		if not autoFarmEnabled then respawnConn:Disconnect() return end
		Character = newChar
		Humanoid = newChar:WaitForChild("Humanoid")
		RootPart = newChar:WaitForChild("HumanoidRootPart")
		wait(1)
		runFarmSequence()
	end)
end

local function stopAutoFarm()
	autoFarmEnabled = false
	AutoFarmToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	clearAllPlatforms()
end

local antiAFKConnection
local tapPositions = {Vector2.new(50,50), Vector2.new(1200,50), Vector2.new(50,650), Vector2.new(1200,650)}

local function simulateTap(position)
	VirtualUser:Button2Down(position, Camera.CFrame)
	wait(0.05)
	VirtualUser:Button2Up(position, Camera.CFrame)
end

local function startAntiAFK()
	antiAFKEnabled = true
	AntiAFKToggle.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
	antiAFKConnection = RunService.Heartbeat:Connect(function()
		if not antiAFKEnabled then return end
		if tick() % 60 < 0.1 then
			for _, pos in ipairs(tapPositions) do
				simulateTap(pos)
				wait(0.3)
			end
		end
	end)
end

local function stopAntiAFK()
	antiAFKEnabled = false
	AntiAFKToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	if antiAFKConnection then 
		antiAFKConnection:Disconnect() 
		antiAFKConnection = nil 
	end
end

local TPFrame
local function createTeleportMenu()
	if TPFrame then TPFrame:Destroy() end
	
	TPFrame = Instance.new("Frame")
	TPFrame.Name = "TPFrame"
	TPFrame.Size = UDim2.new(0, 260, 0, 400)
	TPFrame.Position = UDim2.new(0.5, 150, 0.5, -200)
	TPFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	TPFrame.BorderSizePixel = 0
	TPFrame.Parent = ScreenGui
	
	local tpDragging = false
	local tpDragInput
	local tpDragStart
	local tpStartPos
	
	local function tpUpdateInput(input)
		if tpDragging then
			local delta = input.Position - tpDragStart
			TPFrame.Position = UDim2.new(tpStartPos.X.Scale, tpStartPos.X.Offset + delta.X, tpStartPos.Y.Scale, tpStartPos.Y.Offset + delta.Y)
		end
	end
	
	TPFrame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			tpDragging = true
			tpDragStart = input.Position
			tpStartPos = TPFrame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then tpDragging = false end
			end)
		end
	end)
	
	TPFrame.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			tpDragInput = input
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if input == tpDragInput then tpUpdateInput(input) end
	end)
	
	local TPTitle = Instance.new("TextLabel")
	TPTitle.Size = UDim2.new(1, 0, 0, 50)
	TPTitle.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	TPTitle.Text = "sealgods babft tp menu"
	TPTitle.TextColor3 = Color3.new(1,1,1)
	TPTitle.TextScaled = true
	TPTitle.Font = Enum.Font.GothamBold
	TPTitle.Parent = TPFrame
	
	RunService.RenderStepped:Connect(function()
		local hue = (tick() * 0.2) % 1
		TPTitle.TextColor3 = Color3.fromHSV(hue, 1, 1)
	end)
	
	local CloseButton = Instance.new("TextButton")
	CloseButton.Size = UDim2.new(0, 24, 0, 24)
	CloseButton.Position = UDim2.new(1, -28, 0, 8)
	CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	CloseButton.Text = "X"
	CloseButton.TextColor3 = Color3.new(1,1,1)
	CloseButton.TextScaled = true
	CloseButton.Font = Enum.Font.GothamBold
	CloseButton.Parent = TPFrame
	
	CloseButton.MouseButton1Click:Connect(function()
		TPFrame:Destroy()
		TPFrame = nil
	end)
	
	local ScrollingFrame = Instance.new("ScrollingFrame")
	ScrollingFrame.Size = UDim2.new(1, -20, 1, -70)
	ScrollingFrame.Position = UDim2.new(0, 10, 0, 60)
	ScrollingFrame.BackgroundTransparency = 1
	ScrollingFrame.ScrollBarThickness = 8
	ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	ScrollingFrame.Parent = TPFrame
	
	local UIListLayout = Instance.new("UIListLayout")
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout.Padding = UDim.new(0, 10)
	UIListLayout.Parent = ScrollingFrame
	
	local teleports = {
		{ name = "chest", pos = Vector3.new(-54, -358, 9475) },
		{ name = "white team", pos = Vector3.new(-50, -10, -511) },
		{ name = "red team", pos = Vector3.new(392, -10, -65) },
		{ name = "black team", pos = Vector3.new(-494, -10, -70) },
		{ name = "blue team", pos = Vector3.new(389, -10, 300) },
		{ name = "green team", pos = Vector3.new(-498, -10, 294) },
		{ name = "magenta team", pos = Vector3.new(389, -10, 647) },
		{ name = "yellow team", pos = Vector3.new(-496, -10, 641) },
	}
	
	local function createTPButton(name, position)
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, 0, 0, 50)
		btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		btn.Text = name
		btn.TextColor3 = Color3.new(1,1,1)
		btn.TextScaled = true
		btn.Font = Enum.Font.Gotham
		btn.Parent = ScrollingFrame
		
		btn.MouseButton1Click:Connect(function()
			if RootPart then
				RootPart.CFrame = CFrame.new(position + Vector3.new(0, 8, 0))
			end
		end)
	end
	
	for _, tp in ipairs(teleports) do
		createTPButton(tp.name, tp.pos)
	end
	
	UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 20)
	end)
end

AntiAFKToggle.MouseButton1Click:Connect(function()
	if antiAFKEnabled then stopAntiAFK() else startAntiAFK() end
end)

AutoFarmToggle.MouseButton1Click:Connect(function()
	if autoFarmEnabled then stopAutoFarm() else startAutoFarm() end
end)

TeleportMenuButton.MouseButton1Click:Connect(function()
	createTeleportMenu()
end)

LocalPlayer.CharacterAdded:Connect(function(newChar)
	Character = newChar
	Humanoid = newChar:WaitForChild("Humanoid")
	RootPart = newChar:WaitForChild("HumanoidRootPart")
end)
