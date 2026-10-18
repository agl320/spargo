local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local dataStore = ServerScriptService.DataStore
local playerData = require(dataStore.PlayerData)

local events = ReplicatedStorage.Events
local coinsEvents = events.Coins

local functions = ReplicatedStorage.Functions
local coinsFunctions = functions.Coins

local DEFAULT_COINS = 0

local function IsNumber(value)
	return typeof(value) == "number" and value == value
end

local Coins = {}

function Coins.Get(player)
	local data = playerData.Get(player)
	return data and data.Coins or DEFAULT_COINS
end

function Coins.Add(player, amount)
	local data = playerData.Get(player)
	if not data or not IsNumber(amount) then return end
	data.Coins = Coins.Get(player) + amount
	coinsEvents.Updated:FireClient(player, data.Coins)
end

function Coins.Remove(player, amount)
	local data = playerData.Get(player)
	if not data or not IsNumber(amount) or Coins.Get(player) < amount then return false end
	data.Coins = Coins.Get(player) - amount
	coinsEvents.Updated:FireClient(player, data.Coins)
	return true
end

coinsFunctions.Get.OnServerInvoke = function(player)
	if playerData.Wait(player) then return Coins.Get(player) end
end

return Coins
