local Players = game:GetService("Players")

local targets = {}

local function OnPlayerAdded(player)
	player.CharacterAdded:Connect(function(character)
		local target = targets[player]
		if not target then return end
		character:PivotTo(target.CFrame)
		if target.OnSpawn then target.OnSpawn(character) end
	end)
end

local Spawner = {}

function Spawner.Respawn(players, cframe, onSpawn)
	for _, player in ipairs(players) do
		if player.Parent then
			targets[player] = cframe and { CFrame = cframe, OnSpawn = onSpawn }
			player:LoadCharacterAsync()
		end
	end
end

Players.PlayerAdded:Connect(OnPlayerAdded)

Players.PlayerRemoving:Connect(function(player)
	targets[player] = nil
end)

for _, player in ipairs(Players:GetPlayers()) do
	OnPlayerAdded(player)
end

return Spawner
