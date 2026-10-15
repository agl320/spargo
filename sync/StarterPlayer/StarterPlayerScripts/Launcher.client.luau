local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local events = ReplicatedStorage:WaitForChild("Events")
local launcherLoad = events:WaitForChild("LauncherLoad")
local launcherUnload = events:WaitForChild("LauncherUnload")
local launcherAim = events:WaitForChild("LauncherAim")
local launcherFired = events:WaitForChild("LauncherFired")
local launcherHit = events:WaitForChild("LauncherHit")
local playAnimation = events:WaitForChild("PlayAnimation")

local modules = ReplicatedStorage:WaitForChild("Modules")
local aim = require(modules:WaitForChild("Aim"))

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local scripts = player.PlayerScripts
local utils = scripts:WaitForChild("Utils")

local playerModule = require(scripts:WaitForChild("PlayerModule"))
local cameraShake = require(utils:WaitForChild("CameraShake"))
local subject = require(utils:WaitForChild("Subject"))
local controls = playerModule:GetControls()

local AIM_SPEED = 50

local active = false
local pitch = 0
local yaw = 0
local currentTrack = nil

launcherLoad.OnClientEvent:Connect(function(sender)
	if sender == player then
		pitch = 0
		yaw = 0
		active = true
	end
end)

launcherUnload.OnClientEvent:Connect(function(sender)
	if sender == player then active = false end
end)

launcherFired.OnClientEvent:Connect(function(sender, power)
	if sender == player then active = false end
	if subject.Is(sender) then cameraShake.Launch(power) end
end)

launcherHit.OnClientEvent:Connect(function(sender)
	if subject.Is(sender) then cameraShake.Hit() end
end)

camera:GetPropertyChangedSignal("CameraSubject"):Connect(cameraShake.Stop)

playAnimation.OnClientEvent:Connect(function(animation)
	local character = player.Character
	if not character then return end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end
	local animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then return end
	if currentTrack then currentTrack:Stop() end
	currentTrack = animator:LoadAnimation(animation)
	currentTrack:Play()
end)

RunService.PreRender:Connect(function(delta)
	if not active then return end
	local move = controls:GetMoveVector()
	yaw = math.clamp(yaw + move.X * AIM_SPEED * delta, aim.YAW_ANGLE_MIN, aim.YAW_ANGLE_MAX)
	pitch = math.clamp(pitch - move.Z * AIM_SPEED * delta, aim.PITCH_ANGLE_MIN, aim.PITCH_ANGLE_MAX)
	if move.Magnitude > 0 then launcherAim:FireServer(pitch, yaw) end
end)
