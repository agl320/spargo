local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local sounds = SoundService:WaitForChild("GUI")
local sound = sounds:WaitForChild("ShowResults")

local events = ReplicatedStorage:WaitForChild("Events")
local resultsEvents = events:WaitForChild("Results")

local player = Players.LocalPlayer
local gui = player.PlayerGui

local screen = gui:WaitForChild("ResultsGUI")
local frame = screen:WaitForChild("Frame")
local template = frame:WaitForChild("EntryTemplate")

resultsEvents:WaitForChild("Show").OnClientEvent:Connect(function(results, duration)
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
	SoundService:PlayLocalSound(sound)
	task.delay(duration, function()
		screen.Enabled = false
	end)
end)