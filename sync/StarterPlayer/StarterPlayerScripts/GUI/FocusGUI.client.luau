local GuiService = game:GetService("GuiService")
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

local LINE_COUNT_MIN, LINE_COUNT_MAX = 12, 56
local LINE_WIDTH_MIN, LINE_WIDTH_MAX = 2, 7
local LINE_LENGTH_MIN, LINE_LENGTH_MAX = 0.1, 0.26
local LINE_SPEED_MIN, LINE_SPEED_MAX = 0.9, 1.9
local LINE_RADIUS_MIN, LINE_RADIUS_MAX = 0.1, 0.85
local LINE_TRANSPARENCY = template.BackgroundTransparency
local FADE_OUT = 3.5
local FOCUS_INTENSITY_MIN = 0.01

local target = 0
local intensity = 0
local lines = {}
local count = LINE_COUNT_MAX
local center = Vector2.zero
local reach = 0
local reduced = false
local shooter = nil
local power = 0

local function Clear(sender)
	if sender ~= shooter then return end
	shooter = nil
	target = 0
end

local function Reset(line, index, progress)
	local angle = (index - 1 + math.random()) / count * math.pi * 2
	line.Direction = Vector2.new(math.cos(angle), math.sin(angle))
	line.Progress = progress
	line.Speed = math.lerp(LINE_SPEED_MIN, LINE_SPEED_MAX, math.random())
	line.Length = math.lerp(LINE_LENGTH_MIN, LINE_LENGTH_MAX, math.random())
	line.Width = math.lerp(LINE_WIDTH_MIN, LINE_WIDTH_MAX, math.random())
	line.Frame.Rotation = math.deg(angle)
	line.Frame.Size = UDim2.fromOffset(line.Length * reach, line.Width)
end

local function Layout(amount)
	count = math.round(math.lerp(LINE_COUNT_MIN, LINE_COUNT_MAX, amount))
	for index, line in ipairs(lines) do
		line.Frame.Visible = index <= count
		if index <= count then Reset(line, index, math.random()) end
	end
end

local function Measure()
	center = screen.AbsoluteSize / 2
	reach = center.Magnitude
end

local function Resize()
	for _, line in ipairs(lines) do
		line.Frame.Size = UDim2.fromOffset(line.Length * reach, line.Width)
	end
end

local function Retarget()
	target = shooter and subject.Is(shooter) and power or 0
	if target > 0 then Layout(target) end
	intensity = target
end

local function Reduce()
	reduced = GuiService.ReducedMotionEnabled
	if reduced then screen.Enabled = false end
end

for index = 1, LINE_COUNT_MAX do
	local frame = template:Clone()
	frame.Name = "Line"
	frame.Parent = screen
	lines[index] = { Frame = frame }
end

Measure()
Layout(1)
Reduce()

launcherFired.OnClientEvent:Connect(function(sender, amount)
	shooter = sender
	power = amount
	Retarget()
end)

launcherHit.OnClientEvent:Connect(Clear)
launcherUnload.OnClientEvent:Connect(Clear)

screen:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
	Measure()
	Resize()
end)

GuiService:GetPropertyChangedSignal("ReducedMotionEnabled"):Connect(Reduce)

camera:GetPropertyChangedSignal("CameraSubject"):Connect(Retarget)

RunService.PreRender:Connect(function(delta)
	if reduced then return end
	intensity = math.lerp(intensity, target, 1 - math.exp(-delta * FADE_OUT))
	screen.Enabled = intensity > FOCUS_INTENSITY_MIN
	if not screen.Enabled then return end
	for index = 1, count do
		local line = lines[index]
		line.Progress += line.Speed * intensity * delta
		if line.Progress >= 1 then Reset(line, index, line.Progress % 1) end
		local radius = math.lerp(LINE_RADIUS_MIN, LINE_RADIUS_MAX, line.Progress) * reach
		local position = center + line.Direction * (radius + line.Length * reach / 2)
		local frame = line.Frame
		frame.Position = UDim2.fromOffset(position.X, position.Y)
		frame.BackgroundTransparency = 1 - (1 - LINE_TRANSPARENCY) * math.sin(line.Progress * math.pi) * intensity
	end
end)
