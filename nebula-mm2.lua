local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

local CHECK_INTERVAL = 1
local HIGHLIGHT_MURDERER = Color3.fromRGB(255, 40, 40)
local HIGHLIGHT_SHERIFF  = Color3.fromRGB(40, 140, 255)
local HIGHLIGHT_GENERAL  = Color3.fromRGB(40, 255, 80)

local KNIFE_NAMES = {
	"Knife", "MurdererKnife", "ClassicSword", "Sword", "Blade",
	"MurdKnife", "Murder Knife", "KillerKnife", "Murd"
}

local GUN_NAMES = {
	"Gun", "Revolver", "Pistol", "SheriffGun", "Handgun", "Sheriff",
	"Firearm", "Weapon", "Sheriff's Gun", "Sheriff Gun", "Colt",
	"Deagle", "Desert Eagle", "Six Shooter", "Peacemaker"
}

local murdererESPEnabled = false
local sheriffESPEnabled = false
local generalESPEnabled = false
local highlighted = {}
local scriptTestEnabled = false
local currentTarget = nil
local targetStartTime = 0
local connection = nil
local antiAfkConnection = nil
local savedCFrame = nil
local crosshairEnabled = false
local crosshairGui = nil
local crosshairConn = nil

local setKillAllVisual

local function isToolMatch(tool, nameList)
	if not tool or not tool:IsA("Tool") then return false end
	local name = tool.Name:lower()
	for _, n in ipairs(nameList) do
		if name:find(n:lower(), 1, true) then
			return true
		end
	end
	return false
end

local function hasRole(player, keywords)
	local char = player.Character
	if not char then return false end

	local sources = {
		player:GetAttribute("Role"),
		player:GetAttribute("Job"),
		player:GetAttribute("Status"),
		char:GetAttribute("Role"),
		char:GetAttribute("Job"),
		char:GetAttribute("Status")
	}

	for _, role in ipairs(sources) do
		if role then
			role = tostring(role):lower()
			for _, k in ipairs(keywords) do
				if role:find(k) then return true end
			end
		end
	end

	for _, obj in ipairs(char:GetDescendants()) do
		if obj:IsA("StringValue") then
			local n = obj.Name:lower()
			if n == "role" or n == "status" or n == "job" or n == "team" then
				local val = obj.Value:lower()
				for _, k in ipairs(keywords) do
					if val:find(k) then return true end
				end
			end
		end
	end

	return false
end

local function isMurderer(player)
	if player == LocalPlayer then return false end
	local char = player.Character
	if not char then return false end

	local backpack = player:FindFirstChildOfClass("Backpack")
	if backpack then
		for _, tool in ipairs(backpack:GetChildren()) do
			if isToolMatch(tool, KNIFE_NAMES) then return true end
		end
	end

	for _, tool in ipairs(char:GetChildren()) do
		if isToolMatch(tool, KNIFE_NAMES) then return true end
	end

	if hasRole(player, {"murd", "killer", "murderer"}) then return true end
	return false
end

local function isSheriff(player)
	if player == LocalPlayer then return false end
	local char = player.Character
	if not char then return false end

	local backpack = player:FindFirstChildOfClass("Backpack")
	if backpack then
		for _, tool in ipairs(backpack:GetChildren()) do
			if isToolMatch(tool, GUN_NAMES) then return true end
		end
	end

	for _, tool in ipairs(char:GetChildren()) do
		if isToolMatch(tool, GUN_NAMES) then return true end
	end

	if hasRole(player, {"sheriff", "police", "officer", "deputy", "law"}) then
		return true
	end
	return false
end

local function createHighlight(player, color, key)
	if not highlighted[player] then
		highlighted[player] = {}
	end
	if highlighted[player][key] and highlighted[player][key].Parent then
		return
	end

	local char = player.Character
	if not char then return end

	local hl = Instance.new("Highlight")
	hl.Name = "Nebula_" .. key
	hl.Adornee = char
	hl.FillColor = color
	hl.OutlineColor = color
	hl.FillTransparency = 0.55
	hl.OutlineTransparency = 0
	hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	hl.Parent = char

	highlighted[player][key] = hl
