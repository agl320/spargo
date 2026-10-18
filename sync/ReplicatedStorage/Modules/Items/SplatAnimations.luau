local ReplicatedStorage = game:GetService("ReplicatedStorage")

local assets = ReplicatedStorage:WaitForChild("Assets")
local animations = assets:WaitForChild("Animations")
local splatAnimations = animations:WaitForChild("Splat")

return {
	Default = {
		Animation = splatAnimations:WaitForChild("Default"),
	},
	Cannonball = {
		Animation = splatAnimations:WaitForChild("Cannonball"),
		Price = 100,
	},
	Cartoon = {
		Animation = splatAnimations:WaitForChild("Cartoon"),
		Price = 100,
	},
	Eagle = {
		Animation = splatAnimations:WaitForChild("Eagle"),
		Price = 100,
	},
	Glow = {
		Animation = splatAnimations:WaitForChild("Glow"),
		Price = 100,
	},
	Nonchalant = {
		Animation = splatAnimations:WaitForChild("Nonchalant"),
		Price = 100,
	},
	Starfish = {
		Animation = splatAnimations:WaitForChild("Starfish"),
		Price = 100,
	},
	Superhero = {
		Animation = splatAnimations:WaitForChild("Superhero"),
		Price = 100,
	},
}
