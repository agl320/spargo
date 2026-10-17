local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local events = ReplicatedStorage.Events
local gameStarted = events.GameStarted
local gameEnded = events.GameEnded
local showResults = events.ShowResults

local modes = ServerScriptService.GameModes
local classic = require(modes.Classic)

local modifiers = ServerScriptService.GameModifiers
local offset = require(modifiers.Offset)

local utils = ServerScriptService.Utils
local timer = require(utils.Timer)

local dataStore = ServerScriptService.DataStore
local coins = require(dataStore.Coins)

local maps = ServerScriptService.Maps
local beach = require(maps.Beach)
local stadium = require(maps.Stadium)

local LOBBY_TIME = 12
local RESULTS_TIME = 6

local pool = { beach, stadium }

local map = nil

gameStarted.OnServerEvent:Connect(function(player)
	if not map then return end
	gameStarted:FireClient(player, map.Name, classic.Name, map.Music)
	classic.Sync(player)
end)

while true do
	if #Players:GetPlayers() == 0 then Players.PlayerAdded:Wait() end

	timer.Start(LOBBY_TIME, "Next game in...")
	task.wait(LOBBY_TIME)

	map = pool[math.random(#pool)]
	map.Load()
	gameStarted:FireAllClients(map.Name, classic.Name, map.Music)
	offset.Start(map)
	local scores = classic.Start(map)
	gameEnded:FireAllClients()
	map.Unload()
	map = nil

	for _, entry in ipairs(scores) do
		if entry.Player.Parent then showResults:FireClient(entry.Player, scores, RESULTS_TIME) end
	end
	task.delay(RESULTS_TIME, function()
		for _, entry in ipairs(scores) do
			coins.Add(entry.Player, entry.Score)
		end
	end)
end