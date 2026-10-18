local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")

local sounds = SoundService:WaitForChild("GUI")
local sound = sounds:WaitForChild("Click")

local events = ReplicatedStorage:WaitForChild("Events")
local launcherEvents = events:WaitForChild("Launcher")

local player = Players.LocalPlayer
local gui = player.PlayerGui

local screen = gui:WaitForChild("PowerGUI")
local frame = screen:WaitForChild("MeterFrame")
local track = frame:WaitForChild("Track")
local arrow = track:WaitForChild("ArrowImage")
local launchFrame = screen:WaitForChild("LaunchFrame")
local button = launchFrame:WaitForChild("LaunchButton")

local SWEEP_TIME = 2

local function GetPower()
	return 1 - math.abs(os.clock() % SWEEP_TIME / SWEEP_TIME * 2 - 1)
end

launcherEvents:WaitForChild("Loaded").OnClientEvent:Connect(function(sender)
	if sender == player then screen.Enabled = true end
end)

launcherEvents:WaitForChild("Unloaded").OnClientEvent:Connect(function(sender)
	if sender == player then screen.Enabled = false end
end)

button.Activated:Connect(function()
	SoundService:PlayLocalSound(sound)
	launcherEvents:WaitForChild("Fire"):FireServer(GetPower())
	screen.Enabled = false
end)

RunService.PreRender:Connect(function()
	if screen.Enabled then arrow.Position = UDim2.fromScale(GetPower(), 0) end
end)
