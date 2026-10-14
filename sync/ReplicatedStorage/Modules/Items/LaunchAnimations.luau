local ReplicatedStorage = game:GetService("ReplicatedStorage")

local assets = ReplicatedStorage:WaitForChild("Assets")
local animations = assets:WaitForChild("Animations")

return {
	Default = {
		Animation = animations:WaitForChild("DefaultLaunch"),
	},
	Cannonball = {
		Animation = animations:WaitForChild("CannonballLaunch"),
	},
	Cartoon = {
		Animation = animations:WaitForChild("CartoonLaunch"),
	},
	Eagle = {
		Animation = animations:WaitForChild("EagleLaunch"),
	},
	Glow = {
		Animation = animations:WaitForChild("GlowLaunch"),
	},
	Nonchalant = {
		Animation = animations:WaitForChild("NonchalantLaunch"),
	},
	Starfish = {
		Animation = animations:WaitForChild("StarfishLaunch"),
	},
	Superhero = {
		Animation = animations:WaitForChild("SuperheroLaunch"),
	},
}