end

local function removeHighlight(player, key)
	if highlighted[player] and highlighted[player][key] then
		highlighted[player][key]:Destroy()
		highlighted[player][key] = nil
	end
end

local function clearPlayerHighlights(player)
	if highlighted[player] then
		if highlighted[player].Murderer then
			highlighted[player].Murderer:Destroy()
		end
		if highlighted[player].Sheriff then
			highlighted[player].Sheriff:Destroy()
		end
		if highlighted[player].General then
			highlighted[player].General:Destroy()
		end
		highlighted[player] = nil
	end
end

local function updateESP()
	for _, player in ipairs(Players:GetPlayers()) do
		local isMurd = isMurderer(player)
		local isSher = isSheriff(player)

		if murdererESPEnabled and isMurd then
			createHighlight(player, HIGHLIGHT_MURDERER, "Murderer")
			removeHighlight(player, "Sheriff")
			removeHighlight(player, "General")
		else
			removeHighlight(player, "Murderer")
		end

		if sheriffESPEnabled and isSher and not isMurd then
			createHighlight(player, HIGHLIGHT_SHERIFF, "Sheriff")
			removeHighlight(player, "General")
		else
			removeHighlight(player, "Sheriff")
		end

		if generalESPEnabled and not isMurd and not isSher then
			createHighlight(player, HIGHLIGHT_GENERAL, "General")
		else
			removeHighlight(player, "General")
		end
	end
end

Players.PlayerRemoving:Connect(clearPlayerHighlights)

Players.PlayerAdded:Connect(function(player)
	player.CharacterRemoving:Connect(function()
		clearPlayerHighlights(player)
	end)
end)

for _, player in ipairs(Players:GetPlayers()) do
	player.CharacterRemoving:Connect(function()
		clearPlayerHighlights(player)
	end)
end

local function getValidTargets()
	local list = {}
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
			local hum = p.Character:FindFirstChildOfClass("Humanoid")
			if hum and hum.Health > 0 then
				table.insert(list, p)
			end
		end
	end
	return list
end

local function pickNewTarget()
	local targets = getValidTargets()
	if #targets == 0 then
		currentTarget = nil
		targetStartTime = 0
		return
	end
	currentTarget = targets[math.random(1, #targets)]
	targetStartTime = tick()
end

local function disableCollisions(char)
	if not char then return end
	for _, part in ipairs(char:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CanCollide = false
		end
	end
end

local function teleportToTarget()
	if not currentTarget or not currentTarget.Character then return end
	local targetRoot = currentTarget.Character:FindFirstChild("HumanoidRootPart")
	local myChar = LocalPlayer.Character
	if not targetRoot or not myChar then return end

	local myRoot = myChar:FindFirstChild("HumanoidRootPart")
	if not myRoot then return end

	disableCollisions(myChar)
	myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, -1.4) * CFrame.Angles(0, math.rad(180), 0)
end

local function clickMiddleOfScreen()
	local camera = workspace.CurrentCamera
	if not camera then return end

	local viewport = camera.ViewportSize
	local x = viewport.X / 2
	local y = viewport.Y / 2

	VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 1)
	VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 1)
end

local function startAntiAfk()
	if antiAfkConnection then
		task.cancel(antiAfkConnection)
	end

	antiAfkConnection = task.spawn(function()
		while scriptTestEnabled do
			pcall(clickMiddleOfScreen)
			task.wait(0.5)
		end
	end)
end

local function stopAntiAfk()
	if antiAfkConnection then
		task.cancel(antiAfkConnection)
		antiAfkConnection = nil
	end
end

