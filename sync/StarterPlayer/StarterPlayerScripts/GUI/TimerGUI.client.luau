local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local events = ReplicatedStorage:WaitForChild("Events")
local startTimer = events:WaitForChild("StartTimer")
local stopTimer = events:WaitForChild("StopTimer")

local player = Players.LocalPlayer
local gui = player.PlayerGui

local screen = gui:WaitForChild("TimerGUI")
local frame = screen:WaitForChild("Frame")
local messageLabel = frame:WaitForChild("MessageLabel")
local timestampLabel = frame:WaitForChild("TimestampLabel")

local timer = nil

startTimer.OnClientEvent:Connect(function(timestamp, message)
	if timer then task.cancel(timer) end
	messageLabel.Text = message
	screen.Enabled = true
	timer = task.spawn(function()
		while screen.Enabled and task.wait() do
			local remaining = timestamp - workspace:GetServerTimeNow()
			if remaining <= 0 then
				screen.Enabled = false
				break
			end
			timestampLabel.Text = string.format("%.1f", remaining)
		end
		timer = nil
	end)
end)

stopTimer.OnClientEvent:Connect(function()
	if timer then
		task.cancel(timer)
		timer = nil
	end
	screen.Enabled = false
end)

startTimer:FireServer()
