local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local events = ReplicatedStorage:WaitForChild("Events")
local launcherFired = events:WaitForChild("LauncherFired")
local launcherHit = events:WaitForChild("LauncherHit")
local launcherUnload = events:WaitForChild("LauncherUnload")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local gui = player.PlayerGui
local scripts = player.PlayerScripts
local utils = scripts:WaitForChild("Utils")

local screen = gui:WaitForChild("FocusGUI")
local template = screen:WaitForChild("LineTemplate")

local subject = require(utils:WaitForChild("Subject"))

local LINE_COUNT = 56
local LINE_WIDTH_MIN, LINE_WIDTH_MAX = 2, 7
local LINE_LENGTH_MIN, LINE_LENGTH_MAX = 0.1, 0.26
local LINE_SPEED_MIN, LINE_SPEED_MAX = 0.9, 1.9
local LINE_RADIUS_MIN, LINE_RADIUS_MAX = 0.1, 0.85
local FADE_IN = 7
local FADE_OUT = 3.5
local FOCUS_INTENSITY_MIN = 0.01

local target = 0
local intensity = 0
local lines = {}
local shooter = nil
local power = 0

local function Clear()
	shooter = nil
	target = 0
end

local function Reset(line, index, progress)
	local angle = (index - 1 + math.random()) / LINE_COUNT * math.pi * 2
	line.Direction = Vector2.new(math.cos(angle), math.sin(angle))
	line.Frame.Rotation = math.deg(angle)
	line.Progress = progress
	line.Speed = math.lerp(LINE_SPEED_MIN, LINE_SPEED_MAX, math.random())
	line.Length = math.lerp(LINE_LENGTH_MIN, LINE_LENGTH_MAX, math.random())
	line.Width = math.lerp(LINE_WIDTH_MIN, LINE_WIDTH_MAX, math.random())
end

for index = 1, LINE_COUNT do
	local frame = template:Clone()
	frame.Name = "Line"
	frame.Visible = true
	frame.Parent = screen
	lines[index] = { Frame = frame }
	Reset(lines[index], index, math.random())
end

launcherFired.OnClientEvent:Connect(function(sender, amount)
	shooter = sender
	power = amount
	target = subject.Is(sender) and power or 0
end)

launcherHit.OnClientEvent:Connect(Clear)
launcherUnload.OnClientEvent:Connect(Clear)

camera:GetPropertyChangedSignal("CameraSubject"):Connect(function()
	target = shooter and subject.Is(shooter) and power or 0
	intensity = target
end)

RunService.PreRender:Connect(function(delta)
	intensity = math.lerp(intensity, target, math.min(delta * (target > intensity and FADE_IN or FADE_OUT), 1))
	screen.Enabled = intensity > FOCUS_INTENSITY_MIN
	if not screen.Enabled then return end
	local center = screen.AbsoluteSize / 2
	local reach = center.Magnitude
	for index, line in ipairs(lines) do
		line.Progress += line.Speed * intensity * delta
		if line.Progress >= 1 then Reset(line, index, line.Progress - 1) end
		local length = line.Length * reach
		local radius = math.lerp(LINE_RADIUS_MIN, LINE_RADIUS_MAX, line.Progress) * reach
		local position = center + line.Direction * (radius + length / 2)
		local frame = line.Frame
		frame.Position = UDim2.fromOffset(position.X, position.Y)
		frame.Size = UDim2.fromOffset(length, line.Width)
		frame.BackgroundTransparency = 1 - (1 - template.BackgroundTransparency) * math.sin(line.Progress * math.pi) * intensity
	end
end)
