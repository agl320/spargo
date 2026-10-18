local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local dataStore = ServerScriptService.DataStore
local coins = require(dataStore.Coins)
local inventory = require(dataStore.Inventory)

local modules = ReplicatedStorage.Modules
local items = require(modules.Items)

local functions = ReplicatedStorage.Functions
local storeFunctions = functions.Store

storeFunctions.Buy.OnServerInvoke = function(player, key, name)
	if typeof(key) ~= "string" or typeof(name) ~= "string" then return false end
	local item = items[key] and items[key][name]
	if not item or not item.Price or inventory.Owns(player, key, name) then return false end
	if not coins.Remove(player, item.Price) then return false end
	inventory.Add(player, key, name)
	return true
end
