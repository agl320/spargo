local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local sounds = SoundService:WaitForChild("GUI")
local collectSound = sounds:WaitForChild("CollectCoin")
local clickSound = sounds:WaitForChild("Click")

local events = ReplicatedStorage:WaitForChild("Events")
local updateCoins = events:WaitForChild("UpdateCoins")

local player = Players.LocalPlayer
local gui = player.PlayerGui
local scripts = player.PlayerScripts
local utils = scripts:WaitForChild("Utils")

local screen = gui:WaitForChild("CoinsGUI")
local frame = screen:WaitForChild("Frame")
local amountLabel = frame:WaitForChild("AmountLabel")
local template = frame:WaitForChild("CoinTemplate")
local buyButton = frame:WaitForChild("BuyButton")

local storeGUI = gui:WaitForChild("StoreGUI")

local activePanel = require(utils:WaitForChild("ActivePanel"))

local COIN_COUNT_MIN, COIN_COUNT_MAX = 1, 40
local BURST_RADIUS_MIN, BURST_RADIUS_MAX = 20, 80
local BURST_TIME = 0.4
local BURST_HOLD = 0.2
local FUNNEL_TIME = 0.2
local FUNNEL_STAGGER = 0.04

local current = nil
local displayed = 0

local function SetLabel(amount)
	displayed = amount
	local text = tostring(amount)
	while true do
		local replaced
		text, replaced = text:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
		if replaced == 0 then break end
	end
	amountLabel.Text = text
end

updateCoins.OnClientEvent:Connect(function(amount)
	if current and amount > current then
		local gained = amount - current
		local count = math.random(COIN_COUNT_MIN, math.clamp(gained, COIN_COUNT_MIN, COIN_COUNT_MAX))
		local share = math.floor(gained / count)
		local center = screen.AbsoluteSize / 2 - frame.AbsolutePosition
		local offset = BURST_TIME + BURST_HOLD
		for index = 1, count do
			local angle = math.random() * math.pi * 2
			local target = center + Vector2.new(math.cos(angle), math.sin(angle)) * math.random(BURST_RADIUS_MIN, BURST_RADIUS_MAX)
			local coin = template:Clone()
			coin.Name = "Coin"
			coin.Position = UDim2.fromOffset(center.X, center.Y)
			coin.Rotation = math.random(0, 359)
			coin.Visible = true
			coin.Parent = frame
			TweenService:Create(coin, TweenInfo.new(BURST_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Position = UDim2.fromOffset(target.X, target.Y)
			}):Play()
			task.delay(offset, function()
				local tween = TweenService:Create(coin, TweenInfo.new(FUNNEL_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
					Position = template.Position
				})
				tween.Completed:Once(function()
					coin:Destroy()
					SoundService:PlayLocalSound(collectSound)
					SetLabel(displayed + (index == count and gained - share * (count - 1) or share))
				end)
				tween:Play()
			end)
			offset += FUNNEL_STAGGER
		end
	else
		SetLabel(amount)
	end
	current = amount
end)

buyButton.Activated:Connect(function()
	SoundService:PlayLocalSound(clickSound)
	activePanel.Toggle(storeGUI)
end)

updateCoins:FireServer()
