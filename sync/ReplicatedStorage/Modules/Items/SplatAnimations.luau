local ReplicatedStorage = game:GetService("ReplicatedStorage")

local assets = ReplicatedStorage:WaitForChild("Assets")
local animations = assets:WaitForChild("Animations")

return {
	Default = {
		Animation = animations:WaitForChild("DefaultSplat"),
	},
	Cannonball = {
		Animation = animations:WaitForChild("CannonballSplat"),
	},
	Cartoon = {
		Animation = animations:WaitForChild("CartoonSplat"),
	},
	Eagle = {
		Animation = animations:WaitForChild("EagleSplat"),
	},
	Glow = {
		Animation = animations:WaitForChild("GlowSplat"),
	},
	Nonchalant = {
		Animation = animations:WaitForChild("NonchalantSplat"),
	},
	Starfish = {
		Animation = animations:WaitForChild("StarfishSplat"),
	},
	Superhero = {
		Animation = animations:WaitForChild("SuperheroSplat"),
	},
}
