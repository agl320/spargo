local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local dataStore = ServerScriptService.DataStore
local playerData = require(dataStore.PlayerData)

local events = ReplicatedStorage.Events
local updateCoins = events.UpdateCoins

local Coins = {}

function Coins.Get(player)
	local data = playerData.Get(player)
	return data and data.Coins or 0
end

function Coins.Add(player, amount)
	local data = playerData.Get(player)
	if not data then return end
	data.Coins = (data.Coins or 0) + amount
	updateCoins:FireClient(player, data.Coins)
end

updateCoins.OnServerEvent:Connect(function(player)
	if playerData.Wait(player) then updateCoins:FireClient(player, Coins.Get(player)) end
end)

return Coins