local function startScriptTest()
	if connection then connection:Disconnect() end

	local myChar = LocalPlayer.Character
	if myChar and myChar:FindFirstChild("HumanoidRootPart") then
		savedCFrame = myChar.HumanoidRootPart.CFrame
	end

	pickNewTarget()
	startAntiAfk()

	connection = RunService.Heartbeat:Connect(function()
		if not scriptTestEnabled then return end

		if not currentTarget or not currentTarget.Character then
			pickNewTarget()
			return
		end

		local hum = currentTarget.Character:FindFirstChildOfClass("Humanoid")
		if not hum or hum.Health <= 0 then
			pickNewTarget()
			return
		end

		if tick() - targetStartTime >= 5 then
			scriptTestEnabled = false
			if setKillAllVisual then
				setKillAllVisual(false)
			end
			stopScriptTest()
			return
		end

		teleportToTarget()
	end)
end

local function stopScriptTest()
	scriptTestEnabled = false
	if connection then
		connection:Disconnect()
		connection = nil
	end
	stopAntiAfk()
	currentTarget = nil
	targetStartTime = 0

	if savedCFrame then
		local myChar = LocalPlayer.Character
		if myChar and myChar:FindFirstChild("HumanoidRootPart") then
			myChar.HumanoidRootPart.CFrame = savedCFrame
		end
		savedCFrame = nil
	end
end

local function findMurderer()
	for _, player in ipairs(Players:GetPlayers()) do
		if isMurderer(player) then
			return player
		end
	end
	return nil
end

local function getMurdererScreenPosition()
	local murderer = findMurderer()
	if not murderer or not murderer.Character then return nil end

	local targetPart = murderer.Character:FindFirstChild("Head")
		or murderer.Character:FindFirstChild("HumanoidRootPart")
	if not targetPart then return nil end

	local cam = workspace.CurrentCamera
	if not cam then return nil end

	local screenPos, onScreen = cam:WorldToViewportPoint(targetPart.Position)
	if not onScreen or screenPos.Z <= 0 then return nil end

	local viewport = cam.ViewportSize
	if screenPos.X < 0 or screenPos.X > viewport.X or screenPos.Y < 0 or screenPos.Y > viewport.Y then
		return nil
	end

	return Vector2.new(screenPos.X + 45, screenPos.Y)
end

local function performScriptTest2()
	local screenPos = getMurdererScreenPosition()
	if not screenPos then return end

	VirtualInputManager:SendMouseButtonEvent(screenPos.X, screenPos.Y, 0, true, game, 1)
	VirtualInputManager:SendMouseButtonEvent(screenPos.X, screenPos.Y, 0, false, game, 1)
end

