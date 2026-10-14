local Map = {}

function Map.new(template)
	local map = {}

	function map.Load()
		map.Model = template:Clone()
		map.Model.Parent = workspace
	end

	function map.Unload()
		map.Model:Destroy()
		map.Model = nil
	end

	function map.GetTarget()
		return map.Model.Interactables.Target
	end

	function map.GetRings()
		return map.Model.Interactables.Target.Rings
	end

	function map.GetSpawn()
		return map.Model.Interactables.Spawn.CFrame + Vector3.new(0, 3, 0)
	end

	function map.GetOrigin()
		error(template.Name .. " has no GetOrigin")
	end

	function map.GetDirection()
		error(template.Name .. " has no GetDirection")
	end

	function map.GetSeat()
		error(template.Name .. " has no GetSeat")
	end

	function map.OnLoad()
	end

	function map.OnAim()
		error(template.Name .. " has no OnAim")
	end

	function map.OnFire()
	end

	function map.OnUnload()
	end

	return map
end

return Map
