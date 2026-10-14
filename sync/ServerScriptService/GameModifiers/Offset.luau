local X_MIN, X_MAX = -150, 150
local Y_MIN, Y_MAX = 0, 150
local Z_MIN, Z_MAX = -75, 75

local Offset = {}

function Offset.Start(map)
	local target = map.GetTarget()
	local random = Random.new()
	local offset = CFrame.new(random:NextNumber(X_MIN, X_MAX), random:NextNumber(Y_MIN, Y_MAX), random:NextNumber(Z_MIN, Z_MAX))
	local position = (target:GetPivot() * offset).Position
	target:PivotTo(CFrame.lookAt(position, map.GetOrigin().Position))
end

return Offset
