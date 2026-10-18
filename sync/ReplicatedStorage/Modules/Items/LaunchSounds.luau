local SoundService = game:GetService("SoundService")

local gameplay = SoundService:WaitForChild("Gameplay")
local launchSounds = gameplay:WaitForChild("Launch")

return {
	Default = {
		Sound = launchSounds:WaitForChild("Default"),
	},
	Floating = {
		Sound = launchSounds:WaitForChild("Floating"),
		Price = 100,
	},
	KingJulien = {
		Sound = launchSounds:WaitForChild("KingJulien"),
		Price = 100,
	},
	Leeroy = {
		Sound = launchSounds:WaitForChild("Leeroy"),
		Price = 100,
	},
	Nacho = {
		Sound = launchSounds:WaitForChild("Nacho"),
		Price = 100,
	},
	Rocket = {
		Sound = launchSounds:WaitForChild("Rocket"),
		Price = 100,
	},
	WeePigs = {
		Sound = launchSounds:WaitForChild("WeePigs"),
		Price = 100,
	},
	Yippee = {
		Sound = launchSounds:WaitForChild("Yippee"),
		Price = 100,
	},
}
