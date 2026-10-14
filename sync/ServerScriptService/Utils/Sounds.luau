local Sounds = {}

function Sounds.Play(sound, position)
	local attachment = Instance.new("Attachment")
	attachment.WorldPosition = position
	attachment.Parent = workspace.Terrain
	local clone = sound:Clone()
	clone.Parent = attachment
	clone.Ended:Once(function()
		attachment:Destroy()
	end)
	clone:Play()
end

function Sounds.Attach(sound, part)
	local clone = sound:Clone()
	clone.Parent = part
	clone.Ended:Once(function()
		clone:Destroy()
	end)
	clone:Play()
	return clone
end

return Sounds
