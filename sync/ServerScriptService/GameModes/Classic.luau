local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local events = ReplicatedStorage.Events
local showResults = events.ShowResults
local showScore = events.ShowScore
local turnStarted = events.TurnStarted
local turnEnded = events.TurnEnded

local utils = ServerScriptService.Utils
local launcher = require(utils.Launcher)
local clones = require(utils.Clones)
local paint = require(utils.Paint)
local spawner = require(utils.Spawner)
local timer = require(utils.Timer)
local focus = require(utils.Focus)

local dataStore = ServerScriptService.DataStore
local coins = require(dataStore.Coins)

local START_DELAY = 4
local SWAP_TIME = 4
local TURN_TIME = 12
local SCORE_DELAY = 2.5
local SPLAT_DELAY = 5
local END_DELAY = 4
local RESULTS_TIME = 6
local COINS_TIME = 3
local WALK_SPEED = 32

local players = {}
local turn = nil

local function SendTurn(event, order, index)
	turn = { Event = event, Order = order, Index = index }
	event:FireAllClients(order, index)
end

local Classic = {}

Classic.Name = "Classic"

function Classic.Sync(player)
	if turn then turn.Event:FireClient(player, turn.Order, turn.Index) end
end

function Classic.Start(map)
	timer.Start(START_DELAY, "Classic starting...")
	task.wait(START_DELAY)

	players = Players:GetPlayers()
	if #players == 0 then return end

	spawner.Respawn(players, map.GetSpawn(), function(character)
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid then humanoid.WalkSpeed = WALK_SPEED end
	end)

	Random.new():Shuffle(players)
	local order = {}
	for _, player in ipairs(players) do
		table.insert(order, player.UserId)
	end
	local scores = {}

	for index, player in ipairs(players) do
		if not player.Parent then
			SendTurn(turnEnded, order, index)
			continue
		end

		SendTurn(turnStarted, order, index)
		timer.Start(SWAP_TIME, player.DisplayName .. "'s turn starting...")
		task.wait(SWAP_TIME)

		if not player.Parent then
			SendTurn(turnEnded, order, index)
			continue
		end
		launcher.Load(player, map)
		local character = player.Character
		focus.Set(character and character:FindFirstChild("HumanoidRootPart"))

		timer.Start(TURN_TIME, player.DisplayName .. "'s Turn")

		local hit = launcher.Fire(player, TURN_TIME, timer.Stop)

		if player.Parent then
			local points = hit and hit.Instance:GetAttribute("Points") or 0
			table.insert(scores, { Player = player, Name = player.DisplayName, Score = points })

			if hit then
				paint.Splat(hit.Position, hit.Normal)
				task.wait(SCORE_DELAY)
				if points > 0 and player.Parent then showScore:FireAllClients(player, map.GetRings(), points) end
				task.wait(SPLAT_DELAY)
				clones.Create(player)
			end
		end

		focus.Clear()
		launcher.Unload(player)
		SendTurn(turnEnded, order, index)
	end

	table.sort(scores, function(first, second)
		return first.Score > second.Score
	end)
	task.wait(END_DELAY)
	showResults:FireAllClients(scores, RESULTS_TIME)
	task.wait(RESULTS_TIME)
	for _, entry in ipairs(scores) do
		coins.Add(entry.Player, entry.Score)
	end
	task.wait(COINS_TIME)
	clones.Clear()
	paint.Clear()

	spawner.Respawn(players)
	turn = nil
end

return Classic
