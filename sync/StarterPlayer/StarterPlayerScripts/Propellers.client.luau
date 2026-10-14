local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local SPIN_SPEED = math.rad(360)

local propellers = {}

local function AddPropeller(propeller)
	local base = propeller:WaitForChild("Base")
	local rotor = propeller:WaitForChild("Rotor")
	if not propeller.Parent then return end
	propellers[propeller] = {
		Base = base,
		Rotor = rotor,
		Offset = base.CFrame:ToObjectSpace(rotor:GetPivot()),
	}
end

for _, propeller in ipairs(CollectionService:GetTagged("Propeller")) do
	task.spawn(AddPropeller, propeller)
end

CollectionService:GetInstanceAddedSignal("Propeller"):Connect(AddPropeller)

CollectionService:GetInstanceRemovedSignal("Propeller"):Connect(function(propeller)
	propellers[propeller] = nil
end)

RunService.PreRender:Connect(function()
	local angle = -os.clock() * SPIN_SPEED
	for _, propeller in pairs(propellers) do
		propeller.Rotor:PivotTo(propeller.Base.CFrame * CFrame.Angles(0, angle, 0) * propeller.Offset)
	end
end)
