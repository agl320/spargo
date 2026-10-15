local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local sounds = SoundService:WaitForChild("GUI")
local clickSound = sounds:WaitForChild("Click")

local events = ReplicatedStorage:WaitForChild("Events")
local launcherLoad = events:WaitForChild("LauncherLoad")
local launcherUnload = events:WaitForChild("LauncherUnload")

local player = Players.LocalPlayer
local gui = player.PlayerGui
local scripts = player.PlayerScripts
local utils = scripts:WaitForChild("Utils")

local screen = gui:WaitForChild("SpectateGUI")
local frame = screen:WaitForChild("Frame")
local button = frame:WaitForChild("SpectateButton")
local status = frame:WaitForChild("StatusLabel")

local subject = require(utils:WaitForChild("Subject"))

local shooter = nil

launcherLoad.OnClientEvent:Connect(function(sender)
	if sender == player then return end
	shooter = sender
	screen.Enabled = true
end)

launcherUnload.OnClientEvent:Connect(function(sender)
	shooter = nil
	if sender == player then return end
	if not subject.Is(player) then subject.Set(player) end
	status.Text = ""
	screen.Enabled = false
end)

button.Activated:Connect(function()
	SoundService:PlayLocalSound(clickSound)
	if not shooter then return end
	if subject.Is(player) then
		subject.Set(shooter)
		status.Text = "Spectating " .. shooter.DisplayName
	else
		subject.Set(player)
		status.Text = ""
	end
end)

launcherLoad:FireServer()
