local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local sounds = SoundService:WaitForChild("GUI")
local clickSound = sounds:WaitForChild("Click")
local purchaseSound = sounds:WaitForChild("Purchase")

local modules = ReplicatedStorage:WaitForChild("Modules")
local items = require(modules:WaitForChild("Items"))

local events = ReplicatedStorage:WaitForChild("Events")
local inventoryEvents = events:WaitForChild("Inventory")

local functions = ReplicatedStorage:WaitForChild("Functions")
local storeFunctions = functions:WaitForChild("Store")
local inventoryFunctions = functions:WaitForChild("Inventory")

local player = Players.LocalPlayer
local gui = player.PlayerGui

local screen = gui:WaitForChild("StoreGUI")
local frame = screen:WaitForChild("Frame")
local title = frame:WaitForChild("TitleLabel")
local tabsFrame = frame:WaitForChild("TabsFrame")
local launchAnimationsButton = tabsFrame:WaitForChild("LaunchAnimationsButton")
local launchSoundsButton = tabsFrame:WaitForChild("LaunchSoundsButton")
local splatAnimationsButton = tabsFrame:WaitForChild("SplatAnimationsButton")
local splatSoundsButton = tabsFrame:WaitForChild("SplatSoundsButton")
local itemsFrame = frame:WaitForChild("ItemsFrame")
local template = itemsFrame:WaitForChild("ItemTemplate")

local TAB_CATEGORIES = {
	[launchAnimationsButton] = "LaunchAnimations",
	[launchSoundsButton] = "LaunchSounds",
	[splatAnimationsButton] = "SplatAnimations",
	[splatSoundsButton] = "SplatSounds",
}

local owned = {}
local selected = launchAnimationsButton

local function Render()
	local key = TAB_CATEGORIES[selected]
	title.Text = selected.Text
	for button in pairs(TAB_CATEGORIES) do
		button.UIStroke.Enabled = button == selected
	end
	for _, button in ipairs(itemsFrame:GetChildren()) do
		if button.Name == "Item" then button:Destroy() end
	end
	local names = {}
	for name, item in pairs(items[key]) do
		if item.Price then table.insert(names, name) end
	end
	table.sort(names)
	for index, name in ipairs(names) do
		local bought = table.find(owned[key] or {}, name)
		local button = template:Clone()
		button.Name = "Item"
		button.Text = name .. "\n" .. (bought and "Owned" or items[key][name].Price)
		button.LayoutOrder = index
		button.Visible = true
		if not bought then
			button.Activated:Connect(function()
				if storeFunctions:WaitForChild("Buy"):InvokeServer(key, name) then SoundService:PlayLocalSound(purchaseSound) end
			end)
		end
		button.Parent = itemsFrame
	end
end

for button in pairs(TAB_CATEGORIES) do
	button.Activated:Connect(function()
		SoundService:PlayLocalSound(clickSound)
		selected = button
		Render()
	end)
end

local function OnInventoryUpdated(newOwned)
	owned = newOwned
	Render()
end

inventoryEvents:WaitForChild("Updated").OnClientEvent:Connect(OnInventoryUpdated)

OnInventoryUpdated(inventoryFunctions:WaitForChild("Get"):InvokeServer())
