local SoundService = game:GetService("SoundService")

local sounds = SoundService:WaitForChild("Effects")

return {
	Default = {
		Sound = sounds:WaitForChild("DefaultLaunch"),
	},
	Floating = {
		Sound = sounds:WaitForChild("FloatingLaunch"),
	},
	KingJulien = {
		Sound = sounds:WaitForChild("KingJulienLaunch"),
	},
	Leeroy = {
		Sound = sounds:WaitForChild("LeeroyLaunch"),
	},
	Nacho = {
		Sound = sounds:WaitForChild("NachoLaunch"),
	},
	Rocket = {
		Sound = sounds:WaitForChild("RocketLaunch"),
	},
	WeePigs = {
		Sound = sounds:WaitForChild("WeePigsLaunch"),
	},
	Yippee = {
		Sound = sounds:WaitForChild("YippeeLaunch"),
	},
}
