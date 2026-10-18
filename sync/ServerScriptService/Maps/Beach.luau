local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local SoundService = game:GetService("SoundService")

local maps = ServerStorage.Maps
local template = maps.Beach

local utils = ServerScriptService.Utils
local map = require(utils.Map)
local sounds = require(utils.Sounds)

local assets = ReplicatedStorage.Assets
local animations = assets.Animations
local mapAnimations = animations.Map

local gameplay = SoundService.Gameplay
local mapSounds = gameplay.Map
local music = SoundService.Music

local Beach = map.new(template)

Beach.Name = "Beach"
Beach.WaitAnimation = mapAnimations.TorpedoLookAround
Beach.Music = music.Beach

function Beach.GetOrigin()
	return Beach.Model.Interactables.Cannon.Barrel.Muzzle.CFrame
end

function Beach.GetDirection()
	return Beach.GetOrigin().LookVector
end

function Beach.GetSeat()
	return Beach.Model.Interactables.Cannon.Barrel
end

function Beach.OnAim(pitch, yaw)
	local cannon = Beach.Model.Interactables.Cannon
	local pivot = Beach.Model:GetPivot()
	local position = cannon.Barrel.Pivot.CFrame.Position
	local yawRotation = CFrame.fromAxisAngle(pivot.UpVector, -math.rad(yaw))
	local pitchRotation = CFrame.fromAxisAngle(pivot.RightVector, math.rad(pitch))
	cannon:PivotTo(CFrame.new(position) * yawRotation)
	cannon.Barrel:PivotTo(CFrame.new(position) * yawRotation * pitchRotation)
end

function Beach.OnFire()
	sounds.Play(mapSounds.CannonFire, Beach.GetOrigin().Position)
end

return Beach
