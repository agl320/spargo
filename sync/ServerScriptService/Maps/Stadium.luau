local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local maps = ServerStorage.Maps
local template = maps.Stadium

local utils = ServerScriptService.Utils
local map = require(utils.Map)
local sounds = require(utils.Sounds)

local assets = ReplicatedStorage.Assets
local animations = assets.Animations
local mapAnimations = animations.Map

local gameplay = SoundService.Gameplay
local mapSounds = gameplay.Map
local music = SoundService.Music

local RUN_TIME = 2

local track = nil

local Stadium = map.new(template)

local function SetArrowVisible(visible)
	for _, part in ipairs(Stadium.Model.Interactables.PenaltySpot.Arrow:GetChildren()) do
		part.Transparency = visible and 0 or 1
	end
end

Stadium.Name = "Stadium"
Stadium.WaitAnimation = mapAnimations.CrouchReady
Stadium.Music = music.Stadium

function Stadium.GetOrigin()
	return Stadium.Model.Interactables.PenaltySpot.Spot.CFrame
end

function Stadium.GetDirection()
	return Stadium.Model.Interactables.PenaltySpot.Arrow:GetPivot().LookVector
end

function Stadium.GetSeat()
	return Stadium.Model.Interactables.PenaltySpot
end

function Stadium.OnLoad()
	SetArrowVisible(true)
	local animator = Stadium.Model.Interactables.PenaltySpot.Kicker.Humanoid.Animator
	track = animator:LoadAnimation(mapAnimations.GoalkeeperRunKick)
end

function Stadium.OnAim(pitch, yaw)
	local penalty = Stadium.Model.Interactables.PenaltySpot
	local pivot = penalty.Spot.CFrame
	local yawRotation = CFrame.fromAxisAngle(pivot.UpVector, -math.rad(yaw))
	local pitchRotation = CFrame.fromAxisAngle(pivot.RightVector, math.rad(pitch))
	penalty.Arrow:PivotTo(CFrame.new(pivot.Position) * yawRotation * pitchRotation)
end

function Stadium.OnFire()
	SetArrowVisible(false)
	local penalty = Stadium.Model.Interactables.PenaltySpot
	local root = penalty.Kicker.HumanoidRootPart
	local tween = TweenService:Create(root, TweenInfo.new(RUN_TIME, Enum.EasingStyle.Linear), { CFrame = penalty.KickSpot.CFrame })
	tween:Play()
	track:Play()
	tween.Completed:Wait()
	sounds.Play(mapSounds.Kick, penalty.KickSpot.Position)
end

function Stadium.OnUnload()
	SetArrowVisible(false)
	track:Destroy()
	track = nil
	local root = Stadium.Model.Interactables.PenaltySpot.Kicker.HumanoidRootPart
	root.CFrame = template.Interactables.PenaltySpot.Kicker.HumanoidRootPart.CFrame
end

return Stadium
