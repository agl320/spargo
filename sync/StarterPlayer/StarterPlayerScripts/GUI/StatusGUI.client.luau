local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local sounds = SoundService:WaitForChild("GUI")
local upNextSound = sounds:WaitForChild("UpNext")

local events = ReplicatedStorage:WaitForChild("Events")
local gameStarted = events:WaitForChild("GameStarted")
local gameEnded = events:WaitForChild("GameEnded")
local turnStarted = events:WaitForChild("TurnStarted")
local turnEnded = events:WaitForChild("TurnEnded")

local player = Players.LocalPlayer
local gui = player.PlayerGui

local screen = gui:WaitForChild("StatusGUI")
local frame = screen:WaitForChild("Frame")
local titleLabel = frame:WaitForChild("TitleLabel")
local statusLabel = frame:WaitForChild("StatusLabel")

local function GetProgress(order, count)
	return "Turn " .. count .. "/" .. #order .. " complete"
end

gameStarted.OnClientEvent:Connect(function(mapName, modeName)
	titleLabel.Text = mapName .. " - " .. modeName
	statusLabel.Text = ""
	screen.Enabled = true
end)

turnStarted.OnClientEvent:Connect(function(order, index)
	if order[index] == player.UserId then
		statusLabel.Text = "Aim at the target to get points!"
	elseif order[index + 1] == player.UserId then
		statusLabel.Text = "You're up next, get ready!"
		SoundService:PlayLocalSound(upNextSound)
	else
		statusLabel.Text = GetProgress(order, index - 1)
	end
end)

turnEnded.OnClientEvent:Connect(function(order, index)
	if order[index + 1] == player.UserId then
		statusLabel.Text = "You're up next, get ready!"
	else
		statusLabel.Text = GetProgress(order, index)
	end
end)

gameEnded.OnClientEvent:Connect(function()
	screen.Enabled = false
end)

gameStarted:FireServer()
