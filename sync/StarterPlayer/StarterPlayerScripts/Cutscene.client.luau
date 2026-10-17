local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local events = ReplicatedStorage:WaitForChild("Events")
local playCutscene = events:WaitForChild("PlayCutscene")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local scripts = player.PlayerScripts
local utils = scripts:WaitForChild("Utils")

local subject = require(utils:WaitForChild("Subject"))

local BIND_NAME = "Cutscene"
local FOCUS_DISTANCE = 100
local CURVE_SAMPLES = 20

local function GetCFrame(points, alpha)
	local cframes = table.clone(points)
	for count = #cframes - 1, 1, -1 do
		for index = 1, count do
			cframes[index] = cframes[index]:Lerp(cframes[index + 1], alpha)
		end
	end
	return cframes[1]
end

playCutscene.OnClientEvent:Connect(function(shots, timestamp, duration)
	local total = 0
	for _, shot in ipairs(shots) do
		shot.Time = 0
		local previous = GetCFrame(shot.Points, 0).Position
		for step = 1, CURVE_SAMPLES do
			local position = GetCFrame(shot.Points, step / CURVE_SAMPLES).Position
			shot.Time += (position - previous).Magnitude
			previous = position
		end
		total += shot.Time
	end
	for _, shot in ipairs(shots) do
		shot.Time = total > 0 and duration * shot.Time / total or duration / #shots
	end

	camera.CameraType = Enum.CameraType.Scriptable
	RunService:BindToRenderStep(BIND_NAME, Enum.RenderPriority.Camera.Value, function()
		local elapsed = workspace:GetServerTimeNow() - timestamp
		if elapsed >= duration then
			RunService:UnbindFromRenderStep(BIND_NAME)
			camera.CameraType = Enum.CameraType.Custom
			subject.Set(player)
			return
		end
		local active = nil
		local progress = 0
		for _, shot in ipairs(shots) do
			active = shot
			progress = elapsed / shot.Time
			if progress < 1 then break end
			elapsed -= shot.Time
		end
		local cframe = GetCFrame(active.Points, TweenService:GetValue(progress, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut))
		camera.CFrame = cframe
		camera.Focus = cframe * CFrame.new(0, 0, -FOCUS_DISTANCE)
	end)
end)
