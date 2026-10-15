local Players = game:GetService("Players")

local active = {}

local Focus = {}

function Focus.Add(parts)
	for _, part in ipairs(parts) do
		table.insert(active, part)
		for _, player in ipairs(Players:GetPlayers()) do
			player:AddReplicationFocus(part)
		end
	end
end

function Focus.Remove(parts)
	for _, part in ipairs(parts) do
		local index = table.find(active, part)
		if index then table.remove(active, index) end
		for _, player in ipairs(Players:GetPlayers()) do
			player:RemoveReplicationFocus(part)
		end
	end
end

Players.PlayerAdded:Connect(function(player)
	for _, part in ipairs(active) do
		player:AddReplicationFocus(part)
	end
end)

return Focus
