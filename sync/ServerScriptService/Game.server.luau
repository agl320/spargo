local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local events = ReplicatedStorage.Events
local gameEvents = events.Game
local mapEvents = events.Map
local gameModifierEvents = events.GameModifier
local gameModeEvents = events.GameMode
local resultsEvents = events.Results

local functions = ReplicatedStorage.Functions
local gameFunctions = functions.Game
local mapFunctions = functions.Map
local gameModifierFunctions = functions.GameModifier
local gameModeFunctions = functions.GameMode

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

local playing = false
local map = nil
local modifier = nil
local mode = nil

gameFunctions.Get.OnServerInvoke = function()
	return playing
end

mapFunctions.Get.OnServerInvoke = function()
	if map then return map.Name, map.Music end
end

gameModifierFunctions.Get.OnServerInvoke = function()
	if modifier then return modifier.Name end
end

gameModeFunctions.Get.OnServerInvoke = function()
	if mode then return mode.Name end
end

while true do
	if #Players:GetPlayers() == 0 then Players.PlayerAdded:Wait() end

	timer.Start(LOBBY_TIME, "Next game in...")
	task.wait(LOBBY_TIME)

	playing = true
	gameEvents.Started:FireAllClients()
	map = pool[math.random(#pool)]
	map.Load()
	mapEvents.Loaded:FireAllClients(map.Name, map.Music)
	modifier = offset
	modifier.Start(map)
	gameModifierEvents.Started:FireAllClients(modifier.Name)
	mode = classic
	gameModeEvents.Started:FireAllClients(mode.Name)
	local scores = mode.Start(map)
	gameModeEvents.Ended:FireAllClients()
	mode = nil
	gameModifierEvents.Ended:FireAllClients()
	modifier = nil
	map.Unload()
	mapEvents.Unloaded:FireAllClients()
	map = nil
	gameEvents.Ended:FireAllClients()
	playing = false

	for _, entry in ipairs(scores) do
		if entry.Player.Parent then resultsEvents.Show:FireClient(entry.Player, scores, RESULTS_TIME) end
	end
	task.delay(RESULTS_TIME, function()
		for _, entry in ipairs(scores) do
			coins.Add(entry.Player, entry.Score)
		end
	end)
end