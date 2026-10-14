local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")

local sounds = SoundService:WaitForChild("GUI")
local clickSound = sounds:WaitForChild("Click")

local player = Players.LocalPlayer
local gui = player.PlayerGui
local scripts = player.PlayerScripts
local utils = scripts:WaitForChild("Utils")

local screen = gui:WaitForChild("NavigationGUI")
local frame = screen:WaitForChild("Frame")

local questsButton = frame:WaitForChild("QuestsButton")
local statisticsButton = frame:WaitForChild("StatisticsButton")
local settingsButton = frame:WaitForChild("SettingsButton")
local inventoryButton = frame:WaitForChild("InventoryButton")
local storeButton = frame:WaitForChild("StoreButton")

local questsGUI = gui:WaitForChild("QuestsGUI")
local statisticsGUI = gui:WaitForChild("StatisticsGUI")
local settingsGUI = gui:WaitForChild("SettingsGUI")
local inventoryGUI = gui:WaitForChild("InventoryGUI")
local storeGUI = gui:WaitForChild("StoreGUI")

local activePanel = require(utils:WaitForChild("ActivePanel"))

local BUTTON_PANELS = {
	[questsButton] = questsGUI,
	[statisticsButton] = statisticsGUI,
	[settingsButton] = settingsGUI,
	[inventoryButton] = inventoryGUI,
	[storeButton] = storeGUI,
}

for button, panel in pairs(BUTTON_PANELS) do
	button.Activated:Connect(function()
		SoundService:PlayLocalSound(clickSound)
		activePanel.Toggle(panel)
	end)
end
