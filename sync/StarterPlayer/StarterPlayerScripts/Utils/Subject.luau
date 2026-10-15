local camera = workspace.CurrentCamera

local Subject = {}

function Subject.Set(target)
	local character = target.Character
	if character then
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid then camera.CameraSubject = humanoid end
	end
end

function Subject.Is(target)
	local character = target.Character
	if not character then return false end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	return camera.CameraSubject == humanoid
end

return Subject
