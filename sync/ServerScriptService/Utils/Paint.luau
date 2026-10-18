local ServerScriptService = game:GetService("ServerScriptService")
local TweenService = game:GetService("TweenService")

local utils = ServerScriptService.Utils
local caster = require(utils.Caster)

local PAINT_COLORS = {
	Color3.fromRGB(50, 100, 220),
	Color3.fromRGB(50, 180, 50),
	Color3.fromRGB(230, 180, 20),
	Color3.fromRGB(200, 80, 200),
	Color3.fromRGB(40, 190, 190),
	Color3.fromRGB(230, 120, 30),
	Color3.fromRGB(240, 100, 160),
}
local PAINT_COUNT_MIN, PAINT_COUNT_MAX = 50, 100
local PAINT_SPEED_MIN, PAINT_SPEED_MAX = 25, 50
local PAINT_SIZE_MIN, PAINT_SIZE_MAX = 2, 8
local PAINT_THICKNESS_MIN, PAINT_THICKNESS_MAX = 0.1, 0.3
local PAINT_DIAMETER = 0.4
local PAINT_TWEEN = TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local DOWNWARD_FORCE = 30
local FORWARD_FORCE = 100
local FORWARD_CHANCE = 0.8
local RAYCAST_OFFSET = 0.3
local RAYCAST_DISTANCE = 200

local template = Instance.new("Part")
template.Anchored = true
template.CanCollide = false
template.CanQuery = false
template.CanTouch = false
template.AudioCanCollide = false
template.CastShadow = false
template.Shape = Enum.PartType.Ball
template.Size = Vector3.new(PAINT_DIAMETER, PAINT_DIAMETER, PAINT_DIAMETER)
template.Material = Enum.Material.SmoothPlastic

local folder = nil

local Paint = {}

function Paint.Splat(position, normal)
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "Paint"
		folder.Parent = workspace
	end

	local random = Random.new()
	local color = PAINT_COLORS[math.random(#PAINT_COLORS)]
	local origin = position + normal * RAYCAST_OFFSET
	local forward = Vector3.new(0, -DOWNWARD_FORCE, 0) - normal * FORWARD_FORCE
	local downward = Vector3.new(0, -(DOWNWARD_FORCE + FORWARD_FORCE), 0)
	for _ = 1, random:NextInteger(PAINT_COUNT_MIN, PAINT_COUNT_MAX) do
		local size = random:NextNumber(PAINT_SIZE_MIN, PAINT_SIZE_MAX)
		local thickness = random:NextNumber(PAINT_THICKNESS_MIN, PAINT_THICKNESS_MAX)

		local paint = template:Clone()
		paint.Color = color
		paint.CFrame = CFrame.new(origin)
		paint.Parent = folder

		caster.Fire(origin, random:NextUnitVector(), random:NextNumber(PAINT_SPEED_MIN, PAINT_SPEED_MAX), {
			Distance = RAYCAST_DISTANCE,
			Gravity = random:NextNumber() < FORWARD_CHANCE and forward or downward,
			OnStep = function(step)
				if paint.Parent then paint.CFrame = CFrame.new(step) end
			end,
			OnHit = function(result)
				if not paint.Parent then return end
				paint.Shape = Enum.PartType.Cylinder
				paint.CFrame = CFrame.lookAt(result.Position + result.Normal * (thickness / 2), result.Position + result.Normal)
					* CFrame.Angles(0, math.pi / 2, 0)
				TweenService:Create(paint, PAINT_TWEEN, {
					Size = Vector3.new(thickness, size, size)
				}):Play()
			end,
			OnMiss = function()
				if paint.Parent then paint:Destroy() end
			end
		})
	end
end

function Paint.Clear()
	if folder then folder:Destroy() end
	folder = nil
end

return Paint
