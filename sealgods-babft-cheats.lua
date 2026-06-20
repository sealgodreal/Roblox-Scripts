-- MASSIVE ui update
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SealgodsBabftCheats"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 0)
MainFrame.AutomaticSize = Enum.AutomaticSize.Y
MainFrame.Position = UDim2.new(0.5, -150, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
MainFrame.BackgroundTransparency = 0.05
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = false
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = MainFrame

local GlowBorder = Instance.new("Frame")
GlowBorder.Size = UDim2.new(1, 4, 1, 4)
GlowBorder.Position = UDim2.new(0, -2, 0, -2)
GlowBorder.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
GlowBorder.BackgroundTransparency = 0.3
GlowBorder.BorderSizePixel = 0
GlowBorder.ZIndex = 0
GlowBorder.Parent = MainFrame

local GlowCorner = Instance.new("UICorner")
GlowCorner.CornerRadius = UDim.new(0, 14)
GlowCorner.Parent = GlowBorder

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 45)
Header.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Header.BackgroundTransparency = 0.1
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 12)
HeaderCorner.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "seal's babft cheats"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local CategoryBar = Instance.new("Frame")
CategoryBar.Size = UDim2.new(1, -20, 0, 30)
CategoryBar.Position = UDim2.new(0, 10, 0, 50)
CategoryBar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
CategoryBar.BackgroundTransparency = 0.2
CategoryBar.Parent = MainFrame

local CategoryCorner = Instance.new("UICorner")
CategoryCorner.CornerRadius = UDim.new(0, 8)
CategoryCorner.Parent = CategoryBar

local categories = {"General", "Misc", "Credits"}
local categoryButtons = {}

for i, cat in ipairs(categories) do
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.333, -2, 1, -4)
	btn.Position = UDim2.new((i-1) * 0.333 + 0.002, 0, 0, 2)
	btn.BackgroundTransparency = 1
	btn.Text = cat
	btn.TextColor3 = Color3.fromRGB(180, 180, 190)
	btn.TextScaled = true
	btn.Font = Enum.Font.GothamSemibold
	btn.BorderSizePixel = 0
	btn.Parent = CategoryBar
	table.insert(categoryButtons, btn)
end

categoryButtons[1].TextColor3 = Color3.fromRGB(255, 255, 255)
categoryButtons[1].BackgroundColor3 = Color3.fromRGB(40, 40, 50)
categoryButtons[1].BackgroundTransparency = 0.2

local CategoryCorner2 = Instance.new("UICorner")
CategoryCorner2.CornerRadius = UDim.new(0, 6)
CategoryCorner2.Parent = categoryButtons[1]

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

local ButtonContainer = Instance.new("Frame")
ButtonContainer.Size = UDim2.new(1, -24, 0, 0)
ButtonContainer.AutomaticSize = Enum.AutomaticSize.Y
ButtonContainer.Position = UDim2.new(0, 12, 0, 88)
ButtonContainer.BackgroundTransparency = 1
ButtonContainer.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ButtonContainer
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local UIPadding = Instance.new("UIPadding")
UIPadding.PaddingBottom = UDim.new(0, 15)
UIPadding.Parent = ButtonContainer

local GREEN = Color3.fromRGB(0, 200, 80)

local buttonStates = {}

local function createButton(text, color, isToggle)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 40)
	btn.BackgroundColor3 = color or Color3.fromRGB(30, 30, 40)
	btn.BackgroundTransparency = 0.2
	btn.Text = text
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.TextScaled = true
	btn.Font = Enum.Font.GothamSemibold
	btn.BorderSizePixel = 0
	btn.Parent = ButtonContainer
	
	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 8)
	btnCorner.Parent = btn
	
	local state = {
		button = btn,
		originalColor = color or Color3.fromRGB(30, 30, 40),
		originalTransparency = 0.2,
		toggled = false
	}
	buttonStates[btn] = state
	
	btn.MouseEnter:Connect(function()
		if isToggle and state.toggled then return end
		TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.05}):Play()
	end)
	
	btn.MouseLeave:Connect(function()
		if isToggle and state.toggled then return end
		TweenService:Create(btn, TweenInfo.new(0.2), {
			BackgroundColor3 = state.originalColor,
			BackgroundTransparency = state.originalTransparency
		}):Play()
	end)
	
	return btn, state
