local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TextService = game:GetService("TextService")
local TweenService = game:GetService("TweenService")

local sounds = SoundService:WaitForChild("GUI")
local upNextSound = sounds:WaitForChild("UpNext")

local events = ReplicatedStorage:WaitForChild("Events")
local mapEvents = events:WaitForChild("Map")
local gameModeEvents = events:WaitForChild("GameMode")
local gameEvents = events:WaitForChild("Game")
local turnEvents = events:WaitForChild("Turn")

local functions = ReplicatedStorage:WaitForChild("Functions")
local mapFunctions = functions:WaitForChild("Map")
local gameModeFunctions = functions:WaitForChild("GameMode")
local turnFunctions = functions:WaitForChild("Turn")

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
local BANNER_PADDING = 16
local BANNER_INSET = 11
local BANNER_DELAY = 0.5
local BANNER_TIME = 0.4
local TAG_TEXT = "NOW PLAYING"
local TAG_COLOUR = Color3.fromRGB(16, 32, 52)
local TAG_HEIGHT = 20
local TAG_PADDING = 10
local TAG_GAP = 2

local TWEEN_IN = TweenInfo.new(BANNER_TIME, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local TWEEN_OUT = TweenInfo.new(BANNER_TIME, Enum.EasingStyle.Quint, Enum.EasingDirection.In)

-- The tag stacks above the title, so the banner has to frame both. Grow Frame by the
-- same amount and StatusLabel, being bottom-anchored, stays clear of the taller banner.
local tagTop = titleLabel.Position.Y.Offset
local contentHeight = TAG_HEIGHT + TAG_GAP + titleLabel.Size.Y.Offset
local BANNER_HEIGHT = contentHeight + BANNER_INSET * 2

frame.Size += UDim2.fromOffset(0, TAG_HEIGHT + TAG_GAP)
titleLabel.Position = UDim2.new(0.5, 0, 0, tagTop + TAG_HEIGHT + TAG_GAP)

local tagLabel = Instance.new("TextLabel")
tagLabel.Name = "TagLabel"
tagLabel.Text = TAG_TEXT
tagLabel.FontFace = titleLabel.FontFace
tagLabel.TextSize = 14
tagLabel.TextColor3 = Color3.new(1, 1, 1)
tagLabel.BackgroundColor3 = TAG_COLOUR
tagLabel.AnchorPoint = Vector2.new(0.5, 0)
tagLabel.Position = UDim2.new(0.5, 0, 0, tagTop)
tagLabel.Size = UDim2.fromOffset(0, TAG_HEIGHT)
tagLabel.AutomaticSize = Enum.AutomaticSize.X
tagLabel.BorderSizePixel = 0

local tagPadding = Instance.new("UIPadding")
tagPadding.PaddingLeft = UDim.new(0, TAG_PADDING)
tagPadding.PaddingRight = UDim.new(0, TAG_PADDING)
tagPadding.Parent = tagLabel

local tagCorner = Instance.new("UICorner")
tagCorner.CornerRadius = UDim.new(0, TAG_HEIGHT // 2)
tagCorner.Parent = tagLabel

tagLabel.Parent = frame

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

-- Centre the banner on the tag-plus-title block rather than on the title alone.
banner.AnchorPoint = Vector2.new(0.5, 0.5)
banner.Position = UDim2.new(0.5, 0, 0, tagTop + contentHeight / 2)

-- The label is authored with a partly transparent stroke; fade to that, not to 0.
local titleStroke = titleLabel.TextStrokeTransparency

local token = 0
local map = nil

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
	TweenService:Create(tagLabel, info, {
		TextTransparency = transparency,
		BackgroundTransparency = transparency
	}):Play()
end

-- Held back by BANNER_DELAY so the banner doesn't snap in the instant a map swaps.
local function ShowBanner(text)
	token += 1
	local id = token
	task.delay(BANNER_DELAY, function()
		if token ~= id then return end
		titleLabel.Text = text
		banner.Size = UDim2.fromOffset(edgeWidth, BANNER_HEIGHT)
		banner.ImageTransparency = 1
		titleLabel.TextTransparency = 1
		titleLabel.TextStrokeTransparency = 1
		tagLabel.TextTransparency = 1
		tagLabel.BackgroundTransparency = 1
		screen.Enabled = true

		local inner = math.max(MeasureWidth(titleLabel), MeasureWidth(tagLabel) + TAG_PADDING * 2)
		if token ~= id then return end
		Animate(inner + BANNER_PADDING * 2 + edgeWidth, 0, TWEEN_IN)
	end)
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

local function OnMapLoaded(mapName)
	map = mapName
end

local function OnGameModeStarted(modeName)
	statusLabel.Text = ""
	ShowBanner(map .. " - " .. modeName)
end

local function OnTurnStarted(order, index)
	if order[index] == player.UserId then
		statusLabel.Text = "Aim at the target to get points!"
	elseif order[index + 1] == player.UserId then
		statusLabel.Text = "You're up next, get ready!"
		SoundService:PlayLocalSound(upNextSound)
	else
		statusLabel.Text = GetProgress(order, index - 1)
	end
end

local function OnTurnEnded(order, index)
	if order[index + 1] == player.UserId then
		statusLabel.Text = "You're up next, get ready!"
	else
		statusLabel.Text = GetProgress(order, index)
	end
end

mapEvents:WaitForChild("Loaded").OnClientEvent:Connect(OnMapLoaded)
gameModeEvents:WaitForChild("Started").OnClientEvent:Connect(OnGameModeStarted)
turnEvents:WaitForChild("Started").OnClientEvent:Connect(OnTurnStarted)
turnEvents:WaitForChild("Ended").OnClientEvent:Connect(OnTurnEnded)
gameEvents:WaitForChild("Ended").OnClientEvent:Connect(HideBanner)

local mapName = mapFunctions:WaitForChild("Get"):InvokeServer()
if mapName then OnMapLoaded(mapName) end

local modeName = gameModeFunctions:WaitForChild("Get"):InvokeServer()
if modeName then OnGameModeStarted(modeName) end

local started, order, index = turnFunctions:WaitForChild("Get"):InvokeServer()
if started then
	OnTurnStarted(order, index)
elseif order then
	OnTurnEnded(order, index)
end
