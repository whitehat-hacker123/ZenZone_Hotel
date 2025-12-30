local prompt = script.Parent
local ReplicatedStorage = game:GetService("ReplicatedStorage")

prompt.Triggered:Connect(function(player)
	
	local breadGui = player:WaitForChild("PlayerGui"):FindFirstChild("BreadGui")--add ur directory
	if breadGui then
		breadGui.Enabled = true
	end
end)