local function enableCrosshair()
	if crosshairGui then return end

	crosshairGui = Instance.new("ScreenGui")
	crosshairGui.Name = "NebulaCrosshair"
	crosshairGui.IgnoreGuiInset = true
	crosshairGui.ResetOnSpawn = false
	crosshairGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	crosshairGui.DisplayOrder = 999
	crosshairGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

	local outer = Instance.new("Frame")
	outer.Name = "Outer"
	outer.Size = UDim2.fromOffset(52, 52)
	outer.BackgroundTransparency = 1
	outer.AnchorPoint = Vector2.new(0.5, 0.5)
	outer.Parent = crosshairGui

	local rotator = Instance.new("Frame")
	rotator.Name = "Rotator"
	rotator.Size = UDim2.fromScale(1, 1)
	rotator.BackgroundTransparency = 1
	rotator.Parent = outer

	local barColor = Color3.fromRGB(190, 120, 255)
	local barThickness = 3
	local barLength = 16
	local gap = 12

	local hLeft = Instance.new("Frame")
	hLeft.Size = UDim2.fromOffset(barLength, barThickness)
	hLeft.Position = UDim2.new(0.5, -barLength - gap/2, 0.5, -barThickness/2)
	hLeft.BackgroundColor3 = barColor
	hLeft.BorderSizePixel = 0
	hLeft.Parent = rotator
	local hLeftStroke = Instance.new("UIStroke")
	hLeftStroke.Color = Color3.fromRGB(30, 10, 50)
	hLeftStroke.Thickness = 1
	hLeftStroke.Parent = hLeft

	local hRight = Instance.new("Frame")
	hRight.Size = UDim2.fromOffset(barLength, barThickness)
	hRight.Position = UDim2.new(0.5, gap/2, 0.5, -barThickness/2)
	hRight.BackgroundColor3 = barColor
	hRight.BorderSizePixel = 0
	hRight.Parent = rotator
	local hRightStroke = Instance.new("UIStroke")
	hRightStroke.Color = Color3.fromRGB(30, 10, 50)
	hRightStroke.Thickness = 1
	hRightStroke.Parent = hRight

	local vTop = Instance.new("Frame")
	vTop.Size = UDim2.fromOffset(barThickness, barLength)
	vTop.Position = UDim2.new(0.5, -barThickness/2, 0.5, -barLength - gap/2)
	vTop.BackgroundColor3 = barColor
	vTop.BorderSizePixel = 0
	vTop.Parent = rotator
	local vTopStroke = Instance.new("UIStroke")
	vTopStroke.Color = Color3.fromRGB(30, 10, 50)
	vTopStroke.Thickness = 1
	vTopStroke.Parent = vTop

	local vBottom = Instance.new("Frame")
	vBottom.Size = UDim2.fromOffset(barThickness, barLength)
	vBottom.Position = UDim2.new(0.5, -barThickness/2, 0.5, gap/2)
	vBottom.BackgroundColor3 = barColor
	vBottom.BorderSizePixel = 0
	vBottom.Parent = rotator
	local vBottomStroke = Instance.new("UIStroke")
	vBottomStroke.Color = Color3.fromRGB(30, 10, 50)
	vBottomStroke.Thickness = 1
	vBottomStroke.Parent = vBottom

	local dot = Instance.new("Frame")
	dot.Size = UDim2.fromOffset(4, 4)
	dot.Position = UDim2.new(0.5, -2, 0.5, -2)
	dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	dot.BorderSizePixel = 0
	dot.Parent = rotator
	local dotCorner = Instance.new("UICorner")
	dotCorner.CornerRadius = UDim.new(1, 0)
	dotCorner.Parent = dot

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromOffset(72, 14)
	label.Position = UDim2.new(1, 6, 1, 2)
	label.BackgroundTransparency = 1
	label.Text = "nebula.lua"
	label.TextColor3 = Color3.fromRGB(190, 120, 255)
	label.Font = Enum.Font.Code
	label.TextSize = 11
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Top
	label.Parent = outer

	local rotation = 0
	crosshairConn = RunService.RenderStepped:Connect(function(dt)
		if not crosshairEnabled or not outer.Parent then return end

		local mouse = UserInputService:GetMouseLocation()
		outer.Position = UDim2.fromOffset(mouse.X, mouse.Y)

		rotation = (rotation + 70 * dt) % 360
		rotator.Rotation = rotation
	end)
end

local function disableCrosshair()
	crosshairEnabled = false
	if crosshairConn then
		crosshairConn:Disconnect()
		crosshairConn = nil
	end
	if crosshairGui then
		crosshairGui:Destroy()
		crosshairGui = nil
	end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Nebula"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 320, 0, 230)
Main.Position = UDim2.new(0.5, -160, 0.5, -115)
Main.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = Main

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(140, 60, 255)
UIStroke.Thickness = 1.5
UIStroke.Transparency = 0.3
UIStroke.Parent = Main

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 42)
TitleBar.BackgroundColor3 = Color3.fromRGB(18, 14, 28)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Main

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

local TitleFix = Instance.new("Frame")
TitleFix.Size = UDim2.new(1, 0, 0, 14)
TitleFix.Position = UDim2.new(0, 0, 1, -14)
TitleFix.BackgroundColor3 = Color3.fromRGB(18, 14, 28)
TitleFix.BorderSizePixel = 0
TitleFix.Parent = TitleBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 16, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Nebula"
Title.TextColor3 = Color3.fromRGB(190, 120, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -38, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(30, 20, 45)
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(200, 200, 220)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 20
CloseBtn.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
	ScreenGui.Enabled = false
end)

