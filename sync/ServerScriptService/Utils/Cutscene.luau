local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local events = ReplicatedStorage.Events
local playCutscene = events.PlayCutscene

local utils = ServerScriptService.Utils
local focus = require(utils.Focus)

local current = nil

local Cutscene = {}

function Cutscene.Play(map, duration)
	local folder = map.GetCutscene()
	if not folder then return end

	local entries = {}
	for _, part in ipairs(folder:GetChildren()) do
		local shot, point = string.match(part.Name, "^(%d+)_(%d+)$")
		if shot then table.insert(entries, { Shot = tonumber(shot), Point = tonumber(point), Part = part }) end
	end
	table.sort(entries, function(first, second)
		if first.Shot ~= second.Shot then return first.Shot < second.Shot end
		return first.Point < second.Point
	end)

	local shots = {}
	local starts = {}
	local shot = nil
	local number = nil
	for _, entry in ipairs(entries) do
		if entry.Shot ~= number then
			number = entry.Shot
			shot = { Points = {} }
			table.insert(shots, shot)
			table.insert(starts, entry.Part)
		end
		table.insert(shot.Points, entry.Part.CFrame)
	end
	if not shot then return end

	current = { Shots = shots, Timestamp = workspace:GetServerTimeNow(), Duration = duration }
	playCutscene:FireAllClients(current.Shots, current.Timestamp, current.Duration)
	focus.Add(starts)
	task.delay(duration, function()
		focus.Remove(starts)
		current = nil
	end)
end

playCutscene.OnServerEvent:Connect(function(player)
	if current then playCutscene:FireClient(player, current.Shots, current.Timestamp, current.Duration) end
end)

return Cutscene
