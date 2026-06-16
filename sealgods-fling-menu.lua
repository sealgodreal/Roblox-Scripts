local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

local character
local humanoid
local root

local activeTarget = nil
local flingConnection = nil
local startPosition = nil
local spinSpeed = 300

local playerButtons = {}

local function updateCharacter(char)
	character = char
	humanoid = char:WaitForChild("Humanoid")
	root = char:WaitForChild("HumanoidRootPart")

	if flingConnection then
		flingConnection:Disconnect()
		flingConnection = nil
	end

	activeTarget = nil
	startPosition = nil
end

updateCharacter(player.Character or player.CharacterAdded:Wait())

player.CharacterAdded:Connect(function(char)
	updateCharacter(char)
end)

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SealgodFlingMenu"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 200, 0, 300)
mainFrame.Position = UDim2.new(0.5, -100, 0.5, -150)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local dragging = false
local dragInput
local dragStart
local startPos

local function updateInput(input)
	if dragging then
		local delta = input.Position - dragStart

		mainFrame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end

mainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

mainFrame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput then
		updateInput(input)
	end
end)

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
title.Text = "sealgods fling menu"
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

RunService.RenderStepped:Connect(function()
	local hue = (tick() * 0.15) % 1
	title.TextColor3 = Color3.fromHSV(hue, 1, 1)
end)

local scrolling = Instance.new("ScrollingFrame")
scrolling.Name = "PlayerList"
scrolling.Size = UDim2.new(1, -20, 1, -70)
scrolling.Position = UDim2.new(0, 10, 0, 60)
scrolling.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
scrolling.BorderSizePixel = 0
scrolling.ScrollBarThickness = 6
scrolling.Parent = mainFrame

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.SortOrder = Enum.SortOrder.Name
uiListLayout.Padding = UDim.new(0, 5)
uiListLayout.Parent = scrolling

local function stopFling()
	activeTarget = nil

	if flingConnection then
		flingConnection:Disconnect()
		flingConnection = nil
	end

	if humanoid and humanoid.Parent then
		humanoid.PlatformStand = false
	end

	if root and root.Parent then
		root.AssemblyAngularVelocity = Vector3.zero

		if startPosition then
			root.CFrame = startPosition
		end
	end

	for _, button in pairs(playerButtons) do
		if button and button.Parent then
			button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		end
	end
end

local function createPlayerButton(plr)
	if plr == player then
		return
	end

	if playerButtons[plr] then
		return
	end

	local btn = Instance.new("TextButton")
	btn.Name = plr.Name
	btn.Size = UDim2.new(1, 0, 0, 40)
	btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	btn.Text = plr.Name
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.TextScaled = true
	btn.Font = Enum.Font.Gotham
	btn.Parent = scrolling

	playerButtons[plr] = btn

	btn.MouseButton1Click:Connect(function()
		if activeTarget == plr then
			stopFling()
			return
		end

		for _, otherButton in pairs(playerButtons) do
			if otherButton and otherButton.Parent then
				otherButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
			end
		end

		activeTarget = plr
		startPosition = root and root.CFrame

		btn.BackgroundColor3 = Color3.fromRGB(100, 200, 100)

		if flingConnection then
			flingConnection:Disconnect()
		end

		flingConnection = RunService.Heartbeat:Connect(function()
			if not root or not root.Parent then
				stopFling()
				return
			end

			if not activeTarget then
				stopFling()
				return
			end

			local targetChar = activeTarget.Character

			if not targetChar then
				stopFling()
				return
			end

			local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")

			if not targetRoot then
				stopFling()
				return
			end

			root.CFrame =
				targetRoot.CFrame *
				CFrame.Angles(0, math.rad(tick() * spinSpeed), 0)

			humanoid.PlatformStand = true
			root.AssemblyAngularVelocity =
				Vector3.new(0, spinSpeed * 15, 0)

			root.AssemblyLinearVelocity =
				Vector3.new(0, 10, 0)
		end)
	end)
end

local function removePlayerButton(plr)
	local btn = playerButtons[plr]

	if btn then
		btn:Destroy()
		playerButtons[plr] = nil
	end

	if activeTarget == plr then
		stopFling()
	end
end

for _, plr in ipairs(Players:GetPlayers()) do
	createPlayerButton(plr)
end

Players.PlayerAdded:Connect(createPlayerButton)
Players.PlayerRemoving:Connect(removePlayerButton)

local function updateCanvas()
	scrolling.CanvasSize = UDim2.new(
		0,
		0,
		0,
		uiListLayout.AbsoluteContentSize.Y + 5
	)
end

uiListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
updateCanvas()
