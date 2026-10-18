local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local utils = ServerScriptService.Utils
local caster = require(utils.Caster)
local sounds = require(utils.Sounds)

local dataStore = ServerScriptService.DataStore
local inventory = require(dataStore.Inventory)

local events = ReplicatedStorage.Events
local launcherEvents = events.Launcher
local animationEvents = events.Animation

local functions = ReplicatedStorage.Functions
local launcherFunctions = functions.Launcher

local modules = ReplicatedStorage.Modules
local aim = require(modules.Aim)

local LAUNCH_GRAVITY = Vector3.new(0, -10, 0)
local LAUNCH_DISTANCE = 1000
local LAUNCH_SPEED = 100
local SPLAT_OFFSET = 0.3

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
	launcherEvents.Loaded:FireAllClients(player)
	animationEvents.Play:FireClient(player, map.WaitAnimation)
end

function Launcher.Fire(player, duration, onAimEnd)
	local launcher = launchers[player]
	if not launcher then return nil end
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
	launcherEvents.Fired:FireAllClients(player, launcher.Power)

	local character = player.Character
	if character then character.Parent = workspace end
	animationEvents.Play:FireClient(player, inventory.GetItem(player, "LaunchAnimations").Animation)
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local sound = root and sounds.Attach(inventory.GetItem(player, "LaunchSounds").Sound, root)

	local done = false
	local hit = nil
	caster.Fire(origin.Position, direction, launcher.Power * LAUNCH_SPEED, {
		Distance = LAUNCH_DISTANCE,
		Gravity = LAUNCH_GRAVITY,
		OnStep = function(position, facing)
			if character then character:PivotTo(CFrame.lookAt(position, position + facing)) end
		end,
		OnHit = function(result)
			hit = result
			if character then character:PivotTo(CFrame.lookAt(result.Position + result.Normal * SPLAT_OFFSET, result.Position)) end
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
		launcherEvents.Hit:FireAllClients(player, hit.Position)
		animationEvents.Play:FireClient(player, inventory.GetItem(player, "SplatAnimations").Animation)
		sounds.Play(inventory.GetItem(player, "SplatSounds").Sound, hit.Position)
	end

	return hit
end

function Launcher.Unload(player)
	local launcher = launchers[player]
	if not launcher then return end
	launcher.Map.OnUnload()
	launcherEvents.Unloaded:FireAllClients(player)
	launchers[player] = nil
	if player.Parent then player:LoadCharacterAsync() end
end

launcherEvents.Aim.OnServerEvent:Connect(function(player, pitch, yaw)
	local launcher = launchers[player]
	if not launcher or launcher.Power or not IsNumber(pitch) or not IsNumber(yaw) then return end
	launcher.Map.OnAim(math.clamp(pitch, aim.PITCH_ANGLE_MIN, aim.PITCH_ANGLE_MAX), math.clamp(yaw, aim.YAW_ANGLE_MIN, aim.YAW_ANGLE_MAX))
end)

launcherEvents.Fire.OnServerEvent:Connect(function(player, power)
	local launcher = launchers[player]
	if not launcher or not IsNumber(power) then return end
	launcher.Power = math.clamp(power, 0, 1)
end)

launcherFunctions.Get.OnServerInvoke = function()
	local active = {}
	for player in pairs(launchers) do
		table.insert(active, player)
	end
	return active
end

return Launcher