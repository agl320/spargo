local OFFSET_X_MIN, OFFSET_X_MAX = -150, 150
local OFFSET_Y_MIN, OFFSET_Y_MAX = 0, 150
local OFFSET_Z_MIN, OFFSET_Z_MAX = -75, 75

local Offset = {}

function Offset.Start(map)
	local target = map.GetTarget()
	local random = Random.new()
	local offset = CFrame.new(random:NextNumber(OFFSET_X_MIN, OFFSET_X_MAX), random:NextNumber(OFFSET_Y_MIN, OFFSET_Y_MAX), random:NextNumber(OFFSET_Z_MIN, OFFSET_Z_MAX))
	local position = (target:GetPivot() * offset).Position
	target:PivotTo(CFrame.lookAt(position, map.GetOrigin().Position))
end

return Offset
