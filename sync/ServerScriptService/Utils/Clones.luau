local folder = nil

local Clones = {}

function Clones.Create(player)
	local character = player.Character
	if not character then return end
	character.Archivable = true
	local clone = character:Clone()
	character.Archivable = false

	for _, descendant in ipairs(clone:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.Anchored = true
			descendant.CanCollide = true
		elseif descendant:IsA("BaseScript") then
			descendant:Destroy()
		end
	end
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "Clones"
		folder.Parent = workspace
	end
	clone.Parent = folder
end

function Clones.GetFolder()
	return folder
end

function Clones.Clear()
	if folder then folder:Destroy() end
	folder = nil
end

return Clones