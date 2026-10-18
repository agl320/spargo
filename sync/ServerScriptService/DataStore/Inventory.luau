local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local dataStore = ServerScriptService.DataStore
local playerData = require(dataStore.PlayerData)

local modules = ReplicatedStorage.Modules
local items = require(modules.Items)

local events = ReplicatedStorage.Events
local inventoryEvents = events.Inventory

local functions = ReplicatedStorage.Functions
local inventoryFunctions = functions.Inventory

local DEFAULT_INVENTORY = {
	LaunchAnimations = { "Default" },
	LaunchSounds = { "Default" },
	SplatAnimations = { "Default" },
	SplatSounds = { "Default" },
}
local DEFAULT_EQUIPPED = {
	LaunchAnimations = "Default",
	LaunchSounds = "Default",
	SplatAnimations = "Default",
	SplatSounds = "Default",
}

local Inventory = {}

function Inventory.Get(player)
	local data = playerData.Get(player)
	local owned = {}
	local equipped = {}
	for key in pairs(items) do
		local saved = data and data.Inventory and data.Inventory[key] or {}
		owned[key] = table.clone(DEFAULT_INVENTORY[key])
		for _, name in ipairs(saved) do table.insert(owned[key], name) end
		equipped[key] = Inventory.GetEquipped(player, key)
	end
	return owned, equipped
end

function Inventory.Owns(player, key, name)
	if not items[key] then return false end
	local data = playerData.Get(player)
	local owned = data and data.Inventory and data.Inventory[key]
	return table.find(DEFAULT_INVENTORY[key], name) ~= nil or (owned ~= nil and table.find(owned, name) ~= nil)
end

function Inventory.Add(player, key, name)
	local data = playerData.Get(player)
	if not data or not items[key] or not items[key][name] or Inventory.Owns(player, key, name) then return end
	data.Inventory = data.Inventory or {}
	data.Inventory[key] = data.Inventory[key] or {}
	table.insert(data.Inventory[key], name)
	inventoryEvents.Updated:FireClient(player, Inventory.Get(player))
end

function Inventory.Equip(player, key, name)
	local data = playerData.Get(player)
	if not data or not items[key] or not items[key][name] or not Inventory.Owns(player, key, name) then return end
	data.Equipped = data.Equipped or {}
	data.Equipped[key] = name
	inventoryEvents.Updated:FireClient(player, Inventory.Get(player))
end

function Inventory.GetEquipped(player, key)
	if not items[key] then return end
	local data = playerData.Get(player)
	local name = data and data.Equipped and data.Equipped[key]
	return items[key][name] and name or DEFAULT_EQUIPPED[key]
end

function Inventory.GetItem(player, key)
	if not items[key] then return end
	return items[key][Inventory.GetEquipped(player, key)]
end

inventoryFunctions.Get.OnServerInvoke = function(player)
	if playerData.Wait(player) then return Inventory.Get(player) end
end

inventoryEvents.Equip.OnServerEvent:Connect(function(player, key, name)
	if typeof(key) ~= "string" or typeof(name) ~= "string" then return end
	Inventory.Equip(player, key, name)
end)

return Inventory
