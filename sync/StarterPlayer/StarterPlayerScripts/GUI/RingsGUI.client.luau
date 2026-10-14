local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local gui = player.PlayerGui
local camera = workspace.CurrentCamera

local screen = gui:WaitForChild("RingsGUI")
local template = screen:WaitForChild("LineTemplate")

local LINE_COUNT = 48

local outlines = {}
local points = {}

local function AddRings(rings)
	local lines = {}
	for index = 1, LINE_COUNT do
		local line = template:Clone()
		line.Name = "Line"
		line.Parent = screen
		lines[index] = line
	end
	outlines[rings] = lines
end

for _, rings in ipairs(CollectionService:GetTagged("Rings")) do
	AddRings(rings)
end

CollectionService:GetInstanceAddedSignal("Rings"):Connect(AddRings)

CollectionService:GetInstanceRemovedSignal("Rings"):Connect(function(rings)
	local lines = outlines[rings]
	if not lines then return end
	for _, line in ipairs(lines) do
		line:Destroy()
	end
	outlines[rings] = nil
end)

RunService.PreRender:Connect(function()
	for rings, lines in pairs(outlines) do
		local edge = nil
		for _, part in ipairs(rings:GetChildren()) do
			if part:IsA("BasePart") and (not edge or part.Size.Y > edge.Size.Y) then edge = part end
		end
		if not edge then
			for _, line in ipairs(lines) do
				line.Visible = false
			end
			continue
		end
		local radius = edge.Size.Y / 2
		for index = 1, LINE_COUNT do
			local angle = index / LINE_COUNT * math.pi * 2
			points[index] = camera:WorldToViewportPoint(edge.CFrame * (Vector3.new(0, math.cos(angle), math.sin(angle)) * radius))
		end
		for index, line in ipairs(lines) do
			local first, second = points[index], points[index % LINE_COUNT + 1]
			local delta = Vector2.new(second.X - first.X, second.Y - first.Y)
			line.Visible = first.Z > 0 and second.Z > 0
			line.Position = UDim2.fromOffset((first.X + second.X) / 2, (first.Y + second.Y) / 2)
			line.Size = UDim2.fromOffset(delta.Magnitude + 1, template.Size.Y.Offset)
			line.Rotation = math.deg(math.atan2(delta.Y, delta.X))
		end
	end
end)