end

local AutoFarmToggle, autoFarmState = createButton("AutoFarm", Color3.fromRGB(30, 30, 40), true)

local AntiAFKToggle, antiAFKState = createButton("Anti-Afk", Color3.fromRGB(30, 30, 40), true)
local ServerHopButton, serverHopState = createButton("Server Hop", Color3.fromRGB(30, 30, 40), false)
local TeleportMenuButton, teleportState = createButton("Teleport Menu", Color3.fromRGB(30, 30, 40), false)

AntiAFKToggle.Visible = false
ServerHopButton.Visible = false
TeleportMenuButton.Visible = false

local StatsContainer = Instance.new("Frame")
StatsContainer.Size = UDim2.new(1, 0, 0, 0)
StatsContainer.AutomaticSize = Enum.AutomaticSize.Y
StatsContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
StatsContainer.BackgroundTransparency = 0.2
StatsContainer.Parent = ButtonContainer

local StatsCorner = Instance.new("UICorner")
StatsCorner.CornerRadius = UDim.new(0, 8)
StatsCorner.Parent = StatsContainer

local StatsLabel = Instance.new("TextLabel")
StatsLabel.Size = UDim2.new(1, -20, 0, 25)
StatsLabel.Position = UDim2.new(0, 10, 0, 5)
StatsLabel.BackgroundTransparency = 1
StatsLabel.Text = "Stats"
StatsLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
StatsLabel.TextScaled = true
StatsLabel.Font = Enum.Font.GothamBold
StatsLabel.TextXAlignment = Enum.TextXAlignment.Left
StatsLabel.Parent = StatsContainer

local StatsList = Instance.new("UIListLayout")
StatsList.Parent = StatsContainer
StatsList.SortOrder = Enum.SortOrder.LayoutOrder
StatsList.Padding = UDim.new(0, 3)

local function createStatLine(text)
	local line = Instance.new("TextLabel")
	line.Size = UDim2.new(1, -20, 0, 18)
	line.Position = UDim2.new(0, 10, 0, 0)
	line.BackgroundTransparency = 1
	line.Text = text
	line.TextColor3 = Color3.fromRGB(180, 180, 190)
	line.TextScaled = true
	line.Font = Enum.Font.Gotham
	line.TextXAlignment = Enum.TextXAlignment.Left
	line.Parent = StatsContainer
	return line
end

local timeLine = createStatLine("Elapsed Time: 00:00:00")
local goldBlocksLine = createStatLine("Gold Blocks Gained: 0")
local totalGoldLine = createStatLine("Gold Gained: 0")
local gphLine = createStatLine("Gold Per Hour: Calculating...")

local CreditsContainer = Instance.new("Frame")
CreditsContainer.Size = UDim2.new(1, 0, 0, 0)
CreditsContainer.AutomaticSize = Enum.AutomaticSize.Y
CreditsContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
CreditsContainer.BackgroundTransparency = 0.2
CreditsContainer.Visible = false
CreditsContainer.Parent = ButtonContainer

local CreditsCorner = Instance.new("UICorner")
CreditsCorner.CornerRadius = UDim.new(0, 8)
CreditsCorner.Parent = CreditsContainer

local CreditsText1 = Instance.new("TextLabel")
CreditsText1.Size = UDim2.new(1, -20, 0, 30)
CreditsText1.Position = UDim2.new(0, 10, 0, 10)
CreditsText1.BackgroundTransparency = 1
CreditsText1.Text = "This exploit panel was created by only sealgod."
CreditsText1.TextColor3 = Color3.fromRGB(200, 200, 210)
CreditsText1.TextScaled = true
CreditsText1.Font = Enum.Font.Gotham
CreditsText1.TextWrapped = true
CreditsText1.Parent = CreditsContainer