local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -24, 0, 36)
TabBar.Position = UDim2.new(0, 12, 0, 52)
TabBar.BackgroundColor3 = Color3.fromRGB(20, 16, 32)
TabBar.BorderSizePixel = 0
TabBar.Parent = Main

local TabCorner = Instance.new("UICorner")
TabCorner.CornerRadius = UDim.new(0, 8)
TabCorner.Parent = TabBar

local AutoTab = Instance.new("TextButton")
AutoTab.Size = UDim2.new(0, 90, 1, -8)
AutoTab.Position = UDim2.new(0, 6, 0, 4)
AutoTab.BackgroundColor3 = Color3.fromRGB(40, 30, 60)
AutoTab.Text = "Auto"
AutoTab.TextColor3 = Color3.fromRGB(200, 190, 220)
AutoTab.Font = Enum.Font.GothamBold
AutoTab.TextSize = 14
AutoTab.Parent = TabBar

local AutoTabCorner = Instance.new("UICorner")
AutoTabCorner.CornerRadius = UDim.new(0, 6)
AutoTabCorner.Parent = AutoTab

local EspTab = Instance.new("TextButton")
EspTab.Size = UDim2.new(0, 90, 1, -8)
EspTab.Position = UDim2.new(0, 100, 0, 4)
EspTab.BackgroundColor3 = Color3.fromRGB(40, 30, 60)
EspTab.Text = "ESP"
EspTab.TextColor3 = Color3.fromRGB(200, 190, 220)
EspTab.Font = Enum.Font.GothamBold
EspTab.TextSize = 14
EspTab.Parent = TabBar

local EspTabCorner = Instance.new("UICorner")
EspTabCorner.CornerRadius = UDim.new(0, 6)
EspTabCorner.Parent = EspTab

local ClientTab = Instance.new("TextButton")
ClientTab.Size = UDim2.new(0, 90, 1, -8)
ClientTab.Position = UDim2.new(0, 194, 0, 4)
ClientTab.BackgroundColor3 = Color3.fromRGB(40, 30, 60)
ClientTab.Text = "Client"
ClientTab.TextColor3 = Color3.fromRGB(200, 190, 220)
ClientTab.Font = Enum.Font.GothamBold
ClientTab.TextSize = 14
ClientTab.Parent = TabBar

local ClientTabCorner = Instance.new("UICorner")
ClientTabCorner.CornerRadius = UDim.new(0, 6)
ClientTabCorner.Parent = ClientTab

local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, -24, 1, -100)
Content.Position = UDim2.new(0, 12, 0, 96)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 4
Content.ScrollBarImageColor3 = Color3.fromRGB(140, 60, 255)
Content.CanvasSize = UDim2.new(0, 0, 0, 0)
Content.AutomaticCanvasSize = Enum.AutomaticSize.Y
Content.Parent = Main

local AutoContent = Instance.new("Frame")
AutoContent.Size = UDim2.new(1, 0, 0, 0)
AutoContent.AutomaticSize = Enum.AutomaticSize.Y
AutoContent.BackgroundTransparency = 1
AutoContent.Visible = false
AutoContent.Parent = Content

local EspContent = Instance.new("Frame")
EspContent.Size = UDim2.new(1, 0, 0, 0)
EspContent.AutomaticSize = Enum.AutomaticSize.Y
EspContent.BackgroundTransparency = 1
EspContent.Visible = false
EspContent.Parent = Content

local ClientContent = Instance.new("Frame")
ClientContent.Size = UDim2.new(1, 0, 0, 0)
ClientContent.AutomaticSize = Enum.AutomaticSize.Y
ClientContent.BackgroundTransparency = 1
ClientContent.Visible = false
ClientContent.Parent = Content

