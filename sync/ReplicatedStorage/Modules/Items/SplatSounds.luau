local SoundService = game:GetService("SoundService")

local gameplay = SoundService:WaitForChild("Gameplay")
local splatSounds = gameplay:WaitForChild("Splat")

return {
	Default = {
		Sound = splatSounds:WaitForChild("Default"),
	},
	Bamboo = {
		Sound = splatSounds:WaitForChild("Bamboo"),
		Price = 100,
	},
	BoneCrack = {
		Sound = splatSounds:WaitForChild("BoneCrack"),
		Price = 100,
	},
	Bonk = {
		Sound = splatSounds:WaitForChild("Bonk"),
		Price = 100,
	},
	Bruh = {
		Sound = splatSounds:WaitForChild("Bruh"),
		Price = 100,
	},
	Egg = {
		Sound = splatSounds:WaitForChild("Egg"),
		Price = 100,
	},
	HighOof = {
		Sound = splatSounds:WaitForChild("HighOof"),
		Price = 100,
	},
	LowOof = {
		Sound = splatSounds:WaitForChild("LowOof"),
		Price = 100,
	},
	Oof = {
		Sound = splatSounds:WaitForChild("Oof"),
		Price = 100,
	},
	Punch = {
		Sound = splatSounds:WaitForChild("Punch"),
		Price = 100,
	},
	Retro = {
		Sound = splatSounds:WaitForChild("Retro"),
		Price = 100,
	},
	Slap = {
		Sound = splatSounds:WaitForChild("Slap"),
		Price = 100,
	},
	Taco = {
		Sound = splatSounds:WaitForChild("Taco"),
		Price = 100,
	},
	VineBoom = {
		Sound = splatSounds:WaitForChild("VineBoom"),
		Price = 100,
	},
}