local CreditsText2 = Instance.new("TextLabel")
CreditsText2.Size = UDim2.new(1, -20, 0, 30)
CreditsText2.Position = UDim2.new(0, 10, 0, 45)
CreditsText2.BackgroundTransparency = 1
CreditsText2.Text = "Discord: @sealgawd"
CreditsText2.TextColor3 = Color3.fromRGB(180, 180, 190)
CreditsText2.TextScaled = true
CreditsText2.Font = Enum.Font.Gotham
CreditsText2.Parent = CreditsContainer

local CreditsText3 = Instance.new("TextLabel")
CreditsText3.Size = UDim2.new(1, -20, 0, 30)
CreditsText3.Position = UDim2.new(0, 10, 0, 80)
CreditsText3.BackgroundTransparency = 1
CreditsText3.Text = "GitHub: @sealgodreal"
CreditsText3.TextColor3 = Color3.fromRGB(180, 180, 190)
CreditsText3.TextScaled = true
CreditsText3.Font = Enum.Font.Gotham
CreditsText3.Parent = CreditsContainer

local TPFrame = nil
local isTPMenuOpen = false

local function updateTPPosition()
	if TPFrame and isTPMenuOpen then
		TPFrame.Position = MainFrame.Position + UDim2.new(0, 310, 0, 0)
	end
end

MainFrame:GetPropertyChangedSignal("Position"):Connect(updateTPPosition)

