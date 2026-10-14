local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local music = SoundService:WaitForChild("Music")
local lobby = music:WaitForChild("Lobby")
local intermission = music:WaitForChild("Intermission")

local events = ReplicatedStorage:WaitForChild("Events")
local gameStarted = events:WaitForChild("GameStarted")
local gameEnded = events:WaitForChild("GameEnded")
local turnStarted = events:WaitForChild("TurnStarted")
local turnEnded = events:WaitForChild("TurnEnded")

local player = Players.LocalPlayer

local FADE_TIME = 1

local volumes = {}
local current = nil
local track = nil

local function Play(sound)
	if sound == current then return end
	if current then
		local previous = current
		local fade = TweenService:Create(previous, TweenInfo.new(FADE_TIME), { Volume = 0 })
		fade.Completed:Once(function(state)
			if state == Enum.PlaybackState.Completed then previous:Stop() end
		end)
		fade:Play()
	end
	current = sound
	volumes[sound] = volumes[sound] or sound.Volume
	if not sound.IsPlaying then
		sound.Volume = 0
		sound:Play()
	end
	TweenService:Create(sound, TweenInfo.new(FADE_TIME), { Volume = volumes[sound] }):Play()
end

local function OnTurn(order)
	Play(table.find(order, player.UserId) and track or lobby)
end

gameStarted.OnClientEvent:Connect(function(_, _, sound)
	track = sound
end)

turnStarted.OnClientEvent:Connect(OnTurn)
turnEnded.OnClientEvent:Connect(OnTurn)

gameEnded.OnClientEvent:Connect(function()
	Play(intermission)
end)

Play(lobby)

gameStarted:FireServer()
