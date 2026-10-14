local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local PULSE_SPEED = 6
local FLICKER_SPEED = 10.2
local PULSE_WEIGHT = 0.7
local FLICKER_WEIGHT = 0.6
local FLAME_AMOUNT = 0.15
local OUTER_AMOUNT = 0.09
local CORE_AMOUNT = 0.06
local GLOW_HEAT = 0.9
local HOT_COLOR = Color3.new(1, 1, 1)

local thrusters = {}

local function AddThruster(thruster)
	local glow = thruster:WaitForChild("NozzleGlow")
	local flameStart = glow:WaitForChild("FlameStart")
	local flameEnd = glow:WaitForChild("FlameEnd")
	local outer = glow:WaitForChild("FlameOuter")
	local core = glow:WaitForChild("FlameCore")
	local light = flameStart:WaitForChild("FlameLight")
	if not thruster.Parent then return end
	thrusters[thruster] = {
		Glow = glow,
		FlameStart = flameStart,
		FlameEnd = flameEnd,
		Outer = outer,
		Core = core,
		Light = light,
		BaseEnd = flameEnd.Position,
		BaseOuter = outer.Width0,
		BaseCore = core.Width0,
		BaseLight = light.Brightness,
		BaseColor = glow.Color,
		Seed = math.random() * 100,
	}
end

for _, thruster in ipairs(CollectionService:GetTagged("Thruster")) do
	task.spawn(AddThruster, thruster)
end

CollectionService:GetInstanceAddedSignal("Thruster"):Connect(AddThruster)

CollectionService:GetInstanceRemovedSignal("Thruster"):Connect(function(thruster)
	thrusters[thruster] = nil
end)

RunService.PreRender:Connect(function()
	local clock = os.clock()
	for _, thruster in pairs(thrusters) do
		local pulse = math.sin(clock * PULSE_SPEED) * PULSE_WEIGHT + math.noise(clock * FLICKER_SPEED, thruster.Seed) * FLICKER_WEIGHT
		local scale = 1 + pulse * FLAME_AMOUNT
		thruster.FlameEnd.Position = thruster.FlameStart.Position + (thruster.BaseEnd - thruster.FlameStart.Position) * scale
		thruster.Outer.Width0 = thruster.BaseOuter * (1 + pulse * OUTER_AMOUNT)
		thruster.Core.Width0 = thruster.BaseCore * (1 + pulse * CORE_AMOUNT)
		thruster.Light.Brightness = thruster.BaseLight * scale
		local heat = math.clamp(GLOW_HEAT + pulse * FLAME_AMOUNT, 0, 1)
		thruster.Glow.Color = thruster.BaseColor:Lerp(HOT_COLOR, 1 - heat)
	end
end)
