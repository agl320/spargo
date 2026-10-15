local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local sounds = SoundService:WaitForChild("GUI")
local bullseyeSound = sounds:WaitForChild("BullseyeScore")
local ringSound = sounds:WaitForChild("RingScore")

local events = ReplicatedStorage:WaitForChild("Events")
local showScore = events:WaitForChild("ShowScore")
local launcherUnload = events:WaitForChild("LauncherUnload")

local player = Players.LocalPlayer
local gui = player.PlayerGui
local scripts = player.PlayerScripts
local utils = scripts:WaitForChild("Utils")
local camera = workspace.CurrentCamera

local screen = gui:WaitForChild("ScoreGUI")
local titleLabel = screen:WaitForChild("TitleLabel")
local pointsLabel = titleLabel:WaitForChild("PointsLabel")
local titleScale = titleLabel:WaitForChild("UIScale")
local pointsScale = pointsLabel:WaitForChild("UIScale")

local subject = require(utils:WaitForChild("Subject"))

local CAMERA_TIME = 1.5
local POP_TIME = 0.25
local POINTS_DELAY = 0.5
local SCORE_DELAY = 0.5
local VIEW_WIDTH = 3
local VIEW_HEIGHT = 1.4
local EDGE_PADDING = 64

local tween = nil
local lit = nil
local material = nil

local function Pop(scale)
	scale.Scale = 0
	local pop = TweenService:Create(scale, TweenInfo.new(POP_TIME, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Scale = 1
	})
	pop:Play()
	return pop
end

local function EndCutscene()
	if tween then
		tween:Cancel()
		tween = nil
	end
	screen.Enabled = false
	if lit then
		lit.Material = material
		lit = nil
	end
	if camera.CameraType == Enum.CameraType.Scriptable then camera.CameraType = Enum.CameraType.Custom end
end

showScore.OnClientEvent:Connect(function(shooter, rings, points)
	if not rings then return end
	local bullseye = 0
	local hit = nil
	for _, descendant in ipairs(rings:GetDescendants()) do
		local value = descendant:GetAttribute("Points")
		if value and value > bullseye then bullseye = value end
		if value == points then hit = descendant end
	end

	lit = hit
	material = hit.Material
	task.delay(CAMERA_TIME, function()
		if lit == hit then hit.Material = Enum.Material.Neon end
	end)

	if not subject.Is(shooter) then return end
	local sound = points == bullseye and bullseyeSound or ringSound

	local box, size = rings:GetBoundingBox()
	local aspect = camera.ViewportSize.X / camera.ViewportSize.Y
	local distance = math.max(size.X * VIEW_WIDTH / aspect, size.Y * VIEW_HEIGHT) / (2 * math.tan(math.rad(camera.FieldOfView) / 2))
	local goal = CFrame.lookAt(box.Position + box.LookVector * distance, box.Position)

	camera.CameraType = Enum.CameraType.Scriptable
	camera:GetPropertyChangedSignal("CameraSubject"):Once(EndCutscene)
	tween = TweenService:Create(camera, TweenInfo.new(CAMERA_TIME, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
		CFrame = goal
	})
	tween.Completed:Once(function(state)
		if state ~= Enum.PlaybackState.Completed then return end
		task.wait(SCORE_DELAY)
		if lit ~= hit then return end
		local edge = camera:WorldToViewportPoint(box.Position + goal.RightVector * size.X / 2 - goal.LookVector * size.Z / 2)
		pointsLabel.Text = tostring(points)
		pointsScale.Scale = 0
		titleScale.Scale = 1
		screen.Enabled = true
		titleLabel.Position = UDim2.fromOffset(edge.X + EDGE_PADDING + titleLabel.AbsoluteSize.X / 2, edge.Y)
		Pop(titleScale).Completed:Once(function()
			task.wait(POINTS_DELAY)
			if lit ~= hit then return end
			SoundService:PlayLocalSound(sound)
			Pop(pointsScale)
		end)
	end)
	tween:Play()
end)

launcherUnload.OnClientEvent:Connect(EndCutscene)