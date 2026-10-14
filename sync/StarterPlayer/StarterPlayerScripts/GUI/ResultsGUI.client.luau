local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local sounds = SoundService:WaitForChild("GUI")
local showResultsSound = sounds:WaitForChild("ShowResults")

local events = ReplicatedStorage:WaitForChild("Events")
local showResults = events:WaitForChild("ShowResults")

local player = Players.LocalPlayer
local gui = player.PlayerGui

local screen = gui:WaitForChild("ResultsGUI")
local frame = screen:WaitForChild("Frame")
local template = frame:WaitForChild("EntryTemplate")

showResults.OnClientEvent:Connect(function(results, duration)
	for _, entry in ipairs(frame:GetChildren()) do
		if entry.Name == "Entry" then entry:Destroy() end
	end
	for index, result in ipairs(results) do
		local entry = template:Clone()
		entry.Name = "Entry"
		entry.Text = result.Name .. "   " .. result.Score
		entry.LayoutOrder = index + 1
		entry.Visible = true
		entry.Parent = frame
	end
	screen.Enabled = true
	SoundService:PlayLocalSound(showResultsSound)
	task.delay(duration, function()
		screen.Enabled = false
	end)
end)