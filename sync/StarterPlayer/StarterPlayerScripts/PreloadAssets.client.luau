local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local StarterGui = game:GetService("StarterGui")
local TextService = game:GetService("TextService")

local assets = ReplicatedStorage:WaitForChild("Assets")
local effects = SoundService:WaitForChild("Effects")

for _, descendant in ipairs(StarterGui:GetDescendants()) do
	if descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox") then
		local params = Instance.new("GetTextBoundsParams")
		params.Text = descendant.Text
		params.Font = descendant.FontFace
		params.Size = descendant.TextSize
		pcall(TextService.GetTextBoundsAsync, TextService, params)
	end
end

ContentProvider:PreloadAsync(assets:GetDescendants())
ContentProvider:PreloadAsync(effects:GetChildren())