local MadeByLabel = Instance.new("TextLabel")
MadeByLabel.Size = UDim2.new(1, 0, 1, 0)
MadeByLabel.Position = UDim2.new(0, 0, 0, 0)
MadeByLabel.BackgroundTransparency = 1
MadeByLabel.Text = "made by sealgod"
MadeByLabel.TextColor3 = Color3.fromRGB(190, 120, 255)
MadeByLabel.Font = Enum.Font.GothamBold
MadeByLabel.TextSize = 18
MadeByLabel.TextXAlignment = Enum.TextXAlignment.Center
MadeByLabel.TextYAlignment = Enum.TextYAlignment.Center
MadeByLabel.Parent = Content

local firstTabClicked = false

local function setActiveTab(tabName)
	if not firstTabClicked then
		firstTabClicked = true
		MadeByLabel.Visible = false
	end

	AutoTab.BackgroundColor3 = Color3.fromRGB(40, 30, 60)
	AutoTab.TextColor3 = Color3.fromRGB(200, 190, 220)
	EspTab.BackgroundColor3 = Color3.fromRGB(40, 30, 60)
	EspTab.TextColor3 = Color3.fromRGB(200, 190, 220)
	ClientTab.BackgroundColor3 = Color3.fromRGB(40, 30, 60)
	ClientTab.TextColor3 = Color3.fromRGB(200, 190, 220)

	AutoContent.Visible = false
	EspContent.Visible = false
	ClientContent.Visible = false

	if tabName == "Auto" then
		AutoTab.BackgroundColor3 = Color3.fromRGB(110, 50, 220)
		AutoTab.TextColor3 = Color3.fromRGB(255, 255, 255)
		AutoContent.Visible = true
	elseif tabName == "ESP" then
		EspTab.BackgroundColor3 = Color3.fromRGB(110, 50, 220)
		EspTab.TextColor3 = Color3.fromRGB(255, 255, 255)
		EspContent.Visible = true
	else
		ClientTab.BackgroundColor3 = Color3.fromRGB(110, 50, 220)
		ClientTab.TextColor3 = Color3.fromRGB(255, 255, 255)
		ClientContent.Visible = true
	end
end

AutoTab.MouseButton1Click:Connect(function()
	setActiveTab("Auto")
end)

EspTab.MouseButton1Click:Connect(function()
	setActiveTab("ESP")
end)

ClientTab.MouseButton1Click:Connect(function()
	setActiveTab("Client")
end)

local function createToggle(name, yPos, callback, parent)
	parent = parent or EspContent
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 42)
	btn.Position = UDim2.new(0, 0, 0, yPos)
	btn.BackgroundColor3 = Color3.fromRGB(22, 18, 34)
	btn.Text = ""
	btn.AutoButtonColor = false
	btn.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = btn

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(80, 40, 140)
	stroke.Thickness = 1
	stroke.Transparency = 0.5
	stroke.Parent = btn

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -70, 1, 0)
	label.Position = UDim2.new(0, 14, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = name
	label.TextColor3 = Color3.fromRGB(210, 200, 230)
	label.Font = Enum.Font.GothamMedium
	label.TextSize = 15
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = btn

	local indicator = Instance.new("Frame")
	indicator.Size = UDim2.new(0, 42, 0, 22)
	indicator.Position = UDim2.new(1, -54, 0.5, -11)
	indicator.BackgroundColor3 = Color3.fromRGB(40, 30, 60)
	indicator.Parent = btn

	local indCorner = Instance.new("UICorner")
	indCorner.CornerRadius = UDim.new(1, 0)
	indCorner.Parent = indicator

	local circle = Instance.new("Frame")
	circle.Size = UDim2.new(0, 18, 0, 18)
	circle.Position = UDim2.new(0, 2, 0.5, -9)
	circle.BackgroundColor3 = Color3.fromRGB(160, 160, 180)
	circle.Parent = indicator

	local circleCorner = Instance.new("UICorner")
	circleCorner.CornerRadius = UDim.new(1, 0)
	circleCorner.Parent = circle

	local enabled = false

	local function setState(state)
		enabled = state
		if enabled then
			TweenService:Create(indicator, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(130, 60, 255)}):Play()
			TweenService:Create(circle, TweenInfo.new(0.2), {
				Position = UDim2.new(1, -20, 0.5, -9),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			}):Play()
			stroke.Color = Color3.fromRGB(150, 80, 255)
		else
			TweenService:Create(indicator, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 30, 60)}):Play()
			TweenService:Create(circle, TweenInfo.new(0.2), {
				Position = UDim2.new(0, 2, 0.5, -9),
				BackgroundColor3 = Color3.fromRGB(160, 160, 180)
			}):Play()
			stroke.Color = Color3.fromRGB(80, 40, 140)
		end
		callback(enabled)
	end

	btn.MouseButton1Click:Connect(function()
		setState(not enabled)
	end)

	return setState
