local prox = script.parent
local rep = game.ReplicatedStorage:FindFirstChild("Cup")

prox.Triggered:connect(function(player)
	if player.WaitForChild("Cup") then
		-- add warning message
	else
		local new = rep:Clone()
	
		new.Parent = player:WaitForChild("Backpack")
	end
end)
