local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local ContentProvider = game:GetService("ContentProvider")
local MarketplaceService = game:GetService("MarketplaceService")

local LOGO_ASSET_ID = "106006891748521"

local THEME = {
    Background = Color3.fromRGB(0, 0, 0),
    PanelLight = Color3.fromRGB(12, 12, 12),
    Purple = Color3.fromRGB(138, 84, 224),
    Text = Color3.fromRGB(245, 245, 245),
    Stroke = Color3.fromRGB(25, 25, 25),
}

local function corner(inst, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = radius or UDim.new(0, 6)
    c.Parent = inst
end

local function stroke(inst)
    local s = Instance.new("UIStroke")
    s.Color = THEME.Stroke
    s.Thickness = 1
    s.Parent = inst
end

local function tween(inst, props, duration, style, direction)
    local info = TweenInfo.new(
        duration or 0.25,
        style or Enum.EasingStyle.Quint,
        direction or Enum.EasingDirection.Out
    )
    local t = TweenService:Create(inst, info, props)
    t:Play()
    return t
end

local function getImageIdFromDecal(decalId)
    local success = pcall(function()
        MarketplaceService:GetProductInfo(tonumber(decalId))
    end)

    if success then
        return "rbxthumb://type=Asset&id=" .. decalId .. "&w=420&h=420"
    end

    return nil
end

local function createLogo(parent, size)
    local img = Instance.new("ImageLabel")
    img.BackgroundTransparency = 1
    img.Size = UDim2.fromOffset(size, size)
    img.ScaleType = Enum.ScaleType.Fit

    local image = getImageIdFromDecal(LOGO_ASSET_ID)
    img.Image = image or "rbxassetid://0"

    img.Parent = parent
    corner(img, UDim.new(0, 6))

    task.spawn(function()
        pcall(function()
            ContentProvider:PreloadAsync({img})
        end)
    end)

    return img
end


local existing = CoreGui:FindFirstChild("XYZ_Loader")
if existing then
    existing:Destroy()
end


local gui = Instance.new("ScreenGui")
gui.Name = "XYZ_Loader"
gui.ResetOnSpawn = false
gui.DisplayOrder = 999
gui.Parent = CoreGui


local loader = Instance.new("Frame")
loader.Size = UDim2.new(0, 280, 0, 160)
loader.Position = UDim2.new(0.5, -140, 0.5, -80)
loader.BackgroundColor3 = THEME.Background
loader.Parent = gui
corner(loader)
stroke(loader)


local logo = createLogo(loader, 48)
logo.Position = UDim2.new(0.5, -24, 0, 24)


local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Text = ".xyz"
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextColor3 = THEME.Text
title.Size = UDim2.new(1,0,0,24)
title.Position = UDim2.new(0,0,0,80)
title.Parent = loader


local barBg = Instance.new("Frame")
barBg.BackgroundColor3 = THEME.PanelLight
barBg.Size = UDim2.new(0,200,0,6)
barBg.Position = UDim2.new(0.5,-100,1,-32)
barBg.Parent = loader
corner(barBg, UDim.new(1,0))


local bar = Instance.new("Frame")
bar.BackgroundColor3 = THEME.Purple
bar.Size = UDim2.new(0,0,1,0)
bar.Parent = barBg
corner(bar, UDim.new(1,0))


task.spawn(function()
    tween(bar,{Size = UDim2.new(1,0,1,0)},1.4)
    task.wait(1.55)
    tween(loader, {BackgroundTransparency = 1}, 0.3)
    tween(logo, {ImageTransparency = 1}, 0.3)
    tween(title, {TextTransparency = 1}, 0.3)
    tween(barBg, {BackgroundTransparency = 1}, 0.3)
    tween(bar, {BackgroundTransparency = 1}, 0.3)
    task.wait(0.35)

    if game.PlaceId == 6839171747 then -- doors
        loadstring(game:HttpGet("https://raw.githubusercontent.com/sealgodreal/Roblox-Scripts/.xyz/main/GameScripts/.xyz_doors.lua"))()
    end

    loader:Destroy()
end)
