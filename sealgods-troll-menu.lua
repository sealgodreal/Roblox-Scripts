-- work in progress!!
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SealgodsTrollMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 240, 0, 200)
MainFrame.Position = UDim2.new(0.5, -120, 0.5, -100)
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
Title.Text = "sealgods troll menu"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

RunService.RenderStepped:Connect(function()
	local hue = (tick() * 0.2) % 1
	Title.TextColor3 = Color3.fromHSV(hue, 1, 1)
end)

local OrbitButton = Instance.new("TextButton")
OrbitButton.Size = UDim2.new(1, -20, 0, 45)
OrbitButton.Position = UDim2.new(0, 10, 0, 60)
OrbitButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
OrbitButton.Text = "orbit unanchored objects"
OrbitButton.TextColor3 = Color3.new(1,1,1)
OrbitButton.TextScaled = true
OrbitButton.Font = Enum.Font.Gotham
OrbitButton.Parent = MainFrame

local FlingButton = Instance.new("TextButton")
FlingButton.Size = UDim2.new(1, -20, 0, 45)
FlingButton.Position = UDim2.new(0, 10, 0, 115)
FlingButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
FlingButton.Text = "fling menu"
FlingButton.TextColor3 = Color3.new(1,1,1)
FlingButton.TextScaled = true
FlingButton.Font = Enum.Font.Gotham
FlingButton.Parent = MainFrame

local Folder = Instance.new("Folder", Workspace)
local Part = Instance.new("Part", Folder)
local Attachment1 = Instance.new("Attachment", Part)
Part.Anchored = true
Part.CanCollide = false
Part.Transparency = 1

if not getgenv().Network then
    getgenv().Network = {
        BaseParts = {},
        Velocity = Vector3.new(14.46262424, 14.46262424, 14.46262424)
    }

    Network.RetainPart = function(Part)
        if typeof(Part) == "Instance" and Part:IsA("BasePart") and Part:IsDescendantOf(Workspace) then
            table.insert(Network.BaseParts, Part)
            Part.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
            Part.CanCollide = false
        end
    end

    local function EnablePartControl()
        LocalPlayer.ReplicationFocus = Workspace
        RunService.Heartbeat:Connect(function()
            sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
            for _, Part in pairs(Network.BaseParts) do
                if Part:IsDescendantOf(Workspace) then
                    Part.Velocity = Network.Velocity
                end
            end
        end)
    end

    EnablePartControl()
end

local radius = 100
local height = 100
local rotationSpeed = 0.5
local attractionStrength = 1500
local orbiting = false
local orbitConnection
local parts = {}

local function RetainPart(part)
    if part:IsA("BasePart") and not part.Anchored and part:IsDescendantOf(workspace) then
        if part.Parent == LocalPlayer.Character or part:IsDescendantOf(LocalPlayer.Character) then
            return false
        end
        part.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
        part.CanCollide = false
        return true
    end
    return false
end

local function addPart(part)
    if RetainPart(part) then
        if not table.find(parts, part) then
            table.insert(parts, part)
        end
    end
end

local function removePart(part)
    local index = table.find(parts, part)
    if index then
        table.remove(parts, index)
    end
end

for _, part in pairs(workspace:GetDescendants()) do
    addPart(part)
end

workspace.DescendantAdded:Connect(addPart)
workspace.DescendantRemoving:Connect(removePart)

local function toggleOrbit()
    if orbiting then
        orbiting = false
        OrbitButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        if orbitConnection then
            orbitConnection:Disconnect()
            orbitConnection = nil
        end
    else
        orbiting = true
        OrbitButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        
        orbitConnection = RunService.Heartbeat:Connect(function()
            if not orbiting then return end
            local humanoidRootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                local tornadoCenter = humanoidRootPart.Position
                for _, part in pairs(parts) do
                    if part.Parent and not part.Anchored then
                        local pos = part.Position
                        local distance = (Vector3.new(pos.X, tornadoCenter.Y, pos.Z) - tornadoCenter).Magnitude
                        local angle = math.atan2(pos.Z - tornadoCenter.Z, pos.X - tornadoCenter.X)
                        local newAngle = angle + math.rad(rotationSpeed)
                        local targetPos = Vector3.new(
                            tornadoCenter.X + math.cos(newAngle) * math.min(radius, distance),
                            tornadoCenter.Y + (height * (math.abs(math.sin((pos.Y - tornadoCenter.Y) / height)))),
                            tornadoCenter.Z + math.sin(newAngle) * math.min(radius, distance)
                        )
                        local directionToTarget = (targetPos - part.Position).Unit
                        part.Velocity = directionToTarget * attractionStrength
                    end
                end
            end
        end)
    end
end

local function openFlingMenu()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/sealgodreal/Roblox-Scripts/main/sealgods-fling-menu.lua"))()
end

OrbitButton.MouseButton1Click:Connect(toggleOrbit)
FlingButton.MouseButton1Click:Connect(openFlingMenu)

LocalPlayer.CharacterAdded:Connect(function(newChar)
	Character = newChar
	Humanoid = newChar:WaitForChild("Humanoid")
	RootPart = newChar:WaitForChild("HumanoidRootPart")
end)
