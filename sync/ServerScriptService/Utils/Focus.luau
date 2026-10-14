local Players = game:GetService("Players")

local current = nil

local function Add(player)
	if current then player:AddReplicationFocus(current) end
end

local Focus = {}

function Focus.Set(part)
	current = part
	for _, player in ipairs(Players:GetPlayers()) do
		Add(player)
	end
end

function Focus.Clear()
	if not current then return end
	for _, player in ipairs(Players:GetPlayers()) do
		player:RemoveReplicationFocus(current)
	end
	current = nil
end

Players.PlayerAdded:Connect(Add)

return Focus
