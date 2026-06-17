local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TextChatService = game:GetService("TextChatService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local function toFancy(text)
	local map = {
		a = "ᴀ", b = "ʙ", c = "ᴄ", d = "ᴅ", e = "ᴇ", f = "ꜰ", g = "ɢ", h = "ʜ", i = "ɪ", j = "ᴊ",
		k = "ᴋ", l = "ʟ", m = "ᴍ", n = "ɴ", o = "ᴏ", p = "ᴘ", q = "ǫ", r = "ʀ", s = "s", t = "ᴛ",
		u = "ᴜ", v = "ᴠ", w = "ᴡ", x = "x", y = "ʏ", z = "ᴢ"
	}
	
	local combining = "\u{0305}"
	
	local result = ""
	for c in text:lower():gmatch(".") do
		local fancy = map[c] or c
		result = result .. fancy .. combining
	end
	return result
end

local function bypassSend(message)
	if message == "" then return end
	
	local channel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
	if not channel then
		for _, ch in pairs(TextChatService.TextChannels:GetChildren()) do
			if ch:IsA("TextChannel") then
				channel = ch
				break
			end
		end
	end
	
	if not channel then
		return
	end
	
	local final = toFancy(message)
	channel:SendAsync(final)
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SealgodsChatBypass"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 280, 0, 200)
mainFrame.Position = UDim2.new(0.5, -140, 0.5, -100)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = mainFrame

local dragging = false
local dragStart
local startPos

local function updateInput(input)
	if dragging then
		local delta = input.Position - dragStart
		mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end

mainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position
	end
end)

mainFrame.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		updateInput(input)
	end
end)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
title.Text = "sealgods chat bypass"
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.new(1, 1, 1)
title.Parent = mainFrame

local titleCorner = Instance.new(“UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = title

RunService.RenderStepped:Connect(function()
	local hue = (tick() * 0.2) % 1
	title.TextColor3 = Color3.fromHSV(hue, 1, 1)
end)

local textBox = Instance.new("TextBox")
textBox.Size = UDim2.new(1, -20, 0, 45)
textBox.Position = UDim2.new(0, 10, 0, 55)
textBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
textBox.TextColor3 = Color3.new(1, 1, 1)
textBox.PlaceholderText = "type anything here"
textBox.Text = ""
textBox.ClearTextOnFocus = false
textBox.Font = Enum.Font.Gotham
textBox.TextScaled = true
textBox.Parent = mainFrame

local boxCorner = Instance.new("UICorner")
boxCorner.CornerRadius = UDim.new(0, 6)
boxCorner.Parent = textBox

local sendButton = Instance.new("TextButton")
sendButton.Size = UDim2.new(1, -20, 0, 55)
sendButton.Position = UDim2.new(0, 10, 0, 110)
sendButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
sendButton.Text = "Send Safe Bypass"
sendButton.TextScaled = true
sendButton.TextColor3 = Color3.new(1, 1, 1)
sendButton.Font = Enum.Font.GothamBold
sendButton.Parent = mainFrame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 8)
btnCorner.Parent = sendButton

local function handleSend()
	local original = textBox.Text
	if original == "" then return end
	
	textBox.Text = "à" .. original
	bypassSend(textBox.Text)
	textBox.Text = ""
end

sendButton.MouseButton1Click:Connect(handleSend)

textBox.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		handleSend()
	end
end)
