local ReplicatedStorage = game:GetService("ReplicatedStorage")

local events = ReplicatedStorage.Events
local timerEvents = events.Timer

local functions = ReplicatedStorage.Functions
local timerFunctions = functions.Timer

local current = nil

local Timer = {}

function Timer.Start(duration, message)
	current = { Timestamp = workspace:GetServerTimeNow() + duration, Message = message }
	timerEvents.Started:FireAllClients(current.Timestamp, current.Message)
end

function Timer.Stop()
	current = nil
	timerEvents.Stopped:FireAllClients()
end

timerFunctions.Get.OnServerInvoke = function()
	if current and current.Timestamp > workspace:GetServerTimeNow() then return current.Timestamp, current.Message end
end

return Timer
