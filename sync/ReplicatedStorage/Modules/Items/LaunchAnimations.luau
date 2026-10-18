local ReplicatedStorage = game:GetService("ReplicatedStorage")

local assets = ReplicatedStorage:WaitForChild("Assets")
local animations = assets:WaitForChild("Animations")
local launchAnimations = animations:WaitForChild("Launch")

return {
	Default = {
		Animation = launchAnimations:WaitForChild("Default"),
	},
	Cannonball = {
		Animation = launchAnimations:WaitForChild("Cannonball"),
		Price = 100,
	},
	Cartoon = {
		Animation = launchAnimations:WaitForChild("Cartoon"),
		Price = 100,
	},
	Eagle = {
		Animation = launchAnimations:WaitForChild("Eagle"),
		Price = 100,
	},
	Glow = {
		Animation = launchAnimations:WaitForChild("Glow"),
		Price = 100,
	},
	Nonchalant = {
		Animation = launchAnimations:WaitForChild("Nonchalant"),
		Price = 100,
	},
	Starfish = {
		Animation = launchAnimations:WaitForChild("Starfish"),
		Price = 100,
	},
	Superhero = {
		Animation = launchAnimations:WaitForChild("Superhero"),
		Price = 100,
	},
}