end

createToggle("Murderer ESP", 0, function(state)
	murdererESPEnabled = state
	if not state then
		for player, _ in pairs(highlighted) do
			removeHighlight(player, "Murderer")
		end
	end
end)

createToggle("Sheriff ESP", 52, function(state)
	sheriffESPEnabled = state
	if not state then
		for player, _ in pairs(highlighted) do
			removeHighlight(player, "Sheriff")
		end
	end
end)

createToggle("General ESP", 104, function(state)
	generalESPEnabled = state
	if not state then
		for player, _ in pairs(highlighted) do
			removeHighlight(player, "General")
		end
	end
end)

createToggle("Custom Crosshair", 0, function(state)
	crosshairEnabled = state
	if state then
		enableCrosshair()
	else
		disableCrosshair()
	end
end, ClientContent)

local ScriptTestBtn = Instance.new("TextButton")
ScriptTestBtn.Size = UDim2.new(1, 0, 0, 42)
ScriptTestBtn.Position = UDim2.new(0, 0, 0, 0)
ScriptTestBtn.BackgroundColor3 = Color3.fromRGB(22, 18, 34)
ScriptTestBtn.Text = ""
ScriptTestBtn.AutoButtonColor = false
ScriptTestBtn.Parent = AutoContent

local stCorner = Instance.new("UICorner")
stCorner.CornerRadius = UDim.new(0, 8)
stCorner.Parent = ScriptTestBtn

local stStroke = Instance.new("UIStroke")
stStroke.Color = Color3.fromRGB(80, 40, 140)
stStroke.Thickness = 1
stStroke.Transparency = 0.5
stStroke.Parent = ScriptTestBtn

local stLabel = Instance.new("TextLabel")
stLabel.Size = UDim2.new(1, -70, 1, 0)
stLabel.Position = UDim2.new(0, 14, 0, 0)
stLabel.BackgroundTransparency = 1
stLabel.Text = "Kill All (MURDERER)"
stLabel.TextColor3 = Color3.fromRGB(210, 200, 230)
stLabel.Font = Enum.Font.GothamMedium
stLabel.TextSize = 15
stLabel.TextXAlignment = Enum.TextXAlignment.Left
stLabel.Parent = ScriptTestBtn

local stIndicator = Instance.new("Frame")
stIndicator.Size = UDim2.new(0, 42, 0, 22)
stIndicator.Position = UDim2.new(1, -54, 0.5, -11)
stIndicator.BackgroundColor3 = Color3.fromRGB(40, 30, 60)
stIndicator.Parent = ScriptTestBtn

local stIndCorner = Instance.new("UICorner")
stIndCorner.CornerRadius = UDim.new(1, 0)
stIndCorner.Parent = stIndicator

local stCircle = Instance.new("Frame")
stCircle.Size = UDim2.new(0, 18, 0, 18)
stCircle.Position = UDim2.new(0, 2, 0.5, -9)
stCircle.BackgroundColor3 = Color3.fromRGB(160, 160, 180)
stCircle.Parent = stIndicator

