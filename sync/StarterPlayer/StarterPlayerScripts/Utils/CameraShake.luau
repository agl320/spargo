local RunService = game:GetService("RunService")

local camera = workspace.CurrentCamera

local SHAKE_OFFSET = 1
local SHAKE_ROLL = math.rad(4)
local SHAKE_SPEED = 20
local LAUNCH_STRENGTH_MIN, LAUNCH_STRENGTH_MAX = 0.3, 1
local LAUNCH_TIME = 0.4
local HIT_STRENGTH = 0.6
local HIT_TIME = 0.25

local current = nil

local CameraShake = {}

function CameraShake.Launch(power)
	current = { Strength = math.lerp(LAUNCH_STRENGTH_MIN, LAUNCH_STRENGTH_MAX, power), Time = LAUNCH_TIME, Start = os.clock() }
end

function CameraShake.Hit()
	current = { Strength = HIT_STRENGTH, Time = HIT_TIME, Start = os.clock() }
end

RunService:BindToRenderStep("CameraShake", Enum.RenderPriority.Camera.Value + 1, function()
	if not current then return end
	local progress = (os.clock() - current.Start) / current.Time
	local intensity = current.Strength * math.max(0, 1 - progress) ^ 2
	local phase = os.clock() * SHAKE_SPEED
	local offset = Vector3.new(math.noise(phase, 0.5), math.noise(phase, 1.5), 0) * SHAKE_OFFSET * intensity
	local roll = math.noise(phase, 2.5) * SHAKE_ROLL * intensity
	camera.CFrame = camera.CFrame * CFrame.new(offset) * CFrame.Angles(0, 0, roll)
	if progress >= 1 then current = nil end
end)

return CameraShake
