local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local sounds = SoundService:WaitForChild("GUI")
local clickSound = sounds:WaitForChild("Click")

local events = ReplicatedStorage:WaitForChild("Events")
local launcherLoad = events:WaitForChild("LauncherLoad")
local launcherUnload = events:WaitForChild("LauncherUnload")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local gui = player.PlayerGui

local screen = gui:WaitForChild("SpectateGUI")
local frame = screen:WaitForChild("Frame")
local button = frame:WaitForChild("SpectateButton")
local status = frame:WaitForChild("StatusLabel")

local shooter = nil

local function SetSubject(target)
	local character = target.Character
	if character then
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid then camera.CameraSubject = humanoid end
	end
end

local function IsSubject(target)
	local character = target.Character
	if not character then return false end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	return camera.CameraSubject == humanoid
end

launcherLoad.OnClientEvent:Connect(function(sender)
	if sender == player then return end
	shooter = sender
	screen.Enabled = true
end)

launcherUnload.OnClientEvent:Connect(function(sender)
	shooter = nil
	if sender == player then return end
	if not IsSubject(player) then SetSubject(player) end
	status.Text = ""
	screen.Enabled = false
end)

button.Activated:Connect(function()
	SoundService:PlayLocalSound(clickSound)
	if not shooter then return end
	if IsSubject(player) then
		SetSubject(shooter)
		status.Text = "Spectating " .. shooter.DisplayName
	else
		SetSubject(player)
		status.Text = ""
	end
end)

launcherLoad:FireServer()