local stCircleCorner = Instance.new("UICorner")
stCircleCorner.CornerRadius = UDim.new(1, 0)
stCircleCorner.Parent = stCircle

setKillAllVisual = function(state)
	if state then
		TweenService:Create(stIndicator, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(130, 60, 255)}):Play()
		TweenService:Create(stCircle, TweenInfo.new(0.2), {
			Position = UDim2.new(1, -20, 0.5, -9),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		}):Play()
		stStroke.Color = Color3.fromRGB(150, 80, 255)
	else
		TweenService:Create(stIndicator, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 30, 60)}):Play()
		TweenService:Create(stCircle, TweenInfo.new(0.2), {
			Position = UDim2.new(0, 2, 0.5, -9),
			BackgroundColor3 = Color3.fromRGB(160, 160, 180)
		}):Play()
		stStroke.Color = Color3.fromRGB(80, 40, 140)
	end
end

ScriptTestBtn.MouseButton1Click:Connect(function()
	scriptTestEnabled = not scriptTestEnabled
	setKillAllVisual(scriptTestEnabled)

	if scriptTestEnabled then
		startScriptTest()
	else
		stopScriptTest()
	end
end)

local ScriptTest2Btn = Instance.new("TextButton")
ScriptTest2Btn.Size = UDim2.new(1, 0, 0, 42)
ScriptTest2Btn.Position = UDim2.new(0, 0, 0, 52)
ScriptTest2Btn.BackgroundColor3 = Color3.fromRGB(22, 18, 34)
ScriptTest2Btn.Text = ""
ScriptTest2Btn.AutoButtonColor = false
ScriptTest2Btn.Parent = AutoContent

local st2Corner = Instance.new("UICorner")
st2Corner.CornerRadius = UDim.new(0, 8)
st2Corner.Parent = ScriptTest2Btn

local st2Stroke = Instance.new("UIStroke")
st2Stroke.Color = Color3.fromRGB(80, 40, 140)
st2Stroke.Thickness = 1
st2Stroke.Transparency = 0.5
st2Stroke.Parent = ScriptTest2Btn

local st2Label = Instance.new("TextLabel")
st2Label.Size = UDim2.new(1, -20, 1, 0)
st2Label.Position = UDim2.new(0, 14, 0, 0)
st2Label.BackgroundTransparency = 1
st2Label.Text = "Shoot Murderer"
st2Label.TextColor3 = Color3.fromRGB(210, 200, 230)
st2Label.Font = Enum.Font.GothamMedium
st2Label.TextSize = 15
st2Label.TextXAlignment = Enum.TextXAlignment.Left
st2Label.Parent = ScriptTest2Btn

ScriptTest2Btn.MouseButton1Click:Connect(function()
	TweenService:Create(ScriptTest2Btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(110, 50, 220)}):Play()
	st2Stroke.Color = Color3.fromRGB(150, 80, 255)

	performScriptTest2()

	task.delay(0.15, function()
		TweenService:Create(ScriptTest2Btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(22, 18, 34)}):Play()
		st2Stroke.Color = Color3.fromRGB(80, 40, 140)
	end)
end)

local dragging = false
local dragInput = nil
local dragStart = nil
local startPos = nil

local function update(input)
	local delta = input.Position - dragStart
	Main.Position = UDim2.new(
		startPos.X.Scale,
		startPos.X.Offset + delta.X,
		startPos.Y.Scale,
		startPos.Y.Offset + delta.Y
	)
end

TitleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = Main.Position
		dragInput = input

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
				dragInput = nil
			end
		end)
	end
end)

TitleBar.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		update(input)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		update(input)
	end
end)

task.spawn(function()
	while true do
		if murdererESPEnabled or sheriffESPEnabled or generalESPEnabled then
			updateESP()
		end
		task.wait(CHECK_INTERVAL)
	end
end)
