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
local SPLAT_COUNT_MIN, SPLAT_COUNT_MAX = 15, 30
local SPLAT_ANGLE = 85
local SPLAT_OFFSET = 0.3
local SPLAT_SPEED_MIN, SPLAT_SPEED_MAX = 100, 100
local SPLAT_SIZE_MIN, SPLAT_SIZE_MAX = 3, 9
local SPLASH_COUNT_MIN, SPLASH_COUNT_MAX = 25, 50
local SPLASH_ANGLE = 45
local SPLASH_OFFSET = 0.1
local SPLASH_SPEED_MIN, SPLASH_SPEED_MAX = 20, 40
local SPLASH_SIZE_MIN, SPLASH_SIZE_MAX = 2, 4
local DROP_DISTANCE = 200
local DROP_GRAVITY = Vector3.new(0, -98.1, 0)
local DROP_THICKNESS = 0.2

local folder = nil

local function ConeDirection(cone, angle)
	return (cone
		* CFrame.Angles(0, 0, math.rad(math.random(0, 359)))
		* CFrame.Angles(math.rad(angle), 0, 0)).LookVector
end

local function FirePaintDrop(origin, direction, speed, size, color)
	local drop = Instance.new("Part")
	drop.Anchored = true
	drop.CanCollide = false
	drop.CanQuery = false
	drop.CastShadow = false
	drop.Shape = Enum.PartType.Ball
	drop.Size = Vector3.new(0.4, 0.4, 0.4)
	drop.Color = color
	drop.Material = Enum.Material.SmoothPlastic
	drop.CFrame = CFrame.new(origin)
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "Paint"
		folder.Parent = workspace
	end
	drop.Parent = folder

	caster.Fire(origin, direction, speed, {
		Distance = DROP_DISTANCE,
		Gravity = DROP_GRAVITY,
		OnStep = function(position)
			if drop.Parent then drop.CFrame = CFrame.new(position) end
		end,
		OnHit = function(result)
			if not drop.Parent then return end
			drop.Shape = Enum.PartType.Cylinder
			drop.CFrame = CFrame.lookAt(result.Position + result.Normal * (DROP_THICKNESS / 2), result.Position + result.Normal)
				* CFrame.Angles(0, math.pi / 2, 0)
			TweenService:Create(drop, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = Vector3.new(DROP_THICKNESS, size, size)
			}):Play()
		end,
		OnMiss = function()
			if drop.Parent then drop:Destroy() end
		end
	})
end

local Paint = {}

function Paint.Splat(position, normal)
	local color = PAINT_COLORS[math.random(#PAINT_COLORS)]

	local splatCone = CFrame.lookAt(Vector3.zero, -normal)
	for _ = 1, math.random(SPLAT_COUNT_MIN, SPLAT_COUNT_MAX) do
		FirePaintDrop(
			position + normal * SPLAT_OFFSET,
			ConeDirection(splatCone, SPLAT_ANGLE),
			math.random(SPLAT_SPEED_MIN, SPLAT_SPEED_MAX),
			math.random(SPLAT_SIZE_MIN, SPLAT_SIZE_MAX),
			color
		)
	end

	local splashCone = CFrame.lookAt(Vector3.zero, normal)
	for _ = 1, math.random(SPLASH_COUNT_MIN, SPLASH_COUNT_MAX) do
		FirePaintDrop(
			position + normal * SPLASH_OFFSET,
			ConeDirection(splashCone, SPLASH_ANGLE),
			math.random(SPLASH_SPEED_MIN, SPLASH_SPEED_MAX),
			math.random(SPLASH_SIZE_MIN, SPLASH_SIZE_MAX),
			color
		)
	end
end

function Paint.Clear()
	if folder then folder:Destroy() end
	folder = nil
end

return Paint
