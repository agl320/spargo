local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local utils = ServerScriptService.Utils
local caster = require(utils.Caster)
local sounds = require(utils.Sounds)

local dataStore = ServerScriptService.DataStore
local inventory = require(dataStore.Inventory)

local events = ReplicatedStorage.Events
local launcherAim = events.LauncherAim
local launcherFire = events.LauncherFire
local launcherLoad = events.LauncherLoad
local launcherUnload = events.LauncherUnload
local launcherFired = events.LauncherFired
local launcherHit = events.LauncherHit
local playAnimation = events.PlayAnimation

local modules = ReplicatedStorage.Modules
local aim = require(modules.Aim)

local LAUNCH_GRAVITY = Vector3.new(0, -10, 0)
local LAUNCH_DISTANCE = 1000
local LAUNCH_SPEED = 100

local launchers = {}

local function IsNumber(value)
	return typeof(value) == "number" and value == value
end

local Launcher = {}

function Launcher.Load(player, map)
	local character = player.Character
	if character then
		local root = character:FindFirstChild("HumanoidRootPart")
		if root then root.Anchored = true end
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.WalkSpeed = 0
			humanoid.JumpHeight = 0
		end
		character:PivotTo(map.GetOrigin())
		character.Parent = map.GetSeat()
	end
	map.OnLoad()
	launchers[player] = { Map = map }
	map.OnAim(0, 0)
	launcherLoad:FireAllClients(player)
	playAnimation:FireClient(player, map.WaitAnimation)
end

function Launcher.Fire(player, duration, onAimEnd)
	local launcher = launchers[player]
	local expiry = duration and (workspace:GetServerTimeNow() + duration) or math.huge
	repeat task.wait() until launcher.Power or workspace:GetServerTimeNow() >= expiry or not player.Parent
	if onAimEnd then onAimEnd() end
	if not player.Parent then return nil end

	if not launcher.Power then
		local character = player.Character
		if character then character.Parent = workspace end
		return nil
	end

	local origin = launcher.Map.GetOrigin()
	local direction = launcher.Map.GetDirection()
	launcher.Map.OnFire()
	if not player.Parent then return nil end
	launcherFired:FireAllClients(player, launcher.Power)

	local character = player.Character
	if character then character.Parent = workspace end
	playAnimation:FireClient(player, inventory.GetItem(player, "LaunchAnimations").Animation)
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local sound = root and sounds.Attach(inventory.GetItem(player, "LaunchSounds").Sound, root)

	local done = false
	local hit = nil
	caster.Fire(origin.Position, direction, launcher.Power * LAUNCH_SPEED, {
		Distance = LAUNCH_DISTANCE,
		Gravity = LAUNCH_GRAVITY,
		OnStep = function(position, direction)
			if character then character:PivotTo(CFrame.lookAt(position, position + direction)) end
		end,
		OnHit = function(result)
			hit = result
			if character then character:PivotTo(CFrame.lookAt(result.Position + result.Normal * 0.3, result.Position)) end
			done = true
		end,
		OnMiss = function()
			done = true
		end
	})

	repeat task.wait() until done
	if sound then sound:Destroy() end
	if not player.Parent then return nil end

	if hit then
		launcherHit:FireAllClients(player, hit.Position)
		playAnimation:FireClient(player, inventory.GetItem(player, "SplatAnimations").Animation)
		sounds.Play(inventory.GetItem(player, "SplatSounds").Sound, hit.Position)
	end

	return hit
end

function Launcher.Unload(player)
	local launcher = launchers[player]
	launcher.Map.OnUnload()
	launcherUnload:FireAllClients(player)
	launchers[player] = nil
	if player.Parent then player:LoadCharacterAsync() end
end

launcherAim.OnServerEvent:Connect(function(player, pitch, yaw)
	local launcher = launchers[player]
	if not launcher or launcher.Power or not IsNumber(pitch) or not IsNumber(yaw) then return end
	launcher.Map.OnAim(math.clamp(pitch, aim.PITCH_ANGLE_MIN, aim.PITCH_ANGLE_MAX), math.clamp(yaw, aim.YAW_ANGLE_MIN, aim.YAW_ANGLE_MAX))
end)

launcherFire.OnServerEvent:Connect(function(player, power)
	local launcher = launchers[player]
	if not launcher or not IsNumber(power) then return end
	launcher.Power = math.clamp(power, 0, 1)
end)

launcherLoad.OnServerEvent:Connect(function(player)
	for active in pairs(launchers) do
		launcherLoad:FireClient(player, active)
	end
end)

return Launcher