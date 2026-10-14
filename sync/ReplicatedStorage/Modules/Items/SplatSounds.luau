local SoundService = game:GetService("SoundService")

local sounds = SoundService:WaitForChild("Effects")

return {
	Default = {
		Sound = sounds:WaitForChild("DefaultSplat"),
	},
	Bamboo = {
		Sound = sounds:WaitForChild("BambooSplat"),
	},
	BoneCrack = {
		Sound = sounds:WaitForChild("BoneCrackSplat"),
	},
	Bonk = {
		Sound = sounds:WaitForChild("BonkSplat"),
	},
	Bruh = {
		Sound = sounds:WaitForChild("BruhSplat"),
	},
	Egg = {
		Sound = sounds:WaitForChild("EggSplat"),
	},
	HighOof = {
		Sound = sounds:WaitForChild("HighOofSplat"),
	},
	LowOof = {
		Sound = sounds:WaitForChild("LowOofSplat"),
	},
	Oof = {
		Sound = sounds:WaitForChild("OofSplat"),
	},
	Punch = {
		Sound = sounds:WaitForChild("PunchSplat"),
	},
	Retro = {
		Sound = sounds:WaitForChild("RetroSplat"),
	},
	Slap = {
		Sound = sounds:WaitForChild("SlapSplat"),
	},
	Taco = {
		Sound = sounds:WaitForChild("TacoSplat"),
	},
	VineBoom = {
		Sound = sounds:WaitForChild("VineBoomSplat"),
	},
}
