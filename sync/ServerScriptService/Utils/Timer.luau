local ReplicatedStorage = game:GetService("ReplicatedStorage")

local events = ReplicatedStorage.Events
local startTimer = events.StartTimer
local stopTimer = events.StopTimer

local current = nil

local Timer = {}

function Timer.Start(duration, message)
	current = { Timestamp = workspace:GetServerTimeNow() + duration, Message = message }
	startTimer:FireAllClients(current.Timestamp, current.Message)
end

function Timer.Stop()
	current = nil
	stopTimer:FireAllClients()
end

startTimer.OnServerEvent:Connect(function(player)
	if current and current.Timestamp > workspace:GetServerTimeNow() then startTimer:FireClient(player, current.Timestamp, current.Message) end
end)

return Timer