local function createTeleportMenu()
	if TPFrame then
		TPFrame:Destroy()
		TPFrame = nil
		isTPMenuOpen = false
		return
	end
	
	isTPMenuOpen = true
	
	TPFrame = Instance.new("Frame")
	TPFrame.Name = "TPFrame"
	TPFrame.Size = UDim2.new(0, 300, 0, 0)
	TPFrame.AutomaticSize = Enum.AutomaticSize.Y
	TPFrame.Position = MainFrame.Position + UDim2.new(0, 310, 0, 0)
	TPFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
	TPFrame.BackgroundTransparency = 0.05
	TPFrame.BorderSizePixel = 0
	TPFrame.ClipsDescendants = true
	TPFrame.Parent = ScreenGui
	
	local tpCorner = Instance.new("UICorner")
	tpCorner.CornerRadius = UDim.new(0, 12)
	tpCorner.Parent = TPFrame
	
	local tpGlow = Instance.new("Frame")
	tpGlow.Size = UDim2.new(1, 4, 1, 4)
	tpGlow.Position = UDim2.new(0, -2, 0, -2)
	tpGlow.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	tpGlow.BackgroundTransparency = 0.3
	tpGlow.BorderSizePixel = 0
	tpGlow.ZIndex = 0
	tpGlow.Parent = TPFrame
	
	local tpGlowCorner = Instance.new("UICorner")
	tpGlowCorner.CornerRadius = UDim.new(0, 14)
	tpGlowCorner.Parent = tpGlow
	
	local tpHeader = Instance.new("Frame")
	tpHeader.Size = UDim2.new(1, 0, 0, 45)
	tpHeader.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
	tpHeader.BackgroundTransparency = 0.1
	tpHeader.Parent = TPFrame
	
	local tpHeaderCorner = Instance.new("UICorner")
	tpHeaderCorner.CornerRadius = UDim.new(0, 12)
	tpHeaderCorner.Parent = tpHeader
	
	local TPTitle = Instance.new("TextLabel")
	TPTitle.Size = UDim2.new(1, -60, 1, 0)
	TPTitle.Position = UDim2.new(0, 15, 0, 0)
	TPTitle.BackgroundTransparency = 1
	TPTitle.Text = "Teleport Menu"
	TPTitle.TextColor3 = Color3.new(1, 1, 1)
	TPTitle.TextScaled = true
	TPTitle.Font = Enum.Font.GothamBold
	TPTitle.TextXAlignment = Enum.TextXAlignment.Left
	TPTitle.Parent = tpHeader
	
	local CloseButton = Instance.new("TextButton")
	CloseButton.Size = UDim2.new(0, 30, 0, 30)
	CloseButton.Position = UDim2.new(1, -40, 0, 8)
	CloseButton.BackgroundColor3 = Color3.fromRGB(150, 20, 20)
	CloseButton.BackgroundTransparency = 0.3
	CloseButton.Text = "X"
	CloseButton.TextColor3 = Color3.new(1, 1, 1)
	CloseButton.TextScaled = true
	CloseButton.Font = Enum.Font.GothamBold
	CloseButton.BorderSizePixel = 0
	CloseButton.Parent = tpHeader
	
	local cc = Instance.new("UICorner")
	cc.CornerRadius = UDim.new(0, 6)
	cc.Parent = CloseButton
	
	CloseButton.MouseButton1Click:Connect(function()
		if TPFrame then
			TPFrame:Destroy()
			TPFrame = nil
			isTPMenuOpen = false
		end
	end)
	
	local TPScroll = Instance.new("ScrollingFrame")
	TPScroll.Size = UDim2.new(1, -24, 0, 280)
	TPScroll.Position = UDim2.new(0, 12, 0, 55)
	TPScroll.BackgroundTransparency = 1
	TPScroll.BorderSizePixel = 0
	TPScroll.ScrollBarThickness = 6
	TPScroll.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 70)
	TPScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	TPScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	TPScroll.Parent = TPFrame
	
	local TPContainer = Instance.new("Frame")
	TPContainer.Size = UDim2.new(1, 0, 0, 0)
	TPContainer.AutomaticSize = Enum.AutomaticSize.Y
	TPContainer.BackgroundTransparency = 1
	TPContainer.Parent = TPScroll
	
	local TPList = Instance.new("UIListLayout")
	TPList.Parent = TPContainer
	TPList.SortOrder = Enum.SortOrder.LayoutOrder
	TPList.Padding = UDim.new(0, 8)
	TPList.HorizontalAlignment = Enum.HorizontalAlignment.Center
	
	local TPPad = Instance.new("UIPadding")
	TPPad.PaddingBottom = UDim.new(0, 15)
	TPPad.Parent = TPContainer
	
	local teleports = {
		{name = "Chest", pos = Vector3.new(-54, -358, 9475)},
		{name = "White Team", pos = Vector3.new(-50, -10, -511)},
		{name = "Red Team", pos = Vector3.new(392, -10, -65)},
		{name = "Black Team", pos = Vector3.new(-494, -10, -70)},
		{name = "Blue Team", pos = Vector3.new(389, -10, 300)},
		{name = "Green Team", pos = Vector3.new(-498, -10, 294)},
		{name = "Magenta Team", pos = Vector3.new(389, -10, 647)},
		{name = "Yellow Team", pos = Vector3.new(-496, -10, 641)},
	}
	
	for _, tp in ipairs(teleports) do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, 0, 0, 40)
		btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
		btn.BackgroundTransparency = 0.2
		btn.Text = tp.name
		btn.TextColor3 = Color3.new(1, 1, 1)
		btn.TextScaled = true
		btn.Font = Enum.Font.GothamSemibold
		btn.BorderSizePixel = 0
		btn.Parent = TPContainer
		
		local bc = Instance.new("UICorner")
		bc.CornerRadius = UDim.new(0, 8)
		bc.Parent = btn
		
		btn.MouseButton1Click:Connect(function()
			if RootPart then
				RootPart.CFrame = CFrame.new(tp.pos + Vector3.new(0, 8, 0))
			end
		end)
	end
	
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
end

local autoFarmEnabled = false
local antiAFKEnabled = false
local allPlatforms = {}
local startTime = tick()
local goldBlocksCompleted = 0
local startGold = 0
local totalGoldGained = 0
local goldHistory = {}
local isFarming = false
local farmLoopActive = false
local stageCycleCompleted = false

