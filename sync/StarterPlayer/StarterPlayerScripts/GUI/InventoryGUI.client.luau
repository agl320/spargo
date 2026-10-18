local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local sounds = SoundService:WaitForChild("GUI")
local sound = sounds:WaitForChild("Click")

local events = ReplicatedStorage:WaitForChild("Events")
local inventoryEvents = events:WaitForChild("Inventory")

local functions = ReplicatedStorage:WaitForChild("Functions")
local inventoryFunctions = functions:WaitForChild("Inventory")

local player = Players.LocalPlayer
local gui = player.PlayerGui

local screen = gui:WaitForChild("InventoryGUI")
local frame = screen:WaitForChild("Frame")
local title = frame:WaitForChild("TitleLabel")
local tabsFrame = frame:WaitForChild("TabsFrame")
local launchAnimationsButton = tabsFrame:WaitForChild("LaunchAnimationsButton")
local launchSoundsButton = tabsFrame:WaitForChild("LaunchSoundsButton")
local splatAnimationsButton = tabsFrame:WaitForChild("SplatAnimationsButton")
local splatSoundsButton = tabsFrame:WaitForChild("SplatSoundsButton")
local itemsFrame = frame:WaitForChild("ItemsFrame")
local template = itemsFrame:WaitForChild("ItemTemplate")
local equippedFrame = frame:WaitForChild("EquippedFrame")
local equippedLabel = equippedFrame:WaitForChild("NameLabel")

local TAB_CATEGORIES = {
	[launchAnimationsButton] = "LaunchAnimations",
	[launchSoundsButton] = "LaunchSounds",
	[splatAnimationsButton] = "SplatAnimations",
	[splatSoundsButton] = "SplatSounds",
}

local owned = {}
local equipped = {}
local selected = launchAnimationsButton

local function Render()
	local key = TAB_CATEGORIES[selected]
	title.Text = selected.Text
	for button in pairs(TAB_CATEGORIES) do
		button.UIStroke.Enabled = button == selected
	end
	for _, item in ipairs(itemsFrame:GetChildren()) do
		if item.Name == "Item" then item:Destroy() end
	end
	for index, name in ipairs(owned[key] or {}) do
		local item = template:Clone()
		item.Name = "Item"
		item.Text = name
		item.LayoutOrder = index
		item.Visible = true
		item.Activated:Connect(function()
			SoundService:PlayLocalSound(sound)
			inventoryEvents:WaitForChild("Equip"):FireServer(key, name)
		end)
		item.Parent = itemsFrame
	end
	equippedLabel.Text = equipped[key] or ""
end

for button in pairs(TAB_CATEGORIES) do
	button.Activated:Connect(function()
		SoundService:PlayLocalSound(sound)
		selected = button
		Render()
	end)
end

local function OnInventoryUpdated(newOwned, newEquipped)
	owned = newOwned
	equipped = newEquipped
	Render()
end

inventoryEvents:WaitForChild("Updated").OnClientEvent:Connect(OnInventoryUpdated)

OnInventoryUpdated(inventoryFunctions:WaitForChild("Get"):InvokeServer())
