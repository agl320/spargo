local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local sounds = SoundService:WaitForChild("GUI")
local sound = sounds:WaitForChild("Click")

local events = ReplicatedStorage:WaitForChild("Events")
local launcherEvents = events:WaitForChild("Launcher")

local functions = ReplicatedStorage:WaitForChild("Functions")
local launcherFunctions = functions:WaitForChild("Launcher")

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

local function OnLauncherLoaded(sender)
	if sender == player then return end
	shooter = sender
	screen.Enabled = true
end

launcherEvents:WaitForChild("Loaded").OnClientEvent:Connect(OnLauncherLoaded)

launcherEvents:WaitForChild("Unloaded").OnClientEvent:Connect(function(sender)
	shooter = nil
	if sender == player then return end
	subject.Set(player)
	status.Text = ""
	screen.Enabled = false
end)

button.Activated:Connect(function()
	SoundService:PlayLocalSound(sound)
	if not shooter then return end
	if subject.Is(player) then
		subject.Set(shooter)
		status.Text = "Spectating " .. shooter.DisplayName
	else
		subject.Set(player)
		status.Text = ""
	end
end)

for _, sender in ipairs(launcherFunctions:WaitForChild("Get"):InvokeServer()) do
	OnLauncherLoaded(sender)
end
