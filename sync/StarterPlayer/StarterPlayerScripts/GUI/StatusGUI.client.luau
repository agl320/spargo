local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TextService = game:GetService("TextService")
local TweenService = game:GetService("TweenService")

local sounds = SoundService:WaitForChild("GUI")
local upNextSound = sounds:WaitForChild("UpNext")

local events = ReplicatedStorage:WaitForChild("Events")
local gameStarted = events:WaitForChild("GameStarted")
local gameEnded = events:WaitForChild("GameEnded")
local turnStarted = events:WaitForChild("TurnStarted")
local turnEnded = events:WaitForChild("TurnEnded")

local player = Players.LocalPlayer
local gui = player.PlayerGui

local screen = gui:WaitForChild("StatusGUI")
local frame = screen:WaitForChild("Frame")
local banner = frame:WaitForChild("BannerLabel")
local titleLabel = frame:WaitForChild("TitleLabel")
local statusLabel = frame:WaitForChild("StatusLabel")

local IMAGE_WIDTH = 160
local IMAGE_HEIGHT = 56
local IMAGE_EDGE = 26
local IMAGE_BAND = 12
local BANNER_SCALE = 2.15
local BANNER_PADDING = 16
local BANNER_TIME = 0.4

-- Size the banner off the title text so the art always frames it. At the default
-- TextSize of 26 this lands on 56, the source image's own height, so the caps draw
-- at their authored size and SliceScale stays at 1.
local BANNER_HEIGHT = math.round(titleLabel.TextSize * BANNER_SCALE)

local TWEEN_IN = TweenInfo.new(BANNER_TIME, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local TWEEN_OUT = TweenInfo.new(BANNER_TIME, Enum.EasingStyle.Quint, Enum.EasingDirection.In)

-- The caps are the outer IMAGE_EDGE columns, held rigid by the 9-slice while the
-- middle stretches. SliceScale maps them from source pixels to the drawn height.
local sliceScale = BANNER_HEIGHT / IMAGE_HEIGHT
local edgeWidth = IMAGE_EDGE * 2 * sliceScale

-- Only the X cuts matter here; the Y cuts just can't be zero-width, which Roblox
-- refuses to draw. Since BANNER_HEIGHT is IMAGE_HEIGHT * sliceScale, every row
-- squashes by the same factor, so where the Y cuts land doesn't change the result.
banner.ScaleType = Enum.ScaleType.Slice
banner.SliceCenter = Rect.new(IMAGE_EDGE, IMAGE_BAND, IMAGE_WIDTH - IMAGE_EDGE, IMAGE_HEIGHT - IMAGE_BAND)
banner.SliceScale = sliceScale

-- TitleLabel is top-anchored in Frame, so centre the banner on its midline.
banner.AnchorPoint = Vector2.new(0.5, 0.5)
banner.Position = titleLabel.Position + UDim2.fromOffset(0, titleLabel.Size.Y.Offset / 2)

-- The label is authored with a partly transparent stroke; fade to that, not to 0.
local titleStroke = titleLabel.TextStrokeTransparency

local token = 0

local function MeasureWidth(label)
	local params = Instance.new("GetTextBoundsParams")
	params.Text = label.Text
	params.Font = label.FontFace
	params.Size = label.TextSize
	params.Width = 10000
	return TextService:GetTextBoundsAsync(params).X
end

local function Animate(width, transparency, info)
	TweenService:Create(banner, info, {
		Size = UDim2.fromOffset(width, BANNER_HEIGHT),
		ImageTransparency = transparency
	}):Play()
	TweenService:Create(titleLabel, info, {
		TextTransparency = transparency,
		TextStrokeTransparency = transparency + (1 - transparency) * titleStroke
	}):Play()
end

local function ShowBanner(text)
	token += 1
	titleLabel.Text = text
	banner.Size = UDim2.fromOffset(edgeWidth, BANNER_HEIGHT)
	banner.ImageTransparency = 1
	titleLabel.TextTransparency = 1
	titleLabel.TextStrokeTransparency = 1
	screen.Enabled = true
	Animate(MeasureWidth(titleLabel) + BANNER_PADDING * 2 + edgeWidth, 0, TWEEN_IN)
end

local function HideBanner()
	token += 1
	local id = token
	Animate(edgeWidth, 1, TWEEN_OUT)
	task.delay(BANNER_TIME, function()
		if token ~= id then return end
		screen.Enabled = false
	end)
end

local function GetProgress(order, count)
	return "Turn " .. count .. "/" .. #order .. " complete"
end

gameStarted.OnClientEvent:Connect(function(mapName, modeName)
	statusLabel.Text = ""
	ShowBanner(mapName .. " - " .. modeName)
end)

turnStarted.OnClientEvent:Connect(function(order, index)
	if order[index] == player.UserId then
		statusLabel.Text = "Aim at the target to get points!"
	elseif order[index + 1] == player.UserId then
		statusLabel.Text = "You're up next, get ready!"
		SoundService:PlayLocalSound(upNextSound)
	else
		statusLabel.Text = GetProgress(order, index - 1)
	end
end)

turnEnded.OnClientEvent:Connect(function(order, index)
	if order[index + 1] == player.UserId then
		statusLabel.Text = "You're up next, get ready!"
	else
		statusLabel.Text = GetProgress(order, index)
	end
end)

gameEnded.OnClientEvent:Connect(HideBanner)

gameStarted:FireServer()
