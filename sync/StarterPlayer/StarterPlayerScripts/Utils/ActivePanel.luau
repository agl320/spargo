local active = nil

local ActivePanel = {}

function ActivePanel.Open(screen)
	if active == screen then return end
	if active then active.Enabled = false end
	screen.Enabled = true
	active = screen
end

function ActivePanel.Close()
	if active then active.Enabled = false end
	active = nil
end

function ActivePanel.Toggle(screen)
	if active == screen then
		ActivePanel.Close()
	else
		ActivePanel.Open(screen)
	end
end

return ActivePanel
