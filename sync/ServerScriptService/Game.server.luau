local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local events = ReplicatedStorage.Events
local gameStarted = events.GameStarted
local gameEnded = events.GameEnded

local modes = ServerScriptService.GameModes
local classic = require(modes.Classic)

local modifiers = ServerScriptService.GameModifiers
local offset = require(modifiers.Offset)

local utils = ServerScriptService.Utils
local timer = require(utils.Timer)

local maps = ServerScriptService.Maps
local beach = require(maps.Beach)
local stadium = require(maps.Stadium)

local LOBBY_TIME = 10

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
	classic.Start(map)
	gameEnded:FireAllClients()
	map.Unload()
	map = nil
end