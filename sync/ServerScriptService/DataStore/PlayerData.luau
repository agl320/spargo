local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local store = DataStoreService:GetDataStore("PlayerData")

local RETRY_ATTEMPTS = 3
local RETRY_DELAY = 1

local cache = {}
local unsaveable = {}

local function Attempt(callback)
	for _ = 1, RETRY_ATTEMPTS do
		local success, result = pcall(callback)
		if success then return true, result end
		task.wait(RETRY_DELAY)
	end
	return false, nil
end

local function Load(player)
	if cache[player] then return end
	local success, data = Attempt(function()
		return store:GetAsync(tostring(player.UserId))
	end)
	if not player.Parent then return end
	cache[player] = data or {}
	if not success then
		unsaveable[player] = true
		warn("Datastore is OFF on purpose for now (" .. player.Name .. " won't save)")
	end
end

local function Save(player)
	local data = cache[player]
	if not data or unsaveable[player] then return end
	Attempt(function()
		return store:UpdateAsync(tostring(player.UserId), function()
			return data, { player.UserId }
		end)
	end)
end

local PlayerData = {}

function PlayerData.Get(player)
	return cache[player]
end

function PlayerData.Wait(player)
	repeat task.wait() until cache[player] or not player.Parent
	return cache[player]
end

Players.PlayerAdded:Connect(Load)

Players.PlayerRemoving:Connect(function(player)
	Save(player)
	cache[player] = nil
	unsaveable[player] = nil
end)

game:BindToClose(function()
	if RunService:IsStudio() then return end
	local players = Players:GetPlayers()
	local remaining = #players
	for _, player in ipairs(players) do
		task.spawn(function()
			Save(player)
			remaining -= 1
		end)
	end
	while remaining > 0 do
		task.wait()
	end
end)

for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(Load, player)
end

return PlayerData