local function getCurrentGold()
	local goldValue = 0
	
	local backpack = LocalPlayer:FindFirstChild("Backpack")
	if backpack then
		local gold = backpack:FindFirstChild("Gold")
		if gold then
			pcall(function()
				goldValue = gold.Value or 0
			end)
			if goldValue > 0 then return goldValue end
		end
	end
	
	local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
	if leaderstats then
		local gold = leaderstats:FindFirstChild("Gold")
		if gold then
			pcall(function()
				goldValue = gold.Value or 0
			end)
			if goldValue > 0 then return goldValue end
		end
	end
	
	local stats = LocalPlayer:FindFirstChild("stats")
	if stats then
		local gold = stats:FindFirstChild("Gold")
		if gold then
			pcall(function()
				goldValue = gold.Value or 0
			end)
			if goldValue > 0 then return goldValue end
		end
	end
	
	local data = LocalPlayer:FindFirstChild("Data")
	if data then
		local gold = data:FindFirstChild("Gold")
		if gold then
			pcall(function()
				goldValue = gold.Value or 0
			end)
			if goldValue > 0 then return goldValue end
		end
	end
	
	return goldValue
end

local function trackGoldChange()
	local newGold = getCurrentGold()
	if newGold > startGold then
		local gained = newGold - startGold
		totalGoldGained = totalGoldGained + gained
		startGold = newGold
		totalGoldLine.Text = "Gold Gained: " .. totalGoldGained
		
		table.insert(goldHistory, {
			time = tick(),
			gold = totalGoldGained
		})
		
		local cutoff = tick() - 600
		for i = #goldHistory, 1, -1 do
			if goldHistory[i].time < cutoff then
				table.remove(goldHistory, i)
			end
		end
		
		if #goldHistory >= 2 then
			local oldest = goldHistory[1]
			local newest = goldHistory[#goldHistory]
			local timeDiff = newest.time - oldest.time
			if timeDiff > 0 then
				local goldDiff = newest.gold - oldest.gold
				local gph = (goldDiff / timeDiff) * 3600
				if gph > 0 then
					gphLine.Text = "Gold Per Hour: " .. math.floor(gph)
				end
			end
		end
		
		return gained
	end
	return 0
end

local stagePositions = {
	Vector3.new(-56, 53, 1841), Vector3.new(-71, 47, 2493),
	Vector3.new(-56, 27, 3346), Vector3.new(-62, 41, 4204),
	Vector3.new(-80, 73, 4921), Vector3.new(-86, 54, 5558),
	Vector3.new(-73, 61, 6556), Vector3.new(-64, 19, 7172),
	Vector3.new(-81, 61, 7949), Vector3.new(-57, 28, 8686),
	Vector3.new(-54, -358, 9493)
}

local function createPlatform(pos)
	local platform = Instance.new("Part")
	platform.Size = Vector3.new(20, 0.5, 20)
	platform.Position = pos + Vector3.new(0, 3.25, 0)
	platform.Anchored = true
	platform.Transparency = 1
	platform.CanCollide = true
	platform.Parent = workspace
	return {platform}
end

local function clearAllPlatforms()
	for _, parts in ipairs(allPlatforms) do
		for _, p in ipairs(parts) do
			if p and p.Parent then p:Destroy() end
		end
	end
	allPlatforms = {}
end

local function createAllPlatforms()
	clearAllPlatforms()
	for i = 1, #stagePositions - 1 do
		table.insert(allPlatforms, createPlatform(stagePositions[i]))
	end
end

local function teleportToStage(i)
	if RootPart and stagePositions[i] then
		RootPart.CFrame = CFrame.new(stagePositions[i] + Vector3.new(0, 8, 0))
	end
end

local function killPlayer()
	if Humanoid then 
		Humanoid.Health = 0 
	end
end

local function farmLoop()
	if farmLoopActive then return end
	farmLoopActive = true
	stageCycleCompleted = false
	
	while autoFarmEnabled do
		for i = 1, #stagePositions do
			if not autoFarmEnabled then 
				farmLoopActive = false
				return 
			end
			
			teleportToStage(i)
			task.wait(0.5)
			trackGoldChange()
			task.wait(2.5)
		end
		
		stageCycleCompleted = true
		
		if autoFarmEnabled then
			local respawnConn
			local respawned = false
			
			respawnConn = LocalPlayer.CharacterAdded:Connect(function(newChar)
				respawnConn:Disconnect()
				respawned = true
				
				Character = newChar
				Humanoid = newChar:WaitForChild("Humanoid")
				RootPart = newChar:WaitForChild("HumanoidRootPart")
				
				if stageCycleCompleted then
					goldBlocksCompleted = goldBlocksCompleted + 1
					goldBlocksLine.Text = "Gold Blocks Gained: " .. goldBlocksCompleted
					stageCycleCompleted = false
				end
				
				task.wait(1)
			end)
			
			local timeout = 0
			while not respawned and autoFarmEnabled and timeout < 30 do
				task.wait(1)
				timeout = timeout + 1
			end
			
			if timeout >= 30 then
				if autoFarmEnabled then
					killPlayer()
					local manualRespawnConn
					local manualRespawned = false
					manualRespawnConn = LocalPlayer.CharacterAdded:Connect(function(newChar)
						manualRespawnConn:Disconnect()
						manualRespawned = true
						
						Character = newChar
						Humanoid = newChar:WaitForChild("Humanoid")
						RootPart = newChar:WaitForChild("HumanoidRootPart")
						
						if stageCycleCompleted then
							goldBlocksCompleted = goldBlocksCompleted + 1
							goldBlocksLine.Text = "Gold Blocks Gained: " .. goldBlocksCompleted
							stageCycleCompleted = false
						end
						
						task.wait(1)
					end)
					
					local manualTimeout = 0
					while not manualRespawned and autoFarmEnabled and manualTimeout < 30 do
						task.wait(1)
						manualTimeout = manualTimeout + 1
					end
				end
			end
		end
	end
	
	farmLoopActive = false
end

local function startAutoFarm()
	if autoFarmEnabled then return end
	
	autoFarmEnabled = true
	isFarming = true
	autoFarmState.toggled = true
	TweenService:Create(AutoFarmToggle, TweenInfo.new(0.2), {BackgroundColor3 = GREEN, BackgroundTransparency = 0.05}):Play()
	
	startGold = getCurrentGold()
	totalGoldGained = 0
	goldBlocksCompleted = 0
	goldHistory = {}
	stageCycleCompleted = false
	gphLine.Text = "Gold Per Hour: Calculating..."
	goldBlocksLine.Text = "Gold Blocks Gained: 0"
	totalGoldLine.Text = "Gold Gained: 0"
	
	createAllPlatforms()
	
	killPlayer()
	
	local respawnConn
	respawnConn = LocalPlayer.CharacterAdded:Connect(function(newChar)
		respawnConn:Disconnect()
		if not autoFarmEnabled then return end
		
		Character = newChar
		Humanoid = newChar:WaitForChild("Humanoid")
		RootPart = newChar:WaitForChild("HumanoidRootPart")
		
		task.wait(1)
		
		if autoFarmEnabled then
			coroutine.wrap(farmLoop)()
		end
	end)
end

local function stopAutoFarm()
	autoFarmEnabled = false
	isFarming = false
	farmLoopActive = false
	stageCycleCompleted = false
	autoFarmState.toggled = false
	TweenService:Create(AutoFarmToggle, TweenInfo.new(0.2), {BackgroundColor3 = autoFarmState.originalColor, BackgroundTransparency = autoFarmState.originalTransparency}):Play()
	clearAllPlatforms()
	
	totalGoldLine.Text = "Gold Gained: 0"
	gphLine.Text = "Gold Per Hour: 0"
	goldBlocksLine.Text = "Gold Blocks Gained: 0"
end

local antiAFKConnection
local tapPositions = {Vector2.new(50,50), Vector2.new(1200,50), Vector2.new(50,650), Vector2.new(1200,650)}

local function simulateTap(position)
	VirtualUser:Button2Down(position, Camera.CFrame)
	task.wait(0.05)
	VirtualUser:Button2Up(position, Camera.CFrame)
end

local function startAntiAFK()
	antiAFKEnabled = true
	antiAFKState.toggled = true
	TweenService:Create(AntiAFKToggle, TweenInfo.new(0.2), {BackgroundColor3 = GREEN, BackgroundTransparency = 0.05}):Play()
	antiAFKConnection = RunService.Heartbeat:Connect(function()
		if not antiAFKEnabled then return end
		if tick() % 60 < 0.1 then
			for _, pos in ipairs(tapPositions) do
				simulateTap(pos)
				task.wait(0.3)
			end
		end
	end)
end

local function stopAntiAFK()
	antiAFKEnabled = false
	antiAFKState.toggled = false
	TweenService:Create(AntiAFKToggle, TweenInfo.new(0.2), {BackgroundColor3 = antiAFKState.originalColor, BackgroundTransparency = antiAFKState.originalTransparency}):Play()
	if antiAFKConnection then
		antiAFKConnection:Disconnect()
		antiAFKConnection = nil
	end
end

local function serverHop()
	local ok = pcall(function() TeleportService:Teleport(game.PlaceId) end)
	if not ok then
		TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
	end
end

local function updateStats()
	while true do
		task.wait(1)
		local elapsed = tick() - startTime
		local hours = math.floor(elapsed / 3600)
		local minutes = math.floor((elapsed % 3600) / 60)
		local seconds = math.floor(elapsed % 60)
		timeLine.Text = string.format("Elapsed Time: %02d:%02d:%02d", hours, minutes, seconds)
		
		if not autoFarmEnabled then
			totalGoldLine.Text = "Gold Gained: 0"
			gphLine.Text = "Gold Per Hour: 0"
		end
	end
end

local currentCategory = "General"

local function switchCategory(category)
	currentCategory = category
	
	AutoFarmToggle.Visible = false
	AntiAFKToggle.Visible = false
	ServerHopButton.Visible = false
	TeleportMenuButton.Visible = false
	StatsContainer.Visible = false
	CreditsContainer.Visible = false
	
	if category == "General" then
		AutoFarmToggle.Visible = true
		StatsContainer.Visible = true
	elseif category == "Misc" then
		AntiAFKToggle.Visible = true
		ServerHopButton.Visible = true
		TeleportMenuButton.Visible = true
	elseif category == "Credits" then
		CreditsContainer.Visible = true
	end
end

for i, btn in ipairs(categoryButtons) do
	btn.MouseButton1Click:Connect(function()
		for _, b in ipairs(categoryButtons) do
			b.TextColor3 = Color3.fromRGB(180, 180, 190)
			b.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
			b.BackgroundTransparency = 0.2
		end
		
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
		btn.BackgroundTransparency = 0.2
		
		switchCategory(categories[i])
	end)
end

switchCategory("General")

AntiAFKToggle.MouseButton1Click:Connect(function()
	if antiAFKEnabled then stopAntiAFK() else startAntiAFK() end
end)

AutoFarmToggle.MouseButton1Click:Connect(function()
	if autoFarmEnabled then stopAutoFarm() else startAutoFarm() end
end)

ServerHopButton.MouseButton1Click:Connect(serverHop)

TeleportMenuButton.MouseButton1Click:Connect(function()
	if isTPMenuOpen then
		if TPFrame then TPFrame:Destroy() end
		TPFrame = nil
		isTPMenuOpen = false
	else
		createTeleportMenu()
	end
end)

LocalPlayer.CharacterAdded:Connect(function(newChar)
	Character = newChar
	Humanoid = newChar:WaitForChild("Humanoid")
	RootPart = newChar:WaitForChild("HumanoidRootPart")
end)

coroutine.wrap(updateStats)()
