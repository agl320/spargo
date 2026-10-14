local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")

local sounds = SoundService:WaitForChild("GUI")
local clickSound = sounds:WaitForChild("Click")

local events = ReplicatedStorage:WaitForChild("Events")
local launcherLoad = events:WaitForChild("LauncherLoad")
local launcherUnload = events:WaitForChild("LauncherUnload")
local launcherFire = events:WaitForChild("LauncherFire")

local player = Players.LocalPlayer
local gui = player.PlayerGui

local screen = gui:WaitForChild("PowerGUI")
local frame = screen:WaitForChild("MeterFrame")
local track = frame:WaitForChild("Track")
local arrow = track:WaitForChild("ArrowImage")
local launchFrame = screen:WaitForChild("LaunchFrame")
local launchButton = launchFrame:WaitForChild("LaunchButton")

local function GetPower()
	return 1 - math.abs(os.clock() % 2 - 1)
end

launcherLoad.OnClientEvent:Connect(function(sender)
	if sender == player then screen.Enabled = true end
end)

launcherUnload.OnClientEvent:Connect(function(sender)
	if sender == player then screen.Enabled = false end
end)

launchButton.Activated:Connect(function()
	SoundService:PlayLocalSound(clickSound)
	launcherFire:FireServer(GetPower())
	screen.Enabled = false
end)

RunService.PreRender:Connect(function()
	if screen.Enabled then arrow.Position = UDim2.fromScale(GetPower(), 0) end
end)
