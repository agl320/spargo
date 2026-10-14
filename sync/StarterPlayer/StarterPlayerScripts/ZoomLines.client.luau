local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local events = ReplicatedStorage:WaitForChild("Events")
local launcherFired = events:WaitForChild("LauncherFired")
local launcherHit = events:WaitForChild("LauncherHit")
local launcherUnload = events:WaitForChild("LauncherUnload")

local player = Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera

local LINE_COUNT = 56
local LINE_COLOR = Color3.new(1, 1, 1)
local LINE_TRANSPARENCY = 0.25
local WIDTH_MIN, WIDTH_MAX = 2, 7
local LENGTH_MIN, LENGTH_MAX = 0.13, 0.33
local SPEED_MIN, SPEED_MAX = 0.9, 1.9
local RADIUS_START, RADIUS_END = 0.1, 0.85
local FLY_SPEED_MIN, FLY_SPEED_MAX = 40, 110
local SPEED_SMOOTHING = 10
local FADE_IN, FADE_OUT = 7, 3.5

local flying = false
local intensity = 0
local speed = 0
local last = nil

local screen = Instance.new("ScreenGui")
screen.Name = "ZoomGUI"
screen.ResetOnSpawn = false
screen.IgnoreGuiInset = true
screen.DisplayOrder = -1
screen.Enabled = false
screen.Parent = gui

local lines = {}

for index = 1, LINE_COUNT do
	local frame = Instance.new("Frame")
	frame.Name = "Line"
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.BackgroundColor3 = LINE_COLOR
	frame.BorderSizePixel = 0
	frame.Parent = screen

	local gradient = Instance.new("UIGradient")
	gradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.45, 0),
		NumberSequenceKeypoint.new(1, 0.65),
	})
	gradient.Parent = frame

	lines[index] = { Frame = frame, Index = index }
end

local function Respawn(line, progress)
	local spread = (line.Index - 1 + math.random()) / LINE_COUNT
	line.Angle = spread * math.pi * 2
	line.Progress = progress
	line.Speed = math.lerp(SPEED_MIN, SPEED_MAX, math.random())
	line.Length = math.lerp(LENGTH_MIN, LENGTH_MAX, math.random())
	line.Width = math.lerp(WIDTH_MIN, WIDTH_MAX, math.random())
end

for _, line in ipairs(lines) do
	Respawn(line, math.random())
end

local function GetRoot()
	local character = player.Character
	return character and character:FindFirstChild("HumanoidRootPart")
end

launcherFired.OnClientEvent:Connect(function()
	flying = true
	speed = 0
	last = nil
end)

launcherHit.OnClientEvent:Connect(function()
	flying = false
end)

launcherUnload.OnClientEvent:Connect(function(sender)
	if sender == player then flying = false end
end)

player.CharacterRemoving:Connect(function()
	flying = false
end)

RunService.PreRender:Connect(function(delta)
	local root = flying and GetRoot()
	if root then
		local position = root.Position
		if last then speed = math.lerp(speed, (position - last).Magnitude / math.max(delta, 1e-4), math.min(delta * SPEED_SMOOTHING, 1)) end
		last = position
	else
		flying = false
		last = nil
	end

	local target = flying and math.clamp((speed - FLY_SPEED_MIN) / (FLY_SPEED_MAX - FLY_SPEED_MIN), 0, 1) or 0
	local rate = target > intensity and FADE_IN or FADE_OUT
	intensity = math.lerp(intensity, target, math.min(delta * rate, 1))

	if intensity < 0.01 then
		if screen.Enabled then
			screen.Enabled = false
			intensity = 0
		end
		return
	end

	screen.Enabled = true

	local viewport = camera.ViewportSize
	local center = viewport / 2
	local reach = viewport.Magnitude / 2

	for _, line in ipairs(lines) do
		line.Progress += line.Speed * delta * (0.6 + intensity * 0.8)
		if line.Progress >= 1 then Respawn(line, line.Progress - 1) end

		local length = reach * line.Length * (0.5 + intensity * 0.5)
		local radius = math.lerp(RADIUS_START, RADIUS_END, line.Progress) * reach
		local direction = Vector2.new(math.cos(line.Angle), math.sin(line.Angle))
		local position = center + direction * (radius + length / 2)
		local fade = math.sin(line.Progress * math.pi)

		local frame = line.Frame
		frame.Position = UDim2.fromOffset(position.X, position.Y)
		frame.Size = UDim2.fromOffset(length, line.Width)
		frame.Rotation = math.deg(line.Angle)
		frame.BackgroundTransparency = 1 - (1 - LINE_TRANSPARENCY) * fade * intensity
	end
end)
