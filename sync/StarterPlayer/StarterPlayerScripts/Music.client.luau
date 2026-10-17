local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local music = SoundService:WaitForChild("Music")
local lobby = music:WaitForChild("Lobby")
local intermission = music:WaitForChild("Intermission")

local events = ReplicatedStorage:WaitForChild("Events")
local gameStarted = events:WaitForChild("GameStarted")
local gameEnded = events:WaitForChild("GameEnded")
local playCutscene = events:WaitForChild("PlayCutscene")

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

gameStarted.OnClientEvent:Connect(function(_, _, sound)
	track = sound
	Play(lobby)
end)

playCutscene.OnClientEvent:Connect(function()
	Play(track)
end)

gameEnded.OnClientEvent:Connect(function()
	Play(intermission)
end)

Play(intermission)

gameStarted:FireServer()
