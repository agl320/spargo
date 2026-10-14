local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local utils = ServerScriptService.Utils
local clones = require(utils.Clones)
local fastCast = require(script.FastCastRedux)

local caster = fastCast.new()

local Caster = {}

function Caster.Fire(origin, direction, speed, configuration)
	local behavior = fastCast.newBehavior()
	behavior.MaxDistance = configuration.Distance
	if configuration.Gravity then behavior.Acceleration = configuration.Gravity end

	local ignore = {}
	for _, player in ipairs(Players:GetPlayers()) do
		if player.Character then table.insert(ignore, player.Character) end
	end
	local folder = clones.GetFolder()
	if folder then table.insert(ignore, folder) end
	local params = RaycastParams.new()
	params.FilterDescendantsInstances = ignore
	behavior.RaycastParams = params

	local cast = caster:Fire(origin, direction, speed, behavior)
	cast.UserData.Configuration = configuration
end

caster.LengthChanged:Connect(function(cast, point, direction, displacement)
	local configuration = cast.UserData.Configuration
	if configuration.OnStep then configuration.OnStep(point + direction * displacement, direction) end
end)

caster.RayHit:Connect(function(cast, result)
	cast.UserData.DidHit = true
	local configuration = cast.UserData.Configuration
	if configuration.OnHit then configuration.OnHit(result) end
end)

caster.CastTerminating:Connect(function(cast)
	local configuration = cast.UserData.Configuration
	if not cast.UserData.DidHit and configuration.OnMiss then configuration.OnMiss() end
end)

return Caster